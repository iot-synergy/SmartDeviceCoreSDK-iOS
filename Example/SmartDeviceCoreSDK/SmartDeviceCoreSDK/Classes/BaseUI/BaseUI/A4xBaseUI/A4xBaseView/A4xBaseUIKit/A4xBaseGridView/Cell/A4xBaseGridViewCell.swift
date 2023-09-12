//


//


//

import UIKit

class A4xBaseGridViewCell: UIView {
    var index: Int? 
    lazy var imgView: UIImageView = {
        let iv = UIImageView()
        let layer = iv.layer
        layer.borderColor = UIColor.colorFromHex("#F0F0F0").cgColor
        layer.borderWidth = 1.0
        //iv.isUserInteractionEnabled = true
        return iv
    }()
    
    lazy var imgBtn: UIButton = {
        let btn = UIButton()
        //let layer = btn.layer
        //layer.borderColor = UIColor.colorFromHex("#F0F0F0").cgColor
        //layer.borderWidth = 1.0
        //btn.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
        btn.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#8CA7EE")), for: .highlighted)
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func initView() {
        self.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        
        self.insertSubview(self.imgBtn, aboveSubview: imgView)
        self.imgBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 0.25, left: 0.25, bottom: 0.25, right: 0.25))
        }
        self.imgBtn.layoutIfNeeded()
        self.imgBtn.clipsToBounds = true
        self.imgBtn.cornerRadius = 5.5.auto()
    }
}
