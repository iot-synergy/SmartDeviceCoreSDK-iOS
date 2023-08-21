
import UIKit
import SmartDeviceCoreSDK

public class A4xBaseLoadingView: UIView {

    public var isLoading : Bool = false
    
    lazy var loadingTipLab : UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xLiveUIKit_loadingTipLab"
        temp.text = A4xBaseManager.shared.getLocalString(key: "connecting")
        temp.font = ADTheme.B2
        temp.textColor = UIColor.white
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.loadingImg.snp.trailing).offset(5)
            make.centerY.equalTo(self.loadingImg.snp.centerY)
            make.trailing.equalTo(self.snp.trailing)
        })
        return temp
    }()
    
    public lazy var loadingImg : UIImageView = {
        let temp = UIImageView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_loadingImg"
        temp.image = bundleImageFromImageName("home_video_loading")?.rtlImage()
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(0)
            make.leading.equalTo(0)
            make.size.equalTo(CGSize(width: 25.auto(), height: 25.auto()))
        })
        return temp
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        addObserver()
        self.loadingImg.isHidden = false
        self.loadingTipLab.isHidden = false
    }
    
    deinit {
        self.removeObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startAnimail() {
        let count = self.loadingImg.layer.animationKeys()?.count ?? 0
        
        if count > 0 {
            return
        }
        isLoading = true
        self.loadingTipLab.text = A4xBaseManager.shared.getLocalString(key: "connecting")
        let baseAnil = CABasicAnimation(keyPath: "transform.rotation")
        baseAnil.fromValue = 0
        baseAnil.toValue = Double.pi * 2
        baseAnil.duration = 1.5
        baseAnil.repeatCount = MAXFLOAT
        self.loadingImg.layer.add(baseAnil, forKey: "rotation")
    }
    
    public func stopAnimail() {
        isLoading = false

        guard self.loadingImg.layer.animationKeys()?.count ?? 0 > 0 else {
            return
        }
        self.loadingImg.layer.removeAllAnimations()
    }
    
    private func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(beginAction(sender:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func removeObserver(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc
    private func beginAction(sender : UIButton){
        if isLoading {
            self.startAnimail()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 100.auto(), height: 25.auto())
    }
}
