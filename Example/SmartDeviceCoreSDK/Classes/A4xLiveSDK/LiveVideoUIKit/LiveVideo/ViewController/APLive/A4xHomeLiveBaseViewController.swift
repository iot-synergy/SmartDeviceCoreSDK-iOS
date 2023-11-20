//
//  A4xHomeLiveBaseViewController.swift
//  A4xLiveVideoUIKit
//
//  Created by huafeng on 2023/4/27.
//

import Foundation
import SmartDeviceCoreSDK
import BaseUI
import A4xLiveVideoUIInterface
import Resolver

enum A4xDisturbActionType {
    case cancle
    case t_30min
    case t_2h
    case t_12h
    
    func intValue() -> Int {
        switch self {
        case .cancle:
            return -1
        case .t_30min:
            return 30 * 60
        case .t_2h:
            return 2 * 60 * 60
        case .t_12h:
            return 12 * 60 * 60
        }
    }
}

// 存放 A4xHomeLiveVideoViewController 和 A4xHomeLiveVideoViewController_Theme1 共同的业务逻辑
public class A4xHomeLiveBaseViewController: A4xHomeBaseViewController, A4xHomeLiveVideoVCProtocol {
    
    // 当前VC的VM对象
    public let liveVideoViewModel: A4xLiveVideoViewModel = A4xLiveVideoViewModel()
    
    public let group = DispatchGroup()
    
    public let queue = DispatchQueue(label: "A4xHomeLiveVideoVC.list.request")
    
    // 创建一个并发队列
    public let concurrentQueue = DispatchQueue(label: "A4xHomeLiveVideoViewController.concurrentLockQueue", attributes: .concurrent)
    
    // 创建一个条件锁
    public let conditionLock = NSConditionLock(condition: 2)
    
    public var reloadDataCount = 0
   
    // 四分屏最大播放数量
    public let splitMaxCount: Int = 4
    // git图片单例
    public let gifManager = A4xBaseGifManager(memoryLimit: 60)
    
    // 设备筛选view
    //private var deviceFilterDropdownView: A4xHomeDeviceFilterDropdownView?
    
    // 错误代理写法 - 强耦合 - 跨层调用 - 需优化
    //private var deviceFilterProtocol: A4xHomeDeviceFilterDropdownViewProtocol?
    
    public var fullVideoSelIndexPath: IndexPath? // 全屏播放的直播下标
    
    public var popMenu: A4xBasePopMenuView! // 绑定菜单

    public var homeMoveTrackAlertBGView: UIView! //
    
    public var moveTrackfirstGuideModel: DeviceBean? // 运动追踪人形追踪首次引导
    
    public var currentLiveDeviceModel: DeviceBean? // 当前正在播放的竖屏设备，只能播放一个设备
    
    public var showImageAnimailRow: Int = -1
    
    // cell 类型 - 切换菜单样式有关
    public var cellTypes: [A4xVideoCellType] = []
    
    public var cellInfos: [A4xHomeLiveVideoCollectCellEnum]? = [.normalMode]
    
    // 列表数据源
    public var dataSource: [DeviceBean]? {
        return self.getCacheDeviceList()
    }
    
    // 获取本地数据源
    private func getCacheDeviceList() -> [DeviceBean]? {
        var allDataSource: [DeviceBean] = A4xUserDataHandle.Handle?.devicesFilter(filter: true, filterType: A4xUserDataHandle.Handle?.locationType ?? .all) ?? []
        self.cellInfos = A4xHomeLiveVideoCollectCellEnum.allCase()
        return allDataSource
    }
    
    public var VCView: UIView {
        get {
            return self.view
        }
    }
    
    
    
    
    
    @objc public required init(nav: UINavigationController?) {
        super.init(nav: nav)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 停止所有直播
    public func stopLiveAll(skipDeviceId: String?, reason: A4xPlayerStopReason, isAPMode: Bool = false) {
        liveVideoViewModel.stopAllLive(skipDeviceId: skipDeviceId ?? "", customParam: ["stopReason" : "\(reason.keyString())", "isAPMode" : isAPMode])
    }
    
    // 检查APMode数据上报云端
    public func checkAPModeDataSourceUpload() {
        logDebug("-----------> checkAPModeDataSourceUpload func")
        
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            return
        }
        
        // 判断是否有APMode的数据
        // 有APMode的数据且未上报，则上报后端
        // 有APMode的数据且已上报，则不做处理
        // 没有查到本地有AP数据，则不做处理
        var deviceAPModels = A4xUserDataHandle.Handle?.deviceAPModels
        if (deviceAPModels?.count ?? 0) > 0 {
            var uploadList: [A4xDeviceRequestModel] = []
            var needDelIds: [String] = []
            var needDelIndexs: [Int] = []
            for i in 0..<(deviceAPModels?.count ?? 0) {
                if deviceAPModels?[i].apModeUpload == 0 {
                    var uploadData = A4xDeviceRequestModel()
                    uploadData.deviceName = deviceAPModels?[i].deviceName
                    uploadData.serialNumber = deviceAPModels?[i].serialNumber
                    uploadData.userSn = deviceAPModels?[i].userSn
                    uploadData.firmwareId = deviceAPModels?[i].firmwareId
                    uploadData.batteryLevel = deviceAPModels?[i].batteryLevel
                    uploadData.isCharging = deviceAPModels?[i].isCharging
                    uploadData.language = deviceAPModels?[i].deviceLanguage
                    uploadData.timeZone = deviceAPModels?[i].timeZone
                    let apInfo = deviceAPModels?[i].bindDeviceModel?.apInfo
                    deviceAPModels?[i].apInfo = apInfo
                    uploadData.settings = deviceAPModels?[i].toJson()
                    let timeInterval: TimeInterval = Date().timeIntervalSince1970
                    uploadData.lastAct = Int(timeInterval)
                    uploadList.append(uploadData)
                } else if deviceAPModels?[i].apModeDelState == 1 {
                    needDelIds.append(deviceAPModels?[i].serialNumber ?? "")
                    needDelIndexs.append(i)
                }
            }
            
            // 有需要上传云端
            if uploadList.count > 0 {
                A4xBaseDeviceSettingInterface.shared.uploadApDeviceList(list: uploadList) { code, message, result in
                    if code == 0 {
                        logDebug("-----------> uploadApDeviceList success")
                        if (deviceAPModels?.count ?? 0) > 0 {
                            for i in 0..<(deviceAPModels?.count ?? 0) {
                                var model = deviceAPModels?[i]
                                model?.apModeUpload = 1
                                deviceAPModels?[i] = model ?? DeviceBean()
                            }
                            A4xUserDataHandle.Handle?.deviceAPModels = deviceAPModels
                        }
                    }
                }
            }
            
            // 有需要删除云端
            if needDelIds.count > 0 {
                A4xBaseDeviceSettingInterface.shared.delApDeviceList(deviceIds: needDelIds, comple: { code, message, result in
                    if code == 0 {
                        logDebug("-----------> delApDeviceList success")
                        if (deviceAPModels?.count ?? 0) > 0 {
                            for i in (0..<needDelIndexs.count).reversed() { // 倒序删除 - i从大到小删除
                                // 有奔溃 Fatal error: Index out of range
                                if (A4xUserDataHandle.Handle?.deviceAPModels?.count ?? -1) >= i {
                                    A4xUserDataHandle.Handle?.deviceAPModels?.remove(at: i)
                                }
                            }
                        }
                    }
                })
            }
            
        }
    }
    
    public func showToAPPageAlert() {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.Theme
        config.rightTextColor = UIColor.white
        weak var weakSelf = self
        
        let alert = A4xBaseAlertView(param: config, identifier: "showToAPPageAlert")
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        alert.message = A4xBaseManager.shared.getLocalString(key: "home_hotspot_connect", param: [tempString])
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
        alert.leftButtonBlock = {
            
        }
        
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "home_viewdevice")
        alert.rightButtonBlock = {
            weakSelf?.stopLiveAll(skipDeviceId: nil, reason: A4xPlayerStopReason.changePage)
            let vc = A4xHotlinkLiveVideoViewController(nav: self.navigationController)
            weakSelf?.navigationController?.pushViewController(vc, animated: true)
        }
        
        alert.show()
    }
    
    public func checkShow4GAlert(device: DeviceBean?, comple: @escaping (Bool)->Void) {
        if device?.apModeType == .AP {
            comple(true)
            return
        }
        if A4xUserDataHandle.Handle?.isShow4GNet ?? false {
            comple(true)
            return
        }
        
        guard A4xUserDataHandle.Handle?.netConnectType == .wwan else {
            comple(true)
            return
        }
        
        UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "pay_attention_data"))
        A4xUserDataHandle.Handle?.isShow4GNet = true
        comple(true)
    }
}
