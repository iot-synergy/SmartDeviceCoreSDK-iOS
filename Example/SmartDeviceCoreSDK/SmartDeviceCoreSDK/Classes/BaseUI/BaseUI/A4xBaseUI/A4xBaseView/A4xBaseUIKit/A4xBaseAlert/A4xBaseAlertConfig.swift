//


//


//

import Foundation
import UIKit

public enum A4xBaseAlertType {
    case alert(_ animailType : A4xBaseAlertAnimailType)
    case sheet
}

public enum A4xBaseAlertAnimailType {
    case top
    case bottom
    case scale
}

public enum A4xBaseAlertBottomAligment {
    case horizontal
    case vertical
}

public struct A4xBaseAlertConfig {
    
    public init(type: A4xBaseAlertType = .alert(.scale), initialSpringVelocity: Float = 0.5, damping: Float = 0.8, duration: Float = 0.3, outBoundsHidden: Bool = false, backgroundAlpha: Float = 0.4, isCancelHidden: Bool = false) {
        self.type = type
        self.initialSpringVelocity = initialSpringVelocity
        self.damping = damping
        self.duration = duration
        self.outBoundsHidden = outBoundsHidden
        self.backgroundAlpha = backgroundAlpha
        self.isCancelHidden = isCancelHidden
    }
    
    public var type: A4xBaseAlertType = .alert(.scale)
    
    
    public var initialSpringVelocity: Float          = 0.5 {
        didSet {
            if self.initialSpringVelocity <= 0 {
                self.initialSpringVelocity = 0.1
            }else if self.initialSpringVelocity >= 1 {
                self.initialSpringVelocity = 1
            }
        }
    }
    
    
    public var damping: Float                        = 0.8 {
        didSet{
            if self.damping <= 0{
                self.damping = 0.1
            }else if self.damping >= 1 {
                self.damping = 1
            }
        }
    }
    
    
    public var duration:Float                       = 0.3
    
    
    public var outBoundsHidden : Bool               = false
    
    
    public var isCancelHidden: Bool                 = false
    
    
    public var backgroundAlpha: Float               = 0.4
    
    public init(){
    }
}

public struct A4xBaseAlertAnimailConfig {
    public var bottomAlignment : A4xBaseAlertBottomAligment  = A4xBaseAlertBottomAligment.horizontal
    
    
    public var padding: Float                       = 8

    public var innerPadding: Float                  = 15
    
    
    public var cornerRadius: Float                  = 8
    
    
    public var buttonHeight: Float                  = 47.auto()
    
    
    public var buttonSectionExtraGap: Float         = 16

    
    public var topSectionExtraGap: Float            = 20
    
    
    public var alertWidth: Float                    = 255.auto()
    
    public var messageLinespace                     = 4
    public var messageAlignment: NSTextAlignment    = .center
    public var titleAlignment: NSTextAlignment      = .center
    
    
    public var messageImg: UIImage?
    
    
    public var alertTitleFont: UIFont               = ADTheme.H3
    public var messageFont: UIFont                  = ADTheme.B1
    public var buttonFont: UIFont                   = ADTheme.B0
    
    public var remindAgainSaveKey: String?
    
    
    public var rightbtnBgColor: UIColor             = ADTheme.Theme //UIColor(red: 86.0/255.0, green:199.0/255.0 , blue:225.0/255.0, alpha:1.0)
    public var leftbtnBgColor: UIColor              = UIColor(red: 229.0/255.0 , green: 229.0/255.0 , blue: 229.0/255.0, alpha:1.0)
    public var titleColor: UIColor                  = UIColor.black
    public var messageColor: UIColor                = UIColor(red:0.4, green:0.4, blue:0.4, alpha:1.0)
    public var leftTitleColor: UIColor              = UIColor(red: 0.2 , green: 0.2 , blue: 0.2, alpha:1.0)
    public var rightTextColor: UIColor              = UIColor.white
    public var textFieldBackgroundColor: UIColor    = UIColor.white
    public var buttonBorderColor: UIColor           = ADTheme.C6

    public init(){
        
    }
}
