//


//

//

import Foundation
import Lottie
import SmartDeviceCoreSDK
import BaseUI

public struct A4xRGBA32: Equatable {
    private var color: UInt32

    var redComponent: UInt8 {
        return UInt8((color >> 24) & 255)
    }

    var greenComponent: UInt8 {
        return UInt8((color >> 16) & 255)
    }

    var blueComponent: UInt8 {
        return UInt8((color >> 8) & 255)
    }

    var alphaComponent: UInt8 {
        return UInt8((color >> 0) & 255)
    }

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let red   = UInt32(red)
        let green = UInt32(green)
        let blue  = UInt32(blue)
        let alpha = UInt32(alpha)
        color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
    }

    static let red     = A4xRGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
    static let green   = A4xRGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
    static let blue    = A4xRGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
    static let white   = A4xRGBA32(red: 255, green: 255, blue: 255, alpha: 255)
    static let black   = A4xRGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
    static let magenta = A4xRGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
    static let yellow  = A4xRGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
    static let cyan    = A4xRGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
    static let theme   = A4xBindConfig.getA4xRGBA32()

    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    public static func ==(lhs: A4xRGBA32, rhs: A4xRGBA32) -> Bool {
        return lhs.color == rhs.color
    }
}

@objc open class A4xBindConfig : NSObject {
    
    /**
     * Application's App Key found on BindUIkit Server's "Management > Applications" section.
     * @discussion Using API Key or App ID will not work.
     * @discussion App key needs to be a non-zero length string, otherwise an exception is thrown.
     */
    @objc open var a4xBindJumpVCName: String = ""
    
    /**
     * For specifying which features BindUIkit will start with.
     * @discussion Available features for each platform:
     */
    @objc open var features: [String : String] = [:]
    
    public static func getLottieColorValueProvider() -> ColorValueProvider {
        let cmp = ADTheme.Theme.cgColor.components
        let red = cmp?[0];
        let green = cmp?[1];
        let blue = cmp?[2];
        let colorValueProvider = ColorValueProvider(LottieColor(r: red ?? 0.0, g: green ?? 0.0, b: blue ?? 0.0, a: 1))
        return colorValueProvider
    }
    
    public static func getA4xRGBA32() -> A4xRGBA32 {
        let cmp   = ADTheme.Theme.cgColor.components
        let red   = UInt8((cmp?[0] ?? 0.0) * 255)
        let green = UInt8((cmp?[1] ?? 0.0) * 255)
        let blue  = UInt8((cmp?[2] ?? 0.0) * 255)
        let rgba32 = A4xRGBA32(red: red, green: green, blue: blue, alpha: 255)
        return rgba32
    }
    
}
