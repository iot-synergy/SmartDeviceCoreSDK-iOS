//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingModuleCheckBoxTitleView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.titleLabel.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var titleLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleCheckBoxTitleView_titleLabel"
        temp.numberOfLines = 2
        temp.textAlignment = .left
        temp.textColor = .black
        temp.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self).offset(19.auto())
            make.height.equalTo(22.auto())
            make.leading.equalTo(self).offset(16.auto())
            make.width.equalTo(120.auto())
        })
        return temp
    }()
    
    
    lazy var contentLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleCheckBoxTitleView_contentLabel"
        temp.numberOfLines = 0
        temp.textAlignment = .right
        temp.textColor = ADTheme.C4
        temp.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.height.equalTo(self.titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(8.auto())
            make.trailing.equalTo(self).offset(-16.auto())
        })
        return temp
    }()
    
    
    lazy var titleDescriptionLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleCheckBoxTitleView_titleDescriptionLabel"
        temp.numberOfLines = 0
        temp.textAlignment = .left
        temp.textColor = ADTheme.C3
        temp.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self)
            make.leading.equalTo(self.titleLabel)
            //make.top.equalTo(self.titleLabel.snp.bottom).offset(8.auto())
            make.bottom.equalTo(self).offset(-8.auto())
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
    public func updateUI(moduleModel: A4xDeviceSettingModuleModel) {
        
        self.titleLabel.text = moduleModel.title
        self.contentLabel.text = moduleModel.titleContent
        self.titleDescriptionLabel.text = moduleModel.titleDescription
        
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
        
        
        let isShowTitleDescription = moduleModel.isShowTitleDescription
        if isShowTitleDescription == true {
            self.titleLabel.snp.remakeConstraints({ (make) in
                make.top.equalTo(self).offset(19.auto())
                make.height.equalTo(22.auto())
                make.leading.equalTo(self).offset(16.auto())
                make.width.equalTo(160.auto())
            })
            
        } else {
            
            self.titleLabel.snp.remakeConstraints { make in
                make.centerY.height.equalTo(self)
                make.leading.equalTo(self).offset(leftPadding)
                make.width.equalTo(120.auto())
            }
        }
        
        if moduleModel.titleContent == "" {
            self.titleLabel.snp.updateConstraints { make in
                make.width.equalTo(240.auto())
            }
        }

        
        let isShowSeparator = moduleModel.isShowSeparator
        if isShowSeparator == true {
            self.separatorView.isHidden = false
        } else {
            self.separatorView.isHidden = true
        }

    }

}
