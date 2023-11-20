//


import Foundation
import BindInterface
import SmartDeviceCoreSDK

import A4xLocation

typealias callbackBlock = ((_ code: Int, _ msg: String, _ result: [String : Any]) -> Void)

var bindSDKCallBack: callbackBlock?

public class BindUIkitImpl: BindInterface {
    
    public init() {}
    
    
    public func pushAddLocationViewController(locationModle: A4xDeviceLocationModel?, navigationController: UINavigationController?) {
        let addloc = A4xAddLocationViewController(locationModle: locationModle)
        navigationController?.pushViewController(addloc, animated: true)
    }
    
    public func pushBindEditDeviceNameViewController(bindCode: String?, bindFrom: String?, serialNumber: String?, isChangeWifi: Bool?, deviceModel: DeviceBean?, navigationController: UINavigationController?) {
        
    }
    
    public func pushScanQrCodeViewController(navigationController: UINavigationController?, comple: @escaping (Int, String, [String : Any]) -> Void) {
        bindSDKCallBack = comple
        let vc = A4xScanQrcodeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public func pushBindViewController(isAPMode: Bool, bindFromType: BindFromTypeEnum, navigationController: UINavigationController?) {
        let vc = BindBootUpGuideViewController()
        vc.bindFromType = bindFromType
        vc.isAPMode = isAPMode
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public func presentBindViewController(isAPMode: Bool, bindFromType: BindFromTypeEnum, navigationController: UINavigationController?) {
        let vc = BindBootUpGuideViewController()
        vc.isAPMode = isAPMode
        vc.bindFromType = bindFromType
        vc.isPresent = true
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        nav.setDirectionConfig()
        navigationController?.present(nav, animated: true)
        
        switch bindFromType {
        case .no_device_add:
            fallthrough
        case .top_menu_add:
            
            break
        default:
            break
        }
    }
    
}
