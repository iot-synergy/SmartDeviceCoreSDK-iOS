//


//


//

import Foundation
import SmartDeviceCoreSDK
import YYWebImage
import BaseUI

class A4xUpdateAddressHeader : UIView{
    var deviceName : String? {
        didSet {
            self.aNameLable.text = deviceName
        }
    }
    
    var deviceInfo : NSAttributedString? {
        didSet {
            self.addressLable.attributedText = deviceInfo
        }
    }
    
    var deviceModle : DeviceBean? {
        didSet {
            self.iconImageV.yy_setImage(with: URL(string: deviceModle?.icon ?? ""), placeholder: bundleImageFromImageName("device_icon_default")?.rtlImage())
        }
    }
    
    var stateInfo : SmartDeviceState = .offline {
        didSet {
            self.statusView.status = stateInfo
        }
    }
    






    override init(frame: CGRect = .zero) {
        super.init(frame : frame)
        self.iconImageV.isHidden = false
        self.aNameLable.isHidden = false
        self.addressLable.isHidden = false
        self.statusView.isHidden = false
        self.locationTipLable.isHidden = false
        self.backgroundColor = UIColor.white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var maskLayer = {
        return CAShapeLayer()
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight,.topLeft], cornerRadii: CGSize(width: 10.auto() , height: 10.auto() ))
        self.maskLayer.frame = self.bounds
        self.maskLayer.path = path.cgPath
        self.layer.mask = self.maskLayer
    }
    
    private
    lazy var statusView : A4xUpdateAddressDeviceState = {
        let temp = A4xUpdateAddressDeviceState()
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-15)
            make.width.equalTo(55)
            make.centerY.equalTo(self.aNameLable.snp.centerY)
            make.height.equalTo(self.snp.height)
        })
        
        return temp
    }()
    
    private
    lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "Camera Name A"
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.H2
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.iconImageV.snp.trailing).offset(15);
            make.trailing.equalTo(self.snp.trailing).offset(-80)
            make.top.equalTo(self.iconImageV.snp.top)
        })
        return temp;
    }();
    
    private lazy var addressLable: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "Beijing's home"
        temp.textColor = ADTheme.C3
        temp.font = ADTheme.B2
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.iconImageV.snp.trailing).offset(15);
            make.trailing.equalTo(self.snp.trailing).offset(-80)
            make.top.equalTo(self.aNameLable.snp.bottom).offset(2)
        })
        return temp;
    }();
    
    
    private lazy var locationTipLable: UILabel = {
        var temp: UILabel = UILabel();
        temp.textColor = ADTheme.C2
        temp.font = ADTheme.B2
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.snp.leading).offset(26.auto());
            make.top.equalTo(self.iconImageV.snp.bottom).offset(23.auto())
        })
        return temp;
    }();
    
    private lazy var iconImageV : UIImageView = {
        var temp : UIImageView = UIImageView()
        self.addSubview(temp)
        temp.contentMode = .scaleAspectFit

        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(16.auto())
            make.top.equalTo(16.auto())
            make.size.equalTo(CGSize(width: 55.auto(), height: 55.auto()))
        })
        return temp;
    }()
}
