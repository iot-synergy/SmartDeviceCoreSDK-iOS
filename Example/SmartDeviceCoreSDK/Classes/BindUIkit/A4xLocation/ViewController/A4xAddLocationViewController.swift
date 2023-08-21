//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

enum A4xAddLocationEnum {
    case name
    case location
    case address
    case delete
    
    func string() -> (placeHoder : String? ,  title : String?) {
        switch self {
        case .name:
            return (A4xBaseManager.shared.getLocalString(key: "location_name") , A4xBaseManager.shared.getLocalString(key: "detail_location"))
        case .address:
            return (A4xBaseManager.shared.getLocalString(key: "detail_location") , A4xBaseManager.shared.getLocalString(key: "detail_location"))
        case .location:
            let district : String
            if A4xBaseAppLanguageType.language() == .english {
                district = ""
            }else {
                district = "\n\(A4xBaseManager.shared.getLocalString(key: "district_country"))"
            }
            
            return ("\(A4xBaseManager.shared.getLocalString(key: "country"))\n\(A4xBaseManager.shared.getLocalString(key: "province_region"))\n\(A4xBaseManager.shared.getLocalString(key: "district_country"))\(district)" ,nil)//A4xBaseManager.shared.getLocalString(key: "location_address_des") , nil)
        case .delete:
            return (nil , A4xBaseManager.shared.getLocalString(key: "delete_this_location"))
        }
    }
    
    func identifier() -> String {
        switch self {
        case .name:
            fallthrough
        case .address:
            return "baseIdentifier"
        case .location:
            return "locationIdentifier"
        case .delete:
            return "deleteIdentifier"
        }
    }
    
    func maxInput() -> Int {
        switch self {
        case .name:
            return 30
        case .address:
            return 220
        case .location:
            return 0
        case .delete:
            return 0
        }
    }
    
    func value(of modle : A4xDeviceLocationModel?) -> String? {
        guard let m = modle else {
            return nil
        }
        
        switch self {
        case .name:
            return m.name
        case .location:
            var location : String?
            if let country = m.country {
                location = country
                if let state = m.state {
                    location? += "\n\(state)"
                }
                if let city = m.city {
                    if city != m.state { 
                        location? += "\n\(city)"
                    }
                    if let district = m.district {
                        location? += "\n\(district)"
                        
                        
                        
                    }
                }
            }
            return location
        case .address:
            return m.add1Name
        case .delete:
            return nil
        }
    }
    
    static func allCases(showDelete : Bool) -> [[A4xAddLocationEnum]] {
        if showDelete {
            return [[.name ],[.delete]]
        }else {
            return [[.name ]]
        }
    }
}


public class A4xAddLocationViewController: A4xBaseViewController {
    public var newLocationBlock : ((Int)-> Void)?
    var autoNext : Bool = false ///添加新设备的时候，添加新位置的时候需要上级页面进行管理跳转

    public init(locationModle :A4xDeviceLocationModel?) {
        self.tempAddressModle = locationModle ?? A4xDeviceLocationModel()
        self.currentModel = locationModle ?? A4xDeviceLocationModel()
        super.init(nibName: nil, bundle: nil)
        self.mutableCreate = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var addressViewModel = A4xBaseAddressViewModel()
    var dataLists : [[A4xAddLocationEnum]] = []
    var tempAddressModle : A4xDeviceLocationModel
    var currentModel : A4xDeviceLocationModel{
        didSet{
            updateData()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addressViewModel.cancleRequest()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addressViewModel.delegate = self
        
        self.view.backgroundColor = ADTheme.C6
        self.defaultNav()
        
        self.tableView.isHidden = false
    }
    public override func defaultNav(){
        super.defaultNav()
        self.navView?.lineView?.isHidden = true
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "location_setting")
        self.navView?.leftItem?.normalImg = "icon_back_gray"
        self.navView?.backgroundColor = UIColor.white
        
        self.dataLists = A4xAddLocationEnum.allCases(showDelete: self.currentModel.id != nil)
        var rightItem = A4xBaseNavItem()
        rightItem.title = A4xBaseManager.shared.getLocalString(key: "save")
        rightItem.titleColor = ADTheme.Theme
        self.navView?.rightItem = rightItem
        weak var weakSelf = self
        self.navView?.rightClickBlock = {
            weakSelf?.addLocationAction(sender: UIButton())
        }
        self.navView?.leftClickBlock = {
            weakSelf?.checkAction()
        }
    }
    
    
    private func checkAction(){
        
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        
        guard !(tempAddressModle == currentModel) else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.Theme
        config.rightTextColor = UIColor.white
        weak var weakSelf = self
        
        let alert = A4xBaseAlertView(param: config, identifier: "delete device")
        alert.message  = A4xBaseManager.shared.getLocalString(key: "change_not_save")
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "no")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "yes")
        alert.rightButtonBlock = {
            weakSelf?.addLocationAction(sender: UIButton())
        }
        alert.leftButtonBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
        alert.show()
    }
    
    private func updateData() {
        
        
        
    }
    
    private
    lazy var tableView : UITableView = {
        let temp = UITableView()
        temp.delegate = self
        temp.dataSource = self
        temp.tableFooterView = UIView()
        temp.accessibilityIdentifier = "tableView"
        temp.separatorInset = .zero
        temp.backgroundColor = UIColor.clear
        temp.separatorColor = ADTheme.C5
        temp.estimatedRowHeight = 80
        temp.rowHeight=UITableView.automaticDimension
        temp.separatorColor = UIColor.clear
        temp.separatorInset = UIEdgeInsets.zero
        
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom)
            make.width.equalTo(self.view.snp.width)
            make.leading.equalTo(0)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        
        return temp
    }()
    
    
    @objc func addLocationAction(sender : UIButton){
        guard self.currentModel.name?.count ?? 0 > 0 else {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "location_name_required"))
            return
        }
        weak var weakSelf = self
        addressViewModel.updateOrAddNewLocation(location: self.currentModel) { (result ,error) in
            if error == nil {
                if result != nil  {
                    weakSelf?.newLocationBlock?(result!)
                }
                UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "update_location_scuess"),  completion: { (f) in
                })
                if let strongSelf = weakSelf {
                    if !strongSelf.autoNext {
                        weakSelf?.navigationController?.popViewController(animated: true)
                    }
                }
                
            }else {
                weakSelf?.view.makeToast(error)
            }
            
        }
    }
}
extension A4xAddLocationViewController : UIScrollViewDelegate , A4xBaseAddressViewModelDelegate {
    
    
    public func getLocation(state: A4xBaseAddressRequestStateEnum, model: A4xDeviceLocationModel?) {
        if var m = model {
            let id = currentModel.id
            let name = currentModel.name
            let addr = currentModel.add1Name
            m.name = name
            m.add1Name = addr
            m.id = id
            currentModel = m
        }
        self.tableView.reloadData()
    }
    
    public func getPermissError(error: A4xBaseAddressDermissStateEnum) {
        
        self.tableView.reloadData()
    }
}

extension A4xAddLocationViewController : UITableViewDelegate , UITableViewDataSource {
    
    //MARK:- UITableViewDataSource
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 15.auto()
        }
        return 0.1
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let temp = UIView()
            temp.backgroundColor = UIColor.white
            return temp
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let temp = UIView()
        temp.backgroundColor = UIColor.clear
        return temp
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15.auto()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataLists.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataLists[section].count
    }
    
    //MARK:- UITableViewDataSource
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataLists[indexPath.section][indexPath.row]
        let identifier = type.identifier()
        var tableCell : A4xAddLocationCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xAddLocationCell
        
        if (tableCell == nil){
            
            if type == .location {
                let  cell = A4xAddLocationAddressCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
                weak var weakSelf = self
                cell.locationBlock = {
                    
                    weakSelf?.addressViewModel.getLocation()
                }
                tableCell = cell
                
            }else if type == .delete {
                tableCell = A4xAddLocationRemove(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            }else{
                tableCell = A4xAddLocationInputCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            }
            weak var weakSelf = self
            tableCell?.editInfoBlock = { (type ,value) in
                weakSelf?.editAction(type: type, value: value)
            }
        }
        
        let stringValue = type.string()
        tableCell?.placeHolder = stringValue.placeHoder
        tableCell?.title = stringValue.title
        tableCell?.value = type.value(of: currentModel)
        tableCell?.type = type
        tableCell?.maxInput = type.maxInput()
        if let cell : A4xAddLocationAddressCell = tableCell as? A4xAddLocationAddressCell {
            cell.isLocationing = self.addressViewModel.isLocationing
        }
        
        return tableCell!
    }
    
    private func showHoldDevicesAlert(str : String? , holdDevices : [DeviceBean]? , locationID : Int) {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = UIColor.white
        config.leftTitleColor = ADTheme.C1
        
        config.rightTextColor = ADTheme.Theme
        config.rightbtnBgColor = UIColor.white
        
        let alert = A4xBaseAlertView(param: config, identifier: "dfshow Save Alert")
        alert.title  = str
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "change")
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
        weak var weakSelf = self

        alert.rightButtonBlock = {
            if let devices : [DeviceBean] = holdDevices {
                let vc = A4xLocationBindDevicesViewController(devices: devices, locationId: locationID)
                weakSelf?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        alert.show()
        
    }
    
    private func showCantDelete(){
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = UIColor.white
        config.leftTitleColor = ADTheme.C2
        config.rightbtnBgColor = UIColor.white
        config.rightTextColor = ADTheme.E1
        
        let alert = A4xBaseAlertView(param: config, identifier: "Cant delete Alert")
        alert.title  = A4xBaseManager.shared.getLocalString(key: "is_last_location")
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "got_it")
        alert.show()
    }
    
    private func showDeleteAlert() {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = UIColor.white
        config.leftTitleColor = ADTheme.C2
        config.rightbtnBgColor = UIColor.white
        config.rightTextColor = ADTheme.E1
        weak var weakSelf = self
        
        let alert = A4xBaseAlertView(param: config, identifier: "dfshow Save Alert")
        alert.title  = A4xBaseManager.shared.getLocalString(key: "delete_location_desc")
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "delete")
        alert.rightButtonBlock = {
            let locationID = self.currentModel.id ?? -1
            weakSelf?.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading"), completion: { (f) in
                
            })
            weakSelf?.addressViewModel.deleteLocation(location: self.currentModel) { (id, error ,holdDevices)  in
                weakSelf?.view.hideToastActivity()
                if error == nil {
                    weakSelf?.newLocationBlock?(id ?? -1)
                    UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "delete_success"),  completion: { (f) in
                    })
                    weakSelf?.navigationController?.popViewController(animated: true)
                    
                }else {
                    if let holdDevice : [DeviceBean] = holdDevices {
                        weakSelf?.showHoldDevicesAlert(str: error, holdDevices: holdDevice, locationID: locationID)
                    }else {
                        weakSelf?.view.makeToast(error)
                        
                    }
                }
            }
            
        }
        
        alert.show()
        
    }
    
    private func editAction(type: A4xAddLocationEnum, value: String?) {
        switch type {
        case .name:
            currentModel.name = value
            
        case .location:
            
            let alert  = A4xLocationSelectView(Address: self.currentModel)
            weak var weakSelf = self
            alert.selectAddressDone = { modle in
                weakSelf?.currentModel = modle
                weakSelf?.tableView.reloadData()
                
            }
            alert.show()
        case .address:
            currentModel.add1Name = value
            
        case .delete:
            
            let counts = A4xUserDataHandle.Handle?.locationsModel.count ?? 0
            if counts == 1 && A4xUserDataHandle.Handle?.deviceModels?.count ?? 0 > 0 {
                self.showCantDelete()
                return
            }
            self.showDeleteAlert()
        }
    }
    
}
