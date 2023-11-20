//


//


//

import UIKit
import SmartDeviceCoreSDK
import A4xLocation
import BindInterface
import Resolver
import BaseUI

class A4xDeviceInformationViewController: A4xBaseViewController, A4xDeviceSettingModuleTableViewCellDelegate, A4xDevicesNameEditViewControllerDelegate {
    
    //MARK: ----- 属性 -----
    
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
    
    public var deviceModel: DeviceBean?
    
    
    public var deviceAttributeModel : DeviceAttributesBean?
    
    
    var tableViewPresenter : A4xDeviceSettingTableViewPresenter?
    
    
    var isAdmin : Bool? = true

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.loadNavtion()
        self.tableView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: self.deviceModel?.serialNumber ?? "", modeType: self.deviceModel?.apModeType ?? .WiFi)
        
        self.getDeviceInfoFromNetwork()
    }
    
    deinit {
        
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: ----- 加载导航 -----
    private func loadNavtion() {
        weak var weakSelf = self
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 1)
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "device_info", param: [tempString]).capitalized
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
    
    //MARK: ----- 更新TableView的UI -----
    private func updateTableViewUI(isComplete: Bool, viewHeight: CGFloat) {
        self.tableView.snp.remakeConstraints { make in
            make.top.equalTo(self.navView!.snp.bottom)
            make.left.width.equalTo(self.view)
            if isComplete == false {
                make.bottom.equalTo(self.view.snp.bottom).offset(-viewHeight)
            } else {
                make.bottom.equalTo(self.view.snp.bottom)
            }
            
        }
    }
    
    
    //MARK: ----- 获取网络请求数据 -----
    private func getDeviceInfoFromNetwork()
    {
        weak var weakSelf = self
        
        DispatchQueue.main.async {
            weakSelf?.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        }
        
        queue.async(group: group, execute: {
            weakSelf?.group.enter()
            weakSelf?.loadAttributesData()
        })

        group.notify(queue: queue) {
            
            DispatchQueue.main.async {
                
                weakSelf?.view.hideToastActivity {
                    weakSelf?.getAllCases()
                    weakSelf?.tableView.reloadData()
                }
                
            }
        }
    }
    
    
    private func loadAttributesData() {
        weak var weakSelf = self
        DeviceSettingCoreUtil.getDeviceAttributes(deviceId: self.deviceModel?.serialNumber ?? "") { code, model, message in
            weakSelf?.group.leave()
            if code == 0 {
                if model.fixedAttributes?.roleName == "admin" {
                    weakSelf?.isAdmin = true
                } else {
                    weakSelf?.isAdmin = false
                }
                weakSelf?.deviceAttributeModel = model
                
                let firmwareStatus = model.realTimeAttributes?.firmwareStatus
                weakSelf?.deviceModel?.upgradeStatus = firmwareStatus ?? 0
                A4xUserDataHandle.Handle?.updateDevice(device: weakSelf?.deviceModel)
                
            } else {
                
            }
        }
    }
    
    //MARK: ----- 根据网络请求结果,处理本地tableview数据源 -----
    private func getAllCases()
    {
        var allModels : Array<Array<A4xDeviceSettingModuleModel>> = []
        
        let deviceInfoModule = self.getdeviceInfoCases()
        allModels.append(deviceInfoModule)
        
        let systemInfoModule = self.getSystemInfoCases()
        allModels.append(systemInfoModule)
        
        let networkInfoModule = self.getNetworkInfoCases()
        allModels.append(networkInfoModule)

        self.tableViewPresenter?.allCases = allModels
    }
    
    
    private func getdeviceInfoCases() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var deviceInfoModule : Array<A4xDeviceSettingModuleModel> = []
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        let fixedAttributes = self.deviceAttributeModel?.fixedAttributes
        
        let realTimeAttributes = self.deviceAttributeModel?.realTimeAttributes
        
        for i in 0..<(modifiableAttributes?.count ?? 0) {
            let attrModel = modifiableAttributes?.getIndex(i)
            let name = attrModel?.name
            let type = attrModel?.type ?? ""


            
            if name == "deviceName" {
                
                let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 1)
                let deviceName = A4xBaseManager.shared.getLocalString(key: "device_name", param: [tempString]).capitalized
                let value = attrModel?.value
                let deviceContentName = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? String ?? ""
                var isInteractiveHidden = false
                if self.isAdmin == true {
                    isInteractiveHidden = false
                } else {
                    isInteractiveHidden = true
                }
                let deviceNameModuleModel = tool.createMuduleModel(moduleType: tool.getModuleType(type: type), currentType: .DeviceName, title: deviceName, titleContent: deviceContentName, isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: isInteractiveHidden, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                deviceInfoModule.append(deviceNameModuleModel)
            } else if name == "location" {
                
                let locationModel = tool.getValueOrOption(anyCodable: attrModel?.value ?? ModifiableAnyAttribute()) as? A4xDeviceSettingUnitModel
                let locationName = locationModel?.text ?? ""
                var isInteractiveHidden = false
                if self.isAdmin == true {
                    isInteractiveHidden = false
                } else {
                    isInteractiveHidden = true
                }
                let useLocationModuleModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .UseLocation, title: A4xBaseManager.shared.getLocalString(key: "location_setting"), titleContent: locationName, isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: isInteractiveHidden, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
                deviceInfoModule.append(useLocationModuleModel)
            }
        }
        
        
        let modelCategory = fixedAttributes?.modelCategory ?? 0
        let titleContent = fixedAttributes?.displayModelNo?.isBlank != true ? fixedAttributes?.displayModelNo : fixedAttributes?.modelNo
        let modelNo = titleContent ?? ""
        if modelNo != ""
        {
            
            let title = A4xBaseManager.shared.getLocalString(key: "model_number", param: [A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: modelCategory)]).capitalized
            let modelNoModuleModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .DeviceType, title: title, titleContent: modelNo, isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: true, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
            deviceInfoModule.append(modelNoModuleModel)
        }
        
        
        let batteryLevel = realTimeAttributes?.batteryLevel ?? 0
        let canStandby = self.deviceAttributeModel?.fixedAttributes?.canStandBy
        if canStandby != 0 {
            
            let title = A4xBaseManager.shared.getLocalString(key: "battery_level").capitalized
            let batteryLevelModuleModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .BatteryLevel, title: title, titleContent: "\(batteryLevel)%", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: true, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
            deviceInfoModule.append(batteryLevelModuleModel)
        }
        
        
        let snNumber = self.deviceAttributeModel?.fixedAttributes?.userSn//.serialNumber
        if snNumber != ""
        {
            
            let title = A4xBaseManager.shared.getLocalString(key: "serial_number")//A4xBaseManager.shared.getLocalString(key: "camera_serial_number", param: [A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: modelCategory)]).capitalized
            let modelSNModuleModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .DeviceSerialNumber, title: title, titleContent: snNumber ?? "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: true, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
            deviceInfoModule.append(modelSNModuleModel)
        }
        
        let sortedDeviceInfoModule = tool.sortModuleArray(moduleArray: deviceInfoModule)
        return sortedDeviceInfoModule
    }
    
    
    private func getSystemInfoCases() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var systemModule : Array<A4xDeviceSettingModuleModel> = []
        
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        let fixedAttributes = self.deviceAttributeModel?.fixedAttributes
        
        let realTimeAttributes = self.deviceAttributeModel?.realTimeAttributes
        
        
        let firmwareId = realTimeAttributes?.firmwareId ?? ""
        let displayGitSha = realTimeAttributes?.displayGitSha ?? ""
        var systemVersion = ""
        if displayGitSha == "" {
            systemVersion = firmwareId
        } else {
            systemVersion = "\(firmwareId)(\(displayGitSha))"
        }
        
        let systemVersionTitle = A4xBaseManager.shared.getLocalString(key: "system_version").capitalized
        let systemVersionModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .SystemVersion, title: systemVersionTitle, titleContent: systemVersion, isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: true, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
        systemModule.append(systemVersionModel)
        
        
        let mcuVersionTitle = A4xBaseManager.shared.getLocalString(key: "mcu_version")
        let mcuNumber = realTimeAttributes?.mcuNumber ?? ""
        if mcuNumber != "" {
            let mcuVersionModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .SystemMCU, title: mcuVersionTitle, titleContent: mcuNumber, isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: true, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
            systemModule.append(mcuVersionModel)
        }
        
        
        let sortedSystemModule = tool.sortModuleArray(moduleArray: systemModule)
        return sortedSystemModule
    }
    
    
    private func getNetworkInfoCases() -> Array<A4xDeviceSettingModuleModel>
    {
        let tool = A4xDeviceSettingModuleTool()
        var networkModule : Array<A4xDeviceSettingModuleModel> = []
        
        
        let modifiableAttributes = self.deviceAttributeModel?.modifiableAttributes
        
        let fixedAttributes = self.deviceAttributeModel?.fixedAttributes
        let modelCategory = fixedAttributes?.modelCategory ?? 0
        
        let realTimeAttributes = self.deviceAttributeModel?.realTimeAttributes
        
        
        let networkName = realTimeAttributes?.networkName ?? ""
        if networkName != "" {
            let wifiTitle = A4xBaseManager.shared.getLocalString(key: "wifi")
            let wifiModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .WifiName, title: wifiTitle, titleContent: networkName, isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: true, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
            networkModule.append(wifiModel)
        }
        
        
        let ipContent = realTimeAttributes?.ip ?? ""
        if ipContent != "" {
            var ipTitle = A4xBaseManager.shared.getLocalString(key: "device_ip", param: [A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: modelCategory)]).capitalized
            ipTitle = ipTitle.replacingOccurrences(of: "Ip", with: "IP")
            let ipModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .IPAddress, title: ipTitle, titleContent: ipContent, isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: true, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
            networkModule.append(ipModel)
        }
        
        let macAddress = fixedAttributes?.macAddress ?? ""
        if macAddress != "" {
            
            let macAddressTitle = A4xBaseManager.shared.getLocalString(key: "mac_address")
            let macAddressModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .WirelessMacAddress, title: macAddressTitle, titleContent: macAddress, isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: true, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
            networkModule.append(macAddressModel)
        }
        
        
        let wiredMacAddress = fixedAttributes?.wiredMacAddress ?? ""
        if wiredMacAddress != "" {
            
            let wiredMacAddressTitle = A4xBaseManager.shared.getLocalString(key: "ethernet_mac_address")
            let wiredMacAddressModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .WiredMacAddress, title: wiredMacAddressTitle, titleContent: wiredMacAddress, isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: true, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
            networkModule.append(wiredMacAddressModel)
        }
        
        if self.isAdmin == true {
            
            let changeNetworkTitle = A4xBaseManager.shared.getLocalString(key: "home_ap_change").capitalized
            let changeNetworkModel = tool.createMuduleModel(moduleType: .ArrowPoint, currentType: .ChangeNetWork, title: changeNetworkTitle, titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
            networkModule.append(changeNetworkModel)
        }
        
        let sortedSystemModule = tool.sortModuleArray(moduleArray: networkModule)
        return sortedSystemModule
    }
    
    
    //MARK: ----- A4xDeviceSettingModuleTableViewCellDelegate -----
    
    func A4xDeviceSettingModuleTableViewCellSwitchDidClick(indexPath: IndexPath, isOn: Bool)
    {
        
    }
    
    
    func A4xDeviceSettingModuleTableViewCellSelectionBoxDidClick(indexPath: IndexPath, index: Int)
    {
        
    }
    
    
    func A4xDeviceSettingModuleTableViewCellDidClick(indexPath: IndexPath)
    {
        
        let moduleModel = self.tableViewPresenter?.allCases?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        if currentType == .ChangeNetWork {
            Resolver.bindImpl.pushBindViewController(bindFromType: .change_wifi, navigationController: self.navigationController)
        } else if currentType == .DeviceName {
            
            let vc = A4xDevicesNameEditViewController() //
            vc.dataSource = self.deviceModel
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else if currentType == .UseLocation {
            
            let vc = A4xDeviceUpdateLocationViewController(type: .device(device: A4xUserDataHandle.Handle?.getDevice(deviceId: deviceModel?.serialNumber ?? "", modeType: deviceModel?.apModeType ?? .WiFi)))
            self.navigationController?.pushViewController(vc, animated: true)
        } else if currentType == .DeviceSerialNumber {
            
            self.copyText(text: moduleModel?.titleContent ?? "")
        }
    }
    
    
    func A4xDeviceSettingModuleTableViewCellButtonDidClick(indexPath: IndexPath)
    {
        
    }
    
    
    func A4xDeviceSettingModuleTableViewCellSliderDidDrag(value: Float, indexPath: IndexPath)
    {
        
    }
    
    
        
    @objc public func copyText(text: String){
        let pboard = UIPasteboard.general
        pboard.string = text
        self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "add_copied_pwd"))
    }
    
    //MARK: ----- A4xDevicesNameEditViewControllerDelegate -----
    
    func A4xDevicesNameEditViewControllerDidEditDeviceName(isComple: Bool, deviceId: String, deviceName: String)
    {
        if isComple == true {
            
            self.getDeviceInfoFromNetwork()
            var tempAttributeModel = self.deviceAttributeModel
            var tempModifiableAttributes = tempAttributeModel?.modifiableAttributes
            for i in 0..<(tempModifiableAttributes?.count ?? 0) {
                let attrModel = tempModifiableAttributes?.getIndex(i)
                let name = attrModel?.name
                if name == "deviceName" {
                    var nameModel = attrModel
                    let anyCodable = ModifiableAnyAttribute()
                    anyCodable.value = nameModel
                    nameModel?.value = anyCodable
                    tempModifiableAttributes?[i] = nameModel ?? A4xDeviceSettingModifiableAttributesModel()
                }
            }
            tempAttributeModel?.modifiableAttributes = tempModifiableAttributes
            self.deviceModel?.deviceName = deviceName
            self.deviceAttributeModel = tempAttributeModel
            self.getAllCases()
            self.tableView.reloadData()
            
        }
    }
}
