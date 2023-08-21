//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI
import YYWebImage

@objc open class A4xLiveVideoViewModel: NSObject {
    
    public override init() {}
    
    
    let maxCount: Int = 5
    
    
    func presetModelBy(deviceId: String) -> [A4xPresetModel]? {
        return presetModels[deviceId]
    }
    
    
    var presetModels: [String : [A4xPresetModel]] {
        set {
            try? Disk.save(newValue, to: .documents, as: "preset.json" )
        }
        get {
            let localModel = (try? Disk.retrieve("preset.json", from: Disk.Directory.documents, as: [String : [A4xPresetModel]].self)) ?? [:]
            return localModel
        }
    }
    
    
    func isTrackingOpen(deviceId: String) -> Bool {
        return motionTrackOpenArr[deviceId] ?? false
    }
    
    //运动追踪开启数组
    var motionTrackOpenArr: [String : Bool] = [:] {
        didSet{
            
        }
    }
    
    var trackModeArr: [String : Bool] = [:] {
        didSet {
            
        }
    }
    
    //
    public func getLocationsModel(result : @escaping ([A4xBaseAlertModelProtocol]?) -> Void) {
        DeviceLocationUtil.getAndSaveUserLocations { (code, msg, res) in }
        result(self.loadLocation())
    }
    
    //
    private func loadLocation() -> [A4xDeviceLocationFilterModel]?{
        var resultArray : [A4xDeviceLocationFilterModel] = Array()
        resultArray.append(A4xDeviceLocationAllModel())
        let locat : [A4xDeviceLocationFilterModel]? = A4xUserDataHandle.Handle?.locationsModel
        if locat != nil {
            resultArray += locat!
        }
        resultArray += [A4xDeviceLocationShareModel()]
        return resultArray;
    }
    
    public func loadMotionTrackStatus(deviceModel: DeviceBean?, comple: @escaping (_ error: String?, _ model: DeviceBean?) -> Void) {
        
        guard let device = deviceModel else {
            comple(A4xBaseManager.shared.getLocalString(key: "other_error_with_code"), nil)
            return
        }
        
        guard let device = A4xUserDataHandle.Handle?.getDevice(deviceId: device.serialNumber ?? "", modeType: device.apModeType ?? .WiFi) else {
            comple(A4xBaseManager.shared.getLocalString(key: "other_error_with_code"), nil)
            return
        }
        
        weak var weakSelf = self
        
        if device.isAdmin() {
            DeviceManageCore.getInstance().getDeviceSettingConfig(serialNumber: device.serialNumber ?? "") { code, message, model in
                weakSelf?.trackModeArr[device.serialNumber ?? ""] = (model?.motionTrackMode ?? 0) > 0
                //运动追踪or人形追踪开关状态 # 1表示 开启， 0表示 关闭
                weakSelf?.motionTrackOpenArr[device.serialNumber ?? ""] = (model?.motionTrack ?? 0) > 0
                
                var needUpdateModel = device
                needUpdateModel.needMotion = model?.needMotion
                
                //数据模型更新处理
                
                needUpdateModel.motionSensitivity = model?.motionSensitivity
                needUpdateModel.motionSensitivityOptionList = model?.motionSensitivityOptionList
                
                needUpdateModel.needNightVision = model?.needNightVision
                needUpdateModel.nightVisionSensitivity = model?.nightVisionSensitivity
                needUpdateModel.nightThresholdLevel = model?.nightThresholdLevel
                
                needUpdateModel.needAlarm = model?.needAlarm
                needUpdateModel.alarmSeconds = model?.alarmSeconds
                
                needUpdateModel.needVideo = model?.needVideo
                needUpdateModel.videoSeconds = model?.videoSeconds
                
                needUpdateModel.deviceLanguage = model?.deviceLanguage
                
                needUpdateModel.nightVisionMode = model?.nightVisionMode
                
                needUpdateModel.whiteLightScintillation = model?.whiteLightScintillation
                
                needUpdateModel.motionTrack = model?.motionTrack
                needUpdateModel.motionTrackMode = model?.motionTrackMode
                
                needUpdateModel.deviceSupportLanguage = model?.deviceSupportLanguage
                
                needUpdateModel.antiflickerSwitch = model?.antiflickerSwitch
                needUpdateModel.antiflicker = model?.antiflicker
                
                needUpdateModel.mirrorFlip = model?.mirrorFlip ?? 0
                needUpdateModel.recLamp = model?.recLamp
                
                needUpdateModel.voiceVolumeSwitch = model?.voiceVolumeSwitch
                needUpdateModel.voiceVolume = model?.voiceVolume
                
                needUpdateModel.cryDetect = model?.cryDetect
                needUpdateModel.cryDetectLevel = model?.cryDetectLevel
                
                needUpdateModel.deviceCallToggleOn = model?.deviceCallToggleOn
                
                needUpdateModel.mechanicalDingDongSwitch = model?.mechanicalDingDongSwitch
                needUpdateModel.mechanicalDingDongDuration = model?.mechanicalDingDongDuration
                
                needUpdateModel.chargeAutoPowerOnCapacity = model?.chargeAutoPowerOnCapacity
                needUpdateModel.chargeAutoPowerOnSwitch = model?.chargeAutoPowerOnSwitch
                needUpdateModel.chargeAutoPowerOnCapacityOptions = model?.chargeAutoPowerOnCapacityOptions
                
                needUpdateModel.alarmWhenRemoveToggleOn = model?.alarmWhenRemoveToggleOn
                
                needUpdateModel.liveAudioToggleOn = model?.liveAudioToggleOn
                
                
                A4xUserDataHandle.Handle?.updateDevice(device: needUpdateModel)
                
                comple(nil, needUpdateModel)
            } onError: { code, message in
                comple(message, nil)
            }

        } else {
            comple(A4xBaseManager.shared.getLocalString(key: "other_error_with_code"), nil)
        }
    }
    
    
    func updateMotionTrackStatus(deviceId : String?, enable : Bool ,comple : @escaping (_ error : String?)->Void) {
        guard let devid = deviceId else {
            return
        }
        self.motionTrackOpenArr.removeValue(forKey: devid)
        
        weak var weakSelf = self
        DeviceSettingCore.getInstance().setMotionTrack(serialNumber: devid, enable: enable) { code, message in
            weakSelf?.motionTrackOpenArr[devid] = enable
            comple(nil)
        } onError: { code, message in
            comple(message)
        }
    }
    
    
    func rotate(deviceModel: DeviceBean?, x: Float, y: Float, comple: @escaping (_ error: String?) -> Void) {
        guard let device = deviceModel else {
            return
        }
        
        guard let device = A4xUserDataHandle.Handle?.getDevice(deviceId: device.serialNumber ?? "", modeType: device.apModeType ?? .WiFi) else {
            return
        }
        
        let mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: device.serialNumber ?? "")
        mLivePlayer?.setPtz(x: x, y: y, onSuccess: { code, msg in
            comple(nil)
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
            comple(msg)
        })
    }
    
    
    
    @objc public func canAddLocation(deviceId: String?) -> Bool {
        if self.presetModelBy(deviceId: deviceId ?? "")?.count ?? 0 >= maxCount {
            return false
        }
        return true
    }
    
    
    func canAdd(deviceId: String?) -> (canAdd : Bool , errorStr : String?) {
        if self.presetModelBy(deviceId: deviceId ?? "")?.count ?? 0 >= maxCount {
            return (false , A4xBaseManager.shared.getLocalString(key: "more_pre_location", param: ["\(maxCount)"]))
        }
        return (true , nil)
    }
    
    
    func setPreLocationPoint(deviceModel: DeviceBean?, preset: A4xPresetModel?, comple: @escaping (_ error: String?)->Void) {
        guard let device = deviceModel  else {
            return
        }
        guard let device = A4xUserDataHandle.Handle?.getDevice(deviceId: device.serialNumber ?? "", modeType: device.apModeType ?? .WiFi) else {
            return
        }
        let mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: device.serialNumber ?? "")
        mLivePlayer?.setPreLocationPoint(coordinate: preset?.coordinate ?? "", onSuccess: { code, msg in
            comple(nil)
        }, onError: { code, msg in
            comple(msg)
        })
    }
    
    
    public func addPreLocationPoint(deviceModel: DeviceBean?, image: UIImage? , name: String? ,comple : @escaping (_ isError : Bool , _ tips : String?)->Void){
        guard let device = deviceModel ,let img = image ,let pName = name else {
            return
        }
        
        if self.presetModelBy(deviceId: device.serialNumber ?? "")?.count ?? 0 >= maxCount {
            comple(false, A4xBaseManager.shared.getLocalString(key: "more_pre_location", param: ["\(maxCount)"]))
            return
        }
        
        guard let device = A4xUserDataHandle.Handle?.getDevice(deviceId: device.serialNumber ?? "", modeType: device.apModeType ?? .WiFi) else {
            comple(false, A4xBaseManager.shared.getLocalString(key: "other_error_with_code"))
            return
        }
        
        let mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: device.serialNumber ?? "")
        
        mLivePlayer?.addPreLocationPoint(name: pName, image: img, onSuccess: {  [weak self] code, msg, model in
            if code == 0 {
                
                self?.addPresetLocation(deviceId: device.serialNumber ?? "", location: model ?? A4xPresetModel())
                comple(true, A4xBaseManager.shared.getLocalString(key: "add_preset_scuess"))
            } else {
                comple(false, msg)
            }
        }, onError: { code, msg in
            comple(false, msg)
        })
    }
    
    
    @objc public func delPresetPosition(deviceId: String?, pointId: Int, comple: @escaping (_ isError: Bool, _ tips: String?) -> Void) {
        guard let devid = deviceId  else {
            return
        }
        weak var weakSelf = self
        let mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: devid)
        mLivePlayer?.deletePreLocationPoint(pointId: pointId, onSuccess: { code,msg in
            weakSelf?.deletePreset(deviceId: devid, presetId: pointId)
            comple(true, A4xBaseManager.shared.getLocalString(key: "position_deleted"))
        }, onError: { code,msg in
            comple(false, msg)
        })
    }
    
    
    func searchAllPresetPosition(deviceModel: DeviceBean?, comple: @escaping (_ error : String?)->Void){
        guard let device = deviceModel else {
            return
        }
        
        guard let device = A4xUserDataHandle.Handle?.getDevice(deviceId: device.serialNumber ?? "", modeType: device.apModeType ?? .WiFi) else {
            return
        }
        
        weak var weakSelf = self
        let mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: device.serialNumber ?? "")
        mLivePlayer?.getPreLocationPoints(onSuccess: { code, responseBean in
            weakSelf?.presetModels[device.serialNumber ?? ""] = responseBean
            comple(nil)
        }, onError: { code, msg in
            comple(msg)
        })
    }
        
    
    func addPresetLocation(deviceId: String, location: A4xPresetModel) {
        guard var deLocations = self.presetModels[deviceId] else {
            return
        }
        deLocations.append(location)
        self.presetModels[deviceId]  = deLocations
    }
    
    
    func deletePreset(deviceId: String, presetId: Int) {
        guard let deLocations = self.presetModels[deviceId] else {
            return
        }
        guard deLocations.count > 0 else {
            return
        }
        let temp = deLocations.filter { (pre) -> Bool in
            if pre.presetId == presetId {
                return false
            }
            return true
        }
        self.presetModels[deviceId]  = temp
    }
    

    
    public static func playStateUIInfo(state: A4xPlayerStateType, deviceId: String, isSDCard: Bool = false, comple: @escaping (_ error: String?, _ action: A4xVideoAction?, _ icon: UIImage?) -> Void) {
        switch state {
        case .loading:
            comple(nil, nil, nil)
            break
        case .playing:
            comple(nil, nil, nil)
            break
        case .needUpdate:
            comple(nil, nil, nil)
            break
        case .forceUpdate:
            comple(nil, nil, nil)
            break
        case .updating:
            let err = A4xBaseManager.shared.getLocalString(key: "device_is_updating")
            let icon = A4xBaseResource.UIImage(named: "device_connect_supper")?.rtlImage()
            comple(err, nil, icon)
            break
        case .paused:
            comple(nil, nil, nil)
            break
        case .nonet:
            let error = A4xBaseManager.shared.getLocalString(key: "failed_to_get_information_and_try")
            let action = A4xVideoAction.video(title: A4xBaseManager.shared.getLocalString(key: "reconnect"), style: .line)
            let tipIcon = A4xLiveUIResource.UIImage(named: "video_connect_network")?.rtlImage()
            comple(error, action, tipIcon)
            break
        case .offline, .lowerShutDown, .keyShutDown, .solarShutDown:
            if let deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceId, modeType: .WiFi) {
                
                let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: deviceModel.modelCategory ?? 1)
                var errorStr = A4xBaseManager.shared.getLocalString(key: "camera_poor_network", param: [tempString, tempString])
                var errorImg = A4xLiveUIResource.UIImage(named: "video_connect_device_offline")?.rtlImage()
                var errorTimeStr = ""
                
                let is24HrFormatStr = "".timeFormatIs24Hr() ? kA4xDateFormat_24 : kA4xDateFormat_12
                
                if A4xBaseAppLanguageType.language() == .chinese || A4xBaseAppLanguageType.language() == .Japanese {
                    
                    let languageFormat = "\(A4xUserDataHandle.Handle?.getBaseDateFormatStr() ?? A4xBaseManager.shared.getLocalString(key: "terminated_format")) \(is24HrFormatStr)"
                    
                    let dataString = DateFormatter.format(languageFormat).string(from: Date(timeIntervalSince1970: deviceModel.offlineTime ?? 0))
                    
                    errorTimeStr = dataString
                } else {
                    let languageFormat = "\(is24HrFormatStr), \(A4xUserDataHandle.Handle?.getBaseDateFormatStr() ?? A4xBaseManager.shared.getLocalString(key: "terminated_format"))"
                    
                    errorTimeStr = DateFormatter.format(languageFormat).string(from: Date(timeIntervalSince1970: deviceModel.offlineTime ?? 0))
                }
                
                if state == .lowerShutDown {
                    errorStr = A4xBaseManager.shared.getLocalString(key: "low_power", param: [tempString]) + "\n\(A4xBaseManager.shared.getLocalString(key: "off_time", param: [errorTimeStr]))"
                    errorImg = A4xLiveUIResource.UIImage(named: "video_device_shutdown_lowpower")?.rtlImage()
                } else if state == .keyShutDown {
                    errorStr = A4xBaseManager.shared.getLocalString(key: "turned_off", param: [tempString]) + "\n\(A4xBaseManager.shared.getLocalString(key: "off_time", param: [errorTimeStr]))"
                    errorImg = A4xLiveUIResource.UIImage(named: "video_device_shutdown_click")?.rtlImage()
                } else if state == .solarShutDown {
                    errorStr = A4xBaseManager.shared.getLocalString(key: "camera_off_solar")
                }
                
                if isSDCard {
                    errorStr = A4xBaseManager.shared.getLocalString(key: "sdvideo_error")
                }
                
                let error = errorStr
                let action = A4xVideoAction.video(title: A4xBaseManager.shared.getLocalString(key: "reconnect"), style: .line)
                let tipIcon = errorImg
                comple(error, action, tipIcon)
            } else {
                comple(nil, nil, nil)
            }
        case .sleep:
            if let deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceId, modeType: .WiFi) {
                let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: deviceModel.modelCategory ?? 1)
                let error = A4xBaseManager.shared.getLocalString(key: "camera_sleep", param: [tempString])
                let action = A4xVideoAction.video(title: A4xBaseManager.shared.getLocalString(key: "camera_wake_up"), style: .theme)
                let tipIcon = A4xLiveUIResource.UIImage(named: "home_sleep_plan")?.rtlImage()
                comple(error, action, tipIcon)
            } else {
                comple(nil, nil, nil)
            }
            break
        case .timeout:
            var error = A4xBaseManager.shared.getLocalString(key: "live_server_timeout")
            var tipIcon = A4xLiveUIResource.UIImage(named: "video_connect_device_offline")?.rtlImage()
            if isSDCard {
                error = A4xBaseManager.shared.getLocalString(key: "sdvideo_timeout")
                tipIcon = A4xLiveUIResource.UIImage(named: "sd_video_timeout")?.rtlImage()
            }
            let action = A4xVideoAction.video(title: A4xBaseManager.shared.getLocalString(key: "reconnect"), style: .line)
            comple(error, action, tipIcon)
            break
        case .connectionLimit:
            comple(nil, nil, nil)
            break
        case .notRecvFirstFrame:
            let error = A4xBaseManager.shared.getLocalString(key: "live_failure_auto_guidance")
            let action = A4xVideoAction.notRecvFirstFrame(title: A4xBaseManager.shared.getLocalString(key: "live_failure_auto_try_btn"), style: .theme, clickState: .start)
            let tipIcon = A4xLiveUIResource.UIImage(named: "video_resolution_auto_icon")?.rtlImage()
            comple(error, action, tipIcon)
            break
        case .apOffline:
            let error = A4xBaseManager.shared.getLocalString(key: "home_notconnect_hotspot")
            let action = A4xVideoAction.apMode(title: A4xBaseManager.shared.getLocalString(key: "home_viewdevice"), style: .line)
            comple(error, action, nil)
            break
        case .noAuth:
            var error = A4xBaseManager.shared.getLocalString(key: "error_2002")
            var tipIcon = A4xLiveUIResource.UIImage(named: "video_connect_access")?.rtlImage()
            if isSDCard {
                error = A4xBaseManager.shared.getLocalString(key: "sdvideo_error")
                tipIcon = A4xLiveUIResource.UIImage(named: "sd_video_error")?.rtlImage()
            }
            
            let action = A4xVideoAction.refresh(title: A4xBaseManager.shared.getLocalString(key: "refresh"), style: .line)
            comple(error, action, tipIcon)
            break
        }
    }
    
    func getLiveState(deviceId: String, customParam: [String: Any]) -> Int? {
        let mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: deviceId, customParam: customParam)
        return mLivePlayer?.state
    }

    func hasOneDeviceIsPlayingOrLoading() -> Bool {
        return LiveManagerInstance.getInstance().isPlaying(deviceId: nil, customParam: [:])
    }
    
    func stopAllLive(skipDeviceId: String, customParam: [String : Any]?) {
        LiveManagerInstance.getInstance().stopLiveAll(skipDeviceModelId: skipDeviceId, customParam: customParam)
    }
    
    func updateAllScreenShot(customParam: [String : Any]?, comple: @escaping (_ deviceID: String) -> Void) {
        LiveManagerInstance.getInstance().updateAllScreenShot(customParam: customParam) { deviceID, screenShotURLStr, screenShotTime in
            let mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: deviceID, customParam: customParam)
            
            guard let deviceSnpURL = URL(string: screenShotURLStr ?? "") else {
                
                comple("")
                return
            }
            
            YYWebImageManager.shared().requestImage(with: deviceSnpURL, options: YYWebImageOptions.showNetworkActivity, progress: nil, transform: nil) { (img, url, from, state, error) in
                if let image = img {
                    
                    mLivePlayer?.magicPixImage(image: image, comple: { res in
                        if let magicPixImg = res {
                            
                            updateThumbImage(deviceID: deviceID, image: magicPixImg, times: screenShotTime)
                        } else {
                            
                            updateThumbImage(deviceID: deviceID, image: image, times: screenShotTime)
                        }
                        onMainThread {
                            
                            comple(deviceID)
                        }
                    })
                }
            }
        }
    }
    
}
