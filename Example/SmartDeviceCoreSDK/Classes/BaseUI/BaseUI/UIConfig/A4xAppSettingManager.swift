

import UIKit
import SmartDeviceCoreSDK

@objc public protocol A4xAppSettingManagerProtocol: AnyObject {
    func changeOrientation(orientation: UIInterfaceOrientationMask)
}

public class A4xAppSettingManager {
    
    public static let shared = A4xAppSettingManager()
    
    public class func `default`() -> A4xAppSettingManager {
        return shared
    }
    
    @objc public weak var delegate : A4xAppSettingManagerProtocol?
    
    public var interfaceOrientations: UIInterfaceOrientationMask = .portrait {
        didSet {
            if oldValue == self.interfaceOrientations {
                return
            }
            
            //强制设置成竖屏
            if interfaceOrientations == .portrait {
                //setInterfaceOrientation(orientation: .portrait)
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue,forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
                A4xLog("interfaceOrientations portrait")
                A4xAppSettingManager.shared.delegate?.changeOrientation(orientation: .portrait)
            } else if !(interfaceOrientations.contains(.portrait) ) {
                if interfaceOrientations.contains(.landscapeRight) {
                    //setInterfaceOrientation(orientation: .landscapeRight)
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue,forKey: "orientation")
                    UIViewController.attemptRotationToDeviceOrientation()
                    A4xLog("interfaceOrientations landscapeRight")
                    A4xAppSettingManager.shared.delegate?.changeOrientation(orientation: .landscapeRight)
                } else if interfaceOrientations.contains(.landscapeLeft) {
                    //setInterfaceOrientation(orientation: .landscapeLeft)
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue,forKey: "orientation")
                    UIViewController.attemptRotationToDeviceOrientation()
                    A4xLog("interfaceOrientations landscapeLeft")
                    A4xAppSettingManager.shared.delegate?.changeOrientation(orientation: .landscapeLeft)
                } else {
                   
                }
            }
        }
    }
    
    private func setInterfaceOrientation(orientation: UIInterfaceOrientationMask) {
        
        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            if #available(iOS 16.0, *) {
                let geometryPreferences: AnyClass? = NSClassFromString("UIWindowScene.GeometryPreferences.iOS")
                geometryPreferences?.setValue(orientation.rawValue, forKey: "interfaceOrientations")
                let sel_method = NSSelectorFromString("requestGeometryUpdateWithPreferences:errorHandler:")
                windowScene?.perform(sel_method, with: geometryPreferences)
            } else {
                
                UIDevice.current.setValue(orientation.rawValue,
                                          forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        } else {
            
            UIDevice.current.setValue(orientation.rawValue,
                                      forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
        
        A4xAppSettingManager.shared.delegate?.changeOrientation(orientation: orientation)
    }
    
    public func orientationIsLandscape() -> Bool {
        if interfaceOrientations == .landscape || interfaceOrientations == .landscapeLeft || interfaceOrientations == .landscapeRight {
            return true
        }
        return false
    }
    
    
   
   
}
