//


//


//

import UIKit
import Lottie
import SmartDeviceCoreSDK
import BaseUI

protocol LiveDisplayViewProtocol: class {
    func videoStartLiveAction(btnType: String)
    func videoStopLiveAction()

    func videoFullAction()
    func videoErrorAction(action: A4xVideoAction)
    
    func videoScreenShot()
    func videoRecordVideo(start: Bool)
}


public class A4xLiveVideoView: UIImageView {
    
    var showChangeAnilmail: Bool = false
    
    var videoState: (Int, String?)? = (A4xPlayerStateType.paused.rawValue, nil)
    
    var dataSource: DeviceBean?
    
    var videoRatio: CGFloat = 16.0 / 9.0 {
        didSet {
            weakBlueEffectView.snp.remakeConstraints { (make) in
                make.centerX.equalTo(self.snp.centerX)
                make.centerY.equalTo(self.snp.centerY)
                if A4xBaseSysDeviceManager.isIpad && !(dataSource?.isFourByThree() ?? true) {
                    make.width.equalTo(self.snp.width)
                    make.height.equalTo(weakBlueEffectView.snp.width).multipliedBy(videoRatio)
                } else {
                    make.height.equalTo(self.snp.height)
                    make.width.equalTo(weakBlueEffectView.snp.height).multipliedBy(videoRatio)
                }
            }
        }
    }
    
    public var thumbImage: UIImage? {
        didSet {
            if thumbImage != oldValue && thumbImage != nil {
                updateImage()
                return
            }
        }
    }
    
    
    public var blueEffectEnable: Bool = true {
        didSet {
            if self.videoState?.0 == A4xPlayerStateType.playing.rawValue {
                self.weakBlueEffectView.isHidden = true
            } else {
                self.weakBlueEffectView.isHidden = !blueEffectEnable
            }
        }
    }
    
    func updateImage() {
        
        if (playerView == nil || (playerView?.subviews.count ?? 0) == 0 ) && showChangeAnilmail {
            let transition = CATransition()
            transition.duration = 0.4
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.fade
            self.layer.add(transition, forKey: "ddd")
        }
        
        
        let renderthumbImageView = self.playerView?.getSubViewByTag(tag: 1002)
        if (renderthumbImageView?.count ?? 0) > 0 {
            //
            renderthumbImageView?[0].removeFromSuperview()
        }
        
        
        if self.videoState?.0 != A4xPlayerStateType.playing.rawValue {
            
            let RTCMTLVideoView = self.playerView?.getSubViewByTag(tag: 1005)
            if (RTCMTLVideoView?.count ?? 0) > 0 {
                //
                
                RTCMTLVideoView?[0].removeFromSuperview()
            }
            
            let renderView = self.getSubViewByTag(tag: 1003)
            if renderView.count > 0 {
                //
                renderView[0].removeFromSuperview()
            }
        }
        
        //let size = CGSize(width: self.height * videoRatio, height: self.height)
        if self.blueEffectEnable {
            if thumbImage != nil {
                //let img = thumbImage?.blurred(radius: 15)
                guard let img = thumbImage else {
                    return self.image = thumbImage//?.resizedImage(size: size)
                }
                self.image = img//.resizedImage(size: size)
            } else {
                self.image = thumbImage//?.resizedImage(size: size)
            }
        } else {
            self.image = thumbImage//?.resizedImage(size: size)
        }
    }
    
    //renderView(renderthumbImageView)
    public weak var playerView: UIView? {
        didSet {
            if let v = self.playerView {
                if self.bounds != .zero {
                    
                    
                    let renderView = self.getSubViewByTag(tag: 1003)
                    if renderView.count > 0 {
                        //
                        renderView[0].removeFromSuperview()
                    }
                    
                    v.translatesAutoresizingMaskIntoConstraints = true
                    //
                    
                    self.layoutIfNeeded()
                    //
                    v.frame = self.bounds
                    v.tag = 1003
                    v.setNeedsDisplay()
                    v.accessibilityIdentifier = "A4xLiveUIKit_playerView"
                    self.insertSubview(v, at: 0)
                    //
                } else {
                    //
                }
            }
        }
    }
    
    public override var frame: CGRect {
        didSet {
            //
            if self.bounds != .zero {
                self.playerView?.frame = self.bounds
            } else {
                //
            }
           
        }
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        //
        if isLandscape() {
            self.playerView?.frame = self.bounds
        }
    }
    
    
    private func isLandscape() -> Bool {
        if A4xAppSettingManager.shared.interfaceOrientations == .landscape {
            return true
        } else {
            return false
        }
    }
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var weakBlueEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let tempV = UIVisualEffectView(effect: blurEffect)
        tempV.backgroundColor = UIColor.clear
        tempV.accessibilityIdentifier = "A4xLiveUIKit_weakBlueEffectView"
        tempV.alpha = 0.85
        self.addSubview(tempV)

        tempV.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            if A4xBaseSysDeviceManager.isIpad && !(dataSource?.isFourByThree() ?? true) {
                make.width.equalTo(self.snp.width)
                make.height.equalTo(tempV.snp.width).multipliedBy(videoRatio)
            } else {
                make.height.equalTo(self.snp.height)
                make.width.equalTo(tempV.snp.height).multipliedBy(videoRatio)
            }
        }
        return tempV
    }()
}

class LiveDisplayView: UIView {

    weak var delegete: LiveDisplayViewProtocol?
    
    var indexPath       : IndexPath?
    
    var deviceModel: DeviceBean? {
        didSet {
            deviceOnLine = deviceModel?.online == 1
            deviceStatus = deviceModel?.deviceStatus ?? 0
            deviceDormancyMessage = deviceModel?.deviceDormancyMessage ?? ""
            deviceVersion = deviceModel?.newestFirmwareId ?? ""
            



        }
    }
    
    var dataDic: [String: Any]? {
        didSet {
            
        }
    }
    
    private func getVideoRatio() -> CGFloat {
        return (deviceModel?.isFourByThree() ?? false) ? (4.0 / 3.0) : (16.0 / 9.0)
    }
    
    var deviceVersion: String = "1.0.0"
    var showChangeAnilmail: Bool = false {
        didSet {
            self.liveContentView.showChangeAnilmail = showChangeAnilmail
        }
    }
    var autoHiddenTime: TimeInterval = 3
    var isAutoHidden: Bool = false
    
    
    var videoStyle: A4xVideoCellStyle? {
        didSet {
            updateViews()
            
            playStatusUpdate(isChangeed: false)
        }
    }
    
    
    var videoState: (Int, String?)? = (A4xPlayerStateType.paused.rawValue, nil) {
        didSet {
            playStatusUpdate(isChangeed: oldValue?.0 != videoState?.0)
        }
    }
    
    private var recoredTime: Int = 0
    
    var deviceOnLine: Bool = true 
    var deviceStatus: Int = 0 
    var deviceDormancyMessage: String = "" 
    
    //MARK:- 生命周期
    init(frame: CGRect = CGRect.zero, delegete: LiveDisplayViewProtocol) {
        self.delegete = delegete
        super.init(frame: frame)
        self.liveContentView.isHidden = false
        self.bottomShareImageV?.isHidden = false
        self.playBtn?.isHidden = false
        self.fullVideoBtn?.isHidden = false
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.liveBgView.isHidden = false
        self.liveText.isHidden = false
        
        self.recordButton.isHidden = true
        self.recoredTimeLabel.isHidden = true
        self.screenShotButton.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateVideoRatio() {
        liveContentView.snp.remakeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(self.snp.height)
            make.width.equalTo(self.snp.height).multipliedBy(getVideoRatio())
        })
        liveContentView.setNeedsDisplay()
        
        let videoRatioImg = (deviceModel?.isFourByThree() ?? false) ? 1 : 0
        self.liveContentView.videoRatio = getVideoRatio()
        self.liveContentView.thumbImage = thumbImage(deviceID: self.deviceModel?.serialNumber ?? "", videoRatio: videoRatioImg)
        
        self.errorView.snp.remakeConstraints { (make) in
            make.width.equalTo(self.snp.width)
            make.height.equalTo(self.snp.height)
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
        }
        self.errorView.setNeedsDisplay()
    }
    
    
    func updateViews() {
        
        updateVideoRatio()
        
        if (self.videoStyle == .`default`) {
            self.fullVideoBtn?.snp.updateConstraints({ (make) in
                make.trailing.equalTo(self.snp.trailing).offset(-15)
                make.bottom.equalTo(self.snp.bottom).offset(-10)
            })
        } else {
            self.fullVideoBtn?.snp.updateConstraints({ (make) in
                make.trailing.equalTo(self.snp.trailing).offset(-9)
                make.bottom.equalTo(self.snp.bottom).offset(-5)
            })
        }
    }
    
    
    lazy var playBtn: UIButton? = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveSDK_playBtn"
        temp.setImage(bundleImageFromImageName("video_play")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("video_pause")?.rtlImage(), for: UIControl.State.selected)
        temp.addTarget(self, action: #selector(playVideoAction(sender:)), for: .touchUpInside)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: 40.auto(), height: 40.auto()))
        })
        return temp
    }()
    
    
    lazy var liveContentView: A4xLiveVideoView = {
        let temp = A4xLiveVideoView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_liveContentView"
        temp.clipsToBounds = true
        temp.tag = 1008
        self.addSubview(temp)
        weak var weakSelf = self
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(self.snp.height)
            make.width.equalTo(self.snp.height).multipliedBy(getVideoRatio())
        })
        return temp
    }()
    
    
    lazy var bottomShareImageV: UIImageView? = {
        let temp = UIImageView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_bottomShareImageV"
        temp.image = A4xLiveUIResource.UIImage(named: "home_play_bottom_shard_bg")?.rtlImage()
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(55.auto())
            make.leading.equalTo(0)
            make.width.equalTo(self.snp.width)
        })
        return temp
    }()
    
    //直播 - loadingUI
    lazy var loadingView: A4xBaseLoadingView = {
        let temp = A4xBaseLoadingView()
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX).offset(8.auto())
            make.centerY.equalTo(self.snp.centerY)
        })
        return temp
    }()
    
    
    lazy var errorView: LiveErrorView = {
        let temp = LiveErrorView()
        temp.accessibilityIdentifier = "A4xLiveSDK_errorView"
        temp.buttonClickAction = {[weak self] type in
            
            UserDefaults.standard.set("1", forKey: "show_error_report_\(self?.deviceModel?.serialNumber ?? "")")
            self?.errorButtonAction(type: type)
        }
        self.insertSubview(temp, aboveSubview: self.liveContentView)
        temp.snp.makeConstraints({ (make) in
            make.width.equalTo(self.snp.width)
            make.height.equalTo(self.snp.height)
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
        })
        return temp
    }()
    
    
    lazy var liveAnimailView: LottieAnimationView = {
        let animationPath = "live_play_animail"
        let temp = A4xLiveUIResource.AnimationView(name: animationPath)
        temp.accessibilityIdentifier = "A4xLiveUIKit_liveAnimailView"
        temp.loopMode = .loop
        self.liveBgView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.width.equalTo(12.auto())
            make.height.equalTo(12.auto())
            make.leading.equalTo(3.auto())
            make.centerY.equalTo(self.liveBgView)
        })
        return temp
    }()
    
    
    lazy var liveBgView: UIView = {
        let temp = UIView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_liveBgView"
        temp.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        temp.cornerRadius = 11.auto()
        temp.clipsToBounds = true
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.height.equalTo(22.auto())
            make.leading.equalTo(12.auto())
            make.top.equalTo(14.auto())
        })
        return temp
    }()
    
    
    lazy var liveText: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xLiveUIKit_liveText"
        self.liveBgView.addSubview(temp)
        temp.font = ADTheme.B3
        temp.textColor = UIColor.white
        temp.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        temp.text = A4xBaseManager.shared.getLocalString(key: "live")
        let width = temp.sizeThatFits(CGSize(width: 200, height: 16))
        temp.snp.makeConstraints({ (make) in
            make.height.equalTo(22.auto())
            make.leading.equalTo(self.liveAnimailView.snp.trailing).offset(5)
            make.centerY.equalTo(self.liveBgView)
            make.trailing.equalTo(self.liveBgView.snp.trailing).offset(-5.auto())
        })
        return temp
    }()
    
    
    lazy var recoredTimeLabel: UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.accessibilityIdentifier = "A4xLiveUIKit_recoredTimeLabel"
        temp.backgroundColor = UIColor(white: 0, alpha: 0.3)
        temp.layer.cornerRadius = 12
        temp.clipsToBounds = true
        temp.font = ADTheme.B2
        temp.textColor = UIColor.white
        temp.isHidden = true
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(10.auto())
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(65)
            make.height.equalTo(24)
        })
        
        return temp
    }()
    
    
    lazy var recordButton: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveSDK_recordButton"
        temp.setImage(bundleImageFromImageName("live_video_record_normail")?.rtlImage(), for: .normal)
        temp.setImage(bundleImageFromImageName("live_sd_record_selected")?.rtlImage(), for: .selected)
        temp.contentHorizontalAlignment = .center
        temp.contentMode = .center
        temp.backgroundColor = .clear
        temp.layer.cornerRadius = 48.auto() / 2
        temp.clipsToBounds = true
        self.addSubview(temp)

        temp.addTarget(self, action: #selector(videoRecordVideo(sender:)), for: UIControl.Event.touchUpInside)

        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom).offset(4)
            make.centerX.equalTo(self.snp.centerX).offset(-32.auto())
            make.size.equalTo(48.auto())
        })
        return temp
    }()
    
    
    lazy var screenShotButton: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveSDK_screenShotButton"
        temp.setImage(bundleImageFromImageName("video_live_screen_shot")?.rtlImage(), for: .normal)
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.contentHorizontalAlignment = .center
        temp.contentMode = .center
        temp.backgroundColor = .clear
        temp.layer.cornerRadius = 48.auto() / 2
        temp.clipsToBounds = true

        self.addSubview(temp)

        temp.addTarget(self, action: #selector(videoScreenShot(sender:)), for: UIControl.Event.touchUpInside)

        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom).offset(4)
            make.centerX.equalTo(self.snp.centerX).offset(32.auto())
            make.size.equalTo(48.auto())
        })
        return temp
    }()
    
    
    public func updataRecoredState(recordState: A4xLiveRecoredState) {
        switch recordState {
        case .stop:
            self.recordButton.isSelected = false
            A4xGCDTimer.shared.destoryTimer(withName: "LIVE_RECORD_TIMER")
            self.recoredTimeLabel.isHidden = true
        case .start:
            self.recoredTimeLabel.isHidden = false
            self.recordButton.isSelected = true
            self.recoredTime = 0
            A4xGCDTimer.shared.scheduledDispatchTimer(withName: "LIVE_RECORD_TIMER", timeInterval: 1.0, queue: DispatchQueue.main, repeats: true) { [weak self] in
                self?.updateRecoredInfo()
            }
        }
    }
    
    
    @objc private func updateRecoredInfo() {
        self.recoredTime += 1
        self.recoredTimeLabel.text = String(format: "%02d:%02d", self.recoredTime / 60, self.recoredTime % 60)
    }
    
    
    @objc func videoScreenShot(sender: UIButton) {
        self.delegete?.videoScreenShot()
    }
    
    
    @objc func videoRecordVideo(sender: UIButton) {
        let recordState = sender.isSelected
        if recordState {
            self.updataRecoredState(recordState: .stop)
            self.delegete?.videoRecordVideo(start: false)
        } else {
            self.updataRecoredState(recordState: .start)
            self.delegete?.videoRecordVideo(start: true)
        }
    }
    
    
    lazy var fullVideoBtn: UIButton? = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveSDK_fullVideoBtn"
        temp.setImage(A4xLiveUIResource.UIImage(named: "video_full_bg")?.rtlImage(), for: UIControl.State.normal)
        temp.addTarget(self, action: #selector(fullVideoAction(sender:)), for: .touchUpInside)
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-15)
            make.bottom.equalTo(self.snp.bottom).offset(-10)
        })
        return temp
    }()
}


extension LiveDisplayView {
    
    
    func errorButtonAction(type: A4xVideoAction) {
        if case .video = type {
            
            self.delegete?.videoStartLiveAction(btnType: "upgrade")
            self.playBtn?.isSelected = true
        } else {
            self.delegete?.videoErrorAction(action: type)
        }
    }
    
    
    @objc private func playVideoAction(sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = !sender.isSelected
            self.delegete?.videoStartLiveAction(btnType: "normal")
        } else {
            sender.isSelected = !sender.isSelected
            self.delegete?.videoStopLiveAction()
        }
    }
    
    
    @objc private func fullVideoAction(sender: UIButton) {
        self.delegete?.videoFullAction()
    }
}


extension LiveDisplayView {
    
    private func playStatusUpdate(isChangeed: Bool) {
        
        self.liveContentView.dataSource = self.deviceModel
        self.liveContentView.videoState = self.videoState
        self.liveContentView.blueEffectEnable = true
        
        //self.liveContentView.thumbImage = thumbImage(deviceID: self.deviceModel?.serialNumber ?? "")
        var image: UIImage? = nil
        if let videoType = A4xPlayerStateType(rawValue: self.videoState?.0 ?? A4xPlayerStateType.paused.rawValue) {
            
            switch videoType {
            case .loading:
                self.liveContentView.blueEffectEnable = true
                playStateLoading()
            case .playing:
                
                self.liveContentView.blueEffectEnable = false
                playStatePlaying(isChangeed: isChangeed)
            case .paused:
                self.liveContentView.blueEffectEnable = false
                playStatepaused()
            case .updating:
                self.liveContentView.blueEffectEnable = true
                let err = A4xBaseManager.shared.getLocalString(key: "device_is_updating")
                let icon = A4xBaseResource.UIImage(named: "device_connect_supper")?.rtlImage()
                playUploadingError(error: err, tipIcon: icon)
            case .needUpdate:
                self.liveContentView.blueEffectEnable = true
                playStateNeedUpdateUI(isFock: false)
            case .forceUpdate:
                self.liveContentView.blueEffectEnable = true
                playStateNeedUpdateUI(isFock: true)
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
                    A4xLiveVideoViewModel.playStateUIInfo(state: videoType, deviceId: deviceId) { [weak self] error, action, icon in
                        if let err = error {
                            self?.liveContentView.blueEffectEnable = true
                            self?.playStateError(error: err, action: action, tipIcon: icon)
                        }
                    }
                }
                break
            case .connectionLimit:
                self.liveContentView.blueEffectEnable = false
                playStatepaused()
                break
            }
        }
        
        if let deviceId = self.videoState?.1 {
            guard let device = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceId, modeType: .WiFi) else {
                return
            }
            let videoRatio = device.isFourByThree() ? 1 : 0
            image = thumbImage(deviceID: deviceId, videoRatio: videoRatio)
        }
        
        
        //self.liveContentView.videoState = self.videoState
        guard let newImg = image else {
            return
        }
        self.liveContentView.thumbImage = newImg
    }
    
    
    private func checkAPModeLiveStateOrCoverPictureTime(isErrUI: Bool = false) {
        let deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: self.deviceModel?.serialNumber ?? "", modeType: self.deviceModel?.apModeType ?? .WiFi)
        
        if !isErrUI {
            
            let timeInterval = thumbTimes(deviceID: self.deviceModel?.serialNumber ?? "")
            if timeInterval != 0 {
                let dateRange = Date.compareCurrentTime(str: timeInterval)
                var msgStr = ""
                
                switch dateRange.0 {
                case 1: 
                    msgStr = A4xBaseManager.shared.getLocalString(key: "player_days_hour")
                    break
                case 2: 
                    msgStr = A4xBaseManager.shared.getLocalString(key: "player_days", param: ["\(dateRange.1)", A4xBaseManager.shared.getLocalString(key: "unit_hours")])
                    break
                case 3: 
                    msgStr = A4xBaseManager.shared.getLocalString(key: "player_days", param: ["\(dateRange.1)", A4xBaseManager.shared.getLocalString(key: "unit_day")])
                    break
                case 4: 
                    msgStr = A4xBaseManager.shared.getLocalString(key: "player_days", param: ["\(dateRange.1)", A4xBaseManager.shared.getLocalString(key: "unit_days")])
                    break
                default:
                    break
                }
                self.liveText.text = msgStr
                liveAnimailView.isHidden = true
                
                liveAnimailView.snp.updateConstraints { make in
                    make.width.equalTo(0)
                }
                self.liveBgView.isHidden = false
            }
        }
        
        func reloadLiveAnimailViewUI(isOnline: Bool) {
            var animationPath = "live_play_animail"
            if !isOnline {
                animationPath = "live_disconnect_animail"
            }
            self.liveAnimailView.stop()
            self.liveAnimailView = A4xLiveUIResource.AnimationView(name: animationPath)
            
            self.liveAnimailView.loopMode = .loop
            self.liveBgView.addSubview(self.liveAnimailView)
            self.liveAnimailView.snp.remakeConstraints({ (make) in
                make.width.equalTo(12.auto())
                make.height.equalTo(12.auto())
                make.leading.equalTo(3.auto())
                make.centerY.equalTo(self.liveBgView)
            })
        }
    }
    
    
    private func checkSleepPlan() {
        
        if deviceOnLine && deviceStatus == 3 {
            playStateSleepPlan(sleepPlanIntro: deviceDormancyMessage)
        } else {
            self.errorView.backgroundColor = .clear
        }
    }
    
    
    private func playStateSleepPlan(sleepPlanIntro: String) {
        var sleepTips = A4xBaseManager.shared.getLocalString(key: "sleeping")//sleepPlanIntro
        self.isAutoHidden = false
        self.fullVideoBtn?.isHidden = true
        self.liveBgView.isHidden = true
        self.playBtn?.isHidden = true
        self.liveAnimailView.stop()
        if self.loadingView.isLoading {
            self.loadingView.stopAnimail()
        }
        self.loadingView.isHidden = true
        self.errorView.isHidden = false
        let startColor = UIColor.colorFromHex("#06241C")
        let endColor = UIColor.colorFromHex("#020106")
        self.errorView.gradientColor(CGPoint(x:0, y:0), CGPoint(x:1, y:1), [startColor.cgColor, endColor.cgColor])
        if self.videoStyle == .default {
            self.errorView.tipIcon = A4xLiveUIResource.UIImage(named: "home_sleep_plan")?.rtlImage()
            self.errorView.buttonItems = []
            if deviceModel?.isAdmin() ?? true { 
                self.errorView.sleepPlanButton()
            } else {
                
                let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 1)
                sleepTips += "\n\n" + A4xBaseManager.shared.getLocalString(key: "admin_wakeup_camera", param: [tempString])
                self.errorView.error = sleepTips
            }
            self.errorView.type = .default
        }
    }
    
    private func playStateLoading() {
        self.isAutoHidden = false
        self.playBtn?.isHidden = true
        
        self.loadingView.isHidden = false
        self.errorView.isHidden = true
        self.liveBgView.isHidden = true
        self.recordButton.isHidden = true
        self.recoredTimeLabel.isHidden = true
        self.screenShotButton.isHidden = true
        self.liveAnimailView.stop()
        self.loadingView.startAnimail()
    }
    
    private func playStatepaused() {
        self.isAutoHidden = false
        self.loadingView.isHidden = true
        self.fullVideoBtn?.isHidden = false
        self.errorView.isHidden = true
        self.playBtn?.isHidden = false
        self.playBtn?.isSelected = false
        self.liveAnimailView.stop()
        self.liveBgView.isHidden = true
        self.recordButton.isHidden = true
        self.recoredTimeLabel.isHidden = true
        self.screenShotButton.isHidden = true
        
        
        checkSleepPlan()
        
        checkAPModeLiveStateOrCoverPictureTime(isErrUI: self.deviceModel?.deviceState() == .sleep)
    }
    
    private func playStatePlaying(isChangeed: Bool) {
        self.liveText.text = A4xBaseManager.shared.getLocalString(key: "live")
        if isChangeed {
            self.playBtn?.isHidden = false
        }
        self.loadingView.isHidden = true
        self.fullVideoBtn?.isHidden = false
        if self.loadingView.isLoading {
            self.loadingView.stopAnimail()
        }
        self.errorView.isHidden = true
        self.playBtn?.isSelected = true
        
        if self.videoStyle == .default {
            self.recordButton.isHidden = false
            self.screenShotButton.isHidden = false
        } else {
            self.recordButton.isHidden = true
            self.recoredTimeLabel.isHidden = true
            self.screenShotButton.isHidden = true
        }
        
        self.liveAnimailView.play()
        liveAnimailView.isHidden = false
        liveAnimailView.snp.updateConstraints { make in
            make.width.equalTo(12.auto())
        }
        self.liveBgView.isHidden = false
        
        if let isRecord = dataDic?["isRecord"] as? Bool {
            if !isRecord {
                self.updataRecoredState(recordState: .stop)
            } 
        }
        
        self.isAutoHidden = true
        DispatchQueue.main.a4xAfter(self.autoHiddenTime) { [weak self] in
            self?.autoHiddenPause()
        }
    }
    
    private func playStateNeedUpdateUI(isFock: Bool) {
        self.isAutoHidden = false
        self.errorView.isHidden = false
        self.errorView.localRemoveGradientLayer()
        self.errorView.backgroundColor = .clear
        self.fullVideoBtn?.isHidden = true
        self.liveAnimailView.stop()
        self.liveBgView.isHidden = true
        self.recordButton.isHidden = true
        self.recoredTimeLabel.isHidden = true
        self.screenShotButton.isHidden = true
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 1)
        if deviceModel?.isAdmin() ?? true {
            self.errorView.error = A4xBaseManager.shared.getLocalString(key: "fireware_need_update_tips", param: [deviceVersion])
            if isFock {
                self.errorView.forceUpgradeButton()
            } else {
                self.errorView.upgradeButton()
            }
            self.errorView.tipIcon = A4xBaseResource.UIImage(named: "device_connect_supper")?.rtlImage()
        } else {
            if !isFock {
                self.errorView.error = A4xBaseManager.shared.getLocalString(key: "forck_update_share", param: [deviceVersion])
                
                self.errorView.buttonItems = [A4xLiveVideoBtnActionItem(style: .line, action: .video(title:  A4xBaseManager.shared.getLocalString(key: "do_not_update"), style: .line))]
            } else {
                self.errorView.error = A4xBaseManager.shared.getLocalString(key: "forck_update_share", param: [deviceVersion]) + "\n\n" + A4xBaseManager.shared.getLocalString(key: "unavailable_before_upgrade", param: [tempString])
                self.errorView.buttonItems = []
            }
            self.errorView.tipIcon = A4xBaseResource.UIImage(named: "device_connect_supper")?.rtlImage()
        }
        self.playBtn?.isHidden = true
        if self.loadingView.isLoading {
            self.loadingView.stopAnimail()
        }
        self.loadingView.isHidden = true
        
        if videoStyle == .default {
            self.errorView.type = .default
        } else {
            self.errorView.type = .simple
        }
        
        
        checkSleepPlan()
      
    }
    
    private func playUploadingError(error: String, tipIcon: UIImage?) {
        self.errorView.isHidden = false
        self.errorView.localRemoveGradientLayer()
        self.errorView.backgroundColor = .clear
        self.errorView.error = error
        self.errorView.buttonItems = nil
        self.errorView.tipIcon = tipIcon
        self.fullVideoBtn?.isHidden = true
        self.playBtn?.isHidden = true
        if self.loadingView.isLoading {
            self.loadingView.stopAnimail()
        }
        self.loadingView.isHidden = true
        self.liveAnimailView.stop()
        self.liveBgView.isHidden = true
        self.recordButton.isHidden = true
        self.recoredTimeLabel.isHidden = true
        self.screenShotButton.isHidden = true
        if videoStyle == .default {
            self.errorView.type = .default
        }else {
            self.errorView.type = .simple
        }
    }
    
    private func playStateError(error: String, action: A4xVideoAction?, tipIcon: UIImage?) {
        self.errorView.isHidden = false
        self.errorView.localRemoveGradientLayer()
        self.errorView.backgroundColor = .clear
        self.errorView.error = error
        if let action = action {
            var viewStyle: A4xHomeVideoButtonStyle = .line
            if let style = action.style() {
                switch style {
                case .theme:
                    viewStyle = .theme
                case .line:
                    viewStyle = .line
                case .none:
                    viewStyle = .none
                }
            }
            if case .notRecvFirstFrame = action {
                self.errorView.notRecvFirstFrameButton()
            } else {
                self.errorView.buttonItems = [A4xLiveVideoBtnActionItem(style: viewStyle, action: action)]
            }
        } else {
            self.errorView.buttonItems = []
        }
        self.errorView.tipIcon = tipIcon
        self.fullVideoBtn?.isHidden = true
        self.playBtn?.isHidden = true
        
        if self.loadingView.isLoading {
            self.loadingView.stopAnimail()
        }
        self.loadingView.isHidden = true
        
        if videoStyle == .default {
            self.errorView.type = .default
        } else {
            self.errorView.type = .simple
        }
        self.liveAnimailView.stop()
        self.liveBgView.isHidden = true
        self.recordButton.isHidden = true
        self.recoredTimeLabel.isHidden = true
        self.screenShotButton.isHidden = true
        
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 1)
        if error == A4xBaseManager.shared.getLocalString(key: "camera_sleep", param: [tempString]) {
            self.playStateSleepPlan(sleepPlanIntro: error)
        }
        
        
        if error == A4xBaseManager.shared.getLocalString(key: "updating") {
            checkSleepPlan()
        }
        
        checkAPModeLiveStateOrCoverPictureTime(isErrUI: true)
    }
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if deviceStatus == 3 {//四分屏点击不处理
            return
        }
        
        if let videoType = A4xPlayerStateType(rawValue: self.videoState?.0 ?? A4xPlayerStateType.paused.rawValue) {
            switch videoType {
            case .playing:
                
                let isHidden = !(self.playBtn?.isHidden ?? true)
                self.playBtn?.isHidden = isHidden
                
                
                if isAutoHidden {
                    
                    return
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
    }
    
    //播放按钮自动消失处理
    func autoHiddenPause() {
        if !isAutoHidden {
            return
        }
        
        if A4xPlayerStateType.playing.rawValue == self.videoState?.0 {
            self.playBtn?.isHidden = true
        }
        isAutoHidden = false
    }
}

