
import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingModuleSwitchView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.titleLabel.isHidden = false
        self.desLabel.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var titleLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleSwitchView_titleLabel"
        temp.numberOfLines = 2
        temp.textAlignment = .left
        temp.textColor = .black
        temp.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.height.equalTo(self)
            make.leading.equalTo(self).offset(16.auto())
            make.trailing.equalTo(self).offset(-80.auto())
        })
        return temp
    }()
    
    
    lazy var introduceLabel: UILabel = {
        let temp = UILabel()
        temp.numberOfLines = 0
        temp.textAlignment = .left
        temp.font = UIFont.systemFont(ofSize: 13)
        temp.textColor = ADTheme.C3
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self)
            make.leading.equalTo(self.titleLabel)
            make.top.equalTo(self.separatorView.snp.bottom)
            make.height.equalTo(self)
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
    
    lazy var loadingSwitchView: A4xDeviceSettingModuleLoadingSwitchView = {
        let temp = A4xDeviceSettingModuleLoadingSwitchView()
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-24.auto())
            make.height.equalTo(28.auto())
            make.width.equalTo(44.0.auto())
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
            make.top.equalTo(self.loadingSwitchView.snp.bottom)
            make.height.equalTo(40.auto())
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
            make.centerY.height.equalTo(self)
            make.leading.equalTo(self).offset(leftPadding)
            make.trailing.equalTo(self).offset(-80.auto())
        }
        
        
        let isShowTitleDescription = moduleModel.isShowTitleDescription
        let titleDescription = moduleModel.titleDescription
        let tool = A4xDeviceSettingModuleTool()
        if isShowTitleDescription == true {
            let height = tool.getTitleDesHeight(moduleModel: moduleModel)
            self.desLabel.snp.remakeConstraints { make in
                make.centerX.equalTo(self)
                make.leading.equalTo(self.titleLabel)
                make.top.equalTo(self.loadingSwitchView.snp.bottom)
                make.height.equalTo(height)
            }
            self.desLabel.isHidden = false
            self.desLabel.text = titleDescription
        } else {
            self.desLabel.isHidden = true
        }
        
        let isInteractiveHidden = moduleModel.isInteractiveHidden
        if isInteractiveHidden == true {
            
            self.loadingSwitchView.isHidden = true
        } else {
            self.loadingSwitchView.isHidden = false
        }
        
        
        let isSwitchLoading = moduleModel.isSwitchLoading
        let isSwitchOpen = moduleModel.isSwitchOpen
        if isSwitchLoading == true {
            
            self.loadingSwitchView.startLoading()
        } else {
            self.loadingSwitchView.stopLoading()
            if isSwitchOpen == true {
                self.loadingSwitchView.loadingSwitch.isOn = true
            } else {
                self.loadingSwitchView.loadingSwitch.isOn = false
            }
        }
        
        
        let isShowIntroduce = moduleModel.isShowIntroduce
        let introduce = moduleModel.introduce
        if isShowIntroduce == true {
            let height = tool.getIntroduceHeight(moduleModel: moduleModel)
            self.introduceLabel.snp.remakeConstraints { make in
                make.centerX.equalTo(self)
                make.leading.equalTo(self.titleLabel)
                make.top.equalTo(self.separatorView.snp.bottom)
                make.height.equalTo(height)
            }
            self.introduceLabel.isHidden = false
            self.introduceLabel.text = introduce
        } else {
            self.introduceLabel.isHidden = true
        }
        
        
        let isShowSeparator = moduleModel.isShowSeparator
        if isShowSeparator == true {
            self.separatorView.isHidden = false
        } else {
            self.separatorView.isHidden = true
        }
          
        







    }

}
