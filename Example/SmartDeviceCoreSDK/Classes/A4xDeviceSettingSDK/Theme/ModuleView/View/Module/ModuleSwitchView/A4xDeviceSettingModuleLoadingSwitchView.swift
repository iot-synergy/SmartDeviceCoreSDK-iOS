
import UIKit
import SmartDeviceCoreSDK
import BaseUI

@objc public class A4xDeviceSettingModuleLoadingSwitchView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.loadingSwitch.isHidden = false
        self.loadingImageView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var loadingImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("home_video_loading")?.rtlImage()
        temp.contentMode = .center
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.bottom.left.right.equalTo(self)
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
    
    
    public lazy var loadingSwitch: UISwitch = {
        let temp = UISwitch()
        temp.onTintColor = ADTheme.Theme
        temp.tintColor = ADTheme.C5
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.bottom.left.right.equalTo(self)
        })
        return temp
    }()
    
    
    @objc public func startLoading() {
        self.loadingSwitch.isHidden = true
        self.loadingImageView.isHidden = false
        self.loadingImageView.layer.add(animail, forKey: "loading")
    }
    
    
    @objc public func stopLoading() {
        self.loadingSwitch.isHidden = false
        self.loadingImageView.isHidden = true
        self.loadingImageView.layer.removeAllAnimations()
    }

}
