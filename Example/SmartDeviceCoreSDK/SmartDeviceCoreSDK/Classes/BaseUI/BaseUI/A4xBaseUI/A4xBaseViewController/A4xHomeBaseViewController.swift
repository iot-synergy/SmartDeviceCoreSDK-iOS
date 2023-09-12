//


import Foundation
import SmartDeviceCoreSDK

@objc open class A4xHomeBaseViewController: A4xBaseViewController {
        
    @objc open override var navigationController: UINavigationController? {
        return self.navtion
    }
    private weak var navtion: UINavigationController?

    
    @objc required public init(nav: UINavigationController?) {
        super.init(nibName: nil, bundle: nil)
        self.navtion = nav
        self.navtion?.setDirectionConfig()
    }
    
    open func startReloadData() {}
    
    open func tabbarWillShow() {
        
    }
    
    open func tabbarWillHidden() {
        
    }
    
    private override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        self.init(nav: nil)
    }
}
