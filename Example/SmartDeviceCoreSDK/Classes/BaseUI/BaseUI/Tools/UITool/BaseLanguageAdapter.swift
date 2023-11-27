//
//  BaseLanguageAdapter.swift
//  BaseUI
//
//  Created by huafeng on 2023/11/17.
//

import Foundation
import SmartDeviceCoreSDK

public class BaseLanguageAdapter: BaseLanguageProtocol {
    
    public init(){}
    
    // 只有从个人中心的语言设置里，手动切换 app 语言触发，需要手动更新下 languageBundle
    public func updateBundle(language: A4xBaseAppLanguageType) {
        let string: String = language.rawValue
        // 根据当前语言环境获取对应的国际化文件
        let bundlePath = a4xBaseBundle().path(forResource: "\(string)", ofType: "lproj") ?? ""
        languageBundle = Bundle(path: bundlePath) ?? Bundle.main
        languageLocale = Locale(identifier: language.rawValue)
        DateFormatter.kyDatalocal = CurrentLocale()
        NotificationCenter.default.post(name: LanguageChangeNotificationKey, object: nil)
    }
    
}
