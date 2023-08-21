//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingPushSettingViewController: A4xBaseViewController, A4xDeviceSettingModuleTableViewCellDelegate, A4xDeviceSettingEnumAlertViewDelegate {
    
    //MARK: ----- 属性 -----
    
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
    
    let attrGroup = DispatchGroup()
    let attrQueue = DispatchQueue.global()
    
    var deviceId: String? = ""
    var deviceModel: DeviceBean?
    
    var mergePushModel: A4xMergePushModel?
    
    var notiConfigModelList: [NotificationConfigBean]?
    
    
    public var deviceAttributeModel : DeviceAttributesBean?
    
    
    var hasVip: Bool = false
    
    var isRequestCompleted : Bool = true
    
    
    
    
    var isSupportPirAi: Bool = false
    
    
    var isNetWorking : Bool = false
        
    private var analysisModels:  [AnalysisModelBean]?
    
    
    
    
    var isShowPersonTag : Bool = false
    var isShowPetTag : Bool = false
    var isShowVehicleTag : Bool = false
    var isShowPackageTag : Bool = false
    
    var tableViewPresenter : A4xDeviceSettingTableViewPresenter?
    
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
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "notification_setting")
        self.tableView.isHidden = false
        
        
        self.deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceId ?? "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.getVipAndAttrInfo()
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
    
    
    @objc private func getVipAndAttrInfo() {
        weak var weakSelf = self
        
        
        attrQueue.async(group: attrGroup, execute: {
            weakSelf?.attrGroup.enter()
            DeviceManageUtil.getDeviceSettingInfo(deviceId: self.deviceId ?? "") { (code, msg, model) in
                weakSelf?.attrGroup.leave()
                if code == 0 {
                    weakSelf?.deviceModel = model
                    A4xUserDataHandle.Handle?.updateDevice(device: weakSelf?.deviceModel ?? DeviceBean())
                    if weakSelf?.deviceModel?.deviceInVip == true {
                        weakSelf?.hasVip = true
                    } else {
                        weakSelf?.hasVip = false
                    }
                    
                } else {
                    weakSelf?.isRequestCompleted = false
                    weakSelf?.view.makeToast(A4xAppErrorConfig(code: code).message())
                }
            }
        })
        
        
        attrQueue.async(group: attrGroup, execute: {
            weakSelf?.attrGroup.enter()
            weakSelf?.getAttrInfoFromNetwork()
        })
        
        
        attrGroup.notify(queue: attrQueue) {
            
            
            if weakSelf?.isRequestCompleted == true {
                DispatchQueue.main.async {
                    
                    weakSelf?.getAllNotificationSettingFromNetwork()
                }
            }
        }
        
    }
    
    
    private func refreshPushView() {
        self.tableView.reloadData()
    }
    
    //MARK: ----- 网络请求相关 -----
    private func getAllNotificationSettingFromNetwork() {
        weak var weakSelf = self
        
        if self.hasVip == true
        {
            
            queue.async(group: group, execute: {
                weakSelf?.group.enter()
                weakSelf?.loadMergePushData()
            })

            
            queue.async(group: group, execute: {
                weakSelf?.group.enter()
                weakSelf?.loadNoticationConfig()
            })
            
            
            queue.async(group: group, execute: {
                weakSelf?.group.enter()
                weakSelf?.queryAIEventSwitchData()
            })
            
            queue.async(group: group, execute: {
                weakSelf?.group.enter()
                weakSelf?.getActivityZoneInfo()
            })
            
        } else {
            if self.isSupportPirAi == true {
                queue.async(group: group, execute: {
                    weakSelf?.group.enter()
                    weakSelf?.loadMergePushData()
                })
                
                queue.async(group: group, execute: {
                    weakSelf?.group.enter()
                    weakSelf?.loadNoticationConfig()
                })
                
                
                queue.async(group: group, execute: {
                    weakSelf?.group.enter()
                    weakSelf?.queryAIEventSwitchData()
                })
            } else {
                
            }
        }
        
        group.notify(queue: queue) {
            
            DispatchQueue.main.async {
                
                weakSelf?.isRequestCompleted = true
                
                weakSelf?.getShowTags()
                weakSelf?.getAllCases()
                weakSelf?.refreshPushView()
            }
        }
    }
    
    private func loadMergePushData() {
        weak var weakSelf = self
        
        DeviceAICore.getInstance().getMergePushData { code, message, isOpen in
            weakSelf?.group.leave()
            var model = A4xMergePushModel()
            model.messageMergeSwitch = isOpen
            weakSelf?.mergePushModel = model
        } onError: { code, message in
            weakSelf?.group.leave()
        }
    }
    
    func loadNoticationConfig() {
        
        guard let deviceId = self.deviceId else {
            self.group.leave()
            return
        }
        
        guard let userId = A4xUserDataHandle.Handle?.loginModel?.id else {
            self.group.leave()
            return
        }
        weak var weakSelf = self
        
        DeviceAIUtil.queryMessageNotification(deviceId: deviceId) { code, message, model in
            weakSelf?.group.leave()
            if code == 0 {
                if model?.list?.count ?? 0 > 0 {
                    self.notiConfigModelList = model?.list
                    //weakSelf?.dataSource = model?.list ?? [] //-1 ??
                    //weakSelf?.reloadData()
                }
            } else {
                weakSelf?.group.leave()
                weakSelf?.view.makeToast(A4xAppErrorConfig(code: code).message())
            }
        }
        











    }
    
    
    private func queryAIEventSwitchData() { 
        weak var weakSelf = self
        DeviceAICore.getInstance().getAnalysisEventConfig(serialNumber: self.deviceModel?.serialNumber ?? "") { code, message, models in
            weakSelf?.group.leave()
            for i in 0..<models.count {
                weakSelf?.analysisModels = models
            }
        } onError: { code, message in
            weakSelf?.group.leave()
            
            weakSelf?.view.makeToast(message)
        }











//





    }
    
    private func getAttrInfoFromNetwork()
    {
        weak var weakSelf = self
        DeviceSettingCoreUtil.getDeviceAttributes(deviceId: self.deviceModel?.serialNumber ?? "") { code, model, message in
            weakSelf?.attrGroup.leave()
            if code == 0 {
                weakSelf?.deviceAttributeModel = model
                let fixedAttributes = weakSelf?.deviceAttributeModel?.fixedAttributes
                if fixedAttributes?.supportPirAi == true {
                    
                    weakSelf?.isSupportPirAi = true
                } else {
                    weakSelf?.isSupportPirAi = false
                }
            } else {
                weakSelf?.isRequestCompleted = false
            }
        }
    }
    
    
    private func getActivityZoneInfo() {
        weak var weakSelf = self
        DeviceActivityZoneCore.getInstance().getAllZonesList(serialNumber: self.deviceModel?.serialNumber ?? "") { code, message, models in
            weakSelf?.group.leave()
            weakSelf?.deviceModel?.zonePointList = models
        } onError: { code, message in
            weakSelf?.group.leave()
            let errorMessage = A4xAppErrorConfig(code: code).message() ?? message
            UIApplication.shared.keyWindow?.makeToast(errorMessage)
        }
    }
    
    //MARK: ----- 数据相关 -----
    
    private func getShowTags() {
        for i in 0..<(self.analysisModels?.count ?? 0) {
            let analysisModel = self.analysisModels?.getIndex(i)
            let checked = analysisModel?.checked ?? false
            if analysisModel?.eventObject == "person" {
                self.isShowPersonTag = checked
            } else if analysisModel?.eventObject == "pet" {
                self.isShowPetTag = checked
            } else if analysisModel?.eventObject == "vehicle" {
                self.isShowVehicleTag = checked
            } else if analysisModel?.eventObject == "package" {
                self.isShowPackageTag = checked
            }
        }
    }
    
    private func getAllCases() {
                
        var allModels : Array<Array<A4xDeviceSettingModuleModel>> = []
        
        
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            if name == "doorbellPressNotifySwitch" {
                
                let ringNotificationModule = self.getRingNotiCases()
                allModels.append(ringNotificationModule)
            }
        }
        
        
        if self.hasVip == true {

            
            let mergeModule = self.getMergePushCases()
            allModels.append(mergeModule)
            
            
            
            let aiModule = self.getDevicePirAICases()
            
            
            
            if (self.notiConfigModelList?.count ?? 0) > 0 {
                let notiConfigModels = self.getNotiConfigCases(isVip: self.hasVip)
                allModels.append(notiConfigModels)
            }
            
        } else {
            
            if self.isSupportPirAi == true {
                
                
                let mergeModule = self.getMergePushCases()
                allModels.append(mergeModule)
                
                
                
                if (self.notiConfigModelList?.count ?? 0) > 0 {
                    let notiConfigModels = self.getNotiConfigCases(isVip: self.hasVip)
                    allModels.append(notiConfigModels)
                }
                
                
                
                let advertisementModule = self.getAdvertisementCase()
                allModels.append(advertisementModule)
                
            } else {
                
                let aiMotionModule = self.getAiMotionCase()
                allModels.append(aiMotionModule)
                
            }
        }
        
        self.tableViewPresenter?.allCases = allModels
        //return allModels
    }
    
    
    private func getRingNotiCases() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var ringNotificationModule : Array<A4xDeviceSettingModuleModel> = []
        var ringNotificationModuleModel : A4xDeviceSettingModuleModel
        var notificationModeModuleModel : A4xDeviceSettingModuleModel
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        var isRingNotiOpen : Bool = true
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let value = attrModel?.value
            if name == "doorbellPressNotifySwitch" {
                
                let ringNotificationSwitchValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                isRingNotiOpen = ringNotificationSwitchValue
                ringNotificationModuleModel = tool.createMuduleModel(moduleType: .Switch, currentType: .RingNoti, title: A4xBaseManager.shared.getLocalString(key: "doorbell_notification_switch").capitalized, titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: ringNotificationSwitchValue, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                ringNotificationModule.append(ringNotificationModuleModel)
            } else if name == "doorbellPressNotifyType" {
                let notiModeValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                let notiModeContentKey = tool.getModifiableAttributeTypeName(currentType: .NotiMode) + "_options_" + (notiModeValue)
                var isInteractiveHidden = false
                if isRingNotiOpen == true {
                    isInteractiveHidden = false
                    let allCase = tool.getEnumCases(currentType: .NotiMode, modifiableAttributeModel: attrModel ?? A4xDeviceSettingModifiableAttributesModel())
                    notificationModeModuleModel = tool.createMuduleModel(moduleType: .Enumeration, currentType: .NotiMode, title: A4xBaseManager.shared.getLocalString(key: "doorbell_notification_mode").capitalized, titleContent: A4xBaseManager.shared.getLocalString(key: notiModeContentKey), isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: isInteractiveHidden, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: allCase, iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                    if allCase.count > 0 {
                        
                        ringNotificationModule.append(notificationModeModuleModel)
                    }
                }
            }
        }
        return tool.sortModuleArray(moduleArray: ringNotificationModule)
    }
    
    
    
    private func getMergePushCases() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var mergeModule : Array<A4xDeviceSettingModuleModel> = []
    
        let messageMergeSwitch = self.mergePushModel?.messageMergeSwitch
        var isSwitchOpen = true
        if messageMergeSwitch == 1 {
            isSwitchOpen = true
        } else {
            isSwitchOpen = false
        }
        let mergeModuleModel = tool.createMuduleModel(moduleType: .Switch, currentType: .PushMerge, title: A4xBaseManager.shared.getLocalString(key: "merge_push"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: true, content: A4xBaseManager.shared.getLocalString(key: "merge_push_tips"), isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: isSwitchOpen, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
        mergeModule = [mergeModuleModel]
        
        return mergeModule
    }
    
    
    private func getDevicePirAICases() -> Array<A4xDeviceSettingModuleModel> {
        var aiModule : Array<A4xDeviceSettingModuleModel> = []
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        
        let tool = A4xDeviceSettingModuleTool()
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            if name == "pirAi" {
                let options = attrModel?.options
                
                let optionsArray = tool.getValueOrOption(anyCodable: options ?? ModifiableAnyAttribute()) as? [A4xDeviceSettingUnitModel]
                let pirAIModel = optionsArray?[0]
                
                
                
            }
        }
        
        
        return aiModule
    }
    
    
    private func getNotiConfigCases(isVip: Bool) -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var notiConfigModule : Array<A4xDeviceSettingModuleModel> = []
        
        var activityZoneModuleModel = A4xDeviceSettingModuleModel()
        if isVip == true {
            let azCountString = (self.deviceModel?.zonePointList?.count ?? 0) as Int
            let azContent = A4xBaseManager.shared.getLocalString(key: "number_az", param: [String(azCountString)])
            
            let azTips = A4xBaseManager.shared.getLocalString(key: "activity_zone_tips", param: [A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 0)])
            activityZoneModuleModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .ActivityZone, title: A4xBaseManager.shared.getLocalString(key: "activity_zones"), titleContent: azContent, isShowTitleDescription: true, titleDescription: azTips, subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
        }
        
        let contentAnalysisModuleModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .ContentAnalysis, title: A4xBaseManager.shared.getLocalString(key: "ai_filter"), titleContent: "", isShowTitleDescription: true, titleDescription: A4xBaseManager.shared.getLocalString(key: "ai_filter_des"), subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: true, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
        if isVip == true {
            notiConfigModule = [activityZoneModuleModel, contentAnalysisModuleModel]
        } else {
            notiConfigModule = [contentAnalysisModuleModel]
        }
        
        
        var personModuleModel : A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
        
        var petModuleModel : A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
        
        var vehicleModuleModel : A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
        
        var packageModuleModel : A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
        
        var otherModuleModel : A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
        
        
        for i in 0..<(self.analysisModels?.count ?? 0) {
            
            let analysisModel = self.analysisModels?.getIndex(i)
            let checked = analysisModel?.checked ?? false
            let eventObject = analysisModel?.eventObject
            if eventObject == "person"
            {
                
                personModuleModel = tool.createMuduleModel(moduleType: .ContentSwitch, currentType: .PersonNoti, title: A4xBaseManager.shared.getLocalString(key: "notification_detection_people"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: true, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: checked, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "main_libary_people", buttonTitle: "", leftImage: "", rightImage: "")
            } else if eventObject == "pet" {
                
                petModuleModel = tool.createMuduleModel(moduleType: .ContentSwitch, currentType: .PetNoti, title: A4xBaseManager.shared.getLocalString(key: "ai_pet"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: true, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: checked, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "main_libary_pet", buttonTitle: "", leftImage: "", rightImage: "")
            } else if eventObject == "vehicle" {
                
                vehicleModuleModel = tool.createMuduleModel(moduleType: .ContentSwitch, currentType: .VehicleNoti, title: A4xBaseManager.shared.getLocalString(key: "ai_car"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: true, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: checked, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "main_libary_vehicle", buttonTitle: "", leftImage: "", rightImage: "")
            } else if eventObject == "package" {
                
                packageModuleModel = tool.createMuduleModel(moduleType: .ContentSwitch, currentType: .PackageNoti, title: A4xBaseManager.shared.getLocalString(key: "package_tag"), titleContent: "", isShowTitleDescription: true, titleDescription: A4xBaseManager.shared.getLocalString(key: "smart_push_package_des"), subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: true, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: checked, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "main_libary_package", buttonTitle: "", leftImage: "", rightImage: "")
            }
        }
        
        if self.isShowVehicleTag == false {
            
            
            let vehicleSubModuleModel1 = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .VehicleNotiMark, title: A4xBaseManager.shared.getLocalString(key: "familiar_vehicle"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: true, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
            vehicleModuleModel.subModuleModels = [vehicleSubModuleModel1]
            vehicleModuleModel.cellHeight = tool.getCellHeight(moduleModel: vehicleModuleModel)
            vehicleModuleModel.contentHeight = tool.getContentHeight(moduleModel: vehicleModuleModel)
            vehicleModuleModel.moduleHeight = tool.getModuleHeight(moduleModel: vehicleModuleModel)
        }
        
        if self.isShowPackageTag == false {
            
            
            let packageSubModuleModel1 = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .PackageNotiDetection, title: A4xBaseManager.shared.getLocalString(key: "detection_parcel"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: true, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
            packageModuleModel.subModuleModels = [packageSubModuleModel1]
            packageModuleModel.cellHeight = tool.getCellHeight(moduleModel: packageModuleModel)
            packageModuleModel.contentHeight = tool.getContentHeight(moduleModel: packageModuleModel)
            packageModuleModel.moduleHeight = tool.getModuleHeight(moduleModel: packageModuleModel)
        }
        
        
        for j in 0..<(self.notiConfigModelList?.count ?? 0) {
            let notiModel = self.notiConfigModelList?.getIndex(j)
            let name = notiModel?.name
            let choice = notiModel?.choice ?? false
            let subEvent = notiModel?.subEvent
            if name == "person"
            {
                
                if self.isShowPersonTag == true {
                    
                    let personSubModuleModel = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .PersonNoti, title: A4xBaseManager.shared.getLocalString(key: "notifications"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: choice, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                    personModuleModel.subModuleModels = [personSubModuleModel]
                
                    
                    personModuleModel.cellHeight = tool.getCellHeight(moduleModel: personModuleModel)
                    personModuleModel.contentHeight = tool.getContentHeight(moduleModel: personModuleModel)
                    personModuleModel.moduleHeight = tool.getModuleHeight(moduleModel: personModuleModel)
                }
            } else if name == "pet" {
                if self.isShowPetTag == true {
                    
                    let petSubModuleModel = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .PetNoti, title: A4xBaseManager.shared.getLocalString(key: "notifications"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: choice, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                    petModuleModel.subModuleModels = [petSubModuleModel]
                    petModuleModel.cellHeight = tool.getCellHeight(moduleModel: petModuleModel)
                    petModuleModel.contentHeight = tool.getContentHeight(moduleModel: petModuleModel)
                    petModuleModel.moduleHeight = tool.getModuleHeight(moduleModel: petModuleModel)
                }
            } else if name == "vehicle" {
                if self.isShowVehicleTag == true {
                    
                    let vehicleSubModuleModel1 = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .VehicleNotiMark, title: A4xBaseManager.shared.getLocalString(key: "familiar_vehicle"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: true, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                    
                    var vehicleEnterSubModuleModel: A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
                    
                    var vehicleHeldSubModuleModel: A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
                    
                    var vehicleOutSubModuleModel: A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
                    var isSelected = false
                    for k in 0..<(subEvent?.count ?? 0) {
                        let subModel = subEvent?.getIndex(k)
                        let subName = subModel?.name
                        let subChoice = subModel?.choice
                        if subChoice == true {
                            isSelected = true
                        } else {
                            isSelected = false
                        }
                        if subName == "vehicle_enter" {
                            vehicleEnterSubModuleModel = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .VehicleNotiComing, title: A4xBaseManager.shared.getLocalString(key: "vehicle_approaching"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: isSelected, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                        } else if subName == "vehicle_held_up" {
                            vehicleHeldSubModuleModel = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .VehicleNotiParking, title: A4xBaseManager.shared.getLocalString(key: "vehicle_parked"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: isSelected, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                        } else if subName == "vehicle_out" {
                            vehicleOutSubModuleModel = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .VehicleNotiLeaving, title: A4xBaseManager.shared.getLocalString(key: "vehicle_leaving"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: isSelected, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                        }
                    }
                    vehicleModuleModel.subModuleModels = [vehicleSubModuleModel1, vehicleEnterSubModuleModel, vehicleOutSubModuleModel, vehicleHeldSubModuleModel]
                    vehicleModuleModel.cellHeight = tool.getCellHeight(moduleModel: vehicleModuleModel)
                    vehicleModuleModel.contentHeight = tool.getContentHeight(moduleModel: vehicleModuleModel)
                    vehicleModuleModel.moduleHeight = tool.getModuleHeight(moduleModel: vehicleModuleModel)
                }
            } else if name == "package" {
                if self.isShowPackageTag == true {
                    
                    let packageSubModuleModel1 = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .PackageNotiDetection, title: A4xBaseManager.shared.getLocalString(key: "detection_parcel"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: true, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                    
                    var packageDownSubModuleModel: A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
                    
                    var packageUpSubModuleModel: A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
                    
                    var packageExistSubModuleModel: A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
                    var isSelected = false
                    for k in 0..<(subEvent?.count ?? 0) {
                        let subModel = subEvent?.getIndex(k)
                        let subName = subModel?.name
                        let subChoice = subModel?.choice
                        if subChoice == true {
                            isSelected = true
                        } else {
                            isSelected = false
                        }
                        if subName == "package_drop_off" {
                            packageDownSubModuleModel = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .PackageNotiDown, title: A4xBaseManager.shared.getLocalString(key: "package_down"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: isSelected, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                        } else if subName == "package_exist" {
                            packageExistSubModuleModel = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .PackageNotiRetention, title: A4xBaseManager.shared.getLocalString(key: "package_detained"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: isSelected, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                        } else if subName == "package_pick_up" {
                            packageUpSubModuleModel = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .PackageNotiPickUp, title: A4xBaseManager.shared.getLocalString(key: "package_up"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: isSelected, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                        }
                    }
                    packageModuleModel.subModuleModels = [packageSubModuleModel1, packageDownSubModuleModel, packageUpSubModuleModel, packageExistSubModuleModel]
                    packageModuleModel.cellHeight = tool.getCellHeight(moduleModel: packageModuleModel)
                    packageModuleModel.contentHeight = tool.getContentHeight(moduleModel: packageModuleModel)
                    packageModuleModel.moduleHeight = tool.getModuleHeight(moduleModel: packageModuleModel)
                }
            } else if name == "other" {
                
                let otherModuleSubModel = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .OtherNoti, title: A4xBaseManager.shared.getLocalString(key: "notifications"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: true, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: choice, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                otherModuleModel = tool.createMuduleModel(moduleType: .ContentSwitch, currentType: .OtherNoti, title: A4xBaseManager.shared.getLocalString(key: "other"), titleContent: "", isShowTitleDescription: true, titleDescription: A4xBaseManager.shared.getLocalString(key: "smart_push_other_des"), subModuleModels: [otherModuleSubModel], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: true, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "main_libary_other", buttonTitle: "", leftImage: "", rightImage: "")
            }
        }
        
        for i in 0..<(self.analysisModels?.count ?? 0) {
            
            let model = self.analysisModels?.getIndex(i)
            let name = model?.eventObject
            if name == "person" {
                notiConfigModule.append(personModuleModel)
            }
            else if name == "pet" {
                notiConfigModule.append(petModuleModel)
            }
            else if name == "vehicle" {
                notiConfigModule.append(vehicleModuleModel)
            }
            else if name == "package" {
                notiConfigModule.append(packageModuleModel)
            }
        }
        
        for i in 0..<(self.notiConfigModelList?.count ?? 0) {
            let model = self.notiConfigModelList?.getIndex(i)
            let name = model?.name
            if name == "other" {
                notiConfigModule.append(otherModuleModel)
            }
        }
        
        
        let sortedArray = tool.sortModuleArray(moduleArray: notiConfigModule)
        return sortedArray
    }
    
    
    private func getAdvertisementCase() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var advertisementModule : A4xDeviceSettingModuleModel
        
        advertisementModule = tool.createBaseAdvertisementModel(moduleType: .Advertisement, currentType: .Advertising, title: A4xBaseManager.shared.getLocalString(key: "vip_activity_zone_title"), buttonTitle: A4xBaseManager.shared.getLocalString(key: "upgrade_now_btn"), rightImage: "device_set_advertisement")
        return [advertisementModule]
    }
    
    
    private func getAiMotionCase() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        
        let aiMotionSubModule = tool.createMuduleModel(moduleType: .MoreInfo, currentType: .AiMotionNotiButton, title: A4xBaseManager.shared.getLocalString(key: "smart_push"), titleContent: "", isShowTitleDescription: true, titleDescription: A4xBaseManager.shared.getLocalString(key: "smart_push_novip_des"), subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: A4xBaseManager.shared.getLocalString(key: "go_buy_2"), leftImage: "", rightImage: "")
                
        let aiNotiSubModule = tool.createMuduleModel(moduleType: .VipInfo, currentType: .NoVipCloudStrorage, title: A4xBaseManager.shared.getLocalString(key: "dialog_payment_ling_title"), titleContent: "", isShowTitleDescription: true, titleDescription: A4xBaseManager.shared.getLocalString(key: "dialog_payment_ling_content"), subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "local_cloud_notification", buttonTitle: "", leftImage: "member_detail_smart_normail", rightImage: "member_detail_smart_vip")
        
        let azSubModule = tool.createMuduleModel(moduleType: .VipInfo, currentType: .NoVipCloudStrorage, title: A4xBaseManager.shared.getLocalString(key: "activity_zones"), titleContent: "", isShowTitleDescription: true, titleDescription: A4xBaseManager.shared.getLocalString(key: "dialog_payment_zone_content"), subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "local_cloud_area", buttonTitle: "", leftImage: "member_detail_zone_normail", rightImage: "member_detail_zone_vip")
         
        return [aiMotionSubModule, aiNotiSubModule, azSubModule]
    }
    
    
    
    
    //MARK: ----- 页面逻辑跳转 -----
    @objc private func moreInfo() {
        let articleUrl = A4xBaseManager.shared.getArticleUrl(articleId: "1500002012382")
        let viewC = A4xBaseWebViewController(urlString: articleUrl)
        self.navigationController?.pushViewController(viewC, animated: true)
    }
    
    private func toSetViewController() {
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 1)
        guard let device = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceId ?? "") else {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "device_offline", param: [tempString]) + " no data")
            return
        }
        
        if device.online ?? 0 == 1 {
            let vc = A4xDeviceSettingMotionDetecctionViewController()
            vc.deviceModel = self.deviceModel
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "device_offline", param: [tempString]))
        }
    }
    

    //MARK: ----- 更新AI的通知开关 -----
    func updateAIConfig(indexPath: IndexPath, index: Int) {
        
        self.isNetWorking = true
        self.getAllCases()
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let tempModuleModel = moduleModel
        
        let subModels = moduleModel?.subModuleModels
        let tempSubModel = subModels?[index]
        tempSubModel?.isSelectionBoxLoading = true
        tempModuleModel?.subModuleModels[index] = tempSubModel ?? A4xDeviceSettingModuleModel()
        self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row] = tempModuleModel ?? A4xDeviceSettingModuleModel()
        self.refreshPushView()
        
        
        var netNotiConfigs = self.notiConfigModelList
        
        let currentType = tempSubModel?.currentType
        let configType = getAIConfigTypeString(currentType: currentType ?? .Normal)
        for i in 0..<(netNotiConfigs?.count ?? 0) {
            let configModel = netNotiConfigs?.getIndex(i)
            let name = configModel?.name
            let subEvent = configModel?.subEvent
            var netSubEvent = subEvent
            if configType == "person" {
                if name == "person" {
                    
                    var tempConfigModel :NotificationConfigBean = configModel ?? NotificationConfigBean()
                    tempConfigModel.choice = !(configModel?.choice ?? false)
                    netNotiConfigs?[i] = tempConfigModel
                }
            } else if configType == "pet" {
                if name == "pet" {
                    
                    var tempConfigModel :NotificationConfigBean = configModel ?? NotificationConfigBean()
                    tempConfigModel.choice = !(configModel?.choice ?? false)
                    netNotiConfigs?[i] = tempConfigModel
                }
            } else if configType == "vehicle_enter" {
                
                if name == "vehicle" {
                    
                    for j in 0..<(subEvent?.count ?? 0) {
                        let subConfigModel = subEvent?.getIndex(j)
                        let subConfigName = subConfigModel?.name
                        if subConfigName == "vehicle_enter" {
                            
                            var tempConfigModel :NotificationConfigBean = subConfigModel ?? NotificationConfigBean()
                            tempConfigModel.choice = !(subConfigModel?.choice ?? false)
                            netSubEvent?[j] = tempConfigModel
                            netNotiConfigs?[i].subEvent = netSubEvent
                            break
                        }
                    }
                }
            } else if configType == "vehicle_held_up" {
                
                if name == "vehicle" {
                    
                    for j in 0..<(subEvent?.count ?? 0) {
                        let subConfigModel = subEvent?.getIndex(j)
                        let subConfigName = subConfigModel?.name
                        if subConfigName == "vehicle_held_up" {
                            
                            var tempConfigModel :NotificationConfigBean = subConfigModel ?? NotificationConfigBean()
                            tempConfigModel.choice = !(subConfigModel?.choice ?? false)
                            netSubEvent?[j] = tempConfigModel
                            netNotiConfigs?[i].subEvent = netSubEvent
                            break
                        }
                    }
                }
            } else if configType == "vehicle_out" {
                
                if name == "vehicle" {
                    
                    for j in 0..<(subEvent?.count ?? 0) {
                        let subConfigModel = subEvent?.getIndex(j)
                        let subConfigName = subConfigModel?.name
                        if subConfigName == "vehicle_out" {
                            
                            var tempConfigModel :NotificationConfigBean = subConfigModel ?? NotificationConfigBean()
                            tempConfigModel.choice = !(subConfigModel?.choice ?? false)
                            netSubEvent?[j] = tempConfigModel
                            netNotiConfigs?[i].subEvent = netSubEvent
                            break
                        }
                    }
                }
            } else if configType == "package_drop_off" {
                
                if name == "package" {
                    
                    for j in 0..<(subEvent?.count ?? 0) {
                        let subConfigModel = subEvent?.getIndex(j)
                        let subConfigName = subConfigModel?.name
                        if subConfigName == "package_drop_off" {
                            
                            var tempConfigModel :NotificationConfigBean = subConfigModel ?? NotificationConfigBean()
                            tempConfigModel.choice = !(subConfigModel?.choice ?? false)
                            netSubEvent?[j] = tempConfigModel
                            netNotiConfigs?[i].subEvent = netSubEvent
                            break
                        }
                    }
                }
            } else if configType == "package_exist" {
                
                if name == "package" {
                    
                    for j in 0..<(subEvent?.count ?? 0) {
                        let subConfigModel = subEvent?.getIndex(j)
                        let subConfigName = subConfigModel?.name
                        if subConfigName == "package_exist" {
                            
                            var tempConfigModel :NotificationConfigBean = subConfigModel ?? NotificationConfigBean()
                            tempConfigModel.choice = !(subConfigModel?.choice ?? false)
                            netSubEvent?[j] = tempConfigModel
                            netNotiConfigs?[i].subEvent = netSubEvent
                            break
                        }
                    }
                }
            } else if configType == "package_pick_up" {
                
                if name == "package" {
                    
                    for j in 0..<(subEvent?.count ?? 0) {
                        let subConfigModel = subEvent?.getIndex(j)
                        let subConfigName = subConfigModel?.name
                        if subConfigName == "package_pick_up" {
                            
                            var tempConfigModel :NotificationConfigBean = subConfigModel ?? NotificationConfigBean()
                            tempConfigModel.choice = !(subConfigModel?.choice ?? false)
                            netSubEvent?[j] = tempConfigModel
                            netNotiConfigs?[i].subEvent = netSubEvent
                            break
                        }
                    }
                }
            } else if configType == "other" {
                if name == "other" {
                    
                    var tempConfigModel :NotificationConfigBean = configModel ?? NotificationConfigBean()
                    tempConfigModel.choice = !(configModel?.choice ?? false)
                    netNotiConfigs?[i] = tempConfigModel
                }
            }
        }
   
        
        for i in 0..<(netNotiConfigs?.count ?? 0) {
            let model = netNotiConfigs?.getIndex(i)
            
        }
        let datas = self.getNetNotiConfig(models: netNotiConfigs ?? [])
        weak var weakSelf = self
        self.updateFilterSetting(datas: datas, models: netNotiConfigs ?? []) { isComple in
            weakSelf?.isNetWorking = false
            if isComple == true {
                self.notiConfigModelList = netNotiConfigs
            } else {
                tempSubModel?.isSelectionBoxLoading = false
                tempModuleModel?.subModuleModels[index] = tempSubModel ?? A4xDeviceSettingModuleModel()
                self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row] = tempModuleModel ?? A4xDeviceSettingModuleModel()
            }
            weakSelf?.getAllCases()
            weakSelf?.refreshPushView()
        }
    }
    
    private func getAIConfigTypeString(currentType: A4xDeviceSettingCurrentType) -> String {
        var string = ""
        switch currentType {
        case .PersonNoti:
            string = "person"
        case .PetNoti:
            string = "pet"
        case .VehicleNotiComing:
            string = "vehicle_enter"
        case .VehicleNotiParking:
            string = "vehicle_held_up"
        case .VehicleNotiLeaving:
            string = "vehicle_out"
        case .PackageNotiDown:
            string = "package_drop_off"
        case .PackageNotiRetention:
            string = "package_exist"
        case .PackageNotiPickUp:
            string = "package_pick_up"
        case .OtherNoti:
            string = "other"
        default:
            string = ""
        }
        return string
    }
    
    
    func getNetNotiConfig(models:  [NotificationConfigBean]) -> [String : [String]]
    {
        var allData : [String : [String]] = [:]
        var peopleArray : [String] = []
        var petArray : [String] = []
        var vehicleArray : [String] = []
        var packageArray : [String] = []
        var otherArray : [String] = []
        
        for i in 0..<models.count {
            let model = models.getIndex(i)
            let name = model?.name
            let choice = model?.choice
            let subEvents = model?.subEvent
            if name == "person" {
                if choice == true {
                    peopleArray = []
                    allData["person"] = peopleArray
                }
            } else if name == "pet" {
                if choice == true {
                    petArray = []
                    allData["pet"] = petArray
                }
            } else if name == "vehicle" {
                for j in 0..<(subEvents?.count ?? 0) {
                    let subModel = subEvents?.getIndex(j)
                    let subName = subModel?.name
                    let subChoice = subModel?.choice
                    if subName == "vehicle_enter"
                    {
                        if subChoice == true {
                            vehicleArray.append("vehicle_enter")
                        }
                    } else if subName == "vehicle_held_up" {
                        if subChoice == true {
                            vehicleArray.append("vehicle_held_up")
                        }
                    } else if subName == "vehicle_out" {
                        if subChoice == true {
                            vehicleArray.append("vehicle_out")
                        }
                    }
                }
                allData["vehicle"] = vehicleArray
            } else if name == "package" {
                for j in 0..<(subEvents?.count ?? 0) {
                    let subModel = subEvents?.getIndex(j)
                    let subName = subModel?.name
                    let subChoice = subModel?.choice
                    if subName == "package_drop_off"
                    {
                        if subChoice == true {
                            packageArray.append("package_drop_off")
                        }
                    } else if subName == "package_exist" {
                        if subChoice == true {
                            packageArray.append("package_exist")
                        }
                    } else if subName == "package_pick_up" {
                        if subChoice == true {
                            packageArray.append("package_pick_up")
                        }
                    }
                }
                allData["package"] = packageArray
            } else if name == "other" {
                if choice == true {
                    otherArray = []
                    allData["other"] = otherArray
                }
            }
        }
        //
        return allData
    }
    
    
    func updateFilterSetting(datas: [String : [String]], models:  [NotificationConfigBean], comple: @escaping (Bool)-> Void) {
        
        guard let userId = A4xUserDataHandle.Handle?.loginModel?.id else {
            comple(false)
            return
        }
        
        guard let deviceId = self.deviceId else {
            comple(false)
            return
        }
        
        let configBean = self.datasToDetaiBean(datas: datas)
        DeviceAICore.getInstance().updateMessageNotification(serialNumber: deviceId, bean: configBean) { code, message in
            comple(true)
        } onError: { code, message in
            comple(false)
        }
    }
    
    private func datasToDetaiBean(datas: [String : [String]]) -> NotificationDetailBean {
        
        var detailBean = NotificationDetailBean()
        
        let keys = Array(datas.keys)
        if keys.contains("person") {
            detailBean.person = []
        }
        
        if keys.contains("pet") {
            detailBean.pet = []
        }
        
        if keys.contains("other") {
            detailBean.other = []
        }
        
        var vehicleArray : [String] = []
        if keys.contains("vehicle") {
            let vehicleValues = datas["vehicle"]
            if (vehicleValues?.count ?? 0) > 0 {
                for i in 0..<(vehicleValues?.count ?? 0) {
                    let vehicleValue = vehicleValues?.getIndex(i)
                    if vehicleValue == "vehicle_enter" || vehicleValue == "vehicle_held_up" || vehicleValue == "vehicle_out" {
                        vehicleArray.append(vehicleValue ?? "")
                    }
                }
            } else {
                vehicleArray = []
            }
        }
        detailBean.vehicle = vehicleArray
        
        var packageArray : [String] = []
        if keys.contains("package") {
            let packageValues = datas["package"]
            if (packageValues?.count ?? 0) > 0 {
                for i in 0..<(packageValues?.count ?? 0) {
                    let packageValue = packageValues?.getIndex(i)
                    if packageValue == "package_drop_off" || packageValue == "package_pick_up" || packageValue == "package_exist" {
                        packageArray.append(packageValue ?? "")
                    }
                }
            } else {
                packageArray = []
            }
        }
        detailBean.package = packageArray
        return detailBean
    }
    
    
    //MARK: ----- 更新AiSwitch开关 -----
    private func updateAnalysisEventConfig(indexPath: IndexPath, isOn: Bool) {
        self.isNetWorking = true
        self.getAllCases()
        var analysisListModels : [AnalysisModelBean] = []
        analysisListModels = self.analysisModels ?? []
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        
        let tempModuleModel = moduleModel
        tempModuleModel?.isSwitchLoading = true
        self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row] = tempModuleModel ?? A4xDeviceSettingModuleModel()
        self.refreshPushView()
        
        let currentType = moduleModel?.currentType
        if currentType == .PersonNoti {
            self.isShowPersonTag = isOn
                 
        } else if currentType == .PetNoti {
            self.isShowPetTag = isOn
                 
        } else if currentType == .VehicleNoti {
            self.isShowVehicleTag = isOn
                 
        } else if currentType == .PackageNoti {
            self.isShowPackageTag = isOn
                 
        }
        
        if analysisListModels.count > 0 {
            for i in 0..<analysisListModels.count {
                let analysisModel = analysisListModels.getIndex(i)
                var tempAnalysisModel = analysisModel ?? AnalysisModelBean()
                if currentType == .PersonNoti {
                    if tempAnalysisModel.eventObject == "person" {
                        tempAnalysisModel.checked = isOn
                        analysisListModels[i] = tempAnalysisModel
                    }
                } else if currentType == .PetNoti {
                    if tempAnalysisModel.eventObject == "pet" {
                        tempAnalysisModel.checked = isOn
                        analysisListModels[i] = tempAnalysisModel
                    }
                } else if currentType == .VehicleNoti {
                    if tempAnalysisModel.eventObject == "vehicle" {
                        tempAnalysisModel.checked = isOn
                        analysisListModels[i] = tempAnalysisModel
                    }
                } else if currentType == .PackageNoti {
                    if tempAnalysisModel.eventObject == "package" {
                        tempAnalysisModel.checked = isOn
                        analysisListModels[i] = tempAnalysisModel
                    }
                }
            }
        }
        weak var weakSelf = self
        
        DeviceAICore.getInstance().updateAnalysisEventConfig(beans: analysisListModels, serialNumber: self.deviceId ?? "") { code, message in
            guard let userId = A4xUserDataHandle.Handle?.loginModel?.id else {
                return
            }
            
            DeviceAIUtil.queryMessageNotification(deviceId: weakSelf?.deviceId ?? "") { code, message, model in
                if code == 0 {
                    if model?.list?.count ?? 0 > 0 {
                        weakSelf?.notiConfigModelList = model?.list
                        weakSelf?.analysisModels = analysisListModels
                        weakSelf?.getVipAndAttrInfo()
                    }
                } else {
                    weakSelf?.view.makeToast(A4xAppErrorConfig(code: code).message())
                    tempModuleModel?.isSwitchLoading = false
                    weakSelf?.tableViewPresenter?.allCases?[indexPath.section][indexPath.row] = tempModuleModel ?? A4xDeviceSettingModuleModel()
                    weakSelf?.refreshPushView()
                }
            }












        } onError: { code, message in
            weakSelf?.view.makeToast(message)
            tempModuleModel?.isSwitchLoading = false
            weakSelf?.tableViewPresenter?.allCases?[indexPath.section][indexPath.row] = tempModuleModel ?? A4xDeviceSettingModuleModel()
            weakSelf?.refreshPushView()
        }
    }
    
    
    private func updateAnalysisEventConfig(list: [AnalysisModelBean], deviceId: String) {
        
    }
    
    
    
    //MARK: ----- 更新推送合并 -----
    
    private func showPushMergeAlert(indexPath: IndexPath, isOn: Bool) {
        
        weak var weakSelf = self
        if isOn == true { 
            self.updatePushMerge(indexPath: indexPath, isOn: isOn)
        } else { 
            var config = A4xBaseAlertAnimailConfig()
            config.leftbtnBgColor = .white
            config.leftTitleColor = ADTheme.C1
            config.rightbtnBgColor = .white
            config.rightTextColor = ADTheme.Theme

            let alert = A4xBaseAlertView(param: config, identifier: "Merge push")
            alert.title = A4xBaseManager.shared.getLocalString(key: "close_combiend")
            alert.message  = A4xBaseManager.shared.getLocalString(key: "close_combiend_tips")
            alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "confirm")
            alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
            weak var weakSelf = self
            alert.leftButtonBlock = { 
                weakSelf?.updatePushMerge(indexPath: indexPath, isOn: isOn)
            }
            alert.rightButtonBlock = { 
                let model = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
                let tempModel = model
                tempModel?.isSwitchLoading = false
                tempModel?.isSwitchOpen = true
                weakSelf?.refreshPushView()
            }
            alert.show()
        }
    }
    
    private func updatePushMerge(indexPath: IndexPath, isOn: Bool)
    {
        weak var weakSelf = self
        let model = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let tempModel = model
        tempModel?.isSwitchLoading = true
        self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row] = tempModel ?? A4xDeviceSettingModuleModel()
        self.refreshPushView()
        
        var messageMergeSwitch = 0
        if isOn == true
        {
            messageMergeSwitch = 1
        } else {
            messageMergeSwitch = 0
        }
        
        DeviceAICore.getInstance().updateMergePushData(isOpen: messageMergeSwitch) { code, message in
            
            weakSelf?.mergePushModel?.messageMergeSwitch = messageMergeSwitch
            tempModel?.isSwitchLoading = false
            tempModel?.isSwitchOpen = isOn
            
            
            self.mergePushModel?.messageMergeSwitch = messageMergeSwitch
            weakSelf?.tableViewPresenter?.allCases?[indexPath.section][indexPath.row] = tempModel ?? A4xDeviceSettingModuleModel()
            weakSelf?.refreshPushView()
        } onError: { code, message in
            weakSelf?.tableViewPresenter?.allCases?[indexPath.section][indexPath.row] = tempModel ?? A4xDeviceSettingModuleModel()
            weakSelf?.refreshPushView()
        }
    }
    
    //MARK: ----- 更新枚举类型数据 -----
    
    @objc private func updateEnumValue(currentType: A4xDeviceSettingCurrentType, value: String) {
        var model = ModifiableAttributes()
        switch currentType {
        case .NotiMode:
            model.name = "doorbellPressNotifyType"
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
                
                weakSelf?.getVipAndAttrInfo()
            } else {
                //
                UIApplication.shared.keyWindow?.makeToast(message)
            }
        }
    }
    
    
    @objc private func updateSwitch(currentType: A4xDeviceSettingCurrentType, enable: Bool) {
        self.updateLocalSwitchCase(currentType: currentType, isOpen: false, isLoading: true)
        self.tableView.reloadData()
        var model = ModifiableAttributes()
        switch currentType {
        case .RingNoti:
            model.name = "doorbellPressNotifySwitch"
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
                
                weakSelf?.getVipAndAttrInfo()
            } else {
                
                weakSelf?.updateLocalSwitchCase(currentType: currentType, isOpen: !enable, isLoading: false)
                weakSelf?.tableView.reloadData()
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
  
    //MARK: ----- A4xDeviceSettingModuleTableViewCellDelegate -----
    func A4xDeviceSettingModuleTableViewCellSwitchDidClick(indexPath: IndexPath, isOn: Bool)
    {
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .RingNoti:
            
            self.updateSwitch(currentType: currentType ?? .RingNoti, enable: isOn)
            break
        case .NotiMode:
            //
            break
        case .PushMerge:
            
            self.showPushMergeAlert(indexPath: indexPath, isOn: isOn)
            break
        case .PersonNoti:
            fallthrough
        case .PetNoti:
            //
            fallthrough
        case .VehicleNoti:
            //
            fallthrough
        case .PackageNoti:
            self.updateAnalysisEventConfig(indexPath: indexPath, isOn: isOn)
            //
            break

        default:
            break
        }
    }
    
    func A4xDeviceSettingModuleTableViewCellSelectionBoxDidClick(indexPath: IndexPath, index: Int)
    {
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let subModel = moduleModel?.subModuleModels[index]
        let currentType = subModel?.currentType
        switch currentType {

        case .PersonNoti:
            
            fallthrough
        case .PetNoti:
            
            fallthrough
        case .VehicleNotiComing:
            
            fallthrough
        case .VehicleNotiParking:
            
            fallthrough
        case .VehicleNotiLeaving:
            
            fallthrough
        case .PackageNotiDown:
            
            fallthrough
        case .PackageNotiPickUp:
            
            fallthrough
        case .PackageNotiRetention:
            
            fallthrough
        case .OtherNoti:
            
            self.updateAIConfig(indexPath: indexPath, index: index)
            break
        case .VehicleNotiMark:
            
            self.pushA4xNotificationMarkVehicleViewController()
            break
        case .PackageNotiDetection:
            
            self.pushA4xNotificationSettingGuideViewController()
            break
        default:
            break
        }
    }
    
    
    func A4xDeviceSettingModuleTableViewCellDidClick(indexPath: IndexPath)
    {
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .NotiMode:
            
            let tool = A4xDeviceSettingModuleTool()
            let typeName = tool.getModifiableAttributeTypeName(currentType: currentType ?? .PirSwitch)
            var modifiableAttributesModel = A4xDeviceSettingModifiableAttributesModel()
            for i in 0..<(modifiableAttributes?.count ?? 0) {
                let attrModel = modifiableAttributes?.getIndex(i)
                let name = attrModel?.name
                if name == typeName {
                    modifiableAttributesModel = attrModel ?? A4xDeviceSettingModifiableAttributesModel()
                }
            }
            let enumAlert = A4xDeviceSettingEnumAlertView.init(frame: self.view.bounds, currentType: currentType ?? .NotiMode, allCases: moduleModel?.enumDataSource ?? [])
            enumAlert.delegate = self
            enumAlert.showAlert()
        case .ActivityZone:
            
            let vc = A4xActivityZoneViewController()
            vc.deviceModel = self.deviceModel
            self.navigationController?.pushViewController(vc, animated: true)
        case .Advertising:
            
            
            
            break
        default:
            break
        }
    }
    
    
    func A4xDeviceSettingModuleTableViewCellButtonDidClick(indexPath: IndexPath)
    {
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .AiMotionNotiButton:
            fallthrough
        case .Advertising:
            break
        default:
            break
        }
    }
    

    func A4xDeviceSettingModuleTableViewCellSliderDidDrag(value: Float, indexPath: IndexPath)
    {
        
    }
    
    //MARK: ----- A4xDeviceSettingEnumAlertViewDelegate -----
    func A4xDeviceSettingEnumAlertViewCellDidClick(currentType: A4xDeviceSettingCurrentType, enumModel: A4xDeviceSettingEnumAlertModel) {
        
        self.updateEnumValue(currentType: currentType, value: enumModel.requestContent ?? "")
        
    }

    //MARK: ----- 页面跳转逻辑 -----

    func pushA4xNotificationMarkVehicleViewController() {
        
    }
    
    
    func pushA4xNotificationSettingGuideViewController()
    {
        
        
    }

}



