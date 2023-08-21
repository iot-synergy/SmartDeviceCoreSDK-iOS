//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

@objc public protocol A4xDeviceSettingModuleSliderViewDelegate : AnyObject {
    
    func A4xDeviceSettingModuleSliderViewDidDrag(value: Float)
}

class A4xDeviceSettingModuleSliderView: UIView {
    
    public weak var delegate: A4xDeviceSettingModuleSliderViewDelegate?
    
    public var moduleModel: A4xDeviceSettingModuleModel?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.countLabel.isHidden = false
        self.titleLabel.isHidden = false
        
        self.leftIconImageView.isHidden = false
        self.slider.isHidden = false
        
        self.rightIconImageView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: ----- 云台校准 -----
    
    
    lazy var countLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleSliderView_countLabel"
        temp.textAlignment = .right
        temp.textColor = .black
        temp.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self).offset(10.5.auto())
            make.height.equalTo(24.auto())
            make.width.equalTo(50.auto())
            make.trailing.equalTo(self).offset(-16.auto())
        })
        return temp
    }()
    
    
    lazy var titleLabel: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleSliderView_titleLabel"
        temp.numberOfLines = 2
        temp.textAlignment = .left
        temp.textColor = .black
        temp.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.height.equalTo(self.countLabel)
            make.leading.equalTo(self).offset(16.auto())
            make.trailing.equalTo(self.countLabel.snp.leading).offset(-10.auto())
        })
        return temp
    }()
    
    
    lazy var leftIconImageView: UIImageView = {
        let temp = UIImageView()
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self).offset(-18.auto())
            make.height.width.equalTo(24.auto())
            make.leading.equalTo(self.titleLabel)
        })
        return temp
    }()
    
    lazy var slider: UISlider = {
        let temp = UISlider()
        temp.accessibilityIdentifier = "A4xDeviceSettingModuleSliderView_titleLabel"
        temp.minimumValue = 0.2
        temp.maximumValue = 1.0
        
        if A4xBaseManager.shared.isRTL() == true {
            temp.semanticContentAttribute = .forceRightToLeft
        } else {
            temp.semanticContentAttribute = .forceLeftToRight
        }
        //temp.value = value
        temp.tintColor = ADTheme.Theme
        temp.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
        temp.addTarget(self, action: #selector(sliderDragUpInside(sender:)), for: .touchUpInside)
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.leading.equalTo(self.leftIconImageView.snp.trailing).offset(24.auto())
            make.trailing.equalTo(self).offset(-16.auto())
            make.centerY.equalTo(self.leftIconImageView)
            make.height.equalTo(32.auto())
        }
        return temp
    }()
    
    
    lazy var rightIconImageView: UIImageView = {
        let temp = UIImageView()
        temp.backgroundColor = .red
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.height.centerY.width.equalTo(self.leftIconImageView)
            make.trailing.equalTo(self).offset(-16.auto())
        })
        return temp
    }()
    
    //MARK: ----- 通过模型更新UI的方法 -----
    public func updateUI(moduleModel: A4xDeviceSettingModuleModel) {
        self.moduleModel = moduleModel
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
            make.top.height.equalTo(self.countLabel)
            make.leading.equalTo(self).offset(leftPadding)
            make.trailing.equalTo(self.countLabel.snp.leading).offset(-10.auto())
        }
        
        self.titleLabel.text = moduleModel.title
        
        self.countLabel.text = moduleModel.titleContent
        
        self.leftIconImageView.image = A4xDeviceSettingResource.UIImage(named: moduleModel.leftImage)?.rtlImage()
        self.slider.minimumValue = moduleModel.minValue
        self.slider.maximumValue = moduleModel.maxValue
        self.slider.value = moduleModel.sliderValue
        
        if moduleModel.rightImage.isBlank != true {
            
            
            self.rightIconImageView.isHidden = false
            
            self.leftIconImageView.image = UIImage(named: moduleModel.rightImage)
            
            self.slider.snp.makeConstraints { make in
                make.leading.equalTo(self.leftIconImageView.snp.trailing).offset(24.auto())
                make.trailing.equalTo(self.rightIconImageView.snp.leading).offset(-16.auto())
                make.centerY.equalTo(self.leftIconImageView)
                make.height.equalTo(32.auto())
            }
        }
    }
    
    //MARK: ----- Slider相关 -----
    @objc func sliderValueChanged(sender : UISlider) {
        let currentValue = self.getSliderValue(value: sender.value)
        if self.moduleModel?.scale == 1.0 {
            
            self.countLabel.text = String(format:"%d",Int(currentValue))
        } else {
            
            self.countLabel.text = String(format:"%.1f",currentValue)
        }
        
        let currentType = self.moduleModel?.currentType
        switch currentType {
        case .AlarmRingVolume:
            if sender.value < 50 {
                self.leftIconImageView.image = A4xDeviceSettingResource.UIImage(named: "device_alarm_volume_low")?.rtlImage()
            } else {
                self.leftIconImageView.image = A4xDeviceSettingResource.UIImage(named: "device_alarm_volume_loud")?.rtlImage()
            }
            break
        case .LiveSpeakerVolume:
            fallthrough
        case .VoiceVolume:
            if sender.value <= 0 {
                self.leftIconImageView.image = A4xDeviceSettingResource.UIImage(named: "device_speaker_volume_mute")?.rtlImage()
            } else if sender.value > 0 && sender.value <= 50 {
                self.leftIconImageView.image = A4xDeviceSettingResource.UIImage(named: "device_speaker_volume_low")?.rtlImage()
            } else {
                self.leftIconImageView.image = A4xDeviceSettingResource.UIImage(named: "device_speaker_volume_loud")?.rtlImage()
            }
        default:
            break
        }
    }
    
    
    @objc func sliderDragUpInside(sender : UISlider) {
        
        let currentValue = self.getSliderValue(value: sender.value)
        sender.value = Float(currentValue)
        if self.moduleModel?.scale == 1.0 {
            
            self.countLabel.text = String(format:"%d",Int(currentValue))
        } else {
            
            self.countLabel.text = String(format:"%.1f",currentValue)
        }
        if self.delegate != nil {
            self.delegate?.A4xDeviceSettingModuleSliderViewDidDrag(value: Float(currentValue))
        }
    }
    
    
    
    private func getSliderValue(value : Float) -> Float
    {
        var newValue : Float = 0.0
        
        let minValue = self.moduleModel?.minValue ?? 0.0
        let maxValue = self.moduleModel?.maxValue ?? 0.0
        
        let scale = self.moduleModel?.scale ?? 0.0

        if value <= minValue {
            newValue = minValue
            return newValue
        }
        
        if value >= maxValue {
            newValue = maxValue
            return newValue
        }
        
        
        let loopCount = Int((maxValue - minValue) / scale)
        for i in 0..<loopCount {
            
            
            
            let halfScale = (scale / 2) + minValue + (Float(i) * scale) 
            let leftScale = (Float(i) * scale) + minValue 
            let rightScale = ((Float(i) + 1) * scale) + minValue 
            
            if value <= halfScale && value > leftScale {
                
                newValue = leftScale
            } else if value > halfScale && value <= rightScale {
                newValue = rightScale
            }
        }
        
        return newValue
    }
    
    
    func getSliderShowContent(value : Int) -> (String, Float)
    {
        
        
        
        
        var (text, volume) : (String, Float)
        if value <= 249 {
            (text, volume) = ("0.2s", 0.2)
        } else if value <= 349 && value > 249 {
            (text, volume) = ("0.3s", 0.3)
        } else if value <= 449 && value > 349 {
            (text, volume) = ("0.4s", 0.4)
        } else if value <= 549 && value > 449 {
            (text, volume) = ("0.5s", 0.5)
        } else if value <= 649 && value > 549 {
            (text, volume) = ("0.6s", 0.6)
        } else if value <= 749 && value > 649 {
            (text, volume) = ("0.7s", 0.7)
        } else if value <= 849 && value > 749 {
            (text, volume) = ("0.8s", 0.8)
        } else if value <= 949 && value > 849 {
            (text, volume) = ("0.9s", 0.9)
        } else if value > 949 {
            (text, volume) = ("1.0s", 1.0)
        } else {
            (text, volume) = ("0.2s", 0.2)
        }
        return (text, volume)
    }

}
