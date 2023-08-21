//


//


//

import Foundation
import UIKit

public struct A4xBaseNavItem  {
    
    public init(normalImg: String? = nil, highlightedImg: String? = nil, selectedImg: String? = nil, title: String? = nil, selectedTitle: String? = nil, titleColor: UIColor? = nil, disableColor: UIColor? = nil, selectedTitleColor: UIColor? = nil, highlightedTitleColor: UIColor? = nil, backgroundColor: UIColor? = nil, font: UIFont? = nil, textAligment: NSTextAlignment? = nil, width: CGFloat? = nil) {
        self.normalImg = normalImg
        self.highlightedImg = highlightedImg
        self.selectedImg = selectedImg
        self.title = title
        self.selectedTitle = selectedTitle
        self.titleColor = titleColor
        self.disableColor = disableColor
        self.selectedTitleColor = selectedTitleColor
        self.highlightedTitleColor = highlightedTitleColor
        self.backgroundColor = backgroundColor
        self.font = font
        self.textAligment = textAligment
        self.width = width
    }
    
    public var normalImg : String?
    public var highlightedImg : String?
    public var selectedImg : String?
    public var title : String?
    public var selectedTitle : String?
    public var titleColor : UIColor?
    public var disableColor : UIColor?
    public var selectedTitleColor : UIColor?
    public var highlightedTitleColor : UIColor?
    public var backgroundColor : UIColor?
    public var font : UIFont?
    public var textAligment : NSTextAlignment?
    public var width: CGFloat?
    
    init() {
        
    }
}
