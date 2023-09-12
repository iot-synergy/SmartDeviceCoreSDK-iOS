//


//


//

import Foundation
import SmartDeviceCoreSDK

public enum LayoutStyle: Int {
    case imageTop
    case imageLeft
    case imageBottom
    case imageRight
    case imageRightNew
}

public typealias ActionBlock = ((UIButton)->Void)

public extension UIButton {
    
    private struct AssociatedKeys {
        static var ActionBlock = "ActionBlock"
        static var ActionDelay = "ActionDelay"
    }
    
    /*图文混排
     /style: 类型
     space: 间距
     eg: btn.layoutButton(.imageLeft, space: 8)
     */
    func layoutButton(_ style: LayoutStyle, space: CGFloat) {
        
        guard let titleL = self.titleLabel, let imageV = self.imageView else {
            return
        }
        
        let imageWidth = imageV.frame.size.width
        let imageHeight = imageV.frame.size.height
        
        let labelWidth = titleL.frame.size.width
        let labelHeight = titleL.frame.size.height
        
        let imageX = imageV.frame.origin.x
        let labelX = titleL.frame.origin.x
        
        let margin = labelX - imageX - imageWidth
        
        var imageInsets = UIEdgeInsets.zero
        var labelInsets = UIEdgeInsets.zero
        
        /**
         *  titleEdgeInsets是title相对于其上下左右的inset
         *  如果只有title，那它上下左右都是相对于button的，image也是一样；
         *  如果同时有image和label，那这时候image的上左下是相对于button，右边是相对于label的；title的上右下是相对于button，左边是相对于image的。
         */
        switch style {
        case .imageTop:
            //labelInsets = UIEdgeInsets(top: 0.5 * (imageHeight + space), left: -(imageWidth - 5), bottom: -0.5 * imageHeight, right: 5)
            //imageInsets = UIEdgeInsets(top: -0.5 * labelHeight, left: 0.5 * labelWidth + 0.5 * margin + imageX, bottom: 0.5 * (labelHeight + space), right: 0.5 * (labelWidth - margin))
            
            labelInsets = UIEdgeInsets(top: imageHeight, left: -(imageWidth), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: -(labelHeight), left: 0, bottom: 0, right: -(labelWidth))
            
        case .imageBottom:
            imageInsets = UIEdgeInsets(top: 0.5 * (labelHeight + space), left: 0.5 * labelWidth + imageX, bottom: -0.5 * labelHeight, right: 0.5 * labelWidth)
            labelInsets = UIEdgeInsets(top: -0.5 * imageHeight, left: -(imageWidth - 5), bottom:0.5 * (imageHeight + space), right: 5)
            
        case .imageRight:
            imageInsets = UIEdgeInsets(top: 0, left: 0.5 * (labelWidth + space), bottom: 0, right: -(labelWidth + 0.5 * space))
            labelInsets = UIEdgeInsets(top: 0, left: -(imageWidth + 0.5 * space), bottom: 0, right: imageWidth + space * 0.5)
            
        case .imageRightNew:
            imageInsets = UIEdgeInsets(top: 0, left: labelWidth + 0.5 * space, bottom: 0, right: 0)
            labelInsets = UIEdgeInsets(top: 0, left: -space, bottom: 0, right: 0)
            
        default:
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0.5 * space)
            labelInsets = UIEdgeInsets(top: 0, left: 0.5 * space, bottom: 0, right: 0)
        }
        
        self.titleEdgeInsets = labelInsets
        self.imageEdgeInsets = imageInsets
    }
    
    
    private var actionBlock: ActionBlock? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ActionBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ActionBlock) as? ActionBlock
        }
    }
    
    private var actionDelay: TimeInterval {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.ActionDelay, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ActionDelay) as? TimeInterval ?? 0
        }
    }
    
    
    /** 部分圆角
     * - corners: 需要实现为圆角的角，可传入多个
     * - radii: 圆角半径
     */
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    
    @objc private func btnDelayClick(_ button: UIButton) {
        actionBlock?(button)
        self.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + actionDelay) { [weak self] in
            
            self?.isEnabled = true
        }
    }
    
    
    func addAction(_ delay: TimeInterval = 0, action: @escaping ActionBlock) {
        addTarget(self, action: #selector(btnDelayClick(_:)) , for: .touchUpInside)
        actionDelay = delay
        actionBlock = action
    }
}

extension UIButton { 
    
    public class func setRtlDirection() {
        self.rtl_MethodSwizzling(fromMethod: #selector(setter: UIButton.contentEdgeInsets), toMethod: #selector(rtl_ContentEdgeInsets(contentEdgeInsets:)))
        self.rtl_MethodSwizzling(fromMethod: #selector(setter: UIButton.titleEdgeInsets), toMethod: #selector(rtl_TitleEdgeInsets(titleEdgeInsets:)))
        self.rtl_MethodSwizzling(fromMethod: #selector(setter: UIButton.imageEdgeInsets), toMethod: #selector(rtl_ImageEdgeInsets(imageEdgeInsets:)))
        self.rtl_MethodSwizzling(fromMethod: #selector(setter: UIButton.contentHorizontalAlignment), toMethod: #selector(rtl_ContentHorizontalAlignment(alignment:)))
        
    }
    
    class func rtl_MethodSwizzling(fromMethod: Selector, toMethod: Selector) {
        guard let method1 = class_getInstanceMethod(self, fromMethod) else { return }
        guard let method2 = class_getInstanceMethod(self, toMethod) else { return }
        method_exchangeImplementations(method1, method2)
    }
    
    @objc func rtl_ContentEdgeInsets(contentEdgeInsets: UIEdgeInsets) {
        let edgeInsets = contentEdgeInsets
        self.rtl_ContentEdgeInsets(contentEdgeInsets: self.rtl_EdgeInsetsWithInsets(UIEdgeInsets: edgeInsets))
        
    }
    
    @objc func rtl_TitleEdgeInsets(titleEdgeInsets: UIEdgeInsets) {
        let edgeInsets = titleEdgeInsets
        self.rtl_TitleEdgeInsets(titleEdgeInsets: self.rtl_EdgeInsetsWithInsets(UIEdgeInsets: edgeInsets))
    }
    
    @objc func rtl_ImageEdgeInsets(imageEdgeInsets: UIEdgeInsets) {
        let edgeInsets = imageEdgeInsets
        self.rtl_ImageEdgeInsets(imageEdgeInsets: self.rtl_EdgeInsetsWithInsets(UIEdgeInsets: edgeInsets))
    }
    
    @objc func rtl_ContentHorizontalAlignment(alignment: UIControl.ContentHorizontalAlignment) {
        var needAlignment = alignment
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            if needAlignment == .left {
                needAlignment = .right
            } else if needAlignment == .right {
                needAlignment = .left
            }
        }
        self.rtl_ContentHorizontalAlignment(alignment: needAlignment)
    }
    
    func rtl_EdgeInsetsWithInsets(UIEdgeInsets insets: UIEdgeInsets) -> UIEdgeInsets {
        var needInsets = insets
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            if (needInsets.left != needInsets.right) {
                let temp = needInsets.left
                needInsets.left = needInsets.right
                needInsets.right = temp
            }
        }
        return needInsets
    }
}
