//


import Foundation
import A4xLiveVideoUIInterface
import SmartDeviceCoreSDK
import BaseUI

public class A4xLiveVideoUIImpl: A4xLiveVideoUIInterface {
    
    public init() {
        
    }
  
    public func pushFullLiveVideoViewController(deviceModel: DeviceBean, shouldBackStop: Bool, topTipString: String?, navigationViewController: UINavigationController?) {
        let cvc = A4xFullLiveVideoViewController() 
        cvc.dataSource = deviceModel
        cvc.shouldBackStop = shouldBackStop
        cvc.topTipString = topTipString
        navigationViewController?.pushViewController(cvc, animated: true)
    }
    
    public func tryPopToFullLiveVideoViewController(navigationController: UINavigationController?) {
        let vcs =  navigationController?.viewControllers.filter({ (vc) -> Bool in
            return vc is A4xFullLiveVideoViewController
        })
            
        guard let toViewController = vcs?.last else {
            return
        }
        navigationController?.popToViewController(toViewController, animated: true)
    }
    
    
}
