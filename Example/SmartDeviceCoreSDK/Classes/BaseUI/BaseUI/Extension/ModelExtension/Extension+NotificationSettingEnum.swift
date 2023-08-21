//

import Foundation
import SmartDeviceCoreSDK

extension A4xNotificationSettingEnum {
    
    public var imgValue: UIImage? { 
        switch self {
        case .person:
            return bundleImageFromImageName("main_libary_people")?.rtlImage()
        case .cat:
            return bundleImageFromImageName("main_libary_pet")?.rtlImage()
        case .car:
            return bundleImageFromImageName("main_libary_vehicle")?.rtlImage()
        case .package:
            return bundleImageFromImageName("main_libary_package")?.rtlImage()
        case .bird:
            return bundleImageFromImageName("main_libary_bird")?.rtlImage()
        case .other:
            return bundleImageFromImageName("main_libary_other")?.rtlImage()
        }
    }
    
    public var imgValue_gray: UIImage? { 
        switch self {
        case .person:
            return bundleImageFromImageName("main_libary_people_gray")?.rtlImage()
        case .cat:
            return bundleImageFromImageName("main_libary_pet_gray")?.rtlImage()
        case .car:
            return bundleImageFromImageName("main_libary_vehicle_gray")?.rtlImage()
        case .package:
            return bundleImageFromImageName("main_libary_package_gray")?.rtlImage()
        case .bird:
            return bundleImageFromImageName("main_libary_bird_gray")?.rtlImage()
        case .other:
            return bundleImageFromImageName("main_libary_other_gray")?.rtlImage()
        }
    }
    
    public var smallImgValue: UIImage? { 
        switch self {
        case .person:
            return bundleImageFromImageName("main_libary_small_people")?.rtlImage()
        case .cat:
            return bundleImageFromImageName("main_libary_small_pet")?.rtlImage()
        case .car:
            return bundleImageFromImageName("main_libary_small_vehicle")?.rtlImage()
        case .package:
            return bundleImageFromImageName("main_libary_small_package")?.rtlImage()
        case .bird:
            return bundleImageFromImageName("main_libary_small_bird")?.rtlImage()
        case .other:
            return bundleImageFromImageName("main_libary_other_roundGrey")?.rtlImage()
        }
    }
}
