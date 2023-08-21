//

import Foundation
import SmartDeviceCoreSDK
import Resolver
import BaseUI

public protocol BindInterface {
    
    func pushBindViewController(bindFromType: BindFromTypeEnum, navigationController: UINavigationController?)
    
    func pushAddLocationViewController(locationModle: A4xDeviceLocationModel?, navigationController: UINavigationController?)
   
    
    func pushBindEditDeviceNameViewController(bindCode: String?, bindFrom: String?, serialNumber: String?, isChangeWifi: Bool?, deviceModel: DeviceBean?, navigationController: UINavigationController?)
        
    
    func presentBindViewController(bindFromType: BindFromTypeEnum, navigationController: UINavigationController?)
    
    func pushScanQrCodeViewController(navigationController: UINavigationController?, comple: @escaping (_ code: Int, _ msg: String, _ result: [String: Any]) -> Void)
    
}


public class NoopBindImpl: BindInterface {
    public init() {
        
    }
    
    public func pushBindViewController(bindFromType: BindFromTypeEnum, navigationController: UINavigationController?) {
        UIApplication.shared.keyWindow?.makeToast("can not push controller because bind sdk not register")
    }
    
    public func presentBindViewController(bindFromType: BindFromTypeEnum, navigationController: UINavigationController?) {
        UIApplication.shared.keyWindow?.makeToast("can not present controller because bind sdk not register")
    }
    
    public func pushScanQrCodeViewController(navigationController: UINavigationController?, comple: @escaping (_ code: Int, _ msg: String, _ result: [String: Any]) -> Void) {
        UIApplication.shared.keyWindow?.makeToast("can not push controller because bind sdk not register")
    }
    
    public func pushAddLocationViewController(locationModle: A4xDeviceLocationModel?, navigationController: UINavigationController?) {
        UIApplication.shared.keyWindow?.makeToast("can not push controller because bind sdk not register")
    }
    
    public func pushBindEditDeviceNameViewController(bindCode: String?, bindFrom: String?, serialNumber: String?, isChangeWifi: Bool?, deviceModel: DeviceBean?, navigationController: UINavigationController?) {
        UIApplication.shared.keyWindow?.makeToast("can not push controller because bind sdk not register")
    }
    
}

extension Resolver {
    
    public static var bindImpl: BindInterface {
        return Resolver.optional(BindInterface.self) ?? NoopBindImpl()
    }
}
