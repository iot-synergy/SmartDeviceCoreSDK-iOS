import Foundation
import UIKit
import SmartDeviceCoreSDK

public struct ADTheme {
    

    public static var APPName : String {
        return "SmartDeviceDemo"
    }
    

    public static let H0 : UIFont  = UIFont.medium(24)
    public static let H1 : UIFont  = UIFont.medium(22)
    public static let H2 : UIFont  = UIFont.medium(18)
    public static let H3 : UIFont  = UIFont.medium(16)
    public static let H4 : UIFont  = UIFont.medium(15)
    public static let H5 : UIFont  = UIFont.medium(14)
    
    public static let B0 : UIFont  = UIFont.regular(18)
    public static let B1 : UIFont  = UIFont.regular(15)
    public static let B2 : UIFont  = UIFont.regular(13)
    public static let B3 : UIFont  = UIFont.regular(11)
    public static let B4 : UIFont  = UIFont.regular(9)


    public static let C1           = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)  //hex color #333333
    public static let C2           = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)  //hex color #666666
    public static let C3           = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)  //hex color #999999 //rgba(153, 153, 153, 1)
    public static let C4           = #colorLiteral(red: 0.69803923, green: 0.69803923, blue: 0.69803923, alpha: 1)  //hex color #b2b2b2
    public static let C5           = #colorLiteral(red: 0.9137254902, green: 0.9215686275, blue: 0.9490196078, alpha: 1)  //hex color #E9EBF2
    public static let C6           = #colorLiteral(red: 0.9647058824, green: 0.968627451, blue: 0.9764705882, alpha: 1)  //hex color #F6F7F9
    public static let C7           = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)  //hex color #FFFFFF

    public static let E1           = #colorLiteral(red: 0.8901961, green: 0.27450982, blue: 0.27450982, alpha: 1)  //hex color #E34646
    
    public static var Theme : UIColor {
        return  #colorLiteral(red: 0.3450980392, green: 0.768627451, blue: 0.6549019608, alpha: 1)
    }
    
    
    
    public static var ThemeStr : String {
        return "#4BBA97"
    }
}
