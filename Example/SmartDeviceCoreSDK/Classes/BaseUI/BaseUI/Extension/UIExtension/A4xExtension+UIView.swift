//


//


//
import UIKit
import Foundation
import SmartDeviceCoreSDK

public class A4xGradientLayer: CAGradientLayer {}

fileprivate var GradientColorKey: String = "gradientColorKey"

public var pointEnableKey : String = "pointEnable"
public var rectPointsKey : String = "rectPoints"
public var rectPointsBlockKey : String = "rectPointsBlock"

extension UIView { 
    
  
    public func filletedCorner(_ cornerRadii: CGSize, _ roundingCorners: UIRectCorner)  {
        //print("-------------> filletedCorner:" + bounds.width.description + " height:" + bounds.height.description)
        let fieldPath = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii:cornerRadii )
        let fieldLayer = CAShapeLayer()
        fieldLayer.frame = bounds
        fieldLayer.path = fieldPath.cgPath
        self.layer.mask = fieldLayer
    }
    
    private static var getAllsubviews: [UIView] = []
    
    private func viewArray(root: UIView) -> [UIView] {
        for view in root.subviews {
            if view.isKind(of: UIView.self) {
                UIView.getAllsubviews.append(view)
            }
            _ = viewArray(root: view)
        }
        return UIView.getAllsubviews
    }
    
    
    public func getSubView(name: String) -> [UIView] {
        let viewArr = viewArray(root: self)
        UIView.getAllsubviews = []
        return viewArr.filter {$0.className == name}
    }
    
    
    public func getAllSubViews() -> [UIView] {
        UIView.getAllsubviews = []
        return viewArray(root: self)
    }
    
    
    public func getSubViewByTag(tag: Int) -> [UIView] {
        let viewArr = viewArray(root: self)
        UIView.getAllsubviews = []
        return viewArr.filter {$0.tag == tag}
    }
    
    
    public func getFrontSubView() -> UIView {
        let viewArr = viewArray(root: self)
        UIView.getAllsubviews = []
        return viewArr[0]
    }
    
    
    public func removeAllSubViews(group: DispatchGroup) {
        let subLeftViews = self.getAllSubViews()
        if subLeftViews.count > 0 {
            for i in 0..<subLeftViews.count {
                subLeftViews[i].removeFromSuperview()
                if i == subLeftViews.count - 1 {
                    group.leave()
                }
            }
        }
    }
    
    //将当前视图转为UIImage
    public func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    public func getImageFromView() -> UIImage {
        
        //第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。
        //第三个参数就是屏幕密度了
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        self.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    
    
    public func gradientColor(_ startPoint: CGPoint, _ endPoint: CGPoint, _ colors: [Any]) {
        
        guard startPoint.x >= 0, startPoint.x <= 1, startPoint.y >= 0, startPoint.y <= 1, endPoint.x >= 0, endPoint.x <= 1, endPoint.y >= 0, endPoint.y <= 1 else {
            return
        }
        
        
        layoutIfNeeded()
        
        var gradientLayer: CAGradientLayer!
        
        localRemoveGradientLayer()
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.layer.bounds
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = self.layer.cornerRadius
        gradientLayer.masksToBounds = true
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.backgroundColor = UIColor.clear
        
        self.layer.masksToBounds = false
    }
    
    
    
    public func localRemoveGradientLayer() {
        if let sl = self.layer.sublayers {
            for layer in sl {
                if layer.isKind(of: CAGradientLayer.self) {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
    
    public func addOnClickListener(target: AnyObject, action: Selector) {
        let gr = UITapGestureRecognizer(target: target, action: action)
        gr.numberOfTapsRequired = 1
        isUserInteractionEnabled = true
        addGestureRecognizer(gr)
    }
    
    public var gradientBackground: A4xBaseGradColor? {
        set {
            objc_setAssociatedObject(self, &GradientColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            gradientColor(gradientColor: newValue)
        }
        
        get {
            guard let gcolor : A4xBaseGradColor = objc_getAssociatedObject(self, &GradientColorKey) as? A4xBaseGradColor else {
                return nil
            }
            return gcolor
        }
    }
    
    public func gradientColor(gradientColor: A4xBaseGradColor?) {
        guard let gradColor = gradientColor else {
            self.removeGradientLayer()
            return
        }
        
        guard gradColor.isVaild() else {
            self.removeGradientLayer()
            return
        }
        
        var layer = self.loadGradientLayer()
        if layer == nil {
            layer = createGradientLayer()
        }
        layer?.backgroundColor = UIColor.gray.cgColor
        layer?.colors       = gradColor.colors
        layer?.locations    = gradColor.locations.sorted() as [NSNumber]
        layer?.startPoint   = CGPoint(x: CGFloat(gradColor.beginPostion.xRatio), y: CGFloat(gradColor.beginPostion.yRatio))
        layer?.endPoint     = CGPoint(x: CGFloat(gradColor.endPostion.xRatio), y: CGFloat(gradColor.endPostion.yRatio))
    }
    
    @objc open func my_layoutSubviews() {
        
        self.my_layoutSubviews()
        self.loadGradientLayer()?.frame = self.bounds
    }
    
    private func createGradientLayer() -> A4xGradientLayer {
        let currentGradient = A4xGradientLayer()
        self.layer.insertSublayer(currentGradient, at: 0)
        swizzledLayout()
        return currentGradient
    }
    
    private func removeGradientLayer() {
        for layer in self.layer.sublayers ?? [] {
            if layer is A4xGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    private func loadGradientLayer() -> A4xGradientLayer? {
        var currentGradient: A4xGradientLayer?
        for layer in self.layer.sublayers ?? [] {
            if layer is A4xGradientLayer {
                currentGradient = layer as? A4xGradientLayer
                break
            }
        }
        return currentGradient
    }
    
    private func swizzledLayout() {
        let originalSelector = #selector(layoutSubviews)
        let swizzledSelector = #selector(my_layoutSubviews)
        
        let swizzledMethod = class_getInstanceMethod(object_getClass(self) , swizzledSelector)
        let originalMethod = class_getInstanceMethod(object_getClass(self) , originalSelector)
        
        //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
        let didAddMethod: Bool = class_addMethod(object_getClass(self), originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(object_getClass(self), swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    
    public func addCorner(conrners: UIRectCorner , radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: conrners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    
    public func addBorder(borderColor: UIColor, borderWidth: CGFloat) {
        let layer = self.layer
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
    
    public func resetFrameToFitRTL() {
        self.setRtlFrame(frame: frame)
    }
    
    public func setRtlFrame(frame: CGRect) {
        self.rtl_setFrame(frame: frame, width: self.superview?.frame.size.width ?? 320)
    }
    
    public func rtl_setFrame(frame: CGRect, width: CGFloat) {
        
        var frameTemp = frame
        
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            
            if self.superview == nil { return }
            
            let x = CGFloat(width) - frameTemp.origin.x - frameTemp.size.width
            frameTemp.origin.x = x
        }
        
        self.frame = frameTemp
        
    }
        
    private func gimp_transform_polygon_is_convex(points : [CGPoint]) ->Bool
    {
        guard points.count == 4 else {
            return false
        }
        let  t1, t2, t3, t4: CGFloat
        t1 = (points[3].x-points[0].x)*(points[1].y-points[0].y)-(points[3].y-points[0].y)*(points[1].x-points[0].x)
        t2 = (points[0].x-points[1].x)*(points[2].y-points[1].y)-(points[0].y-points[1].y)*(points[2].x-points[1].x)
        t3 = (points[1].x-points[2].x)*(points[3].y-points[2].y)-(points[1].y-points[2].y)*(points[3].x-points[2].x)
        t4 = (points[2].x-points[3].x)*(points[0].y-points[3].y)-(points[2].y-points[3].y)*(points[0].x-points[3].x)

        if t1*t2*t3*t4 > 0 {
            return true
        }
        return false
    }
    
}

private let debugAccessibilityEnabled = true

private func isExcluded(_ kind: AnyClass) -> Bool {
    let name = String(describing: kind)
    return (name.count > 2 && name.prefix(2) == "UI") ||
        (name.count > 3 && name.prefix(3) == "_UI")
}

extension UIControl {














}

extension UIView {














//














}

extension UIView {





//










}

extension UIViewController {



}


extension UIScrollView {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesMoved(touches, with: event)
        super.touchesMoved(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesCancelled(touches, with: event)
        super.touchesCancelled(touches, with: event)
    }
}


