//


//


//

import Foundation
import UIKit

extension UIViewController {
    open var isNavigationTopVC: Bool {
        if let nav = self.navigationController  {
            let viewControllers = nav.viewControllers
            if viewControllers.count == 1 {
                return true
            }
          
            let lastClass = type(of: self)
            let currentClass = type(of: viewControllers.last!)
            
            if lastClass == currentClass {
                return true
            }
            
            return false
        } else  {
            return self.presentedViewController == nil && view.window != nil
        }
    }
    
    
    public func getPresentedViewControllerFromNav(by name: String) -> UIViewController? {
        var toViewController: UIViewController? = nil
        let vc = self.navigationController?.presentedViewController
        if vc?.className == name {
            toViewController = vc
        }
        guard toViewController != nil else {
            return nil
        }
        return toViewController
    }
    
    /** 获取当前控制器 */
    public static func current() -> UIViewController {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        return UIViewController.findBest(vc: vc ?? UIViewController())
    }
    
    private static func findBest(vc: UIViewController) -> UIViewController {
        if vc.presentedViewController != nil {
            return UIViewController.findBest(vc: vc.presentedViewController!)
        } else if vc.isKind(of: UISplitViewController.self) {
            let svc = vc as! UISplitViewController
            if svc.viewControllers.count > 0 {
                return UIViewController.findBest(vc: svc.viewControllers.last!)
            } else {
                return vc
            }
        } else if vc.isKind(of: UINavigationController.self) {
            let svc = vc as! UINavigationController
            if svc.viewControllers.count > 0 {
                return UIViewController.findBest(vc: svc.topViewController!)
            } else {
                return vc
            }
        } else if vc.isKind(of: UITabBarController.self) {
            let svc = vc as! UITabBarController
            if (svc.viewControllers?.count ?? 0) > 0 {
                return UIViewController.findBest(vc: svc.selectedViewController ?? UIViewController())
            } else {
                return vc
            }
        } else {
            return vc
        }
    }
}
