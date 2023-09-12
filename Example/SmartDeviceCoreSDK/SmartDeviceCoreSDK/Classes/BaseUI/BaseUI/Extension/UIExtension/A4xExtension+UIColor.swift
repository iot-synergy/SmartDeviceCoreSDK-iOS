//


//

//


import Foundation
import UIKit

public extension UIColor {
    
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var r, g, b, a: CGFloat
        a = alpha

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            } else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }

        return nil
    }
    
    static func colorFromHex(_ hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        var r, g, b, a: CGFloat
        a = alpha
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x000000ff) / 255
                    return self.init(red: r, green: g, blue: b, alpha: a)
                }
            } else if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x000000ff) / 255

                    return self.init(red: r, green: g, blue: b, alpha: a)
                }
            }
        }

        return UIColor.hex(hex: 111111, alpha: a)
    }
    
    
    
    
    class func hex(hex: Int) -> UIColor {
        return UIColor.hex(hex: hex, alpha: 1.0)
    }
    
    class func hex(hex: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat((hex >> 16) & 0xFF)/255.0, green: CGFloat((hex >> 8) & 0xFF)/255.0, blue: CGFloat(hex & 0xFF)/255.0, alpha: alpha)
    }
    ///
    /*
    class func hex(hex: String) -> UIColor {
        var alpha, red, blue, green: CGFloat
        let colorString = hex.replacingOccurrences(of: "#", with: "")
        switch colorString.count {
        case 3: 
            alpha = 1.0
            red = colorComponent(hex: colorString, start: 0, length: 1)
            green = colorComponent(hex: colorString, start: 1, length: 1)
            blue = colorComponent(hex: colorString, start: 2, length: 1)
        case 4: 
            alpha = colorComponent(hex: colorString, start: 0, length: 1)
            red = colorComponent(hex: colorString, start: 1, length: 1)
            green = colorComponent(hex: colorString, start: 2, length: 1)
            blue = colorComponent(hex: colorString, start: 3, length: 1)
        case 6: 
            alpha = 1.0
            red = colorComponent(hex: colorString, start: 0, length: 2)
            green = colorComponent(hex: colorString, start: 2, length: 2)
            blue = colorComponent(hex: colorString, start: 4, length: 2)
        case 8: 
            alpha = colorComponent(hex: colorString, start: 0, length: 2)
            red = colorComponent(hex: colorString, start: 2, length: 2)
            green = colorComponent(hex: colorString, start: 4, length: 2)
            blue = colorComponent(hex: colorString, start: 6, length: 2)
        default:
            alpha =  0
            red = 0
            green = 0
            blue = 0
        }
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }*/
    private class func colorComponent(hex: String, start: Int, length: Int) -> CGFloat {
        let subString = hex.sliceString(start..<(start + length))
        let fullHex = length == 2 ? subString : (subString + subString)
        var val: CUnsignedInt = 0
        Scanner(string: fullHex).scanHexInt32(&val)
        return CGFloat(val) / 255.0
    }
    
    var hex: String {
        var color = self
        if color.cgColor.numberOfComponents < 4 {
            let components = color.cgColor.components
            
            color = UIColor(red: components![0], green: components![0], blue: components![0], alpha: components![1])
        }
        if color.cgColor.colorSpace?.model != CGColorSpaceModel.rgb {
            return "#FFFFFF"
        }
        return String(format: "#%02X%02X%02X", Int(color.cgColor.components![0]*255.0), Int(color.cgColor.components![1]*255.0), Int(color.cgColor.components![2]*255.0))
    }
    
    
    class func rgba(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    class func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return rgba(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    var rgba: [Int] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [Int(red*255.0), Int(green*255.0), Int(blue*255.0), Int(alpha)]
    }
    
    class func randomColor() -> UIColor {
        let red = CGFloat(arc4random()%255)
        let green = CGFloat(arc4random()%255)
        let blue = CGFloat(arc4random()%255)
        let color = UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
        return color
    }
    
    
    
}
