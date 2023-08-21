//


//


//

import Foundation
import SmartDeviceCoreSDK

public struct A4xBaseAuthorizationInfo {
    var title : String?
    var descLable : String?
    var descLable2 : String?
    var image : UIImage?
    var tipImage : (UIImage? , String)?
    var tipImageRightStr: String?
    var tip2Image : (UIImage? , String)?
    var okBtnTitle: String?
    var cancelBtnTitle: String?
    var tip1Left: Bool?
    var tip2Left: Bool?
    var okBtnHiden: Bool?
    var cancelBtnHiden: Bool?
}

public enum A4xBaseAuthorizationState {
    case accept
    case reject
}

public enum A4xBaseAuthorizationType {
    case pushAuth
    case location
    case locationServices
    case audio
    case photo
    case camera
    case connectWifi
    case wifiEmpty
    case localNet
    case bluetoothAuth
    case bluetoothOpen
    
    public func authInfo() -> A4xBaseAuthorizationInfo {
        var authInfo : A4xBaseAuthorizationInfo = A4xBaseAuthorizationInfo()
        switch self {
        case .wifiEmpty:
            authInfo.title = A4xBaseManager.shared.getLocalString(key: "prompt")
            authInfo.descLable = A4xBaseManager.shared.getLocalString(key: "can_not_get_ssid")
            authInfo.okBtnTitle = A4xBaseManager.shared.getLocalString(key: "change_wifi")
            authInfo.cancelBtnTitle = A4xBaseManager.shared.getLocalString(key: "manual_input")
        case .connectWifi:
            authInfo.title = A4xBaseManager.shared.getLocalString(key: "prompt") 
            authInfo.descLable = A4xBaseManager.shared.getLocalString(key: "g4_change_wifi")
            authInfo.okBtnTitle = A4xBaseManager.shared.getLocalString(key: "connect_wifi")
            authInfo.cancelBtnTitle = A4xBaseManager.shared.getLocalString(key: "manual_input")
        case .pushAuth:
            authInfo.title = A4xBaseManager.shared.getLocalString(key: "push_permission") //"开启推送权限"
            authInfo.descLable = A4xBaseManager.shared.getLocalString(key: "get_new_pushes")
            authInfo.image = bundleImageFromImageName("authorization_push")?.rtlImage()
        case .location:
            authInfo.title = A4xBaseManager.shared.getLocalString(key: "allow_location_permission_title")
            authInfo.descLable = A4xBaseManager.shared.getLocalString(key: "allow_location_permission_for_camera")
            authInfo.image = bundleImageFromImageName("authorization_public_bg")?.rtlImage()
            authInfo.tipImage = (bundleImageFromImageName("authorization_location_tipImage")?.rtlImage(), A4xBaseManager.shared.getLocalString(key: "location"))
            authInfo.tipImageRightStr = A4xBaseManager.shared.getLocalString(key: "while_using")
            authInfo.okBtnTitle = A4xBaseManager.shared.getLocalString(key: "allow_location_permission")
            authInfo.cancelBtnTitle = A4xBaseManager.shared.getLocalString(key: "manual_input")
        case .locationServices:
            authInfo.title = A4xBaseManager.shared.getLocalString(key: "turn_on_location_services_title")
            authInfo.descLable = A4xBaseManager.shared.getLocalString(key: "open_location_wifi")
            authInfo.image = bundleImageFromImageName("authorization_public_bg")?.rtlImage()
            authInfo.tipImage = (bundleImageFromImageName("authorization_switch_tipImage")?.rtlImage(),A4xBaseManager.shared.getLocalString(key: "location_service"))
            authInfo.okBtnTitle = A4xBaseManager.shared.getLocalString(key: "open_location_service")
            authInfo.cancelBtnTitle = A4xBaseManager.shared.getLocalString(key: "manual_input")
            authInfo.tip1Left = true
            authInfo.tip2Left = true
        case .audio:
            authInfo.title = A4xBaseManager.shared.getLocalString(key: "microphone_permission")
            authInfo.descLable = A4xBaseManager.shared.getLocalString(key: "microphone_permission_tips")
            authInfo.image = bundleImageFromImageName("authorization_public_bg")?.rtlImage()
            authInfo.tipImage = (bundleImageFromImageName("authorization_audio_tipImage")?.rtlImage() , A4xBaseManager.shared.getLocalString(key: "microphone"))
        case .photo:
            authInfo.title = A4xBaseManager.shared.getLocalString(key: "photos_permission")
            authInfo.descLable = A4xBaseManager.shared.getLocalString(key: "photos_permission_tips")
            authInfo.image = bundleImageFromImageName("authorization_public_bg")?.rtlImage()
            authInfo.tipImage = (bundleImageFromImageName("authorization_photo_tipImage")?.rtlImage() , A4xBaseManager.shared.getLocalString(key: "photos"))
        case .localNet:
            authInfo.title = A4xBaseManager.shared.getLocalString(key: "Local_network_tips1")
            authInfo.descLable = A4xBaseManager.shared.getLocalString(key: "Local_network_tips2")
            authInfo.image = bundleImageFromImageName("authorization_public_bg")?.rtlImage()
            authInfo.tipImage = (bundleImageFromImageName("authorization_localnet_tipImage")?.rtlImage() , A4xBaseManager.shared.getLocalString(key: "Local_network"))
        case .camera:
            authInfo.title = A4xBaseManager.shared.getLocalString(key: "camera_permission")
            authInfo.descLable = A4xBaseManager.shared.getLocalString(key: "camera_permission_tips")
            authInfo.image = bundleImageFromImageName("authorization_public_bg")?.rtlImage()
            authInfo.tipImage = (bundleImageFromImageName("authorization_camera_tipImage")?.rtlImage() , A4xBaseManager.shared.getLocalString(key: "camera"))
        case .bluetoothAuth:
            authInfo.title = A4xBaseManager.shared.getLocalString(key: "allow_bluetooth_permission")
            authInfo.descLable = A4xBaseManager.shared.getLocalString(key: "open_bluetooth")
            authInfo.image = bundleImageFromImageName("authorization_public_bg")
            authInfo.okBtnTitle = A4xBaseManager.shared.getLocalString(key: "allow_bluetooth_permission_button")
            authInfo.cancelBtnTitle = A4xBaseManager.shared.getLocalString(key: "not_allow")
        case .bluetoothOpen:
            authInfo.title = A4xBaseManager.shared.getLocalString(key: "bluetooth_system_center")
            authInfo.descLable = A4xBaseManager.shared.getLocalString(key: "open_bluetooth")
            authInfo.image = bundleImageFromImageName("authorization_bluetooth_bg")
            authInfo.okBtnTitle = A4xBaseManager.shared.getLocalString(key: "ok")
            authInfo.cancelBtnHiden = true
        }
        return authInfo
    }
 
}
