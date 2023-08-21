//
//  A4xHomeLiveThemeViewController.swift
//  AddxAi
//
//  Created by demo on 2023/4/27.
//  Copyright © 2023 addx.ai. All rights reserved.
//

import Foundation
import SmartDeviceCoreSDK

// 直播首页点击 Cell的信封标签，跳到 相册首页
public typealias HomeLive2HomeLibraryCallBack = ((IndexPath, DeviceBean?) -> Void)

public protocol A4xHomeLiveThemeViewController: UIViewController {
    
    var homeLive2HomeLibraryCallBack: HomeLive2HomeLibraryCallBack? { get set }
    
}
