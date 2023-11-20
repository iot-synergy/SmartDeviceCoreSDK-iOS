//


//


//

import UIKit
import SmartDeviceCoreSDK

class A4xDeviceSettingLightSettingViewModel: NSObject {
    
    
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
        
        let recLampModule = self.getRecLampCase()
        allModels.append(recLampModule)
        
        


        
        self.allCases = allModels
        
        return self.allCases ?? []
    }
    
    
    private func getRecLampCase() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var models: Array<A4xDeviceSettingModuleModel> = []
            
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            if name == "recLampSwitch" {
                
                let recLampTitle = A4xBaseManager.shared.getLocalString(key: "indicator")
                let value = attrModel?.value
                let recLampSwitchValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                let recLampModel = tool.createBaseSwitchModel(moduleType: .Switch, currentType: .RecLampSwitch, title: recLampTitle, isSwitchOpen: recLampSwitchValue, isSwitchLoading: false)
                recLampModel.isShowContent = true
                let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
                recLampModel.content = A4xBaseManager.shared.getLocalString(key: "indicator_des", param: [tempString])
                recLampModel.cellHeight = tool.getCellHeight(moduleModel: recLampModel)
                recLampModel.moduleHeight = tool.getModuleHeight(moduleModel: recLampModel)
                recLampModel.contentHeight = tool.getContentHeight(moduleModel: recLampModel)
                models.append(recLampModel)
            }
        }
        
        
        
        let sortedArray = tool.sortModuleArray(moduleArray: models)
        
        return sortedArray
    }
    
    
    private func getNightVisionCase() -> Array<A4xDeviceSettingModuleModel>
    {
        
        let tool = A4xDeviceSettingModuleTool()
        var models: Array<A4xDeviceSettingModuleModel> = []
            
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        var nightVisionValue = false
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            if name == "nightVisionSwitch" {
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "night_version")
                let value = attrModel?.value
                nightVisionValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                let nightVisionModel = tool.createBaseSwitchModel(moduleType: tool.getModuleType(type: type), currentType: .NightVisionSwitch, title: titleString, isSwitchOpen: nightVisionValue, isSwitchLoading: false)
                models.append(nightVisionModel)
            }
        }
        
        if nightVisionValue == true {
            
            for i in 0..<(modifiableAttributes?.count ?? 0) {
                let attrModel = modifiableAttributes?.getIndex(i)
                let name = attrModel?.name
                if name == "nightVisionMode" {
                    
                    let titleString = A4xBaseManager.shared.getLocalString(key: "config_night_mode")
                    let value = attrModel?.value
                    let nightVisionMode = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                    
                    let allCase = tool.getEnumCases(currentType: .NightVisionMode, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                    let nightVisionModeContentKey = tool.getModifiableAttributeTypeName(currentType: .NightVisionMode) + "_options_" + (nightVisionMode)
                    let nightVisionModeModel = tool.createBaseEnumModel(moduleType: .Enumeration, currentType: .NightVisionMode, title: titleString, titleContent: A4xBaseManager.shared.getLocalString(key: nightVisionModeContentKey), enumDataSource: allCase)
                    if allCase.count > 0 {
                        
                        models.append(nightVisionModeModel)
                    }
                    
                } else if name == "nightVisionSensitivity" {
                    
                    let titleString = A4xBaseManager.shared.getLocalString(key: "sensitivity_level")
                    let value = attrModel?.value
                    let nightVisionSensitivity = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                    
                    let allCase = tool.getEnumCases(currentType: .NightVisionSensitivity, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                    let nightVisionSensitivityContentKey = tool.getModifiableAttributeTypeName(currentType: .NightVisionMode) + "_options_" + (nightVisionSensitivity)
                    let nightVisionSensitivityModel = tool.createBaseEnumModel(moduleType: .Enumeration, currentType: .NightVisionSensitivity, title: titleString, titleContent: A4xBaseManager.shared.getLocalString(key: nightVisionSensitivityContentKey), enumDataSource: allCase)
                    if allCase.count > 0 {
                        
                        models.append(nightVisionSensitivityModel)
                    }
                }
            }
        }
        
        
        var sortedArray = tool.sortModuleArray(moduleArray: models)
        
        if sortedArray.count > 0 {
            let lastModel = sortedArray.last
            lastModel?.isShowContent = true
            let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
            lastModel?.content = A4xBaseManager.shared.getLocalString(key: "night_version_tips", param: [tempString])
            lastModel?.cellHeight = tool.getCellHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.moduleHeight = tool.getModuleHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.contentHeight = tool.getContentHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            sortedArray[sortedArray.count-1] = lastModel ?? A4xDeviceSettingModuleModel()
        }
        return sortedArray
    }
    
    //MARK: ----- 更新数据 -----
    
    @objc public func updateSwitch(currentType: A4xDeviceSettingCurrentType, enable: Bool, comple: @escaping (_ code: Int, _ message: String) -> Void) {
        
        var model = ModifiableAttributes()
        switch currentType {
        case .RecLampSwitch:
            model.name = "recLampSwitch"
            break
        case .NightVisionSwitch:
            model.name = "nightVisionSwitch"
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
        case .NightVisionMode:
            model.name = "nightVisionMode"
            break
        case .NightVisionSensitivity:
            model.name = "nightVisionSensitivity"
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
    
}
