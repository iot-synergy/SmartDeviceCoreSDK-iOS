//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol A4xDevicesInviteInfoCellProtocol: class {
    func devicesCellSwicth(flag: Bool, type: A4xDevicesInviteInfoEnum?)
    func devicesCellSelect(type: A4xDevicesInviteInfoEnum?)
    func devicesCellClick(sender: UIControl, type: A4xDevicesInviteInfoEnum?)
}

class A4xDevicesInviteInfoCell: UITableViewCell {
    weak var `protocol`: A4xDevicesInviteInfoCellProtocol?
    var type: A4xDevicesInviteInfoEnum?
    
    var qrcodeImg: UIImage? {
        didSet {
            self.qrCodeImageV.image = qrcodeImg
            self.errorView.isHidden = true
            self.errorMsg.isHidden = true
        }
    }
    
    func setModelCategory(modelCategory: Int)
    {
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: modelCategory)
        self.titleLbl.text = A4xBaseManager.shared.getLocalString(key: "use_app_scan", param: [ADTheme.APPName, tempString])
    }
    
    var expireDate: String? {
        didSet {
            
            self.expiringDateLbl.text = A4xBaseManager.shared.getLocalString(key: "qr_expire", param: [expireDate ?? ""])
            self.expiringDateLbl.snp.remakeConstraints({ (make) in
                make.top.equalTo(self.qrCodeImageV.snp.bottom).offset(24.auto())
                make.centerX.equalTo(self.contentView.snp.centerX).offset(13.auto())
                make.width.lessThanOrEqualTo(self.contentView.snp.width).multipliedBy(0.85)
            })
            self.expiringDateLbl.layoutIfNeeded()
            self.updateUI()
        }
    }
    
    var errMsg: String? {
        didSet {
            self.errorMsg.text = errMsg
            self.errorView.isHidden = false
            self.errorMsg.isHidden = false
        }
    }
    
    var cellHeight: CGFloat = 0
    var defCellHeight: CGFloat = 0
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
        self.titleLbl.isHidden = false
        self.qrCodeImageV.isHidden = false
        self.errorView.isHidden = true
        self.errorMsg.isHidden = true
        self.expiringDateLbl.isHidden = false
        defCellHeight = cellHeight
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var titleLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "use_app_scan", param: [ADTheme.APPName])
        lbl.textColor = ADTheme.C1
        lbl.font = ADTheme.B1
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.top.equalTo(self.contentView.snp.top).offset(24.auto())
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.width.equalTo(self.contentView.width - 64.auto())
        })
        lbl.layoutIfNeeded()
        cellHeight += lbl.height + 24.auto()
        return lbl
    }()
    
    private lazy var qrCodeImageV: UIImageView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.clear
        let longPressGes =  UILongPressGestureRecognizer(target: self, action: #selector(qrcodeImageViewLongPress(longPress:)))
        longPressGes.minimumPressDuration = 1.0
        temp.addGestureRecognizer(longPressGes)
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalTo(self.titleLbl.snp.bottom).offset(24.auto())
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                make.width.height.equalTo(UIScreen.main.bounds.size.width * 0.5)
            } else {
                
                make.width.height.equalTo(self.contentView.snp.width).multipliedBy(0.85)
            }
        })
        temp.layoutIfNeeded()
        
        let imageV = UIImageView()
        imageV.backgroundColor = ADTheme.C6
        imageV.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageV)
        
        imageV.snp.makeConstraints({ (make) in
            make.center.equalTo(temp.snp.center)
            make.width.equalTo(temp.snp.width)
            make.height.equalTo(imageV.snp.width)
        })
        imageV.layoutIfNeeded()
        cellHeight += imageV.height + 24.auto()
        return imageV
    }()
    
    @objc public func qrcodeImageViewLongPress(longPress: UILongPressGestureRecognizer)
    {
        switch longPress.state {
        case .began:
            break;
        case .changed:
            //
            break;
        case .ended:
            break;
        default:
            break
        }
    }
    
    private lazy var errorView: UIControl = {
        let temp = UIControl()
        temp.isHidden = true
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.center.equalTo(self.qrCodeImageV.snp.center)
            make.width.equalTo(self.qrCodeImageV.snp.width)
            make.height.equalTo(self.qrCodeImageV.snp.height)
        })
        temp.addTarget(self, action: #selector(reLoadQrCode(_:)), for: .touchUpInside)
        return temp
    }()
    
    private lazy var errorMsg: UILabel = {
        let errorIcon = UIImageView()
        errorIcon.image = bundleImageFromImageName("join_device_qrcode_error")?.rtlImage()
        self.errorView.addSubview(errorIcon)
        
        errorIcon.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.errorView.snp.centerX)
            make.centerY.equalTo(self.errorView.snp.centerY).offset(-12)
        })
        
        let errorMsg = UILabel()
        errorMsg.backgroundColor = UIColor.clear
        errorMsg.text = A4xBaseManager.shared.getLocalString(key: "error_message")
        errorMsg.font = ADTheme.B2
        errorMsg.textAlignment = .center
        errorMsg.lineBreakMode = .byWordWrapping
        errorMsg.numberOfLines = 0
        errorMsg.textColor = ADTheme.C2
        self.errorView.addSubview(errorMsg)
        errorMsg.snp.makeConstraints({ (make) in
            make.top.equalTo(errorIcon.snp.bottom).offset(5)
            make.centerX.equalTo(errorIcon.snp.centerX)
            make.width.equalTo(self.errorView.snp.width).offset(-70)
        })
        return errorMsg
    }()
    
    
    private lazy var expiringDateLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "qr_expire", param: ["2002年8月13日20:00"])
        lbl.textColor = ADTheme.C3
        lbl.font = ADTheme.B2
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.top.equalTo(self.qrCodeImageV.snp.bottom).offset(24.auto())
            make.centerX.equalTo(self.contentView.snp.centerX).offset(13.auto())
            make.width.lessThanOrEqualTo(self.contentView.snp.width).multipliedBy(0.85)
        })
        lbl.layoutIfNeeded()
        cellHeight += lbl.height + 24.auto() + 32.auto()
        return lbl
    }()

    func getCellHeight() -> CGFloat {
        return cellHeight
    }
    
    private func updateUI() {
        self.layoutIfNeeded()
        if A4xBaseAppLanguageType.language() == .chinese {
            cellHeight = defCellHeight + expiringDateLbl.height + 30.auto()
        } else {
            cellHeight = defCellHeight + expiringDateLbl.height
        }
    }
    
     @objc func reLoadQrCode(_ sender: UIControl) {
        self.protocol?.devicesCellClick(sender: sender, type: self.type)
    }
}

class A4xDevicesInviteGuideCell: UITableViewCell {
    weak var `protocol`: A4xDevicesInviteInfoCellProtocol?
    var type: A4xDevicesInviteInfoEnum?
    
    var qrcodeImg: UIImage? {
        didSet {



        }
    }
    
    var expireDate: String? {
        didSet {
            //self.expiringDateLbl.text = A4xBaseManager.shared.getLocalString(key: "qr_expire", param: [expireDate ?? ""])
            self.updateUI()
        }
    }
    
    var errMsg: String? {
        didSet {



        }
    }
    
    var cellHeight: CGFloat = 0
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
        
        self.permissionImgView.isHidden = false
        self.permissionLbl.isHidden = false
        self.permissionIntroLbl.isHidden = false
        
        self.lineView.isHidden = false
        
        self.addShareDeviceImgView.isHidden = false
        self.addShareDeviceLbl.isHidden = false
        
        self.tip1ImgView.isHidden = false
        self.tip1Lbl.isHidden = false
        
        self.tip2ImgView.isHidden = false
        self.tip2Lbl.isHidden = false
        self.addShareGuide2ImgView.isHidden = false
        
        self.tip3ImgView.isHidden = false
        self.tip3Lbl.isHidden = false
        self.addShareGuide3ImgView.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var permissionImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = A4xDeviceSettingResource.UIImage(named: "device_share_permission")?.rtlImage()
        self.contentView.addSubview(iv)
        iv.snp.makeConstraints({ (make) in
            make.top.equalTo(self.contentView.snp.top).offset(21.auto())
            make.leading.equalTo(self.contentView.snp.leading).offset(16.auto())
            make.width.height.equalTo(24.auto())
        })
        iv.layoutIfNeeded()
        return iv
    }()
    
    
    private lazy var permissionLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "permission")
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.heavy(17)
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.permissionImgView.snp.trailing).offset(8.auto())
            make.centerY.equalTo(self.permissionImgView.snp.centerY)
            make.width.lessThanOrEqualTo(self.contentView.width - 32.auto())
        })
        lbl.layoutIfNeeded()
        cellHeight += max(lbl.height, permissionImgView.height) + 21.auto()
        return lbl
    }()
    
    
    private lazy var permissionIntroLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "invite_title_des")
        lbl.textColor = ADTheme.C2
        lbl.font = UIFont.regular(14)
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.permissionImgView.snp.leading).offset(0.auto())
            make.top.equalTo(self.permissionLbl.snp.bottom).offset(8.auto())
            make.width.lessThanOrEqualTo(self.contentView.width - 32.auto())
        })
        lbl.layoutIfNeeded()
        cellHeight += lbl.height + 8.auto()
        return lbl
    }()
    
    
    private lazy var lineView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.colorFromHex("#DADBE0")
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.top.equalTo(self.permissionIntroLbl.snp.bottom).offset(16.auto())
            make.leading.equalTo(16.auto())
            make.width.equalTo(self.contentView.snp.width).offset(-32.auto())
            make.height.equalTo(0.5)
        }
        cellHeight += temp.height + 16.auto()
        return temp
    }()
    
    
    private lazy var addShareDeviceImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = A4xDeviceSettingResource.UIImage(named: "device_share_add_guide")?.rtlImage()
        self.contentView.addSubview(iv)
        iv.snp.makeConstraints({ (make) in
            make.top.equalTo(self.lineView.snp.bottom).offset(16.auto())
            make.leading.equalTo(self.lineView.snp.leading).offset(0)
            make.width.height.equalTo(24.auto())
        })
        iv.layoutIfNeeded()
        return iv
    }()
    
    
    private lazy var addShareDeviceLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "hao_to_invite")
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.heavy(17)
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.addShareDeviceImgView.snp.centerY).offset(0.auto())
            make.leading.equalTo(self.addShareDeviceImgView.snp.trailing).offset(8.auto())
            make.width.lessThanOrEqualTo(self.contentView.width - 32.auto())
        })
        lbl.layoutIfNeeded()
        cellHeight += max(lbl.height, addShareDeviceImgView.height) + 16.auto()
        return lbl
    }()
    
    
    lazy var tip1ImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.contentMode = .center
        iv.image = bundleImageFromImageName("add_camera_err_tip_1")
        self.contentView.addSubview(iv)
        iv.snp.makeConstraints({ (make) in
            make.top.equalTo(self.addShareDeviceLbl.snp.bottom).offset(24.auto())
            make.leading.equalTo(self.contentView.snp.leading).offset(16.auto())
            make.width.height.equalTo(20.auto())
        })
        iv.layoutIfNeeded()
        return iv
    }()
    
    
    lazy var tip1Lbl: UILabel = {
        var lbl: UILabel = UILabel()
        let attrString = NSMutableAttributedString(string:
            A4xBaseManager.shared.getLocalString(key: "invite_info_des", param: [ADTheme.APPName])
        )
        
        let param = NSMutableParagraphStyle()
        param.alignment = .left
        param.lineSpacing = 3
        
        attrString.addAttribute(.paragraphStyle, value: param, range: NSRange(location: 0, length: attrString.string.count))
        
        attrString.addAttribute(.font, value: UIFont.regular(14), range: NSRange(location: 0, length: attrString.string.count))
        
        attrString.addAttribute(.foregroundColor, value: ADTheme.C2, range: NSRange(location: 0, length: attrString.string.count))
        
        attrString.string.ranges(of: ADTheme.APPName).forEach { [weak attrString](range) in
            attrString?.addAttribute(.foregroundColor, value: ADTheme.C1, range: range)
            attrString?.addAttribute(.font, value: UIFont.regular(14), range: range)
        }
        lbl.attributedText = attrString
        lbl.numberOfLines = 0
        //lbl.textColor = ADTheme.C2
        //lbl.textAlignment = .left
        //lbl.font = UIFont.regular(14)
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.top.equalTo(self.tip1ImgView.snp.top).offset(0)
            make.leading.equalTo(self.tip1ImgView.snp.trailing).offset(10.auto())
            make.width.lessThanOrEqualTo(self.contentView.width - 32.auto())
        })
        lbl.layoutIfNeeded()
        cellHeight += max(lbl.height, tip1ImgView.height) + 24.auto()
        return lbl
    }()
    
    
    lazy var tip2ImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.contentMode = .center
        iv.image = bundleImageFromImageName("add_camera_err_tip_2")
        self.contentView.addSubview(iv)
        iv.snp.makeConstraints({ (make) in
            make.top.equalTo(self.tip1Lbl.snp.bottom).offset(16.auto())
            make.centerX.equalTo(self.tip1ImgView.snp.centerX).offset(0)
            make.width.height.equalTo(20.auto())
        })
        iv.layoutIfNeeded()
        return iv
    }()
    
    
    lazy var tip2Lbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        lbl.text = A4xBaseManager.shared.getLocalString(key: "how_to_add_friend_camera")
        lbl.textColor = ADTheme.C2
        lbl.font = UIFont.regular(14)
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.top.equalTo(self.tip2ImgView.snp.top).offset(0)
            make.leading.equalTo(self.tip2ImgView.snp.trailing).offset(10.auto())
            make.width.lessThanOrEqualTo(self.contentView.width - 32.auto())
        })
        lbl.layoutIfNeeded()
        cellHeight += max(lbl.height, tip2ImgView.height) + 16.auto()
        return lbl
    }()
    
    
    private lazy var addShareGuide2ImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = A4xDeviceSettingResource.UIImage(named: "device_share_guide_2")?.rtlImage()
        self.contentView.addSubview(iv)
        iv.snp.makeConstraints({ (make) in
            make.top.equalTo(self.tip2Lbl.snp.bottom).offset(16.auto())
            make.centerX.equalTo(self.contentView.snp.centerX).offset(0.auto())
            make.size.equalTo(CGSize(width: 274.auto(), height: 235.auto()))
        })
        
        var quitIV: UIImageView = UIImageView()
        quitIV.image = A4xDeviceSettingResource.UIImage(named: "icon_share_quit")?.rtlImage()
        iv.addSubview(quitIV)
        quitIV.snp.makeConstraints { (make) in
            make.top.equalTo(iv.snp.top).offset(54.5.auto())
            make.trailing.equalTo(iv.snp.trailing).offset(-42.auto())
            make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
        }
        
        iv.layoutIfNeeded()
        cellHeight += iv.height + 16.auto()
        return iv
    }()
    
    
    lazy var tip3ImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.contentMode = .center
        iv.image = bundleImageFromImageName("add_camera_err_tip_3")
        self.contentView.addSubview(iv)
        iv.snp.makeConstraints({ (make) in
            make.top.equalTo(self.addShareGuide2ImgView.snp.bottom).offset(23.5.auto())
            make.centerX.equalTo(self.tip2ImgView.snp.centerX).offset(0.auto())
            make.width.height.equalTo(20.auto())
        })
        iv.layoutIfNeeded()
        return iv
    }()
    
    
    lazy var tip3Lbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        lbl.text = A4xBaseManager.shared.getLocalString(key: "get_use_permission", param: [ADTheme.APPName])
        lbl.textColor = ADTheme.C2
        lbl.font = UIFont.regular(14)
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.top.equalTo(self.tip3ImgView.snp.top).offset(0)
            make.leading.equalTo(self.tip3ImgView.snp.trailing).offset(10.auto())
            make.width.lessThanOrEqualTo(self.contentView.width - 32.auto())
        })
        lbl.layoutIfNeeded()
        cellHeight += max(lbl.height, tip3ImgView.height) + 23.auto()
        return lbl
    }()
    
    
    private lazy var addShareGuide3ImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = A4xDeviceSettingResource.UIImage(named: "device_share_guide_3")?.rtlImage()
        self.contentView.addSubview(iv)
        iv.snp.makeConstraints({ (make) in
            make.top.equalTo(self.tip3Lbl.snp.bottom).offset(16.auto())
            make.centerX.equalTo(self.contentView.snp.centerX).offset(0.auto())
            make.size.equalTo(CGSize(width: 274.auto(), height: 235.auto()))
        })
        
        var scanIV: UIImageView = UIImageView()
        scanIV.image = bundleImageFromImageName("join_device_scan_animail")?.rtlImage()
        iv.addSubview(scanIV)
        scanIV.snp.makeConstraints { (make) in
            make.centerX.equalTo(iv.snp.centerX)
            make.centerY.equalTo(iv.snp.centerY).offset(20.auto())
            make.size.equalTo(CGSize(width: 224.5.auto(), height: 101.5.auto()))
        }
        
        iv.layoutIfNeeded()
        cellHeight += iv.height + 16.auto() + 31.auto()
        return iv
    }()

    func getCellHeight() -> CGFloat {
        return cellHeight
    }
    
    private func updateUI() {
        self.layoutIfNeeded()
    }
}

