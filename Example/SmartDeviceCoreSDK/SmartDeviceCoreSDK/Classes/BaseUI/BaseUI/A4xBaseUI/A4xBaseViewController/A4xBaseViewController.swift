

import UIKit
import SnapKit
import SmartDeviceCoreSDK

public enum FromViewControllerEnum {
    case homeVC
    case liveVC
    case soundSetVC
    case lightSetVC
    case notiticationSetVC
    case registeredVC 
    case apModeBind
    case homeUserFeedBack
}


public enum A4xCellCornerType : Int {
    case all
    case top
    case bottom
    case normal
}

open class A4xBaseViewController: UIViewController, UIGestureRecognizerDelegate {
    open var mutableCreate : Bool = false //允许多次创建
    open var viewControllerIdentifier : String?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    deinit {
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = ADTheme.C6
        self.addAlertCommle()
        

    }
  
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //该页面显示时可以横竖屏切换
        A4xAppSettingManager.shared.interfaceOrientations = .portrait
        
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        } else {
            
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //页面退出时还原强制竖屏状态
        //A4xAppSettingManager.shared.interfaceOrientations = .portrait
        
    }
    
    open func defaultNav() {
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.lineView?.isHidden = false
        weak var weakSelf = self
        self.navView?.leftClickBlock = {
            weakSelf?.back()
        }
    }
    
    open func back(){
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.dismiss(animated: true) {
            }
        }
    }
    
    open dynamic func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    open lazy var navView : A4xBaseNavView? = {
        let temp = A4xBaseNavView();
        temp.backgroundColor = UIColor.white
        self.view.addSubview(temp)
    
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(0)
            make.trailing.equalTo(self.view.snp.trailing)
            make.top.equalTo(0)
        })
        return temp
    }()
    
    
    open func addAlertCommle() {
        
        weak var weakSelf = self
        A4xBaseErrorUnit.addAccountCompleBlock(type: .noLogin, Tag: type(of: self).description()) { (error) in
            weakSelf?.tipAlert(des: error)
        }
        A4xBaseErrorUnit.addAccountCompleBlock(type: .loginExpired, Tag: type(of: self).description()) { (error) in
            weakSelf?.tipAlert(des: error)
        }
        A4xBaseErrorUnit.addAccountCompleBlock(type: .otherLogin, Tag: type(of: self).description()) { (error) in
            weakSelf?.tipAlert(des: error, buttonTitle: A4xBaseManager.shared.getLocalString(key: "resign_in"))
        }
        A4xBaseErrorUnit.addAccountCompleBlock(type: A4xAccountErrorType.deviceRemove, Tag: type(of: self).description()) { [weak self] (error) in



        }
    }
    
    open func tipAlert(des: String, buttonTitle: String = A4xBaseManager.shared.getLocalString(key: "got_it")) {
        
        DispatchQueue.main.async {
            if A4xUserDataHandle.Handle?.loginModel == nil {
                return
            }
            
            A4xUserDataHandle.Handle?.clearAllData()

            let alert = A4xBaseAlertView(identifier: A4xBaseManager.shared.getLocalString(key: "logout"))
            alert.message  = des
            alert.rightButtonTitle = buttonTitle
            alert.rightButtonBlock = {
                UserDefaults.standard.set("1", forKey: "login_out")
                
            }
            alert.show()
        }
    }
    
    open override func didReceiveMemoryWarning() {
        
    }
}
