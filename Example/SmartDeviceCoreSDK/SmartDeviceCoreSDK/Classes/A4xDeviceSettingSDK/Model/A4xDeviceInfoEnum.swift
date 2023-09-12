//


//


//

import Foundation
import SmartDeviceCoreSDK
import Resolver




public enum A4xDeviceAdvancedInfoEnum  {
    
     case filcker //抗频闪
     case filcker_rate //频闪率
     case install 
    
     static public func advanceCase(flickerEnable enable : Bool , deviceModle : DeviceBean?) -> [[A4xDeviceAdvancedInfoEnum]] {
         var advanceCase : [[A4xDeviceAdvancedInfoEnum]] = Array()
    
         var filckerCase : [A4xDeviceAdvancedInfoEnum] = Array()
         filckerCase.append(.filcker)
        
         advanceCase.append(filckerCase)
        
         var installCase: [A4xDeviceAdvancedInfoEnum] = Array()
         let deviceSupperMirror = deviceModle?.deviceSupport?.deviceSupportMirrorFlip ?? false
         if (deviceModle?.online == 1) && deviceSupperMirror {
             advanceCase.append(installCase)
         }
        
         return advanceCase
     }

    static public func flickerCase(flickerEnable enable : Bool , deviceModle : DeviceBean?) -> [[A4xDeviceAdvancedInfoEnum]] {
        var cases : [[A4xDeviceAdvancedInfoEnum]] = Array()
        var nightCase : [A4xDeviceAdvancedInfoEnum] = Array()
        nightCase.append(.filcker)
        if enable {
            if deviceModle?.antiflickerSupport ?? false {
                nightCase.append(.filcker_rate)
            }
        }
        cases.append(nightCase)
        return cases
    }
    
    public enum A4xFlickerRate: Int {
        case rate_50hz = 50
        case rate_60hz = 60
        
        public func stringValue() -> String {
            return "\(self.value())Hz"
        }
        
        public func stringTipsValue() -> String {
            return ""
        }
        
        public func value() -> Int {
            return self.rawValue
        }
        
        public static func value(of: Int) -> A4xFlickerRate {
            if let type: A4xFlickerRate = A4xFlickerRate(rawValue: of) {
                return type
            }
            return .rate_50hz
        }
        
        public static func allcase() -> [A4xFlickerRate] {
            return [.rate_50hz, .rate_60hz]
        }
        
        public static func allCaseDes() -> [(String, String, [String : Any])] {
            var caseDes : [(String, String, [String : Any])] = Array()
            let allcase = A4xFlickerRate.allcase()
            for index in 0..<allcase.count {
                caseDes.append((allcase[index].stringValue(), allcase[index].stringTipsValue(), [:]))
            }
            return caseDes
        }
    }
    
    public var rawValue: String {
        switch self {
        case .filcker:
            return A4xBaseManager.shared.getLocalString(key: "anti_flicker_setting")
        case .filcker_rate:
            return A4xBaseManager.shared.getLocalString(key: "flicker_rate")
        case .install:
            return A4xBaseManager.shared.getLocalString(key: "installation_settings")
        }
    }
}




