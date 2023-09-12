//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDevicesShareInviteViewController: A4xBaseViewController {
    //var deviceId : String?
    var deviceModel: DeviceBean?
    private var viewModle : A4xDeviceShareViewModel = A4xDeviceShareViewModel()
    
    private var cellInfos: [[A4xDevicesInviteInfoModel]]?
    
    private var qrCodeImg: UIImage?
    private var expireDate: Int?
    private var isErrView: Bool?
    private var errMsg: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNavtion()
        
        self.tableView.isHidden = false
        



        
        DispatchQueue.main.a4xAfter(0.05) {
            self.loadQrdata()
        }
        
    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "invite").capitalized
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
        temp.backgroundColor = .clear
        temp.tableFooterView = UIView()
        temp.accessibilityIdentifier = "tableView"
        temp.separatorInset = .zero
        temp.separatorStyle = .none
        temp.separatorColor = UIColor.clear
        temp.estimatedRowHeight = 80
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
    
    private func loadQrdata() {
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading"), bgColor : UIColor.clear) { (r) in }
        
        weak var weakSelf = self
        self.viewModle.loadShareQrcode(deviceID: self.deviceModel?.serialNumber ?? "") { (flag, shareId, expireDate, code, error) in
            weakSelf?.view.hideToastActivity {
                if flag && shareId != nil {
                    weakSelf?.isErrView = false
                    weakSelf?.tableView.hiddNoDataView()
                    UIImage.generateQrcode(codeString: shareId!) { (image) in
                        weakSelf?.qrCodeImg = image
                        weakSelf?.expireDate = expireDate
                        self.cellInfos = A4xDevicesInviteInfoEnum.cases()
                        self.tableView.reloadData()
                    }
                } else {
                    weakSelf?.qrCodeImg = nil
                    weakSelf?.isErrView = true
                    weakSelf?.errMsg = error
                    weakSelf?.view.makeToast(error)
                    weakSelf?.tableView.reloadData()
                    
                    if code == -1009 {
                        var errorStr = A4xAppErrorConfig(code: code).message()
                        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
                            errorStr = A4xBaseManager.shared.getLocalString(key: "phone_no_net")
                        }
                        
                        let compleBlock: () -> Void = {
                            
                            weakSelf?.loadQrdata()
                            //weakSelf?.tableView.mj_header?.beginRefreshing()
                        }
                        
                        
                        weakSelf?.tableView.adReloadData(error: errorStr, noDataTip: A4xBaseManager.shared.getLocalString(key: "nodata_libary_tip"), noDataImage: bundleImageFromImageName("home_libary_no_data")?.rtlImage(), noDataType: .normal, comple: compleBlock)
                    }
                }
            }
        }
    }
    
    @objc private func reLoadQrCode(){
        self.isErrView = false
        self.loadQrdata()
    }
}

extension A4xDevicesShareInviteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let qrcodeModel: A4xDevicesInviteInfoModel = self.cellInfos![indexPath.section][indexPath.row]
        switch qrcodeModel.type {
        case .qrcodeShow:
            return qrcodeModel.cellHeight ?? 415.5.auto()
        case .qrcodeGuide:
            return qrcodeModel.cellHeight ?? 826.5.auto()
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
        var qrcodeModel: A4xDevicesInviteInfoModel = self.cellInfos![indexPath.section][indexPath.row]
        
        if qrcodeModel.type == .qrcodeShow {
            let identifier = "A4xDevicesInviteInfoCell"
            var tableCell: A4xDevicesInviteInfoCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesInviteInfoCell
            
            if (tableCell == nil) {
                tableCell = A4xDevicesInviteInfoCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            }
            
            let type = qrcodeModel.type
            tableCell?.type = type
            tableCell?.protocol = self
            tableCell?.errMsg = self.errMsg
            tableCell?.setModelCategory(modelCategory: self.deviceModel?.modelCategory ?? 1)
            let is24HrFormatStr = "".timeFormatIs24Hr() ? kA4xDateFormat_24 : kA4xDateFormat_12
            
            var languageFormat = ""
            
            if A4xBaseAppLanguageType.language() == .chinese || A4xBaseAppLanguageType.language() == .Japanese {
                languageFormat = "\(A4xUserDataHandle.Handle?.getBaseDateFormatStr() ?? A4xBaseManager.shared.getLocalString(key: "terminated_format")) \(is24HrFormatStr)"
            } else {
                languageFormat = "\(is24HrFormatStr), \(A4xUserDataHandle.Handle?.getBaseDateFormatStr() ?? A4xBaseManager.shared.getLocalString(key: "terminated_format"))"
            }
            
            let dataString = DateFormatter.format(languageFormat).string(from: Date(timeIntervalSince1970: TimeInterval(self.expireDate ?? Int(Date().timeIntervalSince1970))))
            
            tableCell?.expireDate = dataString
            tableCell?.qrcodeImg = self.qrCodeImg
            qrcodeModel.cellHeight = tableCell?.getCellHeight() ?? 415.5.auto()
            cellInfos![indexPath.section][indexPath.row] = qrcodeModel
            return tableCell!
        } else {
            let identifier = "A4xDevicesInviteGuideCell"
            var tableCell: A4xDevicesInviteGuideCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesInviteGuideCell
            
            if (tableCell == nil) {
                tableCell = A4xDevicesInviteGuideCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            }
            
            tableCell?.type = qrcodeModel.type
            tableCell?.protocol = self
            qrcodeModel.cellHeight = tableCell?.getCellHeight() ?? 826.5.auto()
            cellInfos![indexPath.section][indexPath.row] = qrcodeModel
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

extension A4xDevicesShareInviteViewController: A4xDevicesInviteInfoCellProtocol {
    func devicesCellSwicth(flag: Bool, type: A4xDevicesInviteInfoEnum?) { }
    func devicesCellSelect(type: A4xDevicesInviteInfoEnum?) { }
    func devicesCellClick(sender: UIControl, type: A4xDevicesInviteInfoEnum?) {
        if type == .qrcodeShow {
            self.reLoadQrCode()
        }
    }
}
