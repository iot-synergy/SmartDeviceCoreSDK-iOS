//


//


//

import Foundation
import UIKit

class A4xBaseToastBgView : UIView {
    var onTopClickBlock : (()->Void)?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let result = point.y > UIScreen.navBarHeight && point.x < UIScreen.navBarHeight
        if !result {
            onTopClickBlock?()
        }
        
        return result
    }
}
