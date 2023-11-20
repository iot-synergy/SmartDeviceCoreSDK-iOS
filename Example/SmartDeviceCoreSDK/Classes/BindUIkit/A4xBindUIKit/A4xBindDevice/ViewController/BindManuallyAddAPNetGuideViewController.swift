//
//  BindManuallyAddAPNetGuideViewController.swift
//  AddxAi
//
//  Created by addx-wjin on 2022/3/15.
//  Copyright © 2022 addx.ai. All rights reserved.
//

import Foundation
import Network
import SmartDeviceCoreSDK
import Resolver
import A4xLiveVideoUIInterface
import BindInterface
import BaseUI

class BindManuallyAddAPNetGuideViewController: BindBaseViewController {
    
    
    
    var needSendBindText: String?
    var operationId: String?
    var apInfoDetailModel: A4xBindAPDeviceInfoModel? // 连接ap和发送tcp消息用
    
    var operationIdArr: [String] = []
    var operationIdStep: Int? = 0
    
    var deviceModel: DeviceBean?
    
    // wait link 计时器
    private var linkApTimeoutTimer: Timer?
    
    // wait link 计时秒数
    private var linkAPLoadingTimerCount : Int = 0
    
    // wait link 计时秒数
    private var linkAPloadingTimerOutCount : Int = 30
    
    private var bindManuallyAddAPNetGuideView: A4xBindManuallyAddAPNetGuideView?
    
    private var isPushNextPage: Bool = false
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        bindManuallyAddAPNetGuideView = A4xBindManuallyAddAPNetGuideView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
        let currentView = bindManuallyAddAPNetGuideView
        currentView?.protocol = self
        self.view.addSubview(currentView!)
        var datas: [String : String] = [:]
        datas["apNetName"] = self.apInfoDetailModel?.ssid
        datas["apNetPwd"] = self.apInfoDetailModel?.password
        currentView!.datas = datas
        weak var weakSelf = self
        currentView?.backClick = {
            if weakSelf?.isAPMode ?? false {
                Resolver.liveUIImpl.pushHotlinkLiveVideoViewController(fromVCType: .apModeBind, navigationViewController: weakSelf?.navigationController)
            } else {
                weakSelf?.navigationController?.popViewController(animated: true)
            }
        }
        
        // 注册切换到前台监听
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        // 注册切换后台监听
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isPushNextPage = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    // 系统wifi设置切换到当前app
    @objc func didBecomeActive() {
        if self.isAPMode ?? false {
            if self.deviceModel?.getAPInfoModel() != nil {
                if checkSSID(ssid: self.deviceModel?.getAPInfoModel()?.ssid ?? "") {
                    self.view.makeToastActivity(title: "loading") { (f) in }
                    self.websocketReConnect(host: self.deviceModel?.getAPInfoModel()?.asideServerIp)
                } else {
                    if #available(iOS 12.0, *) {
                        BindCore.getInstance().startBindByApDirect(bindDeviceModel: self.selectedBindDeviceModel)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        } else {
            if self.selectedBindDeviceModel != nil {
                if checkSSID(ssid: self.apInfoDetailModel?.ssid ?? "") {
                    self.view.makeToastActivity(title: "loading") { (f) in }
                    if #available(iOS 12.0, *) {
                        self.viewModel?.sendTCPMsg(host: apInfoDetailModel?.asideServerIp ?? "192.168.1.2", port: apInfoDetailModel?.asideServerPort ?? "23450", sendTxt: self.needSendBindText ?? "")
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
        
        func checkSSID(ssid: String) -> Bool {
            if A4xBaseNetworkIotManager.share.getSSID() == ssid {
                return true
            } else {
                return false
            }
        }
    }
    
    // 系统切换到后台
    @objc func applicationEnterBackground() {
        
    }
    
    override func onSuccess(code: Int, msg: String?, serialNumber: String?) {
        Resolver.liveUIImpl.pushHotlinkLiveVideoViewController(fromVCType: .apModeBind, navigationViewController: self.navigationController)
    }
    
    private func jumpToBindConnectWaitViewController() {
        self.view.hideToastActivity(block: { })
        
        if isPushNextPage {
            return
        }
        isPushNextPage = true
        
        let vc = BindConnectWaitViewController()
        vc.serialNumber = self.selectedBindDeviceModel?.serialNumber
        vc.fromManuallyAP = true
        vc.currentStep = 2
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func websocketReConnect(host: String? = "192.168.1.2") {
        let userid = A4xUserDataHandle.Handle?.loginModel?.id
        DispatchQueue.main.a4xAfter(3) {
            DeviceSettingCore.getInstance().getApDeviceInfo(serialNumber: self.deviceModel?.serialNumber ?? "") {[weak self] code, apModel, message in
                onMainThread {
                    Resolver.liveUIImpl.pushHotlinkLiveVideoViewController(fromVCType: .apModeBind, navigationViewController: self?.navigationController)
                }
            } onError: {code, message in
                logDebug("-----------> GET_INFO failed")
            }
        }
    }
}

extension BindManuallyAddAPNetGuideViewController: A4xBindManuallyAddAPNetGuideViewProtocol {
   
    func noFindNetLblClick() {
        // 跳转到配网引导页
        let vc = BindReSetGuideViewController()
        vc.sourceFromEnum = 2
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func nextActionToSysSetting() {
        self.jumpSysSetting()
    }
    
    // 系统设置
    func jumpSysSetting() {
        // open安全接口
        // if let url = URL(string: UIApplication.openSettingsURLString) {
        //     UIApplication.shared.open(url, options: [:], completionHandler: nil)
        // }
        let data = Data(bytes: [0x41,0x70,0x70,0x2d,0x50,0x72,0x65,0x66,0x73,0x3a,0x72,0x6f,0x6f,0x74])
        let setUrl = String.init(data: data, encoding: String.Encoding.utf8)
        // 跳转出去，设置正常类型
        //self.getWifiResType = .normal
        // 跳转出去，设置离开为true
        //self.leaveFromJumpSysSet = true
        // 跳转到系统设置
        if let url = URL(string: setUrl ?? UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}

// 计时器相关
extension BindManuallyAddAPNetGuideViewController {
    
    // 开始计时
    private func linkAPStartTimer(isContinue: Bool = false) {
        if linkApTimeoutTimer != nil {
            linkApTimeoutTimer?.invalidate()
            linkApTimeoutTimer = nil
        }
        
        if !isContinue {
            linkAPLoadingTimerCount = 0
        }
        linkApTimeoutTimer = Timer(timeInterval: 1, target: self, selector: #selector(linkAPLoadingTime), userInfo: nil, repeats: true)
        RunLoop.current.add(linkApTimeoutTimer!, forMode: .common)
        linkApTimeoutTimer?.fire()
    }
    
    // 停止计时
    private func linkAPStopTimer() {
        linkApTimeoutTimer?.invalidate()
        linkApTimeoutTimer = nil
    }
    
    // 计时中
    @objc private func linkAPLoadingTime() {
        logDebug("---------> ap manually add loadingTimerCount: \(linkAPLoadingTimerCount)")
        if linkAPLoadingTimerCount <= linkAPloadingTimerOutCount {
            linkAPLoadingTimerCount += 1
            return
        }
        
        if linkAPLoadingTimerCount == linkAPloadingTimerOutCount + 1 {
            self.view.hideToastActivity(block: { })
        }
        
        // 停止计时
        linkAPStopTimer()
    }
    
    private func checkLinkAPTimeOut() -> Bool {
        return linkAPLoadingTimerCount > linkAPloadingTimerOutCount
    }
}

