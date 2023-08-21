//


//


//

import Foundation
import SmartDeviceCoreSDK

public struct A4xDevicesSleepPlanModel {
    var cellHeight: CGFloat?
    var type: A4xDevicesSleepPlanEnum
    var title: String?
    
    public init(_ type: A4xDevicesSleepPlanEnum, _ title: String? = nil) {
        self.type = type
        self.title = title
    }
}

public enum A4xDevicesSleepPlanEnum {
    case sleepPlanOpen 
    case sleepPlan 
    case setPlan 
    
    static public func cases(setPlanEnable: Bool, deviceModle: DeviceBean?) -> [[A4xDevicesSleepPlanModel]] {
        var baseCases: [[A4xDevicesSleepPlanModel]] = Array()
        baseCases.append([A4xDevicesSleepPlanModel(.sleepPlanOpen, A4xBaseManager.shared.getLocalString(key: "sleep_mode"))])
       
        var setPlanCase: [A4xDevicesSleepPlanModel] = Array()
        setPlanCase.append(A4xDevicesSleepPlanModel(.sleepPlan, A4xBaseManager.shared.getLocalString(key: "auto_sleep")))
        if setPlanEnable {
            setPlanCase.append(A4xDevicesSleepPlanModel(.setPlan, A4xBaseManager.shared.getLocalString(key: "schedule_time")))
        }
        baseCases.append(setPlanCase)
        return baseCases
    }
}

public struct A4xDevicesSetSleepPlanModel {
    var cellHeight: CGFloat?
    var type: A4xDevicesSetSleepPlanEnum
    var title: String?
    
    public init(_ type: A4xDevicesSetSleepPlanEnum, _ title: String? = nil) {
        self.type = type
        self.title = title
    }
}

public enum A4xDevicesSetSleepPlanEnum {
    case editPlan 
    case showPlan 
    
    static public func cases(showPlan: Bool, deviceModle: DeviceBean?) -> [[A4xDevicesSetSleepPlanModel]] {
        var baseCases: [[A4xDevicesSetSleepPlanModel]] = Array()
        if showPlan {
            baseCases.append([A4xDevicesSetSleepPlanModel(.showPlan)])
            return baseCases
        } else {
            baseCases.append([A4xDevicesSetSleepPlanModel(.editPlan)])
            return baseCases
        }
    }
}

