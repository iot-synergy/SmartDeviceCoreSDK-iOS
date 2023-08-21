//




import Foundation
import SmartDeviceCoreSDK
import Resolver
import BaseUI

public enum A4xDevicesSettingFrom {
    case `default`
    case `simple`
}


public protocol A4xDeviceSettingInterface {
    
    
    func pushDevicesSettingViewController(deviceModel: DeviceBean?, fromType: A4xDevicesSettingFrom, navigationController: UINavigationController?)
    
    
    func pushDevicesShareViewController(deviceModel: DeviceBean, navigationController: UINavigationController?)
    
    func pushDevicesSoundViewController(deviceModel: DeviceBean, navigationController: UINavigationController?)
    
    func pushActivityZoneViewController(deviceModel: DeviceBean?, navigationController: UINavigationController?)
        
}

public class NoopDeviceSettingImpl: A4xDeviceSettingInterface {
    
    public init() {
        
    }
    
    public func pushDevicesSettingViewController(deviceModel: DeviceBean?, fromType: A4xDevicesSettingFrom, navigationController: UINavigationController?) {
        UIApplication.shared.keyWindow?.makeToast("can not push controller because setting sdk not register")
    }
    
    public func pushDevicesShareViewController(deviceModel: DeviceBean, navigationController: UINavigationController?) {
        UIApplication.shared.keyWindow?.makeToast("can not push controller because setting sdk not register")
    }
    
    public func pushDevicesSoundViewController(deviceModel: DeviceBean, navigationController: UINavigationController?) {
        UIApplication.shared.keyWindow?.makeToast("can not push controller because setting sdk not register")
    }
    
    public func pushActivityZoneViewController(deviceModel: DeviceBean?, navigationController: UINavigationController?) {
        UIApplication.shared.keyWindow?.makeToast("can not push controller because setting sdk not register")
    }
    
}



extension Resolver {
    
    public static var deviceSettingImpl: A4xDeviceSettingInterface {
        return Resolver.optional(A4xDeviceSettingInterface.self) ?? NoopDeviceSettingImpl()
    }
    
}

