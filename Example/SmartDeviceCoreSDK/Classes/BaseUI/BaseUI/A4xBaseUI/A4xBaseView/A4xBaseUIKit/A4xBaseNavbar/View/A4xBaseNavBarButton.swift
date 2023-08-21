//


//


//

import UIKit
import SmartDeviceCoreSDK

public class A4xBaseNavBarButton : UIButton {
    public var navItem : A4xBaseNavItem? {
        didSet {
            updateItem()
        }
    }
    
    private func updateItem(){
        if navItem?.normalImg != nil {
            self.setImage(bundleImageFromImageName(navItem!.normalImg!)?.rtlImage(), for: UIControl.State.normal)
        } else {
            self.setImage(nil, for: UIControl.State.normal)
        }
        
        if navItem?.selectedImg != nil {
            self.setImage(bundleImageFromImageName(navItem!.selectedImg!)?.rtlImage(), for: UIControl.State.selected)
        }else {
            self.setImage(nil, for: UIControl.State.selected)
        }
        
        if navItem?.highlightedImg != nil {
            self.setImage(bundleImageFromImageName(navItem!.selectedImg!)?.rtlImage(), for: UIControl.State.selected)
        }else {
            self.setImage(nil, for: UIControl.State.highlighted)
        }
        
        if let title = navItem?.title {
            self.setTitle(title, for: UIControl.State.normal)
        }else {
            self.setTitle("", for: UIControl.State.normal)
        }
        
        if  let font = navItem?.font {
            self.titleLabel?.font = font
        }
        
        if let title = navItem?.selectedTitle {
            self.setTitle(title, for: UIControl.State.selected)
        }else {
            self.setTitle(navItem?.title, for: UIControl.State.selected)
        }
        
        if let color = navItem?.titleColor {
            self.setTitleColor(color, for: UIControl.State.normal)
        }
        
        if let color = navItem?.selectedTitleColor {
            self.setTitleColor(color, for: UIControl.State.selected)
        }
        
        if let color = navItem?.disableColor {
            self.setTitleColor(color, for: UIControl.State.disabled)
        }
        
        if let color = navItem?.highlightedTitleColor {
            self.setTitleColor(color, for: UIControl.State.highlighted)
        }
        
        if let bgc = navItem?.backgroundColor {
            self.backgroundColor = bgc
        }

        if let al = navItem?.textAligment {
            self.titleLabel?.textAlignment = al
        }
        
        if let width = navItem?.width {
            self.width = width
        }
    }
}
