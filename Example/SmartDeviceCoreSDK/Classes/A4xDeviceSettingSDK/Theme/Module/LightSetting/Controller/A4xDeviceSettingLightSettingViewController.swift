//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public class A4xDeviceSettingLightSettingViewController: A4xBaseViewController, A4xDeviceSettingModuleTableViewCellDelegate, A4xDeviceSettingEnumAlertViewDelegate {

    
    var deviceModel: DeviceBean?
    
    var tableViewPresenter : A4xDeviceSettingTableViewPresenter?
    
    var viewModel : A4xDeviceSettingLightSettingViewModel?
    
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
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel = A4xDeviceSettingLightSettingViewModel()
        
        self.viewModel?.allCases?.removeAll()
        
        weak var weakSelf = self
        
        self.viewModel?.deviceModel = self.deviceModel
        self.viewModel?.getDeviceInfoFromNetwork { code in
            if code == 0 {
                
                weakSelf?.tableViewReloadData()
            } else {
                
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadNavtion()
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "light_setting") 
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
    
    
    private func tableViewReloadData() {
        self.tableViewPresenter?.allCases = self.viewModel?.allCases
        self.tableView.reloadData()
    }
    
    //MARK: ----- A4xDeviceSettingModuleTableViewCellDelegate -----
    
    public func A4xDeviceSettingModuleTableViewCellButtonDidClick(indexPath: IndexPath)
    {
        
        
        let allCase = self.viewModel?.allCases
        let moduleModel = allCase?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        
        
    }
    
    
    public func A4xDeviceSettingModuleTableViewCellSwitchDidClick(indexPath: IndexPath, isOn: Bool)
    {
        
        let allCase = self.viewModel?.allCases
        self.tableViewPresenter?.allCases = allCase
        let moduleModel = allCase?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .RecLampSwitch:
            fallthrough
        case .AlarmFlashSwitch:
            fallthrough
        case .NightVisionSwitch:
            
            self.viewModel?.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: isOn, isLoading: true)
            self.tableViewReloadData()
            
            weak var weakSelf = self
            self.viewModel?.updateSwitch(currentType: currentType ?? .PirSwitch, enable: isOn) { code, message in
                if code == 0 {
                    weakSelf?.viewModel?.getDeviceInfoFromNetwork { code in
                        if code == 0 {
                            //self.viewModel.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: isOn, isLoading: false)
                            
                            weakSelf?.tableViewReloadData()
                        } else {
                            weakSelf?.viewModel?.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: !isOn, isLoading: false)
                            weakSelf?.view.makeToast(message)
                            weakSelf?.tableViewReloadData()
                        }
                    }
                    
                } else {
                    weakSelf?.viewModel?.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: !isOn, isLoading: false)
                    weakSelf?.tableViewReloadData()
                    weakSelf?.view.makeToast(message)
                }
                
            }
            
            break
        default:
            break
        }
        
    }
    
    
    public func A4xDeviceSettingModuleTableViewCellSelectionBoxDidClick(indexPath: IndexPath, index: Int)
    {
        
    }
    
    
    public func A4xDeviceSettingModuleTableViewCellDidClick(indexPath: IndexPath)
    {
        
        let allCase = self.viewModel?.allCases
        let moduleModel = allCase?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .NightVisionMode:
            fallthrough
        case .NightVisionSensitivity:
            
            let enumAlert = A4xDeviceSettingEnumAlertView.init(frame: self.view.bounds, currentType: currentType ?? .NotiMode, allCases: moduleModel?.enumDataSource ?? [])
            enumAlert.delegate = self
            enumAlert.showAlert()
            break
        default:
            break
        }
    }
    
    
    public func A4xDeviceSettingModuleTableViewCellSliderDidDrag(value: Float, indexPath: IndexPath)
    {
        
    }
    
    //MARK: ----- A4xDeviceSettingEnumAlertViewDelegate -----
    public func A4xDeviceSettingEnumAlertViewCellDidClick(currentType: A4xDeviceSettingCurrentType, enumModel: A4xDeviceSettingEnumAlertModel) {
        

        weak var weakSelf = self
        self.viewModel?.updateEnumValue(currentType: currentType, value: enumModel.requestContent ?? "") { code, message in
            if code == 0 {
                weakSelf?.viewModel?.getDeviceInfoFromNetwork { code in
                    if code == 0 {
                        //self.viewModel.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: isOn, isLoading: false)
                        weakSelf?.tableViewReloadData()
                    } else {
                        self.view.makeToast(message)
                        weakSelf?.tableViewReloadData()
                    }
                }
            } else {
                weakSelf?.tableViewReloadData()
                weakSelf?.view.makeToast(message)
            }
            
        }
    }
    
}
