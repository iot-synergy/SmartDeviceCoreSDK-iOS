//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingEnumAlertTableViewCell: UITableViewCell {
    
    
    private lazy var backView : UIView = {
        let temp = UIView()
        temp.backgroundColor = .white
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.leading.width.height.equalTo(self.contentView)
        })
        return temp
    }()
    
    
    lazy var contentLabel : UILabel = {
        let temp = UILabel()
        temp.font = UIFont.systemFont(ofSize: 15)
        temp.textAlignment = .center
        temp.textColor = .black
        self.backView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.leading.width.equalTo(self.contentView)
            make.height.equalTo(30.auto())
        })
        return temp
    }()
    
    
    private lazy var desLabel : UILabel = {
        let temp = UILabel()
        temp.font = UIFont.systemFont(ofSize: 11)
        temp.isHidden = true
        temp.textAlignment = .center
        temp.numberOfLines = 0
        temp.textColor = ADTheme.C3
        self.backView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(-8.auto())
            make.height.equalTo(20.auto())
            make.leading.equalTo(self.contentView.snp.leading).offset(24.auto())
        })
        return temp
    }()
    
    @objc override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear//UIColor.hex(0xF5F6FA)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc public func setCell(enumModel: A4xDeviceSettingEnumAlertModel, radiusType: A4xDeviceSettingModuleCornerRadiusType) {
        self.desLabel.text = enumModel.descriptionContent
        self.contentLabel.text = enumModel.content
        if enumModel.descriptionContent != "" {
            
            self.desLabel.isHidden = false
            let textWidth = UIScreen.main.bounds.width - 48.auto()
            let textheight = enumModel.descriptionContent?.textHeightFromTextString(text: enumModel.descriptionContent ?? "", textWidth: textWidth, fontSize: 11, isBold: false) ?? 30.auto()
            self.desLabel.snp.remakeConstraints({ (make) in
                make.centerX.equalTo(self.contentView)
                make.bottom.equalTo(self.contentView).offset(-8.auto())
                make.height.equalTo(textheight)
                make.leading.equalTo(self.contentView.snp.leading).offset(24.auto())
            })
            self.contentLabel.snp.remakeConstraints({ (make) in
                make.top.leading.width.equalTo(self.contentView)
                make.bottom.equalTo(self.desLabel.snp.top)
            })
        } else {
            self.desLabel.isHidden = true
        }
        



        
        
        switch radiusType {
        case .All:
            self.contentView.layer.masksToBounds = true
            self.contentView.layer.cornerRadius = 12
            self.contentView.layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue | CACornerMask.layerMinXMaxYCorner.rawValue | CACornerMask.layerMaxXMaxYCorner.rawValue)
        case .Top:
            self.contentView.layer.masksToBounds = true
            self.contentView.layer.cornerRadius = 12
            self.contentView.layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue)
        case .Bottom:
            self.contentView.layer.masksToBounds = true
            self.contentView.layer.cornerRadius = 12
            self.contentView.layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMaxYCorner.rawValue | CACornerMask.layerMaxXMaxYCorner.rawValue)
        case .None:
            break;
        }
        
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
