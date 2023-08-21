//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceShareArrowCell : UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.aNameLable.isHidden = false
        self.arrowImageV.isHidden = false
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
    lazy var arrowImageV : UIImageView = {
        var temp = UIImageView()
        temp.contentMode = .center
        temp.image = bundleImageFromImageName("home_user_info_arrow")?.rtlImage()
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
    
    private
    lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.H3
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(15)
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp;
    }();
}
