import UIKit
import SmartDeviceCoreSDK
import BaseUI

enum A4xUserSettingEnum {
    case language
    case location
    case joinDevice
    case logout

    var rawValue : String {
        switch self {

        case .language:
            return A4xBaseManager.shared.getLocalString(key: "language")
        case .location:
            return A4xBaseManager.shared.getLocalString(key: "location_management")
        case .joinDevice:
            return A4xBaseManager.shared.getLocalString(key: "join_friend_device")
        case .logout:
            return A4xBaseManager.shared.getLocalString(key: "logout")
        }
    }
    
    static func allCases() -> [[A4xUserSettingEnum]] {
        return [[.joinDevice ,.language , .location, .logout]]
    }
}
