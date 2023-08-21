//


//


//

import UIKit
import Lottie
import SmartDeviceCoreSDK
import BaseUI

public protocol A4xFullLiveVideoControlProtocol: AnyObject {
    func videoBarBackAction()
    func videoBarSettingAction() //视频点击设置
    func videoAlarmAction()  //视频点击警告
    func videoSpeakAction(enable: Bool) -> Bool
    func videoVolumeAction(enable: Bool)
    func videoScreenShot(view: UIView)
    func videoRecordVideo(start: Bool)
    func setResolution(type: A4xVideoSharpType)
    func resolutionIntroAction()
    func videoReconnect()
    func videoDisReconnect()
    func videoZoomChange()
    func deviceRotate(point: CGPoint)
    func resetLocationAction(type: A4xFullLiveVideoPresetCellType, data: A4xPresetModel?)
    func presetLocationAction()
    func videoControlWhiteLight(enable: Bool)
    func liveMotionTrackChange(enable: Bool, comple: @escaping (_ isScuess: Bool)-> Void)
    func deviceSleepToWakeUp(device: DeviceBean?)
    func autoResolutionAction(type: Int?)
}


extension A4xFullLiveVideoControlProtocol {
    func videoDisReconnect() {}
    
    func videoControlWhiteLight(enable: Bool) {}
    
    func deviceRotate(point: CGPoint) {}
    
    func resetLocationAction(type: A4xFullLiveVideoPresetCellType, data: A4xPresetModel?) {}
    
    func videoZoomChange() {}
    
    func liveMotionTrackChange(enable: Bool, comple: @escaping (_ isScuess: Bool)-> Void) {}
}

public enum A4xLiveRecoredState {
    case start
    case stop
}


public enum A4xMagicPixStateType {
    case off_to_auto
    case auto_to_off
    case open_to_off
    case auto_to_open
    case open_to_auto
}

public class A4xFullLiveVideoContentView: UIView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hidView = super.hitTest(point, with: event)
        if hidView == self {
            return nil
        }
        return hidView
    }
}

public class A4xFullLiveVideoControlView: UIView {
    
    let autoHiddenTime : TimeInterval = 6
    private let itemSize : CGSize = CGSize(width: 44.auto(), height: 44.auto())
    private let itemImageSize : CGSize = CGSize(width: 24, height: 24)
    private var recoredTimer : Timer?
    private var recoredTime : Int = 0
    
    private var lastScale : CGFloat = 1
    private var minScale : CGFloat = 1
    private var maxScale : CGFloat = 2
    public var isTap: Bool = false
    
    public var canRotate: Bool = true {
        didSet {
            self.moreMenuSubLeftView.rotateEnable = canRotate
        }
    }
    
    public var supportMotionTrack: Bool = true {
        didSet {
            self.moreMenuSubLeftView.supportMotionTrack = supportMotionTrack
        }
    }

    public var isTrackingOpen: Bool = false {
        didSet {
            self.moreMenuSubLeftView.isTrackingOpen = isTrackingOpen
        }
    }
    
    public var isFollowAdmin: Bool = false {
        didSet {
            self.moreMenuSubLeftView.fllowEnable = isFollowAdmin && canRotate
            self.resetLocation.isAdmin = isFollowAdmin
        }
    }
        
    
    public var autoFollowBtnIsHumanImg: Bool = true {
        didSet {
            self.moreMenuSubLeftView.isHuman = autoFollowBtnIsHumanImg
        }
    }
    
    
    public var supperWhitelight: Bool = false {
        didSet {
            self.moreMenuSubLeftView.lightSupper = supperWhitelight
        }
    }
    
    public var canRotating: Bool = false {
        didSet {
            self.moreMenuSubLeftView.rotateEnable = canRotating
            self.resetLocation.isEnabled = canRotating
            self.drawTapView.isUserInteractionEnabled = canRotating
            self.resetLocation.alpha = canRotating ? 1 : 0.7
            self.drawTapView.alpha = canRotating ? 1 : 0.7
        }
    }
    
    public var isRotate: Bool = true {
        didSet { }
    }
    
    public var whiteLight: Bool = false {
        didSet {
            self.moreMenuSubLeftView.lightEnable = whiteLight
        }
    }
    
    public var recordEnable: Bool = true {
         didSet {
            self.recordButton.alpha = recordEnable ? 1 : 0
         }
     }
    
    public var liveAudioToggleOn: Bool = true {
         didSet {
            
             if self.dataSource?.liveAudioToggleOn == false {
                self.volumeButton.setImage(bundleImageFromImageName("video_live_volume_mute")?.rtlImage(), for: .normal)
                self.volumeButton.alpha = 0.5
            } else {
                self.volumeButton.setImage(bundleImageFromImageName("video_live_volume")?.rtlImage(), for: .normal)
                self.volumeButton.setImage(bundleImageFromImageName("video_live_volume_mute")?.rtlImage(), for: .selected)
                self.volumeButton.alpha = 1.0
            }
         }
     }
    
    @objc public func updateVolumeButtonUI(liveAudioToggleOn : Bool) {
        self.dataSource?.liveAudioToggleOn = liveAudioToggleOn
       
        if liveAudioToggleOn == false {
            self.volumeButton.setImage(bundleImageFromImageName("video_live_volume_mute")?.rtlImage(), for: .normal)
            self.volumeButton.alpha = 0.5
        } else {
            self.volumeButton.setImage(bundleImageFromImageName("video_live_volume")?.rtlImage(), for: .normal)
            self.volumeButton.setImage(bundleImageFromImageName("video_live_volume_mute")?.rtlImage(), for: .selected)
            self.volumeButton.alpha = 1.0
        }
    }
    
    public lazy var doubleRecognier: UITapGestureRecognizer = {
        let rec = UITapGestureRecognizer(target: self, action: #selector(doubleTapVideoAction(sender:)))
        rec.delegate = self
        rec.numberOfTapsRequired = 2
        return rec
    }()
    
    lazy var oneTapRecognier : UITapGestureRecognizer = {
        let rec = UITapGestureRecognizer(target: self, action: #selector(tapVideoAction))
        rec.numberOfTapsRequired = 1
        rec.delegate = self

        return rec
    }()
    
    public var spackVoiceData: [Float] = [] {
        didSet {
            self.spakingView.pointLocation = spackVoiceData
        }
    }
    
    public var recordState: A4xLiveRecoredState = .stop {
        didSet{
            updataRecoredState()
        }
    }
    
    public var downloadSpeed: String? {
        didSet {
            self.downloadSpeedLable.text = downloadSpeed
        }
    }
    
    public var videoState: (Int, String?)? = (A4xPlayerStateType.paused.rawValue, nil) {
        didSet {
            self.videoStateUpdate()
        }
    }
    public var audioEnable: Bool = true {
        didSet {
            self.volumeButton.isSelected = !audioEnable
        }
    }
    
    public var showPoorNetwork: Bool = false {
        didSet {
            if showPoorNetwork {
                let linkStr = A4xBaseManager.shared.getLocalString(key: "switch_to_auto_now")
                
                var txtStr = ""
                if self.dataSource?.getResolutionFromCache() == self.dataSource?.minToMaxResolution().1 {
                    let str = A4xBaseManager.shared.getLocalString(key: "dp_live_revolution_1280_720")
                    txtStr = A4xBaseManager.shared.getLocalString(key: "live_failure_resolution_guidance", param: [str]) + " " + linkStr
                } else {
                    let str = A4xBaseManager.shared.getLocalString(key: "auto")
                    txtStr = A4xBaseManager.shared.getLocalString(key: "live_failure_resolution_guidance", param: [str]) + " " + linkStr
                }
                let tmpWidth = txtStr.textWidthFromTextString(text: txtStr, textHeight: 36.auto(), fontSize: 14.auto(), isBold: false)
                let txtWidth = min(tmpWidth + 32.auto() + 40.auto(), max(UIScreen.width, UIScreen.height) * 0.7)
                autoTipView.autoTipsStr = (linkStr, txtStr)
                autoTipView.snp.updateConstraints { make in
                    make.width.equalTo(txtWidth)
                }
                self.autoTipView.showAni()
            }
        }
    }
    
    public weak var `protocol` : A4xFullLiveVideoControlProtocol?
    
    public var dataSource: DeviceBean? {
        didSet {
            videoRatio = getVideoRatio()
            supperWhitelight = dataSource?.deviceContrl?.whiteLight ?? false
            
            canRotate = dataSource?.deviceContrl?.rotate ?? false
            supportMotionTrack = dataSource?.deviceContrl?.supportMotionTrack ?? false
            isFollowAdmin = dataSource?.isAdmin() ?? false
            
            deviceInfoUpdate()
        }
    }
    
    var videoRatio: CGFloat = 16.0 / 9.0 {
        didSet {}
    }
    
    public var presetListData: [A4xPresetModel]? {
        didSet {
            self.resetLocation.presetListData = presetListData
        }
    }
    
    public init(frame: CGRect = .zero, model: DeviceBean = DeviceBean()) {
        self.dataSource = model
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        videoRatio = getVideoRatio()
        self.contentView.isHidden = false
        self.liveContentView.isHidden = false
        self.liveBgView.isHidden = false
        self.liveText.isHidden = false
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.moreButton.isHidden = false
        self.recordButton.isHidden = false
        self.screenShotButton.isHidden = false
        self.volumeButton.isHidden = false
        self.autoTipView.isHidden = true
        self.speakButton.isHidden = false
        self.magicMicButton.isHidden = true
        self.spakingView.isHidden = true
        self.videoDetailButton.isHidden = false
        self.downloadSpeedLable.isHidden = true
        self.playBtn.isHidden = false
        self.drawTapView.isHidden = true
        self.backButton.isHidden = false
        
        self.moreMenuSubLeftView.isHidden = true
        
        //self.batterButton.isHidden = false || !(dataSource?.supperBatter() ?? false)

        self.resetLocation.isHidden = true
        self.deviceWifiStateImageV.isHidden = true
        self.contentView.addGestureRecognizer(self.doubleRecognier)
        self.contentView.addGestureRecognizer(self.oneTapRecognier)
        self.oneTapRecognier.require(toFail: self.doubleRecognier)
        
        //
        videoStateUpdate()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public weak var videoView: UIView? {
        didSet {
            liveContentView.playerView = videoView
        }
    }
    
    lazy private var contentView: A4xFullLiveVideoContentView = {
        let temp = A4xFullLiveVideoContentView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_contentView"
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
    
    public lazy var liveContentView: A4xLiveVideoView = {
        let temp = A4xLiveVideoView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_liveContentView"
        temp.dataSource = self.dataSource
        temp.videoRatio = videoRatio
        temp.clipsToBounds = true
        temp.isUserInteractionEnabled = true
        self.contentView.insertSubview(temp, at: 0)
        weak var weakSelf = self
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            if A4xBaseSysDeviceManager.isIpad && !(dataSource?.isFourByThree() ?? true) {
                make.width.equalTo(self.snp.width)
                make.height.equalTo(temp.snp.width).multipliedBy(videoRatio)
            } else {
                make.height.equalTo(self.snp.height)
                make.width.equalTo(temp.snp.height).multipliedBy(videoRatio)
            }
        })
        
        return temp
    }()
    
    
    lazy var recoredTimeLabel: UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.backgroundColor = .red
        temp.layer.cornerRadius = 18.25.auto()
        temp.clipsToBounds = true
        temp.font = ADTheme.B2
        temp.textColor = UIColor.white
        temp.isHidden = true
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.backButton.snp.bottom)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.width.equalTo(75.auto())
            make.height.equalTo(36.5.auto())
        })
        
        return temp
    }()
    
    
    lazy var backButton: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_backButton"
        temp.setImage(bundleImageFromImageName("icon_back_write")?.rtlImage(), for: .normal)
        temp.imageView?.size = itemImageSize
        temp.backgroundColor = .clear
        self.contentView.addSubview(temp)
        
        temp.contentHorizontalAlignment = .center
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.addTarget(self, action: #selector(videoBarBackAction(sender:)), for: UIControl.Event.touchUpInside)
        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let left = 22
        
        temp.snp.makeConstraints({ (make) in
            if #available(iOS 11.0,*) {
                if UIApplication.isIPhoneX() {
                    make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading).offset(left * 2)
                } else {
                    make.leading.equalTo(left)
                }
            } else {
                make.leading.equalTo(left)
            }
            make.top.equalTo(top)
            make.size.equalTo(itemSize)
        })
        return temp
    }()
    
    lazy var liveBgView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        temp.cornerRadius = 13.auto()
        temp.clipsToBounds = true
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.height.equalTo(26.auto())
            make.width.lessThanOrEqualTo(78.auto())
            make.leading.equalTo(self.backButton.snp.trailing)
            make.centerY.equalTo(self.backButton.snp.centerY)
        })
        return temp
    }()
    
    lazy var liveAnimailView: LottieAnimationView = {
        let animationPath = "live_play_animail"
        let temp = A4xLiveUIResource.AnimationView(name: animationPath)
        temp.loopMode = .loop

        self.liveBgView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.width.equalTo(16.auto())
            make.height.equalTo(16.auto())
            make.leading.equalTo(6.auto())
            make.centerY.equalTo(self.liveBgView)
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
            make.height.equalTo(26.auto())
            make.leading.equalTo(self.liveAnimailView.snp.trailing).offset(5)
            make.centerY.equalTo(self.liveBgView)
            make.trailing.equalTo(self.liveBgView.snp.trailing).offset(-5.auto())
        })
        
        return temp
    }()
    
    
    lazy var moreButton: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_moreButton"
        temp.setImage(A4xLiveUIResource.UIImage(named: "live_video_more")?.rtlImage(), for: .normal)
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.contentHorizontalAlignment = .center
        temp.contentMode = .center
        self.contentView.addSubview(temp)
        
        temp.addTarget(self, action: #selector(moreMenuAction(sender:)), for: UIControl.Event.touchUpInside)
        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let right = -12
        
        temp.snp.makeConstraints({ (make) in
            if #available(iOS 11.0,*) {
                if UIApplication.isIPhoneX() {
                    make.trailing.equalTo(self.safeAreaLayoutGuide.snp.trailing).offset(right * 2 - 12)
                } else {
                    make.trailing.equalTo(self.contentView.snp.trailing).offset(right)
                }
            } else {
                make.trailing.equalTo(self.contentView.snp.trailing).offset(right)
            }
            make.centerY.equalTo(self.backButton.snp.centerY)
            make.size.equalTo(itemSize)
        })
        return temp
    }()
    
    
    lazy var moreMenuSubLeftView: A4xFullLiveVideoMoreMenuView = {
        let admin = self.dataSource?.isAdmin() ?? false
        let rotate = self.dataSource?.deviceContrl?.rotate ?? false
        let supperAlert = self.dataSource?.deviceSupport?.deviceSupportAlarm ?? false
        let temp = A4xFullLiveVideoMoreMenuView(supperAlert: supperAlert, rotateEnable: rotate,supportMotionTrack: self.dataSource?.deviceContrl?.supportMotionTrack ?? false, lightSupper: self.dataSource?.deviceContrl?.whiteLight ?? false , fllowEnable: admin && rotate)
        temp.protocol = self
        self.addSubview(temp)
        temp.quitBlock = { [weak self] in
            self?.moreMenuSubLeftView.isHidden = true
        }
        return temp
    }()
    
    
    
    lazy var resetLocation: A4xFullLiveVideoPresetLocationView = {
        let temp = A4xFullLiveVideoPresetLocationView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_resetLocation"
        temp.isEnabled = true
        weak var weakSelf = self
        
        temp.itemActionBlock = { (modle ,type) in
            if case .none = type {
                weakSelf?.isTrackingOpen = false
            }
            weakSelf?.protocol?.resetLocationAction(type: type, data: modle)
        }
        temp.colseVideoBlock = {
            weakSelf?.resetLocation.frame = CGRect(x:  weakSelf?.width ?? 222.auto(), y: 0, width: 170.auto(), height: weakSelf?.height ?? 0)
            
            weakSelf?.resetLocation.isHidden = true
            
            weakSelf?.moreMenuSubLeftView.isHidden = false
            weakSelf?.moreMenuSubLeftView.frame = CGRect(x: (weakSelf?.width ?? 222.auto()) - 222.auto(), y: 0, width: 222.auto(), height: weakSelf?.height ?? 0)

        }
        self.addSubview(temp)
        return temp
    }()
    
    
    lazy var liveVideoRightMenuView: A4xFullLiveVideoRightMenuView = {
        let temp = A4xFullLiveVideoRightMenuView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_liveVideoRightMenuView"
        temp.selectResolutionBlock = { [weak self] resolutionType in
            self?.protocol?.setResolution(type: resolutionType)
            self?.setLiveVideoRightMenuViewShow(false)
        }

        temp.resolutionIntroBlock = { [weak self] in
            self?.protocol?.resolutionIntroAction()
        }
        temp.backgroundColor = UIColor.hex(0x1D1C1C, alpha: 0.8)
        temp.isHidden = true
        self.addSubview(temp)
        return temp
    }()
    
    
    
    lazy var videoDetailButton: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_videoDetailButton"
        temp.setTitle(A4xVideoSharpType.hb.name(), for: .normal)
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.setTitleColor(UIColor.white, for: .normal)
        temp.titleLabel?.font = ADTheme.B2
        temp.contentHorizontalAlignment = .center
        temp.contentMode = .center
        self.contentView.addSubview(temp)

        temp.addTarget(self, action: #selector(videoDetailAction), for: UIControl.Event.touchUpInside)
        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let right = -8
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.moreButton.snp.leading).offset(-right)
            make.centerY.equalTo(self.backButton.snp.centerY)
            make.size.equalTo(CGSize(width: 80, height: 44))
        })
        return temp
    }()
    
    
    lazy var deviceWifiStateImageV: UIImageView = {
        let imageV = UIImageView()
        imageV.accessibilityIdentifier = "A4xLiveUIKit_deviceWifiStateImageV"
        self.contentView.addSubview(imageV)
        let itemSize : CGSize = CGSize(width: 24, height: 24)
        imageV.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.videoDetailButton.snp.leading).offset(-57.5.auto())
            make.centerY.equalTo(self.moreButton.snp.centerY)
            make.size.equalTo(itemSize)
        })
        return imageV
    }()
    
    
    lazy var downloadSpeedLable: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xLiveUIKit_downloadSpeedLable"
        temp.textAlignment = .right
        temp.textColor = UIColor.white
        temp.font = ADTheme.B3
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.deviceWifiStateImageV.snp.trailing)
            make.centerY.equalTo(self.moreButton.snp.centerY)
        })
        return temp
    }()
    
    private lazy var drawTapView: A4xDeviceRockerControlView = {
        let temp = A4xDeviceRockerControlView()
        temp.visableColors = [UIColor.hex(0x000000, alpha: 0.2) , UIColor.hex(0x000000, alpha: 0.2)]
        temp.lineColor = UIColor.hex(0xFFFFFF, alpha: 0.3)
        temp.borderColor = UIColor.hex(0xFFFFFF, alpha: 0.3)
        temp.onCircleTapBlock = {[weak self] point in
            self?.protocol?.deviceRotate(point: point)
        }
        self.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY).offset(-20.auto())
            make.trailing.equalTo(self.moreButton.snp.trailing).offset(-15.auto())
            make.size.equalTo(CGSize(width: 145.auto(), height: 145.auto()))
        }
        return temp
    }()
    
    
    lazy var speakButton: A4xLiveSpeakImageView = {
        let temp = A4xLiveSpeakImageView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_speakButton"
        temp.setImage(A4xLiveUIResource.UIImage(named: "video_live_speak")?.rtlImage(), for: UIControl.State.normal)
        temp.contentMode = .center
        self.contentView.addSubview(temp)
        weak var weakSelf = self
        temp.touchAction = { en in
            switch en {
            case .down:
                weakSelf?.videoSpeakAction(isDown: true)
            case .up:
                weakSelf?.videoSpeakAction(isDown: false)
            case .tap:
                weakSelf?.videoSpeakShortPress()
            }
        }
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.drawTapView.snp.centerX)
            make.top.equalTo(self.drawTapView.snp.bottom).offset(16.auto())
            make.size.equalTo(CGSize(width: 64.8.auto(), height: 64.8.auto()))
        })
        return temp
    }()
    

    
    lazy var spakingView: LiveVoiceAnimationView = {
        let temp = LiveVoiceAnimationView()
        temp.backgroundColor = UIColor(white: 0, alpha: 0.3)
        temp.layer.cornerRadius = 36.auto() / 2
        temp.clipsToBounds = true
        self.addSubview(temp)
                
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom).offset(-19.5.auto())
            make.size.equalTo(CGSize(width: 134.5.auto(), height: 36.auto()))
        })
        return temp
    }()
    
    
    
    lazy var recordButton: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_recordButton"
        temp.setImage(bundleImageFromImageName("live_video_record_normail")?.rtlImage(), for: .normal)
        temp.setImage(A4xLiveUIResource.UIImage(named: "live_video_record_selected")?.rtlImage(), for: .selected)
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.contentHorizontalAlignment = .center
        temp.contentMode = .center
        temp.backgroundColor = UIColor(white: 0, alpha: 0.3)
        temp.layer.cornerRadius = itemSize.height / 2
        temp.clipsToBounds = true
        self.contentView.addSubview(temp)

        temp.addTarget(self, action: #selector(videoRecordVideo(sender:)), for: UIControl.Event.touchUpInside)
        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let right = -12

        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.centerY).offset(-32.auto())
            make.centerX.equalTo(self.backButton.snp.centerX)
            make.size.equalTo(itemSize)
        })
        return temp
    }()
    
    
    lazy var screenShotButton: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_screenShotButton"
        temp.setImage(bundleImageFromImageName("video_live_screen_shot")?.rtlImage(), for: .normal)
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.contentHorizontalAlignment = .center
        temp.contentMode = .center
        temp.backgroundColor = UIColor(white: 0, alpha: 0.3)
        temp.layer.cornerRadius = itemSize.height / 2
        temp.clipsToBounds = true

        self.contentView.addSubview(temp)

        temp.addTarget(self, action: #selector(videoScreenShot(sender:)), for: UIControl.Event.touchUpInside)
        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let right = 0

        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.snp.centerY).offset(0.auto())
            make.centerX.equalTo(self.backButton.snp.centerX)
            make.size.equalTo(itemSize)
        })
        return temp
    }()
    
    
    lazy var volumeButton: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_volumeButton"
        if self.dataSource?.liveAudioToggleOn == false {
            temp.setImage(bundleImageFromImageName("video_live_volume_mute")?.rtlImage(), for: .normal)
            temp.alpha = 0.5
        } else {
            temp.setImage(bundleImageFromImageName("video_live_volume")?.rtlImage(), for: .normal)
            temp.setImage(bundleImageFromImageName("video_live_volume_mute")?.rtlImage(), for: .selected)
            temp.alpha = 1.0
        }
        
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.contentHorizontalAlignment = .center
        temp.contentMode = .center
        temp.backgroundColor = UIColor(white: 0, alpha: 0.3)
        temp.layer.cornerRadius = itemSize.height / 2
        temp.clipsToBounds = true
        self.contentView.addSubview(temp)
        
        temp.addTarget(self, action: #selector(videoVolumeAction(sender:)), for: UIControl.Event.touchUpInside)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.screenShotButton.snp.bottom).offset(32.auto())
            make.centerX.equalTo(self.screenShotButton.snp.centerX)
            make.size.equalTo(itemSize)
        })
        return temp
    }()
    
    
    lazy var autoTipView: A4xFullLiveAutoRessolutionAnimailView = {
        let temp = A4xFullLiveAutoRessolutionAnimailView()
        temp.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        temp.cornerRadius = 18.auto()
        let linkStr = A4xBaseManager.shared.getLocalString(key: "switch_to_auto_now")
        let txtStr = A4xBaseManager.shared.getLocalString(key: "switch_to_auto_reminder") + " " + linkStr
        let tmpWidth = txtStr.textWidthFromTextString(text: txtStr, textHeight: 36.auto(), fontSize: 14.auto(), isBold: false)
        let txtWidth = min(tmpWidth + 32.auto() + 40.auto(), max(UIScreen.width, UIScreen.height) * 0.7)
        temp.autoTipsStr = (linkStr, txtStr)
        temp.clipsToBounds = true
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.height.equalTo(36.auto())
            make.width.equalTo(txtWidth)
            make.leading.equalTo(self.volumeButton.snp.leading).offset(-20.auto())
            make.top.equalTo(self.volumeButton.snp.bottom).offset(12.auto())
        })
        temp.resolutionToAutoActionBlock = { [weak self] in
            if self?.dataSource?.getResolutionFromCache() == self?.dataSource?.minToMaxResolution().1 {
                self?.protocol?.setResolution(type: self?.dataSource?.minToMaxResolution().0 ?? .auto)
                return
            }
            self?.protocol?.setResolution(type: .auto)
        }
        return temp
    }()
    
    
    lazy var magicMicButton: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_magicMicButton"
        temp.setImage(A4xLiveUIResource.UIImage(named: "live_video_full_magic_mic_sub_sel")?.rtlImage(), for: .normal)
        temp.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        temp.contentHorizontalAlignment = .center
        temp.contentMode = .center
        temp.backgroundColor = UIColor(white: 0, alpha: 0.3)
        temp.layer.cornerRadius = itemSize.height / 2
        temp.clipsToBounds = true
        self.contentView.addSubview(temp)
        
        temp.addTarget(self, action: #selector(magicMicAction(sender:)), for: UIControl.Event.touchUpInside)
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.volumeButton.snp.centerY).offset(0.auto())
            make.centerX.equalTo(self.speakButton.snp.centerX)
            make.size.equalTo(itemSize)
        })
        return temp
    }()
    
    
    lazy var playBtn: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_playBtn"
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
        temp.accessibilityIdentifier = "A4xLiveUIKit_errorView"
        self.contentView.insertSubview(temp, belowSubview: self.backButton)
        temp.buttonClickAction = { [weak self] type in
            
            if case .sleepPlan = type { 
                self?.protocol?.deviceSleepToWakeUp(device: self?.dataSource)
            } else if case .notRecvFirstFrame(title: _, style: _, clickState: let clickState) = type {
                if clickState == .start {
                    self?.protocol?.autoResolutionAction(type: 0)
                } else if clickState == .noThanks {
                    self?.protocol?.autoResolutionAction(type: 1)
                }
            } else {
                self?.protocol?.videoReconnect()
            }
        }
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.width.equalTo(self.contentView.snp.width)
            make.height.equalTo(self.contentView.snp.height)
        })
        return temp
    }()
    
    @objc func playVideoAction() {
        if !self.playBtn.isSelected {
            self.protocol?.videoReconnect()
        } else {
            self.protocol?.videoDisReconnect()
        }
    }
    
    private func getVideoRatio() -> CGFloat {
        return (dataSource?.isFourByThree() ?? false) ? (4.0 / 3.0) : (A4xBaseSysDeviceManager.isIpad ? 9.0 / 16.0 : 16.0 / 9.0)
    }
    
    deinit {
        
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hidView = super.hitTest(point, with: event)
        if hidView == self {
            return nil
        }
        return hidView
    }
}

extension A4xFullLiveVideoControlView {
    
    func free() {
        self.recoredTimer?.invalidate()
        self.recoredTimer = nil
        spakingView.free()
    }
    
    
    func setLiveVideoRightMenuViewShow(_ isShow: Bool) {
        self.liveVideoRightMenuView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.liveVideoRightMenuView.frame = CGRect(x: isShow ? self.width - 222.auto() : self.width, y: 0, width: 222.auto(), height: self.height)
        }) { (f) in
            if !isShow {
                self.liveVideoRightMenuView.isHidden = !isShow
            }
        }
    }
    
    @objc private func locationButtonAction() {
        self.protocol?.presetLocationAction()
        self.resetLocation.frame = CGRect(x: self.width, y: 0, width: 222.auto(), height: self.height)
        self.resetLocation.isHidden = false
        self.resetLocation.frame = CGRect(x: self.width - 222.auto(), y: 0, width: 222.auto(), height: self.height)
    }
    
    func visableLocationView(show : Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.resetLocation.frame = CGRect(x: show ? self.width - 170.auto() : self.width, y: 0, width: 170.auto(), height: self.height)
        }) { (f) in
        }
    }
    
    @objc private func connectionVideoAction() {
        self.protocol?.videoReconnect()
    }
    
    func updataRecoredState() {
        switch self.recordState {
        case .stop:
            self.recordButton.isSelected = false
            self.recoredTimeLabel.isHidden = true
            A4xGCDTimer.shared.destoryTimer(withName: "LIVE_RECORD_TIMER_FULL")
        case .start:
            self.changeButtonVisable(toHidden: true)
            
            self.recoredTimeLabel.isHidden = false
            self.recordButton.isSelected = true
            self.recoredTime = 0
            A4xGCDTimer.shared.scheduledDispatchTimer(withName: "LIVE_RECORD_TIMER_FULL", timeInterval: 1.0, queue: DispatchQueue.main, repeats: true) { [weak self] in
                self?.updateRecoredInfo()
            }
        }
    }
    
    @objc private func updateRecoredInfo() {
        self.recoredTime += 1
        self.recoredTimeLabel.text = String(format: "%02d:%02d", self.recoredTime / 60, self.recoredTime % 60)
    }
    
    private func baseStyle() {
        self.liveBgView.isHidden = true
        self.liveAnimailView.stop()
        
        self.loadingView.isHidden = true
        
        self.errorView.isHidden = true
        self.errorView.localRemoveGradientLayer()
        
        self.moreButton.isHidden = true
        self.drawTapView.isHidden = true
        
        self.downloadSpeedLable.isHidden = true
        self.deviceWifiStateImageV.isHidden = true
        
        self.recordButton.isHidden = true
        self.screenShotButton.isHidden = true
        
        self.volumeButton.isHidden = true
        self.autoTipView.isHidden = true
        self.speakButton.isHidden = true
        
        self.magicMicButton.isHidden = true
        self.videoDetailButton.isHidden = true
        
    }
    
    private func noneStyle() {
        
        baseStyle()
        
        self.playBtn.isSelected = false
        self.playBtn.isHidden = false
        
        self.hiddenMenu()

    }
    
    private func loadingStyle() {
        
        baseStyle()

        self.loadingView.isHidden = false
        self.loadingView.startAnimail()
        
        self.playBtn.isHidden = true

    }
    
    private func pausedStyle() {
        
        baseStyle()
        
        self.playBtn.isSelected = false
        self.playBtn.isHidden = false
   
        self.hiddenMenu()

    }
    
    
    private func playingStyle() {
        
        self.loadingView.stopAnimail()
        
        self.loadingView.isHidden = true
        
        self.errorView.isHidden = true
        self.errorView.localRemoveGradientLayer()
        
        self.liveBgView.isHidden = false
        
        self.liveAnimailView.play()
        
        self.moreButton.isHidden = false
        self.drawTapView.isHidden = !canRotate
        
        self.downloadSpeedLable.isHidden = false
        self.deviceWifiStateImageV.isHidden = false
        
        self.recordButton.isHidden = false
        self.screenShotButton.isHidden = false
        
        self.volumeButton.isSelected = false
        self.volumeButton.isHidden = false
        self.autoTipView.isHidden = true
        self.speakButton.isHidden = false
        
        self.magicMicButton.isHidden = false || !(dataSource?.deviceSupportVoiceEffect() ?? false)
        
        if self.canRotate {
            self.speakButton.snp.remakeConstraints({ (make) in
                make.centerX.equalTo(self.drawTapView.snp.centerX)
                make.top.equalTo(self.drawTapView.snp.bottom).offset(16.auto())
                make.size.equalTo(CGSize(width: 64.8.auto(), height: 64.8.auto()))
            })
        } else {
            self.speakButton.snp.remakeConstraints({ (make) in
                make.trailing.equalTo(self.moreButton.snp.trailing).offset(-15.auto())
                make.centerY.equalTo(self.snp.centerY)
                make.size.equalTo(CGSize(width: 64.8.auto(), height: 64.8.auto()))
            })
        }
        
        self.videoDetailButton.isHidden = false
        
        self.playBtn.isHidden = true
        self.playBtn.isSelected = true
        
        weak var weakSelf = self
        DispatchQueue.main.a4xAfter(self.autoHiddenTime) {
            if self.isTap == false {
                if weakSelf != nil && weakSelf?.videoState?.0 == A4xPlayerStateType.playing.rawValue && weakSelf?.spakingView.isHidden ?? true  {
                    weakSelf?.changeButtonVisable()
                }
            }
        }
        changeButtonVisable()
    }
    
    private func doneStyle() {
        
    }
    
    private func playStateUnuseError(isFock: Bool) {
        self.loadingView.stopAnimail()
        
        baseStyle()
        
        let deviceVersion = self.dataSource?.newestFirmwareId ?? ""
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
        
        if self.dataSource?.isAdmin() ?? false {
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
            }
            self.errorView.tipIcon = A4xBaseResource.UIImage(named: "device_connect_supper")?.rtlImage()
        }
        
        self.errorView.isHidden = false
        
        self.playBtn.isHidden = true

        self.hiddenMenu()
    }
    
    private func errorStyle(error: String, action: A4xVideoAction?, tipIcon: UIImage?) {
        self.loadingView.stopAnimail()
        self.errorView.error = error
        
        baseStyle()
        
        if let action = action  {
            var viewStyle : A4xHomeVideoButtonStyle = .line
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
        
        self.errorView.isHidden = false
        
        self.playBtn.isHidden = true
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
        if error == A4xBaseManager.shared.getLocalString(key: "camera_sleep", param: [tempString]) {
            self.playStateSleepPlan(sleepPlanIntro: error)
        }

        self.hiddenMenu()
    }
    
    
    private func playStateSleepPlan(sleepPlanIntro: String) {
        var sleepTips = sleepPlanIntro
        let startColor = UIColor.colorFromHex("#06241C")
        let endColor = UIColor.colorFromHex("#020106")
        self.errorView.gradientColor(CGPoint(x:0, y:0), CGPoint(x:1, y:1), [startColor.cgColor, endColor.cgColor])
        self.errorView.type = .default
        self.errorView.tipIcon = A4xLiveUIResource.UIImage(named: "home_sleep_plan")?.rtlImage()
        self.errorView.buttonItems = []
        if self.dataSource?.isAdmin() ?? true { 
            self.errorView.sleepPlanButton()
        } else {
            let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
            sleepTips += "\n\n" + A4xBaseManager.shared.getLocalString(key: "admin_wakeup_camera", param: [tempString])
        }
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
        self.errorView.error = sleepTips.isBlank ? A4xBaseManager.shared.getLocalString(key: "camera_sleep", param: [tempString]) : sleepTips
    }
    
    func hiddenMenu() {
        self.resetLocation.frame = CGRect(x: self.width, y: 0, width: 170.auto(), height: self.height)
        self.resetLocation.isHidden = true
        self.moreMenuSubLeftView.frame = CGRect(x: self.width, y: 0, width: 222.auto(), height: self.height)
        self.moreMenuSubLeftView.isHidden = true
        self.liveVideoRightMenuView.frame = CGRect(x: self.width, y: 0, width: 222.auto(), height: self.height)
        self.liveVideoRightMenuView.isHidden = true
        self.spakingView.isHidden = true
        self.spakingView.free()
    }
    
    
    @objc func doubleTapVideoAction(sender: UITapGestureRecognizer) {
        self.protocol?.videoZoomChange()
        changeButtonVisable(toHidden: false)
    }
    
    @objc func tapVideoAction() {
        self.isTap = true
        if !self.resetLocation.isHidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.resetLocation.frame = CGRect(x: self.width, y: 0, width: 170.auto(), height: self.height)
            }) { (f) in
             self.resetLocation.isHidden = true
            }
        }
        
        if !self.moreMenuSubLeftView.isHidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.moreMenuSubLeftView.frame = CGRect(x: self.width, y: 0, width: 222.auto(), height: self.height)
                self.moreMenuSubLeftView.updateFrame()
            }) { (f) in
             self.moreMenuSubLeftView.isHidden = true
            }
        }
        if !self.liveVideoRightMenuView.isHidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.liveVideoRightMenuView.frame = CGRect(x: self.width, y: 0, width: 222.auto(), height: self.height)
            }) { (f) in
             self.liveVideoRightMenuView.isHidden = true
            }
        }
        
        self.changeButtonVisable()
    }
  
    private func changeButtonVisable(toHidden: Bool? = nil) {
        let isHidden : Bool = toHidden == nil ? !self.moreButton.isHidden : toHidden!

        UIView.animate(withDuration: 0.2) {
            if self.videoState?.0 == A4xPlayerStateType.playing.rawValue {
                self.moreButton.isHidden = isHidden
                self.drawTapView.isHidden = isHidden || !self.canRotate
                self.downloadSpeedLable.isHidden = isHidden
                self.deviceWifiStateImageV.isHidden = isHidden
                
                self.recordButton.isHidden = isHidden
                self.screenShotButton.isHidden = isHidden
                self.volumeButton.isHidden = isHidden
                self.speakButton.isHidden = isHidden
                self.magicMicButton.isHidden = isHidden || !(self.dataSource?.deviceSupportVoiceEffect() ?? false)
                self.videoDetailButton.isHidden = isHidden
            }
        }
    }
}



extension A4xFullLiveVideoControlView {
    
    func videoStateUpdate() {
        self.liveContentView.videoState = self.videoState
        self.liveContentView.blueEffectEnable = true
        
        if A4xPlayerStateType.playing.rawValue == self.videoState?.0 {
            self.liveContentView.blueEffectEnable = false
            playingStyle()
            self.liveContentView.image = nil
            return
        }
        
        var image : UIImage? = nil
        self.speakButton.isUserInteractionEnabled = false
        self.speakButton.isUserInteractionEnabled = true
        self.recordState = .stop
        
        if let state = A4xPlayerStateType(rawValue: self.videoState?.0 ??  A4xPlayerStateType.paused.rawValue) {
            switch state {
            case .loading:
                
                self.liveContentView.blueEffectEnable = true
                loadingStyle()
            case .paused:
                self.liveContentView.blueEffectEnable = true
                pausedStyle()
                self.visableLocationView(show: false)
            case .playing:
                self.liveContentView.blueEffectEnable = false
                playingStyle()
                self.liveContentView.image = nil
            case .needUpdate:
                self.liveContentView.blueEffectEnable = true
                playStateUnuseError(isFock: false)
                self.visableLocationView(show: false)
            case .forceUpdate:
                self.liveContentView.blueEffectEnable = true
                playStateUnuseError(isFock: true)
                self.visableLocationView(show: false)
                break
            case .updating:
                fallthrough
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
                            self?.liveContentView.blueEffectEnable = true
                            self?.errorStyle(error: err, action: action, tipIcon: icon)
                            self?.visableLocationView(show: false)
                        }
                    }
                }
                break
            case .connectionLimit:
                pausedStyle()
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
        self.liveContentView.image = image
        
        //self.liveContentView.thumbImage = image

    }
    
    
    func deviceInfoUpdate() {
        
        guard let dataSource = self.dataSource else {
            return
        }
        
        let detailsharp = dataSource.getResolutionFromCache()
        
        self.videoDetailButton.setTitle(detailsharp.name(), for: .normal)

        //self.videoDetailButton.title = self.dataSource?.videoSharp().name()
        //self.batterButton.setBatterInfo(leavel: dataSource.batter ?? 0, isCharging: dataSource.charging ?? 0, isOnline: dataSource.online ?? 0 == 1, quantityCharge: dataSource?.quantityCharge ?? false)
        
        if let wifiState = self.dataSource?.wifiStrength() {
            switch wifiState {
            case .offline:
                self.deviceWifiStateImageV.image = bundleImageFromImageName("device_live_wifi_none")?.rtlImage()
            case .none:
                self.deviceWifiStateImageV.image = bundleImageFromImageName("device_live_wifi_none")?.rtlImage()
            case .weak:
                self.deviceWifiStateImageV.image = bundleImageFromImageName("device_live_wifi_week")?.rtlImage()
            case .normail:
                self.deviceWifiStateImageV.image = bundleImageFromImageName("device_live_wifi_middle")?.rtlImage()
            case .strong:
                self.deviceWifiStateImageV.image = bundleImageFromImageName("device_live_wifi_strong")?.rtlImage()
            }
        }
        self.resetLocation.editEnable = self.dataSource?.isAdmin() ?? true
        //self.canRotate = self.dataSource?.deviceContrl?.rotate ?? false
        
        
        
        
        self.drawTapView.isHidden = self.moreButton.isHidden || !self.canRotate
    }
    
    @objc func videoBarBackAction(sender: UIButton) {
        self.protocol?.videoBarBackAction()
    }
    
    
    @objc func moreMenuAction(sender: UIButton) {
        //self.protocol?.videoBarSettingAction()
        self.isTap = true
        changeButtonVisable(toHidden: true)

        self.moreMenuSubLeftView.frame = CGRect(x: self.width, y: 0, width: 222.auto(), height: self.height)
        self.moreMenuSubLeftView.updateFrame()
        self.moreMenuSubLeftView.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.moreMenuSubLeftView.frame = CGRect(x: self.width - 222.auto(), y: 0, width: 222.auto(), height: self.height)
        }) { (f) in}
    }
    
    @objc func videoSpeakAction(isDown: Bool) {
        
        guard (self.protocol?.videoSpeakAction(enable: isDown) ?? false) == true else {
            return
        }
        
        if isDown {
            self.spakingView.isHidden = false
            self.spakingView.load()
            self.hideAllToasts()
            return
        }
        self.spakingView.isHidden = true
        self.spakingView.free()
    }
    
    @objc func videoSpeakShortPress() {
        var style = ToastStyle()
        style.cornerRadius = 18
        style.messageFont = UIFont.systemFont(ofSize: 13)
        style.maxHeightPercentage = 10
        style.maxWidthPercentage = 18
        style.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        style.imageSize = CGSize(width: 18, height: 18)
        style.horizontalPadding = 7
        self.hideAllToasts()
        self.makeToast(A4xBaseManager.shared.getLocalString(key: "hold_speak"), point: self.spakingView.center, title: nil, image: A4xLiveUIResource.UIImage(named: "speak_tip_icon")?.rtlImage(), style: style , completion: nil)
    }
    
    @objc func videoVolumeAction(sender: UIButton) {
        
        self.protocol?.videoVolumeAction(enable: sender.isSelected)
        sender.isSelected = !sender.isSelected
    }
    
    
    @objc func magicMicAction(sender: UIButton) {
        self.isTap = true
        changeButtonVisable(toHidden: true)
        liveVideoRightMenuView.frame = CGRect(x: self.width, y: 0, width: 222.auto(), height: self.height)
        liveVideoRightMenuView.curRightMenuViewType = .magicMic
       
        self.liveVideoRightMenuView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.liveVideoRightMenuView.frame = CGRect(x: self.width - 222.auto(), y: 0, width: 222.auto(), height: self.height)
        }) { (f) in
        }
    }
    
    @objc func videoScreenShot(sender: UIButton) {
        self.protocol?.videoScreenShot(view: sender)
    }
    
    @objc func videoDetailAction() {
        if self.recordState == .start {
            self.makeToast(A4xBaseManager.shared.getLocalString(key: "cannot_switch"))
            return
        }
        self.isTap = true
        changeButtonVisable(toHidden: true)
        liveVideoRightMenuView.frame = CGRect(x: self.width, y: 0, width: 222.auto(), height: self.height)
        liveVideoRightMenuView.curRightMenuViewType = .resolution
        liveVideoRightMenuView.supportResolutionList = dataSource?.deviceSharpList() ?? A4xVideoSharpType.all()
        
        if let data = self.dataSource {
            liveVideoRightMenuView.selectedResolutionType = data.getResolutionFromCache()
        }
        
        self.liveVideoRightMenuView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.liveVideoRightMenuView.frame = CGRect(x: self.width - 222.auto(), y: 0, width: 222.auto(), height: self.height)
        }) { (f) in
            //self.liveVideoRightMenuView.isHidden = true
        }
    }
    
    @objc func videoRecordVideo(sender: UIButton) {
        switch self.recordState {
        case .stop:
            self.recordState = .start
            self.protocol?.videoRecordVideo(start: true)
        case .start:
            self.recordState = .stop
            self.protocol?.videoRecordVideo(start: false)
        }
    }
}

extension A4xFullLiveVideoControlView: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view == self.contentView {
            return true
        } else {
            return false
        }
    }
}

extension A4xFullLiveVideoControlView : A4xFullLiveVideoMoreMenuViewProtocol {
    func deviceMenuClick(type: A4xFullLiveDeviceMenuType, compleAction: @escaping (Bool) -> Void) {
        switch type {
        case .track:
            let enable = !self.isTrackingOpen
            self.protocol?.liveMotionTrackChange(enable: enable, comple: { [weak self] (success) in
                if success {
                    self?.isTrackingOpen = enable
                }
                compleAction(success)
            })
            return
        case .alert:
            self.protocol?.videoAlarmAction()
            compleAction(true)
        case .location:
            self.moreMenuSubLeftView.frame = CGRect(x: self.width, y: 0, width: 222.auto(), height: self.height)
            self.moreMenuSubLeftView.updateFrame()
            self.moreMenuSubLeftView.isHidden = true
            self.locationButtonAction()
            compleAction(true)
            return
        case .light:
            self.protocol?.videoControlWhiteLight(enable: !self.whiteLight)
        case .setting:
            self.protocol?.videoBarSettingAction()
            compleAction(true)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.moreMenuSubLeftView.frame = CGRect(x: self.width, y: 0, width: 222.auto(), height: self.height)
            self.moreMenuSubLeftView.updateFrame()
        }) { (f) in
            self.moreMenuSubLeftView.isHidden = true
        }
    }
    
    
}
