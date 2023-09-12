//


//


//

import Foundation
import SmartDeviceCoreSDK

public enum A4xDevicesMotioninfoEnum {
    
    case motion     //= "Motion Detection"
    case motion_d   //= "Detection Sensitivity" 检测灵敏度
    case shooting_interval_switch 
    case shooting_interval 
    case record     //= "Record Video"
    case record_d   //= "Duration"
    case record_r   //= "Resolution"
    case alarm     //= "Camera Alarm"
    case alarm_d   //= "Duration "
    
    
    
    case recLamp
    case alarm_light     //= "Camera Alarm" 报警闪光灯
    case night      //= "Night Vision"
    case night_d    //= "Sensitivity Level"
    case night_modle    //夜视模式
    
    case motion_tracking //运动跟踪
    case move_tracking //追踪模式

    var rawValue : String {
        switch self {
        case .motion:
            return A4xBaseManager.shared.getLocalString(key: "motion_detection")
        case .motion_d:
            return A4xBaseManager.shared.getLocalString(key: "detection_sensitivity")
        case .shooting_interval_switch:
            return A4xBaseManager.shared.getLocalString(key: "shooting_interval")
        case .shooting_interval:
            return A4xBaseManager.shared.getLocalString(key: "interval_time")
        case .record:
            return A4xBaseManager.shared.getLocalString(key: "record_video")
        case .record_d:
            return A4xBaseManager.shared.getLocalString(key: "video_duration")
        case .record_r:
            return A4xBaseManager.shared.getLocalString(key: "video_resolution")
        
        case .alarm:
            return A4xBaseManager.shared.getLocalString(key: "camera_alarm")
        case .alarm_d:
            return A4xBaseManager.shared.getLocalString(key: "duration_alarm")
        case .night:
            return A4xBaseManager.shared.getLocalString(key: "night_version")
        case .night_d:
            return A4xBaseManager.shared.getLocalString(key: "sensitivity_level")
        case .recLamp:
            return A4xBaseManager.shared.getLocalString(key: "indicator")
        case .alarm_light:
            return A4xBaseManager.shared.getLocalString(key: "flash_light_item")
        case .night_modle:
            return A4xBaseManager.shared.getLocalString(key: "config_night_mode")
        
         case .motion_tracking:
             return A4xBaseManager.shared.getLocalString(key: "motion_tracking")
         case .move_tracking:
             return A4xBaseManager.shared.getLocalString(key: "tracking_mode")
        }
    }
    
    public enum A4xDeviceMoveTrackModel: Int {
        case allMove    = 0
        case human      = 1
        
        var stringValue: String {
            switch self {
            case .allMove:
                return A4xBaseManager.shared.getLocalString(key: "action_tracking")
            case .human:
                return A4xBaseManager.shared.getLocalString(key: "human_tracking")
            }
        }
        
        var stringTipsValue: String {
            switch self {
            case .allMove:
                return ""
            case .human:
                return ""
            }
        }
        
        public static func allcase() -> [A4xDeviceMoveTrackModel] {
            return [.allMove, .human]
        }
        
        public static func value(of: Int) -> A4xDeviceMoveTrackModel {
            return A4xDeviceMoveTrackModel(rawValue: of) ?? .allMove
        }
        
    }
    
    
    
    public enum A4xMotionLevelEnum: Int {
        case high = 1 
        case medium = 2  
        case low = 3  //= "Low"
        case auto = 4 
        
        var stringValue : String {
            switch self {
            case .high:
                return A4xBaseManager.shared.getLocalString(key: "high")
            case .medium:
                return A4xBaseManager.shared.getLocalString(key: "medium")
            case .low:
                return A4xBaseManager.shared.getLocalString(key: "low")
            case .auto:
                return A4xBaseManager.shared.getLocalString(key: "auto")
            }
        }
        
        var stringTipsValue: String {
            switch self {
            case .high:
                return ""
            case .medium:
                return ""
            case .low:
                return ""
            case .auto:
                return ""
            }
        }
        
        public static func value(of : Int) -> A4xMotionLevelEnum {
            return A4xMotionLevelEnum(rawValue: of) ?? .low
        }
    }
    
    
    //
   

    
    public enum A4xRecordCountEnum {
        case auto
        case value(Int)
        
        var rawValue: String {
            switch self {
            case .auto:
                return A4xBaseManager.shared.getLocalString(key: "auto")
            case let .value(v):
                return "\(v)s"
            }
        }
        
        func rawTipsValue(modelCategory: Int) -> String {
            switch self {
            case .auto:
                let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: modelCategory)
                return A4xBaseManager.shared.getLocalString(key: "auto_video_record_desc", param: [tempString])
            case .value(_):
                return ""
            }
        }
        
        public static func allcase() -> [A4xRecordCountEnum] {
            return [.auto, .value(10), .value(15), .value(20)]
        }
        
        public static func allCaseDes(modelCategory: Int) -> [(String, String, [String : Any])] {
            var caseDes: [(String, String, [String : Any])] = Array()
            let allcase = A4xRecordCountEnum.allcase()
            for index in 0..<allcase.count {
                caseDes.append((allcase[index].rawValue, allcase[index].rawTipsValue(modelCategory: modelCategory), [:]))
            }
            return caseDes
        }
        
        
        public static func clickCase(timeModels: [A4xDeviceTimeIntervalModel]) -> [A4xRecordCountEnum] {
            var allcase = [A4xRecordCountEnum]()
            
            for timeModel in timeModels {
                if timeModel.enabled == true {
                    if timeModel.value == -1 {
                        allcase.append(.auto)
                    } else {
                        allcase.append(.value(timeModel.value ?? 0))
                    }
                }
            }
            return allcase
        }
        
        
        public static func clickVideoSecondsApCase(videoSeconds: [Int]) -> [A4xRecordCountEnum] {
            var allcase = [A4xRecordCountEnum]()
            for videoSecond in videoSeconds {
                if videoSecond == -1 {
                    allcase.append(.auto)
                } else {
                    allcase.append(.value(videoSecond))
                }
            }
            return allcase
        }
        
        public static func clickCaseDes(type: Int, timeModels: [A4xDeviceTimeIntervalModel]) -> [(String, String, [String : Any])] {
            var caseDes: [(String, String, [String : Any])] = Array()
            for timeModel in timeModels {
                
                if timeModel.enabled == true {
                    let timeStringCase = "video_duration_" + String(timeModel.value!)
                    var timeString = A4xBaseManager.shared.getLocalString(key: timeStringCase)
                    var subString = ""
                    if timeModel.value == -1 { 
                        timeString = A4xBaseManager.shared.getLocalString(key: "auto")
                        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: type)
                        subString = A4xBaseManager.shared.getLocalString(key: "auto_video_record_desc", param: [tempString])
                    }
                    caseDes.append(("", subString, [timeString : timeModel.enabled as Any]))
                }
            }
            return caseDes
        }
        
        public static func clickVideoSecondsAPCaseDes(type: Int, videoSeconds: [Int]) -> [(String, String, [String : Any])] {
            var caseDes: [(String, String, [String : Any])] = Array()
            for videoSecond in videoSeconds {
                let timeStringCase = "video_duration_" + String(videoSecond)
                var timeString = A4xBaseManager.shared.getLocalString(key: timeStringCase)
                var subString = ""
                if videoSecond == -1 { 
                    timeString = A4xBaseManager.shared.getLocalString(key: "auto")
                    let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: type)
                    subString = A4xBaseManager.shared.getLocalString(key: "auto_video_record_desc", param: [tempString])
                }
                caseDes.append(("", subString, [timeString : true]))
            }
            return caseDes
        }
        
        public func value() -> Int {
            switch self {
            case .auto:
                return -1
            case let .value(v):
                return v
            }
        }
        
        public static func value(of: Int) -> A4xRecordCountEnum {
            guard of != 10 && of != 15 && of != 20 else {
                return .value(of)
            }
            return .auto
        }
    }
    
    static public func apCases(motionEnable mEnable: Bool, recordEnable rEnable: Bool, cameraEnable cEnable: Bool, shootingEnable: Bool, isSupportshooting: Bool, moveTracking mvEnable: Bool, deviceModle: DeviceBean?) -> [[A4xDevicesMotioninfoEnum]] {
        var cases: [[A4xDevicesMotioninfoEnum]] = Array()

        var motionCase: [A4xDevicesMotioninfoEnum] = Array()
        motionCase.append(.motion)
        if mEnable {
            motionCase.append(.motion_d)
        } else {
            cases.append(motionCase)
            return cases
        }
        
        cases.append(motionCase)
        var shootingCase: [A4xDevicesMotioninfoEnum] = Array()
        
        if isSupportshooting == true
        {
            if shootingEnable == true {
                shootingCase.append(.shooting_interval_switch)
                shootingCase.append(.shooting_interval)
            }
            else{
                shootingCase.append(.shooting_interval_switch)
            }
        }
        cases.append(shootingCase)
        
        var recordCase: [A4xDevicesMotioninfoEnum] = Array()
        if rEnable {
            recordCase.append(.record_d)
            

            cases.append(recordCase)
        }
        
        
        if deviceModle?.deviceContrl?.supportMotionTrack == true {
            
            
            cases.append([.motion_tracking])
            
            if mvEnable {
                //recordCase.append(.move_tracking)
            }
        }
        return cases
    }
    
    static public func cases(motionEnable mEnable: Bool, recordEnable rEnable: Bool, cameraEnable cEnable: Bool, shootingEnable: Bool, isSupportshooting: Bool, cooldownUserEnable: Bool, moveTracking mvEnable: Bool, deviceModle: DeviceBean?) -> [[A4xDevicesMotioninfoEnum]] {
        var cases: [[A4xDevicesMotioninfoEnum]] = Array()

        var motionCase: [A4xDevicesMotioninfoEnum] = Array()
        motionCase.append(.motion)
        if mEnable {
            motionCase.append(.motion_d)
        } else {
            cases.append(motionCase)
            return cases
        }
        
        cases.append(motionCase)
        var shootingCase: [A4xDevicesMotioninfoEnum] = Array()
        
        if isSupportshooting == true
        {
            if cooldownUserEnable == true {
                shootingCase.append(.shooting_interval_switch)
                if shootingEnable == true {
                    shootingCase.append(.shooting_interval)
                }
            }
            else{

                shootingCase.append(.shooting_interval)
            }
        }
        
        cases.append(shootingCase)
        
        var recordCase: [A4xDevicesMotioninfoEnum] = Array()
        if rEnable {
            recordCase.append(.record_d)
            recordCase.append(.record_r)
            cases.append(recordCase)
        }
        
        
        if deviceModle?.deviceContrl?.supportMotionTrack == true {
            
            
            cases.append([.motion_tracking])
            
            if mvEnable {
                //recordCase.append(.move_tracking)
            }
        }
        return cases
    }
    
    
    static public func nightCase(nightEnable enable: Bool, deviceModle: DeviceBean?) -> [[A4xDevicesMotioninfoEnum]] {
        var cases: [[A4xDevicesMotioninfoEnum]] = Array()
        var nightCase: [A4xDevicesMotioninfoEnum] = Array()
        nightCase.append(.night)
        if enable {
            if deviceModle?.deviceContrl?.whiteLight ?? false {
                nightCase.append(.night_modle)
            }
            nightCase.append(.night_d)
        }
        cases.append(nightCase)
        return cases
    }
    
    
    static public func lightCase(nightEnable enable: Bool , deviceModle : DeviceBean?) -> [[A4xDevicesMotioninfoEnum]] {
        var cases: [[A4xDevicesMotioninfoEnum]] = Array()
        
        var lamptCase: [A4xDevicesMotioninfoEnum] = Array()
        if deviceModle?.supportRecLamp() == true {
            lamptCase.append(.recLamp)
            cases.append(lamptCase)
        }
        
        var lightCase: [A4xDevicesMotioninfoEnum] = Array()
        if deviceModle?.deviceContrl?.whiteLight ?? false {
            lightCase.append(.alarm_light)
            cases.append(lightCase)
        }
        
        var nightCase: [A4xDevicesMotioninfoEnum] = Array()
        nightCase.append(.night)
        if enable {
            if deviceModle?.deviceContrl?.whiteLight ?? false {
                nightCase.append(.night_modle)
            }
            nightCase.append(.night_d)
        }
        cases.append(nightCase)
        return cases
    }
}
