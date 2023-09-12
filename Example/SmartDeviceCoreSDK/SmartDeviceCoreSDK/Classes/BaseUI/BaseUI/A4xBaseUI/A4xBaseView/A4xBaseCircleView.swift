
import UIKit

open class A4xBaseCircleView : UIView {
    public var radio : Float = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    public var bgColor : UIColor? = UIColor.clear {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    public var radioType : UIRectCorner = .allCorners
    
    

    public override var backgroundColor: UIColor? {
        didSet {}
    }
    
    override public init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setValue(UIColor.clear, forKey: "backgroundColor")
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.radio == 0 {
            super.backgroundColor = bgColor
            return
        }
        
        let ctx = UIGraphicsGetCurrentContext()
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: self.radioType, cornerRadii: CGSize(width: CGFloat(self.radio), height: CGFloat(self.radio))).cgPath

        
        ctx?.addPath(path)
        ctx?.closePath()
        ctx?.setFillColor(bgColor?.cgColor ?? UIColor.clear.cgColor)
        ctx?.drawPath(using: .fill)
    }
}

