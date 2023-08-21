//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xSDTimerIndicator : UIView {
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.circleImageV.isHidden = false
        
        self.backgroundColor = ADTheme.Theme
    }
    
    override var frame: CGRect {
        didSet {
            self.circleImageV.frame = CGRect(x: (self.bounds.width - 10) / 2 , y: 0, width: 10, height: 10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDate(date: Date, show: Bool) {
        dateLable.isHidden = !show
        if !show {
            return
        }
        
        dateLable.text = dateString(date: date)
        let size = dateLable.sizeThatFits(CGSize(width: 200, height: 15))
        let padding : CGFloat = 5.auto()
        self.dateLable.frame = CGRect(x: (self.bounds.width - size.width  ) / 2 - padding, y: 0 - 8.auto() - size.height - padding * 2 , width: size.width + padding * 2 , height: size.height + padding * 2)

    }
    
    
    lazy var dateLable: UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.font = UIFont.systemFont(ofSize: 11.auto())
        temp.textColor = UIColor.white
        temp.backgroundColor = UIColor.hex(0x686868)
        temp.layer.cornerRadius = 5.auto()
        temp.clipsToBounds = true
        self.addSubview(temp)
        return temp
    }()
    
    lazy var circleImageV: UIImageView = {
        let temp = UIImageView()
        temp.backgroundColor = UIColor.white
        temp.image = A4xDeviceSettingResource.UIImage(named: "device_sd_indicator")?.rtlImage()
        self.addSubview(temp)
        return temp
    }()
    
    private func dateString(date : Date) -> String {
        let fmt = DateFormatter();
        let language =  A4xBaseAppLanguageType.language()
        switch language {
        case .chinese:
            fmt.dateFormat = "MM月dd日 / HH:mm:ss";
        case .english:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .Japanese:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .german:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .russian:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .french:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .italian:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .spanish:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .finnish:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .hebrew:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .arab:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .vietnam:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .portuguese:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .polish:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .turkish:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .chinese_traditional:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        case .cezch:
            fmt.dateFormat = "MMM dd / HH:mm:ss";
        }
        return fmt.string(from: date)
    }
}
