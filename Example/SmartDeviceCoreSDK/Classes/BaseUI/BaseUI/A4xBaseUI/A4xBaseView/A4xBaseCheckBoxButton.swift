//


//


//

import UIKit

public enum A4xBaseCheckBoxState {
    case normail
    case selected
    case error
    
    public func negate() -> A4xBaseCheckBoxState {
        if self == .normail {
            return .selected
        }else if self == .selected {
            return .normail
        }else if self == .error {
            return .selected
        }
        return .normail
    }
}

public class A4xBaseCheckBoxButton: UIButton {
    var expandSizeKey = "expandSizeKey"
    public var boxState: A4xBaseCheckBoxState {
        didSet {
            updateState()
        }
    }

    public var images: Dictionary<A4xBaseCheckBoxState, UIImage> = Dictionary()
    
    override public var isSelected: Bool {
        didSet {
            self.boxState = isSelected ? .selected : .normail
        }
    }
    
    open func addx_expandSize(size: CGFloat) {
        objc_setAssociatedObject(self, &expandSizeKey, size, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
    }
    
    private func expandRect() -> CGRect {
        let expandSize = objc_getAssociatedObject(self, &expandSizeKey)
        if (expandSize != nil) {
            return CGRect(x: bounds.origin.x - (expandSize as! CGFloat), y: bounds.origin.y - (expandSize as! CGFloat), width: bounds.size.width + 2 * (expandSize as! CGFloat), height: bounds.size.height + 2 * (expandSize as! CGFloat))
        } else {
            return bounds
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let buttonRect = expandRect()
        if (buttonRect.equalTo(bounds)) {
            return super.point(inside: point, with: event)
        } else {
            return buttonRect.contains(point)
        }
    }
    
    public init(frame: CGRect = .zero, state: A4xBaseCheckBoxState = .normail) {
        boxState = state
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateState() {
        self.setImage(images[boxState], for: UIControl.State.normal)
        self.setImage(images[boxState], for: UIControl.State.highlighted)
    }
    
    public func setImage(image : UIImage? , state : A4xBaseCheckBoxState) {
        images[state] = image
        
        if state == .normail {
            self.setImage(image, for: UIControl.State.normal)
        }else if state == .selected {
            self.setImage(image, for: UIControl.State.selected)
        }
    }
}
