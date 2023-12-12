//
//  AppDelegate.swift
//  SmartDeviceCoreSDK
//
//  Created by meihuafeng on 08/11/2023.
//  Copyright (c) 2023 meihuafeng. All rights reserved.
//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppDelegate.registerAllServices()
        
        // init smart device core sdk
        let config:InitSDKConfig = InitConfigBuilder()
            .setTenantId("vicoo")
            .setLanguage("en")
            .setIsDebug(true)
            .setLoggerDelegate(LoggerImpl())
            .setAccountChangeListener(self)
            .build()
            
        SmartDeviceCore.getInstance().initSDK(config: config) { code, message in
            
        } onError: { code, message in
            
        }
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        A4xUserDataHandle.loadStoreData {
            
            if A4xUserDataHandle.Handle?.loginModel != nil {
                
                let homeVC = RootViewController(menuIndex: 0)
                let nav: A4xBaseAccountNavgationContoller =  A4xBaseAccountNavgationContoller(rootViewController: homeVC)
                nav.setDirectionConfig()
                self.window?.rootViewController = nav;
                
            } else {
                let rootVC : AccountFirstController = AccountFirstController()
                let nav: A4xBaseAccountNavgationContoller =  A4xBaseAccountNavgationContoller(rootViewController: rootVC)
                nav.setDirectionConfig()
                self.window?.rootViewController = nav
            }
            
            self.window?.makeKeyAndVisible()
            
        }
        
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return A4xAppSettingManager.shared.interfaceOrientations
    }
    
}

extension AppDelegate: AccountChangeListener {
    func onLoginSuccess(userId: Int64) {
        
    }
    
    
    // 账号过期
    func onAccountInfoError(status: Int) {
        logError("account info error: \(status)")
    }
    
}
