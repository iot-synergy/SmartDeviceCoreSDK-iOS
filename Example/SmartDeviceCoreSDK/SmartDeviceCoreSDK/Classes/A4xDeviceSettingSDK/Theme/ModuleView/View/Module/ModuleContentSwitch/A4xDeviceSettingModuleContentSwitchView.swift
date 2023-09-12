//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingModuleContentSwitchView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.titleLabel.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var iconImageView: UIImageView = {
        let temp = UIImageView()
        //temp.image = bundleImageFromImageName("member_more_info_arrow")
        temp.contentMode = .center
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self).offset(16.auto())
            make.width.height.equalTo(24.auto())
            //make.centerY.equalTo(self)
            make.top.equalTo(self).offset(13.auto())
        })
        return temp
    }()
    
    
    lazy var titleLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleContentSwitchView_titleLabel"
        temp.numberOfLines = 2
        temp.textAlignment = .left
        temp.textColor = .black
        temp.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.height.equalTo(self.iconImageView)
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(16.auto())
            make.trailing.equalTo(self).offset(-100.auto())
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
            make.leading.equalTo(self.iconImageView)
            make.top.equalTo(self.iconImageView.snp.bottom).offset(7.5.auto())
            make.height.equalTo(30.auto())
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
    
    //MARK: ----- 通过模型更新UI的方法 -----
    public func updateUI(moduleModel: A4xDeviceSettingModuleModel) {
        
        self.titleLabel.text = moduleModel.title
        
        self.iconImageView.image = bundleImageFromImageName(moduleModel.iconPath)
        self.desLabel.text = moduleModel.titleDescription
        
        self.updateSubViewConstraints(moduleModel: moduleModel)
        
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
        
        







        
        
        if moduleModel.currentType == .OtherNoti {
            self.loadingSwitchView.isHidden = true
            self.isUserInteractionEnabled = false
        }
    }
    
    private func updateSubViewConstraints(moduleModel: A4xDeviceSettingModuleModel) {
        
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
        
        
        let isShowTitleDescription = moduleModel.isShowTitleDescription
        if isShowTitleDescription == true
        {
            
            self.iconImageView.snp.remakeConstraints({ (make) in
                make.leading.equalTo(self).offset(leftPadding)
                make.width.height.equalTo(24.auto())
                make.top.equalTo(self).offset(13.auto())
            })
            self.loadingSwitchView.snp.remakeConstraints({ (make) in
                make.centerY.equalTo(self.iconImageView)
                make.trailing.equalTo(self).offset(-24.auto())
                make.height.equalTo(28.auto())
                make.width.equalTo(44.0.auto())
            })
            self.desLabel.snp.remakeConstraints({ (make) in
                make.centerX.equalTo(self)
                make.leading.equalTo(self.iconImageView)
                make.top.equalTo(self.loadingSwitchView.snp.bottom)
                make.bottom.equalTo(self)
            })
        } else {
            self.iconImageView.snp.remakeConstraints({ (make) in
                make.leading.equalTo(self).offset(16.auto())
                make.width.height.equalTo(24.auto())
                make.centerY.equalTo(self)
            })
        }

        if moduleModel.isNetWorking == true {
            self.loadingSwitchView.isUserInteractionEnabled = false
        }
    }

}
