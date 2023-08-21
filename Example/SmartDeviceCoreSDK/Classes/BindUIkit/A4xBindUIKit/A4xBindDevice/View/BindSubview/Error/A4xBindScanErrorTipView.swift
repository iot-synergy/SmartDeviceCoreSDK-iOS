//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class ScanErrorTipView: UIView {
    private var buttonBlock: (()->Void)?
    
    func setTitle(title: String, buttom: String?, comple: @escaping ()->Void) {
        self.tipLabel.text = title
        self.tipButton.isHidden = buttom == nil
        self.tipButton.setTitle(buttom, for: .normal)
        let size = self.tipButton.sizeThatFits(CGSize(width: self.width - 50.auto(), height: 200))
        tipButton.snp.updateConstraints { (make) in
            make.width.equalTo(max(size.width, 155.auto()))
            make.height.equalTo(max(50.auto(), size.height + 10.auto()))
        }
        
        buttonBlock = comple
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tipLabel.isHidden = false
        self.tipButton.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var tipLabel: UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        temp.font = ADTheme.B1
        temp.textColor = UIColor.white
        temp.text = A4xBaseManager.shared.getLocalString(key: "no_camera_auth")
        self.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.width.equalTo(self.snp.width).offset(-64.auto())
            make.centerX.equalTo(self.snp.centerX)
        }
        return temp
    }()
    
    lazy var tipButton: UIButton = {
        var temp = UIButton()
        temp.accessibilityIdentifier = "registeredV_button"
        temp.titleLabel?.font = ADTheme.B1
        temp.titleLabel?.numberOfLines = 0
        temp.titleLabel?.textAlignment = .center
        temp.titleLabel?.adjustsFontSizeToFitWidth = true
        temp.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);

        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "scan_camera_qr_code"), for: UIControl.State.normal)
        temp.setTitleColor(UIColor.white, for: UIControl.State.normal)
        temp.layer.borderColor = ADTheme.Theme.cgColor
        temp.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
        temp.setBackgroundImage(UIImage.buttonNormallImage , for: .disabled)
        temp.setBackgroundImage(UIImage.buttonPressImage , for: .highlighted)
        temp.layer.borderWidth = 1
        temp.layer.cornerRadius = 25.auto()
        temp.clipsToBounds = true
        temp.addTarget(self, action: #selector(buttonAction), for: UIControl.Event.touchUpInside)
        self.addSubview(temp)

        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(150.auto())
            make.height.equalTo(50.auto())
            make.top.equalTo(tipLabel.snp.bottom).offset(32.auto())
            make.bottom.equalTo(self.snp.bottom)

        })
        return temp
    }()
    
    @objc func buttonAction() {
        buttonBlock?()
    }
}
