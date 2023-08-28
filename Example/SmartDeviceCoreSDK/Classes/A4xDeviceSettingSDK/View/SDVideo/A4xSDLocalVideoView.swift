//
//  A4xSDLocalVideoView.swift
//  AddxAi
//
//  Created by kzhi on 2020/1/9.
//  Copyright © 2020 addx.ai. All rights reserved.
//

import Foundation
import SmartDeviceCoreSDK
import A4xLiveVideoUIKit
import Lottie
import BaseUI

protocol A4xSDLocalVideoViewProtocol: class {
    func sdVideoVolumeAction(enable : Bool)
    func sdVideoScreenShot(view : UIView)
    func sdVideoRecordVideo(start : Bool)
    func sdVideoFull()
    func sdVideoPlay(comple: @escaping (Bool) -> Void)
    func sdVideoStop()
}

class A4xSDLocalVideoView: UIView {
    
    private let itemSize : CGSize = CGSize(width: 52.auto(), height: 52.auto())
    private let itemImageSize : CGSize = CGSize(width: 24, height: 24)
    
    private var recoredTime : Int = 0
    private var autoHiddenTime: TimeInterval = 3
    private var isAutoHidden: Bool = false
    
    public var recordState : A4xLiveRecoredState = .stop {
        didSet{
            updataRecoredState()
        }
    }
    
    /// 视频播放状态
    var videoState: (Int, String?)? = (A4xPlayerStateType.paused.rawValue, nil) {
        didSet {
            logDebug("-----------> sd videoState didSet:\(videoState?.0 ?? .none)")
            if oldValue?.0 != videoState?.0 {
                self.videoStateUpdate()
            }
            
        }
    }
    
    var audioEnable: Bool = false {
        didSet {
            self.volumeButton.isSelected = !audioEnable
        }
    }
    
    
    weak var `protocol` : A4xSDLocalVideoViewProtocol?
    
    var dataSource : DeviceBean?
    
    init(frame: CGRect = .zero, model: DeviceBean = DeviceBean()) {
        self.dataSource = model
        super.init(frame: frame)
        self.bottomImageV?.isHidden = false
        self.topImageV?.isHidden = false
        self.loadingView.isHidden = true
        self.recordButton.isHidden = false
        self.screenShotButton.isHidden = false
        self.volumeButton.isHidden = false
        self.playBtn.isHidden = true
        self.fullButton.isHidden = true
        videoStateUpdate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var videoView: UIView? {
        didSet {
            if self.videoView == nil {
                return
            }
            self.videoView?.translatesAutoresizingMaskIntoConstraints = true
            self.videoView?.backgroundColor = UIColor.clear
            self.videoView?.frame = self.bounds
            self.insertSubview(videoView!, at: 0)
        }
    }
    
    lazy private var contentView: A4xFullLiveVideoContentView =  {
        let temp = A4xFullLiveVideoContentView()
        self.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            if #available(iOS 11.0,*) {
                make.edges.equalTo(self.safeAreaLayoutGuide.snp.edges)
            }else {
                make.edges.equalTo(self.snp.edges)
            }
        }
        
        return temp
    }()
    
    lazy var topImageV: UIImageView? = {
        let temp = UIImageView()
        temp.backgroundColor = UIColor.clear
        temp.image = bundleImageFromImageName("video_play_top_share")?.rtlImage()//?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 2, bottom: 0, right: 2))
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.snp.top)
            make.height.equalTo(60.auto())
            make.leading.equalTo(0)
            make.width.equalTo(self.snp.width)
        })
        
        return temp
    }()
    
    lazy var bottomImageV: UIImageView? = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("video_play_bottom_shard_bg")?.rtlImage().resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 1, bottom: 0, right: 1))
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(60.auto())
            make.leading.equalTo(0)
            make.width.equalTo(self.snp.width)
        })
        
        return temp
    }()
    
    lazy var recoredTimeLabel: UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.backgroundColor = UIColor(white: 0, alpha: 0.3)
        temp.layer.cornerRadius = 12
        temp.clipsToBounds = true
        temp.font = ADTheme.B2
        temp.textColor = UIColor.white
        temp.isHidden = true
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(10.auto())
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.width.equalTo(65)
            make.height.equalTo(24)
        })
        
        return temp
    }()
    
    lazy var recordButton: UIButton = {
        let temp = UIButton()
        temp.setImage(bundleImageFromImageName("live_video_record_normail")?.rtlImage(), for: .normal)
        temp.setImage(bundleImageFromImageName("live_sd_record_selected")?.rtlImage(), for: .selected)
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.contentHorizontalAlignment = .center
        temp.contentMode = .center
        self.contentView.addSubview(temp)

        temp.addTarget(self, action: #selector(videoRecordVideo(sender:)), for: UIControl.Event.touchUpInside)
        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let right = -12

        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.screenShotButton.snp.centerY)
            make.centerX.equalTo(self.snp.centerX).offset(-25.auto())
            make.size.equalTo(itemSize)
        })
        return temp
    }()
 
    lazy var screenShotButton: UIButton = {
        let temp = UIButton()
        temp.setImage(bundleImageFromImageName("video_live_screen_shot")?.rtlImage(), for: .normal)
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.contentHorizontalAlignment = .center
        temp.contentMode = .center

        self.contentView.addSubview(temp)

        temp.addTarget(self, action: #selector(videoScreenShot(sender:)), for: UIControl.Event.touchUpInside)
        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let right = 0

        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.centerX.equalTo(self.snp.centerX).offset(25.auto())
            make.size.equalTo(itemSize)
        })
        return temp
    }()
    
    lazy var volumeButton: UIButton = {
        let temp = UIButton()
        temp.setImage(bundleImageFromImageName("video_live_volume")?.rtlImage(), for: .normal)
        temp.setImage(bundleImageFromImageName("video_live_volume_mute")?.rtlImage(), for: .selected)
        
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.contentHorizontalAlignment = .center
        temp.contentMode = .center
        
        self.contentView.addSubview(temp)
        
        temp.addTarget(self, action: #selector(videoVolumeAction(sender:)), for: UIControl.Event.touchUpInside)

        
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.screenShotButton.snp.centerY)
            make.leading.equalTo(10.auto())
            make.size.equalTo(itemSize)
        })
        return temp
    }()
    
    
    lazy var fullButton: UIButton = {
        let temp = UIButton()
        temp.setImage(bundleImageFromImageName("video_full_screen")?.rtlImage(), for: .normal)
        temp.setImage(bundleImageFromImageName("video_exit_full_screen")?.rtlImage(), for: .selected)
        temp.addTarget(self, action: #selector(fullAction), for: .touchUpInside)
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-10.auto())
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalTo(self.screenShotButton.snp.centerY)
        })
        return temp
    }()
    
   //MARK:- view 创建
    lazy var playBtn: UIButton = {
        let temp = UIButton()
        temp.setImage(bundleImageFromImageName("video_play")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("video_pause")?.rtlImage(), for: UIControl.State.selected)
        temp.addTarget(self, action: #selector(playVideoAction(sender:)), for: .touchUpInside)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: 70.auto(), height: 70.auto()))
        })
        return temp
    }()
    
    //MARK:- view 创建
    lazy var loadingView: A4xBaseLoadingView = {
        let temp = A4xBaseLoadingView()
        temp.loadingImg.image = bundleImageFromImageName("live_video_loading")?.rtlImage()
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.contentView.snp.centerX).offset(8.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
    
    lazy var errorView: LiveErrorView = {
        let temp = LiveErrorView(frame: .zero, maxWidth: 500)
        self.contentView.addSubview(temp)
        temp.buttonClickAction = {[weak self] type in
            logDebug("-----------> A4xSDLocalVideoView LiveErrorView buttonClickAction to videoPlay")
            self?.protocol?.sdVideoPlay(comple: { res in
                
            })
        }
        
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.width.equalTo(self.contentView.snp.width)
            make.height.equalTo(150)
        })
        return temp
    }()
    
    deinit {
        logDebug("A4xSDLocalVideoFullView deinit")
    }
}

extension A4xSDLocalVideoView {
    
    @objc private func fullAction() {
        self.protocol?.sdVideoFull()
    }
    
    @objc private func connectionVideoAction(){
//        self.protocol?.videoReconnect()
    }
    
    func updataRecoredState() {
        switch self.recordState {
        case .stop:
            self.recordButton.isSelected = false
            self.recoredTimeLabel.isHidden = true
            A4xGCDTimer.shared.destoryTimer(withName: "SD_RECORD_TIMER")
        case .start:
            self.recoredTimeLabel.isHidden = false
            self.recordButton.isSelected = true
            self.recoredTime = 0
            A4xGCDTimer.shared.scheduledDispatchTimer(withName: "SD_RECORD_TIMER", timeInterval: 1.0, queue: DispatchQueue.main, repeats: true) { [weak self] in
                self?.updateRecoredInfo()
            }
        }
    }
    
    @objc private func playVideoAction(sender: UIButton) {
        logDebug("-----------> A4xSDLocalVideoView playVideoAction to videoPlay")
        
        if !sender.isSelected {
            self.protocol?.sdVideoPlay(comple: { res in
                if res {
                    sender.isSelected = !sender.isSelected
                }
            })
            //self.delegete?.videoStartLiveAction(btnType: "normal")
        } else {
            sender.isSelected = !sender.isSelected
            self.protocol?.sdVideoStop()
            //self.delegete?.videoStopLiveAction()
        }
        
    }
    
    //播放按钮自动消失处理
    func autoHiddenPause() {
        if !isAutoHidden {
            return
        }
        
        if A4xPlayerStateType.playing.rawValue == self.videoState?.0 {
            self.playBtn.isHidden = true
        }
        isAutoHidden = false
    }
    
    // sd卡回看点击屏幕处理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let videoType = A4xPlayerStateType(rawValue: self.videoState?.0 ?? A4xPlayerStateType.paused.rawValue)
        switch videoType {
        case .playing:
            // 播放中，点击播放区域出现播放按钮
            let isHidden = !self.playBtn.isHidden
            DispatchQueue.main.async {
                self.playBtn.isHidden = isHidden
            }
            isAutoHidden = true
            if !isHidden {
                DispatchQueue.main.a4xAfter(self.autoHiddenTime) { [weak self] in
                    self?.autoHiddenPause()
                }
            }
        default :
            break
        }
    }
    
    @objc private func updateRecoredInfo() {
        logDebug("-----------> updateRecoredInfo recoredTime: \(recoredTime)")
        self.recoredTime += 1
        self.recoredTimeLabel.text = String(format: "%02d:%02d", self.recoredTime / 60, self.recoredTime % 60);
    }
    
    private func noneStyle() {
        logDebug("------------> live sd noneStyle")
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.recordButton.isHidden = true
        self.screenShotButton.isHidden = true
        self.volumeButton.isHidden = true
        self.playBtn.isHidden = false
        self.playBtn.isSelected = false
        self.fullButton.isHidden = true
        self.errorView.isHidden = true
    }
    
    private func playStateError(error : String, img: UIImage?){
        self.errorView.isHidden = false
        self.errorView.error = error
        self.errorView.tipIcon = img
        self.errorView.defaultButton()
        self.loadingView.stopAnimail()
        self.loadingView.isHidden = true
        self.playBtn.isHidden = false
        self.playBtn.isSelected = false
        self.fullButton.isHidden = true
        self.volumeButton.isHidden = true
        self.playBtn.isHidden = true
        self.recordButton.isHidden = true
        self.screenShotButton.isHidden = true
    }
    
    private func loadingStyle() {
        self.loadingView.isHidden = false
        self.errorView.isHidden = true
        self.recordButton.isHidden = true
        self.screenShotButton.isHidden = true
        self.volumeButton.isHidden = true
        self.playBtn.isHidden = true
        self.fullButton.isHidden = true
        self.loadingView.startAnimail()
    }
    
    
    private func playingStyle() {
        logDebug("-----------> sd playingStyle")
        self.loadingView.stopAnimail()
        self.volumeButton.isSelected = false
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.recordButton.isHidden = false
        self.screenShotButton.isHidden = false
        self.volumeButton.isHidden = false
        self.playBtn.isSelected = true
        self.playBtn.isHidden = false
        self.fullButton.isHidden = false
        
        self.isAutoHidden = true
        DispatchQueue.main.a4xAfter(self.autoHiddenTime) { [weak self] in
            self?.autoHiddenPause()
        }

    }
}

extension A4xSDLocalVideoView {
    
    func videoStateUpdate() {
        if A4xPlayerStateType.playing.rawValue == self.videoState?.0 {
            playingStyle()
            return
        }
        self.recordState = .stop
        if let state = A4xPlayerStateType(rawValue: self.videoState?.0 ?? A4xPlayerStateType.paused.rawValue) {
            switch state {
            case .loading:
                loadingStyle()
            case .playing:
                playingStyle()
            case .paused:
                noneStyle()
            case .needUpdate:
                fallthrough
            case .updating:
                fallthrough
            case .forceUpdate:
                noneStyle()
                break
            case .nonet:
                fallthrough
            case .offline:
                fallthrough
            case .lowerShutDown:
                fallthrough
            case .keyShutDown:
                fallthrough
            case .solarShutDown:
                fallthrough
            case .sleep:
                fallthrough
            case .timeout:
                fallthrough
            case .notRecvFirstFrame:
                fallthrough
            case .apOffline:
                fallthrough
            case .noAuth:
                if let deviceId = self.videoState?.1 {
                    A4xLiveVideoViewModel.playStateUIInfo(state: state, deviceId: deviceId) { [weak self] error, action, icon in
                        if let err = error, let iconImg = icon {
                            self?.playStateError(error: err, img: iconImg)
                        }
                    }
                }
                break
            case .connectionLimit:
                noneStyle()
                break
            }
        }
    }
    
    @objc func videoBarBackAction(sender : UIButton) {
//        self.protocol?.videoBarBackAction()
    }
    
    @objc func videoBarSettingAction(sender : UIButton) {
//        self.protocol?.videoBarSettingAction()
    }
    
    @objc func videoAlarmAction(sender : UIButton) {
//        self.protocol?.videoAlarmAction()
    }
    
    
    @objc func videoVolumeAction(sender : UIButton) {
        
        self.protocol?.sdVideoVolumeAction(enable: sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
    
    @objc func videoScreenShot(sender : UIButton) {
        self.protocol?.sdVideoScreenShot(view: sender)
    }
    
    @objc func videoDetailAction(sender : UIControl) {
//        if self.recordButtonState == .runing {
//            self.makeToast(A4xBaseManager.shared.getLocalString(key: "cannot_switch"))
//            return
//        }
//
//        weak var weakSelf = self
//        sender.showSharpDialog(datas: A4xVideoSharpType.all(), select: self.dataSource?.getResolutionFromCache()) { (detail) in
//            weakSelf?.protocol?.setResolution(type: detail)
//        }
    }
    
    @objc func videoRecordVideo(sender : UIButton) {
        switch self.recordState {
        case .stop:
            self.recordState = .start
            self.protocol?.sdVideoRecordVideo(start: true)
        case .start:
            self.recordState = .stop
            self.protocol?.sdVideoRecordVideo(start: false)
        }
    }
}

extension A4xSDLocalVideoView : UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == self {
            return true
        }else {
            return false
        }
    }
}
