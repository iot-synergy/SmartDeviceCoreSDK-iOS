//



import Foundation
import SmartDeviceCoreSDK

extension A4xVideoCellStyle {
    public func image() -> UIImage? {
        switch self {
        case .default:
            return bundleImageFromImageName("homepage_head_menus")?.rtlImage()
        case .split:
            return bundleImageFromImageName("homepage_head_menus")?.rtlImage()
        @unknown default:
            return bundleImageFromImageName("homepage_head_menus")?.rtlImage()
        }
    }
}
