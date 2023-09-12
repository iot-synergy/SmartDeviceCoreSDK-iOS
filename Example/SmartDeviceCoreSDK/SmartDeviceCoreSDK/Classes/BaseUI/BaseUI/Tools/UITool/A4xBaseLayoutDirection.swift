//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK

public class A4xBaseLayoutDirection {
    public static func setDirectionConfig() {
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            UISearchBar.appearance().semanticContentAttribute = .forceRightToLeft
            UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
            UIScrollView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            UISearchBar.appearance().semanticContentAttribute = .forceLeftToRight
            UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
            UIScrollView.appearance().semanticContentAttribute = .forceLeftToRight
        }
    }
    
    
    public static func hookUIAlignment() {
        UILabel.setRtlDirection()
        UIButton.setRtlDirection()
        UITextField.setRtlDirection()
        UITextView.setRtlDirection()
    }
    
    public static func needChangeDirection() -> Bool {
        
        
        
        if (UIView.appearance().semanticContentAttribute != .forceRightToLeft) && (A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab) {
            return true
        }
        
        if (UIView.appearance().semanticContentAttribute == .forceRightToLeft) && (A4xBaseAppLanguageType.language() != .hebrew && A4xBaseAppLanguageType.language() != .arab) {
            return true
        }
        return false
    }
}
