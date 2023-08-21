//


//


//

import Foundation
import SmartDeviceCoreSDK

public enum A4xDeviceSettingInfoEnum {
    public typealias AllCases = String

    case header
    /**
     第一个参数： 添加 [.motion,（运动检测） .analysis,（AI 分析） .notifi] 方块模块个数
     第二个参数： 添加 [.motion,（运动检测） .analysis,（AI 分析） .notifi] 方块模块中 开启、未开启等文案
     */
    case boxArr(([A4xDeviceSettingSubInfoEnum]?, [String]?))
    

    
    case lightSet 
    case soundSet
    
    case share
    case remove 

    public static func == (lhs: A4xDeviceSettingInfoEnum, rhs: A4xDeviceSettingInfoEnum) -> Bool {
        return lhs.rawValue(modelCategory: 0) == rhs.rawValue(modelCategory: 0)
    }
    
    public func rawValue(modelCategory: Int? = 0) -> String? {
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: modelCategory ?? 0)
        switch self {
        case .header:
            return nil
        
        case .boxArr(_):
            return nil
        case .lightSet:
            return A4xBaseManager.shared.getLocalString(key: "light_setting")
        case .soundSet:
            return A4xBaseManager.shared.getLocalString(key: "audio_setting")
        case .share:
            return A4xBaseManager.shared.getLocalString(key: "share")
        case .remove:
            return A4xBaseManager.shared.getLocalString(key: "remove_device", param: [tempString])
        }
    }
    
    
    public var imgValue : UIImage? {
        switch self {
        
        case .header:
            return A4xDeviceSettingResource.UIImage(named: "device_set_push")?.rtlImage()
        case .boxArr(_):
            return A4xDeviceSettingResource.UIImage(named: "device_set_push")?.rtlImage()
        case .lightSet:
            return A4xDeviceSettingResource.UIImage(named: "device_set_light")?.rtlImage()
        case .soundSet:
            return A4xDeviceSettingResource.UIImage(named: "device_set_sound")?.rtlImage()
        case .share:
            return A4xDeviceSettingResource.UIImage(named: "device_set_share")?.rtlImage()
        case .remove:
            return A4xDeviceSettingResource.UIImage(named: "device_set_push")?.rtlImage()
        }
    }
    
    
    internal static func managerCases(vip : Bool,offline : Bool , deviceModel : DeviceBean?) -> [[A4xDeviceSettingInfoEnum]]  {
        
        var allSetting: [[A4xDeviceSettingInfoEnum]] = [[.header]] 
        if A4xProjectConfigManager.projectConfig.deviceSettingTheme == .theme1 {
            allSetting = [[]]
        }
        
        if offline {
            allSetting.append( [.remove])
            return allSetting
        }
        
        var boxSetting: [A4xDeviceSettingInfoEnum] = []
        var boxSubSetting: [A4xDeviceSettingSubInfoEnum] = []  
        var boxSetDesArr: [String] = []

        boxSubSetting = [.motion, .notifi, .alarmSetting, .videoSetting]
        let motionDesStr = ""
        let notifiDesStr = ""
        let alarmSettingDesString = ""
        let videoSettingDesString = ""
        boxSetDesArr = [motionDesStr, notifiDesStr, alarmSettingDesString, videoSettingDesString]
        
        
        boxSetting.append(.boxArr((boxSubSetting, boxSetDesArr)))
        allSetting.append(boxSetting)
        
        var normal2Settings : [A4xDeviceSettingInfoEnum] = []
        
        let supportRecLamp = deviceModel?.supportRecLamp()
        if deviceModel?.online == 1 {
            if supportRecLamp == false {
            } else {
                normal2Settings.append(.lightSet)
            }
        }

        normal2Settings.append(.soundSet)
        allSetting.append(normal2Settings)
        
        var normal3Settings : [A4xDeviceSettingInfoEnum] = []
        normal3Settings.append(.share)
        allSetting.append(normal3Settings)

        
        allSetting.append([.remove])
        return allSetting
    }
  
}

public enum A4xDeviceSettingSubInfoEnum {
    case motion 
    case notifi 
    case alarmSetting 
    
    case videoSetting 

    
    public var rawValue : String? {
        switch self {
        case .motion:
            return A4xBaseManager.shared.getLocalString(key: "motion_detection")
        case .notifi:
            return A4xBaseManager.shared.getLocalString(key: "notification_setting")
        case .alarmSetting:
            return A4xBaseManager.shared.getLocalString(key: "alarm_setting")
        case .videoSetting:
            return A4xBaseManager.shared.getLocalString(key: "video_settings").capitalized
        }
    }
    
    public func imgValue() -> UIImage? {
        switch self {
        case .motion:
            return A4xDeviceSettingResource.UIImage(named: "device_set_motion_detection")?.rtlImage()
        case .notifi:
            return A4xDeviceSettingResource.UIImage(named: "device_set_push")?.rtlImage()
        case .alarmSetting:
            return A4xDeviceSettingResource.UIImage(named: "device_set_alarm")?.rtlImage()
        case .videoSetting:
            return A4xDeviceSettingResource.UIImage(named: "device_set_video_setting")?.rtlImage()

        }
    }
}
