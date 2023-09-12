//



import Foundation
import A4xDeviceSettingInterface
import SmartDeviceCoreSDK

public class A4xDeviceSettingImpl: A4xDeviceSettingInterface {
    
    public init(){}
    
    public func pushDevicesSettingViewController(deviceModel: DeviceBean?, fromType: A4xDevicesSettingFrom, navigationController: UINavigationController?) {
        let vc = A4xDevicesSettingViewController()
        vc.deviceModel = deviceModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public func pushDevicesShareViewController(deviceModel: DeviceBean, navigationController: UINavigationController?) {
        let vc = A4xDevicesShareViewController(deviceModel: deviceModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public func pushDevicesSoundViewController(deviceModel: DeviceBean, navigationController: UINavigationController?) {
        let soundVC = A4xDeviceSettingVoiceSettingViewController()
        soundVC.deviceModel = deviceModel
        navigationController?.pushViewController(soundVC, animated: true)
    }

    public func pushSDVideoHistoryViewController(deviceModel: DeviceBean?, navigationController: UINavigationController?) {
        let vc = A4xSDVideoHistoryViewController(deviceModel: deviceModel ?? DeviceBean())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public func pushActivityZoneViewController(deviceModel: DeviceBean?, navigationController: UINavigationController?) {
        let vc = A4xActivityZoneViewController()
        vc.deviceModel = deviceModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
