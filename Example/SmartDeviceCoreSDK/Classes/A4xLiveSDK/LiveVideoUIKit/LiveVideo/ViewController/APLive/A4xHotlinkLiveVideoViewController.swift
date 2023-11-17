//
//  A4xHotlinkLiveVideoViewController.swift
//  AddxAi
//
//  Created by 积加 on 2022/3/23.
//  Copyright © 2022 addx.ai. All rights reserved.
//

import UIKit

import MJRefresh
import SmartDeviceCoreSDK
import Resolver
import BindInterface
import A4xDeviceSettingInterface
import BaseUI
import A4xLiveVideoUIInterface

public class A4xHotlinkLiveVideoViewController: A4xHomeLiveBaseViewController {
    
    public var fromVCType: FromViewControllerEnum?
    
    open override var dataSource: [DeviceBean]? {
        return A4xUserDataHandle.Handle?.devicesFilter(filter: true, filterType: .aplist) ?? []
    }
    
    private func collectViewReloadData(code: Int, error: String?) {
        logDebug("-----------> reloadData error: \(error ?? "is nil")")
        guard isNavigationTopVC else {
            logDebug("-----------> reloadData isTop return")
            return
        }

        if dataSource != nil && dataSource!.count > 0 {
            // 数据不为空
            collectView.hiddNoDataView()
        } else {
            // 数据为空
            if code != 0 {
                weak var weakSelf = self
                // 警告不生效
                guard (weakSelf?.collectView.showNoDataView(value: A4xBaseNoDataValueModel.error(error: error, comple: {
                    weakSelf?.collectView.mj_header?.beginRefreshing()
                }))) != nil else { return }
            } else {
                collectView.hiddNoDataView()
            }
        }
        
        logDebug("-----------> reloadData collectView.reloadData()")
        
        self.collectView.collectionViewLayout.invalidateLayout()
        // 刷新列表数据
        self.collectView.reloadData()
    }
    
    lazy var collectionLayout: A4xHomeLiveVideoCollectLayout = {
        let temp = A4xHomeLiveVideoCollectLayout(delegate: self)
        return temp
    }()
    
    lazy var collectView: UICollectionView = {
        let temp = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionLayout)
        temp.dataSource = self
        temp.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10.auto(), right: 0)
        temp.delegate = self
        temp.clipsToBounds = false
        temp.backgroundColor = .clear
        temp.register(A4xHomeLiveVideoCollectCell.self, forCellWithReuseIdentifier: "A4xHomeLiveVideoCollectCell")
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints({ make in
            make.top.equalTo(UIScreen.navBarHeight)
            make.leading.equalTo(self.view.snp.leading)
            make.width.equalTo(self.view.snp.width)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        return temp
    }()
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logDebug("-----------> viewDidAppear func")
        // 禁止侧滑
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
//        checkAPModeDataSourceUpload()
        
        // 不在刷新中 - 执行此逻辑 - 页面切换逻辑
        if !(collectView.mj_header?.isRefreshing ?? true) {
            reloadCellTypes()
            collectViewReloadData(code: 0, error: nil)
        }
        
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        logDebug("-----------> viewDidLoad func")
        view.backgroundColor = ADTheme.C6
        
        collectView.isHidden = false
        
        defaultNav()
        
        // 设置直播默认样式
        A4xUserDataHandle.Handle?.videoStyle = .default

        weak var weakSelf = self
//        collectView.mj_header = A4xMJRefreshHeader {
//            // 首页下拉列表刷新处理
//            A4xBaseDeviceSettingInterface.shared.getApDeviceList { (code, err, models) in
//                weakSelf?.collectView.mj_header?.endRefreshing()
//                // 停止所有直播
//                self.stopLiveAll(skipDeviceId: nil, reason: .pull, isAPMode: true)
//                
//                // 更新最新封面图
//                self.liveVideoViewModel.updateAllScreenShot(customParam: ["isAPMode" : true]) { [weak weakSelf] deviceID in
//                    if !deviceID.isBlank {
//                        weakSelf?.reloadCellWithDeviceId(deviceID: deviceID)
//                    } else {
//                        weakSelf?.collectViewReloadData(code: code, error: err)
//                    }
//                }
//            }
//        }
        
        if !(collectView.mj_header?.isRefreshing ?? true) {
            collectView.mj_header?.beginRefreshing()
        }
        
        // 注册语言切换通知
        initLanguageChangeNotification()
        
        // 注册进入后台
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // 注册进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(enterActiveGround), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        A4xUserDataHandle.Handle?.addDeviceUpdateListen(targer: self)
        A4xUserDataHandle.Handle?.addAccountChange(targer: self)
        
    }
    
    override public func defaultNav() {
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftBtn?.isHidden = false
        navView?.backgroundColor = ADTheme.C6
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "home_device_hotspot")
        weak var weakSelf = self
        self.navView?.leftClickBlock = {
            weakSelf?.backClick()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    
        // 移除Wi-Fi监听
        A4xUserDataHandle.Handle?.removeWifiChangeProtocol(target: self)
        // 移除账号监听
        A4xUserDataHandle.Handle?.removeAccountChangeProtocol(target: self)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 注册Wi-Fi监听
        A4xUserDataHandle.Handle?.addWifiChange(targer: self)
    }
    
    // 进入到后台
    @objc func enterBackGround() {
        logDebug("-----------> HotlinkLiveVideo enterBackGround")
    }
    
    // 进入到前台
    @objc func enterActiveGround() {
        logDebug("-----------> HotlinkLiveVideo enterActiveGround")
    }
    
    // 切换语言处理
    private func initLanguageChangeNotification() {
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: LanguageChangeNotificationKey, object: nil, queue: OperationQueue.main) { _ in
            
            // 更新列表数据 - v3.1 by wjin
            A4xBaseDeviceSettingInterface.shared.getApDeviceList { (code, err, models) in
                // 刷新数据
                weakSelf?.collectViewReloadData(code: code, error: err)
            }
        }
    }
    
    private func reloadCellWithDeviceId(deviceID: String) {
        
        guard !deviceID.isEmpty else {
            return
        }
        
        var reloadindex: Int? = nil
        for index in 0..<(self.dataSource?.count ?? 0) {
            if let deviceModle = self.dataSource?[index] {
                if deviceModle.serialNumber == deviceID {
                    reloadindex = index
                }
            }
        }
        
        guard let index = reloadindex else {
            return
        }
        
        showImageAnimailRow = index
        
        self.collectViewReloadData(code: 0, error: nil)
    }
    
    @objc func deviceListChange(noti: NSNotification) {
        DispatchQueue.main.async {
            self.collectView.mj_header?.beginRefreshing()
        }
    }
    
    private func backClick() {
        
        if A4xWebSocketMessageTool.shared.haveAPDeviceOnline() {
            var config = A4xBaseAlertAnimailConfig()
            config.leftbtnBgColor = UIColor.white
            config.leftTitleColor = UIColor.colorFromHex("#2F3742")
            
            config.rightbtnBgColor = UIColor.white
            config.rightTextColor = ADTheme.Theme
            config.messageColor = UIColor.colorFromHex("#2F3742")
            
            let alert = A4xBaseAlertView(param: config, identifier: "back click")
            alert.message = A4xBaseManager.shared.getLocalString(key: "home_back_hotspot")
            alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
            alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "ok")
            alert.rightButtonBlock = {
                let _ = A4xBaseNetworkIotManager.share.disconnect()
                backAction()
            }
            alert.show()
        } else {
            backAction()
        }
        
        func backAction() {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        logDebug("-----> A4xHotlinkLiveVideoViewController deinit")
    }
}

// MARK: - 连接ap
extension A4xHotlinkLiveVideoViewController {
    
    // 连接设备
    private func loginDevice() {
        if self.currentLiveDeviceModel?.getAPInfoModel() != nil {
            weak var weakSelf = self
            // ApConnectCore的方法都建立在已经绑定Ap设备成功的基础上
            // 如果AP设备未绑定,本地不会缓存Ap设备相关的Ap信息,调用ApConnectCore接口就会失败
            let isConnectAp = ApConnectCore.getInstance().isConnectAp(serialNumber: self.currentLiveDeviceModel?.serialNumber ?? "")
            if isConnectAp {
                self.getApDeviceInfo()
            } else {
                // AP 未连接
                if #available(iOS 12.0, *) {
                    // connect ap
                    ApConnectCore.getInstance().connectAp(serialNumber: self.currentLiveDeviceModel?.serialNumber ?? "") { code, message in
                        weakSelf?.getApDeviceInfo()
                    } onError: { code, message in
                        
                    }
                } else {

                }
            }
        }
    }
    
    
    // 重连websocket
    private func getApDeviceInfo() {
        let userid = A4xUserDataHandle.Handle?.loginModel?.id
        DispatchQueue.main.a4xAfter(3) {
            
            DeviceSettingCore.getInstance().getApDeviceInfo(serialNumber: self.currentLiveDeviceModel?.serialNumber ?? "") {[weak self] code, apModel, message in
                onMainThread {
                    self?.collectViewReloadData(code: 0, error: nil)
                }
            } onError: {[weak self] code, message in
                UIApplication.shared.keyWindow?.makeToast("GET_INFO failed")
                self?.view.hideToastActivity(block: { })
            }
        }
    }
    
    
    
}

// MARK: -  UICollection delegate

extension A4xHotlinkLiveVideoViewController: A4xHomeVideoCellContentProtocol, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: A4xHomeVideoCellContentProtocol - 凹
    func getCellHeight(forRow row: Int, itemWidth: CGFloat) -> CGFloat {
        let currentCellType: A4xVideoCellType = .default
        let viewType: A4xVideoCellType = self.cellTypes.getIndex(row) ?? currentCellType
        return A4xHomeLiveVideoCollectCell.heightForDevice(type: viewType, itemWidth: itemWidth, deviceModel: self.dataSource?.getIndex(row))
    }
    
    func getDefaultCellType(rowIndex: Int) -> A4xVideoCellType {
        let currentCellType: A4xVideoCellType = .default
        var viewType: A4xVideoCellType = self.cellTypes.getIndex(rowIndex) ?? currentCellType
        
        if let deviceModle = dataSource?.getIndex(rowIndex) {
            if let state = self.liveVideoViewModel.getLiveState(deviceId: deviceModle.serialNumber ?? "", customParam: ["isAPMode" : true]) {
                if state == A4xPlayerStateType.playing.rawValue {
                    if viewType == .default {
                        viewType = .playControl(isShowMore: false)
                    }
                } else {
                    viewType = .default
                }
                updateCellType(type: viewType, rowIndex: rowIndex)
            }
        }
        return viewType
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (dataSource?.count ?? 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell: A4xHomeLiveVideoCollectCell = collectionView.dequeueReusableCell(withReuseIdentifier: "A4xHomeLiveVideoCollectCell", for: indexPath) as! A4xHomeLiveVideoCollectCell
        
        if self.showImageAnimailRow == indexPath.row {
            cell.showChangeAnilmail(true)
            self.showImageAnimailRow = -1
        } else {
            cell.showChangeAnilmail(false)
        }
        
        let data = dataSource?.getIndex(indexPath.row)
        logDebug("-----------> collectionView cell create sn: \(data?.serialNumber ?? "")")
        
        //NSLog("声音是否置灰: \(data?.liveAudioToggleOn)")
        cell.indexPath = indexPath
        cell.videoStyle = cellTypes.getIndex(indexPath.row) ?? .default
        cell.protocol = self
        
        // 竖屏运动追踪状态图标
        let isTrackingOpen = liveVideoViewModel.isTrackingOpen(deviceId: data?.serialNumber ?? "")
        
        // 是否为用户自己设备
        let isFollowAdmin = data?.isAdmin() ?? false
        
        // 预设位置信息
        let presetListData = liveVideoViewModel.presetModelBy(deviceId: data?.serialNumber ?? "")
        
        var dataDic: [String : Any] = [:]
        dataDic["isTrackingOpen"] = isTrackingOpen
        dataDic["isFollowAdmin"] = isFollowAdmin
        dataDic["presetListData"] = presetListData
        
        cell.dataDic = dataDic
        cell.dataSource = data
        
        // cell 点击事件处理
        weak var weakSelf = self
        cell.autoFollowBlock = { deviceModel, follow, comple in
            weakSelf?.deviceFllowAction(deviceModel: deviceModel, enable: follow, comple: comple)
        }
        
        cell.itemliveStartBlock = { [weak self] model in
            self?.currentLiveDeviceModel = model
        }
        
        cell.liveStateChangeBlock = { [weak self] deviceModel, stateCode in
            if let state = A4xPlayerStateType(rawValue: stateCode) {
                self?.liveStateChange(state: state, deviceId: deviceModel?.serialNumber ?? "")
            }
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //全屏切半屏后定位到切之前的位置
        if fullVideoSelIndexPath != nil {
            collectView.scrollToItem(at: fullVideoSelIndexPath ?? IndexPath(row: 0, section: 0), at: .top, animated: true)
            fullVideoSelIndexPath = nil
        }
    }
    
    // 更新对应index的cell的显示类型
    private func updateCellType(type: A4xVideoCellType, rowIndex: Int) {
        if self.cellTypes.count != self.dataSource?.count {
            reloadCellTypes()
        }
        
        guard rowIndex < cellTypes.count  else {
            return
        }
        
        cellTypes[rowIndex] = type
    }
    
    // 根据直播状态，设置cell展示样式 - 枚举类型
    private func reloadCellTypes() {
        // 移除所有样式
        cellTypes.removeAll()
        
        let count  = self.dataSource?.count ?? 0
        guard count > 0 else {
            return
        }
        
        // 非四分屏
        var types = Array(repeating: A4xVideoCellType.default, count: count)
        for index in 0..<count {
            if let device = self.dataSource?.getIndex(index) {
                // 初始化 竖屏包含对所有直播实例的实例化
                if A4xPlayerStateType.playing.rawValue == liveVideoViewModel.getLiveState(deviceId: device.serialNumber ?? "", customParam: ["isAPMode" : true]) {
                    types[index] = .playControl(isShowMore: false)
                }
            }
        }
        cellTypes = types
    }

    // 运动追踪设置
    private func deviceFllowAction(deviceModel: DeviceBean?, enable: Bool, comple: @escaping (Bool) -> Void) {
        weak var weakSelf = self
        liveVideoViewModel.updateMotionTrackStatus(deviceId: deviceModel?.serialNumber ?? "", enable: enable) { error in
            if error != nil {
                weakSelf?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "request_timeout_and_try"))
            }
            comple(error == nil)
        }
    }

    private func deviceAtIndex(deviceId: String?) -> (Int, DeviceBean?) {
        if let allSource = dataSource, let devid = deviceId {
            for index in 0 ..< allSource.count {
                let modle = allSource[index]
                if modle.serialNumber == devid {
                    return (index, modle)
                }
            }
        }
        return (-1, nil)
    }
}

extension A4xHotlinkLiveVideoViewController: A4xHomeLiveVideoCollectCellProtocol {
    func liveStateChange(state: A4xPlayerStateType, deviceId: String) {
        logDebug("-----------> live liveStateChange func state: \(state) deviceId: \(deviceId)")
        guard isNavigationTopVC else {
            logDebug("-----------> live liveStateChange isTop return")
            return
        }
        
        let (index, deviceModel) = deviceAtIndex(deviceId: deviceId)
        
        // 在当前作用域(并不仅限于函数)结束时执行
        defer {
            collectViewReloadData(code: 0, error: nil)
            if state == .playing {
                if fullVideoSelIndexPath == nil {
                    collectView.scrollToItem(at: IndexPath(row: index, section: 0), at: .top, animated: true)
                }
            }
        }
        
        
        if A4xUserDataHandle.Handle?.videoStyle == .split || index < 0 {
            logDebug("-----------> live liveStateChange index < 0 return")
            return
        }
        
        var currentType = cellTypes.getIndex(index) ?? .default
        weak var weakSelf = self
        if state == .playing {
            if currentType != .playControl(isShowMore: false) {
                currentType = .playControl(isShowMore: false)
            }
            
            liveVideoViewModel.searchAllPresetPosition(deviceModel: deviceModel) { error in
                weakSelf?.collectViewReloadData(code: 0, error: nil)
            }
        } else {
            if currentType != .default {
                currentType = .default
            }
        }
        
        self.updateCellType(type: currentType, rowIndex: index)
    }
    
    // 设备设置
    func deviceSetting(device: DeviceBean?, subPage: String?) {
        
        if device?.apModeType == .AP {
            
            if subPage == "apModeGuide" {
                currentLiveDeviceModel = device
                self.loginDevice()
                return
            }
            
            self.stopLiveAll(skipDeviceId: nil, reason: .changePage, isAPMode: true)
            
            if subPage == "sdVideo" {
                Resolver.deviceSettingImpl.pushSDVideoHistoryViewController(deviceModel: device, navigationController: navigationController)
                return
            }
        }
        
        self.stopLiveAll(skipDeviceId: nil, reason: .changePage, isAPMode: true)
        
        // to setting
        Resolver.deviceSettingImpl.pushDevicesSettingViewController(deviceModel: device, fromType: .default, navigationController: navigationController)

    }
    
    // 设备唤醒处理
    func deviceSleepToWakeUp(device: DeviceBean?) {}
    func deviceRecordList(indexPath: IndexPath, device: DeviceBean?) {}
    // 设备信息设置
    func deviceOTAAction(device: DeviceBean?, state: String?, clickState: LiveOtaActionType?) {}
    // 设备分享给用户
    func deviceShareToUser(device: DeviceBean?) {}
    // 上报log到S3
    func videoReportLogAction(device: DeviceBean?) {}
    func videoRefreshUI(device: DeviceBean?, isRefreshAll: Bool) {
        if isRefreshAll {
            self.collectView.mj_header?.beginRefreshing()
            return
        }
        guard let devId = device?.serialNumber else {
            return
        }
        A4xUserDataHandle.Handle?.updateDevice(device: device)
        collectViewReloadData(code: 0, error: nil)
    }
    
    // 跳转到全屏直播 凸
    func videoControlFull(device: DeviceBean?, indexPath: IndexPath?) {
        if device == nil {
            return
        }
        self.stopLiveAll(skipDeviceId: device?.serialNumber ?? "", reason: .changePage, isAPMode: true)
        let vc = A4xFullLiveVideoViewController()
        vc.delegate = self
        vc.dataSource = device
        vc.liveVideoViewModel = liveVideoViewModel
        vc.currentIndexPath = indexPath
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //
    func deviceCellModelUpdate(device: DeviceBean?, type: A4xVideoCellType, indexPath: IndexPath?) {
        self.updateCellType(type: type, rowIndex: indexPath?.row ?? 0)
        self.collectViewReloadData(code: 0, error: nil)
    }
    
    /// 首页声音按钮置灰功能
    func muteVoiceGoSoundSetting(deviceModel: DeviceBean?) {
        self.stopLiveAll(skipDeviceId: nil, reason: .changePage, isAPMode: true)
        Resolver.deviceSettingImpl.pushDevicesSoundViewController(deviceModel: deviceModel ?? DeviceBean(serialNumber: deviceModel?.serialNumber ?? ""), navigationController: self.navigationController)
    }
    
}

// MARK: - UserDevicesChangeProtocol , A4xUserDataHandleWifiProtocol
extension A4xHotlinkLiveVideoViewController: UserDevicesChangeProtocol, A4xUserDataHandleWifiProtocol, A4xUserDataHandleAccountProtocol {
    public func userLogout() {}
    public func onLoginInfoChanged(newUserId: Int64) {}
    public func wifiInfoUpdate(status: A4xReaStatus) {}
    public func userDevicesChange(status: A4xDeviceChange) {}
}

// MARK: - ViewController handle
extension A4xHotlinkLiveVideoViewController: A4xFullLiveVideoViewControllerDelegate {
    // 接收 A4xFullLiveVideoViewController 消息处理 凹
    func didFinishViewController(controller: UIViewController, currentIndexPath: IndexPath) {
        logDebug("-------------> didFinishViewController")
        controller.navigationController?.popViewController(animated: true)
        self.fullVideoSelIndexPath = currentIndexPath
    }
}

