//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceShareRoleCell : UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.aNameLable.isHidden = false
        self.enableLabel.isHidden = false
        self.selectionStyle = .default
        self.selectBackgroundColor = ADTheme.C6
        self.updateSelectBgColor()
    }
    
    var selectBackgroundColor : UIColor? {
        didSet {
            updateSelectBgColor()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var roleEnable : Bool = false {
        didSet {
            self.enableLabel.text = roleEnable ? A4xBaseManager.shared.getLocalString(key: "enabled") : A4xBaseManager.shared.getLocalString(key: "disable")
        }
    }
    
    var nameString : String? {
        didSet {
            self.aNameLable.text = nameString
        }
    }
    
    private func updateSelectBgColor() {
        let view = UIView()
        view.backgroundColor = self.selectBackgroundColor
        self.selectedBackgroundView = view
    }
    
    private
    lazy var enableLabel : UILabel = {
        var temp = UILabel()
        temp.textAlignment = .right
        temp.textColor = ADTheme.C3
        temp.font = ADTheme.B1
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-15)
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
    
    private
    lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.font = UIFont.regular(16)
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(15)
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp;
    }();
}
