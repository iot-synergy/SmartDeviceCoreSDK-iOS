//


//


//

import UIKit
import SafariServices
import SmartDeviceCoreSDK
import BaseUI

class AccountFirstController: A4xBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = "A4xIdentifier_AccountFirstPage"
        self.bgImageView.isHidden = false
        self.overView.isHidden = false
        self.loginButton.isHidden = false
    }

    lazy private var bgImageView : UIImageView = {
        let temp = UIImageView()
        temp.clipsToBounds = true
        temp.image = bundleImageFromImageName("user_login_bg")?.rtlImage()
        temp.contentMode = .scaleAspectFill
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.view.snp.edges)
        })
        return temp
    }()
    
    lazy private
    var overView : UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.black.withAlphaComponent(0.56)
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.view.snp.edges)
        })
        return temp
    }()

    lazy var loginButton : UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "accountxislogin"
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "has_account_and_login"), for: .normal)
        temp.setTitleColor(UIColor.white, for: .normal)
        temp.titleLabel?.font = ADTheme.B1

        temp.setBackgroundImage(UIImage.color(color: UIColor.white.withAlphaComponent(0.2)), for: .normal)
        temp.setBackgroundImage(UIImage.color(color: UIColor.white.withAlphaComponent(0.2)), for: .disabled)
        temp.setBackgroundImage(UIImage.color(color: UIColor.white.withAlphaComponent(0.2)), for: .highlighted)
        temp.layer.cornerRadius = 25.auto()
        temp.clipsToBounds = true
        
        temp.addTarget(self, action: #selector(loginAction), for: UIControl.Event.touchUpInside)
        self.view.addSubview(temp)

        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width).offset(-70.auto())
            make.height.equalTo(50.auto())
            if #available(iOS 11.0,*) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-50.auto())
            }else {
                make.bottom.equalTo(self.view.snp.bottom).offset(-60.auto())
            }
        })
        return temp
    }()
    
    @objc
    func loginAction() {
        
        SmartDeviceCore.getInstance().login(token: "Bearer eyJhbGciOiJIUzUxMiJ9.eyJ0aGlyZFVzZXJJZCI6InNoZW5tb3VfdGVzdF9uVHpiV1VhQUpHSXN6RzREd045dnYxIiwiYWNjb3VudElkIjoic2hlbm1vdV90ZXN0Iiwic2VlZCI6Ijk1OWY3ZjE2NzNlMjRmMDM4MDQ5ODBiOTZhMWJjZTQ2IiwiZXhwIjoyNjkxNjQ3MjQ1LCJ1c2VySWQiOjEwMTY0ODF9.MwdO-kN6itp6ipJyKwdLancqInNz8yRb3tvFf7g63QvGYHaq_gb5SJtv08X9uvmmTkaMXyQWZXyzgcYtYxCf4g") { code, message in
            let homeVC = RootViewController(menuIndex: 0)
            let nav: A4xBaseAccountNavgationContoller =  A4xBaseAccountNavgationContoller(rootViewController: homeVC)
            nav.setDirectionConfig()
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.window?.rootViewController = nav
        } onError: { code, message in
            
        }

    }

}
