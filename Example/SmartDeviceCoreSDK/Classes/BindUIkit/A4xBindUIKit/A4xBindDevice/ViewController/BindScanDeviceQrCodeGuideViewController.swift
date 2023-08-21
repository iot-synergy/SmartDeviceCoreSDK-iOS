//


//


import UIKit
import SmartDeviceCoreSDK
import BindInterface
import BaseUI

class BindScanDeviceQrCodeGuideViewController : BindBaseViewController {
    
    var tipStrArr: [String]? = [A4xBaseManager.shared.getLocalString(key: "qrcode_way1"),
                               A4xBaseManager.shared.getLocalString(key: "qrcode_way2"),
                               A4xBaseManager.shared.getLocalString(key: "qrcode_way3")]
    
    var tipImgArr: [UIImage]? = [bundleImageFromImageName("bind_device_un_open1")?.rtlImage() ?? UIImage(),
                                bundleImageFromImageName("bind_device_un_open2")?.rtlImage() ?? UIImage(),
                                bundleImageFromImageName("bind_device_un_open3")?.rtlImage() ?? UIImage()]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultNav()
        self.view.backgroundColor = .white
        
        self.titleLable.isHidden = false
        self.scanButton.isHidden = false
        self.cantFindQrOnLbl.isHidden = false
        
        self.loadViewIfNeeded()
        self.tipPageView.isHidden = false
    
        self.tipPageView.tipTuple = (self.tipStrArr, self.tipImgArr)
        self.tipPageView.autoPlay = false
        self.tipPageView.delay = 3
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func defaultNav() {
        super.defaultNav()
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        navView?.lineView?.isHidden = true
        navView?.leftItem = leftItem
        navView?.backgroundColor = UIColor.clear
    }
    
    
    lazy var titleLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "confirm_model_number")
        temp.textAlignment = .center
        temp.numberOfLines = 0
        temp.font = UIFont.medium(20)
        temp.textColor = UIColor.colorFromHex("#333333")
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.top.equalTo(self.navView!.snp.bottom).offset(8.auto())
            make.width.equalTo(self.view.snp.width).offset(-64.auto())
            make.centerX.equalTo(self.view.snp.centerX)
        }
        temp.layoutIfNeeded()
        return temp
    }()
    
    lazy var scanButton: UIButton = {
        var temp = UIButton()
        temp.accessibilityIdentifier = "registeredV_button"
        temp.titleLabel?.font = ADTheme.B1
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "scan_camera_qr_code"), for: UIControl.State.normal)
        temp.setTitleColor(UIColor.white, for: UIControl.State.normal)
        temp.layer.borderColor = ADTheme.Theme.cgColor
        temp.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
        temp.setBackgroundImage(UIImage.buttonNormallImage , for: .disabled)
        temp.setBackgroundImage(UIImage.buttonPressImage , for: .highlighted)
        temp.layer.borderWidth = 1
        temp.layer.cornerRadius = 25.auto()
        temp.clipsToBounds = true
        self.view.addSubview(temp)

        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width).offset(-42.auto())
            make.height.equalTo(50.auto())
            make.bottom.equalTo(self.view.snp.bottom).offset(-81.auto())
        })
        temp.layoutIfNeeded()
        return temp
    }()
    
    
    lazy var cantFindQrOnLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "can_not_find_camera_qr_code")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.Theme
        lbl.font = UIFont.regular(14)
        self.view.addSubview(lbl)
        lbl.snp.makeConstraints({ make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.bottom.equalTo(self.view.snp.bottom).offset(-33.auto())
            make.width.equalTo(266.5.auto())
        })
        return lbl
    }()
    
    private lazy var tipPageView: A4xBasePageControlView = {
        let temp = A4xBasePageControlView()
        temp.isUserInteractionEnabled = true
        self.view.addSubview(temp)
        
        let oneLineHeight = "title".textHeightFromTextString(text: "title", textWidth: self.view.width - 64.auto(), fontSize: 20.auto(), isBold: false)
        let titleStr = A4xBaseManager.shared.getLocalString(key: "confirm_model_number")
        let itemHeight = titleStr.textHeightFromTextString(text: titleStr, textWidth: self.view.width - 64.auto(), fontSize: 20.auto(), isBold: false)
        var titleLineCount = Int(itemHeight / oneLineHeight)
        titleLineCount = titleLineCount % 10 > 2 ? titleLineCount - 2 : 0
        
        temp.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width)
            make.bottom.equalTo(self.scanButton.snp.top).offset(-30.auto())
            make.height.equalTo(385.auto() - (titleLineCount % 10) * 22.5.auto())
        }
        
        temp.layoutIfNeeded()
        return temp
    }()
    
    private func isCannotBoot() -> String {
        return (self.bindErrorTypeEnum == .canNotBoot) ? "unable_to_power_on" : "other"
    }
}

//MARK:- 底层轮询绑定有关
extension BindScanDeviceQrCodeGuideViewController {
    override func onSuccess(code: Int, msg: String?, serialNumber: String?) {
        let vc = BindConnectWaitViewController()
        vc.serialNumber = serialNumber
        vc.currentStep = 4
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func bindDeviceError(errorCode: Int) {
        
    }
}
