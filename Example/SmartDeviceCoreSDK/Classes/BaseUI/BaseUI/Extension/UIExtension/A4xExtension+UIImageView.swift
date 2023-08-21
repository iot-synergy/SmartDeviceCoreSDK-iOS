//


//


//

import Foundation

extension UIImageView {
    
    public func changeImageWithColor(color: UIColor, image: UIImage) {
        let tempImg = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.tintColor = color
        self.image = tempImg
    }
    
    public func addActionHandler(_ action : @escaping ()->Void ) -> Void {
        let funcAbount = NSStringFromSelector(#function)
        let runtimeKey = RuntimeKeyFromParams(self, funcAbount: funcAbount)!
        self.isUserInteractionEnabled = true
        self.keyOfUnsafeRawPointer = runtimeKey
        objc_setAssociatedObject(self, runtimeKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let keypointer = self.keyOfUnsafeRawPointer else {
            return
        }
        let block = objc_getAssociatedObject(self, keypointer) as? ()->Void;
        if block != nil {
            block!();
        }
    }
}

public func RuntimeKeyFromParams(_ obj: NSObject!, funcAbount: String!) -> UnsafeRawPointer! {
    let unique = "\(obj.hashValue)," + funcAbount
    let key:UnsafeRawPointer = UnsafeRawPointer(bitPattern: unique.hashValue)!
    return key;
}
