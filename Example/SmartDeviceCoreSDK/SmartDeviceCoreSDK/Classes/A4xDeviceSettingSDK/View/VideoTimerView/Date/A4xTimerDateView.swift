//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK

class A4xTimerDateView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.dateMonthLabel.isHidden = false
        self.dateDayLabel.isHidden = false
        self.backgroundColor = UIColor.white.withAlphaComponent(0.3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            self.dateMonthLabel.frame = CGRect(x: 0, y: 5, width: self.bounds.width, height: 16)
            self.dateDayLabel.frame = CGRect(x: 0, y: self.bounds.height - 28 - 5, width: self.bounds.width, height: 28)
        }
    }
    
    
    var date : Date? {
        didSet {
            if let d = date {
                let str = self.dateFormat.string(from: d)
                let dates = str.split(separator: "*")
                if dates.count < 1 {
                    self.dateMonthLabel.text = ""
                    self.dateDayLabel.text = ""
                    return
                }
                self.dateMonthLabel.text = String(dates[0])
                self.dateDayLabel.text = String(dates[1])
            }else {
                self.dateMonthLabel.text = ""
                self.dateDayLabel.text = ""
            }
        }
    }

    private lazy var dateFormat : DateFormatter = {
        let fmt = DateFormatter();
        var dataFormat : String = "MMM.*d"
        if A4xBaseAppLanguageType.language() == .chinese {
            dataFormat = "MMMM*d"
        }
        fmt.dateFormat = dataFormat;
        fmt.locale = CurrentLocale()
        return fmt;
    }()
    
    private
    lazy var dateMonthLabel : UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        temp.font = UIFont.systemFont(ofSize: 16.auto())
        self.addSubview(temp)
        
        return temp
    }()
    
    
    private
    lazy var dateDayLabel : UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2,alpha:1.000000)
        temp.font = UIFont.systemFont(ofSize: 25.auto(), weight: .medium)
        self.addSubview(temp)
        
        return temp
    }()
}
