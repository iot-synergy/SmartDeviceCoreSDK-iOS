//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public enum A4xLocationUpdate {
    case device(device: DeviceBean?)
    case manager
    case unhold(device: DeviceBean, troubleLocationId: Int) 
}

@objc public protocol A4xDeviceUpdateLocationViewControllerDelegate : AnyObject {
    
    func A4xDeviceUpdateLocationViewControllerViewDidDisappear()
}

public class A4xDeviceUpdateLocationViewController: A4xBaseViewController {
    private var updateType : A4xLocationUpdate
    private var deviceModle : DeviceBean?
    private var editMode : Bool = false{
        didSet {
            self.tableView.reloadData()
        }
    }
    var compleBlock : (()->Void)?
    public weak var delegate : A4xDeviceUpdateLocationViewControllerDelegate?
    private var troubleLocationId : Int = -1
    var locationsData : [A4xDeviceLocationModel] {
        get {
            return A4xUserDataHandle.Handle!.locationsModel.filter { (add) -> Bool in
                return add.id ?? -2 != self.troubleLocationId
            }
        }
    }
    
    public init(type : A4xLocationUpdate ,nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.updateType = type
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.mutableCreate = true
        if case .device(let modle) = type {
            self.deviceModle = modle
        }else if case .unhold(let modle , let troubleId) = type {
            self.deviceModle = modle
            self.troubleLocationId = troubleId
        } else {
            editMode = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNav()
        self.tableView.isHidden = false
        self.updateLocation { [weak self] in
            self?.tableView.reloadData()
            
        }
        
    }
    
    func updateLocation(comple : @escaping ()->Void) {
        DeviceLocationUtil.getAndSaveUserLocations { (code, msg, res) in
            comple()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.delegate != nil {
            self.delegate?.A4xDeviceUpdateLocationViewControllerViewDidDisappear()
        }
    }


    private func loadNav() {
        self.defaultNav()
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "location_setting")
        self.navView?.leftItem?.normalImg = "icon_back_gray"
        self.navView?.backgroundColor = UIColor.white
        self.navView?.lineView?.isHidden = true
        
        if case .device(_) = self.updateType {
            var rightItem = A4xBaseNavItem()
            rightItem.title = A4xBaseManager.shared.getLocalString(key: "edit")
            rightItem.titleColor = ADTheme.C1
            self.navView?.rightItem = rightItem
            weak var weakSelf = self
            self.navView?.rightClickBlock = {
                if let edmo = weakSelf?.editMode {
                    weakSelf?.editMode = !edmo
                    weakSelf?.navView?.rightItem?.title = edmo ? A4xBaseManager.shared.getLocalString(key: "edit") : A4xBaseManager.shared.getLocalString(key: "done")

                }
            }
        }
    }

    lazy var tableView : UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        temp.delegate = self
        temp.dataSource = self
        temp.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20.auto(), right: 0)
        temp.backgroundColor = UIColor.clear
        temp.separatorColor = UIColor.clear
        
        
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom).offset(10)
            make.bottom.equalTo(self.view.snp.bottom)
            make.leading.equalTo(0)
            make.width.equalTo(self.view.snp.width)
        })
        return temp
    }()
}

extension A4xDeviceUpdateLocationViewController : UITableViewDelegate , UITableViewDataSource {
    func numrows() -> Int {
        return locationsData.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == self.numrows() {
            return 62.auto()
        }
        return 52.auto()

    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numrows() + 1
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.numrows() {
            let identifier = "identifier"
            var tableCell : A4xDevicesCreateLocationCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesCreateLocationCell
            if (tableCell == nil){
                tableCell = A4xDevicesCreateLocationCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier);
            }
            tableCell?.title = A4xBaseManager.shared.getLocalString(key: "create_location")
            return tableCell!
        }else {
            let identifier = "identifier2"
            var tableCell : A4xDevicesUpdateLocationCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesUpdateLocationCell
            if (tableCell == nil){
                tableCell = A4xDevicesUpdateLocationCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier);
            }
            let location = locationsData[indexPath.row]
            tableCell?.title = location.name
            tableCell?.editMode = self.editMode
            let currentLocation = self.deviceModle?.locationId
            let cellLocation = location.id ?? 0
            
            tableCell?.checked = currentLocation == cellLocation
            return tableCell!
        }
    }
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
    }
    
    
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bounds =  cell.contentView.bounds.insetBy(dx: 16.auto(), dy: 0)
        var cornet : [UIRectCorner] = []
        if indexPath.row == 0 {
            cornet += [.topLeft , .topRight]
        }
        if indexPath.row  == self.numrows() - 1 {
            cornet += [.bottomRight , .bottomLeft]
        }
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: UIRectCorner(cornet), cornerRadii: CGSize(width: 12.auto(), height: 12.auto()))
        let maskLayer : CAShapeLayer = CAShapeLayer()
        maskLayer.frame = cell.contentView.bounds
        maskLayer.path = path.cgPath
        cell.contentView.layer.mask = maskLayer
    }
   
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == self.numrows() {
            self.createNewLocation()
        }else {
            let location = locationsData[indexPath.row]

            if self.editMode {
                self.updateLocation(location: location)
            }else {
                self.changeDeviceLocation(location: location)
            }
           
        }
    }
}


extension A4xDeviceUpdateLocationViewController {
    private func changeDeviceLocation(location : A4xDeviceLocationModel?) {
        guard let deviceId = self.deviceModle?.serialNumber else {
            return
        }
        
        guard let changeToLocation = location else {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "location_error"))
            return
        }
        weak var weakSelf = self
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        
        DeviceLocationCore.getInstance().setDeviceLocation(serialNumber: deviceId, locationId: changeToLocation.id ?? 0) { code, message in
            weakSelf?.deviceModle?.locationId = location?.id ?? 0
            weakSelf?.deviceModle?.locationName = location?.name
            weakSelf?.tableView.reloadData()
            A4xUserDataHandle.Handle?.updateDevice(device: weakSelf?.deviceModle)
            UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "update_location_scuess"), completion: { (f) in
            })
            if let compleBlock = weakSelf?.compleBlock {
                compleBlock()
            }else {
                weakSelf?.navigationController?.popViewController(animated: true)
            }
        } onError: { code, message in
            weakSelf?.view.makeToast(A4xAppErrorConfig(code : code).message())
        }
    }
    
    private func updateLocation(location : A4xDeviceLocationModel?){
        weak var weakSelf = self
        let vc = A4xAddLocationViewController(locationModle: location)
        vc.newLocationBlock = {locationId in
            weakSelf?.tableView.reloadData()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createNewLocation(){
        weak var weakSelf = self

        let vc = A4xAddLocationViewController(locationModle: nil)
        vc.newLocationBlock = {locationId in
            weakSelf?.tableView.reloadData()
        }
        self.navigationController?.pushViewController(vc, animated: true)

    }
}
