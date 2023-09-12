//


//


//

import Foundation
import SmartDeviceCoreSDK

protocol LiveBottomMenuViewProtocol: class {
    func controlLocation(clickModel model: A4xPresetModel?, clickType type: A4xDevicePresetCellType)
    func controlType(changeToType type: LivePresetEditType)
    func controlDeviceRotate(toPoint point: CGPoint)
    func controlCommandSpeak(type: LiveSpeakActionEnum)
    func deviceMenuAction(type: LiveMenuActionType, comple: @escaping (Bool) -> Void)
}

class LiveBottomMenuView: UIView {
    
    weak var `protocol` : LiveBottomMenuViewProtocol? = nil
    
    var deviceModel: DeviceBean? {
        didSet {
            self.alpha = (self.deviceModel?.deviceContrl?.canRotate ?? false) ? 1 : 0.8
            
            self.canRotate = self.deviceModel?.deviceContrl?.canRotate ?? false
            
            self.supportMotionTrack = self.deviceModel?.deviceContrl?.supportMotionTrack ?? false
            
            self.lightEnable = self.deviceModel?.deviceContrl?.whiteLight ?? false
            
            self.volumeButtonStatus = self.deviceModel?.liveAudioToggleOn
            
            self.supperAlert = self.deviceModel?.deviceSupport?.deviceSupportAlarm ?? false
            
            self.editEnable = self.deviceModel?.isAdmin() ?? true
        }
    }
    
    var dataDic: [String: Any]? {
        didSet {
            
            let autoFollowBtnIsHumanImg = dataDic?["autoFollowBtnIsHumanImg"] as? Bool
            let isTrackingOpen = dataDic?["isTrackingOpen"] as? Bool
            let isFollowAdmin = dataDic?["isFollowAdmin"] as? Bool
            let presetListData = dataDic?["presetListData"] as? [A4xPresetModel]?
            self.autoFollowBtnIsHumanImg = autoFollowBtnIsHumanImg ?? false
            self.isTrackingOpen = isTrackingOpen ?? false
            self.isFollowAdmin = isFollowAdmin ?? false
            self.presetListData = presetListData ?? []
            
            let whiteLight = self.dataDic?["whiteLight"] as? Bool
            let audioEnable = self.dataDic?["audioEnable"] as? Bool
            let voiceEffect = self.dataDic?["voiceEffect"] as? Int
            let magicPixEnable = self.dataDic?["magicPixEnable"] as? Bool
            let magicPixProcessState = self.dataDic?["magicPixProcessState"] as? Int
            
            self.lightisOn = whiteLight ?? false
            self.deviceVoiceOn = audioEnable ?? false
            self.magicPixEnable = magicPixEnable ?? false
            if magicPixEnable ?? false {
                self.magicPixProcessState = magicPixProcessState ?? 0
            } else {
                self.magicPixProcessState = 0
            }
        }
    }
    
    
    var presetListData: [A4xPresetModel]? {
        didSet {
            self.editView.presetListData = presetListData
        }
    }
    
    var videoStyle: A4xVideoCellType = .default {
        didSet {
            self.commentView.videoStyle = videoStyle
        }
    }

    
    var canRotate: Bool = true
    
    
    var supportMotionTrack: Bool = true
    
    
    var lightEnable: Bool = true
    
    
    var supperAlert: Bool = false {
        didSet {
            self.menuView.updateUIState(type: .alert)
        }
    }
    
    
    var volumeButtonStatus: Bool? = true {
        didSet {
            self.menuView.updateUIState(type: .sound)
        }
    }
    
    
    var deviceVoiceOn: Bool = false {
        didSet {
            self.menuView.updateUIState(type: .sound)
        }
    }
    
    
    var magicPixEnable: Bool = false {
        didSet {
            self.menuView.updateItemInfo(type: .magicPix)
        }
    }
    
    
    var magicPixProcessState: Int = 0 {
        didSet {
            self.menuView.updateItemInfo(type: .magicPix)
        }
    }
    
    
    var isTrackingOpen: Bool = false {
        didSet {
            self.menuView.updateUIState(type: .track)
        }
    }
    
    
    var lightisOn: Bool = false{
        didSet {
            self.menuView.updateUIState(type: .light)
        }
    }
    
    
    var isShowMore: Bool = false {
        didSet {}
    }
    
    
    var isFollowAdmin: Bool = false {
        didSet {
            self.editView.isAdmin = isFollowAdmin
            self.menuView.updateUIState(type: .track)
        }
    }
    
    
    var editEnable: Bool = true {
        didSet {
            self.editView.editEnable = editEnable
            self.editView.isAdmin = editEnable
        }
    }

    
    var isAlerting: Bool {
        return menuView.isAlerting
    }
    
    
    var autoFollowBtnIsHumanImg: Bool = false
    
    
    var editModle: LivePresetEditType = .none {
        didSet {
            if self.editModle == .show || self.editModle == .none {
                self.editView.isHidden = true
            } else {
                self.editView.isHidden = false
            }
            self.editView.editModle = (self.editModle == .delete)
        }
    }
    
    override var frame: CGRect{
        didSet {}
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.menuView.isHidden = false
        self.commentView.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {}
    
    
    func updateUI() {
        switch self.videoStyle {
        case .default:
            fallthrough
        case .locations:
            self.menuView.isHidden = true
            self.commentView.isHidden = true
            self.editView.isHidden = false
            self.editView.editMenuViewType = .location
            self.editView.editModle = false
        case .locations_edit:
            self.menuView.isHidden = true
            self.commentView.isHidden = true
            self.editView.isHidden = false
            self.editView.editMenuViewType = .location
            self.editView.editModle = true
        case .playControl(let isShowMore):
            self.isShowMore = isShowMore
            self.menuView.isHidden = false
            self.menuView.initMenuUI()
            
            self.menuView.snp.updateConstraints { make in
                make.height.equalTo(self.menuView.getMenuHeight(isMore: self.isShowMore))
            }
            
            self.commentView.isHidden = false
            self.editView.isHidden = true
            
            if canRotate {
                self.commentView.snp.updateConstraints { make in
                    make.height.equalTo(CGFloat(145.auto() + 24.auto()))
                }
            } else {
                self.commentView.snp.updateConstraints { make in
                    make.height.equalTo(CGFloat(95.auto() + 24.auto()))
                }
            }
            
            
            self.commentView.updateView()
            
            self.layoutIfNeeded()
        }
    }
    
    
    private lazy var menuView: A4xHomeDeviceMenuView = {
        let temp = A4xHomeDeviceMenuView()
        self.addSubview(temp)
        temp.protocol = self
        temp.snp.makeConstraints { make in
            make.top.equalTo(16.auto())
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(92.auto())
            make.width.equalTo(self.snp.width)
        }
        return temp
    }()
    
    
    private lazy var commentView: A4xHomeDeviceCommandView = {
        let temp = A4xHomeDeviceCommandView()
        self.addSubview(temp)
        temp.dragTapProtocol = self
        temp.protocol = self
        
        temp.snp.makeConstraints { make in
            make.top.equalTo(menuView.snp.bottom).offset(8.auto())
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(self.height - 98.auto())
            make.width.equalTo(self.snp.width)
        }
        return temp
    }()
    
    
    private lazy var editView: LiveMenulEditView = {
        let temp = LiveMenulEditView()
        temp.protocol = self
        self.addSubview(temp)
        
        temp.snp.makeConstraints { make in
            make.top.equalTo(8.auto())
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(self.snp.height)
            make.width.equalTo(self.snp.width)
        }
        return temp
    }()
    
    static var menuHeight: CGFloat = 0.0
    static func height(type: A4xVideoCellType, forWidth width: CGFloat, alertSupper: Bool, supportMagicPix: Bool, rotateEnable rotate: Bool, supportMotionTrack: Bool, whiteLight light: Bool, supportVoiceEffect: Bool) -> CGFloat {
        
        let canRtateMinHeight: CGFloat = 230.auto()
        
        switch type {
        case .default:
            fallthrough
        case .locations:
            fallthrough
        case .locations_edit:
            menuHeight = 220.auto()
            return menuHeight
        case .playControl(let isShowMore):
            let menuHeigt = A4xHomeDeviceMenuView.height(forWidth: width, alertSupper: alertSupper, supportMagicPix: supportMagicPix, rotateEnable: rotate, supportMotionTrack: supportMotionTrack, whiteLight: light, supportVoiceEffect: supportVoiceEffect, showMore: isShowMore)
            if rotate {
                menuHeight = max(menuHeigt + 145.auto() + 24.auto(), canRtateMinHeight)
                return menuHeight
            } else {
                menuHeight = max(menuHeigt + 95.auto() + 24.auto(), canRtateMinHeight)
                return menuHeight
            }
        }
    }
}


extension LiveBottomMenuView: LiveMenulEditViewProtocol {
    
    func deviceLocationClose(ofView: LiveMenulEditView) {
        self.protocol?.controlType(changeToType: LivePresetEditType.none)
    }
    
    
    func deviceLocationEdit(ofView: LiveMenulEditView, type: LivePresetEditType) {
        self.protocol?.controlType(changeToType: type)
    }
    
    
    func deviceLocationClick(ofView: LiveMenulEditView, location: A4xPresetModel?, type: A4xDevicePresetCellType) {
        self.protocol?.controlLocation(clickModel: location, clickType: type)
    }
}

extension LiveBottomMenuView: A4xDeviceRockerControlViewProtocol {
    func onCircleTapAction(point: CGPoint) {
        self.protocol?.controlDeviceRotate(toPoint: point)
    }
}

extension LiveBottomMenuView: A4xHomeDeviceCommandViewProtocol {
    func deviceCommandSpeak(type: LiveSpeakActionEnum) {
        self.protocol?.controlCommandSpeak(type: type)
    }
    
    func deviceCommandRotate() -> Bool {
        return self.canRotate
    }
}


extension LiveBottomMenuView: A4xHomeDeviceMenuViewProtocol {
    
    func deviceMenuClick(type: LiveMenuActionType, comple: @escaping (Bool) -> Void) {
        guard let pro = self.protocol else {
            comple(true)
            return
        }
        
        pro.deviceMenuAction(type: type) { [weak self] res in
            comple(res)
            switch type {
            case .sound:
                if res {
                    self?.deviceVoiceOn = !(self?.deviceVoiceOn ?? false)
                }
                break
            case .light:
                if res {
                    self?.lightisOn = !(self?.lightisOn ?? false)
                }
                break
            case .alert:
                break
            case .magicPix:
                break
            case .track:
                if res {
                    self?.isTrackingOpen = !(self?.isTrackingOpen ?? false)
                }
                break
            case .location:
                break
            case .more:
                break
            }
        }
    }
    
    
    //声音按钮是否置灰
    func deviceIsLiveAudioToggleOn() -> Bool {
        return volumeButtonStatus ?? true
    }
    
    func deviceVoiceIsOn() -> Bool {
        return deviceVoiceOn
    }

    func devcieSupperAlert() -> Bool {
        return supperAlert
    }
    
    func deviceRotateEnable() -> Bool {
        return canRotate
    }
    
    func deviceSupportMotionTrack() -> Bool {
        return supportMotionTrack
    }
    
    func deviceMoveIsHuman() -> Bool {
        return autoFollowBtnIsHumanImg
    }
    
    func deviceLightEnable() -> Bool {
        return lightEnable
    }
    
    func deviceLightisOn() -> Bool {
        return lightisOn
    }
    
    func deviceIsAdmin() -> Bool {
        return self.isFollowAdmin
    }
    
    func deviceIsShowMore() -> Bool {
        return isShowMore
    }
    
    func deviceIsAlerting() -> Bool {
        return true
    }
    
    func deviceIsTrackingOpen() -> Bool {
        return self.isTrackingOpen && self.isFollowAdmin
    }

    
    func deviceMagicPixEnable() -> Bool {
        return self.magicPixEnable
    }
    
    func deviceMagicPixProcessState() -> Int {
        return self.magicPixProcessState
    }
    
    func deviceSupportVoiceEffect() -> Bool {
        return deviceModel?.deviceSupportVoiceEffect() ?? false
    }
    
    func deviceSupportMagicPix() -> Bool {
        let sysSupportMagicPixVideo = (sysSupportMagicPixVideo() == .strong || sysSupportMagicPixVideo() == .weak)
        return (deviceModel?.deviceSupportMagicPix() ?? false) && sysSupportMagicPixVideo
    }
    
    
}
