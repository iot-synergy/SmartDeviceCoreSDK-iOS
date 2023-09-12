//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xBleAuthAlertView: UIView {
    
    var bleAuthAlertBtnClick: ((Bool)->Void)?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.colorFromHex("#000000" ,alpha: 0.6)
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        let alertView = UIView()
        var alertViewHeight: CGFloat = 16.auto()
        self.addSubview(alertView)
        alertView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(288.auto())
            make.height.equalTo(280.auto())
        }
        
        let titleLbl = UILabel()
        titleLbl.textColor = ADTheme.C1
        titleLbl.font = ADTheme.H3
        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "bluetooth_permission")
        titleLbl.textAlignment = .center
        titleLbl.numberOfLines = 0
        alertView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(268.auto())
            make.top.equalTo(alertView.snp.top).offset(16.auto())
        }
        alertViewHeight += (titleLbl.getLabelHeight(titleLbl, width: 268.auto()) + 16.auto())
        
        let msgLbl = UILabel()
        msgLbl.textColor = ADTheme.C2
        msgLbl.font = UIFont.regular(15)
        msgLbl.text = A4xBaseManager.shared.getLocalString(key: "bluetooth_tips1", param: [ADTheme.APPName])
        msgLbl.textAlignment = .center
        msgLbl.numberOfLines = 0
        alertView.addSubview(msgLbl)
        msgLbl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(268.auto())
            make.top.equalTo(titleLbl.snp.bottom).offset(8.auto())
        }
        alertViewHeight += (msgLbl.getLabelHeight(msgLbl, width: 268.auto()) + 8.auto())
        
        let guideImgBgView = UIImageView()
        guideImgBgView.image = bundleImageFromImageName("bind_device_link_ap_guide_bg")
        alertView.addSubview(guideImgBgView)
        guideImgBgView.snp.makeConstraints { make in
            make.top.equalTo(msgLbl.snp.bottom).offset(9.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(164.auto())
            make.height.equalTo(114.auto())
        }
        
        alertViewHeight += 114.auto() + 9.auto()
        
        let guideImgAuthLbl = UILabel()
        guideImgAuthLbl.font = UIFont.regular(13)
        guideImgAuthLbl.text = A4xBaseManager.shared.getLocalString(key: "set")
        guideImgAuthLbl.textAlignment = .center
        guideImgAuthLbl.textColor = ADTheme.C1
        guideImgBgView.addSubview(guideImgAuthLbl)
        guideImgAuthLbl.snp.makeConstraints { make in
            make.top.equalTo(guideImgBgView.snp.top).offset(24.5.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(268.auto())
        }
        
        let guideImgAuthView = UIImageView()
        guideImgAuthView.image = bundleImageFromImageName("bind_device_ble_set_guide")
        guideImgBgView.addSubview(guideImgAuthView)
        guideImgAuthView.snp.makeConstraints { make in
            make.top.equalTo(guideImgBgView.snp.top).offset(52.5.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(160.auto())
            make.height.equalTo(38.auto())
        }
        
        let appIconImgView = UIImageView()
        appIconImgView.image = getAppIcon()
        
        guideImgAuthView.addSubview(appIconImgView)
        appIconImgView.snp.makeConstraints { make in
            make.leading.equalTo(guideImgAuthView.snp.leading).offset(19.auto())
            make.centerY.equalToSuperview()
            make.width.equalTo(19.2.auto())
            make.height.equalTo(19.2.auto())
        }
        
        let appNameLbl = UILabel()
        appNameLbl.font = UIFont.regular(13)
        appNameLbl.text = ADTheme.APPName
        appNameLbl.textAlignment = .left
        appNameLbl.textColor = ADTheme.C1
        guideImgAuthView.addSubview(appNameLbl)
        appNameLbl.snp.makeConstraints { make in
            make.leading.equalTo(appIconImgView.snp.trailing).offset(7.5.auto())
            make.centerY.equalToSuperview()
            make.width.equalTo(93.auto())
        }
        
        let msg2Lbl = UILabel()
        msg2Lbl.textColor = ADTheme.C2
        msg2Lbl.font = UIFont.regular(15)
        msg2Lbl.text = A4xBaseManager.shared.getLocalString(key: "bluetooth_tips2", param: [ADTheme.APPName])
        msg2Lbl.textAlignment = .center
        msg2Lbl.numberOfLines = 0
        alertView.addSubview(msg2Lbl)
        msg2Lbl.snp.makeConstraints { (make) in
            make.top.equalTo(guideImgBgView.snp.bottom).offset(32.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(268.auto())
        }
        
        alertViewHeight += (msg2Lbl.getLabelHeight(msg2Lbl, width: 268.auto()) + 32.auto())
        
        let guide2ImgBgView = UIImageView()
        guide2ImgBgView.image = bundleImageFromImageName("bind_device_link_ap_guide_bg")
        alertView.addSubview(guide2ImgBgView)
        guide2ImgBgView.snp.makeConstraints { make in
            make.top.equalTo(msg2Lbl.snp.bottom).offset(9.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(164.auto())
            make.height.equalTo(114.auto())
        }
        
        alertViewHeight += 114.auto() + 9.auto()
        
        let guide2ImgAuthLbl = UILabel()
        guide2ImgAuthLbl.font = UIFont.regular(13)
        guide2ImgAuthLbl.text = ADTheme.APPName
        guide2ImgAuthLbl.textAlignment = .center
        guide2ImgAuthLbl.textColor = ADTheme.C1
        guide2ImgBgView.addSubview(guide2ImgAuthLbl)
        guide2ImgAuthLbl.snp.makeConstraints { make in
            make.top.equalTo(guide2ImgBgView.snp.top).offset(24.5.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(268.auto())
        }
        
        let guide2ImgAuthView = UIImageView()
        guide2ImgAuthView.image = bundleImageFromImageName("authorization_ble_tipImage")
        guide2ImgBgView.addSubview(guide2ImgAuthView)
        guide2ImgAuthView.snp.makeConstraints { make in
            make.top.equalTo(guide2ImgBgView.snp.top).offset(52.5.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(160.auto())
            make.height.equalTo(38.auto())
        }
        
        let bleNameLbl = UILabel()
        bleNameLbl.font = UIFont.regular(13)
        bleNameLbl.text = A4xBaseManager.shared.getLocalString(key: "bluetooth")
        bleNameLbl.textAlignment = .left
        bleNameLbl.textColor = ADTheme.C1
        guide2ImgAuthView.addSubview(bleNameLbl)
        bleNameLbl.snp.makeConstraints { make in
            make.leading.equalTo(guide2ImgAuthView.snp.leading).offset(45.5.auto())
            make.centerY.equalToSuperview()
            make.width.equalTo(93.auto())
        }
        
        let doneBtn = UIButton()
        doneBtn.titleLabel?.font = ADTheme.B1
        doneBtn.titleLabel?.numberOfLines = 0
        doneBtn.titleLabel?.textAlignment = .center
        doneBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "go_set"), for: UIControl.State.normal)
        
        doneBtn.setTitleColor(ADTheme.C4, for: UIControl.State.disabled)
        doneBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        doneBtn.setBackgroundImage(UIImage.buttonNormallImage, for: .normal)
        
        let image = doneBtn.currentBackgroundImage
        let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.Theme, by: 0.9)
        doneBtn.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
        doneBtn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .disabled)
        doneBtn.layer.cornerRadius = 8.auto()
        doneBtn.accessibilityIdentifier = "ble_auth_go_set"
        
        doneBtn.clipsToBounds = true
        alertView.addSubview(doneBtn)
        
        doneBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(alertView.snp.centerX).offset(0)
            make.width.equalTo(alertView.snp.width).offset(-42.auto())
            make.height.equalTo(38.4.auto())
            make.top.equalTo(guide2ImgBgView.snp.bottom).offset(19.auto())
        }
        
        doneBtn.addTarget(self, action: #selector(bleAuthAlertViewAction(sender:)), for: .touchUpInside)
        
        alertViewHeight += 38.4.auto() + 19.auto()
        
        let cancelBtn = UIButton()
        cancelBtn.titleLabel?.font = ADTheme.B1
        cancelBtn.titleLabel?.numberOfLines = 0
        cancelBtn.titleLabel?.textAlignment = .center
        cancelBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "cancel"), for: .normal)
        cancelBtn.backgroundColor = .clear
        cancelBtn.accessibilityIdentifier = "ble_auth_cancel"
        
        cancelBtn.setTitleColor(ADTheme.Theme, for: .normal)
        alertView.addSubview(cancelBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(alertView.snp.centerX).offset(2.auto())
            make.width.equalTo(alertView.snp.width).offset(-42.auto())
            make.height.equalTo(38.4.auto())
            make.top.equalTo(doneBtn.snp.bottom).offset(0.auto())
        }
        
        cancelBtn.addTarget(self, action: #selector(bleAuthAlertViewAction(sender:)), for: .touchUpInside)
        
        alertViewHeight += 38.4.auto()
        
        
        alertView.snp.updateConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(min(alertViewHeight, UIScreen.height))
        }
        
        alertView.layoutIfNeeded()
        alertView.backgroundColor = .white
        //设置阴影颜色
        alertView.layer.shadowColor = UIColor.black.cgColor
        //设置透明度
        alertView.layer.shadowOpacity = 0.1
        //设置阴影半径
        alertView.layer.shadowRadius = 6.5
        //设置阴影偏移量
        alertView.layer.shadowOffset = CGSize(width: 0, height: -2)
        alertView.filletedCorner(CGSize(width: 15, height: 15),UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue | UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
    }
    
    @objc private func bleAuthAlertViewAction(sender: UIButton) {
        if sender.accessibilityIdentifier == "ble_auth_go_set" {
            self.bleAuthAlertBtnClick?(true)
        } else {
            self.bleAuthAlertBtnClick?(false)
        }
    }
    
    func showInWindow() {
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    func hiddenInWindow() {
        self.removeFromSuperview()
    }
}
