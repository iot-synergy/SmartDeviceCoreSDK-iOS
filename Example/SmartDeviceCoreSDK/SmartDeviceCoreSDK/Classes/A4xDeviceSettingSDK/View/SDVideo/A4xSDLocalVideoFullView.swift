//
//  A4xSDLocalVideoFullView.swift
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

protocol A4xSDLocalVideoFullViewProtocol : class {
    func videoVolumeAction(enable : Bool)
    func videoScreenShot(view : UIView)
    func videoRecordVideo(start : Bool)
    func videoFull()
    func videoBarBackAction()
    func videoPlay()
}

class A4xSDLocalVideoFullView: UIView {
    
    private let itemSize : CGSize = CGSize(width: 52.auto(), height: 52.auto())
    private let itemImageSize : CGSize = CGSize(width: 24, height: 24)
    private var recoredTimer : Timer?
    private var recoredTime : Int = 0
    
    public var recordState: A4xLiveRecoredState = .stop {
        didSet{
            updataRecoredState()
        }
    }
    
    /// 视频播放状态
    var videoState: (Int, String?)? = (A4xPlayerStateType.paused.rawValue, nil) {
        didSet {
            if oldValue?.0 != videoState?.0 {
                self.videoStateUpdate()
            }
            
        }
    }
    var audioEnable: Bool = true {
        didSet {
            self.volumeButton.isSelected = !audioEnable
        }
    }
    
    weak var `protocol` : A4xSDLocalVideoFullViewProtocol?
    
    var dataSource: DeviceBean?
    
    var videoRatio: CGFloat = 16.0 / 9.0 {
        didSet {
            videoView?.isHidden = false
            videoView?.snp.remakeConstraints({ (make) in
                make.centerX.equalTo(self.snp.centerX)
                make.centerY.equalTo(self.snp.centerY)
                if A4xBaseSysDeviceManager.isIpad && !(dataSource?.isFourByThree() ?? true) {
                    make.width.equalTo(self.snp.width)
                    make.height.equalTo(contentView.snp.width).multipliedBy(videoRatio)
                } else {
                    make.height.equalTo(self.snp.height)
                    make.width.equalTo(contentView.snp.height).multipliedBy(videoRatio)
                }
            })
            contentView.isHidden = false
            contentView.snp.remakeConstraints { (make) in
                make.centerX.equalTo(self.snp.centerX)
                make.centerY.equalTo(self.snp.centerY)
                if A4xBaseSysDeviceManager.isIpad && !(dataSource?.isFourByThree() ?? true) {
                    make.width.equalTo(self.snp.width)
                    make.height.equalTo(contentView.snp.width).multipliedBy(videoRatio)
                } else {
                    make.height.equalTo(self.snp.height)
                    make.width.equalTo(contentView.snp.height).multipliedBy(videoRatio)
                }
            }
        }
    }
    
    
    
    init(frame: CGRect = .zero , model: DeviceBean = DeviceBean()) {
        self.dataSource = model
        super.init(frame: frame)
        
        videoRatio = getVideoRatio()
        
        self.topImageV?.isHidden = false
        self.bottomImageV?.isHidden = false
        self.contentView.isHidden = false
        self.videoView?.isHidden = false
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.recordButton.isHidden = false
        self.screenShotButton.isHidden = false
        self.volumeButton.isHidden = false
        self.playBtn.isHidden = true
        self.backButton.isHidden = false
        videoStateUpdate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var videoView: UIView? {
        didSet {
//            if self.videoView == nil {
//                return
//            }
//            self.videoView?.translatesAutoresizingMaskIntoConstraints = true
//            self.videoView?.backgroundColor = UIColor.clear
//            self.layoutIfNeeded()
//            self.videoView?.frame = self.bounds
//            self.insertSubview(videoView!, at: 0)
            
            if let v = self.videoView {
                if self.bounds != .zero {
                    // 移除重复的 renderView
                    let renderView = self.getSubViewByTag(tag: 1003)
                    if renderView.count > 0 {
                        //logDebug("-----------> capture 删除renderView 1003")
                        renderView[0].removeFromSuperview()
                    }
                    
                    v.translatesAutoresizingMaskIntoConstraints = true
                    // 处理更新不及时
                    self.layoutIfNeeded()
                    v.frame = self.bounds
                    v.tag = 1003
                    v.setNeedsDisplay()
                    self.insertSubview(v, at: 0)
                    //logDebug("-----------> capture 插入renderView 1003")
                } else {
                    logDebug("-----------> playerView sd didSet self.bounds is zero and return")
                }
            }
        }
    }
    
    lazy private var contentView: A4xFullLiveVideoContentView =  {
        let temp = A4xFullLiveVideoContentView()
        self.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            if A4xBaseSysDeviceManager.isIpad && !(dataSource?.isFourByThree() ?? true) {
                make.width.equalTo(self.snp.width)
                make.height.equalTo(temp.snp.width).multipliedBy(videoRatio)
            } else {
                make.height.equalTo(self.snp.height)
                make.width.equalTo(temp.snp.height).multipliedBy(videoRatio)
            }
        }
        
        return temp
    }()
    
    private func getVideoRatio() -> CGFloat {
        return (dataSource?.isFourByThree() ?? false) ? (4.0 / 3.0) : (A4xBaseSysDeviceManager.isIpad ? 9.0 / 16.0 : 16.0 / 9.0)
    }
    
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
            make.bottom.equalTo(self.snp.bottom)
            make.centerX.equalTo(self.snp.centerX).offset(-40.auto())
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
            make.centerX.equalTo(self.snp.centerX)//.offset(40.auto())
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
    
    lazy var backButton: UIButton = {
        let temp = UIButton()
        temp.setImage(bundleImageFromImageName("icon_back_write")?.rtlImage(), for: .normal)
        temp.imageView?.size = itemImageSize
        temp.backgroundColor = UIColor.clear
        self.contentView.addSubview(temp)
        
        temp.contentHorizontalAlignment = .center
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.addTarget(self, action: #selector(videoBarBackAction(sender:)), for: UIControl.Event.touchUpInside)
        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let left = 12
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(left)
            make.top.equalTo(top)
            make.size.equalTo(itemSize)
        })
        return temp
    }()
    
   //MARK:- view 创建
    lazy var playBtn: UIButton = {
        let temp = UIButton()
        temp.setImage(bundleImageFromImageName("video_play")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("video_pause")?.rtlImage(), for: UIControl.State.selected)
        temp.addTarget(self, action: #selector(playVideoAction), for: .touchUpInside)
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
        temp.buttonClickAction = { [weak self] type in
            if case .video = type  {
                logDebug("-----------> A4xSDLocalVideoView LiveErrorView buttonClickAction to videoPlay")
                self?.protocol?.videoPlay()
            }
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

extension A4xSDLocalVideoFullView {
    
    func free() {
        self.recoredTimer?.invalidate()
        self.recoredTimer = nil
    }
    
    @objc private func fullAction() {
        self.protocol?.videoFull()
    }
    
    @objc private func connectionVideoAction() { }
    
    func updataRecoredState() {
        switch self.recordState {
        case .stop:
            self.recordButton.isSelected = false
            A4xGCDTimer.shared.destoryTimer(withName: "SD_RECORD_TIMER")
            self.recoredTimeLabel.isHidden = true
        case .start:
            self.recoredTimer?.invalidate()
            self.recoredTimer = nil
            self.recoredTimeLabel.isHidden = false
            self.recordButton.isSelected = true
            self.recoredTime = 0
            A4xGCDTimer.shared.scheduledDispatchTimer(withName: "SD_RECORD_TIMER", timeInterval: 1.0, queue: DispatchQueue.main, repeats: true) { [weak self] in
                self?.updateRecoredInfo()
            }
        }
    }
    
    @objc private func playVideoAction(){
        logDebug("-----------> A4xSDLocalVideoFullView playVideoAction to videoPlay")
        self.protocol?.videoPlay()
    }
    
    @objc private func updateRecoredInfo(){
        self.recoredTime += 1
        self.recoredTimeLabel.text = String(format: "%02d:%02d", self.recoredTime / 60, self.recoredTime % 60);
    }
    
    private func noneStyle() {
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.recordButton.isHidden = true
        self.screenShotButton.isHidden = true
        self.volumeButton.isHidden = true
        self.playBtn.isHidden = false

    }
    
    private func loadingStyle() {
        self.loadingView.isHidden = false
        self.errorView.isHidden = true
        self.recordButton.isHidden = true
        self.screenShotButton.isHidden = true
        self.volumeButton.isHidden = true
        self.playBtn.isHidden = true
        self.loadingView.startAnimail()
    }
    private func playStateError(error : String){
        self.errorView.isHidden = false
        self.errorView.error = error
        self.errorView.defaultButton()
        self.loadingView.stopAnimail()
        self.loadingView.isHidden = true
        self.playBtn.isHidden = false
        self.volumeButton.isHidden = true
        self.playBtn.isHidden = true
        self.recordButton.isHidden = true
        self.screenShotButton.isHidden = true
    }
    
    private func playingStyle() {
        self.loadingView.stopAnimail()
        self.volumeButton.isSelected = false
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.recordButton.isHidden = false
        self.screenShotButton.isHidden = false
        self.volumeButton.isHidden = false
        self.playBtn.isHidden = true
    }
}
extension A4xSDLocalVideoFullView {
    
    func videoStateUpdate() {
        self.recordState = .stop
        if let state = A4xPlayerStateType(rawValue: self.videoState?.0 ?? A4xPlayerStateType.paused.rawValue) {
            switch state {
            case .loading:
                loadingStyle()
                break
            case .playing:
                playingStyle()
                break
            case .paused:
                fallthrough
            case .needUpdate:
                fallthrough
            case .forceUpdate:
                fallthrough
            case .updating:
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
                        if let err = error {
                            self?.playStateError(error: err)
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
    
    @objc func videoBarBackAction(sender: UIButton) {
        self.protocol?.videoBarBackAction()
    }
    
    @objc func videoBarSettingAction(sender: UIButton) {}
    
    @objc func videoAlarmAction(sender: UIButton) { }
    
    
    @objc func videoVolumeAction(sender: UIButton) {
        self.protocol?.videoVolumeAction(enable: sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
    
    @objc func videoScreenShot(sender: UIButton) {
        self.protocol?.videoScreenShot(view: sender)
    }
    
    @objc func videoDetailAction(sender: UIControl) { }
    
    @objc func videoRecordVideo(sender: UIButton) {
        switch self.recordState {
        case .stop:
            self.recordState = .start
            self.protocol?.videoRecordVideo(start: true)
        case .start:
            self.recordState = .stop
            self.protocol?.videoRecordVideo(start: false)
        default:
            return
        }
    }
}

extension A4xSDLocalVideoFullView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == self {
            return true
        }else {
            return false
        }
    }
}
