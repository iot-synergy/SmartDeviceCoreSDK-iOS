//


//


//

import UIKit
import SmartDeviceCoreSDK
import A4xLocation
import BaseUI

class A4xDevicesSettingHeaderView : UITableViewCell {
    var dataSource : DeviceBean? {
        didSet {
            
            self.aNameLable.text = self.dataSource?.deviceName
            
            
            self.updateBatterInfo()
            
            
            self.iconImageV.yy_setImage(with: URL(string: dataSource?.icon ?? ""), placeholder: bundleImageFromImageName("device_icon_default")?.rtlImage())
            
            
            var isWired = false
            if dataSource?.deviceNetType == 0 {
                isWired = false
            } else {
                isWired = true
            }
            self.updateNetstate(status: dataSource?.wifiStrength() ?? .strong, isWired: isWired)
           
            
            self.updateDeviceState(resStr: (self.dataSource?.deviceState() ?? .offline).stringValue)
            
            
            self.updateLocationState(resStr:  self.dataSource?.locationName ?? "")
            
            if dataSource?.canUpdate() == true {
                self.redPointView.isHidden = false
            } else {
                self.redPointView.isHidden = true
            }
            
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.aNameLable.isHidden = false
        self.batterImgV.isHidden = false
        self.iconImageV.isHidden = false
        
        self.wifiStateBtn.isHidden = false
        self.deviceStateBtn.isHidden = false
        self.locationStateBtn.isHidden = false
        
        self.arrowIV.isHidden = false
        self.redPointView.isHidden = true
        self.updateLabel.isHidden = true
        
        self.statusView.isHidden = false
        
        //self.updateBatterInfo()
        //self.updateNetstate(status: .none)
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    private lazy var statusView: A4xUpdateAddressDeviceState = {
        let temp = A4xUpdateAddressDeviceState()
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-16.auto())
            make.width.equalTo(55)
            make.centerY.equalTo(self.aNameLable.snp.centerY)
            make.height.equalTo(self.snp.height)
        })
        
        return temp
    }()
    
    
    private lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "Camera"
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.H2
        temp.setContentHuggingPriority(.required, for: .horizontal)
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.contentView.snp.top).offset(16.auto())
            make.leading.equalTo(self.contentView.snp.leading).offset(16.auto())
            make.trailing.lessThanOrEqualTo(self.contentView.snp.trailing).offset(-70.auto())
        })
        return temp
    }()
    
    
    lazy var batterImgV: A4xBaseBatteryView = {
        let temp = A4xBaseBatteryView()
        self.contentView.addSubview(temp)
        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let right = 0
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.aNameLable.snp.centerY)
            make.leading.equalTo(self.aNameLable.snp.trailing).offset(10.auto())
        })
        return temp
    }()
    
    
    private lazy var batterleavelLbl: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "100%"
        temp.textColor = UIColor.colorFromHex("#4F5052")
        temp.font = UIFont.regular(10)
        temp.setContentHuggingPriority(.required, for: .horizontal)
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.batterImgV.snp.centerY)
            make.leading.equalTo(self.batterImgV.snp.trailing).offset(1.auto())
        })
        return temp
    }()
    
    
    private lazy var iconImageV: UIImageView = {
        var temp : UIImageView = UIImageView()
        self.contentView.addSubview(temp)
        temp.contentMode = .scaleAspectFit
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(16.auto())
            make.top.equalTo(self.aNameLable.snp.bottom).offset(12.auto())
            make.size.equalTo(CGSize(width: 72.auto(), height: 72.auto()))
        })
        return temp
    }()
    
    
    lazy var wifiStateBtn: UIButton = {
        var btn: UIButton = UIButton()
        btn.titleLabel?.font = ADTheme.B3
        //btn.titleLabel?.numberOfLines = 0
        //btn.titleLabel?.textAlignment = .center
        btn.setTitle(A4xBaseManager.shared.getLocalString(key: "wifi_state_ios"), for: UIControl.State.normal)
        btn.setTitleColor(ADTheme.C3, for: UIControl.State.normal)
        
        btn.setImage(A4xDeviceSettingResource.UIImage(named: "device_wifi_tip")?.rtlImage(), for: .normal)
        btn.layoutButton(.imageLeft, space: 8)
        btn.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#F6F5FA")), for: .normal)

        btn.layer.cornerRadius = 9.5.auto()
        btn.clipsToBounds = true
        self.contentView.addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            make.top.equalTo(self.iconImageV.snp.top)
            make.leading.equalTo(self.iconImageV.snp.trailing).offset(16.auto())
            make.height.equalTo(19.auto())
            make.width.equalTo(102.auto())
        })
        btn.layoutIfNeeded()
        return btn
    }()
    
    
    lazy var deviceStateBtn: UIButton = {
        var btn: UIButton = UIButton()
        btn.titleLabel?.font = ADTheme.B3
        //btn.titleLabel?.numberOfLines = 0
        //btn.titleLabel?.textAlignment = .center
        btn.setTitle(A4xBaseManager.shared.getLocalString(key: "device_state_ios"), for: UIControl.State.normal)
        btn.setTitleColor(ADTheme.C3, for: UIControl.State.normal)
        
        btn.setImage(A4xDeviceSettingResource.UIImage(named: "device_state_tip")?.rtlImage(), for: .normal)
        btn.layoutButton(.imageLeft, space: 8)
        btn.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#F6F5FA")), for: .normal)

        btn.layer.cornerRadius = 9.5.auto()
        btn.clipsToBounds = true
        self.contentView.addSubview(btn)
        let apModeType = self.dataSource?.apModeType ?? .WiFi
        btn.snp.makeConstraints({ (make) in
            make.top.equalTo(self.wifiStateBtn.snp.bottom).offset(11.auto())
            make.leading.equalTo(self.wifiStateBtn.snp.leading)
            make.height.equalTo(19.auto())
            make.width.equalTo(102.auto())
        })
        btn.layoutIfNeeded()
        return btn
    }()
    
    
    lazy var locationStateBtn: UIButton = {
        var btn: UIButton = UIButton()
        btn.titleLabel?.font = ADTheme.B3
        //btn.titleLabel?.numberOfLines = 0
        //btn.titleLabel?.textAlignment = .center
        btn.setTitle("使用位置", for: UIControl.State.normal)
        btn.setTitleColor(ADTheme.C3, for: UIControl.State.normal)
        
        btn.setImage(A4xDeviceSettingResource.UIImage(named: "device_location_state")?.rtlImage(), for: .normal)
        btn.layoutButton(.imageLeft, space: 8)
        btn.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#F6F5FA")), for: .normal)

        btn.layer.cornerRadius = 9.5.auto()
        btn.clipsToBounds = true
        self.contentView.addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            make.top.equalTo(self.deviceStateBtn.snp.bottom).offset(11.auto())
            make.leading.equalTo(self.wifiStateBtn.snp.leading)
            make.height.equalTo(19.auto())
            make.width.equalTo(102.auto())
        })
        btn.layoutIfNeeded()
        return btn
    }()
    
    lazy var redPointView: UIView = {
        var temp: UIView = UIView()
        temp.backgroundColor = .red
        temp.layer.cornerRadius = 3.auto()
        temp.layer.masksToBounds = true
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.arrowIV)
            make.trailing.equalTo(self.arrowIV.snp.leading).offset(-5.auto())
            make.width.height.equalTo(6.auto())
        })
        return temp
    }()
    
    lazy var arrowIV: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("home_user_info_arrow")?.rtlImage()
        self.contentView.addSubview(iv)
        iv.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-16.auto())
            //make.height.equalTo(11.auto())
            //make.width.equalTo(5.5.auto())
        })
        return iv
    }()
    
    
    private lazy var updateLabel: UILabel = {
        var temp: UILabel = UILabel()
        temp.backgroundColor = UIColor.red
        temp.layer.cornerRadius = 4.auto()
        temp.layer.masksToBounds = true
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.arrowIV.snp.leading).offset(-4.auto())
            make.width.height.equalTo(8.auto())
            make.centerY.equalTo(self.arrowIV)
        })
        return temp
    }()
    
}


extension A4xDevicesSettingHeaderView {
    
    
    private func updateBatterInfo() {
        guard let datasource = self.dataSource else {
            return
        }
        self.batterImgV.setBatterInfo(leavel: datasource.batteryLevel ?? 0, isCharging: datasource.isCharging ?? 0, isOnline: datasource.online ?? 0 == 1, quantityCharge: datasource.quantityCharge ?? false)
        self.batterImgV.isHidden = !(dataSource?.supperBatter() ?? false)
        self.batterleavelLbl.isHidden = !(dataSource?.supperBatter() ?? false)
        let (batter, symc) = datasource.safeBatterInfo()
        self.batterleavelLbl.text = "\(batter)\(symc)"
    }
    
    
    private func updateNetstate(status: A4xWiFiStyle, isWired: Bool) {
        
        //
        if isWired == false {
            let str: String = status.rawValue
            let img: UIImage = status.imgValue ?? A4xDeviceSettingResource.UIImage(named: "device_wifi_none")?.rtlImage() as! UIImage
            let strWidth = A4xBaseManager.shared.getLocalString(key: "wifi_state", param: [str]).width(font: ADTheme.B3, wordSpace: 0)
            let strMinWidth = min(strWidth + 14.auto() + 15.auto() + 8.auto(), 223.auto())
            self.wifiStateBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "wifi_state", param: [str]), for: .normal)
            self.wifiStateBtn.setImage(img, for: .normal)

            
            self.wifiStateBtn.snp.updateConstraints { (make) in
                make.width.equalTo(strMinWidth)
            }
            self.wifiStateBtn.layoutIfNeeded()
        } else {
            
            let str: String = A4xBaseManager.shared.getLocalString(key: "wired_connection")
            let img: UIImage = A4xDeviceSettingResource.UIImage(named: "device_wifi_state_wired")?.rtlImage() ?? UIImage()
            let strWidth = str.width(font: ADTheme.B3, wordSpace: 0)
            let strMinWidth = min(strWidth + 14.auto() + 15.auto() + 8.auto(), 223.auto())
            self.wifiStateBtn.setTitle(str, for: .normal)
            self.wifiStateBtn.setImage(img, for: .normal)

            
            self.wifiStateBtn.snp.updateConstraints { (make) in
                make.width.equalTo(strMinWidth)
            }
            self.wifiStateBtn.layoutIfNeeded()
        }
        
       
        //self.wifiStateLbl.text = str



















        
        //let isOffline = (self.dataSource?.deviceState() ?? .offline) == .offline
        //self.wifiStateImg.alpha = isOffline ? 0.4 : 1
    }
    
    
    private func updateDeviceState(resStr: String) {
        let str: String = resStr
        let strWidth = A4xBaseManager.shared.getLocalString(key: "device_state", param:[str]).width(font: ADTheme.B3, wordSpace: 0)
        let strMinWidth = min(strWidth + 14.auto() + 15.auto() + 8.auto(), 223.auto())







        var apString : String = ""
        self.deviceStateBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "device_state", param: [str]), for: .normal)
        
        self.deviceStateBtn.snp.remakeConstraints({ (make) in
            make.top.equalTo(self.wifiStateBtn.snp.bottom).offset(11.auto())
            make.leading.equalTo(self.iconImageV.snp.trailing).offset(16.auto())
            make.height.equalTo(19.auto())
            make.width.equalTo(102.auto())
        })

        
        self.deviceStateBtn.snp.updateConstraints { (make) in
            make.width.equalTo(strMinWidth)
        }
        self.deviceStateBtn.layoutIfNeeded()
        
        //let isOffline = (self.dataSource?.deviceState() ?? .offline) == .offline
        //self.wifiStateImg.alpha = isOffline ? 0.4 : 1
    }
    
    
    private func updateLocationState(resStr: String) {
        let str: String = A4xBaseManager.shared.getLocalString(key: "location_setting") + ": " + resStr
        let strWidth = str.width(font: ADTheme.B3, wordSpace: 0)
        let strMinWidth = min(strWidth + 14.auto() + 15.auto() + 8.auto(), 223.auto())
        self.locationStateBtn.setTitle(str, for: .normal)

        
        self.locationStateBtn.snp.updateConstraints { (make) in
            make.width.equalTo(strMinWidth)
        }
        self.locationStateBtn.layoutIfNeeded()
    }
}
