//


//


//

import UIKit
import AVKit
import AudioUnit
import SmartDeviceCoreSDK
import Lottie

import BaseUI

@objc public protocol A4xMediaPlayerViewProtocol: AnyObject {
    func magicPixEnableSettingAction(_ enable: Bool)
    func playBtnClickAction(_ selected: Bool)
    func seekAction(_ progress: Float)
}

//MARK: - 自定义视频播放器
public class A4xMediaPlayerView: UIView {
    
    weak var `protocol`: A4xMediaPlayerViewProtocol?
    
    public var controlBarHidden: ((Bool) -> Void)?
    
    var isLandscape: Bool {
        get {
            return A4xAppSettingManager.shared.orientationIsLandscape()
        }
    }

    public var currentDuration: Float? {
        didSet {
            self.playInfoUpdate()
        }
    }
    
    public var duration: Float?
    
    private var isPlaying: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.videoMaskImgV?.isHidden = true
        self.bottomImageV?.isHidden = false
        self.playButton.isHidden = false
        self.startTimeLabel.isHidden = false
        self.progressSlider.isHidden = false
        self.totalTimeLabel.isHidden = false
        self.loadingView.isHidden = true
        self.mediaContentView.isHidden = false
    }
    
    public override var frame: CGRect {
        didSet {
            
            
            self.scrollView.frame = self.frame
            self.mediaContentView.frame = self.frame
            
            updateBgFrame()
            
            let isPortrait = !self.isLandscape
            self.playButton.snp.updateConstraints({ (make) in
                make.bottom.equalTo(self.snp.bottom).offset(isPortrait ? -5.auto() : -25.auto())
            })
        }
    }
    
    deinit {
        
    }
    
    
    private var totalTimeFormat: String {
        let totalTime = self.duration ?? 0.0
        if totalTime.isNaN {
            return "00:00"
        }
        return String.init(format: "%02zd:%02zd", Int(totalTime / 60), Int(totalTime.truncatingRemainder(dividingBy: 60.0)))
    }
    
    
    private var currentTimeFormat: String {
        let playTime = self.currentDuration ?? 0.0
        if playTime.isNaN {
            return "00:00"
        }
        return String.init(format: "%02zd:%02zd", Int(playTime / 60), Int(playTime.truncatingRemainder(dividingBy: 60.0)))
    }
    
    private func playInfoUpdate() {
        
        self.startTimeLabel.text = self.currentTimeFormat
        if self.totalTimeFormat != self.totalTimeLabel.text {
            self.totalTimeLabel.text = self.totalTimeFormat
        }
    }
    
    @objc public func mediaPlayerUpdateState(state: A4xMediaPlayerState, _ playTime: Float = 0.0, _ isCacheDone: Bool = false, _ errorInfo: String? = "") {
        
        switch state {
        case .none:
            break
        case .cache:
            if isCacheDone {
                self.loadingView.stopAnimail()
                self.playButton.isEnabled = true
            } else {
                self.playButton.isEnabled = true
                self.loadingView.startAnimail()
            }
        case .playing:
            self.isPlaying = true
            self.progressSlider.value = playTime / floor((max(1, self.duration ?? 0.0)))
            self.startTimeLabel.text = self.currentTimeFormat
            self.playButton.isSelected = true
        case .comple:
            self.isPlaying = false
            self.loadingView.stopAnimail()
            self.playButton.isSelected = false
            self.playButton.isEnabled = true
        case .pause:
            self.isPlaying = false
            self.progressSlider.value = (self.currentDuration ?? 0.0) / floor((max(1, self.duration ?? 0.0)))
            
            if self.playButton.layer.animationKeys()?.count ?? 0 > 0 {
                self.playButton.layer.removeAllAnimations()
            }
            
            self.playButton.isSelected = false
            self.loadingView.stopAnimail()
        case .stop:
            self.isPlaying = false
            if self.playButton.layer.animationKeys()?.count ?? 0 > 0 {
                self.playButton.layer.removeAllAnimations()
            }
            
            self.playButton.isSelected = false
            self.loadingView.stopAnimail()
        case .error:
            self.isPlaying = false
            if self.playButton.layer.animationKeys()?.count ?? 0 > 0 {
                self.playButton.layer.removeAllAnimations()
            }
            
            self.loadingView.stopAnimail()
            DispatchQueue.main.a4xAfter(0.0) {
                self.playButton.isSelected = false
            }
            
            if A4xUserDataHandle.Handle?.netConnectType == .nonet {
                UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "failed_to_get_information_and_try"))
            } else {
                
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateBgFrame() {
        self.videoMaskImgV?.isHidden = !self.isLandscape
    }
    
    lazy var bottomImageV: UIImageView? = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("video_play_bottom_shard_bg")?.rtlImage().resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 1, bottom: 0, right: 1))
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.edges.equalTo(videoMaskImgV!.snp.edges)
        })
        
        return temp
    }()
    
    
    lazy var mediaContentView: A4xMediaContentView = {
        let temp = A4xMediaContentView()
        self.scrollView.addSubview(temp)
        temp.isUserInteractionEnabled = true
        let rec = UITapGestureRecognizer(target: self, action: #selector(showControlBar(sender:)))
        temp.addGestureRecognizer(rec)
        return temp
    }()
    
    @objc func showControlBar(sender: UITapGestureRecognizer) {
        if !isLandscape {
            return
        }
        let show = self.playButton.isHidden
        controlBarHidden?(!show)
        self.playButton.isHidden = !show
        self.startTimeLabel.isHidden = !show
        self.progressSlider.isHidden = !show
        self.totalTimeLabel.isHidden = !show
        self.bottomImageV?.isHidden = !show
        self.videoMaskImgV?.isHidden = !show || !isLandscape
    }
    
    lazy var panRecognier: UITapGestureRecognizer = {
        let rec = UITapGestureRecognizer(target: self, action: #selector(panVideoAction(sender:)))
        rec.numberOfTapsRequired = 2
        return rec
    }()
    
    @objc func panVideoAction(sender: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let temp = UIScrollView()
        temp.backgroundColor = .clear
        temp.delegate = self
        temp.showsVerticalScrollIndicator = false
        temp.showsHorizontalScrollIndicator = false
        temp.minimumZoomScale = 1
        temp.maximumZoomScale = 3
        temp.addGestureRecognizer(panRecognier)
        self.addSubview(temp)
        return temp
    }()
    
    //MARK:- view 创建
    lazy var loadingView: A4xVideoLoadingView = {
        let temp = A4xVideoLoadingView()
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.snp.edges)
        })
        return temp
    }()
    
    lazy private var videoMaskImgV: UIImageView? = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("video_play_bottom_shard_bg")?.rtlImage().resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 1, bottom: 0, right: 1))
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(100)
            make.leading.equalTo(0)
            make.width.equalTo(self.snp.width)
        })
        
        return temp
    }()
    
    lazy var progressSlider: UISlider = {
        let temp = UISlider()
        temp.setThumbImage(bundleImageFromImageName("slider_thumb")?.rtlImage(), for: .normal)
        temp.setMaximumTrackImage(bundleImageFromImageName("slider_max")?.rtlImage().resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 4, bottom: 1, right: 4)), for: .normal)
        temp.setMinimumTrackImage(bundleImageFromImageName("slider_min")?.rtlImage().resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 4, bottom: 1, right: 4)), for: .normal)
        temp.value = 0
        temp.addTarget(self, action: #selector(playSeekBeginAction(sender:)), for: .touchDown)
        temp.addTarget(self, action: #selector(playSeekEndAction(sender:)), for: .touchUpInside)
        temp.addTarget(self, action: #selector(playSeekEndAction(sender:)), for: .touchUpOutside)
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.startTimeLabel.snp.trailing).offset(8)
            make.trailing.equalTo(self.totalTimeLabel.snp.leading).offset(-8)
            make.centerY.equalTo(self.playButton.snp.centerY)
        })
        
        if A4xBaseManager.shared.isRTL() {
            temp.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        } else {
            temp.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        }
        
        return temp
    }()
    
    lazy var startTimeLabel: UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.B2
        temp.textColor = UIColor.white
        temp.adjustsFontSizeToFitWidth = true
        self.addSubview(temp)
        temp.text = "00.00"
        let width = 40
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.playButton.snp.trailing).offset(8)
            make.centerY.equalTo(self.playButton.snp.centerY)
            make.width.equalTo(width)
        })
        return temp
    } ()
    
    lazy var totalTimeLabel: UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.B2
        temp.textColor = UIColor.white
        temp.adjustsFontSizeToFitWidth = true
        temp.textAlignment = .right
        self.addSubview(temp)
        temp.text = "00.00"
        let width = 40
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-15)
            make.centerY.equalTo(self.playButton.snp.centerY)
            make.width.equalTo(width)
            
        })
        return temp
    } ()
    
    lazy var playButton: UIButton = {
        let temp = UIButton()
        temp.setImage(bundleImageFromImageName("av_video_pause")?.rtlImage(), for: .selected)
        temp.setImage(bundleImageFromImageName("av_video_play")?.rtlImage(), for: .normal)
        temp.addTarget(self, action: #selector(playVideoAction), for: .touchUpInside)
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(4.auto())
            make.size.equalTo(CGSize(width: 40.auto(), height: 40.auto()))
            make.bottom.equalTo(self.snp.bottom).offset(isLandscape ? -40.auto() : -5.auto())
        })
        return temp
    }()
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let isShow = !self.playButton.isHidden
        var show = isShow
        if isShow && (self.isPlaying) {
            show = false
        } else if !isShow {
            show = true
        }
        
        controlBarHidden?(!show)
        self.playButton.isHidden = !show
        self.startTimeLabel.isHidden = !show
        self.progressSlider.isHidden = !show
        self.totalTimeLabel.isHidden = !show
        self.bottomImageV?.isHidden = !show
        self.videoMaskImgV?.isHidden = !show || !isLandscape
    }

}


extension A4xMediaPlayerView {
    @objc func playSeekBeginAction(sender: UISlider) {
        progressSlider.setThumbImage(bundleImageFromImageName("slider_thumb_bigger")?.rtlImage(), for: .normal) 
        //self.mediaContentView.pausePlay()
        self.protocol?.playBtnClickAction(true)
    }
    
    @objc func playSeekEndAction(sender: UISlider) {
        progressSlider.setThumbImage(bundleImageFromImageName("slider_thumb")?.rtlImage(), for: .normal) 
        //self.mediaContentView.seek(progress: sender.value)
        self.protocol?.seekAction(sender.value)
    }
    
    @objc func playVideoAction() {
        if self.playButton.isSelected {
            //self.mediaContentView.pausePlay()
        } else {
            //self.mediaContentView.startPlay()
        }
        self.protocol?.playBtnClickAction(self.playButton.isSelected)
    }
    
   
}

//
extension A4xMediaPlayerView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mediaContentView
    }
}


public class A4xMediaContentView: UIView {
    override public class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
  
    public override var frame: CGRect {
        didSet {
        }
    }
}
