//
//  Extension+A4xBaseManager.swift
//  BaseUI
//
//  Created by huafeng on 2023/8/29.
//

import Foundation
import SmartDeviceCoreSDK

extension A4xBaseManager {
    
    /// 传入ModelCategory -> 设备类型字符串
    /// 1 -> "摄像机"
    /// 2 -> "门铃"
    /// 3 -> "室内机"
    public func getDeviceTypeString(deviceModelCategory: Int) -> String {
        /// 暂无数据,暂时写死
        switch deviceModelCategory {
        case 0:
            /// 设备
            return A4xBaseManager.shared.getLocalString(key: "device_type_unknown")
        case 1:
            /// 摄像机
            return A4xBaseManager.shared.getLocalString(key: "device_type_camera")
        case 2:
            /// 门铃
            return A4xBaseManager.shared.getLocalString(key: "device_type_doorbell")
        case 3:
            /// 暂无室内机文案,先写成设备
            return A4xBaseManager.shared.getLocalString(key: "device_type_unknown")
        default:
            /// 默认设备
            return A4xBaseManager.shared.getLocalString(key: "device_type_unknown")
        }
    }
    
    // 根据文章id获取文章地址的方法
    // 调用示例
    // let articleUrl = A4xBaseManager.shared.getArticleUrl(articleId: "132103242342")
    public func getArticleUrl(articleId: String) -> String {
        // https://support.vicoo.tech/hc/zh-cn/articles/6887615596313
        let zendeskHost = A4xAppBuildConfig.getZendeskInfo().zendeskHost ?? "https://support.vicoo.tech"
        // 帮助中心
        let helpCenter = "/hc/"
        // zendesk语言
        let zendeskLanguage = A4xBaseAppLanguageType.language().zendeskValue()
        // 文章
        let articleString = "/articles/"
        // 拼接方式 zendesk域名+帮助中心+语言+文章+文章id
        
        let articleUrl : String = zendeskHost + helpCenter + zendeskLanguage + articleString + articleId
        logDebug("获取到的zendeskUrl是: \(articleUrl)")
        return articleUrl
    }
    
    // 根据后端返回一大串的包含文章id的字符串直接获取文章地址的方法
    // 调用示例
    public func getArticleUrlFromService(articleString: String) -> String {
        // https://support.vicoo.tech/hc/zh-cn/articles/6887615596313
        let zendeskHost = A4xAppBuildConfig.getZendeskInfo().zendeskHost ?? "https://support.vicoo.tech"
        let articleUrl : String = zendeskHost + articleString
        logDebug("根据后端返回的一大串的包含文章id的字符串,获取到的zendeskUrl是: \(articleUrl)")
        let resultString = articleUrl.replacingOccurrences(of: "en-us", with: A4xBaseAppLanguageType.language().zendeskValue())
        logDebug("最终修改后的的zendeskUrl是: \(resultString)")
        return resultString
    }
    
    // 根据类型获取协议链接的方法,返回一个协议链接String
    // 调用示例
    // let termsURL = A4xBaseManager.shared.getAgreementURL(subjectType: .terms)
    public func getAgreementURL(subjectType: A4xAgreementType) -> String {
        
        
        // https://api-us.dzeesja.com/management/app-files/dzeeshome/terms-of-use/cn/index.html
        // 需要对其拼接
        // https://api-us.dzeesja.com
        // 默认先从配置文件里读
        var baseUrl = A4xProjectConfigManager.projectConfig.agreementNodeUrl ?? ""
        
        // 1.先从UserDefault获取agreementNodelUrl
        if let userDefaultBaseUrl = UserDefaults.standard.string(forKey: "A4xAgreementNodeUrl") {
            if !(userDefaultBaseUrl.isBlank) {
                // 如果本地缓存不是空，优先使用本地缓存
                baseUrl = userDefaultBaseUrl
            }
        }
        
        let tenantId = A4xProjectConfigManager.projectConfig.tenantId ?? "tenantId is nil"
        if tenantId.isBlank {
            return ""
        }
        
        var language = ""
        let languageType = A4xBaseAppLanguageType.language()
        if languageType == .chinese {
            language = "cn"
        } else {
            language = languageType.rawValue
        }
        
        // 处理主体类型
        var type = ""
        var typeDes = ""
        switch subjectType {
        case .terms:
            type = "terms-of-use"
            typeDes = "terms"
            break
        case .policy:
            type = "privacy-policy"
            typeDes = "policy"
            break
        case .awareness:
            type = "awareness-service-agreement"
            typeDes = "awareness"
            break
        case .subscription:
            type = "continuous-subscription-service-agreement"
            typeDes = "subscription"
            break
        default:
            break
        }
        // 最终拼接生成的协议连接地址
        let url = baseUrl + "/management/app-files/" + tenantId.lowercased() + "/" + type + "/" + language + "/index.html"
        NSLog("获取到的\(typeDes)协议链接地址是: \(url)")
        return url
    }
    
    
    public func getBindSuccessGuideUrl() -> String {
        return getIndoorUnitUrl(unitType: .bindSuccess)
    }
    
    
    public func getIndoorUnitGuideUrl() -> String {
        return getIndoorUnitUrl(unitType: .indoorUnit)
    }
    
    
    private func getIndoorUnitUrl(unitType: IndoorUnitType) -> String {
        
        var baseUrl = A4xProjectConfigManager.projectConfig.indoorUnitBaseUrl ?? ""
        let projectConfigModel = A4xProjectConfigManager.projectConfig
        return baseUrl + "/\(projectConfigModel.tenantId?.lowercased() ?? "")" + "/\(projectConfigModel.indoorUnitVersion ?? "")" + "/\(A4xBaseAppLanguageType.language().tableValue())" + "/\(unitType.rawValue)"
    }

    
    private enum IndoorUnitType: String {
        case bindSuccess = "root.html"
        case indoorUnit = "IndoorUnit.html"
    }
    
    
    public func getWebviewParams(deviceID: String) -> Dictionary<String, Any> {
        let bundle = Bundle.main.infoDictionary
        let deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceID, modeType: .WiFi) ?? DeviceBean()
        let isDoorbell = deviceModel.isDoorBell() // 是否为门铃设备
        let webParams: Dictionary<String, Any> = [
            "bundle"    : (bundle?["CFBundleIdentifier"] as? String) ?? "bundle is nil",
            "appBuild"  : A4xAppBuildConfig.buildInfo().getBuildEnv().rawValue,
            "appName"   : A4xProjectConfigManager.projectConfig.bundleDisplayName ?? "appName is nil",
            "tenantId"  : A4xProjectConfigManager.projectConfig.tenantId ?? "tenantId is nil",
            "version"   : (bundle?["CFBundleVersion"] as? String) ?? "version is nil",
            "appType"   : "iOS",
            "modelNo"   : deviceModel.modelNo ?? "", // 设备型号
            "token"     :A4xNetManager.engine.getToken() ?? "token is nil",
            "language"  : A4xBaseAppLanguageType.language().rawValue,
            "requestId" : "\(Date().timeIntervalSince1970)".md5(),
            "serialNumber": deviceModel.serialNumber ?? "serialNumber is nil",
            "countryNo" : A4xNetManager.engine.getCountry(),
            
            "supportAutoPowerOn" : String(deviceModel.deviceSupport?.supportChargeAutoPowerOn ?? 0), // 是否支持自动开关机
            "isDoorbell" : isDoorbell ? "1" : "0", // 是否是门铃设备
            "baseUrl"   : A4xAppBuildConfig.loadHost() ?? "baseUrl is nil"
        ]
        return webParams
    }

    public func isRTL() -> Bool {
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            return true
        }
        return false
    }
    
    public func matchStrRange(_ matchStr: String) -> [NSRange] {
        var selfStr : NSString =  NSString()
        var withStr = Array(repeating: "%@", count: (matchStr as NSString).length).joined(separator: "") //辅助字符串
        if matchStr == withStr { withStr = withStr.lowercased() } //临时处理辅助字符串差错
        var allRange = [NSRange]()
        while selfStr.range(of: matchStr).location != NSNotFound {
            let range = selfStr.range(of: matchStr)
            allRange.append(NSRange(location: range.location,length: range.length))
            selfStr = selfStr.replacingCharacters(in: NSMakeRange(range.location, range.length), with: withStr) as NSString
        }
        return allRange
    }
}
