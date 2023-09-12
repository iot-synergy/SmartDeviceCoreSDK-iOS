//


//


//

import Foundation
import SmartDeviceCoreSDK

public struct A4xDevicesInviteInfoModel {
    var cellHeight: CGFloat?
    var type: A4xDevicesInviteInfoEnum
    var title: String?
    
    public init(_ type: A4xDevicesInviteInfoEnum, _ title: String? = nil) {
        self.type = type
        self.title = title
    }
}

public enum A4xDevicesInviteInfoEnum {
    case qrcodeShow 
    case qrcodeGuide 
    
    static public func cases() -> [[A4xDevicesInviteInfoModel]] {
        var baseCases: [[A4xDevicesInviteInfoModel]] = Array()
        baseCases.append([A4xDevicesInviteInfoModel(.qrcodeShow, A4xBaseManager.shared.getLocalString(key: "crying_detection"))])
        var qrcodeGuideCase: [A4xDevicesInviteInfoModel] = Array()
        qrcodeGuideCase.append(A4xDevicesInviteInfoModel(.qrcodeGuide))
        baseCases.append(qrcodeGuideCase)
        return baseCases
    }
}
