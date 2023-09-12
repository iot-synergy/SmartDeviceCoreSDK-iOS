//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingModulePantiltCalibrationView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.calibrationButton.isHidden = false
        self.titleLabel.isHidden = false
        self.loadingImageView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: ----- 云台校准 -----
    
    lazy var calibrationButton : UIButton = {
        let temp = UIButton()
        temp.backgroundColor = ADTheme.Theme
        temp.setTitleColor(.white, for: .normal)
        temp.layer.cornerRadius = 15.auto()
        temp.layer.masksToBounds = true
        let title = A4xBaseManager.shared.getLocalString(key: "calibrate_start")
        let width = title.textWidthFromTextString(text: title, textHeight: 30, fontSize: 13, isBold: false)
        temp.setTitle(title, for: .normal)
        temp.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self.snp.trailing).offset(-16.auto())
            make.width.equalTo((width + 20).auto())
            make.height.equalTo(40.auto())
        }
        return temp
    }()
    
    
    lazy var loadingImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("home_video_loading")?.rtlImage()
        temp.contentMode = .center
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.calibrationButton.snp.leading).offset(-7.5.auto())
            make.centerY.equalTo(self.calibrationButton)
            make.width.height.equalTo(16.auto())
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
    
    
    lazy var titleLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModulePantiltCalibrationView_titleLabel"
        temp.numberOfLines = 2
        temp.textAlignment = .left
        temp.textColor = .black
        temp.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self)
            make.height.equalTo(40.auto())
            make.leading.equalTo(self).offset(16.auto())
            make.trailing.equalTo(self.calibrationButton.snp.leading).offset(-10.auto())
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
        
        let buttonTitle = moduleModel.buttonTitle
        
        
        if buttonTitle == A4xBaseManager.shared.getLocalString(key: "calibrate_in_progress") {
            self.loadingImageView.isHidden = false
            self.startLoading()
            
            self.titleLabel.snp.remakeConstraints { make in
                make.centerY.equalTo(self)
                make.height.equalTo(40.auto())
                make.leading.equalTo(self).offset(leftPadding)
                make.trailing.equalTo(self.loadingImageView.snp.leading).offset(-10.auto())
            }
            
            self.calibrationButton.backgroundColor = .white
            
            self.calibrationButton.setTitleColor(ADTheme.C3, for: .normal)
            self.calibrationButton.layer.cornerRadius = 0.auto()
        } else {
            self.loadingImageView.isHidden = true
            self.stopLoading()
            
            self.titleLabel.snp.remakeConstraints { make in
                make.centerY.equalTo(self)
                make.height.equalTo(40.auto())
                make.leading.equalTo(self).offset(leftPadding)
                make.trailing.equalTo(self.calibrationButton.snp.leading).offset(-10.auto())
            }
            
            self.calibrationButton.backgroundColor = ADTheme.Theme
            self.calibrationButton.setTitleColor(.white, for: .normal)
            self.calibrationButton.layer.cornerRadius = 15.auto()
            self.calibrationButton.layer.masksToBounds = true
        }
            
        let width = buttonTitle.textWidthFromTextString(text: buttonTitle, textHeight: 30, fontSize: 13, isBold: false)
        self.calibrationButton.setTitle(buttonTitle, for: .normal)
        self.calibrationButton.snp.remakeConstraints { make in
            make.top.equalTo(self).offset(15.auto())
            make.trailing.equalTo(self.snp.trailing).offset(-16.auto())
            make.width.equalTo((width + 20).auto())
            make.height.equalTo(30.auto())
        }
        
    }
    
    
    @objc public func startLoading() {
        self.loadingImageView.isHidden = false
        self.loadingImageView.layer.add(animail, forKey: "loading")
    }
    
    
    @objc public func stopLoading() {
        self.loadingImageView.isHidden = true
        self.loadingImageView.layer.removeAllAnimations()
    }

}
