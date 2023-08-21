//


//


//

import UIKit

import SmartDeviceCoreSDK
import BaseUI

class A4xDevicesSleepPlanShowViewController: A4xBaseViewController {

    //var deviceId: String
    private var controlModel: A4xDeviceControlViewModel?
   
    var deviceModel: DeviceBean?
    
    private var cellInfos: [[A4xDevicesSetSleepPlanModel]]?
    private var editCells: [A4xDevicesSetSleepPlanEnum] = [] {
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
        
        self.noNetView.isHidden = true
        self.noNetImage.isHidden = false
        self.noNetLbl.isHidden = false
        self.nextBtn.isHidden = false
        //
        self.deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: self.deviceModel?.serialNumber ?? "", modeType: self.deviceModel?.apModeType ?? .WiFi)
        
        
        controlModel = A4xDeviceControlViewModel.loadLocalData(deviceModel: self.deviceModel ?? DeviceBean(serialNumber: self.deviceModel?.serialNumber ?? ""), comple: { [weak self] (error) in
            self?.view.makeToast(error)
            if (self?.controlModel?.sleepPlanModels?.count ?? 0) > 0 {
                self?.reloadData()
            }
        })
        
        
        //controlModel?.resolution = self.deviceModel?.resolution
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        









    }
    
    
    @objc private func loadData() {
        
        controlModel?.getSleepPlanList(comple: { [weak self] (error) in
            self?.view.hideToastActivity()
            if error != nil {
                self?.view.makeToast(error)
                self?.navView?.rightBtn?.isHidden = true
                self?.noNetView.isHidden = false
            } else {
                self?.noNetView.isHidden = true
                self?.reloadData()
            }
        })
    }
    
    private func reloadData() {
        self.navView?.rightBtn?.isHidden = !(controlModel?.sleepPlanModels?.count ?? 0 > 0)
        self.cellInfos = A4xDevicesSetSleepPlanEnum.cases(showPlan: controlModel?.sleepPlanModels?.count ?? 0 > 0, deviceModle: self.deviceModel)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        A4xUserDataHandle.Handle?.videoHelper.stopAlive(deviceId: self.deviceModel?.serialNumber ?? "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //A4xUserDataHandle.Handle?.videoHelper.keepAlive(deviceId: self.deviceId, isHeartbeat: true, comple: { [weak self] (state, flag) in
            //self?.deviceSetup = flag
        //})
        
        
        loadData()
        
    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "schedule_time").capitalized
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
        
        var rightItem = A4xBaseNavItem()
        
        rightItem.normalImg = "device_add_sleep_plan"
        self.navView?.rightItem = rightItem
        self.navView?.rightBtn?.isHidden = true
        self.navView?.rightClickBlock = { [weak self] in
            
            let vc = A4xDevicesSleepPlanSetViewController(deviceModel: self?.deviceModel ?? DeviceBean(serialNumber: self?.deviceModel?.serialNumber ?? ""))
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private
    lazy var tableView: UITableView = {
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
    
    
    lazy var noNetView: UIView = {
        var v = UIView()
        v.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        self.view.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.top.equalTo(UIScreen.navBarHeight)
            make.leading.equalTo(0)
            make.width.equalToSuperview()
            make.height.equalTo(UIScreen.height - UIScreen.navBarHeight)
        }
        return v
    }()
    
    lazy var noNetImage : UIImageView = {
        var temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        temp.image = A4xDeviceSettingResource.UIImage(named: "device_sleep_plan_error")?.rtlImage()
        self.noNetView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.noNetView.snp.centerY).offset(-UIScreen.navBarHeight)
            make.centerX.equalTo(self.noNetView.snp.centerX)
            make.width.equalTo(189.auto())
            make.height.equalTo(179.5.auto())
        })
        return temp
    }()
    
    //device_sleep_plan_error
    lazy var noNetLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "loading_failed")
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.font = UIFont.regular(14)
        lbl.textColor = ADTheme.C3
        self.noNetView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.top.equalTo(self.noNetImage.snp.bottom).offset(16.auto())
            make.centerX.equalTo(self.noNetImage.snp.centerX)
        })
        return lbl
    }()
    
    lazy var nextBtn: UIButton = {
        var btn:UIButton = UIButton()
        btn.titleLabel?.font = ADTheme.B1
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.textAlignment = .center
        btn.setTitle(A4xBaseManager.shared.getLocalString(key: "please_retry"), for: UIControl.State.normal)
        btn.setTitleColor(ADTheme.C4, for: UIControl.State.disabled)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
        let image = btn.currentBackgroundImage
        let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.Theme, by: 0.9)
        btn.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
        btn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .disabled)
        btn.addTarget(self, action: #selector(loadData), for: .touchUpInside)
        btn.layer.cornerRadius = 25.auto()
        btn.clipsToBounds = true
        self.noNetView.addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            make.top.equalTo(self.noNetLbl.snp.bottom).offset(16.auto())
            make.centerX.equalTo(self.noNetImage.snp.centerX)
            make.width.equalTo(214.auto())
            make.height.equalTo(50.auto())
        })
        return btn
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

}

extension A4xDevicesSleepPlanShowViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sleepPlanModel: A4xDevicesSetSleepPlanModel = self.cellInfos![indexPath.section][indexPath.row]
        switch sleepPlanModel.type {
        case .editPlan:
            return sleepPlanModel.cellHeight ?? 129.auto()
        case .showPlan:
            return UIScreen.height - UIScreen.navBarHeight - 10.auto() - 16.auto()
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
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sleepPlanModel: A4xDevicesSetSleepPlanModel = self.cellInfos![indexPath.section][indexPath.row]
        if sleepPlanModel.type == .editPlan { 
            let identifier = "A4xDevicesSetSleepPlanCell"
            var tableCell: A4xDevicesSetSleepPlanCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesSetSleepPlanCell
            
            if (tableCell == nil) {
                tableCell = A4xDevicesSetSleepPlanCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            }
            
            var sleepPlanModel = cellInfos![indexPath.section][indexPath.row]
            tableCell?.type = sleepPlanModel.type
            tableCell?.setModelCategory(modelCategory: self.deviceModel?.modelCategory ?? 1)
            tableCell?.protocol = self
            
            switch sleepPlanModel.type {
            case .editPlan:
                sleepPlanModel.cellHeight = tableCell?.getCellHeight() ?? 290.auto()
                cellInfos![indexPath.section][indexPath.row] = sleepPlanModel
                break
            default:
                break
            }
            return tableCell!
        } else { 
            let identifier = "A4xDevicesShowSleepPlanCell"
            var tableCell: A4xDevicesShowSleepPlanCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesShowSleepPlanCell

            if (tableCell == nil) {
                tableCell = A4xDevicesShowSleepPlanCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            }

            //var sleepPlanModel = cellInfos![indexPath.section][indexPath.row]
            tableCell?.type = sleepPlanModel.type
            tableCell?.protocol = self
            
            tableCell?.sleepPlanModels = controlModel?.sleepPlanModels
            
            switch sleepPlanModel.type {
            case .showPlan:
                //sleepPlanModel.cellHeight = tableCell?.getCellHeight() ?? 290.auto()
                //cellInfos![indexPath.section][indexPath.row] = sleepPlanModel
                break
            default:
                break
            }
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

extension A4xDevicesSleepPlanShowViewController: A4xDevicesSetSleepPlanCellProtocol {
    func devicesBtnClick(sender: UIButton, status: String, type: A4xDevicesSetSleepPlanEnum?) {
        
        if status == "noArea" {
            
            let startHour = sender.tag / 7 * 4
            let startMinute = 0
            var endHour = startHour + 4
            var endMinute = 0
            if startHour == 20 {
                endHour = startHour + 3
                endMinute = 30
            }
            let planStartDay:[Int] = [sender.tag % 7]
            let vc = A4xDevicesSleepPlanSetViewController(deviceModel: self.deviceModel ?? DeviceBean(serialNumber: self.deviceModel?.serialNumber ?? ""))
            vc.setSleepPlanNew = true
            //vc.sleepPlanModels = sleepModels
            vc.period = sender.tag
            vc.startHour = startHour
            vc.startMinute = startMinute
            vc.endHour = endHour
            vc.endMinute = endMinute
            vc.planStartDay = planStartDay
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            
            let vc = A4xDevicesSleepPlanSetViewController(deviceModel: self.deviceModel ?? DeviceBean(serialNumber: self.deviceModel?.serialNumber ?? ""))
            vc.setSleepPlanNew = false
            let sleepModels = controlModel?.sleepPlanModels?.filter {
                $0.period == sender.tag / 1000
            }
            let planStartDay: [Int] = sleepModels?.map { return $0.planDay } as? [Int] ?? [1,2,3,4,5]
            vc.sleepPlanModels = sleepModels
            vc.period = sender.tag / 1000
            vc.planStartDay = planStartDay
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
   
    func devicesCellClick(sender: UIButton, type: A4xDevicesSetSleepPlanEnum?) {
        guard let switchType: A4xDevicesSetSleepPlanEnum = type else {
            return
        }
        
        if switchType == .editPlan {
            let vc = A4xDevicesSleepPlanSetViewController(deviceModel: self.deviceModel ?? DeviceBean(serialNumber: self.deviceModel?.serialNumber ?? ""))
            vc.setSleepPlanNew = true
            //vc.period
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func devicesCellSwicth(flag: Bool, type: A4xDevicesSetSleepPlanEnum?) { }
    
    func devicesCellSelect(type: A4xDevicesSetSleepPlanEnum?) {
        guard type != nil else {
            return
        }
    }
}



