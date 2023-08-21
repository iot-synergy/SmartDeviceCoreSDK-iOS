//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xLocationBindDevicesViewController: A4xBaseViewController {
    var devices : [DeviceBean] {
        didSet {
            
            if devices.count == 0 {
                weak var weakSelf = self
                DispatchQueue.main.a4xAfter(0.5) {
                    weakSelf?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    var locationId : Int
    
    init(devices : [DeviceBean] , locationId : Int) {
        self.devices = devices
        self.locationId = locationId
        super.init(nibName: nil, bundle: nil)
    }
    
    var locationsData : [A4xDeviceLocationModel] {
        get {
            return A4xUserDataHandle.Handle!.locationsModel.filter { (add) -> Bool in
                return add.id ?? -2 != self.locationId
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateDataSource()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultNav()
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "alter_location")
        self.tableView.isHidden = false
        self.view.backgroundColor = ADTheme.C6
        
    }
    
    
    private
    lazy var tableView : UITableView = {
        let temp = UITableView(frame: .zero, style: .grouped)
        temp.delegate = self
        temp.dataSource = self
        temp.backgroundColor = UIColor.clear
        temp.tableFooterView = UIView()
        
        temp.contentInset = UIEdgeInsets(top: 10.auto(), left: 0, bottom: 0, right: 0)
        temp.accessibilityIdentifier = "tableView"
        temp.separatorColor = ADTheme.C6
        temp.separatorInset = .zero
        temp.estimatedRowHeight = 80;
        temp.rowHeight=UITableView.automaticDimension;
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom)
            make.width.equalTo(self.view.snp.width).offset(-32.auto())
            make.bottom.equalTo(self.view.snp.bottom)
            make.centerX.equalTo(self.view.snp.centerX)
        })
        
        return temp
    }()
    
    func updateDataSource() {
        let locationID = self.locationId
        let temp = devices.filter { (db) -> Bool in
            if let storeDb = A4xUserDataHandle.Handle?.getDevice(deviceId: db.serialNumber ?? "") {
                if (storeDb.locationId ?? -1) == locationID {
                    return true
                }
            }
            return false
        }
        self.devices = temp
        self.tableView.reloadData()
    }
    
}


extension A4xLocationBindDevicesViewController :  UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.auto()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 114.auto()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.auto()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationsData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tempV = A4xUpdateAddressHeader()
        let data = devices[section]
        tempV.deviceInfo = self.locationInfo(device: data)
        tempV.stateInfo = data.deviceState()
        tempV.deviceName = data.deviceName
        tempV.deviceModle = data

        return tempV
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let tempV = A4xUpdateAddressFooter()
        return tempV
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "identifier"
        
        var tableCell : A4xUpdateAddressCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xUpdateAddressCell
        if (tableCell == nil){
            tableCell = A4xUpdateAddressCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier);
        }
        tableCell?.title = locationsData[indexPath.row].name
        tableCell?.checked = false
        return tableCell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         let c = A4xUserDataHandle.Handle!.locationsModel.count
         if indexPath.row == c  {
             cell.contentView.layer.mask = nil
             return
         }
        let bounds =  cell.contentView.bounds.insetBy(dx: 10.auto(), dy: 0)
         
        var rectCorner : UIRectCorner = UIRectCorner.allCorners
        if self.locationsData.count > 1 {
            if indexPath.row == 0 {
                rectCorner = [.topLeft,.topRight]
            }else if indexPath.row == self.locationsData.count - 1 {
                rectCorner = [.bottomLeft,.bottomRight]
            }else {
                rectCorner = []
            }
        }
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 10.auto() , height: 10.auto() ))
         let maskLayer : CAShapeLayer = CAShapeLayer()
         maskLayer.frame = cell.contentView.bounds
         maskLayer.path = path.cgPath
         cell.contentView.layer.mask = maskLayer
         
         
         cell.contentView.frame = cell.frame.insetBy(dx: 17, dy: 18)
         
         cell.contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
         cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
         cell.contentView.layer.shadowOpacity = 1
         cell.contentView.layer.shadowRadius = 7.5
     }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? A4xUpdateAddressCell else {
            return
        }
        cell.checked = true
        

        
        self.changeDeviceLocation(indexPath: indexPath)

    }
    
    private func locationInfo(device : DeviceBean? ) -> NSAttributedString? {
        
        let normailString = device?.loaction()?.name
        guard normailString != nil else {
            return nil
        }
        
        let font = ADTheme.B2
        let color = ADTheme.C4
        
        let showAttr = A4xBaseManager.shared.getLocalString(key: "current_location", param: [normailString ?? ""])
        let normalCount : Int = showAttr.count
        let attr = NSMutableAttributedString(string: showAttr)
        
        
        attr.addAttribute(.font, value: font, range: NSRange(location: 0, length: normalCount))
        attr.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: normalCount))
        
        return attr

    }
    
    
    private func changeDeviceLocation(indexPath: IndexPath) {
        let location = locationsData[indexPath.row]
        var dModle : DeviceBean = self.devices[indexPath.section]
        guard let deviceId = dModle.serialNumber else {
            return
        }
      
        weak var weakSelf = self
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        DeviceLocationCore.getInstance().setDeviceLocation(serialNumber: deviceId, locationId: locationId) { code, message in
            dModle.locationId = location.id ?? 0
            DispatchQueue.main.a4xAfter(0.2) {
                A4xUserDataHandle.Handle?.updateDevice(device: dModle)
                weakSelf?.tableView.beginUpdates()
                weakSelf?.devices.remove(at: indexPath.section)
                weakSelf?.tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section), with: .left)
                weakSelf?.tableView.endUpdates()
            }
            let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: dModle.modelCategory ?? 1)
            UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "alerdy_move_location", param: [tempString, location.name ?? ""]), completion: { (f) in
                
            })
        } onError: { code, message in
            weakSelf?.view.makeToast(A4xAppErrorConfig(code : code).message())
            weakSelf?.tableView.reloadData()
        }

        
    }
}
