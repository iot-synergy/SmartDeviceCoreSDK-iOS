//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDevicesShareViewController: A4xBaseViewController {
    //var deviceId : String?
    private var deviceModel : DeviceBean?
    private var viewModle : A4xDeviceShareViewModel = A4xDeviceShareViewModel()

    var cellDatas : [A4xDevicesShareSessionInfoEnum : [A4xDevicesShareinfoEnum]]?
    var session : [A4xDevicesShareSessionInfoEnum]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNavtion()
        self.view.backgroundColor = ADTheme.C6
        self.tableView.isHidden = false
        self.updateData(users: [])
        self.loadNetData()
    }
    
    init(deviceModel: DeviceBean, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        //self.deviceId = deviceId
        self.deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceModel.serialNumber ?? "", modeType: deviceModel.apModeType ?? .WiFi)
    }
    
    private func updateData(users : [A4xUserDataModel]) {
        var user = A4xUserDataModel()
        user.name = self.deviceModel?.adminName
        user.email = self.deviceModel?.adminEmail
        user.phone = self.deviceModel?.adminPhone
        let (cellDaatas , session) = A4xDevicesShareinfoEnum.shareCase(admin: user, shareUsers: users)
        self.cellDatas = cellDaatas
        self.session = session
        self.tableView.reloadData()
    }
    
    private func removeData(user : A4xUserDataModel) {
        self.tableView.reloadData()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "share")
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg =  "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
    }

    private
    lazy var tableView : UITableView = {
        let temp = UITableView()
        temp.delegate = self
        temp.dataSource = self
        temp.backgroundColor = UIColor.clear
        temp.tableFooterView = UIView()
        temp.accessibilityIdentifier = "tableView"
        temp.separatorInset = .zero
        temp.separatorColor = ADTheme.C5
        temp.estimatedRowHeight = 80
        temp.rowHeight = UITableView.automaticDimension
        self.view.addSubview(temp)
        temp.mj_header = A4xMJRefreshHeader { [weak self] in
            self?.loadNetData()
        }
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom)
            make.width.equalTo(self.view.snp.width)
            make.leading.equalTo(0)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        
        return temp
    }()
    
}

extension A4xDevicesShareViewController {
    private func loadNetData(){
        //self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (r) in }
        weak var weakSelf = self
        self.viewModle.loadShareUser(deviceID: self.deviceModel?.serialNumber ?? "") { (result, error) in
            weakSelf?.tableView.mj_header?.endRefreshing()
            //weakSelf?.view.hideToastActivity {
                if error != nil {
                    weakSelf?.view.makeToast(error)
                }
                weakSelf?.updateData(users: result)
            //}
        }
    }
    
    private func deleteUser(user : A4xUserDataModel){
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (r) in }
        weak var weakSelf = self
        self.viewModle.shareUserDelete(deviceID: self.deviceModel?.serialNumber ?? "", deleteUser: user) { (flag, error) in
            weakSelf?.view.hideToastActivity { }
            if flag {
                let currentUsers = weakSelf?.cellDatas?[.shared]?.filter({ (shareUser) -> Bool in
                    if case let .share(temp) = shareUser {
                        if user.id ?? 0 == temp.id ?? 0 {
                            return false
                        }
                    }
                    return true
                })
                weakSelf?.cellDatas?[.shared] = currentUsers
                weakSelf?.tableView.reloadData()
            }else {
                
                weakSelf?.view.makeToast(error)
            }
        }

    }
    
    private func showDeleteAlert(user : A4xUserDataModel) {
        
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.E1
        config.rightTextColor = UIColor.white
        
        let deviceName = self.deviceModel?.deviceName ?? A4xBaseManager.shared.getLocalString(key: "camera")
        let userName = user.email ?? ""
        
        var attrMessage : NSAttributedString {
            
            let temp = NSMutableAttributedString(string: A4xBaseManager.shared.getLocalString(key: "remove_share_device_des", param: [userName,deviceName]))
            let count = temp.string.count
            
            temp.addAttribute(NSAttributedString.Key.font, value: config.messageFont, range: NSRange(location: 0, length: count))
            temp.addAttribute(NSAttributedString.Key.foregroundColor, value: config.messageColor, range: NSRange(location: 0, length: count))
            let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = CGFloat(config.messageLinespace) //大小调整
            paragraphStyle.alignment = config.messageAlignment
            temp.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: count))
            if let deviceRange = temp.string.range(of: deviceName) {
                let range = temp.string.nsRange(from: deviceRange)
                if range.length > 0 {
                    temp.addAttribute(NSAttributedString.Key.font, value: ADTheme.B1, range: range)
                }
            }
            
            if let userRange = temp.string.range(of: userName) {
                let range = temp.string.nsRange(from: userRange)
                if range.length > 0 {
                    temp.addAttribute(NSAttributedString.Key.font, value: ADTheme.B1, range: range)
                }
            }
            
            return temp
        }
        
        weak var weakSelf = self
        
        //alert title
        var attrTitle : NSAttributedString {
            let temp = NSMutableAttributedString(string: A4xBaseManager.shared.getLocalString(key: "remove_share_device_title"))
            let count = temp.string.count
            
            temp.addAttribute(NSAttributedString.Key.font, value: config.alertTitleFont, range: NSRange(location: 0, length: count))
            temp.addAttribute(NSAttributedString.Key.foregroundColor, value: config.titleColor, range: NSRange(location: 0, length: count))
            let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            temp.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: count))
            return temp
        }
        
        let alert = A4xBaseAlertView(param: config, identifier: "delete user")
        alert.titleAttr = attrTitle
        alert.messageAttr  = attrMessage
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "delete")
        alert.rightButtonBlock = {
            weakSelf?.deleteUser(user: user)
        }
        alert.show()
    }
}

extension A4xDevicesShareViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sessionIndex = self.session?[indexPath.section] else {
            return 0.0
        }
        guard let sessionRows = self.cellDatas?[sessionIndex] else {
            return 0
        }
        let row = sessionRows[indexPath.row]
        if row == A4xDevicesShareinfoEnum.invite   {
            return 46
        }else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellDatas?[self.session?[section] ?? .admin]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 29
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        let lable = UILabel()
        lable.textColor = ADTheme.C4
        lable.font = ADTheme.B1
        v.addSubview(lable)
        
        lable.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalTo(v.snp.centerY).offset(1.5)
            make.trailing.lessThanOrEqualTo(v.snp.trailing).offset(-30)
        }
        lable.text = self.session?[section].rawValue
        return v
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        if let rowType = self.cellDatas?[self.session?[indexPath.section] ?? .admin]?[indexPath.row] {
            if rowType == A4xDevicesShareinfoEnum.invite   {
                let identifier = "identifier"
                var tableCell : A4xDeviceShareArrowCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDeviceShareArrowCell
                if (tableCell == nil){
                    tableCell = A4xDeviceShareArrowCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
                }
                tableCell?.nameString = A4xBaseManager.shared.getLocalString(key: "invite").capitalized
                cell = tableCell
            }else {
                let identifier = "identifier2"
                var tableCell : A4xDeviceShareEditCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDeviceShareEditCell
                if (tableCell == nil){
                    tableCell = A4xDeviceShareEditCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
                }
                if case let .admin(user) = rowType {
                    tableCell?.nameString = user.name
                    tableCell?.emailString = (user.email?.count ?? 0) > 0 ? user.email : user.phone
                }else if case let .share(user) = rowType {
                    tableCell?.nameString = user.name
                    tableCell?.emailString = (user.email?.count ?? 0) > 0 ? user.email : user.phone
                }
                
                cell = tableCell
            }
        }else {
            cell = UITableViewCell()
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if let rowType = self.cellDatas?[self.session?[indexPath.section] ?? .admin]?[indexPath.row] {
            if case .share(_) = rowType  {
                return .delete
            }
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        if let rowType = self.cellDatas?[self.session?[indexPath.section] ?? .admin]?[indexPath.row] {
            if case let .share(user) = rowType  {
                DispatchQueue.main.async {
                    self.showDeleteAlert(user: user)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let rowType = self.cellDatas?[self.session?[indexPath.section] ?? .admin]?[indexPath.row] {
            if case  .invite = rowType  {
                
                let vc = A4xDevicesShareInviteViewController()
                vc.deviceModel = self.deviceModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    

}

