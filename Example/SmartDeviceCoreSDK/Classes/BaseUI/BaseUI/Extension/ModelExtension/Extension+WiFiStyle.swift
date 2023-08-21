//




import Foundation
import SmartDeviceCoreSDK

extension A4xWiFiStyle {
    public var imgValue: UIImage? {
        switch self {
        case .none:
            return bundleImageFromImageName("device_wifi_state_none")?.rtlImage()
        case .weak:
            return bundleImageFromImageName("device_wifi_state_weak")?.rtlImage()
        case .normail:
            return bundleImageFromImageName("device_wifi_state_middle")?.rtlImage()
        case .strong:
            return bundleImageFromImageName("device_wifi_state_strong")?.rtlImage()
        case .offline:
            return bundleImageFromImageName("device_wifi_state_none")?.rtlImage()
        }
    }
    
    public var verticalImgValue: UIImage? {
        switch self {
        case .none:
            return bundleImageFromImageName("live_video_vertical_wifi_none")?.rtlImage()
        case .weak:
            return bundleImageFromImageName("live_video_vertical_wifi_week")?.rtlImage()
        case .normail:
            return bundleImageFromImageName("live_video_vertical_wifi_middle")?.rtlImage()
        case .strong:
            return bundleImageFromImageName("live_video_vertical_wifi_strong")?.rtlImage()
        case .offline:
            return bundleImageFromImageName("live_video_vertical_wifi_none")?.rtlImage()
        }
    }
}
