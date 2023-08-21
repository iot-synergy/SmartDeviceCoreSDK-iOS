//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingModuleMultiTextSelectionBoxView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.titleLabel.isHidden = false
        self.selectImageView.isHidden = false
        self.loadingImageView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    lazy var titleLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleMultiTextSelectionBoxView_titleLabel"
        temp.numberOfLines = 2
        temp.textAlignment = .left
        temp.textColor = ADTheme.C1
        temp.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self).offset(16.auto())
            make.height.equalTo(22.4.auto())
            make.leading.equalTo(self).offset(16.auto())
            make.trailing.equalTo(self).offset(-100.auto())
        })
        return temp
    }()
    
    
    lazy var desLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleMultiTextSelectionBoxView_desLabel"
        temp.numberOfLines = 0
        temp.textAlignment = .left
        temp.textColor = ADTheme.C3
        temp.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(4.auto())
            make.height.equalTo(40.auto())
            make.leading.equalTo(self).offset(16.auto())
            make.centerX.equalTo(self)
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
    
    
    lazy var selectImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("checkbox_unselect")?.rtlImage()
        temp.contentMode = .scaleAspectFill
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.desLabel)
            make.centerY.equalTo(self.titleLabel)
            make.width.height.equalTo(15.auto())
        })
        return temp
    }()
    
    
    lazy var loadingImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("home_video_loading")?.rtlImage()
        temp.contentMode = .scaleAspectFill
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.desLabel)
            make.centerY.equalTo(self.titleLabel)
            make.width.height.equalTo(15.auto())
        })
        return temp
    }()
    
    private lazy var animail: CABasicAnimation = {
        let baseAnil = CABasicAnimation(keyPath: "transform.rotation")
        baseAnil.fromValue = 0
        baseAnil.toValue = Double.pi * 2
        baseAnil.duration = 1.5
        baseAnil.repeatCount = MAXFLOAT
        return baseAnil
    }()
    
    
    @objc public func startLoading() {
        self.selectImageView.isHidden = true
        self.titleLabel.isHidden = false
        self.desLabel.isHidden = false
        self.loadingImageView.isHidden = false
        self.separatorView.isHidden = true
        self.loadingImageView.layer.add(animail, forKey: "loading")
    }
    
    
    @objc public func stopLoading() {
        self.selectImageView.isHidden = false
        self.titleLabel.isHidden = false
        self.loadingImageView.isHidden = true
        self.loadingImageView.layer.removeAllAnimations()
    }
    
    //MARK: ----- 通过模型更新UI的方法 -----
    public func updateUI(moduleModel: A4xDeviceSettingModuleModel, leftPadding: CGFloat = 0.auto()) {
        
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
            make.top.equalTo(self).offset(16.auto())
            make.height.equalTo(22.4.auto())
            make.leading.equalTo(self).offset(leftPadding)
            make.trailing.equalTo(self).offset(-100.auto())
        }
        
        
        let screenWidth = UIScreen.main.bounds.width
        let textWidth : CGFloat = screenWidth - 48.auto()
        let height = moduleModel.titleDescription.textHeightFromTextString(text: moduleModel.titleDescription, textWidth: textWidth, fontSize: 13, isBold: false)
        
        
        self.desLabel.text = moduleModel.titleDescription
        self.desLabel.snp.remakeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(4.auto())
            make.height.equalTo(height + 1.0.auto())
            make.leading.equalTo(self).offset(leftPadding)
            make.centerX.equalTo(self)
        }
        
        
        let isShowSeparator = moduleModel.isShowSeparator
        if isShowSeparator == true {
            self.separatorView.isHidden = false
        } else {
            self.separatorView.isHidden = true
        }
        
        
        let isSelected = moduleModel.isSelected
        let isSelectionBoxLoading = moduleModel.isSelectionBoxLoading
        if isSelectionBoxLoading == true {
            
            self.selectImageView.isHidden = true
            self.loadingImageView.isHidden = false
            self.startLoading()
        } else {
            self.selectImageView.isHidden = false
            self.loadingImageView.isHidden = true
            self.stopLoading()
            if isSelected == true {
                self.selectImageView.image = bundleImageFromImageName("checkbox_select")
            } else {
                self.selectImageView.image = bundleImageFromImageName("checkbox_unselect")
            }
        }

        if moduleModel.isNetWorking == true {
            self.isUserInteractionEnabled = false
        } else {
            self.isUserInteractionEnabled = true
        }
    }

}
