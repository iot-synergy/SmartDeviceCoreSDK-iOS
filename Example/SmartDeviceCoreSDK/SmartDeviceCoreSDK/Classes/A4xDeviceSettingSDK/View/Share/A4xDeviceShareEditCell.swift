//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceShareEditCell : UITableViewCell {
    
    var nameString : String? {
        didSet {
            self.aNameLable.text = nameString
        }
    }
    var emailString: String? {
        didSet {
            self.desLable.text = emailString
        }
    }
    
    var selectBackgroundColor : UIColor? {
        didSet {
            updateSelectBgColor()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.aNameLable.isHidden = false
        self.desLable.isHidden = false
        self.selectionStyle = .default
        self.selectBackgroundColor = ADTheme.C6
        self.updateSelectBgColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateSelectBgColor() {
        let view = UIView()
        view.backgroundColor = self.selectBackgroundColor
        self.selectedBackgroundView = view
    }
    
    private
    lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.H3
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(15)
            make.top.equalTo(13)
            make.trailing.lessThanOrEqualTo(self.contentView.snp.trailing).offset(-30)
        })
        return temp;
    }();
    
    private
    lazy var desLable: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "test"
        temp.textColor = ADTheme.C3
        temp.font = ADTheme.B1
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(15)
            make.bottom.lessThanOrEqualTo(self.contentView.snp.bottom).offset(-13)
        })
        return temp;
    }();
}
