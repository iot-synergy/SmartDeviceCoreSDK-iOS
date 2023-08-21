//


//


//

import Foundation
import UIKit
import Photos
import SmartDeviceCoreSDK

public class A4xBaseAuthorizationViewModel {
    public static var single = A4xBaseAuthorizationViewModel()
    let serialQueue = DispatchQueue(label: "serialQueue", qos: DispatchQoS.userInitiated)

    let authorQurue : [A4xBaseAuthorizationType] = [.pushAuth , .audio , .photo , .camera]
    
    public func requestAllAuthor() {
        let semaphore = DispatchSemaphore(value: 1)

        serialQueue.async { [weak self] in

            for requestIndex in 0..<(self?.authorQurue.count ?? 0) {
                if let author = self?.authorQurue.getIndex(requestIndex) {
                    let result = semaphore.wait(timeout: DispatchTime.distantFuture)
                    if result == .success {
                        self?.showRequestAlert(type: author, comple: { (f) in
                            semaphore.signal()
                        })
                    }
                }
            }
            print("showRequestAlert done")
        }
    }
    
    
    
    public func showRequestAlert(type : A4xBaseAuthorizationType, comple: @escaping (Bool)->Void) {
        print("showRequestAlert --> \(type)")
        DispatchQueue.main.a4xAfter(0.1) { [weak self] in
            let alert = A4xBaseAuthorztionAlertView(config: A4xBaseAlertConfig(), type: type)
            alert.show()

            alert.onResultAction = {(open, type) in
                print("onResultAction \(open) \(type)")
                if open {
                    self?.openSetting()
                    comple(true)
                }else {
                    UserDefaults.standard.set("1", forKey: "push_notic_alert_click_later")
                    comple(false)
                }
            }
        }
      
    }
    
    private func openSetting() {
        
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    
    }
    
    public func requestVoIPAuthor(comple: @escaping (_ isAgree : Bool ,_ isRequest : Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        let requestAuthorBlock: () -> Void = {
            center.requestAuthorization(options: [.badge,.sound,.alert]) { (granted, error) in
                
                guard error == nil else {
                    
                    comple(false, true)
                    return
                }
                
                guard granted else {
                    
                    comple(false, true)
                    return
                }
                comple(true, true)
            }
        }
        //可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
        //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象哦，不能直接修改！
        center.getNotificationSettings { (setting) in
            let status = setting.authorizationStatus
            switch status {
            case .notDetermined:
                
                fallthrough
            case .provisional:
                
                requestAuthorBlock()
            case .denied:
                requestAuthorBlock()
                //fallthrough
            //
            case .authorized:
                
                onMainThread {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                comple(true , false)
            default :
                comple(true , false)
            }
        }
        
    }
    
    public func setPushAuthorInfo(comple: @escaping (_ result : String) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (setting) in
            let status = setting.authorizationStatus
            switch status {
            case .notDetermined:
                setPushAuth("UnKnown")
                comple("notDetermined")
            case .provisional:
                setPushAuth("Open")
                comple("provisional")
            case .denied:
                setPushAuth("Close")
                comple("denied")
            case .authorized:
                setPushAuth("Open")
                comple("authorized")
            default :
                setPushAuth("UnKnown")
                comple("default")
            }
        }
        
        func setPushAuth(_ status: String) {
            UserDefaults.standard.setValue(status, forKey: "push_permissions")
        }
    }
    
    public func getPushAuthInfo() -> String {
        return UserDefaults.standard.string(forKey: "push_permissions") ?? "UnKnown"
    }
    
    public func requestPushAuthor(isForce: Bool, target: UNUserNotificationCenterDelegate, comple: @escaping (_ isAgree : Bool ,_ isRequest : Bool) -> Void) {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = target
        UIApplication.shared.registerForRemoteNotifications()
        
        let requestAuthorBlock: () -> Void = {
            
            if !isForce {
                comple(false, true)
                return
            }
            
            center.requestAuthorization(options: [.badge,.sound,.alert]) { (granted, error) in
                
                guard error == nil else {
                    
                    comple(false, true)
                    return
                }
                
                guard granted else {
                    
                    comple(false, true)
                    return
                }
                comple(true, true)
            }
        }
        //可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
        //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象哦，不能直接修改！
        center.getNotificationSettings { (setting) in
            let status = setting.authorizationStatus
            switch status {
            case .notDetermined:
                
                
                fallthrough
            case .provisional:
                
                requestAuthorBlock()
            case .denied:
                requestAuthorBlock()
                //fallthrough
            //
            case .authorized:
                
                onMainThread {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                comple(true , false)
            default :
                comple(true , false)
            }
        }
        
        func setPushAuth(status: String) {
            UserDefaults.standard.setValue(status, forKey: "push_permissions")
        }
    }
    
    public func requestPhotoAuthor (comple : @escaping (Bool)->Void) {
        onMainThread {
            var status = PHPhotoLibrary.authorizationStatus()
            if #available(iOS 14, *) {
                 status = PHPhotoLibrary.authorizationStatus(for: PHAccessLevel.readWrite)
            }
            switch status {
            case .notDetermined:
                
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized {
                        comple(true)
                    }else {
                        comple(false)
                    }
                }
            case .restricted:
                comple(false)
            case .denied:
                comple(false)
            case .authorized:
                comple(true)
            case .limited:
                comple(false)
            @unknown default:
                
                print("Didn't request permission for User Notifications")
                comple(false)
            }
        }
    }
}
