//


//

//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xDeviceSettingResource {
    
    static func UIImage(named: String) -> UIImage? {
        return bundleImageFromImageName(named, for: A4xDeviceSettingResource.self)
    }

}
