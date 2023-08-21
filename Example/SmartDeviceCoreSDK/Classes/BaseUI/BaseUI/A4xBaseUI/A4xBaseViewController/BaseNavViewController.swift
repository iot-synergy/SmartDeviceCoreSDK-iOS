//


import Foundation


open class BaseNavViewController: A4xBaseViewController {
    
    open var navViewTitle: String? { return nil }
    
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNavtion()
    }
    
    
    private func loadNavtion() {
        weak var weakSelf = self
        self.navView?.title = self.navViewTitle
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg =  "icon_back_gray"
        self.navView?.leftItem = leftItem
        
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
    }
}
