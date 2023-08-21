//


//




import UIKit
import SmartDeviceCoreSDK
import BaseUI

let advertisementLeftViewMaxHeight = 124.auto()




public class A4xDeviceSettingModuleAdvertisementLeftView: UIView {
         
    public lazy var titleLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleAdvertisementLeftView_titleLabel"
        temp.numberOfLines = 0
        temp.textAlignment = .left
        temp.textColor = .black
        temp.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.leading.width.equalTo(self)
            make.height.equalTo(25.auto())
        })
        return temp
    }()
    
    
    public lazy var goBuyButton: UIButton = {
        let temp = UIButton(type: .system)
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleAdvertisementLeftView_goBuyButton"
        temp.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        temp.setTitleColor(ADTheme.C1, for: .normal)
        temp.layer.cornerRadius = 13.auto()
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8.auto())
            make.leading.equalTo(self)
            make.height.equalTo(26.auto())
            make.width.equalTo(100.auto())
        })
        return temp
    }()
    
}


class A4xDeviceSettingModuleAdvertisementView: UIView {

    
    lazy var leftView: A4xDeviceSettingModuleAdvertisementLeftView = {
        let temp = A4xDeviceSettingModuleAdvertisementLeftView()
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self).offset(16.auto())
            make.centerY.equalTo(self)
            make.height.equalTo(82.auto())
            make.width.equalTo(advertisementLeftViewMaxHeight)
        })
        return temp
    }()
    
    
    lazy var advertisementImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = A4xDeviceSettingResource.UIImage(named: "device_set_advertisement")
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self).offset(-16.auto())
            make.centerY.equalTo(self)
            make.height.equalTo(82.auto())
            make.width.equalTo(184.auto())
        })
        return temp
    }()
    
    //MARK: ----- 通过模型更新UI的方法 -----
    public func updateUI(moduleModel: A4xDeviceSettingModuleModel) {
        
        self.leftView.titleLabel.text = moduleModel.title
        self.leftView.goBuyButton.setTitle(moduleModel.buttonTitle, for: .normal)
        
        var leftPadding = 0.auto()
        let levelType = moduleModel.moduleLevelType
        switch levelType {
        case .Main:
            leftPadding = A4xDeviceSettingModuleLeftPadding_LevelMain
            //rightPadding = 0.auto()
            break
        case .Notification:
            leftPadding = A4xDeviceSettingModuleLeftPadding_LevelNotification
            break
        case .Other:
            leftPadding = A4xDeviceSettingModuleLeftPadding_LevelOther
            break
        default:
            leftPadding = A4xDeviceSettingModuleLeftPadding_LevelMain
            break
        }
        
        
        self.leftView.snp.remakeConstraints({ (make) in
            make.leading.equalTo(self).offset(16.auto())
            make.centerY.equalTo(self)
            make.height.equalTo(moduleModel.moduleHeight - 16.auto())
            make.width.equalTo(advertisementLeftViewMaxHeight)
        })
        
        let title = moduleModel.title
        let titleHeight = title.textHeightFromTextString(text: title, textWidth: advertisementLeftViewMaxHeight, fontSize: 18, isBold: true) + 1
        self.leftView.titleLabel.snp.remakeConstraints({ (make) in
            make.top.leading.width.equalTo(self.leftView)
            make.height.equalTo(titleHeight)
        })
        
        
        let buttonTitle = moduleModel.buttonTitle
        self.leftView.goBuyButton.setTitle(buttonTitle, for: .normal)
        
        let buttonTextWidth = buttonTitle.textWidthFromTextString(text: buttonTitle, textHeight: 26.auto(), fontSize: 13, isBold: false)
        let buttonWidth = buttonTextWidth + 26.auto()
        self.leftView.goBuyButton.snp.remakeConstraints({ (make) in
            make.top.equalTo(self.leftView.titleLabel.snp.bottom).offset(8.auto())
            make.leading.equalTo(self.leftView)
            make.height.equalTo(26.auto())
            if buttonWidth >= advertisementLeftViewMaxHeight {
                make.width.equalTo(advertisementLeftViewMaxHeight)
            } else {
                make.width.equalTo(buttonWidth)
            }
        })
        
        let startColor = UIColor(hex: "#FAE1A9") ?? UIColor()
        let endColor = UIColor(hex: "#FBEBCF") ?? UIColor()
        self.leftView.goBuyButton.gradientColor(CGPoint(x:0, y:0), CGPoint(x:1, y:0), [startColor.cgColor, endColor.cgColor])
        
        
        self.advertisementImageView.image = A4xDeviceSettingResource.UIImage(named: moduleModel.rightImage)

    }
    
}
