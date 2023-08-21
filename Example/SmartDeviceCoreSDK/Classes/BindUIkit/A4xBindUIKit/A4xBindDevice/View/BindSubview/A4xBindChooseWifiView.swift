import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xBindChooseWifiView: A4xBindBaseView {
    var backClick: (()->Void)?
    
    lazy var navView: A4xBaseNavView = {
        let temp = A4xBaseNavView()
        temp.backgroundColor = .clear//UIColor.white
        temp.lineView?.isHidden = true
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(0)
            make.trailing.equalTo(self.snp.trailing)
            make.top.equalTo(0)
        })
        
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        temp.leftItem = leftItem
        
        temp.leftClickBlock = { [weak self] in
            self?.backClick?()
        }
        return temp
    }()
    
    
    lazy var channalTipsView: UIView = {
        var v: UIView = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    lazy var channal_2_4g_Lbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.textColor = ADTheme.C2
        lbl.textAlignment = .right
        lbl.text = "2.4GHz"
        lbl.font = UIFont.medium(16)
        return lbl
    }()
    
    lazy var channal_2_4g_IV: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.contentMode = .center
        iv.image = bundleImageFromImageName("bind_device_channal_2_4g")
        return iv
    }()
    
    lazy var channal_5g_Lbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.textColor = ADTheme.C2
        lbl.textAlignment = .left
        lbl.text = "5GHz"
        lbl.font = UIFont.medium(16)
        return lbl
    }()
    
    lazy var channal_5g_IV: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.contentMode = .center
        iv.image = bundleImageFromImageName("bind_device_channal_5g")?.rtlImage()
        return iv
    }()

    lazy var wifiNameTxtField: A4xBaseTextField = {
        var txtField: A4xBaseTextField = A4xBaseTextField()
        txtField.accessibilityIdentifier = "wifi_name"
        txtField.backgroundColor = UIColor.clear
        txtField.font = ADTheme.B1
        txtField.textColor = ADTheme.C1
        txtField.textAlignment = .left
        txtField.setMaxTextsCount(maxChar: 255)
        txtField.placeholder = A4xBaseManager.shared.getLocalString(key: "network_name")
        //txtField.inset = UIEdgeInsets(top: 0, left: 15.auto(), bottom: 0, right: 80.auto())
        txtField.inset = UIEdgeInsets(top: 0, left: 15.auto(), bottom: 0, right: 10.auto())
        txtField.keyboardType = .asciiCapable
        if #available(iOS 11.0, *) {
            txtField.textContentType = .username
        }
        txtField.clearButtonMode = .whileEditing
        txtField.addLineStyle()
        txtField.setDirectionConfig()
        //txtField.resetFrameToFitRTL()
        return txtField
    }()
    
    lazy var wifiPwdTxtFiled: A4xBaseTextField = {
        var txtField: A4xBaseTextField = A4xBaseTextField()
        txtField.accessibilityIdentifier = "wifi_pwd"
        txtField.font = ADTheme.B1
        txtField.textColor = ADTheme.C1
        txtField.textAlignment = .left
        txtField.setMaxTextsCount(maxChar: 255)
        txtField.showLookPwd = true
        txtField.isSecureTextEntry = false
        txtField.openPwdEye = true
        txtField.clearButtonMode = .whileEditing
        txtField.keyboardType = .asciiCapable
        if #available(iOS 11.0, *) {
            txtField.textContentType = .password
        }
        txtField.inset = UIEdgeInsets(top: 0, left: 15.auto(), bottom: 0, right: 10.auto())
        txtField.placeholder = A4xBaseManager.shared.getLocalString(key: "enter_password")
        txtField.addLineStyle()
        txtField.setDirectionConfig()
        //txtField.resetFrameToFitRTL()
        return txtField
    }()
   
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.navView.isHidden = false
        
        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "select_wifi_title")
        titleHintTxtView.text(text: A4xBaseManager.shared.getLocalString(key: "connect_wifi_tips"), links: (A4xBaseManager.shared.getLocalString(key: "learn_more_2"), "")) {
            height in
            
        }
        titleHintTxtView.textAlignment = .center
        titleHintTxtView.linkTextColor = UIColor(hex: "#3495E8") ?? UIColor.blue
        titleHintTxtView.textColor = UIColor.colorFromHex("#999999")
        titleHintTxtView.font = UIFont.regular(13)
        
        addSubview(channalTipsView)
        channalTipsView.addSubview(channal_2_4g_Lbl)
        channalTipsView.addSubview(channal_2_4g_IV)
        channalTipsView.addSubview(channal_5g_Lbl)
        channalTipsView.addSubview(channal_5g_IV)
        
        addSubview(wifiNameTxtField)
        addSubview(wifiPwdTxtFiled)
        nextBtn.removeFromSuperview()
        
        addSubview(nextBtn)
        titleLbl.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.navView.snp.bottom).offset(0)
            make.width.equalTo(self.snp.width).offset(-62.auto())
        }
        
        let titleHintStr = A4xBaseManager.shared.getLocalString(key: "connect_wifi_tips")
        titleHintTxtView.snp.remakeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(titleLbl.snp.bottom).offset(8.auto())
            make.width.equalTo(self.snp.width).offset(-32.auto())
            //make.height.equalTo(titleHintTxtViewHeight)
        })
        
        channalTipsView.snp.makeConstraints({ make in
            make.top.equalTo(titleHintTxtView.snp.bottom).offset(8.auto())
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(22.auto())
            make.width.equalTo(self.snp.width)
        })
        
        channal_2_4g_IV.snp.makeConstraints({ make in
            make.trailing.equalTo(channalTipsView.snp.centerX).offset(-11.auto())
            make.centerY.equalTo(channalTipsView.snp.centerY)
            make.height.equalTo(13.auto())
            make.width.equalTo(13.auto())
        })
        
        channal_2_4g_Lbl.snp.makeConstraints({ make in
            make.trailing.equalTo(channal_2_4g_IV.snp.leading).offset(-8.auto())
            make.centerY.equalTo(channal_2_4g_IV.snp.centerY)
        })
        
        channal_5g_Lbl.snp.makeConstraints({ make in
            make.centerY.equalTo(channalTipsView.snp.centerY)
            make.leading.equalTo(channalTipsView.snp.centerX).offset(0)
        })
        
        channal_5g_IV.snp.makeConstraints({ make in
            make.centerY.equalTo(channal_5g_Lbl.snp.centerY).offset(0)
            make.leading.equalTo(channal_5g_Lbl.snp.trailing).offset(6.5.auto())
            make.height.equalTo(13.auto())
            make.width.equalTo(13.auto())
        })
        
        wifiNameTxtField.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(titleHintTxtView.snp.bottom).offset(67.auto())
            make.height.equalTo(40.auto())
            make.width.equalTo(self.snp.width).offset(-64.auto())
        })
        wifiNameTxtField.layoutIfNeeded()
        
        wifiPwdTxtFiled.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(wifiNameTxtField.snp.bottom).offset(20)
            make.height.equalTo(40.auto())
            make.width.equalTo(self.snp.width).offset(-64.auto())
        })
        wifiPwdTxtFiled.layoutIfNeeded()
        
        
        nextBtn.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-42.auto())
            make.height.equalTo(50.auto())
            make.bottom.equalTo(self.snp.bottom).offset(-35.auto())
        })
    }
}
