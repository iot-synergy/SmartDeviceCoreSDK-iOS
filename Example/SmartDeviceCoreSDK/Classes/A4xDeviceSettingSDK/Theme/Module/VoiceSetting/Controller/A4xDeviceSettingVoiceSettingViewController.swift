//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public class A4xDeviceSettingVoiceSettingViewController: A4xBaseViewController, A4xDeviceSettingModuleTableViewCellDelegate {

    
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
        temp.accessibilityIdentifier = "A4xDeviceSettingVoiceSettingViewController_tableView"
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
        
        
        
        A4xDeviceSettingVoiceSettingViewModel.shared.deviceModel = self.deviceModel
        weak var weakSelf = self
        A4xDeviceSettingVoiceSettingViewModel.shared.getDeviceInfoFromNetwork { code in
            if code == 0 {
                
                weakSelf?.tableViewPresenter?.allCases = A4xDeviceSettingVoiceSettingViewModel.shared.allCases
                weakSelf?.tableView.reloadData()
            } else {
                
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadNavtion()
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "audio_setting") 
        self.tableView.isHidden = false
        
    }
    
    //MARK: ----- UI相关 -----
    
    private func loadNavtion() {
        weak var weakSelf = self
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = {
            
            A4xDeviceSettingVoiceSettingViewModel.shared.backAndSendNotification()
            weakSelf?.navigationController?.popViewController(animated: true)
        }
        
    }
    
    private func tableViewReloadData() {
        self.tableViewPresenter?.allCases = A4xDeviceSettingVoiceSettingViewModel.shared.allCases
        self.tableView.reloadData()
    }
    
    //MARK: ----- A4xDeviceSettingModuleTableViewCellDelegate -----
    
    public func A4xDeviceSettingModuleTableViewCellButtonDidClick(indexPath: IndexPath)
    {
        
        
        let allCase = A4xDeviceSettingVoiceSettingViewModel.shared.allCases
        self.tableViewPresenter?.allCases = allCase
        let moduleModel = allCase?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        
        
    }
    
    
    public func A4xDeviceSettingModuleTableViewCellSwitchDidClick(indexPath: IndexPath, isOn: Bool)
    {
        
        let allCase = A4xDeviceSettingVoiceSettingViewModel.shared.allCases
        self.tableViewPresenter?.allCases = allCase
        let moduleModel = allCase?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .LiveAudio:
            fallthrough
        case .RecordingAudio:
            
            A4xDeviceSettingVoiceSettingViewModel.shared.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: isOn, isLoading: true)
            self.tableViewReloadData()
            
            weak var weakSelf = self
            A4xDeviceSettingVoiceSettingViewModel.shared.updateSwitch(currentType: currentType ?? .PirSwitch, enable: isOn) { code, message in
                if code == 0 {
                    A4xDeviceSettingVoiceSettingViewModel.shared.getDeviceInfoFromNetwork { code in
                        if code == 0 {
                            //A4xDeviceSettingVoiceSettingViewModel.shared.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: isOn, isLoading: false)
                            weakSelf?.tableViewReloadData()
                        } else {
                            A4xDeviceSettingVoiceSettingViewModel.shared.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: !isOn, isLoading: false)
                            weakSelf?.view.makeToast(message)
                            weakSelf?.tableViewReloadData()
                        }
                    }
                } else {
                    A4xDeviceSettingVoiceSettingViewModel.shared.updateLocalSwitchCase(currentType: currentType ?? .PirSwitch, isOpen: !isOn, isLoading: false)
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
        
        let allCase = A4xDeviceSettingVoiceSettingViewModel.shared.allCases
        self.tableViewPresenter?.allCases = allCase
        let moduleModel = allCase?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .DeviceLanguage:
            let vc = A4xDevicesLanguageViewController(deviceModel: self.deviceModel ?? DeviceBean(serialNumber: self.deviceModel?.serialNumber ?? ""))
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .DoorbellRing:
            
            break
        default:
            break
        }
    }
    
    
    public func A4xDeviceSettingModuleTableViewCellSliderDidDrag(value: Float, indexPath: IndexPath)
    {
        
        
        let allCase = A4xDeviceSettingVoiceSettingViewModel.shared.allCases
        self.tableViewPresenter?.allCases = allCase
        let moduleModel = allCase?[indexPath.section][indexPath.row]
        let currentType = moduleModel?.currentType
        switch currentType {
        case .AlarmRingVolume:
            fallthrough
        case .LiveSpeakerVolume:
            fallthrough
        case .VoiceVolume:
            
            self.view.makeToastActivity(title: "loading", completion: { (f) in })
            
            weak var weakSelf = self
            A4xDeviceSettingVoiceSettingViewModel.shared.updateSlider(currentType: currentType ?? .AlarmRingVolume, value: Int(value)) { code, message in
                if code == 0 {
                    A4xDeviceSettingVoiceSettingViewModel.shared.getDeviceInfoFromNetwork { code in
                        weakSelf?.view.hideToastActivity()
                        if code == 0 {
                            weakSelf?.tableViewReloadData()
                        } else {
                            weakSelf?.tableViewReloadData()
                            weakSelf?.view.makeToast(message)
                        }
                    }
                } else {
                    self.view.hideToastActivity()
                    weakSelf?.tableViewReloadData()
                    weakSelf?.view.makeToast(message)
                }
            }
            break
        default:
            break
        }
    }
    

}
