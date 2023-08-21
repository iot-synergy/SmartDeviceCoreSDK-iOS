//


//


//

import UIKit
import SmartDeviceCoreSDK

public class A4xLanguageViewCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.languageLabel.isHidden = false
        self.checkImageV.isHidden = false
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    public var title : String = "" {
        didSet {
            self.languageLabel.text = title
        }
    }
    
    public var check : Bool = false {
        didSet {
            self.checkImageV.isHidden = !check
        }
    }
    
    private
    lazy var languageLabel : UILabel = {
        var temp = UILabel()
        temp.textAlignment = .left
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.B1
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in

            make.leading.equalTo(15.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.width.lessThanOrEqualTo(self.contentView.snp.width).offset(-100)
        })
        return temp
    }()
    
    private
    lazy var checkImageV : UIImageView = {
        var temp = UIImageView()
        temp.isHidden = true
        temp.contentMode = .center
        self.contentView.addSubview(temp)
        let image = bundleImageFromImageName("device_location_checked")
        temp.image = image
        let imageSize = image?.size ?? CGSize(width: 20, height: 20)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-7)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(imageSize)
        })
        return temp
    }()
}
