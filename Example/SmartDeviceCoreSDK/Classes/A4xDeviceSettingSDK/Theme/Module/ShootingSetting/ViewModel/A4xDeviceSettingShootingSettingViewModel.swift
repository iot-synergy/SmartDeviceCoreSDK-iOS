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
    
    //MARK: ----- AP模式数据 -----
    public func getApAllCases()
    {
        var allModels : Array<Array<A4xDeviceSettingModuleModel>> = []
        // 运动触发警报模块
        let apShootingModule = self.getAPShootingCase()
        allModels.append(apShootingModule)
        
        self.allCases = allModels
    }
    
    // 报警铃声
    private func getAPShootingCase() -> Array<A4xDeviceSettingModuleModel>
    {
        // 运动触发报警模块相关
        let tool = A4xDeviceSettingModuleTool()
        var apMotionModule: Array<A4xDeviceSettingModuleModel> = []
            
        var cooldownSwitchValue = false
        
        if self.deviceModel?.cooldown?.userEnable != nil {
            if self.deviceModel?.cooldown?.userEnable == true {
                cooldownSwitchValue = true
            } else {
                cooldownSwitchValue = false
            }
        }
        
        // 拍摄间隔 pirCooldownSwitch
        let cooldownSwitchTitleString = A4xBaseManager.shared.getLocalString(key: "shooting_interval").capitalized

        let pirCooldownModel = tool.createBaseSwitchModel(moduleType: tool.getModuleType(type: "SWITCH"), currentType: .PirCooldownSwitch, title: cooldownSwitchTitleString, isSwitchOpen: cooldownSwitchValue, isSwitchLoading: false)
        apMotionModule.append(pirCooldownModel)
        
        
        if cooldownSwitchValue == true {
            // 运动检测和拍摄间隔开关都开启的话,展示拍摄间隔时长枚举
            // 拍摄间隔时长 pirCooldownSwitch
            let intervalTimeTitleString = A4xBaseManager.shared.getLocalString(key: "interval_time")
            let value = self.deviceModel?.cooldown?.value ?? 30
            // 当前展示的时间
            let pirCooldownTimeValue = self.getApModeStringValue(currentType: .PirCooldownTime, value: value)
            let pirCooldownTimeContentKey = tool.getModifiableAttributeTypeName(currentType: .PirCooldownTime) + "_options_" + (pirCooldownTimeValue)
            
            var pirCooldownTimeEnumData: Array<A4xDeviceSettingEnumAlertModel> = []
            for i in 0..<(self.deviceModel?.cooldown?.notCloseValues?.count ?? 0) {
                let cooldownTime_Int = self.deviceModel?.cooldown?.notCloseValues?.getIndex(i) ?? 10
                let cooldownTimeEnumModel = A4xDeviceSettingEnumAlertModel()
                var cooldownTimeValue = self.getApModeStringValue(currentType: .PirCooldownTime, value: cooldownTime_Int)
                let cooldownContentKey = tool.getModifiableAttributeTypeName(currentType: .PirCooldownTime) + "_options_" + (cooldownTimeValue)
                cooldownTimeEnumModel.content = A4xBaseManager.shared.getLocalString(key: cooldownContentKey)
                cooldownTimeEnumModel.isEnable = true
                if cooldownTime_Int == -1 {
                    cooldownTimeEnumModel.requestContent = "auto"
                } else {
                    cooldownTimeEnumModel.requestContent = "\(cooldownTime_Int)"
                }
                
                pirCooldownTimeEnumData.append(cooldownTimeEnumModel)
                
            }
            let pirCooldownTimeModel = tool.createBaseEnumModel(moduleType: tool.getModuleType(type: "ENUM"), currentType: .PirCooldownTime, title: intervalTimeTitleString, titleContent: A4xBaseManager.shared.getLocalString(key: pirCooldownTimeContentKey), enumDataSource: pirCooldownTimeEnumData)
            apMotionModule.append(pirCooldownTimeModel)
            
        }
        return apMotionModule
    }
    
   
    
    
    //MARK: ----- 更新数据 -----
    // 更新开关(AP和WIFI模式通用,内部已经处理)
    @objc public func updateSwitch(currentType: A4xDeviceSettingCurrentType, enable: Bool, comple: @escaping (_ code: Int, _ message: String) -> Void) {
        
        // 再处理数据
        if self.deviceModel?.apModeType == .AP {
            let attribute = ApDeviceAttributeModel()
            switch currentType {
            case .PirCooldownSwitch:
                // 拍摄间隔开关
                self.deviceModel?.cooldown?.userEnable = enable
                attribute.name = "coolDownEnable"
                attribute.value = enable
                break
            default:
                break
            }
            weak var weakSelf = self
            let attributeArray : Array<ApDeviceAttributeModel> = [attribute]
            DeviceSettingCore.getInstance().updateApDeviceInfo(serialNumber: self.deviceModel?.serialNumber ?? "", attributes: attributeArray) { code, message in
                A4xUserDataHandle.Handle?.updateDevice(device: weakSelf?.deviceModel)
                // 成功之后更新数据
                weakSelf?.getApAllCases()
                //weakSelf?.tableView.reloadData()
                comple(code, message)
            } onError: { code, message in
                comple(code, A4xBaseManager.shared.getLocalString(key: "open_fail_retry"))
            }
        } else {
            
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
                NSLog("拿到的model 更新结果: \(code)")
                if code == 0 {
                    // 重新获取数据
                    comple(code, message)
                } else {
                    // 解决网络请求失败导致的一直Loading的BUG,除非退出页面
                    //weakSelf?.updateLocalSwitchCase(currentType: currentType, isOpen: !enable, isLoading: false)
                    comple(code, message)
                }
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
    
    //MARK: ----- AP模式下的数据处理 -----
    // 获取Ap模式下的解析的数据源 String
    private func getApModeStringValue(currentType: A4xDeviceSettingCurrentType ,value: Int) -> String {
        var modeValue = ""
        switch currentType {
        case .PirCooldownTime:
            // 拍摄间隔
            if value == -1 {
                modeValue = "auto"
            } else {
                modeValue = "\(value)s"
            }
            return modeValue
        default:
            return ""
        }
    }
    
    // 获取Ap模式下的上传的数据源 Int
    private func getApModeRequestEnumValue(currentType: A4xDeviceSettingCurrentType ,value: String) -> Int {
        var modeValue = 0
        switch currentType {
        case .PirCooldownTime:
            // 拍摄间隔
            // 视频时长
            if value == "auto" {
                modeValue = -1
            } else {
                modeValue = value.intValue()
            }
            return modeValue
        default:
            return 0
        }
    }
    
    // 更新枚举值
    @objc public func updateEnumValue(currentType: A4xDeviceSettingCurrentType, value: String, comple: @escaping (_ code: Int, _ message: String) -> Void) {
        if self.deviceModel?.apModeType == .AP {
            let attribute = ApDeviceAttributeModel()
            switch currentType {
            case .PirCooldownTime:
                self.deviceModel?.cooldown?.value = self.getApModeRequestEnumValue(currentType: currentType, value: value)
                attribute.name = "coolDownCurrentValue"
                attribute.value = self.getApModeRequestEnumValue(currentType: currentType, value: value)
                break
            default:
                break
            }
            weak var weakSelf = self
            let attributeArray : Array<ApDeviceAttributeModel> = [attribute]
            DeviceSettingCore.getInstance().updateApDeviceInfo(serialNumber: self.deviceModel?.serialNumber ?? "", attributes: attributeArray) { code, message in
                A4xUserDataHandle.Handle?.updateDevice(device: weakSelf?.deviceModel)
                // 成功之后更新数据
                weakSelf?.getApAllCases()
                comple(code, message)
            } onError: { code, message in
                comple(code, message)
            }
            
            
        } else {
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
                NSLog("拿到的model 更新结果: \(code)")
                if code == 0 {
                    // 重新获取数据
                    comple(code, message)
                } else {
                    // 解决网络请求失败导致的一直Loading的BUG,除非退出页面
                    //weakSelf?.updateLocalSwitchCase(currentType: currentType, isOpen: !enable, isLoading: false)
                    comple(code, message)
                }
            }
        }
        
    }
}
