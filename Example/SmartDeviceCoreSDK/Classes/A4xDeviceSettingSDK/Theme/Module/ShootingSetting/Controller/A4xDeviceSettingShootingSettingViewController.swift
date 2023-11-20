//


//

//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingShootingSettingViewController: A4xBaseViewController, A4xDeviceSettingModuleTableViewCellDelegate, A4xDeviceSettingEnumAlertViewDelegate {
    
    var viewModel : A4xDeviceSettingShootingSettingViewModel? = A4xDeviceSettingShootingSettingViewModel()
    
    
    var deviceModel: DeviceBean?
    
    var tableViewPresenter : A4xDeviceSettingTableViewPresenter?
    
    //MARK: ----- UI组件 -----
    lazy private var tableView: UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped);
        temp.backgroundColor = UIColor.clear
        //temp.sectionHeaderHeight = A4xDeviceSettingModuleCellTopPadding
        temp.separatorInset = UIEdgeInsets.zero
        temp.separatorColor = UIColor.clear
        temp.separatorStyle = .none
        temp.accessibilityIdentifier = "A4xDeviceSettingAlarmSettingViewController_tableView"
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel = A4xDeviceSettingShootingSettingViewModel()
        
        self.viewModel?.allCases?.removeAll()
        
        if self.deviceModel?.apModeType == .AP {
            // 这里是给AP的数据源赋值
            self.deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: self.deviceModel?.serialNumber ?? "", modeType: .AP)
            self.viewModel?.deviceModel = self.deviceModel
            self.viewModel?.getApAllCases()
            self.tableViewReloadData()
        } else {
            weak var weakSelf = self
            // 这一行是Wifi下设备的数据源
            self.viewModel?.deviceModel = self.deviceModel
            self.viewModel?.getDeviceInfoFromNetwork { code in
                if code == 0 {
                    NSLog("当前数据源: \(weakSelf?.viewModel?.allCases)")
                    weakSelf?.tableViewReloadData()
                } else {
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadNavtion()
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "recording_setting")
        self.tableView.isHidden = false
        
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
    

    //MARK: ----- A4xDeviceSettingModuleTableViewCellDelegate -----
    
    func A4xDeviceSettingModuleTableViewCellButtonDidClick(indexPath: IndexPath)
    {
        
    }
    
    
    func A4xDeviceSettingModuleTableViewCellSwitchDidClick(indexPath: IndexPath, isOn: Bool)
    {
        
        let allCase = self.viewModel?.allCases
        let moduleModel = allCase?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .PirCooldownSwitch:
            fallthrough
        case .SDCardCooldownSwitch:
            
            self.viewModel?.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: isOn, isLoading: true)
            self.tableViewReloadData()
            
            weak var weakSelf = self
            self.viewModel?.updateSwitch(currentType: currentType ?? .PirSwitch, enable: isOn) { code, message in
                if code == 0 {
                    if self.deviceModel?.apModeType == .AP {
                        weakSelf?.tableViewReloadData()
                    } else {
                        weakSelf?.viewModel?.getDeviceInfoFromNetwork { code in
                            if code == 0 {
                                weakSelf?.tableViewReloadData()
                            } else {
                                weakSelf?.viewModel?.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: !isOn, isLoading: false)
                                weakSelf?.view.makeToast(message)
                                weakSelf?.tableViewReloadData()
                            }
                        }
                    }
                    
                } else {
                    self.viewModel?.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: !isOn, isLoading: false)
                    weakSelf?.tableViewReloadData()
                    weakSelf?.view.makeToast(message)
                }
                
            }
            
            break
        default:
            break
        }
        
    }
    
    
    func A4xDeviceSettingModuleTableViewCellSelectionBoxDidClick(indexPath: IndexPath, index: Int)
    {
        
    }
    
    
    func A4xDeviceSettingModuleTableViewCellDidClick(indexPath: IndexPath)
    {
        
        let allCase = self.viewModel?.allCases
        let moduleModel = allCase?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .SDCardCooldownSeconds:
            fallthrough
        case .SDCardVideoModes:
            fallthrough
        case .PirCooldownTime:
            
            let enumAlert = A4xDeviceSettingEnumAlertView.init(frame: self.view.bounds, currentType: currentType ?? .PirSensitivity, allCases: moduleModel?.enumDataSource ?? [])
            enumAlert.delegate = self
            enumAlert.showAlert()
        default:
            break
        }
    }
    
    
    func A4xDeviceSettingModuleTableViewCellSliderDidDrag(value: Float, indexPath: IndexPath)
    {
        
    }
    
    //MARK: ----- A4xDeviceSettingEnumAlertViewDelegate -----
    func A4xDeviceSettingEnumAlertViewCellDidClick(currentType: A4xDeviceSettingCurrentType, enumModel: A4xDeviceSettingEnumAlertModel) {
        

        weak var weakSelf = self
        self.viewModel?.updateEnumValue(currentType: currentType, value: enumModel.requestContent ?? "") { code, message in
            if code == 0 {
                if self.deviceModel?.apModeType == .AP {
                    // AP模式更新完成直接刷新
                    weakSelf?.tableViewReloadData()
                } else {
                    self.viewModel?.getDeviceInfoFromNetwork { code in
                        if code == 0 {
                            weakSelf?.tableViewReloadData()
                        } else {
                            self.view.makeToast(message)
                            weakSelf?.tableViewReloadData()
                        }
                    }
                }
            } else {
                weakSelf?.tableViewReloadData()
                weakSelf?.view.makeToast(message)
            }
        }
    }
    
    private func tableViewReloadData() {
        self.tableViewPresenter?.allCases = self.viewModel?.allCases
        self.tableView.reloadData()
    }

}
