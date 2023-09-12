//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK
import BaseUI


public enum A4xHomeLiveVideoCollectCellEnum {
    case normalMode
    
    static public func allCase(apEnable: Bool = false) -> [A4xHomeLiveVideoCollectCellEnum] {
        var cases: [A4xHomeLiveVideoCollectCellEnum] = Array()
        cases = [.normalMode]
        return cases
    }
}

protocol A4xHomeLiveVideoCollectCellProtocol : class {
    
    func videoControlFull(device: DeviceBean?, indexPath: IndexPath?)
    
    
    func deviceSetting(device: DeviceBean?, subPage: String?)
    
    
    func deviceOTAAction(device : DeviceBean?, state: String?, clickState: LiveOtaActionType?)
    
    
    func deviceCellModelUpdate(device : DeviceBean?, type : A4xVideoCellType , indexPath: IndexPath?)
    
    
    func deviceSleepToWakeUp(device : DeviceBean?)
    
    
    func videoRefreshUI(device: DeviceBean?, isRefreshAll: Bool)
    
    
    func muteVoiceGoSoundSetting(deviceModel: DeviceBean?)
}

class A4xHomeAPLiveCollectCell: UICollectionViewCell {
    open var apTitleLabel: UILabel?
    
    
    lazy var apModeEnterView: UIView = {
        var view = UIView()
        view.backgroundColor = .white
        view.cornerRadius = 12.auto()
        self.contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.height.equalTo(50.auto())
            make.width.equalTo(self.contentView.snp.width).offset(-16.auto())
            make.leading.equalTo(self.contentView.snp.leading).offset(8.auto())
        }
        
        let iconImgView = UIImageView()
        view.addSubview(iconImgView)
        iconImgView.image = A4xLiveUIResource.UIImage(named: "homepage_ap_icon")
        iconImgView.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.height.equalTo(24.auto())
            make.width.equalTo(24.auto())
            make.leading.equalTo(view.snp.leading).offset(8.auto())
        }
        
        let arrowImgView = UIImageView()
        arrowImgView.contentMode = .center
        arrowImgView.image = bundleImageFromImageName("home_user_info_arrow")?.rtlImage()
        view.addSubview(arrowImgView)
        arrowImgView.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.height.equalTo(11.auto())
            make.width.equalTo(5.5.auto())
            make.trailing.equalTo(view.snp.trailing).offset(-8.auto())
        }
        
        let titleLbl = UILabel()
        view.addSubview(titleLbl)
        titleLbl.textAlignment = .left
        titleLbl.font = UIFont.regular(15)
        titleLbl.textColor = ADTheme.C1
        titleLbl.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.height.equalTo(24.auto())
            make.trailing.equalTo(arrowImgView.snp.leading).offset(-14.auto())
            make.leading.equalTo(iconImgView.snp.trailing).offset(9.auto())
        }
        apTitleLabel = titleLbl
        
        return view
    }()
    
    //MARK:- 生命周期
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 11.auto()
        self.contentView.layer.masksToBounds = true

        self.apModeEnterView.isHidden = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class A4xHomeLiveVideoCollectCell: UICollectionViewCell {
    
    var videoStyle      : A4xVideoCellType = .default
    
    var indexPath       : IndexPath?
    
    weak var `protocol` : A4xHomeLiveVideoCollectCellProtocol?
    
    var autoFollowBlock: ((_ deviceModel: DeviceBean?, Bool, _ comple: @escaping (Bool) -> Void) -> Void)?

    var itemliveStartBlock: ((_ deviceModel: DeviceBean?) -> Void)?

    var presetItemActionBlock: ((_ deviceModel: DeviceBean?, A4xPresetModel?, A4xDevicePresetCellType, UIImage?) -> Void)?
    
    var liveStateChangeBlock: ((_ deviceModel: DeviceBean?, _ stateCode: Int) -> Void)?
    
    var dataSource: DeviceBean? {
        didSet {
            
            updateVideoSytle()
        }
    }
    
    var dataDic: [String: Any]? {
        didSet {
            
        }
    }
    
    var mLivePlayer: LivePlayer?
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    //MARK:- 生命周期
    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.cornerRadius = 11.auto()
        self.contentView.layer.masksToBounds = true
    }
    
    deinit {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var livePlayerControlView: LivePlayerControlView = {
        let temp = LivePlayerControlView()
        temp.protocol = self
        temp.backgroundColor = .clear
        temp.layer.cornerRadius = 11
        temp.layer.masksToBounds = true
        temp.layer.shadowPath = UIBezierPath(rect: temp.bounds).cgPath
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return temp
    }()
    
    
    private func updateVideoSytle() {
        
        let width = min(UIApplication.shared.keyWindow?.width ?? 359.auto(), UIApplication.shared.keyWindow?.height ?? 359.auto())
        let minWidth = min(self.width, width)
        self.contentView.frame = CGRect(x: 0, y: 0, width: minWidth, height: self.height)
        livePlayerControlView.isHidden = false
        
        LiveManagerInstance.getInstance().addLiveStateProtocol(deviceId: "all", target: self)
        mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: dataSource?.serialNumber ?? "")
        mLivePlayer?.setListener(liveStateListener: self)
        
        self.livePlayerControlView.videoStyle = self.videoStyle
        
        let whiteLight = mLivePlayer?.getWhiteLight() ?? false
        let audioEnable = mLivePlayer?.getAudioEnable() ?? false
        let voiceEffect = mLivePlayer?.getVoiceEffect() ?? 0
        let magicPixEnable = mLivePlayer?.getMagicPixEnable() ?? false
        let magicPixProcessState = mLivePlayer?.magicPixProcessState ?? 0
        let isRecord = mLivePlayer?.isRecord
        
        self.dataDic?["whiteLight"] = whiteLight
        self.dataDic?["audioEnable"] = audioEnable
        self.dataDic?["voiceEffect"] = voiceEffect
        self.dataDic?["magicPixEnable"] = magicPixEnable
        self.dataDic?["magicPixProcessState"] = magicPixProcessState
        self.dataDic?["isRecord"] = isRecord
        
        self.livePlayerControlView.dataDic = self.dataDic
        self.livePlayerControlView.updateSubViews(deviceModel: self.dataSource, playerView: mLivePlayer?.playView, state: mLivePlayer?.state ?? A4xPlayerStateType.paused.rawValue)//deviceModel = self.dataSource
    }
    
    public func showChangeAnilmail(_ status: Bool) {
        self.livePlayerControlView.updateThumbImage(status)
    }
    
    public func updateMagicPixProcessState(state: Int) {
        self.livePlayerControlView.updateMagicPixProcessState(state: state)
    }
    
    public func updateVoiceMicAnimation(points: [Float]?) {
        self.livePlayerControlView.updateVoiceMicAnimation(pointLocation: points)
    }
    
    private func magicPixAction(enable: Bool, comple: @escaping (Bool) -> Void) {
        
        
        if enable {
            
            setMagicPixEnable(comple: comple)
        } else {
            
            
            switch sysSupportMagicPixVideo() {
            case .none:
                break
            case .weak:
                break
            case .strong:
                
                setMagicPixEnable(comple: comple)
                break
            case .unknown:
                break
            }
        }
    }
    
    private func setMagicPixEnable(comple: @escaping (Bool) -> Void) {
        guard let dataSource = self.dataSource else {
            comple(false)
            return
        }

        guard dataSource.serialNumber != nil else {
            comple(false)
            return
        }

        let enable = mLivePlayer?.getMagicPixEnable() ?? false
        mLivePlayer?.magicPixEnable(enable: !enable)

        let magicPixEnable = mLivePlayer?.getMagicPixEnable() ?? false
        self.livePlayerControlView.updateMagicEnable(enable: magicPixEnable)

        if magicPixEnable {
            let magicPixProcessState = mLivePlayer?.magicPixProcessState ?? 0
            self.livePlayerControlView.updateMagicPixProcessState(state: magicPixProcessState)
        } else {
            self.livePlayerControlView.updateMagicPixProcessState(state: 0)
        }
        comple(true)
    }
    
    
    private func showDeviceAlert(title: String? = nil, message: String? = nil, cancelTitle: String? = nil, doneTitle: String? = nil, image: UIImage? = nil, doneAction: (() -> Void)? = nil, cancleAction: (() -> Void)? = nil) {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = UIColor.white
        config.rightbtnBgColor = UIColor.white
        config.leftTitleColor = ADTheme.C1
        config.rightTextColor = ADTheme.E1
        config.messageImg = image
        let alert = A4xBaseAlertView(param: config, identifier: "title \(title ?? "")")
        alert.title = title
        alert.message = message
        alert.leftButtonTitle = cancelTitle
        alert.rightButtonTitle = doneTitle
        alert.rightButtonBlock = {
            doneAction?()
        }
        alert.leftButtonBlock = {
            cancleAction?()
        }
        alert.show()
    }
    
    
    private func stopOtherLive() {
        let playCount = 1
        LiveManagerInstance.getInstance().stopOtherLive(skipDeviceId: dataSource?.serialNumber ?? "", customParam: ["playerNumber" : playCount, "apToken" : dataSource?.apModeModel?.aptoken ?? "", "live_player_type" : "vertical"]) { code in
            if code == -1 {
                UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "same_time_play_most"))
            }
        }
    }
}

extension A4xHomeLiveVideoCollectCell: LivePlayerControlViewProtocol {
    
    func settingAction(subPage: String?) {
        self.protocol?.deviceSetting(device: self.dataSource, subPage: subPage)
    }
    
    func liveAction(type: Int) {
        guard let dataSource = self.dataSource else {
            return
        }
        if type == 0 { 
            if let state = A4xPlayerStateType(rawValue: mLivePlayer?.state ?? A4xPlayerStateType.paused.rawValue) {
                
                switch state {
                case .updating:
                    
                    break
                case .needUpdate, .forceUpdate:
                    
                    var doNotUpdateDic = UserDefaults.standard.dictionary(forKey: "do_not_update") ?? [:]
                    doNotUpdateDic["do_not_update_\(self.dataSource?.serialNumber ?? "null")"] = "1"
                    UserDefaults.standard.set(doNotUpdateDic, forKey: "do_not_update")
                    self.protocol?.videoRefreshUI(device: self.dataSource, isRefreshAll: false)
                    break
                case .paused:
                    break
                default:
                    break
                }
            }
            
            self.itemliveStartBlock?(dataSource)
            
            
            self.stopOtherLive()
            
            
            mLivePlayer?.startLive(customParam: ["apToken" : dataSource.apModeModel?.aptoken ?? "", "live_player_type" : self.videoStyle == .default ? "vertical" : "split"])
        } else { 
            mLivePlayer?.stopLive()
        }
    }
    
    func errorAction(action: A4xVideoAction) {
        if case .upgrade(let actionTitle, _, let clickState) = action {
            if self.dataSource?.isAdmin() ?? true {
                
                if clickState == .later {
                    if let state = A4xPlayerStateType(rawValue: mLivePlayer?.state ?? A4xPlayerStateType.paused.rawValue) {
                        switch state {
                        case .needUpdate, .forceUpdate:
                            var doNotUpdateDic = UserDefaults.standard.dictionary(forKey: "do_not_update") ?? [:]
                            doNotUpdateDic["do_not_update_\(self.dataSource?.serialNumber ?? "null")"] = "1"
                            UserDefaults.standard.set(doNotUpdateDic, forKey: "do_not_update")
                            self.protocol?.videoRefreshUI(device: self.dataSource, isRefreshAll: false)
                            return
                        default:
                            break
                        }
                    }
                }
                self.protocol?.deviceOTAAction(device: self.dataSource, state: actionTitle, clickState: clickState)
            }
        } else if case .sleepPlan = action {
            
            self.protocol?.deviceSleepToWakeUp(device: self.dataSource)
        } else if case .apMode = action {
            self.protocol?.deviceSetting(device: self.dataSource, subPage: "apModeGuide")
        } else if case .notRecvFirstFrame(_, _, let clickState) = action {
            
            self.stopOtherLive()
            
            if clickState == .start {
                dataSource?.saveResolutionToCache(type: .auto)
                mLivePlayer?.startLive(customParam: ["apToken" : dataSource?.apModeModel?.aptoken ?? "", "live_player_type" : self.videoStyle == .default ? "vertical" : "split"])
            } else if clickState == .noThanks {
                mLivePlayer?.startLive(customParam: ["autoResolutionEnable": false])
            }
        } else {
            self.protocol?.videoRefreshUI(device: dataSource, isRefreshAll: true)
        }
    }
    
    func screenShotAction() {
        A4xBasePhotoManager.default().checkAuthor { [weak self] error in
            if error == .no {
                self?.mLivePlayer?.screenShot(onSuccess: { _code, msg, image in
                    guard let img = image else {
                        self?.makeToast(A4xBaseManager.shared.getLocalString(key: "shot_fail"))
                        return
                    }
                    A4xBasePhotoManager.default().save(image: img, result: { (result, att) in
                        
                        if result {
                            self?.makeToast(A4xBaseManager.shared.getLocalString(key: "record_success"))
                        } else {
                            self?.makeToast(A4xBaseManager.shared.getLocalString(key: "shot_fail"))
                        }
                    })
                }, onError: { code, msg in
                    
                })
            } else {
                A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.photo) {_ in }
            }
        }
    }
    
    func recordAction(isStart: Bool) {
        
        A4xBasePhotoManager.default().checkAuthor { [weak self] (error) in
            if error == .no {
                if isStart {
                    self?.mLivePlayer?.startRecord(path: NSHomeDirectory() + "/Documents/webrtcTmp.mp4")
                } else {
                    self?.mLivePlayer?.stopRecord()
                }
            } else {
                if error == .reject {
                }
                A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.photo) { _ in
                }
            }
        }
    }
    
    func fullAction() {
        self.protocol?.videoControlFull(device: self.dataSource, indexPath: self.indexPath)
    }
    
    func menuItemAction(type: LiveMenuActionType, status: Bool?, comple: @escaping (Bool) -> Void) {
        guard let dataSource = self.dataSource else {
            comple(true)
            return
        }
        
        guard dataSource.serialNumber != nil else {
            comple(true)
            return
        }
        
        switch type {
        case .sound:
            let enable = !(mLivePlayer?.getAudioEnable() ?? false)
            mLivePlayer?.audioEnable(enable: enable)
            comple(true)
        case .alert:
            if status ?? false {
                self.makeToast(A4xBaseManager.shared.getLocalString(key: "alarm_playing"))
                comple(false)
            } else {
                weak var weakSelf = self
                let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: dataSource.modelCategory ?? 1)
                self.showDeviceAlert(message: A4xBaseManager.shared.getLocalString(key: "do_alarm_tips", param: [tempString]), cancelTitle: A4xBaseManager.shared.getLocalString(key: "cancel"), doneTitle: A4xBaseManager.shared.getLocalString(key: "alarm_on"), image: bundleImageFromImageName("device_send_alert")?.rtlImage(), doneAction: { [weak self] in
                    self?.mLivePlayer?.setAlarm(onSuccess: { code, msg in
                        comple(true)
                    }, onError: { code, msg in
                        weakSelf?.makeToast(A4xAppErrorConfig(code: code).message())
                        
                        comple(false)
                    })
                }) {
                    comple(false)
                }
            }
        case .magicPix:
            let enable = mLivePlayer?.getMagicPixEnable() ?? false
            self.magicPixAction(enable: enable, comple: comple)
            break
        case .track:
            self.autoFollowBlock?(dataSource ,!(status ?? false), comple)
        case .location:
            self.protocol?.deviceCellModelUpdate(device: dataSource, type: .locations, indexPath: self.indexPath)
            comple(true)
        case .light:
            let isOn = mLivePlayer?.getWhiteLight() ?? false
            mLivePlayer?.setWhiteLight(enable: !isOn, onSuccess: { code, msg in
                comple(true)
            }, onError: { code, msg in
                comple(false)
            })
        case .more:
            self.protocol?.deviceCellModelUpdate(device: dataSource, type: .playControl(isShowMore: !(status ?? false)), indexPath: self.indexPath)
            comple(true)
            break

        }
    }
    
    func presetItemAction(preset: A4xPresetModel?, type: A4xDevicePresetCellType) {
        if type == .add {
            mLivePlayer?.screenShot(onSuccess: {  [weak self] _code, msg, image in
                self?.presetItemActionBlock?(self?.dataSource, preset, type, image)
            }, onError: { code, msg in
                
            })
        } else {
            self.presetItemActionBlock?(self.dataSource, preset, type, nil)
        }
    }
    
    func changePresetEditType(type: LivePresetEditType, isShowMore: Bool) {
        switch type {
        case .none:
            let playType = A4xVideoCellType.playControl(isShowMore: isShowMore)
            self.protocol?.deviceCellModelUpdate(device: self.dataSource, type: playType, indexPath: self.indexPath)
        case .show:
            self.protocol?.deviceCellModelUpdate(device: self.dataSource, type: .locations, indexPath: self.indexPath)
        case .edit:
            self.protocol?.deviceCellModelUpdate(device: self.dataSource, type: .locations, indexPath: self.indexPath)
        case .delete:
            self.protocol?.deviceCellModelUpdate(device: self.dataSource, type: .locations_edit, indexPath: self.indexPath)
        }
    }
    
    func speakAction(enable: Bool) -> Bool {
        let signal = DispatchSemaphore(value: 1)
        var isOpenRecord = false
        openRecordServiceWithBlock { [weak self] flag in
            if !flag {
                A4xBaseAuthorizationViewModel.single.showRequestAlert(type: .audio) { _ in }
                signal.signal()
            } else {
                isOpenRecord = true
                signal.signal()
            }
        }
        
        let result = signal.wait(timeout: .distantFuture)
        if result == .success {
            if enable {
                if !isOpenRecord {
                    return false
                }
                mLivePlayer?.audioEnable(enable: true)
            }
        }
        mLivePlayer?.speakEnable(enable: enable)
        return true
    }
    
    func rotateAction(point: CGPoint) {
        mLivePlayer?.setPtz(x: Float(point.x), y: Float(point.y), onSuccess: { code, msg in
        }, onError: { code, msg in
            switch code {
            case -6:
                UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "limit_reached"), position: ToastPosition.bottom(offset: 50))
                break
            case -7:
                UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "calibrating_now_try_later"), position: ToastPosition.bottom(offset: 50))
                break
            default:
                break
            }
        })
    }
}


extension A4xHomeLiveVideoCollectCell: LiveManagerInstanceProtocol {
    public func onIJKPlayer(deviceId: String) -> LivePlayer? {
        return nil
    }
}


extension A4xHomeLiveVideoCollectCell: ILiveStateListener {
    ///
    public func onRenderView(surfaceView: UIView) {
        self.livePlayerControlView.updateRenderView(view: surfaceView)
    }
    
    ///
    public func onPlayerState(stateCode: Int, msg: String) {
        let voipLiveKey = UserDefaults.standard.value(forKey: "A4xDoorBellLiveKey") as? String
        if voipLiveKey == "1" {
            return
        }
        
        self.liveStateChangeBlock?(self.dataSource, stateCode)
    }
    
    ///
    public func onRecordState(state: Int, videoPath: String) {
        let s = A4xPlayerRecordState.init(rawValue: state)
        switch s {
        case .start:
            self.livePlayerControlView.liveDisplayView.updataRecoredState(recordState: .start)
        case .end:
            self.livePlayerControlView.liveDisplayView.updataRecoredState(recordState: .stop)
            A4xBasePhotoManager.default().save(videoPath: videoPath) { (result, id) in
                if result {
                    UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "record_success"))
                } else {
                    UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "record_failed"))
                }
            }
        case .startError:
            self.livePlayerControlView.liveDisplayView.updataRecoredState(recordState: .stop)
        case .endError:
            self.livePlayerControlView.liveDisplayView.updataRecoredState(recordState: .stop)
        case .none:
            break
        }
    }
    
    ///
    public func onMicFrame(data: [Float]) {
        self.updateVoiceMicAnimation(points: data)
    }
    
    ///
    public func onDeviceMsgPush(code: Int) {
        var message = ""
        switch code {
        case 1:
            message = A4xBaseManager.shared.getLocalString(key: "network_low")
            break
        case 2:
            message = A4xBaseManager.shared.getLocalString(key: "live_viewers_limit")
            break
        case 3:
            
            A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.localNet) { [weak self](f) in
                if !f {
                } else {
                    self?.mLivePlayer?.sendLiveMessage(customParam: ["isLocalNetLimit": true])
                }
            }
            break
        case -1:
            message = A4xBaseManager.shared.getLocalString(key: "sd_card_not_exist")
            break
        case -2:
            let message = A4xBaseManager.shared.getLocalString(key: "sdcard_has_no_video")
            break
        case -3:
            let message = A4xBaseManager.shared.getLocalString(key: "sdcard_need_format")
            break
        case -4:
            let message = A4xBaseManager.shared.getLocalString(key: "SDcard_video_viewers_limit")
            break
        case -5:
            message = A4xBaseManager.shared.getLocalString(key: "other_error_with_code")
            break
        default:
            break
        }
        if message.count > 0 {
            if message == A4xBaseManager.shared.getLocalString(key: "network_low") {
                return
            }
            UIApplication.shared.keyWindow?.makeToast(message)
        }
    }
    
}


extension A4xHomeLiveVideoCollectCell {
    
    static func heightForDevice(type: A4xVideoCellType, itemWidth: CGFloat, deviceModel: DeviceBean?) -> CGFloat {
        let videoHeight: CGFloat = itemWidth / ((deviceModel?.isFourByThree() ?? false) ? 1.33 : 1.8 )
        let normalVideoBaseHeight: CGFloat = videoHeight + ((deviceModel?.isFourByThree() ?? false) ? 40.auto() : 50.auto())
        switch type {
        case .default:
            return normalVideoBaseHeight
        case .locations:
            fallthrough
        case .locations_edit:
            fallthrough
        case .playControl:
            return normalVideoBaseHeight + LiveBottomMenuView.height(type: type, forWidth: itemWidth, alertSupper: deviceModel?.deviceSupport?.deviceSupportAlarm ?? false, supportMagicPix: deviceModel?.deviceSupportMagicPix() ?? false, rotateEnable: deviceModel?.deviceContrl?.canRotate ?? false, supportMotionTrack: deviceModel?.deviceContrl?.supportMotionTrack ?? false, whiteLight: deviceModel?.deviceContrl?.whiteLight ?? false, supportVoiceEffect: deviceModel?.deviceSupportVoiceEffect() ?? false)
        }
    }
}
