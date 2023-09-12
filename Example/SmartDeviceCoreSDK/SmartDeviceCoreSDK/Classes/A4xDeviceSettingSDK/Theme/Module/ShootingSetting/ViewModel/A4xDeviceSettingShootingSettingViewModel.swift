//


//

//

import UIKit
import SmartDeviceCoreSDK

class A4xDeviceSettingShootingSettingViewModel: NSObject {

    
    public var deviceModel : DeviceBean?
    
    
    public var deviceAttributeModel : DeviceAttributesBean? = DeviceAttributesBean()
    
    
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
        
        let shootingModule = self.getShootingCase()
        if shootingModule.count > 0 {
            allModels.append(shootingModule)
        }
        
        
        let sdVideoModule = self.getSDVideoCase()
        if sdVideoModule.count > 0 {
            allModels.append(sdVideoModule)
        }
        
        
        self.allCases = allModels
        
        return self.allCases ?? []
    }
    
    
    private func getShootingCase() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var shootingModule : Array<A4xDeviceSettingModuleModel> = []
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        
        var isCooldownOpen = false
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            
            if name == "pirCooldownSwitch" {
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "shooting_interval").capitalized
                let value = attrModel?.value
                
                let cooldownValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                isCooldownOpen = cooldownValue
                let pirCooldownModel = tool.createBaseSwitchModel(moduleType: tool.getModuleType(type: type), currentType: .PirCooldownSwitch, title: titleString, isSwitchOpen: cooldownValue, isSwitchLoading: false)
                let disabled = attrModel?.disabled
                if disabled != true {
                    shootingModule.append(pirCooldownModel)
                }
            }
                
        }
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            if name == "pirCooldownTime" {
                if isCooldownOpen == true {
                    
                    let titleString = A4xBaseManager.shared.getLocalString(key: "interval_time")
                    let value = attrModel?.value
                    let allCase = tool.getEnumCases(currentType: .PirCooldownTime, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                    let pirCooldownTimeValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                    let pirCooldownTimeContentKey = tool.getModifiableAttributeTypeName(currentType: .PirCooldownTime) + "_options_" + (pirCooldownTimeValue)
                    let pirCooldownTimeModel = tool.createBaseEnumModel(moduleType: tool.getModuleType(type: type), currentType: .PirCooldownTime, title: titleString, titleContent: A4xBaseManager.shared.getLocalString(key: pirCooldownTimeContentKey), enumDataSource: allCase)
                    if allCase.count > 0 {
                        
                        shootingModule.append(pirCooldownTimeModel)
                    }
                }
            }
        }
        
        let sortedMotionModule = tool.sortModuleArray(moduleArray: shootingModule)
        return sortedMotionModule
    }
    
    
    private func getSDVideoCase() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var sdModule : Array<A4xDeviceSettingModuleModel> = []
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        
        var isSDOpen = false
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            
            if name == "sdCardVideoModes" {
                
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "sdCardVideoModes")
                let value = attrModel?.value
                let allCase = tool.getEnumCases(currentType: .SDCardVideoModes, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                let pirCooldownTimeValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                let pirCooldownTimeContentKey = tool.getModifiableAttributeTypeName(currentType: .SDCardVideoModes) + "_options_" + (pirCooldownTimeValue)
                let pirCooldownTimeModel = tool.createBaseEnumModel(moduleType: tool.getModuleType(type: type), currentType: .SDCardVideoModes, title: titleString, titleContent: A4xBaseManager.shared.getLocalString(key: pirCooldownTimeContentKey), enumDataSource: allCase)
                if allCase.count > 0 {
                    
                    sdModule.append(pirCooldownTimeModel)
                }
                
            } else if name == "sdCardCooldownSwitch" {
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "shooting_interval_sd")
                let value = attrModel?.value
                isSDOpen = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                
                let sdVideoValue = isSDOpen
                let sdSwitchModel = tool.createBaseSwitchModel(moduleType: tool.getModuleType(type: type), currentType: .SDCardCooldownSwitch, title: titleString, isSwitchOpen: sdVideoValue, isSwitchLoading: false)
                let disabled = attrModel?.disabled
                if disabled != true {
                    sdModule.append(sdSwitchModel)
                }
            }
        }
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            
            if name == "sdCardCooldownSeconds" {
                if isSDOpen == true {
                    
                    let titleString = A4xBaseManager.shared.getLocalString(key: "interval_time_sd")
                    let value = attrModel?.value
                    let allCase = tool.getEnumCases(currentType: .SDCardCooldownSeconds, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                    let pirCooldownTimeValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                    let pirCooldownTimeContentKey = tool.getModifiableAttributeTypeName(currentType: .SDCardCooldownSeconds) + "_options_" + (pirCooldownTimeValue)
                    let pirCooldownTimeModel = tool.createBaseEnumModel(moduleType: tool.getModuleType(type: type), currentType: .SDCardCooldownSeconds, title: titleString, titleContent: A4xBaseManager.shared.getLocalString(key: pirCooldownTimeContentKey), enumDataSource: allCase)
                    if allCase.count > 0 {
                        
                        sdModule.append(pirCooldownTimeModel)
                    }
                }
            }
        }
        
        let sortedMotionModule = tool.sortModuleArray(moduleArray: sdModule)
        return sortedMotionModule
    }
    
    //MARK: ----- 更新数据 -----
    
    @objc public func updateSwitch(currentType: A4xDeviceSettingCurrentType, enable: Bool, comple: @escaping (_ code: Int, _ message: String) -> Void) {
        
        
        var model = ModifiableAttributes()
        switch currentType {
        case .PirCooldownSwitch:
            model.name = "pirCooldownSwitch"
            break
        case .SDCardCooldownSwitch:
            model.name = "sdCardCooldownSwitch"
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
        case .PirCooldownTime:
            model.name = "pirCooldownTime"
        case .SDCardVideoModes:
            model.name = "sdCardVideoModes"
        case .SDCardCooldownSeconds:
            model.name = "sdCardCooldownSeconds"
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
