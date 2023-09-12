//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

enum A4xBindEditLocationType  {
    case front_door
    case livingroom
    case back_door
    case garden
    case office
    case garage 

    var rawValue : String {
        switch self {
        case .front_door:
            return A4xBaseManager.shared.getLocalString(key: "front_door")
        case .livingroom:
            return A4xBaseManager.shared.getLocalString(key: "livingroom")
        case .back_door:
            return A4xBaseManager.shared.getLocalString(key: "back_door")
        case .garden:
            return A4xBaseManager.shared.getLocalString(key: "garden")
        case .office:
            return A4xBaseManager.shared.getLocalString(key: "office")
        case .garage:
            return A4xBaseManager.shared.getLocalString(key: "garage")
        }
    }

    var image : UIImage? {
        switch self {
        case .front_door:
            return bundleImageFromImageName("location_front_door")?.rtlImage()
        case .livingroom:
            return bundleImageFromImageName("location_livingroom")?.rtlImage()
        case .back_door:
            return bundleImageFromImageName("location_back_door")?.rtlImage()
        case .garden:
            return bundleImageFromImageName("location_garden")?.rtlImage()
        case .office:
            return bundleImageFromImageName("location_office")?.rtlImage()
        case .garage:
            return bundleImageFromImageName("location_office")?.rtlImage()
        }
    }

    static func allCases(filter modles: [A4xDeviceLocationModel]? = nil) -> [A4xBindEditLocationType] {
        var results = [front_door, livingroom, back_door, garden, office, .garage]
        guard let filter = modles else {
            return results
        }

        results.removeAll { (type) -> Bool in
            for address in filter {
                if let name = address.name, name == type.rawValue {
                    return true
                }
            }
            return false
        }
        return results
    }
}
