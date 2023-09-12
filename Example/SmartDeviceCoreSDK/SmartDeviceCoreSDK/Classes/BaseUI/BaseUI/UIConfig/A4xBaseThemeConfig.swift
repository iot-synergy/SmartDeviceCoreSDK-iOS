//
//  A4xBaseThemeConfig.swift
//  AddxAi
//
//  Created by 郭建恒 on 2022/7/19.
//  Copyright © 2022 addx.ai. All rights reserved.
//

import UIKit
import SmartDeviceCoreSDK

/// 支付套餐名字，如果是HG则直接返回后端的tierName字段，其他都根据tierID去取值
@objc public enum A4xSDKPayType: Int {
    /// 默认
    case `Default`      = 0
    /// OEM
    case OEM_HG = 1
}

/// 主体变更协议类型
@objc public enum A4xAgreementType: Int {
    /// terms 条款
    case terms        = 0
    /// policy 隐私政策
    case policy       = 1
    /// awareness
    case awareness    = 2
    /// awareness 订阅
    case subscription = 3
}

public class A4xBaseThemeConfig: NSObject {

    @objc public static let shared = A4xBaseThemeConfig()
    
    @objc public var sdkPayType : A4xSDKPayType = .Default
    
    /// 设置绑定支持Wi-Fi 或 有线
    ///  0,默认支持Wi-Fi 和 有线；1，仅支持Wi-Fi；2，仅支持有线
    @objc public func supportBindType() -> Int {
        let res = A4xProjectConfigManager.projectConfig.bindSupportNetType
        return res ?? 0
    }
  
    /// 设置绑定支持常电 或 低功耗
    ///  0,默认支持常电和低功耗；1，仅支持低功耗；2，仅支持常电
    @objc public func supportDeviceType() -> Int {
        let res = A4xProjectConfigManager.projectConfig.bindSupportEnergyType
        return res ?? 0
    }
    
    /// 用户设置页 -- 顶部主题色对应的tenantId
    @objc public var userSettingTopThemeColorTenantIds: [String] = ["homeguardsmart"]
    
    /// A4xUserVipDetailViewController页面用于判断是单设备维度、用户维度
    @objc public var payDetailDesByDevice: [String] = ["homeguardsmart"]
    
    /// OEM App FAQ List
    @objc public var faqList:[String : String] = [
        "itroncam":"https://faq.itroncam.com/nz/en/articles001",
        "shenmou":"https://faq.superacme.com/faq/public/"
    ]
    
    /// OEM Login Header BgPic
    @objc public var OEMList:[String : String] = [
        // 绿色
        "vicoo":"greenLoginHeader",
        // 黄色
        "monkeyvision":"yellowLoginHeader",
        // 蓝色
        "bestsee":"blueLoginHeader",
        "uniarchlife":"blueLoginHeader",
        "itroncam":"blueLoginHeader",
        "rscamera":"blueLoginHeader",
        // 红色
        "dzeesHome":"redLoginHeader",
        "provisionhome":"redLoginHeader",
        "cyberviewPlus":"redLoginHeader",
        "hthome":"redLoginHeader",
        // 黄绿色
        "ismart":"yellowGreenLoginHeader",
        "homeguardsmart":"yellowGreenLoginHeader",
        // 蓝紫色
        "shenmou":"bluePurpleLoginHeader",
        "anlife":"bluePurpleLoginHeader",
        
//        jxja,soliom,netvue,askari,guard,verbatim
    ]
    
    /// App仅在国内上线的tenantIds,不支持苹果的Voice-Over-Time-Protocal
    @objc public var supportArray_CN : [String] = ["guard", "shenmou", "juziyouzi"]
    
    // 获取是否支持国内App
    @objc public func supportCN() -> Bool {
        return A4xBaseThemeConfig.shared.supportArray_CN.contains(A4xProjectConfigManager.projectConfig.tenantId ?? "vicoo") == true
    }
    
}
