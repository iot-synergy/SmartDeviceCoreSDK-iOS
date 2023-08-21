//


//


//

import UIKit
import AutoInch

public extension UIFont {
    static func medium(_ size : Float) -> UIFont {
        return UIFont.systemFont(ofSize: size.auto() , weight: .medium)
    }
    
    static func heavy(_ size : Float) -> UIFont {
        return UIFont.systemFont(ofSize: size.auto() , weight: .heavy)
    }
    
    static func regular(_ size : Float) -> UIFont {
        return UIFont.systemFont(ofSize: size.auto() , weight: .regular)
    }
}
