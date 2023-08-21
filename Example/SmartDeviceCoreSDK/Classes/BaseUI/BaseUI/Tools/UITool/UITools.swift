//


import Foundation
import SmartDeviceCoreSDK


public func bundleImageFromImageName(_ imageName: String, for aClass: AnyClass = A4xBaseResource.self) -> UIImage? {
    if let bundleImage = UIImage(named: imageName, in: a4xBaseBundle(for: aClass), compatibleWith: nil) {
           return bundleImage
    } else {
        if !imageName.isEmpty {
            assert(false, "未找到图片资源文件, imageName:\(imageName)")
            if A4xBaseManager.shared.checkIsDebug() {
                showErrorAlert(resourceName: imageName, for: aClass)
            }
            
        }
        return UIImage(named: imageName)
    }
}

public func showErrorAlert(resourceName: String, for aClass: AnyClass) {
    var config = A4xBaseAlertAnimailConfig()
    config.rightbtnBgColor = UIColor.clear
    config.rightTextColor = ADTheme.Theme
    let alert = A4xBaseAlertView(param: config, identifier: "showTipAlert + \(Int.kRandom())")
    alert.message  = "在当前类: \(aClass) 未找到资源文件, resourceName:\(resourceName)"
    alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "got_it")
    
    alert.show()
}



public func a4xBaseBundle(for aClass: AnyClass = A4xBaseResource.self) -> Bundle {
    let frameworkBundle = Bundle(for: aClass)
    return frameworkBundle
}

public var languageBundle: Bundle = {
    let currentLanguage = A4xBaseAppLanguageType.language()
    
    let bundlePath = a4xBaseBundle().path(forResource: "\(currentLanguage.rawValue)", ofType: "lproj") ?? ""
    return Bundle(path: bundlePath) ?? Bundle.main
}()


public func getNavigation() -> UINavigationController? {
    var navtions: UINavigationController? = nil
    if let nav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
        navtions = nav
    }
    navtions?.setDirectionConfig()
    return navtions
}
