//




import Foundation

public enum BindFromTypeEnum {
    case first_register
    case no_device_add
    case top_menu_add
    case change_wifi
    case device_manager_wifi_add
    case device_manager_ap_add
    case error_reason(type: BindErrorTypeEnum)
    case back_click
    
    public var key: String? {
        switch self {
        case .first_register:
            return "first_register"
        case .no_device_add:
            return "no_device_add"
        case .top_menu_add:
            return "top_menu_add"
        case .change_wifi:
            return "change_wifi"
        case .device_manager_wifi_add:
            return "device_manager_wifi_add"
        case .device_manager_ap_add:
            return "device_manager_ap_add"
        case .error_reason(let errorType):
            return "error_reason:\(errorType.errCode)"
        case .back_click:
            return "back_click"
        }
    }
}
