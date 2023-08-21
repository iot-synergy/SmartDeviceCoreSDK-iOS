//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

public class A4xUpdateAddressDeviceState: UIView {
    var status: SmartDeviceState = .offline {
        didSet {
            self.aNameLable.text = status.stringValue
            self.aNameLable.textColor = ADTheme.C2

            switch status {
            case .online:
                self.tipIconView.bgColor = ADTheme.Theme
            case .offline:
                self.tipIconView.bgColor = ADTheme.C3
            case .sleep:
                self.tipIconView.bgColor = ADTheme.Theme
            case .lowPower:
                self.tipIconView.bgColor = UIColor.hex(0xFFDF37)
            }
        }
    }
    
    private lazy var tipIconView: A4xBaseCircleView = {
        let temp = A4xBaseCircleView()
        temp.radio = 4
        temp.bgColor = ADTheme.Theme
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.aNameLable.snp.leading).offset(-10.auto())
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: 8, height: 8))
        })
        
        return temp
    }()
    
    private lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = SmartDeviceState.offline.stringValue
        temp.textColor = ADTheme.Theme
        temp.font = ADTheme.B2
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing)
            make.centerY.equalTo(self.snp.centerY)
        })
        return temp
    }()
}
