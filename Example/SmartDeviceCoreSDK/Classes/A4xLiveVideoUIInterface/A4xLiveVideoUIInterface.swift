//


import Foundation
import SmartDeviceCoreSDK
import Resolver
import BaseUI

public protocol A4xLiveVideoUIInterface {
    
    
    
    func pushFullLiveVideoViewController(deviceModel: DeviceBean, shouldBackStop: Bool, topTipString: String?, navigationViewController: UINavigationController?)
    
    func tryPopToFullLiveVideoViewController(navigationController: UINavigationController?)
    
    // To ApMode Live page
    func pushHotlinkLiveVideoViewController(fromVCType: FromViewControllerEnum?, navigationViewController: UINavigationController?)
    
}


class NoopLiveVideoUIImpl: A4xLiveVideoUIInterface {

    func pushFullLiveVideoViewController(deviceModel: DeviceBean, shouldBackStop: Bool, topTipString: String?, navigationViewController: UINavigationController?) {
        noopImplToast()
    }
    
    func tryPopToFullLiveVideoViewController(navigationController: UINavigationController?) {
        noopImplToast()
    }
    
    func pushHotlinkLiveVideoViewController(fromVCType: FromViewControllerEnum?, navigationViewController: UINavigationController?) {
        noopImplToast()
    }
    
    private func noopImplToast() {
        UIApplication.shared.keyWindow?.makeToast("error: not register live ui impl")
    }
    
}


extension Resolver {
    public static var liveUIImpl: A4xLiveVideoUIInterface {
        return Resolver.optional(A4xLiveVideoUIInterface.self) ?? NoopLiveVideoUIImpl()
    }
}
