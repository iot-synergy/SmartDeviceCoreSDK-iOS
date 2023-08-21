//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI


@objc public enum A4xDeviceStarLightBitOperationStatus : Int {
    case NoWhite_NoStarLight_NoOpenNightVisionMode = 0 
    case NoWhite_NoStarLight_OpenNightVisionMode   = 1 
    case NoWhite_StarLight_NoOpenNightVisionMode   = 2 
    case NoWhite_StarLight_OpenNightVisionMode     = 3 
    case White_NoStarLight_NoOpenNightVisionMode   = 4 
    case White_NoStarLight_OpenNightVisionMode     = 5 
    case White_StarLight_NoOpenNightVisionMode     = 6 
    case White_StarLight_OpenNightVisionMode       = 7 
}

class A4xDeviceSettingVideoSettingViewController: A4xBaseViewController, A4xDeviceSettingModuleTableViewCellDelegate, A4xDeviceSettingEnumAlertViewDelegate {
        
    //MARK: ----- 属性 -----
    
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
    var deviceModel: DeviceBean?
    
    public var deviceAttributeModel : DeviceAttributesBean?
    
    
    var tableViewPresenter : A4xDeviceSettingTableViewPresenter?
    
    
    var isNetworking : Bool = false
    
    //MARK: ----- UI组件 -----
    lazy private var tableView: UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped);
        temp.backgroundColor = UIColor.clear
        //temp.sectionHeaderHeight = A4xDeviceSettingModuleCellTopPadding
        temp.separatorInset = UIEdgeInsets.zero
        temp.separatorColor = UIColor.clear
        temp.separatorStyle = .none
        temp.accessibilityIdentifier = "A4xDeviceSettingPushSettingViewController_tableView"
        self.tableViewPresenter = A4xDeviceSettingTableViewPresenter()
        self.tableViewPresenter?.delegate = self
        temp.delegate = self.tableViewPresenter
        temp.dataSource = self.tableViewPresenter
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom)
            make.left.width.equalTo(self.view)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        
        return temp
    }()
    
    //MARK: ----- 系统方法 -----
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadNavtion()
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "video_settings").capitalized
        self.tableView.isHidden = false
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.getDeviceInfoFromNetwork()
        
    }
    //MARK: ----- UI相关 -----
    
    private func loadNavtion() {
        weak var weakSelf = self
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
        
        
        
        
        
        
        
        
        
    }
    
    //MARK: ----- Wifi模式 -----
    //MARK: ----- 通过网络请求获取数据 -----
    private func getDeviceInfoFromNetwork()
    {
        weak var weakSelf = self
        
        DispatchQueue.main.async {
            weakSelf?.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        }
        
        queue.async(group: group, execute: {
            weakSelf?.group.enter()
            weakSelf?.loadAttributesData(withGroup: true)
        })

        group.notify(queue: queue) {
            
            DispatchQueue.main.async {
                
                weakSelf?.view.hideToastActivity {
                    weakSelf?.tableView.reloadData()
                }
                
            }
        }
    }
    
    
    
    private func loadAttributesData(withGroup: Bool) {
        weak var weakSelf = self
        DeviceSettingCoreUtil.getDeviceAttributes(deviceId: self.deviceModel?.serialNumber ?? "") { code, model, message in
            if withGroup == true {
                weakSelf?.group.leave()
            }
            if code == 0 {
                weakSelf?.deviceAttributeModel = model
                weakSelf?.getAllCases()
                weakSelf?.tableView.reloadData()
            } else {
                
            }
        }
    }
    
    
    private func getAllCases()
    {
        
        var allModels : Array<Array<A4xDeviceSettingModuleModel>> = []
        
        
        let videoRecordModule = self.getVideoRecordCase()
        if videoRecordModule.count > 0
        {
            allModels.append(videoRecordModule)
        }
        
        let antiFlickerModule = self.getAntiFlickerCase()
        if antiFlickerModule.count > 0
        {
            allModels.append(antiFlickerModule)
        }
        
        let starlightModule = self.getStarlightSensorCase()
        if starlightModule.count > 0
        {
            allModels.append(starlightModule)
        }
        
        
        let linkageModule = self.getLinkageCase()
        if linkageModule.count > 0
        {
            allModels.append(linkageModule)
        }
        
        self.tableViewPresenter?.allCases = allModels
    }
    
    
    private func getVideoRecordCase() -> Array<A4xDeviceSettingModuleModel>
    {
        
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes

        let tool = A4xDeviceSettingModuleTool()
        
        var models: Array<A4xDeviceSettingModuleModel> = []
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            if name == "videoResolution" {
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "video_resolution")
                let value = attrModel?.value
                let videoResolutionValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                
                let allCase = tool.getEnumCases(currentType: .VideoResolution, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                let videoResolutionContentKey = tool.getModifiableAttributeTypeName(currentType: .VideoResolution) + "_options_" + (videoResolutionValue)
                let videoResolutionModel = tool.createBaseEnumModel(moduleType: tool.getModuleType(type: type), currentType: .VideoResolution, title: titleString, titleContent: A4xBaseManager.shared.getLocalString(key: videoResolutionContentKey), enumDataSource: allCase)
                if allCase.count > 0 {
                    
                    models.append(videoResolutionModel)
                }
            }

            else if name == ""{
                
            }
            
            else if name == "videoFlipSwitch" {
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "rotate_image").capitalized
                let value = attrModel?.value
                let videoFlipModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .videoFlipEntrance, title: titleString, titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                models.append(videoFlipModel)
            }
        }
        
        let sortedArray = tool.sortModuleArray(moduleArray: models)
        return sortedArray
    }
    
    
    private func getAntiFlickerCase() -> Array<A4xDeviceSettingModuleModel>
    {
        
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        let tool = A4xDeviceSettingModuleTool()
        
        var models: Array<A4xDeviceSettingModuleModel> = []
        var antiFlickerValue = false
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            if name == "videoAntiFlickerSwitch" {
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "anti_flicker")
                let value = attrModel?.value
                antiFlickerValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                let antiFlickerModel = tool.createBaseSwitchModel(moduleType: tool.getModuleType(type: type), currentType: .antiFlickerSwitch, title: titleString, isSwitchOpen: antiFlickerValue, isSwitchLoading: false)
                let disabled = attrModel?.disabled
                if disabled != true {
                    models.append(antiFlickerModel)
                }
            }
        }
        
        if antiFlickerValue == true {
            for i in 0..<(modifiableAttributes?.count ?? 0) {
                let attrModel = modifiableAttributes?.getIndex(i)
                let name = attrModel?.name
                let type = attrModel?.type ?? ""
                if name == "videoAntiFlickerFrequency" {
                    
                    let titleString = A4xBaseManager.shared.getLocalString(key: "flicker_rate")
                    let value = attrModel?.value
                    let antiFlickerFrequencyValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                    
                    let allCase = tool.getEnumCases(currentType: .AntiFlickerFrequency, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                    let antiFlickerFrequencyContentKey = tool.getModifiableAttributeTypeName(currentType: .AntiFlickerFrequency) + "_options_" + (antiFlickerFrequencyValue)
                    let antiFlickerFrequencyModel = tool.createBaseEnumModel(moduleType: tool.getModuleType(type: type), currentType: .AntiFlickerFrequency, title: titleString, titleContent: A4xBaseManager.shared.getLocalString(key: antiFlickerFrequencyContentKey), enumDataSource: allCase)
                    if allCase.count > 0 {
                        
                        models.append(antiFlickerFrequencyModel)
                    }
                }
            }
            
        }
        
        var sortedArray = tool.sortModuleArray(moduleArray: models)
        
        if sortedArray.count > 0 {
            let lastModel = sortedArray.last
            lastModel?.isShowContent = true
            let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
            lastModel?.content = A4xBaseManager.shared.getLocalString(key: "anti_flicker_tips", param: [tempString])
            lastModel?.cellHeight = tool.getCellHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.moduleHeight = tool.getModuleHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.contentHeight = tool.getContentHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            sortedArray[sortedArray.count-1] = lastModel ?? A4xDeviceSettingModuleModel()
        }
        return sortedArray
    }
    
    
    
    
    private func getStarlightSensorCase() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var models: Array<A4xDeviceSettingModuleModel> = []
        
        var starLightModel = A4xDeviceSettingModuleModel()
        
        var autoNightVisionModel = A4xDeviceSettingModuleModel()
        
        var blackWhiteModel = A4xDeviceSettingModuleModel()
        
        var colorModel = A4xDeviceSettingModuleModel()
        
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        let fixedAttributes = self.deviceAttributeModel?.fixedAttributes
        
        let deviceType = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: fixedAttributes?.modelCategory ?? 0)
        
        
        let supportWhiteLight = fixedAttributes?.supportWhiteLight ?? false

        
        let supportWhiteLight_Int = supportWhiteLight.toInt() << 2
        
        
        
        let supportStarlightSensor = fixedAttributes?.supportStarlightSensor ?? false

        
        let supportStarlightSensor_Int = supportStarlightSensor.toInt() << 1
                
        
        let starLightTitle = A4xBaseManager.shared.getLocalString(key: "starlight_sensor_title")
        let autoNightTitle = A4xBaseManager.shared.getLocalString(key: "night_version")
        let blackWhiteTitle = A4xBaseManager.shared.getLocalString(key: "night_vision_white_black_title")
        let blackWhiteDes = A4xBaseManager.shared.getLocalString(key: "night_vision_white_black_descr")
        let colorModeTitle = A4xBaseManager.shared.getLocalString(key: "night_vision_color_title")
        let colorModeDes = A4xBaseManager.shared.getLocalString(key: "night_vision_color_descr")
        
        if supportStarlightSensor == true {
            
            starLightModel = tool.createBaseInformationModel(moduleType: .InformationBar, currentType: .StarlightSensor, title: starLightTitle, leftImage: "device_set_starlight_icon", rightImage: "device_set_information_icon")
            models.append(starLightModel)
        }
        
        
        var nightVisionSwitch = true
        var nightVisionSwitch_Int = 0
        
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            if name == "nightVisionSwitch" {
                
                
                let value = attrModel?.value
                nightVisionSwitch = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                autoNightVisionModel = tool.createBaseSwitchModel(moduleType: .Switch, currentType: .AutoNightVisionSwitch, title: autoNightTitle, isSwitchOpen: nightVisionSwitch, isSwitchLoading: false)
                models.append(autoNightVisionModel)
                nightVisionSwitch_Int = nightVisionSwitch.toInt()
            }
        }
        
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            if name == "nightVisionMode" {
                if nightVisionSwitch == true {
                    
                    let value = attrModel?.value
                    let nightVisionMode = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                    let options = attrModel?.options
                    let optionsArray = tool.getValueOrOption(anyCodable: options ?? ModifiableAnyAttribute()) as? [String]
                    if (optionsArray?.count ?? 0) > 1 {
                        for i in 0..<(optionsArray?.count ?? 0) {
                            nightVisionSwitch_Int = supportWhiteLight.toInt()
                            let optionString = optionsArray?.getIndex(i)
                            if optionString == "white" {
                                
                                colorModel = tool.createBaseMultiTextSelectionBoxModel(moduleType: .MultiTextSelectionBox, currentType: .StarlightColor, title: colorModeTitle, titleDescription: colorModeDes, isShowTitleDescription: true)
                                models.append(colorModel)
                            } else if optionString == "infrared" {
                                blackWhiteModel = tool.createBaseMultiTextSelectionBoxModel(moduleType: .MultiTextSelectionBox, currentType: .StarlightWhiteBlack, title: blackWhiteTitle, titleDescription: blackWhiteDes, isShowTitleDescription: true)
                                blackWhiteModel.isShowSeparator = true
                                models.append(blackWhiteModel)
                            }
                        }
                    }
                    
                    if nightVisionMode == "white" {
                        colorModel.isSelected = true
                    } else if nightVisionMode == "infrared" {
                        blackWhiteModel.isSelected = true
                    }
                }
            }
        }
        
        let result = supportWhiteLight_Int + supportStarlightSensor_Int + nightVisionSwitch_Int
        let status = A4xDeviceStarLightBitOperationStatus(rawValue: result)

        
        
        var bottomContent = ""
        
        switch status {
        case .NoWhite_NoStarLight_NoOpenNightVisionMode:
            
            fallthrough
        case .White_NoStarLight_NoOpenNightVisionMode:
            fallthrough
        case .NoWhite_StarLight_NoOpenNightVisionMode:
            fallthrough
        case .White_StarLight_NoOpenNightVisionMode:
            bottomContent = A4xBaseManager.shared.getLocalString(key: "night_vision_off_descr", param: [deviceType])
            break
        case .NoWhite_NoStarLight_OpenNightVisionMode:
            
            fallthrough
        case .NoWhite_StarLight_OpenNightVisionMode:
            bottomContent = A4xBaseManager.shared.getLocalString(key: "night_vision_on_descr", param: [deviceType])
            break
        case .White_NoStarLight_OpenNightVisionMode:
            
            fallthrough
        case .White_StarLight_OpenNightVisionMode:
            
            bottomContent = ""
            break
        default:
            break
        }
        
        if nightVisionSwitch == true {
            
            for i in 0..<(modifiableAttributes?.count ?? 0) {
                let attrModel = modifiableAttributes?.getIndex(i)
                let name = attrModel?.name
                if name == "nightVisionSensitivity" {
                    
                    let titleString = A4xBaseManager.shared.getLocalString(key: "sensitivity_level")
                    let value = attrModel?.value
                    let nightVisionSensitivity = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                    
                    let allCase = tool.getEnumCases(currentType: .NightVisionSensitivity, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                    let nightVisionSensitivityContentKey = tool.getModifiableAttributeTypeName(currentType: .NightVisionSensitivity) + "_options_" + (nightVisionSensitivity)
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
            if bottomContent != "" {
                lastModel?.isShowContent = true
                lastModel?.content = bottomContent
                lastModel?.cellHeight = tool.getCellHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
                lastModel?.moduleHeight = tool.getModuleHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
                lastModel?.contentHeight = tool.getContentHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
                sortedArray[sortedArray.count-1] = lastModel ?? A4xDeviceSettingModuleModel()
            }
        }
        return sortedArray
        
    }
    
    
    private func getLinkageCase() -> Array<A4xDeviceSettingModuleModel>
    {

        
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        let tool = A4xDeviceSettingModuleTool()
        var models: Array<A4xDeviceSettingModuleModel> = []
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            if name == "liveStreamCodec" {
                
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "str_inter")
                let linkageModel = tool.createBaseArrowPointModel(moduleType: .ArrowPoint, currentType: .audioVideoLinkage, title: titleString, isInteractiveHidden: false)
                    
                models.append(linkageModel)
            }
        }
        
        return models
    }
    
    //MARK: ----- 数据更新 -----
    
    @objc private func updateSwitch(currentType: A4xDeviceSettingCurrentType, enable: Bool) {
        
        self.updateLocalSwitchCase(currentType: currentType, isOpen: false, isLoading: true)
        self.tableView.reloadData()
        
        var model = ModifiableAttributes()
        switch currentType {
        case .antiFlickerSwitch:
            model.name = "videoAntiFlickerSwitch"
        case .AutoNightVisionSwitch:
            model.name = "nightVisionSwitch"
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
                
                weakSelf?.getDeviceInfoFromNetwork()
            } else {
                
                weakSelf?.updateLocalSwitchCase(currentType: currentType, isOpen: !enable, isLoading: false)
                weakSelf?.tableView.reloadData()
            }
        }
        
    }
    
    
    @objc private func updateEnumValue(indexPath: IndexPath = IndexPath(), currentType: A4xDeviceSettingCurrentType, value: String) {
        var model = ModifiableAttributes()
        switch currentType {
        case .StarlightWhiteBlack:
            
            fallthrough
        case .StarlightColor:
            
            self.isNetworking = true
            model.name = "nightVisionMode"
            break
        case .VideoResolution:
            model.name = "videoResolution"
        case .AntiFlickerFrequency:
            model.name = "videoAntiFlickerFrequency"
        case .NightVisionSensitivity:
            model.name = "nightVisionSensitivity"
        default:
            model.name = ""
        }
        let codableModel = ModifiableAnyAttribute()
        codableModel.value = value
        model.value = codableModel
        let modifiableAttributes = [model]
        weak var weakSelf = self
        DeviceSettingCoreUtil.updateModifiableAttributes(deviceId: self.deviceModel?.serialNumber ?? "", modifiableAttributes: modifiableAttributes) { code, message in
            
            
            weakSelf?.isNetworking = false
            if code == 0 {
                
                weakSelf?.getDeviceInfoFromNetwork()
            } else {
                
                weakSelf?.tableView.reloadData()
                UIApplication.shared.keyWindow?.makeToast(message)
            }
        }
        
    }
    
    @objc private func updateLocalSwitchCase(currentType: A4xDeviceSettingCurrentType, isOpen: Bool, isLoading: Bool) {
        var tempCases = self.tableViewPresenter?.allCases
        for i in 0..<(self.tableViewPresenter?.allCases?.count ?? 0) {
            let module = self.tableViewPresenter?.allCases?.getIndex(i)
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
        self.tableViewPresenter?.allCases = tempCases
    }
    
    
    private func getApModeRequestEnumValue(currentType: A4xDeviceSettingCurrentType ,value: String) -> Int {
        
        var modeValue = 0
        switch currentType {
        case .VideoResolution:
            
            modeValue = value.intValue()
            return modeValue
        case .AntiFlickerFrequency:
            
            modeValue = value.intValue()
            return modeValue
        case .PirRecordTime:
            
            if value == "auto" {
                modeValue = -1
            } else {
                modeValue = value.intValue()
            }
            return modeValue
        case .PirCooldownTime:
            
            
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
    
    //MARK: ----- 私有方法 -----
    
    private func selectionBoxLoading(indexPath: IndexPath, isBoxLoading: Bool = true) {
        var tempAllCases = self.tableViewPresenter?.allCases
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        moduleModel?.isSelectionBoxLoading = isBoxLoading
        tempAllCases?[indexPath.section][indexPath.row] = moduleModel ?? A4xDeviceSettingModuleModel()
        self.tableViewPresenter?.allCases = tempAllCases
        self.tableView.reloadData()
    }
    
    private func updateModel(originModel: A4xDeviceSettingModuleModel, content: String) -> A4xDeviceSettingModuleModel {
        let tool = A4xDeviceSettingModuleTool()
        var model = A4xDeviceSettingModuleModel()
        model = originModel
        model.content = content
        model.isShowContent = true
        model.cellHeight = tool.getCellHeight(moduleModel: model)
        model.moduleHeight = tool.getModuleHeight(moduleModel: model)
        model.contentHeight = tool.getContentHeight(moduleModel: model)
        return model
    }
    
    
    //MARK: ----- A4xDeviceSettingModuleTableViewCellDelegate -----
    
    func A4xDeviceSettingModuleTableViewCellSwitchDidClick(indexPath: IndexPath, isOn: Bool)
    {
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        
        self.updateSwitch(currentType: currentType ?? .PirCooldownSwitch, enable: isOn)
    }
    
    
    func A4xDeviceSettingModuleTableViewCellSelectionBoxDidClick(indexPath: IndexPath, index: Int)
    {
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .StarlightWhiteBlack:
            
            
            if self.isNetworking == false {
                self.selectionBoxLoading(indexPath: indexPath)
                self.updateEnumValue(indexPath: indexPath, currentType: currentType ?? .StarlightWhiteBlack, value: "infrared")
            }
            break
        case .StarlightColor:
            
            if self.isNetworking == false {
                self.selectionBoxLoading(indexPath: indexPath)
                self.updateEnumValue(indexPath: indexPath, currentType: currentType ?? .StarlightColor, value: "white")
            }
            break
        default:
            break
        }
    }
    
    
    func A4xDeviceSettingModuleTableViewCellDidClick(indexPath: IndexPath)
    {
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .videoFlipEntrance:
            break
        case .StarlightSensor:
            var config = A4xBaseAlertAnimailConfig()
            config.rightTextColor = ADTheme.Theme
            config.rightbtnBgColor = .white
            let alert = A4xBaseAlertView(param: config, identifier: "showTipAlert")
            alert.title = A4xBaseManager.shared.getLocalString(key: "starlight_sensor_title")
            alert.message = A4xBaseManager.shared.getLocalString(key: "starlight_sensor_descr")
            alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "close_btn")
            alert.show()
            break
        case .audioVideoLinkage:
            break
            



        case .VideoResolution:
            fallthrough
        case .NightVisionSensitivity:
            fallthrough
        case .AntiFlickerFrequency:
            
            let enumAlert = A4xDeviceSettingEnumAlertView.init(frame: self.view.bounds, currentType: currentType ?? .NotiMode, allCases: moduleModel?.enumDataSource ?? [])
            enumAlert.delegate = self
            enumAlert.showAlert()
        default:
            break
        }
    }
    
    
    func A4xDeviceSettingModuleTableViewCellButtonDidClick(indexPath: IndexPath)
    {
        
    }
    
    
    func A4xDeviceSettingModuleTableViewCellSliderDidDrag(value: Float, indexPath: IndexPath)
    {
        
    }
    
    //MARK: ----- A4xDeviceSettingEnumAlertViewDelegate -----
    func A4xDeviceSettingEnumAlertViewCellDidClick(currentType: A4xDeviceSettingCurrentType, enumModel: A4xDeviceSettingEnumAlertModel) {
        
        self.updateEnumValue(currentType: currentType, value: enumModel.requestContent ?? "")
    }
}
