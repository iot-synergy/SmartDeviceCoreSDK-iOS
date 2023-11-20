//


//


//

import UIKit
import SmartDeviceCoreSDK
import Resolver

class A4xDeviceSettingAlarmSettingViewModel: NSObject {

    
    @objc public static let shared = A4xDeviceSettingAlarmSettingViewModel()
    
    
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
        
        let motionAlarmModule = self.getMotionAlarmCase()
        if motionAlarmModule.count > 0 {
            allModels.append(motionAlarmModule)
        }
        
        
        let antiDisassemblyAlarmModule = self.getAntiDisassemblyAlarmCase()
        if antiDisassemblyAlarmModule.count > 0 {
            allModels.append(antiDisassemblyAlarmModule)
        }
        
        
        let alarmFlashLightModule = self.getAlarmFlashLightCase()
        if alarmFlashLightModule.count > 0 {
            allModels.append(alarmFlashLightModule)
        }
        
        self.allCases = allModels
        
        return self.allCases ?? []
    }
    
    
    private func getMotionAlarmCase() -> Array<A4xDeviceSettingModuleModel>
    {
        
        let tool = A4xDeviceSettingModuleTool()
        var models: Array<A4xDeviceSettingModuleModel> = []
            
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        //motionAlertSwitch
        var motionAlertSwitchOpen = false
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            if name == "motionAlertSwitch" {
                
                let alarmRingTitle = A4xBaseManager.shared.getLocalString(key: "alert_buttom")
                let value = attrModel?.value
                motionAlertSwitchOpen = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                let alarmRingModel = tool.createBaseSwitchModel(moduleType: .Switch, currentType: .MotionAlertSwitch, title: alarmRingTitle, isSwitchOpen: motionAlertSwitchOpen, isSwitchLoading: false)
                models.append(alarmRingModel)
            }
        }
        
        if motionAlertSwitchOpen == true {
            for i in 0..<(modifiableAttributes?.count ?? 0) {
                let attrModel = modifiableAttributes?.getIndex(i)
                let name = attrModel?.name
                let type = attrModel?.type ?? ""
                if name == "alarmDuration" {
                    
                    let alarmDurationTitle = A4xBaseManager.shared.getLocalString(key: "duration_alarm")
                    let value = attrModel?.value
                    let alarmDurationValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                    
                    let allCase = tool.getEnumCases(currentType: .AlarmDuration, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                    let alarmDurationContentKey = tool.getModifiableAttributeTypeName(currentType: .AlarmDuration) + "_options_" + (alarmDurationValue)
                    let alarmDurationModel = tool.createBaseEnumModel(moduleType: .Enumeration, currentType: .AlarmDuration, title: alarmDurationTitle, titleContent: A4xBaseManager.shared.getLocalString(key: alarmDurationContentKey), enumDataSource: allCase)
                    if allCase.count > 0 {
                        
                        models.append(alarmDurationModel)
                    }
                }
            }
        }
        
        var sortedArray = tool.sortModuleArray(moduleArray: models)
        
        if sortedArray.count > 0 {
            let lastModel = sortedArray.last
            lastModel?.isShowContent = true
            let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
            lastModel?.content = A4xBaseManager.shared.getLocalString(key: "siren_des", param: [tempString])
            lastModel?.cellHeight = tool.getCellHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.moduleHeight = tool.getModuleHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.contentHeight = tool.getContentHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            sortedArray[sortedArray.count-1] = lastModel ?? A4xDeviceSettingModuleModel()
        }
        return sortedArray
    }
    
    
    private func getAntiDisassemblyAlarmCase() -> Array<A4xDeviceSettingModuleModel>
    {
        
        let tool = A4xDeviceSettingModuleTool()
        var models: Array<A4xDeviceSettingModuleModel> = []
            
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            if name == "antiDisassemblyAlarmSwitch" {
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "setting_db_remove")
                let value = attrModel?.value
                let antiDisassemblyAlarmValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                let antiDisassemblyAlarmModel = tool.createBaseSwitchModel(moduleType: tool.getModuleType(type: type), currentType: .AntiDisassemblyAlarm, title: titleString, isSwitchOpen: antiDisassemblyAlarmValue, isSwitchLoading: false)
                antiDisassemblyAlarmModel.isShowContent = true
                let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
                if antiDisassemblyAlarmValue == false {
                    antiDisassemblyAlarmModel.content = A4xBaseManager.shared.getLocalString(key: "setting_db_remove_off")
                } else {
                    antiDisassemblyAlarmModel.content = A4xBaseManager.shared.getLocalString(key: "setting_db_remove_on")
                }
                antiDisassemblyAlarmModel.cellHeight = tool.getCellHeight(moduleModel: antiDisassemblyAlarmModel)
                antiDisassemblyAlarmModel.moduleHeight = tool.getModuleHeight(moduleModel: antiDisassemblyAlarmModel)
                antiDisassemblyAlarmModel.contentHeight = tool.getContentHeight(moduleModel: antiDisassemblyAlarmModel)
                
                models.append(antiDisassemblyAlarmModel)
            }
        }
        
        let sortedArray = tool.sortModuleArray(moduleArray: models)
        return sortedArray
    }
    
    
    
    
    private func getAlarmFlashLightCase() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var models: Array<A4xDeviceSettingModuleModel> = []
            
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            if name == "alarmFlashLightSwitch" {
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "flash_light_item")
                let value = attrModel?.value
                let alarmFlashLightValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                let alarmFlashLightModel = tool.createBaseSwitchModel(moduleType: tool.getModuleType(type: type), currentType: .AlarmFlashSwitch, title: titleString, isSwitchOpen: alarmFlashLightValue, isSwitchLoading: false)
                alarmFlashLightModel.isShowContent = true
                let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
                alarmFlashLightModel.content = A4xBaseManager.shared.getLocalString(key: "camera_white_tips", param: [tempString])
                alarmFlashLightModel.cellHeight = tool.getCellHeight(moduleModel: alarmFlashLightModel)
                alarmFlashLightModel.moduleHeight = tool.getModuleHeight(moduleModel: alarmFlashLightModel)
                alarmFlashLightModel.contentHeight = tool.getContentHeight(moduleModel: alarmFlashLightModel)
                models.append(alarmFlashLightModel)
            }
        }
            
        
        let sortedArray = tool.sortModuleArray(moduleArray: models)
        return sortedArray
    }
    
    //MARK: ----- 更新数据 -----
    
    @objc public func updateSwitch(currentType: A4xDeviceSettingCurrentType, enable: Bool, comple: @escaping (_ code: Int, _ message: String) -> Void) {
        
        var model = ModifiableAttributes()
        switch currentType {
        case .MotionAlertSwitch:
            model.name = "motionAlertSwitch"
            break
        case .AntiDisassemblyAlarm:
            model.name = "antiDisassemblyAlarmSwitch"
            break
        case .AlarmFlashSwitch:
            model.name = "alarmFlashLightSwitch"
            break
        default:
            model.name = ""
            break
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
    
    
    @objc public func updateEnumValue(currentType: A4xDeviceSettingCurrentType, value: String, comple: @escaping (_ code: Int, _ message: String) -> Void) {
        var model = ModifiableAttributes()
        switch currentType {
        case .AlarmDuration:
            model.name = "alarmDuration"
        default:
            model.name = ""
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

}
