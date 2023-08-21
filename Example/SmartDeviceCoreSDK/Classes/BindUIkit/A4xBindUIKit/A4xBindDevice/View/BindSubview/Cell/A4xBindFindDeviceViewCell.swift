//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

public protocol A4xBindFindDeviceViewCellProtocol: AnyObject {
    func cellClickAction(model: BindDeviceModel)
}

class A4xBindFindDeviceViewCell: UITableViewCell {
    var cellHeight: CGFloat = 0
    
    weak var `protocol`: A4xBindFindDeviceViewCellProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = UIColor.colorFromHex("#F5F6FA")
        self.selectedBackgroundView?.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectedBackgroundView?.backgroundColor = .clear
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.contentView.backgroundColor = highlighted ? UIColor.colorFromHex("#D4D3D9") : UIColor.colorFromHex("#F5F6FA")
        self.selectedBackgroundView?.backgroundColor = .clear
    }

    override func select(_ sender: Any?) {
        super.select(sender)
    }
    
    var model: (BindDeviceModel?, CGFloat?) {
        didSet {
            
            cellHeight = 12.auto()
            
            nameLbl.text = (model.0?.displayModelNo?.isBlank ?? true) ? model.0?.modelNo : model.0?.displayModelNo ?? ""
            
            cellHeight += 22.5.auto()
            
            snLbl.text = "S/N:\(model.0?.userSn ?? "")"
            
            cellHeight += 20.auto()
            
            let multicastInfoModel = model.0?.getMulticastInfoModel()
            if multicastInfoModel != nil {
                if multicastInfoModel?.wiredMac?.isBlank ?? true {
                    self.wiredStateBtn.isHidden = true
                } else {
                    self.wiredStateBtn.isHidden = false
                    
                    let wiredMacStr: String = "\(A4xBaseManager.shared.getLocalString(key: "find_device_mac_wire"))\(multicastInfoModel?.wiredMac ?? "")"
                    let wiredMacStrWidth = wiredMacStr.width(font: ADTheme.B3, wordSpace: 0)//A4xBaseManager.shared.getLocalString(key: "Ethernet：", param: [wiredMacStr]).width(font: ADTheme.B3, wordSpace: 0)
                    let wiredMacStrMinWidth = min(wiredMacStrWidth + 14.auto() + 15.auto() + 8.auto(), 229.auto())
                    self.wiredStateBtn.setTitle(wiredMacStr, for: .normal)
                    let wiredMacOffImg: UIImage = bundleImageFromImageName("bind_wired_offline")?.rtlImage() as! UIImage
                    let wiredMacOnImg: UIImage = bundleImageFromImageName("bind_wired_online")?.rtlImage() as! UIImage
                    self.wiredStateBtn.setImage((model.0?.isCable() ?? false) ? wiredMacOnImg : wiredMacOffImg, for: .normal)
                    
                    
                    self.wiredStateBtn.snp.updateConstraints { (make) in
                        make.width.equalTo(wiredMacStrMinWidth)
                    }
                    self.wiredStateBtn.layoutIfNeeded()
                    
                    cellHeight += 24.auto() + 8.auto()
                }
                
                if multicastInfoModel?.wirelessMac?.isBlank ?? true {
                    if model.0?.macAddress?.isBlank ?? true {
                        self.wifiStateBtn.isHidden = true
                    } else {
                        wifiMac(macStr: model.0?.macAddress ?? "")
                    }
                } else {
                    wifiMac(macStr: multicastInfoModel?.wirelessMac ?? "")
                }
            } else {
                self.wiredStateBtn.isHidden = true
                if model.0?.macAddress?.isBlank ?? true {
                    self.wifiStateBtn.isHidden = true
                } else {
                    wifiMac(macStr: model.0?.macAddress ?? "")
                }
            }
            
            cellHeight += 8.auto()
            let imgUrl: URL = URL.init(string: model.0?.icon ?? "") ?? URL(fileURLWithPath: "")
            iconIV.yy_setImage(with: imgUrl, placeholder: UIImage.init(color: ADTheme.C4)) { (receivedSize, expectedSize) in
            } transform: { [weak self] (image, url) in
                try? Disk.save(image, to: .documents, as: self?.model.0?.serialNumber ?? "default")
                return image
            } completion: { (image, url, type, stage, error) in

            }
            
            
            
            func wifiMac(macStr: String) {
                self.wifiStateBtn.isHidden = false
                
                //"Wi-Fi：\(macStr)"//
                let wifiMacStr: String = "\(A4xBaseManager.shared.getLocalString(key: "find_device_mac_wifi"))\(macStr)"
                let wifiMacImg: UIImage = bundleImageFromImageName("bind_type_wifi")?.rtlImage() as! UIImage
                let wifiMacStrWidth = wifiMacStr.width(font: ADTheme.B3, wordSpace: 0)
                let wifiMacStrMinWidth = min(wifiMacStrWidth + 14.auto() + 15.auto() + 8.auto(), 229.auto())
                self.wifiStateBtn.setTitle(wifiMacStr, for: .normal)
                self.wifiStateBtn.setImage(wifiMacImg, for: .normal)
                
                
                self.wifiStateBtn.snp.updateConstraints { (make) in
                    make.top.equalTo(self.snLbl.snp.bottom).offset(self.wiredStateBtn.isHidden ? 8.auto() : 36.auto())
                    make.width.equalTo(wifiMacStrMinWidth)
                }
                self.wifiStateBtn.layoutIfNeeded()
                
                cellHeight += 24.auto() + 4.auto()
            }
        }
    }
    
    private lazy var nameLbl: UILabel = {
        var temp = UILabel()
        temp.textAlignment = .left
        temp.textColor = ADTheme.C1
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        temp.font = ADTheme.H3
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.snp.top).offset(12.auto())
            make.leading.equalTo(self.snp.leading).offset(12.auto())
            make.width.lessThanOrEqualTo(self.contentView.snp.width).offset(-60)
        })
        return temp
    }()
    
    private lazy var snLbl: UILabel = {
        var temp = UILabel()
        temp.textAlignment = .center
        temp.textColor = ADTheme.C3
        temp.lineBreakMode = .byTruncatingTail
        temp.font = UIFont.regular(14)
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.nameLbl.snp.bottom)//.offset(9.5.auto())
            make.leading.equalTo(self.nameLbl.snp.leading).offset(0)
            make.width.lessThanOrEqualTo(self.contentView.snp.width).offset(-60)
        })
        return temp
    }()
    
    private lazy var wiredStateBtn: UIButton = {
        var btn: UIButton = UIButton()
        btn.titleLabel?.font = ADTheme.B3
        btn.isUserInteractionEnabled = false
        btn.setTitle("Ethernet：", for: UIControl.State.normal)
        btn.setTitleColor(ADTheme.C3, for: UIControl.State.normal)
        
        btn.setImage(bundleImageFromImageName("bind_wired_offline")?.rtlImage(), for: .normal)
        btn.layoutButton(.imageLeft, space: 8)
        btn.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#FFFFFF")), for: .normal)
        btn.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#D4D3D9")), for: .selected)
        //btn.addTarget(self, action: #selector(cellClickAction), for: .touchDragInside)

        btn.layer.cornerRadius = 9.5.auto()
        btn.clipsToBounds = true
        self.contentView.addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            make.top.equalTo(self.snLbl.snp.bottom).offset(8.auto())
            make.leading.equalTo(self.snLbl.snp.leading)
            make.height.equalTo(24.auto())
            make.width.equalTo(102.auto())
        })
        btn.layoutIfNeeded()
        return btn
    }()
    
    private lazy var wifiStateBtn: UIButton = {
        var btn: UIButton = UIButton()
        btn.titleLabel?.font = ADTheme.B3
        btn.isUserInteractionEnabled = false
        btn.setTitle("Wi-Fi：", for: UIControl.State.normal)
        btn.setTitleColor(ADTheme.C3, for: UIControl.State.normal)
        btn.setImage(bundleImageFromImageName("bind_type_wifi")?.rtlImage(), for: .normal)
        btn.layoutButton(.imageLeft, space: 8)
        btn.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#FFFFFF")), for: .normal)
        btn.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#D4D3D9")), for: .selected)
        //btn.addTarget(self, action: #selector(cellClickAction), for: .touchDragInside)

        btn.layer.cornerRadius = 9.5.auto()
        btn.clipsToBounds = true
        self.contentView.addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            make.top.equalTo(self.snLbl.snp.bottom).offset(36.auto())
            make.leading.equalTo(self.snLbl.snp.leading)
            make.height.equalTo(24.auto())
            make.width.equalTo(102.auto())
        })
        btn.layoutIfNeeded()
        return btn
    }()
    
    private lazy var iconIV: UIImageView = {
        var temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        temp.image = bundleImageFromImageName("home_user_info_arrow")?.rtlImage()
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-16.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.width.height.equalTo(48.auto())
        })
        return temp
    }()
    
    func getCellHeight() -> CGFloat {
        
        return cellHeight
    }
    
    @objc func cellClickAction() {
        self.protocol?.cellClickAction(model: self.model.0 ?? BindDeviceModel())
    }
}
