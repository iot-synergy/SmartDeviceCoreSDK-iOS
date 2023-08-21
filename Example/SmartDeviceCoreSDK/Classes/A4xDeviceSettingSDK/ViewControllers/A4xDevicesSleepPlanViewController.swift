//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDevicesSleepPlanViewController: A4xBaseViewController {

    //var deviceId: String
    var controlModel: A4xDeviceControlViewModel?
   
    var deviceModel: DeviceBean?
    
    private var cellInfos: [[A4xDevicesSleepPlanModel]]?
    private var editCells: [A4xDevicesSleepPlanEnum] = [] {
        didSet {
            self.reloadData()
        }
    }
    
    private var deviceSetup: Bool = false
    
    init(deviceModel: DeviceBean, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.deviceModel = deviceModel
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNavtion()
        
        self.tableView.isHidden = false
        
        //
        
        self.deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: self.deviceModel?.serialNumber ?? "", modeType: self.deviceModel?.apModeType ?? .WiFi)
        
        
        controlModel = A4xDeviceControlViewModel.loadLocalData(deviceModel: self.deviceModel ?? DeviceBean(serialNumber: self.deviceModel?.serialNumber ?? ""), comple: { [weak self] (error) in
            self?.view.makeToast(error)
            self?.reloadData()
        })
        
        
        //controlModel?.resolution = self.deviceModel?.resolution

//






        
    }
    
    private func reloadData() {
        self.cellInfos = A4xDevicesSleepPlanEnum.cases(setPlanEnable: self.controlModel?.sleepPlanStatus ?? false, deviceModle: self.deviceModel)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //A4xUserDataHandle.Handle?.videoHelper.stopAlive(deviceId: self.deviceId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        getSelectSingleDevice()
        
        //self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        
        controlModel?.getSleepPlanStatus(comple: { [weak self] (error) in
            //self?.view.hideToastActivity()
            self?.view.makeToast(error)
            self?.reloadData()
        })
        



    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "sleep_setting")
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
    }
    
    private lazy var tableView: UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        temp.delegate = self
        temp.dataSource = self
        temp.backgroundColor = UIColor.clear
        temp.tableFooterView = UIView()
        temp.accessibilityIdentifier = "tableView"
        temp.separatorInset = .zero
        temp.separatorStyle = .none
        temp.separatorColor = UIColor.clear
        temp.estimatedRowHeight = 80;
        temp.rowHeight = UITableView.automaticDimension
        temp.showsVerticalScrollIndicator = false
        temp.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20.auto(), right: 0)
        temp.estimatedSectionFooterHeight = 1
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom)
            make.width.equalTo(self.view.snp.width).offset(-32.auto())
            make.centerX.equalTo(self.view.snp.centerX)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        
        return temp
    }()
    
    private func keepDeviceAlive(comple: @escaping (_ isScuess: Bool)->Void) {
        if self.deviceSetup {
            comple(true)
        } else {
            A4xUserDataHandle.Handle?.videoHelper.keepAlive(deviceId: self.deviceModel?.serialNumber ?? "", isHeartbeat: false, comple: { [weak self] (state, flag) in
                self?.deviceSetup = flag
                comple(flag)
            })
        }
    }
    
    private func sleepAlert() {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = UIColor.white
        config.leftTitleColor = UIColor.colorFromHex("#2F3742")
        
        config.rightbtnBgColor = UIColor.white
        config.rightTextColor = ADTheme.Theme
        config.messageColor = UIColor.colorFromHex("#2F3742")
        weak var weakSelf = self
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 1)
        let alert = A4xBaseAlertView(param: config, identifier: "delete device")
        //alert.title = A4xBaseManager.shared.getLocalString(key: "remove_device_title")
        alert.message = A4xBaseManager.shared.getLocalString(key: "sleep_tips", param: [tempString])
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "camera_wake_up")
        alert.rightButtonBlock = {
            weakSelf?.sleepToWakeUP()
        }
        alert.show()
    }
    
    private func sleepToWakeUP() {
        
        self.controlModel?.sleepToWakeUP(enable: false, comple: { [weak self] err in
            if err != nil {
                self?.view.makeToast(err)
            } else {
                self?.deviceModel?.deviceStatus = 0
                let vc = A4xDevicesSleepPlanShowViewController(deviceModel: self?.deviceModel ?? DeviceBean(serialNumber: self?.deviceModel?.serialNumber ?? ""))
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        })
        
    }
    
    private func getSelectSingleDevice(showLoading: Bool = true) {
        if showLoading {
            self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (r) in }
        }
        
        weak var weakSelf = self
        
        DeviceManageUtil.getDeviceSettingInfo(deviceId: deviceModel?.serialNumber ?? "") { (code, msg, model) in
            
            if showLoading {
                weakSelf?.view.hideToastActivity()
            } else {
                weakSelf?.tableView.mj_header?.endRefreshing()
            }
            
            if code == 0 {
                /* 和大列表区别主要是更新以下参数*/
                weakSelf?.deviceModel?.awake = model?.awake ?? 0
                
                weakSelf?.deviceModel?.sdCard = model?.sdCard
                weakSelf?.deviceModel?.packagePush = model?.packagePush
                
                weakSelf?.deviceModel?.antiflickerSupport = model?.antiflickerSupport
                weakSelf?.deviceModel?.displayGitSha = model?.displayGitSha
                weakSelf?.deviceModel?.dormancyPlanSwitch = model?.dormancyPlanSwitch
                
                
                weakSelf?.deviceModel?.deviceStatus = model?.deviceStatus ?? 0
                weakSelf?.deviceModel?.online = model?.online ?? 1
                weakSelf?.deviceModel?.upgradeStatus = model?.upgradeStatus ?? 0
                weakSelf?.deviceModel?.batteryLevel = model?.batteryLevel ?? 0
                weakSelf?.deviceModel?.signalStrength = model?.signalStrength ?? 0
                weakSelf?.deviceModel?.isCharging = model?.isCharging ?? 0
                weakSelf?.deviceModel?.firmwareId = model?.firmwareId
                weakSelf?.deviceModel?.newestFirmwareId = model?.newestFirmwareId
                weakSelf?.deviceModel?.personDetect = model?.personDetect
                weakSelf?.deviceModel?.pushIgnored = model?.pushIgnored
                weakSelf?.deviceModel?.deviceDormancyMessage = model?.deviceDormancyMessage
                
                
                weakSelf?.reloadData()
            } else {
                weakSelf?.view.makeToast(A4xAppErrorConfig(code: code).message())
            }
        }
    }

}

extension A4xDevicesSleepPlanViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sleepPlanModel: A4xDevicesSleepPlanModel = self.cellInfos![indexPath.section][indexPath.row]
        switch sleepPlanModel.type {
        case .sleepPlanOpen:
            return sleepPlanModel.cellHeight ?? 276.5.auto()
        case .sleepPlan:
            fallthrough
        case .setPlan:
            return 60.auto()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellInfos?[section].count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellInfos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var showTips: Bool = false
        let view = UIView()
        showTips = showTips || (section + 1) >= 1
        let sleepPlanModel = cellInfos?.getIndex(section)?.getIndex(0)
        switch sleepPlanModel?.type {
        case .sleepPlan:
            showTips = showTips || !(controlModel?.sleepPlanStatus ?? false)
            break
        default:
            break
        }
        
        if showTips {
            let lable = UILabel()
            lable.textColor = ADTheme.C3
            lable.font = ADTheme.B2
            lable.numberOfLines = 0
            lable.lineBreakMode = .byWordWrapping
            view.addSubview(lable)
            lable.snp.makeConstraints { (make) in
                make.leading.equalTo(15.auto())
                make.width.equalTo(view.snp.width).offset(-30.auto())
                make.bottom.equalTo(view.snp.bottom).offset(-2)
                make.top.equalTo(6.auto())
            }
            
            if sleepPlanModel?.type == .sleepPlan {
                let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 1)
                lable.text = A4xBaseManager.shared.getLocalString(key: "auto_sleep_prompt", param: [tempString])



            }
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sleepPlanModel: A4xDevicesSleepPlanModel = self.cellInfos![indexPath.section][indexPath.row]
        if sleepPlanModel.type == .sleepPlanOpen {
            let identifier = "A4xDevicesSleepPlanOpenCell"
            var tableCell: A4xDevicesSleepPlanOpenCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesSleepPlanOpenCell
            
            if (tableCell == nil) {
                tableCell = A4xDevicesSleepPlanOpenCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            }
            
            var sleepPlanModel = cellInfos![indexPath.section][indexPath.row]
            tableCell?.type = sleepPlanModel.type
            tableCell?.protocol = self
            tableCell?.nameString = sleepPlanModel.title
            
            switch sleepPlanModel.type {
            case .sleepPlanOpen:
                tableCell!.switch = self.deviceModel?.deviceStatus == 3
                sleepPlanModel.cellHeight = tableCell?.getCellHeight() ?? 276.5.auto()
                cellInfos![indexPath.section][indexPath.row] = sleepPlanModel
                break
            default:
                break
            }
            tableCell?.isLoading = editCells.contains(sleepPlanModel.type)
            return tableCell!
            
        } else if sleepPlanModel.type == .sleepPlan {
            let identifier = "A4xDevicesSleepPlanCell"
            var tableCell: A4xDevicesSleepPlanCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesSleepPlanCell
            
            if (tableCell == nil) {
                tableCell = A4xDevicesSleepPlanCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            }
            
            let type = sleepPlanModel.type
            tableCell?.type = type
            tableCell?.protocol = self
            
            switch type {
            case .sleepPlan: 
                tableCell!.switch = (self.controlModel?.sleepPlanStatus ?? false)
            default:
                break
            }
            tableCell?.nameString = sleepPlanModel.title
            tableCell?.isLoading = editCells.contains(type)
            return tableCell!
            
        } else {
            
            let identifier = "A4xDevicesSleepPlanCell"
            var tableCell: A4xDevicesSleepPlanCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesSleepPlanCell
            
            if (tableCell == nil) {
                tableCell = A4xDevicesSleepPlanCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            }
            
            let type = sleepPlanModel.type
            tableCell?.type = type
            tableCell?.protocol = self
            tableCell!.switch = (self.controlModel?.sleepPlanStatus ?? false)
            tableCell!.tipString = " "
            tableCell?.nameString = sleepPlanModel.title
            tableCell?.isLoading = editCells.contains(type)
            return tableCell!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
        cell.clipsToBounds = true
        let count = self.tableView(self.tableView, numberOfRowsInSection: indexPath.section)
        if indexPath.row == count {
            cell.contentView.layer.mask = nil
            return
        }
        let bounds = cell.contentView.bounds
        
        var rectCorner: UIRectCorner = UIRectCorner.allCorners
        if count > 1 {
            if indexPath.row == 0 {
                rectCorner = [.topLeft, .topRight]
            } else if indexPath.row == count - 1 {
                rectCorner = [.bottomLeft, .bottomRight]
            } else {
                rectCorner = []
            }
        } else {
            rectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        }
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 10.auto(), height: 10.auto()))
        
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = cell.contentView.bounds
        maskLayer.path = path.cgPath
        
        cell.contentView.layer.mask = maskLayer
        cell.contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.contentView.layer.shadowOpacity = 1
        cell.contentView.layer.shadowRadius = 7.5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension A4xDevicesSleepPlanViewController: A4xDevicesSleepPlanCellProtocol {
    func devicesCellClick(sender: UIButton, type: A4xDevicesSleepPlanEnum?) {
        
    }
    
    func devicesCellSwicth(flag: Bool, type: A4xDevicesSleepPlanEnum?) {
        guard let switchType: A4xDevicesSleepPlanEnum = type else {
            return
        }
        
        let resultBlock: (String?) -> Void = { [weak self] (error) in
            self?.view.makeToast(error)
            if switchType == .sleepPlanOpen {
                if error == nil{
                    self?.deviceModel?.deviceStatus = flag ? 3 : 0
                }
            }
            if let index = self?.editCells.firstIndex(of: switchType) {
                self?.editCells.remove(at: index)
            }
        }
        
        let compleBlock:() -> Void = { [weak self] in






            switch switchType {
            case .sleepPlanOpen:
                self?.controlModel?.sleepToWakeUP(enable: flag, comple: resultBlock)
                break
            case .sleepPlan:
                self?.controlModel?.setSleepPlanStatus(enable: flag, comple: resultBlock)
            default:
                return
            }
        }
        
        self.editCells.append(switchType)
        compleBlock()
    }
    
    func devicesCellSelect(type: A4xDevicesSleepPlanEnum?) {
        guard type != nil else {
            return
        }
        
        switch type {
        case .setPlan:



            let vc = A4xDevicesSleepPlanShowViewController(deviceModel: self.deviceModel ?? DeviceBean(serialNumber: self.deviceModel?.serialNumber ?? ""))
                self.navigationController?.pushViewController(vc, animated: true)

            break
        default:
            return
        }
    }
}
