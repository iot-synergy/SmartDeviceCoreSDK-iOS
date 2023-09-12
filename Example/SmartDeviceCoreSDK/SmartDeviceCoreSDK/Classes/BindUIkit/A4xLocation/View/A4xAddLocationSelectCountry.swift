//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xAddLocationSelectCountry : UIControl {
    
    var country : String? {
        set{
            self.currNameV.text = newValue
        }
        get{
            return self.currNameV.text
        }
    }
    
    
    
    override init(frame : CGRect = .zero){
        super.init(frame: frame)
        self.tipLabel.isHidden = false
        self.arrowImage.isHidden = false
        self.currNameV.isHidden = false
        self.addLineStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tipLabel : UILabel = {
        
        var temp = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "country")
        temp.font = ADTheme.B2
        temp.textColor = ADTheme.C2
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(0)
            make.centerY.equalTo(self.snp.centerY)
        })
        return temp;
    }()
    

    private lazy var arrowImage : UIImageView = {
        
        var temp: UIImageView = UIImageView();
        temp.image = bundleImageFromImageName("add_dialog_arrow")?.rtlImage()
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(16)
            make.height.equalTo(16)
        })
        return temp
    }()

    private lazy var currNameV : UILabel = {
        
        var temp = UILabel()

        temp.textAlignment = .right
        temp.font = ADTheme.B2
        temp.textColor = ADTheme.Theme
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.arrowImage.snp.leading)
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(self.tipLabel.snp.trailing).offset(15)
        })

        return temp
    }()
}
