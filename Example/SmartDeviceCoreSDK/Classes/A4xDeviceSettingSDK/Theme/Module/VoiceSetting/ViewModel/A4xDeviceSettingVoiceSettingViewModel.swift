//


//


//

import UIKit
import SmartDeviceCoreSDK

class A4xDeviceSettingVoiceSettingViewModel: NSObject {

    
    @objc public static let shared = A4xDeviceSettingVoiceSettingViewModel()
    
    
    public var deviceModel : DeviceBean?
    
    
    public var deviceAttributeModel : DeviceAttributesBean?
    
    
    var allCases : Array<Array<A4xDeviceSettingModuleModel>>? = []
    
    //MARK: ----- 获取网络请求数据 -----
    public func getDeviceInfoFromNetwork(comple: @escaping (_ code: Int) -> Void)
    {
        weak var weakSelf = self
        DeviceSettingCoreUtil.getDeviceAttributes(deviceId: self.deviceModel?.serialNumber ?? "") { code, model, message in
            if code == 0 {
                weakSelf?.deviceAttributeModel = model
                weakSelf?.allCases = weakSelf?.getAllCases()
                comple(code)
            } else {
                 comple(code)
            }
        }
    }
    
    
    public func getAllCases() -> Array<Array<A4xDeviceSettingModuleModel>>
    {
        var allModels : Array<Array<A4xDeviceSettingModuleModel>> = []
        
        let alarmRingModule = self.getAlarmRingCase()
        if alarmRingModule.count > 0 {
            allModels.append(alarmRingModule)
        }
        
        
        let voiceModule = self.getVoiceCase()
        if voiceModule.count > 0 {
            allModels.append(voiceModule)
        }
        
        
        let audioModule = self.getAudioCase()
        if audioModule.count > 0 {
            allModels.append(audioModule)
        }
        
        
        let liveSpeakerVolumeModule = self.getLiveSpeakerVolumeCase()
        if liveSpeakerVolumeModule.count > 0 {
            allModels.append(liveSpeakerVolumeModule)
        }
        
        self.allCases = allModels
        
        return self.allCases ?? []
    }
    
    
    private func getAlarmRingCase() -> Array<A4xDeviceSettingModuleModel>
    {
        
        let tool = A4xDeviceSettingModuleTool()
        var models: Array<A4xDeviceSettingModuleModel> = []
            
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            if name == "alarmVolume" {
                let value = attrModel?.value
                let valueInt = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Int ?? 0
                
                let intRange = attrModel?.intRange
                let min = intRange?["min"] ?? 0
                let max = intRange?["max"] ?? 0
                let interval = intRange?["interval"] ?? 0
                
                let minFloat = Float(min)
                let maxFloat = Float(max)
                let intervalFloat = Float(interval)
                let valueFloat = Float(valueInt)
                                
                
                let alarmVolumeTitle = A4xBaseManager.shared.getLocalString(key: "alarm_volume").capitalized 
                let alarmVolumeContent = "\(valueInt)"
                var leftImage = ""
                if valueInt >= 50
                {
                    leftImage = "device_alarm_volume_loud"
                } else {
                    leftImage = "device_alarm_volume_low"
                }
                let rightImage = ""
                let alarmVolumeModel = tool.createBaseSliderModel(moduleType: .Slider, currentType: .AlarmRingVolume, title: alarmVolumeTitle, titleContent: alarmVolumeContent, leftImage: leftImage, rightImage: rightImage, sliderValue: valueFloat, scale: intervalFloat, minValue: minFloat, maxValue: maxFloat, isNormalSlider: true)
                models.append(alarmVolumeModel)
            }
        }
        
        let sortedArray = tool.sortModuleArray(moduleArray: models)
        return sortedArray
    }
    
    
    
    private func getVoiceCase() -> Array<A4xDeviceSettingModuleModel>
    {
        
        let tool = A4xDeviceSettingModuleTool()
        var models: Array<A4xDeviceSettingModuleModel> = []
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            if name == "voiceLanguage" {
                
                let deviceLanguageTitle = A4xBaseManager.shared.getLocalString(key: "device_language", param: [tempString]).capitalized
                let value = attrModel?.value
                let deviceLanguageValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                let deviceLanguageContentKey = tool.getModifiableAttributeTypeName(currentType: .DeviceLanguage) + "_options_" + (deviceLanguageValue)
                let deviceLanguageContent = A4xBaseManager.shared.getLocalString(key: deviceLanguageContentKey)
                let deviceLanguageModel = tool.createBaseArrowPointModel(moduleType: .ArrowPoint, currentType: .DeviceLanguage, title: deviceLanguageTitle, isInteractiveHidden: false)
                deviceLanguageModel.titleContent = deviceLanguageContent
                models.append(deviceLanguageModel)
            } else if name == "doorBellRing" {
                
                let doorbellRingTitle = A4xBaseManager.shared.getLocalString(key: "setting_db_tone").capitalized
                let value = attrModel?.value
                let doorbellRingValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? A4xDeviceSettingUnitModel ?? A4xDeviceSettingUnitModel()
                let doorbellRingContentKey = tool.getModifiableAttributeTypeName(currentType: .DoorbellRing) + "_options_" + (doorbellRingValue.unitId ?? "1")
                let doorbellRingContent = A4xBaseManager.shared.getLocalString(key: doorbellRingContentKey)
                let doorbellRingModel = tool.createBaseArrowPointModel(moduleType: .ArrowPoint, currentType: .DoorbellRing, title: doorbellRingTitle, isInteractiveHidden: false)
                doorbellRingModel.titleContent = doorbellRingContent
                models.append(doorbellRingModel)
            } else if name == "voiceVolume" {
                let value = attrModel?.value
                let valueInt = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Int ?? 0
                
                let intRange = attrModel?.intRange
                let min = intRange?["min"] ?? 0
                let max = intRange?["max"] ?? 0
                let interval = intRange?["interval"] ?? 0
                
                let minFloat = Float(min)
                let maxFloat = Float(max)
                let intervalFloat = Float(interval)
                let valueFloat = Float(valueInt)
                                
                
                let voiceVolumeTitle = A4xBaseManager.shared.getLocalString(key: "prompt_volume").capitalized
                let voiceVolumeContent = "\(valueInt)"
                var leftImage = ""
                if valueInt <= 0 {
                    leftImage = "device_speaker_volume_mute"
                } else if valueInt > 0 && valueInt <= 50 {
                    leftImage = "device_speaker_volume_low"
                } else {
                    leftImage = "device_speaker_volume_loud"
                }
                let rightImage = ""
                let voiceVolumeModel = tool.createBaseSliderModel(moduleType: .Slider, currentType: .VoiceVolume, title: voiceVolumeTitle, titleContent: voiceVolumeContent, leftImage: leftImage, rightImage: rightImage, sliderValue: valueFloat, scale: intervalFloat, minValue: minFloat, maxValue: maxFloat, isNormalSlider: true)
                models.append(voiceVolumeModel)
            }
        }
        
        
        let sortedArray = tool.sortModuleArray(moduleArray: models)
        return sortedArray
    }
    
    
    
    private func getAudioCase() -> Array<A4xDeviceSettingModuleModel>
    {
        
        let tool = A4xDeviceSettingModuleTool()
        var models: Array<A4xDeviceSettingModuleModel> = []
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            if name == "liveAudioSwitch" {
                
                let liveAudioTitle = A4xBaseManager.shared.getLocalString(key: "live_audio_recording_swt").capitalized
                let type = attrModel?.type ?? ""
                let value = attrModel?.value
                let liveAudioOpen = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                let liveAudioModel = tool.createBaseSwitchModel(moduleType: tool.getModuleType(type: type), currentType: .LiveAudio, title: liveAudioTitle, isSwitchOpen: liveAudioOpen, isSwitchLoading: false)
                models.append(liveAudioModel)
            } else if name == "recordingAudioSwitch" {
                
                let recordingAudioTitle = A4xBaseManager.shared.getLocalString(key: "video_audio_recording_swt").capitalized
                let type = attrModel?.type ?? ""
                let value = attrModel?.value
                let recordingAudioOpen = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                let recordingAudioModel = tool.createBaseSwitchModel(moduleType: tool.getModuleType(type: type), currentType: .RecordingAudio, title: recordingAudioTitle, isSwitchOpen: recordingAudioOpen, isSwitchLoading: false)
                models.append(recordingAudioModel)
            }
        }
        
        
        var sortedArray = tool.sortModuleArray(moduleArray: models)
        
        let lastModel = sortedArray.last
        
        if sortedArray.count > 0 {
            lastModel?.isShowContent = true
            lastModel?.content = A4xBaseManager.shared.getLocalString(key: "audio_recording_instr", param: [tempString])
            lastModel?.cellHeight = tool.getCellHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.moduleHeight = tool.getModuleHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.contentHeight = tool.getContentHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            sortedArray[sortedArray.count-1] = lastModel ?? A4xDeviceSettingModuleModel()
        }
        return sortedArray
    }
    
    
    private func getLiveSpeakerVolumeCase() -> Array<A4xDeviceSettingModuleModel>
    {
        
        let tool = A4xDeviceSettingModuleTool()
        var models: Array<A4xDeviceSettingModuleModel> = []
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            if name == "liveSpeakerVolume" {
                
                let value = attrModel?.value
                let valueInt = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Int ?? 0
                
                let intRange = attrModel?.intRange
                let min = intRange?["min"] ?? 0
                let max = intRange?["max"] ?? 0
                let interval = intRange?["interval"] ?? 0
                
                let minFloat = Float(min)
                let maxFloat = Float(max)
                let intervalFloat = Float(interval)
                let valueFloat = Float(valueInt)
                                
                
                let liveSpeakerVolumeTitle = A4xBaseManager.shared.getLocalString(key: "inter_volume").capitalized
                let liveSpeakerVolumeContent = "\(valueInt)"
                var leftImage = ""
                if valueInt <= 0 {
                    leftImage = "device_speaker_volume_mute"
                } else if valueInt > 0 && valueInt <= 50 {
                    leftImage = "device_speaker_volume_low"
                } else {
                    leftImage = "device_speaker_volume_loud"
                }
                let rightImage = ""
                let liveSpeakerVolumeModel = tool.createBaseSliderModel(moduleType: .Slider, currentType: .LiveSpeakerVolume, title: liveSpeakerVolumeTitle, titleContent: liveSpeakerVolumeContent, leftImage: leftImage, rightImage: rightImage, sliderValue: valueFloat, scale: intervalFloat, minValue: minFloat, maxValue: maxFloat, isNormalSlider: true)
                liveSpeakerVolumeModel.isShowContent = true
                liveSpeakerVolumeModel.content = A4xBaseManager.shared.getLocalString(key: "audio_recording_instr", param: [tempString])
                liveSpeakerVolumeModel.cellHeight = tool.getCellHeight(moduleModel: liveSpeakerVolumeModel)
                liveSpeakerVolumeModel.moduleHeight = tool.getModuleHeight(moduleModel: liveSpeakerVolumeModel)
                liveSpeakerVolumeModel.contentHeight = tool.getContentHeight(moduleModel: liveSpeakerVolumeModel)
                models.append(liveSpeakerVolumeModel)
            }
        }
        
        
        let sortedArray = tool.sortModuleArray(moduleArray: models)

        return sortedArray
    }
    
    
    //MARK: ----- 更新数据 -----
    
    @objc public func updateSwitch(currentType: A4xDeviceSettingCurrentType, enable: Bool, comple: @escaping (_ code: Int, _ message: String) -> Void) {
        
        
        var model = ModifiableAttributes()
        switch currentType {
        case .LiveAudio:
            model.name = "liveAudioSwitch"
        case .RecordingAudio:
            model.name = "recordingAudioSwitch"
        default:
            model.name = ""
        }
        let codableModel = ModifiableAnyAttribute()
        codableModel.value = enable
        model.value = codableModel
        let modifiableAttributes = [model]
        weak var weakSelf = self
        DeviceSettingCoreUtil.updateModifiableAttributes(deviceId: self.deviceModel?.serialNumber ?? "", modifiableAttributes: modifiableAttributes) { code, message in
            
            if code == 0 {
                
                comple(code, message)
            } else {
                
                //weakSelf?.updateLocalSwitchCase(currentType: currentType, isOpen: !enable, isLoading: false)
                comple(code, message)
            }
        }
        
    }
    
    
    @objc public func updateSlider(currentType: A4xDeviceSettingCurrentType, value: Int, comple: @escaping (_ code: Int, _ message: String) -> Void) {
        
        
        var model = ModifiableAttributes()
        switch currentType {
        case .AlarmRingVolume:
            model.name = "alarmVolume"
            break
        case .VoiceVolume:
            model.name = "voiceVolume"
            break
        case .LiveSpeakerVolume:
            
            model.name = "liveSpeakerVolume"
            break
        default:
            model.name = ""
            break
        }
        let codableModel = ModifiableAnyAttribute()
        codableModel.value = value
        model.value = codableModel
        let modifiableAttributes = [model]
        weak var weakSelf = self
        DeviceSettingCoreUtil.updateModifiableAttributes(deviceId: self.deviceModel?.serialNumber ?? "", modifiableAttributes: modifiableAttributes) { code, message in
            
            if code == 0 {
                
                comple(code, message)
            } else {
                
                //weakSelf?.updateLocalSwitchCase(currentType: currentType, isOpen: !enable, isLoading: false)
                comple(code, message)
            }
        }
        
    }
    
    @objc public func updateLocalSwitchCase(currentType: A4xDeviceSettingCurrentType, isOpen: Bool, isLoading: Bool) {
        var tempCases = self.allCases
        for i in 0..<(self.allCases?.count ?? 0) {
            let module = self.allCases?.getIndex(i)
            var tempModule = module
            for j in 0..<(module?.count ?? 0) {
                let model = module?.getIndex(j)
                let tempModel = model
                if currentType == model?.currentType {
                    tempModel?.isSwitchOpen = isOpen
                    tempModel?.isSwitchLoading = isLoading
                    tempModule?[j] = tempModel ?? A4xDeviceSettingModuleModel()
                    tempCases?[i] = tempModule ?? []
                }
            }
        }
        self.allCases = tempCases
    }
    
    //MARK: ----- 返回按钮点击事件 -----
    
    @objc public func backAndSendNotification() {
        
        let deviceAudioModel = self.getDeviceAudioModel()
        
        let userInfo = ["deviceId": self.deviceModel?.serialNumber ?? "", "deviceAudioModel": deviceAudioModel] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deviceSoundViewControllerReturn"), object: nil, userInfo: userInfo)
    }
    
    
    //MARK: ----- 返回按钮点击事件 -----
    
    public func getDeviceAudioModel() -> A4xDeviceAudioModel {
        var deviceAudioModel = A4xDeviceAudioModel()
        let tool = A4xDeviceSettingModuleTool()
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            if name == "voiceVolume" {
                let value = attrModel?.value
                let valueInt = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Int
                deviceAudioModel.liveSpeakerVolume = valueInt ?? 0
            } else if name == "liveAudioSwitch" {
                let value = attrModel?.value
                let liveAudioToggleOn = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool
                deviceAudioModel.liveAudioToggleOn = liveAudioToggleOn ?? false
            } else if name == "recordingAudioSwitch" {
                let value = attrModel?.value
                let recordingAudioToggleOn = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool
                deviceAudioModel.recordingAudioToggleOn = recordingAudioToggleOn ?? false
            } else if name == "doorBellRing" {
                
                let value = attrModel?.value
                let currentRing = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? A4xDeviceSettingUnitModel ?? A4xDeviceSettingUnitModel()
                let currentRingKey = Int(currentRing.unitId ?? "1")
                deviceAudioModel.doorBellRingKey = currentRingKey ?? 0
                
                
                let options = attrModel?.options
                let optionsArray = tool.getValueOrOption(anyCodable: options ?? ModifiableAnyAttribute()) as? [A4xDeviceSettingUnitModel]
                var supportDoorBellRingKeys = Array<A4xSupportDoorBellRingModel>()
                for i in 0..<(optionsArray?.count ?? 0) {
                    let objectModel = optionsArray?.getIndex(i)
                    var supportDoorBellRingModel = A4xSupportDoorBellRingModel()
                    supportDoorBellRingModel.ringId = Int(objectModel?.unitId ?? "1") ?? 0
                    supportDoorBellRingModel.url = objectModel?.url
                    supportDoorBellRingKeys.append(supportDoorBellRingModel)
                    
                }
                deviceAudioModel.supportDoorBellRingKey = supportDoorBellRingKeys
            }
        }
        return deviceAudioModel
    }
}
