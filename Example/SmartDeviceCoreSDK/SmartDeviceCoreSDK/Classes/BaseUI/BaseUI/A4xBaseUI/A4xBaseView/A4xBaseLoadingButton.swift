
import UIKit
import SmartDeviceCoreSDK

public class A4xBaseLoadingButton : UIButton {
    public var isLoading : Bool = false {
        didSet {
            if isLoading {
                self.isUserInteractionEnabled = false
                self.loadingView.isHidden = false
                self.loadingView.layer.add(animail, forKey: "ddd")
                self.imageView?.isHidden = true
                self.titleLabel?.isHidden = true
                self.imageView?.isHidden = true
            }else {
                self.loadingView.isHidden = true
                self.loadingView.layer.removeAllAnimations()
                self.isUserInteractionEnabled = true
                self.imageView?.isHidden = false
                self.titleLabel?.isHidden = false
                self.imageView?.isHidden = false

            }
        }
    }
    
    private lazy var animail : CABasicAnimation = {
        let baseAnil = CABasicAnimation(keyPath: "transform.rotation")
        baseAnil.fromValue = 0
        baseAnil.toValue = Double.pi * 2
        baseAnil.duration = 1.5
        baseAnil.repeatCount = MAXFLOAT
        return baseAnil
    }()
    
    private lazy var loadingView : UIImageView = {
        let loadingV = UIImageView()
        loadingV.image = bundleImageFromImageName("home_video_loading")?.rtlImage()
        loadingV.contentMode = .center
        self.addSubview(loadingV)
        
        loadingV.snp.makeConstraints { (make) in
            make.size.equalTo(self.snp.size)
            make.centerY.equalTo(self.snp.centerY)
            make.centerX.equalTo(self.snp.centerX)
        }
        return loadingV
    }()
}
