//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingModuleInformationBarView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.iconImageView.isHidden = false
        self.titleLabel.isHidden = false
        self.infoImageView.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var iconImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("checkbox_unselect")?.rtlImage()
        temp.contentMode = .scaleAspectFill
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self).offset(16.auto())
            make.centerY.equalTo(self)
            make.width.height.equalTo(22.4.auto())
        })
        return temp
    }()
    
    
    lazy var infoImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("checkbox_unselect")?.rtlImage()
        temp.contentMode = .scaleAspectFill
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-16.auto())
            make.centerY.equalTo(self.iconImageView)
            make.width.height.equalTo(17.auto())
        })
        return temp
    }()
    
    
    lazy var titleLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleMultiTextSelectionBoxView_titleLabel"
        temp.numberOfLines = 2
        temp.textAlignment = .left
        temp.textColor = ADTheme.C1
        temp.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(22.4.auto())
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(16.auto())
            make.trailing.equalTo(self.infoImageView.snp.leading).offset(-16.auto())
        })
        return temp
    }()
    
    
    
    lazy var separatorView: UIView = {
        let temp = UIView()
        temp.backgroundColor = A4xDeviceSettingModuleTool().getSeparatorColor()
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.bottom.centerX.equalTo(self)
            make.trailing.equalTo(self).offset(-16.auto())
            make.height.equalTo(1.auto())
        })
        return temp
    }()
    
    
    //MARK: ----- 通过模型更新UI的方法 -----
    public func updateUI(moduleModel: A4xDeviceSettingModuleModel, leftPadding: CGFloat = 0.auto()) {
        
        self.titleLabel.text = moduleModel.title
        self.iconImageView.image = A4xDeviceSettingResource.UIImage(named: moduleModel.leftImage)
        self.infoImageView.image = A4xDeviceSettingResource.UIImage(named: moduleModel.rightImage)
        
        var leftPadding = 0.auto()
        let levelType = moduleModel.moduleLevelType
        switch levelType {
        case .Main:
            leftPadding = A4xDeviceSettingModuleLeftPadding_LevelMain
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
        
        self.iconImageView.snp.remakeConstraints({ (make) in
            make.leading.equalTo(self).offset(leftPadding)
            make.centerY.equalTo(self)
            make.width.height.equalTo(22.4.auto())
        })
        
        
        
        
        let isShowSeparator = moduleModel.isShowSeparator
        if isShowSeparator == true {
            self.separatorView.isHidden = false
        } else {
            self.separatorView.isHidden = true
        }
        

    }

}
