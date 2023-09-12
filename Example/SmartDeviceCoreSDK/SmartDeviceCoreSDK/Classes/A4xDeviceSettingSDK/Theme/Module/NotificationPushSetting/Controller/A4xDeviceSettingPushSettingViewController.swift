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
    
    
    var notiConfigModelList: [NotificationConfigBean]?
    
    public var deviceAttributeModel : DeviceAttributesBean?
    
    
    var hasVip: Bool = false
    
    var isRequestCompleted : Bool = true
    
    
    var isSupportPirAi: Bool = false
    
    
    var isNetWorking : Bool = false
        
    private var analysisModels:  [AnalysisModelBean]?
    
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
                    weakSelf?.queryAIEventSwitchData()
                })
            }
        }
        
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                weakSelf?.isRequestCompleted = true
                weakSelf?.getAllCases()
                weakSelf?.refreshPushView()
            }
        }
    }

    private func queryAIEventSwitchData() { 
        weak var weakSelf = self
        DeviceAICore.getInstance().getAnalysisEventConfig(serialNumber: self.deviceModel?.serialNumber ?? "") { code, message, models in
            weakSelf?.group.leave()
            weakSelf?.analysisModels = models
        } onError: { code, message in
            weakSelf?.group.leave()
            weakSelf?.view.makeToast(message)
        }
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

    private func getAllCases() {
                
        var allModels : Array<Array<A4xDeviceSettingModuleModel>> = []
        if self.hasVip == true {
            let notiConfigModels = self.getNotiConfigCases(isVip: self.hasVip)
            allModels.append(notiConfigModels)
            
        } else {
            
            if self.isSupportPirAi == true {
                let notiConfigModels = self.getNotiConfigCases(isVip: self.hasVip)
                allModels.append(notiConfigModels)
                
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

            weakSelf?.analysisModels = analysisListModels
            weakSelf?.getVipAndAttrInfo()
            
        } onError: { code, message in
            weakSelf?.view.makeToast(message)
            tempModuleModel?.isSwitchLoading = false
            weakSelf?.tableViewPresenter?.allCases?[indexPath.section][indexPath.row] = tempModuleModel ?? A4xDeviceSettingModuleModel()
            weakSelf?.refreshPushView()
        }
    }
    
   
  
    //MARK: ----- A4xDeviceSettingModuleTableViewCellDelegate -----
    func A4xDeviceSettingModuleTableViewCellSwitchDidClick(indexPath: IndexPath, isOn: Bool)
    {
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
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

    }
    
    
    func A4xDeviceSettingModuleTableViewCellDidClick(indexPath: IndexPath)
    {
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
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
        
    }
}



