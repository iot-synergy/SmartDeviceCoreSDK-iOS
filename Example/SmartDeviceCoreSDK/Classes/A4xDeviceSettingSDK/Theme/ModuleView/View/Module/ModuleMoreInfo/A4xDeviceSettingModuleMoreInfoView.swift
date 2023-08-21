//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingModuleMoreInfoView: UIView {

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
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleMoreInfoView_titleLabel"
        temp.numberOfLines = 2
        temp.textAlignment = .left
        temp.textColor = .black
        temp.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self).offset(19.auto())
            make.height.equalTo(22.auto())
            make.leading.equalTo(self).offset(16.auto())
            make.trailing.equalTo(self).offset(-100.auto())
        })
        return temp
    }()
    
    //MARK: ----- 未订阅鸟类UI -----
    
    lazy var learnMoreButton : UIButton = {
        let temp = UIButton()
        temp.backgroundColor = ADTheme.Theme
        temp.setTitleColor(.white, for: .normal)
        temp.layer.cornerRadius = 15.auto()
        temp.layer.masksToBounds = true
        let title = A4xBaseManager.shared.getLocalString(key: "learn_more_2")
        let width = title.textWidthFromTextString(text: title, textHeight: 30, fontSize: 13, isBold: false)
        temp.setTitle(title, for: .normal)
        temp.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.top.equalTo(self).offset(15.auto())
            make.trailing.equalTo(self.snp.trailing).offset(-16.auto())
            make.width.equalTo((width + 20).auto())
            make.height.equalTo(30.auto())
        }
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
    
    
    lazy var desLabel: UILabel = {
        let temp = UILabel()
        temp.numberOfLines = 0
        temp.textAlignment = .left
        temp.font = UIFont.systemFont(ofSize: 13)
        temp.textColor = ADTheme.C3
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self)
            make.leading.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5.auto())
            make.height.equalTo(self)
        })
        return temp
    }()
    
    //MARK: ----- 通过模型更新UI的方法 -----
    public func updateUI(moduleModel: A4xDeviceSettingModuleModel) {
        
        self.titleLabel.text = moduleModel.title
        
        
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
        
        self.titleLabel.snp.remakeConstraints { make in
            make.top.equalTo(self).offset(19.auto())
            make.height.equalTo(22.auto())
            make.leading.equalTo(self).offset(leftPadding)
            make.trailing.equalTo(self).offset(-100.auto())
        }
        
        
        let buttonTitle = moduleModel.buttonTitle
        let width = buttonTitle.textWidthFromTextString(text: buttonTitle, textHeight: 30, fontSize: 13, isBold: false)
        self.learnMoreButton.setTitle(buttonTitle, for: .normal)
        self.learnMoreButton.snp.remakeConstraints { make in
            make.top.equalTo(self).offset(15.auto())
            make.trailing.equalTo(self.snp.trailing).offset(-16.auto())
            make.width.equalTo((width + 20).auto())
            make.height.equalTo(30.auto())
        }
        
        
        let isShowTitleDescription = moduleModel.isShowTitleDescription
        let titleDescription = moduleModel.titleDescription
        let tool = A4xDeviceSettingModuleTool()
        if isShowTitleDescription == true {
            let height = tool.getTitleDesHeight(moduleModel: moduleModel)
            self.desLabel.snp.remakeConstraints { make in
                make.centerX.equalTo(self)
                make.leading.equalTo(self.titleLabel)
                make.top.equalTo(self.titleLabel.snp.bottom).offset(10.auto())
                make.height.equalTo(height)
            }
            self.desLabel.isHidden = false
            self.desLabel.text = titleDescription
        } else {
            self.desLabel.isHidden = true
        }
        
        
        let isShowSeparator = moduleModel.isShowSeparator
        if isShowSeparator == true {
            self.separatorView.isHidden = false
        } else {
            self.separatorView.isHidden = true
        }
        
        






                
    }
    
    

}
