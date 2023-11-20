//


//


//

import UIKit
import SmartDeviceCoreSDK
import Resolver
import BaseUI

class A4xDeviceSettingMotionDetecctionViewController: A4xBaseViewController, A4xDeviceSettingModuleTableViewCellDelegate, A4xDeviceSettingEnumAlertViewDelegate {
    
    
    var deviceModel : DeviceBean?
    
    var isNetworking : Bool = false
    
    var detectPirAIValues : [String] = []
    
    
    public var deviceAttributeModel : DeviceAttributesBean? = DeviceAttributesBean()
    
    
    var tableViewPresenter : A4xDeviceSettingTableViewPresenter?
    
    
    var isMotionOpen: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.loadNavtion()
        self.tableView.isHidden = false
        if self.deviceModel?.apModeType == .AP {
            // AP Mode
            self.getApCases()
            self.tableView.reloadData()
        } else {
            self.getDeviceInfoFromNetwork()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        


    }
    
    //MARK: ----- 加载导航 -----
    private func loadNavtion() {
        weak var weakSelf = self
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 1)
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "motion_detection", param: [tempString])
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
    }
    
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
    
    //MARK: ----- 获取网络请求数据 -----
    private func getDeviceInfoFromNetwork()
    {
        weak var weakSelf = self
        DeviceSettingCoreUtil.getDeviceAttributes(deviceId: self.deviceModel?.serialNumber ?? "") { code, model, message in
            if code == 0 {
                weakSelf?.deviceAttributeModel = model
                weakSelf?.getAllCases()
                weakSelf?.tableView.reloadData()
            } else {
                
            }
        }
    }
    
    //MARK: ----- 根据网络请求结果,处理本地tableview数据源 -----
    private func getAllCases()
    {
        var allModels : Array<Array<A4xDeviceSettingModuleModel>> = []
        
        let motionModule = self.getMotionCases()
        allModels.append(motionModule)
        
        let isShow = self.isShowShootingSetting()
        if isShow {
            let shootingModule = self.getWifiAndAPShootingCases()
            allModels.append(shootingModule)
        }
        
        
        
        if self.isMotionOpen == true {
            let motionTrackModule = self.getMotionTrackCases()
            if motionTrackModule.count > 0 {
                allModels.append(motionTrackModule)
            }
        }
        
        
        let sleepModule = self.getSleepCases()
        allModels.append(sleepModule)
        
        self.tableViewPresenter?.allCases = allModels
    }
    
    
    private func getMotionCases() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var motionModule : Array<A4xDeviceSettingModuleModel> = []
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        var isCooldownOpen = false
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            if name == "pirSwitch" {
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "motion_detection")
                let value = attrModel?.value
                let pirSwitchValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                self.isMotionOpen = pirSwitchValue
                let pirSwitchModel = tool.createBaseSwitchModel(moduleType: tool.getModuleType(type: type), currentType: .PirSwitch, title: titleString, isSwitchOpen: pirSwitchValue, isSwitchLoading: false)
                let disabled = attrModel?.disabled
                if disabled != true {
                    motionModule.append(pirSwitchModel)
                }
            } else if name == "pirCooldownSwitch" {
                
                let titleString = A4xBaseManager.shared.getLocalString(key: "shooting_interval").capitalized
                let value = attrModel?.value
                let cooldownValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                isCooldownOpen = cooldownValue
            }
        }
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""
            
            if self.isMotionOpen == true {
                
                if name == "pirAi" {
                    
                    let options = attrModel?.options
                    let optionsArray = tool.getValueOrOption(anyCodable: options ?? ModifiableAnyAttribute()) as? [A4xDeviceSettingUnitModel]
                    let pirAI = optionsArray?[0]
                    
                    let values = attrModel?.value
                    let valuesArray = tool.getValueOrOption(anyCodable: values ?? ModifiableAnyAttribute()) as? [String] ?? []
                    
                    self.detectPirAIValues = valuesArray
                    
                    
                    let pirAIModel = tool.getCheckBoxSubModels(modelCategory: self.deviceModel?.modelCategory ?? 0,attrModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel(), isNetWorking: self.isNetworking)
                    motionModule.append(pirAIModel)
                    
                } else if name == "pirSensitivity" {
                    
                    let titleString = A4xBaseManager.shared.getLocalString(key: "detection_sensitivity")
                    let value = attrModel?.value
                    let pirSensitivityValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                    
                    let allCase = tool.getEnumCases(currentType: .PirSensitivity, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                    let pirSensitivityContentKey = tool.getModifiableAttributeTypeName(currentType: .PirSensitivity) + "_options_" + (pirSensitivityValue)
                    let pirSensitivityModel = tool.createBaseEnumModel(moduleType: tool.getModuleType(type: type), currentType: .PirSensitivity, title: titleString, titleContent: A4xBaseManager.shared.getLocalString(key: pirSensitivityContentKey), enumDataSource: allCase)
                    if allCase.count > 0 {
                        
                        motionModule.append(pirSensitivityModel)
                    }
                } else if name == "pirRecordTime" {
                    
                    let titleString = A4xBaseManager.shared.getLocalString(key: "video_duration").capitalized
                    let value = attrModel?.value
                    let allCase = tool.getEnumCases(currentType: .PirRecordTime, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel(), modelCategory: self.deviceAttributeModel?.fixedAttributes?.modelCategory)
                    let pirRecordTimeValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                    let pirRecordTimeContentKey = tool.getModifiableAttributeTypeName(currentType: .PirRecordTime) + "_options_" + (pirRecordTimeValue)
                    let pirRecordTimeModel = tool.createBaseEnumModel(moduleType: tool.getModuleType(type: type), currentType: .PirRecordTime, title: titleString, titleContent: A4xBaseManager.shared.getLocalString(key: pirRecordTimeContentKey), enumDataSource: allCase)
                    if allCase.count > 0 {
                        
                        motionModule.append(pirRecordTimeModel)
                    }
                }
            }
        }
        
        var sortedMotionModule = tool.sortModuleArray(moduleArray: motionModule)
        
        let lastModel = sortedMotionModule.last
        if sortedMotionModule.count > 0 {
            lastModel?.isShowContent = true
            let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
            lastModel?.content = A4xBaseManager.shared.getLocalString(key: "motion_detection_des", param: [tempString])
            lastModel?.cellHeight = tool.getCellHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.moduleHeight = tool.getModuleHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.contentHeight = tool.getContentHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            sortedMotionModule[sortedMotionModule.count-1] = lastModel ?? A4xDeviceSettingModuleModel()
        }
        return sortedMotionModule
    }
    
    private func getSleepCases() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var sleepModule : Array<A4xDeviceSettingModuleModel> = []
        
        let realTimeAttributes = self.deviceAttributeModel?.realTimeAttributes
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        let dormancySwitchTitleString = A4xBaseManager.shared.getLocalString(key: "sleep_mode").capitalized
        var isdormancySwitchOpen = false
        if realTimeAttributes?.deviceStatus == 3 {
            isdormancySwitchOpen = true
        } else {
            isdormancySwitchOpen = false
        }
        let dormancySwitchModel = tool.createBaseSwitchModel(moduleType: .Switch, currentType: .DormancySwitch, title: dormancySwitchTitleString, isSwitchOpen: isdormancySwitchOpen, isSwitchLoading: false)
        dormancySwitchModel.isShowTitleDescription = true
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
        dormancySwitchModel.titleDescription = A4xBaseManager.shared.getLocalString(key: "auto_sleep_subtext", param: [tempString])
        dormancySwitchModel.cellHeight = tool.getCellHeight(moduleModel: dormancySwitchModel)
        dormancySwitchModel.moduleHeight = tool.getModuleHeight(moduleModel: dormancySwitchModel)
        dormancySwitchModel.contentHeight = tool.getContentHeight(moduleModel: dormancySwitchModel)
        sleepModule.append(dormancySwitchModel)
        
        var isTimedDormancyOpen = false
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            
            if name == "timedDormancySwitch" {
                let timedDormancySwitchTitleString = A4xBaseManager.shared.getLocalString(key: "auto_sleep")
                let value = attrModel?.value
                let timedDormancySwitchValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                isTimedDormancyOpen = timedDormancySwitchValue
                let timedDormancySwitchModel = tool.createBaseSwitchModel(moduleType: .Switch, currentType: .TimedDormancySwitch, title: timedDormancySwitchTitleString, isSwitchOpen: timedDormancySwitchValue, isSwitchLoading: false)
                let disabled = attrModel?.disabled
                if disabled != true {
                    sleepModule.append(timedDormancySwitchModel)
                }
            }
            
        }
        
        if isTimedDormancyOpen == true {
            
            let timeSettingModel = tool.createBaseArrowPointModel(moduleType: .ArrowPoint, currentType: .TimedDormancySetting, title: A4xBaseManager.shared.getLocalString(key: "schedule_time").capitalized, isInteractiveHidden: false)
            sleepModule.append(timeSettingModel)
        }
        
        var sortedSleepModule = tool.sortModuleArray(moduleArray: sleepModule)
        
        let lastModel = sortedSleepModule.last
        if sortedSleepModule.count > 0 {
            lastModel?.isShowContent = true
            let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
            lastModel?.content = A4xBaseManager.shared.getLocalString(key: "auto_sleep_prompt", param: [tempString])
            lastModel?.cellHeight = tool.getCellHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.moduleHeight = tool.getModuleHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            lastModel?.contentHeight = tool.getContentHeight(moduleModel: lastModel ?? A4xDeviceSettingModuleModel())
            sortedSleepModule[sortedSleepModule.count-1] = lastModel ?? A4xDeviceSettingModuleModel()
        }
        return sortedSleepModule
        
    }
    
    
    private func getMotionTrackCases() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var motionTrackModule : Array<A4xDeviceSettingModuleModel> = []
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let value = attrModel?.value
            if name == "motionTrackingSwitch" {
                let motionTrackString = A4xBaseManager.shared.getLocalString(key: "motion_tracking")
                let motionTrackValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                let motionTrackModel = tool.createBaseSwitchModel(moduleType: .Switch, currentType: .MotionTrackingSwitch, title: motionTrackString, isSwitchOpen: motionTrackValue, isSwitchLoading: false)
                
                let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
                motionTrackModel.content = A4xBaseManager.shared.getLocalString(key: "motion_tracking_open", param: [tempString])
                motionTrackModel.isShowContent = true
                motionTrackModel.cellHeight = tool.getCellHeight(moduleModel: motionTrackModel)
                motionTrackModel.moduleHeight = tool.getModuleHeight(moduleModel: motionTrackModel)
                motionTrackModel.contentHeight = tool.getContentHeight(moduleModel: motionTrackModel)
                let disabled = attrModel?.disabled
                if disabled != true {
                    motionTrackModule.append(motionTrackModel)
                }
            }
        }
        
        return motionTrackModule
    }
    
    //MARK: ----- 获取AP模式数据 -----
    private func getApCases()
    {
        var allModels : Array<Array<A4xDeviceSettingModuleModel>> = []
        // 运动检测模块
        let motionModule = self.getApMotionCases()
        allModels.append(motionModule)
        
        let isShow = self.isShowShootingSetting()
        if isShow {
            let shootingModule = self.getWifiAndAPShootingCases()
            allModels.append(shootingModule)
        }
        
        self.tableViewPresenter?.allCases = allModels
    }
    
    // 运动检测通知
    private func getApMotionCases() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var apMotionModule : Array<A4xDeviceSettingModuleModel> = []
        
        // pirSwitch 运动检测开关
        let titleString = A4xBaseManager.shared.getLocalString(key: "motion_detection")
        var pirSwitchValue: Bool = false
        if self.deviceModel?.deviceConfigBean?.needMotion == 1 {
            pirSwitchValue = true
        } else {
            pirSwitchValue = false
        }
        
        let pirSwitchModel = tool.createBaseSwitchModel(moduleType: tool.getModuleType(type: "SWITCH"), currentType: .PirSwitch, title: titleString, isSwitchOpen: pirSwitchValue, isSwitchLoading: false)
        apMotionModule.append(pirSwitchModel)
        
        // 拍摄间隔开关
        var cooldownSwitchValue: Bool = false
        // 只有开启了运动检测,下面一系列才会显示出来
        if pirSwitchValue == true {
            // pir灵敏度 pirSensitivity
            let currentPirSensitivityTitle = A4xBaseManager.shared.getLocalString(key: "detection_sensitivity")
            let currentPirSensitivityTitleString = A4xBaseManager.shared.getLocalString(key: "detection_sensitivity")
            var currentMotionSensitivityString = self.getApModeStringValue(currentType: .PirSensitivity, value: self.deviceModel?.deviceConfigBean?.motionSensitivity ?? 1)
            let currentPirSensitivityContentKey = tool.getModifiableAttributeTypeName(currentType: .PirSensitivity) + "_options_" + (currentMotionSensitivityString)
            // 获取枚举的数据源 [1,2,3]
            var pirSensitivityEnumData: Array<A4xDeviceSettingEnumAlertModel> = []
            for i in 1..<4 {
                let pirSensitivityEnumModel = A4xDeviceSettingEnumAlertModel()
                let enumMotionSensitivityString = self.getApModeStringValue(currentType: .PirSensitivity, value: i)
                let enumPirSensitivityContentKey = tool.getModifiableAttributeTypeName(currentType: .PirSensitivity) + "_options_" + (enumMotionSensitivityString)
                pirSensitivityEnumModel.content = A4xBaseManager.shared.getLocalString(key: enumPirSensitivityContentKey)
                pirSensitivityEnumModel.requestContent = "\(i)"
                pirSensitivityEnumModel.isEnable = true
                pirSensitivityEnumData.append(pirSensitivityEnumModel)
            }
            
            let pirSensitivityModel = tool.createBaseEnumModel(moduleType: tool.getModuleType(type: "ENUM"), currentType: .PirSensitivity, title: currentPirSensitivityTitle, titleContent: A4xBaseManager.shared.getLocalString(key: currentPirSensitivityContentKey), enumDataSource: pirSensitivityEnumData)
            apMotionModule.append(pirSensitivityModel)
        
            // 录制时长 pirRecordTime
            let currentRecordTimeTitle = A4xBaseManager.shared.getLocalString(key: "video_duration")
            // 处理enum
            var secondsEnumData: Array<A4xDeviceSettingEnumAlertModel> = []
            for i in 0..<(self.deviceModel?.apModeModel?.videoSecondsValues?.count ?? 0) {
                let secondsValue_Int = self.deviceModel?.apModeModel?.videoSecondsValues?.getIndex(i)
                var secondsValue = ""
                let secondsEnumModel = A4xDeviceSettingEnumAlertModel()
                if secondsValue_Int == -1 {
                    secondsValue = "auto"
                    secondsEnumModel.requestContent = "auto"
                    let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
                    secondsEnumModel.descriptionContent = A4xBaseManager.shared.getLocalString(key: "auto_video_record_desc", param: [tempString])
                } else {
                    secondsValue = "\(secondsValue_Int ?? 10)s"
                    secondsEnumModel.requestContent = "\(secondsValue_Int ?? 10)"
                }
                
                let secondsContentKey = tool.getModifiableAttributeTypeName(currentType: .PirRecordTime) + "_options_" + (secondsValue)
                secondsEnumModel.content = A4xBaseManager.shared.getLocalString(key: secondsContentKey)
                
                secondsEnumModel.isEnable = true
                secondsEnumData.append(secondsEnumModel)
                
            }
            
            let videoSeconds_Int = self.deviceModel?.deviceConfigBean?.videoSeconds
            var currentVideoSeconds = self.getApModeStringValue(currentType: .PirRecordTime, value: videoSeconds_Int ?? 10)
            let pirRecordTimeContentKey = tool.getModifiableAttributeTypeName(currentType: .PirRecordTime) + "_options_" + (currentVideoSeconds)
            let pirRecordTimeModel = tool.createBaseEnumModel(moduleType: tool.getModuleType(type: "ENUM"), currentType: .PirRecordTime, title: currentRecordTimeTitle, titleContent: A4xBaseManager.shared.getLocalString(key: pirRecordTimeContentKey), enumDataSource: secondsEnumData)
            apMotionModule.append(pirRecordTimeModel)
        }
        
        
//        }
        // 排序
        var sortedMotionModule = tool.sortModuleArray(moduleArray: apMotionModule)
        
        return sortedMotionModule
    }
    
    //MARK: ----- AP模式下的数据处理 -----
    // 获取Ap模式下的解析的数据源 String
    private func getApModeStringValue(currentType: A4xDeviceSettingCurrentType ,value: Int) -> String {
        var modeValue = ""
        switch currentType {
        case .PirSensitivity:
            // Pir灵敏度
            if value == 1 {
                modeValue = "low"
            } else if value == 2 {
                modeValue = "mid"
            } else if value == 3 {
                modeValue = "high"
            } else if value == 4 {
                modeValue = "auto"
            } else {
                modeValue = "auto"
            }
            return modeValue
        case .PirRecordTime:
            // 视频时长
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
        case .PirSensitivity:
            // Pir灵敏度
            modeValue = value.intValue()
            return modeValue
        case .PirRecordTime:
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
    
    //MARK: ----- AP和WIFI模式下拍摄设置入口 -----
    private func getWifiAndAPShootingCases() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var models : Array<A4xDeviceSettingModuleModel> = []
        let shootingTitle = A4xBaseManager.shared.getLocalString(key: "recording_setting")
        let shootingModule = tool.createBaseArrowPointModel(moduleType: .ArrowPoint, currentType: .ShootingSettings, title: shootingTitle, isInteractiveHidden: false)
        models.append(shootingModule)
        return models
    }
    
    //MARK: ----- 获取是否展示拍摄设置的入口 -----
    private func isShowShootingSetting() -> Bool {
        var isShow = false
        if self.deviceModel?.apModeType == .AP {
            isShow = true
        } else {
            var isOpenPirCooldownSwitch = false
            var isOpenSdCardCooldownSwitch = false
            
            let tool = A4xDeviceSettingModuleTool()
            let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
            for i in 0..<(modifiableAttributes?.count ?? 0) {
                let attrModel = modifiableAttributes?.getIndex(i)
                let name = attrModel?.name
                if name == "pirCooldownSwitch" {
                    let disabled = attrModel?.disabled
                    if disabled != true {
                        isShow = true
                        break
                    }
                    
                    let value = attrModel?.value
                    isOpenPirCooldownSwitch = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false

                } else if name == "sdCardCooldownSwitch" {
                    let disabled = attrModel?.disabled
                    if disabled != true {
                        isShow = true
                        break
                    }
                    let value = attrModel?.value
                    isOpenSdCardCooldownSwitch = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                }
                else if name == "sdCardVideoModes" {
                    let allCase = tool.getEnumCases(currentType: .SDCardVideoModes, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                    if allCase.count > 0 {
                        isShow = true
                        break
                    }
                }
            }
            
            for i in 0..<(modifiableAttributes?.count ?? 0) {
                let attrModel = modifiableAttributes?.getIndex(i)
                let name = attrModel?.name
                if name == "sdCardCooldownSeconds" {
                    if isOpenSdCardCooldownSwitch == true {
                        let allCase = tool.getEnumCases(currentType: .SDCardCooldownSeconds, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                        if allCase.count > 0 {
                            isShow = true
                            break
                        }
                    }
                }
                else if name == "pirCooldownTime" {
                    if isOpenPirCooldownSwitch == true {
                        let allCase = tool.getEnumCases(currentType: .PirCooldownTime, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                        if allCase.count > 0 {
                            isShow = true
                            break
                        }
                    }
                }
            }
        }
        return isShow
    }
    
    //MARK: ----- 更新接口数据 -----
    
    @objc private func updateDormancySwitch(enable: Bool) {
        weak var weakSelf = self
        self.updateLocalSwitchCase(currentType: .DormancySwitch, isOpen: false, isLoading: true)
        self.tableView.reloadData()
        DeviceSleepPlanCore.getInstance().setSleep(serialNumber: self.deviceModel?.serialNumber ?? "", enable: enable) { code, message in
            weakSelf?.updateLocalSwitchCase(currentType: .DormancySwitch, isOpen: enable, isLoading: false)
            weakSelf?.tableView.reloadData()
        } onError: { code, message in
            weakSelf?.updateLocalSwitchCase(currentType: .DormancySwitch, isOpen: !enable, isLoading: false)
            weakSelf?.tableView.reloadData()
        }
    }
    
    @objc private func showPirSwitchAlert(enable: Bool) {
        weak var weakSelf = self
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.Theme
        config.rightTextColor = UIColor.white
        let alert = A4xBaseAlertView(param: config, identifier: "motion alert")
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 1)
        alert.title = A4xBaseManager.shared.getLocalString(key: "sure_to_turn_off_detection")
        alert.message  = A4xBaseManager.shared.getLocalString(key: "camera_will_not_record", param: [tempString])
        
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "no")
        alert.leftButtonBlock = {
            weakSelf?.tableView.reloadData()
        }
        
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "yes")
        alert.rightButtonBlock = {
            weakSelf?.updateSwitch(currentType: .PirSwitch, enable: enable)
        }
        self.showAlert(view: alert, isClearAll: true)
    }
    
    
    // 更新开关(AP和WIFI模式通用,内部已经处理)
    @objc private func updateSwitch(currentType: A4xDeviceSettingCurrentType, enable: Bool) {
        // 先Loading
        self.updateLocalSwitchCase(currentType: currentType, isOpen: false, isLoading: true)
        self.tableView.reloadData()
        // 再处理数据
        if self.deviceModel?.apModeType == .AP {
            let attribute = ApDeviceAttributeModel()
            switch currentType {
            case .PirSwitch:
                attribute.name = "needMotion"
                if enable == true {
                    self.deviceModel?.deviceConfigBean?.needMotion = 1
                    attribute.value = 1
                } else {
                    self.deviceModel?.deviceConfigBean?.needMotion = 0
                    attribute.value = 0
                }
            default:
                break
            }
            weak var weakSelf = self
            let attributeArray : Array<ApDeviceAttributeModel> = [attribute]
            DeviceSettingCore.getInstance().updateApDeviceInfo(serialNumber: self.deviceModel?.serialNumber ?? "", attributes: attributeArray) { code, message in
                A4xUserDataHandle.Handle?.updateDevice(device: weakSelf?.deviceModel)
                // 成功之后更新数据
                weakSelf?.getApCases()
                weakSelf?.tableView.reloadData()
            } onError: { code, message in
                self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "open_fail_retry"))
            }

        } else {
            
            var model = ModifiableAttributes()
            switch currentType {
            case .PirSwitch:
                model.name = "pirSwitch"
            case .PirCooldownSwitch:
                model.name = "pirCooldownSwitch"
            case .TimedDormancySwitch:
                model.name = "timedDormancySwitch"
            case .MotionTrackingSwitch:
                model.name = "motionTrackingSwitch"
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
                    // 重新获取数据
                    weakSelf?.getDeviceInfoFromNetwork()
                    let postDic : [String: Any] = ["type":model.name ?? "", "deviceId": weakSelf?.deviceModel?.serialNumber ?? "", "enable" : enable]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "A4xLiveNeedUpdateData"), object: nil, userInfo: postDic)
                    weakSelf?.deviceModel?.motionTrack = enable.toInt()
                    A4xUserDataHandle.Handle?.updateDevice(device: weakSelf?.deviceModel)
                } else {
                    weakSelf?.updateLocalSwitchCase(currentType: currentType, isOpen: !enable, isLoading: false)
                    weakSelf?.tableView.reloadData()
                }
            }
        }
        
    }
    
    
    @objc private func updateCheckBox(module: A4xDeviceSettingModuleModel, indexPath: IndexPath, index: Int, isSelected: Bool, isLoading: Bool, values: [String]) {
        let currentType = module.currentType ?? .PirDetectPreference
        var model = ModifiableAttributes()
        switch currentType {
        case .PirDetectPreference:
            model.name = "pirAi"
        default:
            model.name = ""
        }
        let codableModel = ModifiableAnyAttribute()
        codableModel.value = values
        model.value = codableModel
        let modifiableAttributes = [model]
        weak var weakSelf = self
        DeviceSettingCoreUtil.updateModifiableAttributes(deviceId: self.deviceModel?.serialNumber ?? "", modifiableAttributes: modifiableAttributes) { code, message in
            if code == 0 {
                weakSelf?.getDeviceInfoFromNetwork()
            } else {
                weakSelf?.tableView.reloadData()
            }
        }
    }
    
    
    @objc private func updateEnumValue(currentType: A4xDeviceSettingCurrentType, value: String) {
        if self.deviceModel?.apModeType == .AP {
            
            var attribute = ApDeviceAttributeModel()
            switch currentType {
            case .PirSensitivity:
                attribute.name = "motionSensitivity"
                self.deviceModel?.deviceConfigBean?.motionSensitivity = self.getApModeRequestEnumValue(currentType: currentType, value: value)
                break
            case .PirRecordTime:
                attribute.name = "videoSeconds"
                self.deviceModel?.deviceConfigBean?.videoSeconds = self.getApModeRequestEnumValue(currentType: currentType, value: value)
                break
            default:
                break
            }
            
            attribute.value = self.getApModeRequestEnumValue(currentType: currentType, value: value) as Any?
            let attributeArray : Array<ApDeviceAttributeModel> = [attribute]
            
            weak var weakSelf = self
            DeviceSettingCore.getInstance().updateApDeviceInfo(serialNumber: self.deviceModel?.serialNumber ?? "", attributes: attributeArray) { code, message in
                A4xUserDataHandle.Handle?.updateDevice(device: weakSelf?.deviceModel)
                // 成功之后更新数据
                weakSelf?.getApCases()
                weakSelf?.tableView.reloadData()
            } onError: { code, message in
                self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "open_fail_retry"))
            }

        } else {
            var model = ModifiableAttributes()
            switch currentType {
            case .PirSwitch:
                model.name = "pirSwitch"
            case .PirSensitivity:
                model.name = "pirSensitivity"
            case .PirRecordTime:
                model.name = "pirRecordTime"
            case .TimedDormancySwitch:
                model.name = "timedDormancySwitch"
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
                    // 重新获取数据
                    weakSelf?.getDeviceInfoFromNetwork()
                } else {
                    //
                    UIApplication.shared.keyWindow?.makeToast(message)
                }
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
    
    
    @objc private func showDevicePirAlert(module: A4xDeviceSettingModuleModel,indexPath: IndexPath, index: Int, isSelected: Bool) {
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)
        let currentType = module.currentType
        var alertMessage = ""
        
        switch currentType {
        case .PirDetectPreference:
            alertMessage = A4xBaseManager.shared.getLocalString(key: "pirAi_options_detectPersonAi_pop", param: [tempString])
            break
        default:
            break
        }
        
        var config = A4xBaseAlertAnimailConfig()
        config.rightbtnBgColor = .white
        config.rightTextColor = ADTheme.Theme
        config.leftbtnBgColor = .white
        let alert = A4xBaseAlertView(param: config, identifier: "showTipAlert + \(Int.kRandom())")
        alert.message  = alertMessage
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "confirm")
        weak var weakSelf = self
        alert.rightButtonBlock = {
            weakSelf?.updateLocalCheckBoxCase(module: module, indexPath: indexPath, index: index, isSelected: isSelected, isLoading: true)
        }
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
        alert.leftButtonBlock = {
            
        }
        alert.show()
        
        
    }
    
    
    @objc private func updateLocalCheckBoxCase(module: A4xDeviceSettingModuleModel, indexPath: IndexPath, index: Int, isSelected: Bool, isLoading: Bool) {
        
        let subModels = module.subModuleModels
        let checkBoxModel = module.subModuleModels.getIndex(index)
        
        
        
        let tempAllCases_resource = self.tableViewPresenter?.allCases ?? []
        
        var tempAllCases = self.tableViewPresenter?.allCases ?? []
        
        let tempMoudle = module
        var tempSubModels = subModels
        
        for i in 0..<subModels.count {
            let subModel = subModels.getIndex(i)
            var tempCheckBoxModel = subModel ?? A4xDeviceSettingModuleModel()
            tempCheckBoxModel.isNetWorking = true
            if i == index {
                tempCheckBoxModel.isSelected = isSelected
                tempCheckBoxModel.isSelectionBoxLoading = isLoading
            }
            tempSubModels[i] = tempCheckBoxModel
        }
        tempMoudle.subModuleModels = tempSubModels
        tempAllCases[indexPath.section][indexPath.row] = tempMoudle
        
        self.tableViewPresenter?.allCases = tempAllCases
        self.tableView.reloadData()
        
        self.tableViewPresenter?.allCases = tempAllCases_resource
        
        if isSelected == true {
            if self.detectPirAIValues.count >= (checkBoxModel?.at_most ?? 1) {
                
                return
            } else {
                self.detectPirAIValues.append(checkBoxModel?.requestValue ?? "")
            }
        } else {
            if self.detectPirAIValues.count <= (checkBoxModel?.at_leat ?? 0) {
                
                return
            } else if self.detectPirAIValues.count > 0{
                for i in 0..<self.detectPirAIValues.count {
                    let value = self.detectPirAIValues.getIndex(i)
                    if value == checkBoxModel?.requestValue {
                        self.detectPirAIValues.remove(at: i)
                    }
                }
            }
        }
        self.updateCheckBox(module: module, indexPath: indexPath, index: index, isSelected: isSelected, isLoading: true, values: self.detectPirAIValues)
    }
    
    
    
    //MARK: ----- A4xDeviceSettingModuleTableViewCellDelegate -----
    
    func A4xDeviceSettingModuleTableViewCellSwitchDidClick(indexPath: IndexPath, isOn: Bool)
    {
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        if currentType == .DormancySwitch {
            
            self.updateDormancySwitch(enable: isOn)
        } else if currentType == .PirSwitch {
            
            if isOn == false {
                
                self.showPirSwitchAlert(enable: isOn)
            } else {
                self.updateSwitch(currentType: currentType ?? .PirSwitch, enable: isOn)
            }
        } else if currentType == .MotionTrackingSwitch {
            
            
            self.updateSwitch(currentType: currentType ?? .MotionTrackingSwitch, enable: isOn)
        } else {
            
            self.updateSwitch(currentType: currentType ?? .PirCooldownSwitch, enable: isOn)
        }
    }
    
    
    func A4xDeviceSettingModuleTableViewCellSelectionBoxDidClick(indexPath: IndexPath, index: Int)
    {
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row] ?? A4xDeviceSettingModuleModel()
        let checkBoxModel = moduleModel.subModuleModels.getIndex(index)
        let isSelected = checkBoxModel?.isSelected ?? false
        let currentType = moduleModel.currentType
        switch currentType {
        case .PirDetectPreference:
            
            
            if isSelected == false {
                
                self.showDevicePirAlert(module: moduleModel, indexPath: indexPath, index: index, isSelected: !isSelected)
            } else {
                
                self.updateLocalCheckBoxCase(module: moduleModel, indexPath: indexPath, index: index, isSelected: !isSelected, isLoading: true)
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
        case .TimedDormancySetting:
            
            let vc = A4xDevicesSleepPlanShowViewController(deviceModel: self.deviceModel ?? DeviceBean(serialNumber: self.deviceModel?.serialNumber ?? ""))
            self.navigationController?.pushViewController(vc, animated: true)
        case .PirSensitivity:
            fallthrough
        case .PirRecordTime:
            
            let enumAlert = A4xDeviceSettingEnumAlertView.init(frame: self.view.bounds, currentType: currentType ?? .PirSensitivity, allCases: moduleModel?.enumDataSource ?? [])
            enumAlert.delegate = self
            enumAlert.showAlert()
        case .ShootingSettings:
            let vc = A4xDeviceSettingShootingSettingViewController()
            vc.deviceModel = self.deviceModel
            self.navigationController?.pushViewController(vc, animated: true)
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


