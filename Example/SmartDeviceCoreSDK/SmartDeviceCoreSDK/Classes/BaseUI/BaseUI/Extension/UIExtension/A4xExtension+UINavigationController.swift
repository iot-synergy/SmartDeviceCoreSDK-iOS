//


//


//

import Foundation
import SmartDeviceCoreSDK

public extension UINavigationController {
    func popToViewController(type ViewControllerType : UIViewController.Type) {
        guard self.viewControllers.count > 0 else {
            return
        }
        
        var viewController : [UIViewController] = []
        
        for index in 0..<self.viewControllers.count {
            let vc = self.viewControllers[index]
            viewController.append(vc)
            if type(of: vc) == ViewControllerType {
                break
            }
            
        }
        
        self.viewControllers = viewController
    }
    
    func setDirectionConfig() {
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            self.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        } else {
            self.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
    }
}
