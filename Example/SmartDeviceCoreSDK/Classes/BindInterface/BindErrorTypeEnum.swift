//


//


//

import Foundation
import SmartDeviceCoreSDK

public enum BindErrorTypeEnum {
    
    case pwd
    
    
    case ap
    
    
    case ip
    
    
    case auth
    
    
    case connect
    
    
    case canNotFindQRCode
    
    
    case noWifi
    
    
    case canNotBoot
    
    
    case scanQRCodeFailed
    
    
    case otherQuestion
    
    
    case linkAPErr
    
    
    case canNotFindAPNet
    
    
    case ipTimeOut

    
    case unSupportWifi
 
    
    case unSupportCable
    
    
    case wiredErr
    
    
    case wirelessErr
    
    
    case backClick
    
    public var rawValue: String {
          switch self {
          case .pwd:
              return A4xBaseManager.shared.getLocalString(key: "connect_error_wifi")
          case .ap:
              return A4xBaseManager.shared.getLocalString(key: "connect_error_wifi_net")
          case .ip:
              return A4xBaseManager.shared.getLocalString(key: "connect_error_ip")
          case .wirelessErr:
              return A4xBaseManager.shared.getLocalString(key: "connect_error_ip")
          case .auth:
              return A4xBaseManager.shared.getLocalString(key: "connect_error_other")
          case .connect:
              return A4xBaseManager.shared.getLocalString(key: "connect_error_no_voice")
          case .canNotFindQRCode:
              return A4xBaseManager.shared.getLocalString(key: "can_not_find_camera_qr_code")
          case .noWifi:
              return A4xBaseManager.shared.getLocalString(key: "connect_no_wifi")
          case .canNotBoot:
              return A4xBaseManager.shared.getLocalString(key: "can_not_power_up")
          case .scanQRCodeFailed:
              return A4xBaseManager.shared.getLocalString(key: "scan_qr_code_failed")
          case .otherQuestion:
              return A4xBaseManager.shared.getLocalString(key: "add_other_error")
          case .linkAPErr:
            return A4xBaseManager.shared.getLocalString(key: "connection_failed")
          case .canNotFindAPNet:
              return A4xBaseManager.shared.getLocalString(key: "connection_failed")
          case .ipTimeOut:
              return A4xBaseManager.shared.getLocalString(key: "ethernet_ip_failed_title")
          case .unSupportWifi:
              return A4xBaseManager.shared.getLocalString(key: "connect_error_unsupport_wifi")
          case .unSupportCable:
              return A4xBaseManager.shared.getLocalString(key: "connect_error_unsupport_ethernet")
          case .wiredErr:
              return "wried bind time out"
          case .backClick:
              return "error list back click"
          }
      }
   
    public var idValue: Int {
        switch self {
        case .pwd:
            return 0
        case .ap:
            return 1
        case .ip:
            return 2
        case .auth:
            return 3
        case .connect:
            return 4
        case .canNotFindQRCode:
            return 5
        case .noWifi:
            return 6
        case .canNotBoot:
            return 7
        case .scanQRCodeFailed:
            return 8
        case .otherQuestion:
            return 9
        case .linkAPErr:
            return 10
        case .canNotFindAPNet:
            return 11
        case .ipTimeOut:
            return 12
        case .unSupportWifi:
            return 13
        case .unSupportCable:
            return 14
        case .wiredErr:
            return 15
        case .wirelessErr:
            return 16
        case .backClick:
            return 17
        }
    }
    
    public var keyValue: String {
        switch self {
        case .pwd:
            return "password error"
        case .ap:
            return "ssid not found"
        case .ip:
            return "Retrieving IP timeout"
        case .wirelessErr:
            return "Wireless connection failed"
        case .auth:
            return "Authentication error"
        case .connect:
            return "Wi-Fi connection fail"
        case .canNotFindQRCode:
            return "Cannot find the QR code"
        case .noWifi:
            return "Cannot find Wi-Fi"
        case .canNotBoot:
            return "Can not Boot"
        case .scanQRCodeFailed:
            return "Wi-Fi connection fail"
        case .otherQuestion:
            return "Other Problems / No beep"
        case .linkAPErr:
            return "link ap error"
        case .canNotFindAPNet:
            return "can not find ap net"
        case .ipTimeOut:
            return "Get IP timeout"
        case .unSupportWifi:
            return "Wi-Fi connection is not supported"
        case .unSupportCable:
            return "Wired connection is not supported"
        case .wiredErr:
            return "Wired time out"
        case .backClick:
            return "error list back click"
        }
    }
    
    
    
    
    
    
    
    
    public var errCode: String {
        switch self {
        case .pwd:
            return "AP_20"
        case .ap:
            return "AP_21"
        case .ip:
            return "AP_23"
        case .wirelessErr:
            return "AP_24"
        case .auth:
            return "AP_22"
        case .connect:
            return "AP_30"
        case .canNotFindQRCode:
            return "APP_100(Cannot find the QR code)"
        case .noWifi:
            return "APP_101(Cannot find Wi-Fi)"
        case .canNotBoot:
            return "APP_102(Can not Boot)"
        case .scanQRCodeFailed:
            return "APP_103(Wi-Fi connection fail)"
        case .otherQuestion:
            return "APP_104(Other Problems / No beep)"
        case .linkAPErr:
            return "APP_105(link ap error)"
        case .canNotFindAPNet:
            return "APP_106(can not find ap net)"
        case .ipTimeOut:
            return "APP_107(Get IP timeout)"
        case .unSupportWifi:
            return "APP_108(Wi-Fi connection is not supported)"
        case .unSupportCable:
            return "APP_109(Wired connection is not supported)"
        case .wiredErr:
            return "APP_110(Wired time out)"
        case .backClick:
            return "APP_111(error list back click)"
        }
    }
    
    public var errBroadCode: String {
        switch self {
        case .pwd:
            return "PASSWORD_ERROR(\"20\")"
        case .ap:
            return "NO_AP(\"21\")"
        case .ip:
            return "DHCP_ERROR(\"23\")"
        case .wirelessErr:
            return "WIRELESS_ERROR(\"24\")"
        case .auth:
            return "AUTH_ERROR(\"22\")"
        case .connect:
            return "SERVER_TIMEOUT(\"30\")"
        default:
            return "OTHER(\(self.errCode))"
        }
    }
    
    
    public static func wifiConnectErrorStates() -> [BindErrorTypeEnum] {
        return [.pwd, .ap, .ip, .auth, .connect, .unSupportWifi, .otherQuestion]
    }
    
    
    public static func cableConnectErrorStates() -> [BindErrorTypeEnum] {
        return [.connect, .unSupportCable, .otherQuestion]
    }
}
