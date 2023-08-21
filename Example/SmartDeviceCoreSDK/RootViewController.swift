//


//




import UIKit
import SmartDeviceCoreSDK
import A4xLiveVideoUIKit
import A4xLiveVideoUIInterface
import A4xLibraryUIKit
import BaseUI

class RootViewController: UITabBarController {
    private var editModle : Bool = false
    private var isHidenBar: Bool = false
    
    public var currentViewController: UIViewController? {
        return self.viewControllers?.getIndex(self.bottomBar.currentIndex)
    }
   
    init(menuIndex: Int) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: LanguageChangeNotificationKey, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        DispatchQueue.main.a4xAfter(0.02) {
            
            self.loadViewControllers()
            
            self.bottomBar.isHidden = false
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: LanguageChangeNotificationKey, object: nil, queue: OperationQueue.main) { (noti) in
            weakSelf?.bottomBar.updateInfo()
            weakSelf?.bottomBar.createBarView()
            A4xUserDataHandle.Handle?.nodeCountry = nil
        }
    }
    
    
    @objc private func loadViewControllers() {
        weak var weakSelf = self
        
        var vcs: [UIViewController] = Array()
        
        let liveViewController: A4xHomeLiveVideoViewController = A4xHomeLiveVideoViewController(nav: self.navigationController)
        vcs.append(liveViewController)
        let libraryViewController = A4xHomeLibraryBaseViewController(nav: self.navigationController)
        libraryViewController.libraryEditBtnClickCallback = { editModle in
            weakSelf?.editModleChange(flag: editModle)
        }
        vcs.append(libraryViewController)
        vcs.append(HomeUserViewController(nav: self.navigationController))
        
        self.viewControllers = vcs
        self.tabBar.isHidden = true
        
        self.setCurrentViewController(A4xHomeLiveVideoViewController.self)
    }

    private func editModleChange(flag: Bool) {
        self.editModle = flag
        self.bottomBar.snp.updateConstraints({ (make) in
            make.bottom.equalTo(self.view.snp.bottom).offset(flag ? UIScreen.bottomBarHeight : 0)
        })
        self.view.layoutIfNeeded()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.updateBarView(isHiden: self.isHidenBar)
    }
    
    private func updateBarView(isHiden: Bool) {
        self.isHidenBar = isHiden
        var barHeight: CGFloat = 0
        if !self.isHidenBar {
            barHeight = UIScreen.bottomBarHeight
        }
        
        self.view.subviews.forEach { (v) in
            guard !(v is UITabBar) else {
                return
            }
            
            guard !(v is HomeBottomBarView) else {
                return
            }
            
            v.frame = CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height - (self.editModle ? 0 : barHeight))
        }
    }

    //MARK:-  create view
    lazy var bottomBar: HomeBottomBarView = {
        weak var weakSelf = self
        let temp: HomeBottomBarView = HomeBottomBarView()
        self.view.addSubview(temp)
        
        temp.bottomSelectBlock = { [weak self] (selectedIndex) in
            let oldVc: A4xHomeBaseViewController? = weakSelf?.selectedViewController as? A4xHomeBaseViewController
            
            
            self?.selectedIndex = selectedIndex
            
            let newVc = weakSelf?.selectedViewController as? A4xHomeBaseViewController
            if let oc: A4xHomeBaseViewController = oldVc, let nv: A4xHomeBaseViewController = newVc {
                if (oc.self != nv.self){
                    oc.tabbarWillHidden()
                }
                nv.tabbarWillShow()
            }

        }
        
        temp.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.snp.bottom)
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.height.equalTo(UIScreen.bottomBarHeight)
        }
        
        return temp
    }()

    
    
    public func setCurrentViewController<T>(_ type: T.Type = T.self) {
        
        if let viewController = self.viewControllers?.filter({$0 is T}).first, let index = self.viewControllers?.firstIndex(of: viewController) {
            self.bottomBar.currentIndex = index
        }
    }
}


extension RootViewController {
    private func getNavigation() -> UINavigationController? {
        var navtions : UINavigationController? = nil
        UIApplication.shared.windows.forEach { (wind) in
            if let nav = wind.rootViewController as? UINavigationController {
                navtions = nav
            }
        }
        navtions?.setDirectionConfig()
        return navtions
    }
}



