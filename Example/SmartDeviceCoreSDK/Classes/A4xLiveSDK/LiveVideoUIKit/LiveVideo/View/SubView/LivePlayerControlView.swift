//


//

//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public protocol LivePlayerControlViewProtocol: AnyObject {
    
    
    
    func settingAction(subPage: String?)
    
    
    func liveAction(type: Int)
    
    
    func errorAction(action: A4xVideoAction)
    
    
    func screenShotAction()
    
    
    func recordAction(isStart: Bool)
    
    
    func fullAction()
    
    
    func menuItemAction(type: LiveMenuActionType, status: Bool?, comple: @escaping (Bool) -> Void)
    
    
    func changePresetEditType(type: LivePresetEditType, isShowMore: Bool)
    
    
    func speakAction(enable: Bool) -> Bool
    
    
    func presetItemAction(preset: A4xPresetModel?, type: A4xDevicePresetCellType)
    
    
    func rotateAction(point: CGPoint)
   
}

public class LivePlayerControlView: UIView {
    
    var videoStyle: A4xVideoCellType = .default
    
    weak var `protocol` : LivePlayerControlViewProtocol?
    
    private var deviceModel: DeviceBean? {
        didSet {}
    }
    
    var dataDic: [String: Any]? {
        didSet {
            
        }
    }
    
    
    lazy var topBarView: LiveTopBarView = {
        let bar: LiveTopBarView = LiveTopBarView()
        bar.accessibilityIdentifier = "A4xLiveUIKit_topBarView"
        bar.protocol = self
        self.addSubview(bar)
        return bar
    }()
    
    //直播展示view
    lazy var liveDisplayView: LiveDisplayView = {
        let temp = LiveDisplayView(delegete: self)
        temp.backgroundColor = UIColor.colorFromHex("#414141")
        self.addSubview(temp)
        temp.layer.cornerRadius = 11
        temp.layer.masksToBounds = true
        temp.layer.shadowPath = UIBezierPath(rect: temp.bounds).cgPath
        return temp
    }()
    
    //直播中 - 展示view下的控制UI - 遥杆、麦克风、警铃
    lazy var liveBottomMenuView: LiveBottomMenuView = {
        let temp = LiveBottomMenuView()
        temp.protocol = self
        temp.backgroundColor = UIColor.white
        self.addSubview(temp)
        return temp
    }()
    
    
    private lazy var voiceAnimationView: LiveVoiceAnimationView = {
        let temp = LiveVoiceAnimationView()
        temp.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        temp.layer.cornerRadius = 18.auto()
        temp.clipsToBounds = true
        self.addSubview(temp)
        return temp
    }()
    
    //MARK:- 生命周期
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 11.auto()
        self.layer.masksToBounds = true
        
        self.topBarView.isHidden = false
        self.liveDisplayView.isHidden = false
        self.liveBottomMenuView.isHidden = true
        self.voiceAnimationView.alpha = 0
  
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("LivePlayerControlView deinit")
    }
    
    ///
    private func startSpeak() {
        self.bringSubviewToFront(voiceAnimationView)
        self.voiceAnimationView.alpha = 0
        
        self.voiceAnimationView.frame = CGRect(x: self.midX, y: self.liveDisplayView.maxY - 40, width: 0, height: 36.auto())
        
        UIView.animate(withDuration: 0.2) {
            self.voiceAnimationView.frame = CGRect(x: self.midX - 67.auto(), y: self.liveDisplayView.maxY - 44.auto(), width: 134.auto(), height: 36.auto())
            
            self.voiceAnimationView.alpha = 1
        }
        voiceAnimationView.load()
    }
    
    ///
    private func stopSpeak() {
        UIView.animate(withDuration: 0.2) {
            self.voiceAnimationView.frame = CGRect(x: self.midX, y: self.liveDisplayView.maxY - 44.auto(), width: 0, height: 36.auto())
            self.voiceAnimationView.alpha = 0
        }
        voiceAnimationView.free()
    }
    
    private func aspectRatio() -> CGFloat {
        return (self.deviceModel?.isFourByThree() ?? false) ? (4.0 / 3.0) : ( 16.0 / 9.0)
    }
    
    private func loadDefalut() {
        
        self.voiceAnimationView.frame = CGRect(x: self.midX, y: self.liveDisplayView.maxY - 44.auto(), width: 0, height: 36.auto())
        
        self.topBarView.snp.remakeConstraints { make in
            make.height.equalTo(50.auto())
            make.width.equalToSuperview()
            make.leading.equalToSuperview()
            make.top.equalTo(self.snp.top)
        }
        self.topBarView.videoStyle = .default
        
        self.liveDisplayView.snp.remakeConstraints { make in
            make.top.equalTo(self.topBarView.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(self.snp.width).multipliedBy(0.9)
            make.height.equalTo(self.snp.width).multipliedBy(0.9 * 1 / self.aspectRatio())
        }
        self.liveDisplayView.cornerRadius = 11.auto()
        self.liveDisplayView.videoState = (A4xPlayerStateType.paused.rawValue, self.deviceModel?.serialNumber ?? "")
        self.liveDisplayView.videoStyle = .default
        
        self.liveBottomMenuView.isHidden = true
    }
    
    private func loadMenuStyle() {
        self.topBarView.snp.remakeConstraints { make in
            make.height.equalTo(50.auto())
            make.width.equalToSuperview()
            make.leading.equalToSuperview()
            make.top.equalTo(self.snp.top)
        }
        self.topBarView.videoStyle = .default
        
        self.liveDisplayView.snp.remakeConstraints { make in
            make.top.equalTo(self.topBarView.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(self.snp.width).multipliedBy(0.9)
            make.height.equalTo(self.snp.width).multipliedBy(0.9 * 1 / self.aspectRatio())
        }
        self.liveDisplayView.cornerRadius = 11.auto()
        self.liveDisplayView.videoState = (A4xPlayerStateType.playing.rawValue, self.deviceModel?.serialNumber ?? "")
        self.liveDisplayView.videoStyle = .default
        
        self.liveBottomMenuView.isHidden = false
        self.liveBottomMenuView.updateUI()
        self.liveBottomMenuView.snp.remakeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(self.liveDisplayView.snp.bottom)
            make.height.equalTo(LiveBottomMenuView.menuHeight)
        }
    }
    
    public func updateSubViews(deviceModel: DeviceBean?, playerView: UIView?, state: Int) {
        self.deviceModel = deviceModel
        
        
        self.topBarView.deviceModel = self.deviceModel
        
        
        self.liveDisplayView.deviceModel = self.deviceModel
        self.liveDisplayView.dataDic = dataDic
        
        
        self.liveBottomMenuView.videoStyle = self.videoStyle
        self.liveBottomMenuView.deviceModel = self.deviceModel
        self.liveBottomMenuView.dataDic = dataDic
        
        switch videoStyle {
        case .`default`:
            self.loadDefalut()
        case .playControl(let isShowMore):
            self.liveBottomMenuView.isShowMore = isShowMore
            fallthrough
        case .locations:
            fallthrough
        case .locations_edit:
            loadMenuStyle()
        }
        
        if let datas = self.deviceModel {
            
            
            
            self.liveDisplayView.liveContentView.playerView = playerView
            self.liveDisplayView.videoState = (state, datas.serialNumber ?? "")
        }
    }
    
    public func updateMagicEnable(enable: Bool) {
        self.liveBottomMenuView.magicPixEnable = enable
    }
    
    public func updateMagicPixProcessState(state: Int) {
        self.liveBottomMenuView.magicPixProcessState = state
    }
    
    public func updateVoiceMicAnimation(pointLocation: [Float]?) {
        self.voiceAnimationView.pointLocation = pointLocation
    }
    
    public func updateThumbImage(_ status: Bool) {
        self.liveDisplayView.showChangeAnilmail = status
    }
    
    public func updateRenderView(view: UIView?) {
        self.liveDisplayView.liveContentView.playerView = view
    }
    
    public func updateLiveState(state: Int) {
        self.liveDisplayView.videoState = (state, self.deviceModel?.serialNumber ?? "")
        if state != A4xPlayerStateType.playing.rawValue {
            self.liveDisplayView.liveContentView.playerView = nil
        }
    }
    
}

extension LivePlayerControlView: LiveTopBarViewProtocol {
    
    
    func deviceSettingAction() {
        self.protocol?.settingAction(subPage: nil)
    }
}

extension LivePlayerControlView: LiveBottomMenuViewProtocol {
    func controlLocation(clickModel model: A4xPresetModel?, clickType type: A4xDevicePresetCellType) {
        self.protocol?.presetItemAction(preset: model, type: type)
    }
    
    func controlType(changeToType type: LivePresetEditType) {
        self.protocol?.changePresetEditType(type: type, isShowMore: self.liveBottomMenuView.isShowMore)
    }
    
    func controlDeviceRotate(toPoint point: CGPoint) {
        self.protocol?.rotateAction(point: point)
    }
    
    func controlCommandSpeak(type: LiveSpeakActionEnum) {
        switch type {
        case .down:
            if let result = self.protocol?.speakAction(enable: true) {
                if result {
                    self.liveBottomMenuView.deviceVoiceOn = true
                    startSpeak()
                }
            }
            self.hideAllToasts()
        case .up:
            let _ = self.protocol?.speakAction(enable: false)
            stopSpeak()
        case .tap:
            var style = ToastStyle()
            style.cornerRadius = 18
            style.messageFont = UIFont.systemFont(ofSize: 13)
            style.maxHeightPercentage = 10
            style.maxWidthPercentage = 18
            style.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            style.imageSize = CGSize(width: 18, height: 18)
            style.horizontalPadding = 12
            self.hideAllToasts()
            self.makeToast(A4xBaseManager.shared.getLocalString(key: "hold_speak"), point: self.voiceAnimationView.center, title: nil, image: A4xLiveUIResource.UIImage(named: "speak_tip_icon")?.rtlImage(), style: style, completion: nil)
        }
    }
    
  
    func deviceMenuAction(type: LiveMenuActionType, comple: @escaping (Bool) -> Void) {
        switch type {
        case .sound:
            fallthrough
        case .magicPix:
            fallthrough
        case .location:
            fallthrough
        case .light:
            fallthrough
        case .alert:
            self.protocol?.menuItemAction(type: type, status: self.liveBottomMenuView.isAlerting, comple: comple)
            break
        case .track:
            self.protocol?.menuItemAction(type: type, status: self.liveBottomMenuView.isTrackingOpen, comple: comple)
            break
        case .more:
            self.protocol?.menuItemAction(type: type, status: self.liveBottomMenuView.isShowMore, comple: comple)
            break
        }
    }
}


extension LivePlayerControlView: LiveDisplayViewProtocol {
    func videoStartLiveAction(btnType: String) {
        self.protocol?.liveAction(type: 0)
    }
    
    func videoStopLiveAction() {
        self.protocol?.liveAction(type: 1)
    }
    
    func videoFullAction() {
        self.liveDisplayView.liveContentView.playerView?.removeFromSuperview()
        self.protocol?.fullAction()
    }
    
    func videoErrorAction(action: A4xVideoAction) {
        self.protocol?.errorAction(action: action)
    }
    
    func videoScreenShot() {
        self.protocol?.screenShotAction()
    }
    
    func videoRecordVideo(start: Bool) {
        self.protocol?.recordAction(isStart: start)
    }
}
