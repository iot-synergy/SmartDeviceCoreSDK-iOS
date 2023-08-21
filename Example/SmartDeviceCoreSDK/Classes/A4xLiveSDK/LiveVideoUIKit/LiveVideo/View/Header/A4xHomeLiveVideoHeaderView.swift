//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI


class A4xHomeLiveVideoHeaderView: UIView {
 
    
    var headAddCameraClickBlock : (()->Void)?
    
    var addCameraImage : UIImage? {
        didSet {
            self.addCameraView.setImage(addCameraImage, for: UIControl.State.normal)
            self.addCameraView.isHidden = false
        }
    }
    
    @objc func headerAddCameraActin(sender : UIButton){
        self.headAddCameraClickBlock?()
    }
    
    lazy var addCameraView: UIButton = { 
        var temp: UIButton = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_bindCameraBtn"
        self.addSubview(temp)
        temp.setImage(A4xLiveUIResource.UIImage(named: "nav_add_device_right")?.rtlImage(), for: UIControl.State.normal)
        temp.imageView?.contentMode = .scaleAspectFit
        temp.imageEdgeInsets = UIEdgeInsets(top: 10.auto(), left: 10.auto(), bottom: 10.auto(), right: 10.auto())
        temp.addTarget(self, action: #selector(headerAddCameraActin(sender:)), for: UIControl.Event.touchUpInside)
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom).offset(-10)
            make.height.equalTo(44.auto())
            make.width.equalTo(44.auto())
            make.trailing.equalTo(self.snp.trailing).offset(-15.5.auto())
        })
        return temp
    }()
    
   
   
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        self.addCameraView.isHidden = false

    }
    
    deinit {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
