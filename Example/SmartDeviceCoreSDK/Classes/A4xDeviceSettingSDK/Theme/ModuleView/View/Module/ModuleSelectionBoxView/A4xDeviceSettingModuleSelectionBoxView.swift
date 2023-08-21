//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingModuleSelectionBoxView: UIView {

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
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleSelectionBoxView_titleLabel"
        temp.numberOfLines = 2
        temp.textAlignment = .left
        temp.textColor = ADTheme.C2
        temp.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.height.equalTo(self)
            make.leading.equalTo(self).offset(16.auto())
            make.trailing.equalTo(self).offset(-100.auto())
        })
        return temp
    }()
    
    
    lazy var selectImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("checkbox_unselect")?.rtlImage()
        temp.contentMode = .scaleAspectFill
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self).offset(-8.auto())
            make.centerY.equalTo(self)
            make.width.height.equalTo(15.auto())
        })
        return temp
    }()
    
    
    lazy var arrowImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("member_more_info_arrow")
        temp.contentMode = .center
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self).offset(-8.auto())
            make.centerY.equalTo(self)
            make.width.height.equalTo(16.auto())
        })
        return temp
    }()
    
    
    lazy var loadingImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("home_video_loading")?.rtlImage()
        temp.contentMode = .scaleAspectFill
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self).offset(-8.auto())
            make.centerY.equalTo(self)
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
        self.loadingImageView.isHidden = false
        self.arrowImageView.isHidden = true
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
            make.centerY.height.equalTo(self)
            make.leading.equalTo(self).offset(leftPadding)
            make.trailing.equalTo(self).offset(-100.auto())
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
        
        






        
        let currentType = moduleModel.currentType
        if currentType == .VehicleNotiMark || currentType == .PackageNotiDetection {
            self.selectImageView.isHidden = true
            self.loadingImageView.isHidden = true
            self.arrowImageView.isHidden = false
        } else {
            self.arrowImageView.isHidden = true
        }
        
        if moduleModel.isNetWorking == true {
            self.isUserInteractionEnabled = false
        } else {
            self.isUserInteractionEnabled = true
        }
    }

}
