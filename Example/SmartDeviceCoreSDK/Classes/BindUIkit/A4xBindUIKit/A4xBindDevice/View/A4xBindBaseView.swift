//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xBindBaseView: UIView {
    
    
    var titleHintStr = A4xBaseManager.shared.getLocalString(key: "connect_wifi_tips")
    
    
    var datas: Dictionary<String, String>? {
        didSet {}
    }
    
    
    lazy var titleLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "congratulation_add_camera")
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        //lbl.backgroundColor = .blue
        lbl.font = UIFont.medium(20)
        lbl.textColor = UIColor.colorFromHex("#333333")
        return lbl
    }()
    
    
    lazy var titleHintTxtView: A4xBaseURLTextView = {
        let txtView: A4xBaseURLTextView = A4xBaseURLTextView()
        txtView.text(text: A4xBaseManager.shared.getLocalString(key: "connect_wifi_tips"), links: ("", "")){
            height in
        }
        txtView.textAlignment = .center
        txtView.linkTextColor = UIColor.colorFromHex("#999999")
        txtView.textColor = UIColor.colorFromHex("#999999")
        txtView.font = UIFont.regular(13)
        txtView.setDirectionConfig()
        return txtView
    }()
    
    
    lazy var nextBtn: UIButton = {
        var btn:UIButton = UIButton()
        btn.titleLabel?.font = ADTheme.B1
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.textAlignment = .center
        btn.setTitle(A4xBaseManager.shared.getLocalString(key: "next"), for: UIControl.State.normal)
        btn.setTitleColor(ADTheme.C4, for: UIControl.State.disabled)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
        //btn.adjustsImageWhenHighlighted = true
        //btn.setBackgroundImage(UIImage.buttonPressImage, for: .highlighted)
        //let pressColor = image.addColor(image.mostColor, with: UIColor.colorFromHex("#000000", alpha: 0.6))
        let image = btn.currentBackgroundImage //UIImage.buttonNormallImage
        let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.Theme, by: 0.9)
        btn.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
        btn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .disabled)
        btn.layer.cornerRadius = 25.auto()
        btn.clipsToBounds = true
        btn.isEnabled = true
        return btn
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height - UIScreen.navBarHeight)
        self.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLbl)
        addSubview(titleHintTxtView)
        addSubview(nextBtn)
        
        
        titleLbl.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(0)
            make.width.equalTo(self.snp.width).offset(-62.auto())
        })
        
        
        let titleHintTxtViewHeight: CGFloat = titleHintTxtView.sizeThatFits(CGSize(width:313, height: CGFloat(MAXFLOAT))).height
        titleHintTxtView.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(titleLbl.snp.bottom).offset(8.auto())
            make.height.equalTo(titleHintTxtViewHeight)
            make.width.equalTo(self.snp.width).offset(-62.auto())
            //make.width.equalTo(313.auto())
        })
        
        
        nextBtn.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-42.auto())
            make.height.equalTo(50.auto())
            make.bottom.equalTo(self.snp.bottom).offset(-35.auto())
        })
    }
    
}
