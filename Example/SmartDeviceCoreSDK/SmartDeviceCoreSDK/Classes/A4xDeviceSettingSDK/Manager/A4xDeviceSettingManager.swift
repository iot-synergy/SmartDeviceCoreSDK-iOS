//


//

//

import UIKit
import SmartDeviceCoreSDK

class A4xDeviceSettingManager: NSObject {

    
    @objc public static let shared = A4xDeviceSettingManager()
    
    public func deviceIsVip(deviceId: String) -> Bool
    {
        let device = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceId, modeType: .WiFi)
        let isVip = device?.deviceInVip ?? false
        return isVip
    }
    
}

