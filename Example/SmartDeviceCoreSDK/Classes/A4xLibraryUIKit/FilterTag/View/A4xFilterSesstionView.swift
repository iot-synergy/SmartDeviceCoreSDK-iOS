//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xFilterSesstionView: UIView {
    init(frame: CGRect, titleString: String?) {
        super.init(frame: frame)
        if let tit = titleString {
            self.aNameLable.text = tit
            self.backgroundColor = ADTheme.C6
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.textColor = ADTheme.C4
        temp.font = ADTheme.B2
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(18)
            make.centerY.equalTo(self.snp.centerY)
        })
        return temp
    }()
}
