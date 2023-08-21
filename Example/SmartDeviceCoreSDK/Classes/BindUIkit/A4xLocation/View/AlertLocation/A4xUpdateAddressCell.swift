//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xUpdateAddressCell: UITableViewCell{
    var title : String? {
        didSet {
            self.aNameLable.text = title
        }
    }
    
    var checked : Bool = false {
        didSet {
            self.checkImageV.image = checked ? bundleImageFromImageName("device_location_checked") : bundleImageFromImageName("notification_uncheck")?.rtlImage()
        }
    }
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.aNameLable.isHidden = false
        self.checkImageV.isHidden = false
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
        self.contentView.backgroundColor = ADTheme.C6
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private
    lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.B1
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(16.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-55.auto())
        })
        return temp;
    }();
    
    private
    lazy var editImageV : UIImageView = {
        var temp = UIImageView()
        temp.contentMode = .center
        temp.image = A4xLocationResource.UIImage(named: "location_manager_edit")?.rtlImage()
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-32.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
    
    
    private
    lazy var checkImageV : UIImageView = {
        var temp = UIImageView()
        temp.contentMode = .center
        temp.image = bundleImageFromImageName("device_location_checked")
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-16.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
}
