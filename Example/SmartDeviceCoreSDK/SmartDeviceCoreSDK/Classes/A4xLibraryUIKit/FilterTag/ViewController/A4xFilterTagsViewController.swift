//


//







import UIKit
import SmartDeviceCoreSDK
import Resolver
import A4xDeviceSettingInterface
import BaseUI

extension A4xLibraryVideoAiTagType {
    public func image() -> UIImage? {
        switch self {
        case .vehicle:
            return bundleImageFromImageName("main_libary_vehicle")?.rtlImage()
        case .pet:
            return bundleImageFromImageName("main_libary_pet")?.rtlImage()
        case .person:
            return bundleImageFromImageName("main_libary_people")?.rtlImage()
        case .cry:
            return bundleImageFromImageName("main_libary_cry")?.rtlImage()
        case .package:
            return bundleImageFromImageName("main_libary_package")?.rtlImage()
        case .package_drop_off:
            return bundleImageFromImageName("main_libary_package")?.rtlImage()//main_libary_package_down()
        case .package_pick_up:
            return bundleImageFromImageName("main_libary_package")?.rtlImage()//main_libary_package_up()
        case .package_exist:
            return bundleImageFromImageName("main_libary_package")?.rtlImage()//main_libary_package_detained()
        case .vehicle_enter:
            return bundleImageFromImageName("main_libary_vehicle")?.rtlImage()
        case .vehicle_out:
            return bundleImageFromImageName("main_libary_vehicle")?.rtlImage()
        case .vehicle_held_up:
            return bundleImageFromImageName("main_libary_vehicle")?.rtlImage()
            
        case .device_call:
            return bundleImageFromImageName("main_libary_device_call")?.rtlImage()
        case .doorbell_press:
            return bundleImageFromImageName("main_libary_doorbell_press")?.rtlImage()
        case .doorbell_remove:
            return bundleImageFromImageName("main_libary_doorbell_remove")?.rtlImage()
        case .bird:
            return bundleImageFromImageName("main_libary_bird")?.rtlImage()
        }
    }
}

class A4xFilterTagsViewController: A4xBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var filterData : A4xVideoLibraryFilterModel?
    private var shouldUpdate : Bool? = false
    private var subVehicleCellHeight: CGFloat = 144.auto()
    private var subPackageCellHeight: CGFloat = 144.auto()
    
    var fileterUpdateBlock : ((Bool)->Void)?
    var temArraySave : [Int]? = []
    
    var netDeviceData : [DeviceBean]? 
    var isFromSDCard: Bool = false
    var sdDeviceSN: String = ""

    
    
    var allTagsModel: TagBean?
    
    
    var allVideoTags: [FilterAiEventTag]?
    
    var netDeviceImagesData: [ZoneBean]? 
    
    var devicesData: [DeviceBean]? {
        return netDeviceData ?? A4xUserDataHandle.Handle?.deviceModels
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        //loadData()
    }
    
    override func back() {
        super.back()
        if self.fileterUpdateBlock != nil {
            self.fileterUpdateBlock!(self.shouldUpdate!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.keyWindow?.makeToastActivity(title: "loading") { (f) in }
        weak var weakSelf = self
        
        
        LibraryCore.getInstance().fetchZoneImages { code, msg, datas in
            if code == 0 {
                weakSelf?.loadData()
                weakSelf?.netDeviceImagesData = datas

            } else {
                weakSelf?.loadData()
                weakSelf?.netDeviceImagesData = nil
                weakSelf?.view.makeToast(A4xAppErrorConfig(code: code).message())
            }
        }
    }
    
    
    private func loadData() {
        
        LibraryCore.getInstance().queryVideoSearchOption(isFromSDCard: self.isFromSDCard, serialNumber: self.sdDeviceSN, onSuccess: { code, message, resultModel in
            if code == 0 {
                
                self.allTagsModel = resultModel
                var tempArray: [FilterAiEventTag] = []
                resultModel?.deviceEventTags?.forEach({ model in
                    tempArray.append(model)
                })
                resultModel?.aiEventTags?.forEach({ model in
                    tempArray.append(model)
                })
                
                self.allVideoTags = tempArray
                self.tableView.reloadData()
            } else {
                self.view.makeToast(A4xAppErrorConfig(code: code).message())
            }
            UIApplication.shared.keyWindow?.hideToastActivity(block: { })
        }, onFail: {code, msg in
            self.view.makeToast(A4xAppErrorConfig(code: code).message())
            UIApplication.shared.keyWindow?.hideToastActivity(block: { })
        })
        
        
        A4xVideoLibraryFilterModel.get { (mod) in
            self.filterData = mod
            self.loadNav()
            self.tableView.isHidden = false
            self.setBgView.isHidden = false
            self.resetBtn.isHidden = false
            self.saveBtn.isHidden = false
        }
    }
    
    private func saveFilterData () {
        if let date = self.filterData {
            A4xVideoLibraryFilterModel.save(model: date)
        }
    }
    
    func loadNav() {
        self.navView?.lineView?.isHidden = false
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "filter")
        weak var weakSelf = self
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
        self.navView?.lineView?.isHidden = true
    }
    
    private lazy var tableView: UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        temp.delegate = self
        temp.dataSource = self
        temp.showsVerticalScrollIndicator = false
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            temp.backgroundColor = .white
        } else {
            temp.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        }
        temp.separatorColor = ADTheme.C5


        temp.tableFooterView = UIView()
        temp.accessibilityIdentifier = "tableView"
        temp.register(A4xFilterTagNormalCell.self, forCellReuseIdentifier: "A4xFilterTagNormalCell")
        temp.register(A4xFilterTagZoneCell.self, forCellReuseIdentifier: "A4xFilterTagZoneCell_identifier")
        temp.separatorInset = .zero
        temp.separatorStyle = .none
        self.view.addSubview(temp)
        let bottomHeight = UIApplication.isIPhoneX() ? 20 : 0
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom)
            make.trailing.equalTo(self.view.snp.trailing)
            make.leading.equalTo(0)
            make.height.equalTo(Int(UIScreen.height - UIScreen.navtionHeight) - 75.auto() - bottomHeight)
        })
        return temp
    }()
    
    
    private lazy var setBgView: UIView = {
        let temp  = UIView()
        temp.backgroundColor = .white
        temp.isUserInteractionEnabled = true
        temp.clipsToBounds = false
        self.view.addSubview(temp)
        let bottomHeight = UIApplication.isIPhoneX() ? 20 : 0
        temp.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottom)
            make.width.equalTo(self.view.snp.width)
            make.height.equalTo(75.auto() + bottomHeight)
            make.leading.equalTo(0)
        }
        temp.layoutIfNeeded()
        temp.layer.masksToBounds = false
        
        temp.layer.shadowColor = UIColor.black.cgColor
        
        temp.layer.shadowOpacity = 0.2
        
        temp.layer.shadowRadius = 5
        
        temp.layer.shadowOffset = CGSize(width: 0, height: -2)
        return temp
    }()
    
    
    private lazy var resetBtn: UIButton = {
        let temp = UIButton()
        temp.titleLabel?.font = ADTheme.B1
        temp.setTitleColor(ADTheme.C1, for: UIControl.State.disabled)
        temp.setTitleColor(ADTheme.Theme, for: UIControl.State.normal)
        let img = UIImage.init(color: ADTheme.Theme.withAlphaComponent(0.1))
        let pressColor = img?.multiplyColor(img?.mostColor ?? ADTheme.Theme, by: 0.9)
        temp.setBackgroundImage(img, for: .normal)
        temp.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
        temp.setBackgroundImage(UIImage.init(color: UIColor.white), for: .disabled)
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "reset"), for: .normal)
        temp.addTarget(self, action: #selector(resetBtnAction), for: .touchUpInside)
        self.setBgView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.setBgView.snp.leading).offset(16.auto())
            make.width.equalTo((UIScreen.width - 32.auto() - 16.auto()) / 2)
            make.height.equalTo(50.auto())
            make.top.equalTo(self.setBgView.snp.top).offset(12.5.auto())
        })
        temp.layer.masksToBounds = true
        temp.layer.cornerRadius = 25.auto()



        return temp
    }()
    
    
    private lazy var saveBtn: UIButton = {
        let temp = UIButton()
        temp.titleLabel?.font = UIFont.regular(16)
        temp.setTitleColor(ADTheme.C1, for: UIControl.State.disabled)
        temp.setTitleColor(UIColor.white, for: UIControl.State.normal)
        temp.layer.borderColor = ADTheme.Theme.cgColor
        temp.setBackgroundImage(UIImage.buttonNormallImage, for: .normal)
        temp.setBackgroundImage(UIImage.buttonPressImage, for: .highlighted)
        temp.setBackgroundImage(UIImage.init(color: UIColor.white), for: .disabled)
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "save"), for: .normal)
        temp.clipsToBounds = true
        temp.addTarget(self, action: #selector(saveBtnAction), for: .touchUpInside)
        self.setBgView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(-16.auto())
            make.leading.equalTo(self.resetBtn.snp.trailing).offset(16.auto());
            make.height.equalTo(50.auto())
            make.centerY.equalTo(self.resetBtn.snp.centerY)
        })
        temp.layer.masksToBounds = true
        temp.layer.cornerRadius = 25.auto()



        return temp
    }()
    
    
    @objc private func resetBtnAction() {
        self.shouldUpdate = true
        A4xVideoLibraryFilterModel.clear()
        self.filterData?.clearAll()
        self.tableView.reloadData()
    }
    
    
    @objc private func saveBtnAction() {
        self.saveFilterData()
        self.back()
    }
    
    
    //MARK:- UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var titleStr : String?
        let c = self.allTagsModel?.devices?.count ?? 0
        if section == 0 && c > 0 {
            titleStr = A4xBaseManager.shared.getLocalString(key: "camera")
            if c == 0 {
                return nil
            }
        } else if section == 1 && self.allVideoTags?.count ?? 0 > 0 {
            titleStr = A4xBaseManager.shared.getLocalString(key: "video_tag")
        } else if section == 2 && self.allTagsModel?.operateOptions?.count ?? 0 > 0 {
            titleStr = A4xBaseManager.shared.getLocalString(key: "other")
        }
        let header: A4xFilterSesstionView = A4xFilterSesstionView(frame: CGRect.zero, titleString: titleStr)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let c = self.allTagsModel?.devices?.count ?? 0
        if section == 0 && c == 0 {
            return 0.01
        } else if section == 1 && (allVideoTags?.count ?? 0 == 0) {
            return 0.01
        } else if section == 2 && (allTagsModel?.operateOptions?.count ?? 0 == 0) {
            return 0.01
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 68
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if A4xUserDataHandle.Handle?.netConnectType == .nonet {
                return 1
            }
            return self.allTagsModel?.devices?.count ?? 0
        } else if section == 1 {
            return allVideoTags?.count ?? 0
        } else if section == 2 {
            return allTagsModel?.operateOptions?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if A4xUserDataHandle.Handle?.netConnectType == .nonet {
                return 10.auto()
            }
            return 132.auto()
        }





        if indexPath.section == 1 {
            if allVideoTags?.count ?? 0 == 0 {
                return 0.01
            } else {
                let sectionModel: FilterAiEventTag = allVideoTags?[indexPath.row] ?? FilterAiEventTag()
                var tempHeight = 0.01
                if sectionModel.name?.count ?? 0 > 0 {
                    tempHeight += 60.auto()
                }
                let subTags: [FilterAiSubTag] = sectionModel.subTags ?? []
                tempHeight += (Double(subTags.count) * 48.auto())
                return tempHeight
            }
        }
        if indexPath.section == 2 && (allTagsModel?.operateOptions?.count ?? 0 == 0) {
            return 0.01
        }
        return 60.auto()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        let bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-32.auto(), height: cell.contentView.bounds.height)
        var rectCorner : UIRectCorner = UIRectCorner.allCorners
        
        if indexPath.section == 0 {
            if self.allTagsModel?.devices?.count == 1 {
                rectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
            } else {
                if indexPath.row == 0 {
                    rectCorner = [.topLeft,.topRight]
                } else if (indexPath.row == ((self.allTagsModel?.devices!.count ?? 0) - 1)) {
                    rectCorner = [.bottomLeft,.bottomRight]
                } else {
                    cell.contentView.layer.mask = nil
                    return
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                rectCorner = [.topLeft,.topRight]
                if indexPath.row == ((self.allVideoTags?.count ?? 0) - 1) {
                    rectCorner = [.topLeft,.topRight,.bottomLeft,.bottomRight]
                }
            } else if indexPath.row == ((self.allVideoTags?.count ?? 0) - 1) {
                rectCorner = [.bottomLeft,.bottomRight]
            } else {
                cell.contentView.layer.mask = nil
                return
            }
        } else {
            if indexPath.row == 0 {
                rectCorner = [.topLeft,.topRight]
                if indexPath.row == ((allTagsModel?.operateOptions?.count ?? 0) - 1) {
                    rectCorner = [.bottomLeft,.bottomRight]
                }
            } else if indexPath.row == ((allTagsModel?.operateOptions?.count ?? 0) - 1) {
                rectCorner = [.bottomLeft,.bottomRight]
            } else {
                cell.contentView.layer.mask = nil
                return
            }
        }
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 10.auto() , height: 10.auto() ))
        let maskLayer : CAShapeLayer = CAShapeLayer()
        maskLayer.frame = cell.contentView.bounds
        maskLayer.path = path.cgPath
        cell.contentView.layer.mask = maskLayer
        cell.contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor


        cell.contentView.layer.shadowRadius = 7.5
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let identifier: String = "A4xFilterTagZoneCell_identifier"
            var zoneCell: A4xFilterTagZoneCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xFilterTagZoneCell
            if zoneCell == nil {
                zoneCell = A4xFilterTagZoneCell(style: .default, reuseIdentifier: identifier)
            }
            if A4xUserDataHandle.Handle?.netConnectType == .nonet { 
                zoneCell?.subAllButton.isHidden = true
                zoneCell?.subAllTitleLbl.isHidden = true
                return zoneCell!
            } else {
                zoneCell?.subAllButton.isHidden = false
                zoneCell?.subAllTitleLbl.isHidden = false
            }
            
            let deviceModel = self.allTagsModel?.devices?[indexPath.row]
            if (deviceModel != nil) {
                zoneCell?.deviceModel = deviceModel
            }
            zoneCell?.filterData = filterData
            
            
            //zoneCell?.allChecked = filterData?.isSelectAllZoneId(deviceId: deviceModel?.serialNumber ?? "") ?? false
            //isSelectDisplayZoneId(deviceId: "\(indexPath.section)_\(indexPath.row)_\(deviceModel?.serialNumber ?? "")_") ?? false
            
            
            let zonePointData = self.netDeviceImagesData?.filter { (zonePoint) -> Bool in
                deviceModel?.serialNumber == zonePoint.serialNumber
            }
            zoneCell?.netDeviceImagesData = zonePointData
            
            weak var weaSelf = self
            
            
            zoneCell?.selectAllIndexPathBlock = {() in
                
                weaSelf?.filterData?.clearAllDisplayZoneIds(deviceId: deviceModel?.serialNumber ?? "", isAllSub: true)
                if let devicName = deviceModel?.deviceName {
                    
                    let trail = "A4xFilterTagsViewController_allScreen"
                    let name = devicName + trail
                    
                    
                    weaSelf?.filterData?.changeSelectZoneIdToDisplay(deviceName: name, deviceId: "\(indexPath.section)_\(indexPath.row)_\(deviceModel?.serialNumber ?? "")_")
                    
                    weaSelf?.filterData?.changeSelectZoneIdToSave(deviceZoneId: 0, deviceId: deviceModel?.serialNumber ?? "", type: 3)
                }
            }
            
            
            zoneCell?.selectAllIndexPathDelBlock = {() in
                
                weaSelf?.filterData?.clearAllDisplayZoneIds(deviceId: "\(indexPath.section)_\(indexPath.row)_\(deviceModel?.serialNumber ?? "")_", isAllSub: false)
                
                weaSelf?.filterData?.changeSelectZoneIdToSave(deviceZoneId: 0, deviceId: deviceModel?.serialNumber ?? "", type: 2)
                
            }
            
            zoneCell?.filterZoneIdAddBlock = { (zoneName, zoneId ,serialNumber) in
                
                
                weaSelf?.filterData?.clearAllDisplayZoneIds(deviceId: "\(indexPath.section)_\(indexPath.row)_\(deviceModel?.serialNumber ?? "")_", isAllSub: false)
                
                if let devicName = deviceModel?.deviceName {
                    
                    let name = devicName + "・" + zoneName
                    
                    
                    weaSelf?.filterData?.changeSelectZoneIdToDisplay(deviceName: name, deviceId: "\(indexPath.section)_\(indexPath.row)_\(deviceModel?.serialNumber ?? "")_\(zoneId ?? 0)")
                    
                    
                    weaSelf?.filterData?.changeSelectZoneIdToSave(deviceZoneId: zoneId ?? 0, deviceId: deviceModel?.serialNumber ?? "", type: 1)
                }
            }
            
            zoneCell?.filterZoneIdDelBlock = { (zoneName, zoneId, serialNumber) in 
                
                weaSelf?.filterData?.changeSelectZoneIdToDisplay(deviceName: zoneName, deviceId: "\(indexPath.section)_\(indexPath.row)_\(deviceModel?.serialNumber ?? "")_\(zoneId ?? 0)")
                
                weaSelf?.filterData?.changeSelectZoneIdToSave(deviceZoneId: zoneId ?? 0, deviceId: deviceModel?.serialNumber ?? "", type: 0)
            }
            
            zoneCell?.pushRemindAreaBlock = {
                var tempModel = DeviceBean()
                tempModel.serialNumber = deviceModel?.serialNumber
                tempModel.apModeType = A4xDeviceAPModeType.WiFi
                Resolver.deviceSettingImpl.pushActivityZoneViewController(deviceModel: tempModel, navigationController: weaSelf?.navigationController)
            }
            return zoneCell!
        } else {
            let normalCell: A4xFilterTagNormalCell? = tableView.dequeueReusableCell(withIdentifier: "A4xFilterTagNormalCell") as? A4xFilterTagNormalCell
            
            normalCell?.protocol = self
            normalCell?.indexPath = indexPath
            
            if indexPath.section == 1 {
                let sectionModel: FilterAiEventTag = allVideoTags?[indexPath.row] ?? FilterAiEventTag()
                let tagName = sectionModel.name ?? ""
                if tagName == "DEVICE_CALL" { 
                    normalCell?.iconImage = bundleImageFromImageName("main_libary_device_call")?.rtlImage()
                    normalCell?.filterName = A4xBaseManager.shared.getLocalString(key: "library_sign")
                    normalCell?.checked = filterData?.isSelect(tag: A4xVideoTag.device_call) ?? false
                } else if tagName == "DOORBELL_PRESS" { 
                    normalCell?.iconImage = bundleImageFromImageName("main_libary_doorbell_press")?.rtlImage()
                    normalCell?.filterName = A4xBaseManager.shared.getLocalString(key: "setting_db_ring")
                    normalCell?.checked = filterData?.isSelect(tag: A4xVideoTag.doorbell_press) ?? false
                } else if tagName == "DOORBELL_REMOVE" { 
                    normalCell?.iconImage = bundleImageFromImageName("main_libary_doorbell_remove")?.rtlImage()
                    normalCell?.filterName = A4xBaseManager.shared.getLocalString(key: "setting_db_remove")
                    normalCell?.checked = filterData?.isSelect(tag: A4xVideoTag.doorbell_remove) ?? false
                } else if tagName == "bird" { 
                    normalCell?.iconImage = bundleImageFromImageName("main_libary_bird")?.rtlImage()
                    normalCell?.filterName = A4xBaseManager.shared.getLocalString(key: "bird")
                    normalCell?.checked = filterData?.isSelect(tag: A4xVideoTag.bird) ?? false
                } else if tagName == "person" { 
                    normalCell?.iconImage = bundleImageFromImageName("main_libary_people")?.rtlImage()
                    normalCell?.filterName = A4xBaseManager.shared.getLocalString(key: "notification_detection_people")
                    normalCell?.checked = filterData?.isSelect(tag: A4xVideoTag.person) ?? false
                } else if tagName == "pet" { 
                    normalCell?.iconImage = bundleImageFromImageName("main_libary_pet")?.rtlImage()
                    normalCell?.filterName = A4xBaseManager.shared.getLocalString(key: "ai_pet")
                    normalCell?.checked = filterData?.isSelect(tag: A4xVideoTag.pet) ?? false
                } else if tagName == "vehicle" { 
                    normalCell?.iconImage = bundleImageFromImageName("main_libary_vehicle")?.rtlImage()
                    normalCell?.filterName = A4xBaseManager.shared.getLocalString(key: "ai_car")
                    normalCell?.checked = filterData?.isSelect(tag: A4xVideoTag.vehicle) ?? false
                    subVehicleCellHeight = normalCell?.configVehicelSubTags(subTags: sectionModel.subTags ?? []) ?? 0
                    
                    normalCell?.subVehicelChecked = [filterData?.isSelect(tag: A4xVideoTag.vehicle_enter) ?? false,
                                               filterData?.isSelect(tag: A4xVideoTag.vehicle_out)   ?? false,
                                               filterData?.isSelect(tag: A4xVideoTag.vehicle_held_up) ?? false]
                } else if tagName == "package" { 
                    normalCell?.iconImage = bundleImageFromImageName("main_libary_package")?.rtlImage()
                    normalCell?.filterName = A4xBaseManager.shared.getLocalString(key: "package_tag")
                    normalCell?.checked = filterData?.isSelect(tag: A4xVideoTag.box) ?? false
                    subPackageCellHeight = normalCell?.configPackageSubTags(subTags: sectionModel.subTags ?? []) ?? 0
                    
                    normalCell?.subPackageChecked = [filterData?.isSelect(tag: A4xVideoTag.package_drop_off) ?? false, filterData?.isSelect(tag: A4xVideoTag.package_pick_up) ?? false, filterData?.isSelect(tag: A4xVideoTag.package_exist) ?? false]
                }
            } else if indexPath.section == 2 {
                let model: FilterAiEventTag = self.allTagsModel?.operateOptions?[indexPath.row] ?? FilterAiEventTag()
                if model.name == "missing" {
                    normalCell?.iconImage = bundleImageFromImageName("main_libary_unread_icon")?.rtlImage()
                    normalCell?.filterName = A4xBaseManager.shared.getLocalString(key: "missed")
                    normalCell?.checked = filterData?.isSelect(other: A4xSourceOther.unread) ?? false
                } else if model.name == "marked" {
                    normalCell?.iconImage = bundleImageFromImageName("main_libary_mark_icon")?.rtlImage()
                    normalCell?.filterName = A4xBaseManager.shared.getLocalString(key: "mark")
                    normalCell?.checked = filterData?.isSelect(other: A4xSourceOther.mark) ?? false
                }
            }
            return normalCell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
        } else if indexPath.section == 1 {
            let sectionModel: FilterAiEventTag = allVideoTags?[indexPath.row] ?? FilterAiEventTag()
            let tagName = sectionModel.name ?? ""
            if tagName == "DEVICE_CALL" { 
                filterData?.change_select(tag: .device_call)
            } else if tagName == "DOORBELL_PRESS" { 
                filterData?.change_select(tag: .doorbell_press)
            } else if tagName == "DOORBELL_REMOVE" { 
                filterData?.change_select(tag: .doorbell_remove)
            } else if tagName == "bird" { 
                filterData?.change_select(tag: .bird)
            } else if tagName == "person" {
                filterData?.change_select(tag: .person)
            } else if tagName == "pet" {
                filterData?.change_select(tag: .pet)
            } else if tagName == "vehicle" {
                self.tableView.deselectRow(at: indexPath, animated: true)
            } else if tagName == "package" {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        } else if indexPath.section == 2 {
            let model: FilterAiEventTag = self.allTagsModel?.operateOptions?[indexPath.row] ?? FilterAiEventTag()
            if model.name == "marked" {
                filterData?.change_select(other: .mark)
            } else if model.name == "missing" {
                filterData?.change_select(other: .unread)
            }
        }
        

        UIView.performWithoutAnimation {
            //关闭CALayer的隐式动画
            CATransaction.setDisableActions(true)
            self.tableView.reloadRows(at: [indexPath], with: .none)
            CATransaction.commit()
        }

        self.shouldUpdate = true
    }
    
}

extension A4xFilterTagsViewController: A4xFilterTagNormalCellProtocol {
    
    func checkCellClick(sender: UIButton, indexPath: IndexPath) {
        let tagModel = allVideoTags?[indexPath.row]
        let tagName = tagModel?.name
        if tagName == "vehicle" { 
            switch sender.tag {
            case 1:
                filterData?.change_select(tag: .vehicle_enter)
                break
            case 2:
                filterData?.change_select(tag: .vehicle_out)
                break
            case 3:
                filterData?.change_select(tag: .vehicle_held_up)
                break
            default:
                break
            }
        } else if tagName == "package" { 
            switch sender.tag {
            case 1:
                filterData?.change_select(tag: .package_drop_off)
                break
            case 2:
                filterData?.change_select(tag: .package_pick_up)
                break
            case 3:
                filterData?.change_select(tag: .package_exist)
                break
            default:
                break
            }
        }
        self.tableView.reloadData()
        self.shouldUpdate = true
    }
}
