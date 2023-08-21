//


//


//

import Foundation
import SmartDeviceCoreSDK

extension UITextField {
    public func setDirectionConfig() {
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            self.semanticContentAttribute = .forceRightToLeft
        } else {
            self.semanticContentAttribute = .forceLeftToRight
        }
    }
    
    public class func setRtlDirection() {
        self.rtl_MethodSwizzling(fromMethod: #selector(setter: UITextField.textAlignment), toMethod: #selector(rtl_setTextAlignment(textAlignment:)))
    }
    
    class func rtl_MethodSwizzling(fromMethod: Selector, toMethod: Selector) {
        guard let method1 = class_getInstanceMethod(self, fromMethod) else { return }
        guard let method2 = class_getInstanceMethod(self, toMethod) else { return }
        method_exchangeImplementations(method1, method2)
    }
    
    @objc func rtl_setTextAlignment(textAlignment: NSTextAlignment) {
        var alignment = textAlignment
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            if textAlignment == .natural || textAlignment == .left {
                alignment = .right
            } else if textAlignment == .right {
                alignment = .left
            }
        }
        self.rtl_setTextAlignment(textAlignment: alignment)
    }
}
