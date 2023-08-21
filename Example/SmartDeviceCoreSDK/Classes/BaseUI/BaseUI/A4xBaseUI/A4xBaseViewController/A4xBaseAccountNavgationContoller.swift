//


//


//

import UIKit

public class A4xBaseAccountNavgationContoller: UINavigationController , UIGestureRecognizerDelegate{
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.isEnabled = false;
        self.interactivePopGestureRecognizer?.delegate = self
        self.navigationBar.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = true
        self.edgesForExtendedLayout = .top
    }
    
    public override var childForStatusBarStyle: UIViewController? {
         return self.topViewController
     }
}
