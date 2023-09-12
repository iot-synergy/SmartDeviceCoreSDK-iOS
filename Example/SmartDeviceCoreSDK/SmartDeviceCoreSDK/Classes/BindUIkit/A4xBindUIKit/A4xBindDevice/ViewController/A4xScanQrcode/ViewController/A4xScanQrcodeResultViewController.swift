//


//


//

import UIKit
import SmartDeviceCoreSDK

import BaseUI

class A4xScanQrcodeResultViewController: BindBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.isHidden = false
        self.descLabel.isHidden = false
        self.doneBtnV.isHidden = false
        self.imageV.isHidden = false
        self.descLabel.attributedText = loadDesAttr()

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func deviceListChange(noti : NSNotification){
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.doneAction()
        }
    }
    
    private
    func loadDesAttr() -> NSAttributedString {
        let attr = NSMutableAttributedString(string: A4xBaseManager.shared.getLocalString(key: "wait_for_permission_tips"))
        attr.addAttribute(.font, value: ADTheme.B2 , range: NSRange(location: 0, length: attr.string.count))
        attr.addAttribute(.foregroundColor, value: ADTheme.C4, range: NSRange(location: 0, length: attr.string.count))
        
        let param = NSMutableParagraphStyle()
        param.lineSpacing = 4
        param.alignment = .center
        param.lineBreakMode = .byWordWrapping
        attr.addAttribute(.paragraphStyle, value: param, range: NSRange(location: 0, length: attr.string.count))
        
        return attr
    }
    
    private
    lazy var imageV : UIImageView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.clear
        self.view.addSubview(bg)
        bg.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.view.snp.leading)
            make.width.equalTo(self.view.snp.width)
            make.top.equalTo(self.descLabel.snp.bottom).offset(30)
            make.bottom.equalTo(self.doneBtnV.snp.top)
        })
        let temp = UIImageView()
        bg.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(bg.snp.centerX)
            make.centerY.equalTo(bg.snp.centerY)
        })
        temp.image = bundleImageFromImageName("join_device_scan_wait_image")?.rtlImage()
        
        return temp
    }()
    
    private
    lazy var titleLabel : UILabel = {
        let temp = UILabel()
        temp.textColor = ADTheme.C1
        temp.textAlignment = .center
        temp.font = ADTheme.H2
        temp.text = A4xBaseManager.shared.getLocalString(key: "request_permission_title")
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(88)
            make.width.equalTo(self.view.snp.width).offset(-50)
            make.centerX.equalTo(self.view.snp.centerX)
        })
        return temp
    }()

    private
    lazy var descLabel : UILabel = {
        let temp = UILabel()
        temp.textColor = ADTheme.C4
        temp.textAlignment = .center
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        temp.font = ADTheme.B2
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(9)
            make.width.equalTo(self.view.snp.width).offset(-50)
            make.centerX.equalTo(self.view.snp.centerX)
        })
        return temp
    }()
    
    private
    lazy var doneBtnV : UIButton = {
        var temp = UIButton()
        temp.titleLabel?.font = ADTheme.B1
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "ok"), for: UIControl.State.normal)
        temp.setTitleColor(UIColor.hex(0xFFFFFF), for: UIControl.State.normal)
        temp.layer.borderColor = ADTheme.Theme.cgColor
        temp.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
        temp.setBackgroundImage(UIImage.buttonPressImage , for: .highlighted)
        temp.setBackgroundImage(UIImage.init(color: UIColor.white), for: .disabled)
        temp.layer.borderWidth = 1
        temp.layer.cornerRadius = 22.5
        temp.clipsToBounds = true
        temp.addTarget(self, action: #selector(doneAction), for: UIControl.Event.touchUpInside)
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width).offset(-60)
            make.height.equalTo(45)
            make.bottom.equalTo(self.view.snp.bottom).offset(-37)
        })
        
        return temp
    }()
    
    @objc
    private func doneAction() {

    }
}
