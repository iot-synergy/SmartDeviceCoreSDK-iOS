//



import Foundation
import Lottie
import CoreText

public class A4xBaseResource {
    
    public static func UIImage(named: String) -> UIImage? {
        return bundleImageFromImageName(named, for: A4xBaseResource.self)
    }

    
    public static func Animation(named: String) -> LottieAnimation? {
        return LottieAnimation.named(named, bundle: a4xBaseBundle())
    }
    
    public static func UIFont(name: String, ofType: String, size: CGFloat) -> UIFont? {
        
        guard let fontPath = a4xBaseBundle().path(forResource: name, ofType: ofType), let fontData = NSData(contentsOfFile: fontPath) else {
            
            return nil
        }
        guard let provider = CGDataProvider(data: fontData) else {
            
            return nil
        }
        guard let font = CGFont(provider) else {
            
            return nil
        }
        
        CTFontManagerRegisterGraphicsFont(font, nil)
        let fontName = font.postScriptName as String?
        return UIKit.UIFont(name: fontName ?? "", size: size)
         
    }

}
