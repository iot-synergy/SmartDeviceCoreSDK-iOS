//
//  BindScanQRCodeViewController.swift
//  AddxAi
//
//  Created by addx-wjin on 2022/3/16.
//  Copyright © 2022 addx.ai. All rights reserved.
//

import Foundation
import Network
import SmartDeviceCoreSDK
import BindInterface
import BaseUI

class BindScanQRCodeViewController: BindBaseViewController {
    
    var isAgainScanQRCode: Bool = false
    var launchWay: String = "bootup"
    
    private var bindScanQRCodeView: A4xBindScanQRCodeView?
    
    private var oldQRCodeImg: UIImage?
    private var newQRCodeImg: UIImage?
    private var wiredQRCodeImg: UIImage?

    private var getResultCount: Int = 0
 
    // 一次请求绑定结果间隔
    private let onceWaitTime: Int = 4
    // 切换新旧二维码时间
    private var waitTimerCount: Int = 30 //Int.max
    
    // 是否新旧请求标记
    private var oldQRCodeStyle: Bool = false
    // 请求绑定最终超时事件
    private var bindTimerOut: Int = 180
    // 请求绑定是否超时
    private var isBindTimerOut: Bool = false

    // 当前屏幕亮度
    private var currentBrightness: CGFloat = 0.7
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        UIScreen.main.brightness = CGFloat(0.8)
        UIApplication.shared.isIdleTimerDisabled = true
        
        
        bindScanQRCodeView = A4xBindScanQRCodeView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
        let currentView = bindScanQRCodeView
        self.view.isUserInteractionEnabled = true
        self.view.addSubview(currentView!)
        
        // 注册获取二维码失败点击事件
        currentView!.errorView.addTarget(self, action: #selector(tryAgainGetQRCodeImg), for: .touchUpInside)
        
        currentView?.backClick = { [weak self] in
            //self?.pushBack(type: .linkAPErr)
            self?.navigationController?.popViewController(animated: false)
        }

        if isAgainScanQRCode || bindErrorTypeEnum == .otherQuestion {
            let lastWifiNameAndPwd = UserDefaults.standard.string(forKey: "save_last_success_wifi")
            let array = lastWifiNameAndPwd?.split(separator: ",")
            if array != nil {
                guard array?.count ?? 0 > 0 else {
                    // 获取扫描二维码
                    getBindQRCodeImg()
                    return
                }
                wifiName = String(array?[0] ?? "no_wifi_name")
                wifiPwd = String(array?[1] ?? "no_wifi_pwd")
                A4xLog("---------> error back wifiname: \(wifiName ?? "")")
                A4xLog("---------> error back wifiPwd: \(wifiPwd ?? "")")
            } else {
            }
        }
        
        // 获取扫描二维码
        oldQRCodeStyle = false
        
        getBindQRCodeImg()
    }
    
    private func pushBack(type: BindErrorTypeEnum) {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancleRequest()
    }
    
    deinit {
        A4xLog("BindScanQRCodeViewController deinit")
    }
    
    private func getBindQRCodeImg() {
        bindScanQRCodeView?.qrCodeLoadingImgView.isHidden = false
        bindScanQRCodeView?.qrCodeLoadingImgView.layer.add(bindScanQRCodeView!.qrCodeLoadingAnimail, forKey: "loading")
        BindCore.getInstance().startBindByQRCode(ssid: self.wifiName, ssidPassword: self.wifiPwd)
    }
    
    // 获取二维码失败后点击事件
    @objc func tryAgainGetQRCodeImg() {
        // 获取扫描二维码
        getBindQRCodeImg()
    }
    
    
    // 取消请求和重置参数
    func cancleRequest() {
        A4xGCDTimer.shared.destoryTimer(withName: "BIND_QRQUEST_TIMER")
        bindTimerOut = 180
        waitTimerCount = 30
        getResultCount = 0
        isBindTimerOut = false
    }
    
    // 开始请求
    func beginRequest(total: Int = Int.max) {
        print("-----------> bindCycleGetResult beginRequest")
        waitTimerCount = total
        
        A4xGCDTimer.shared.scheduledDispatchTimer(withName: "BIND_QRQUEST_TIMER", timeInterval: TimeInterval(onceWaitTime), queue: DispatchQueue.main, repeats: true) { [weak self] in
            self?.bindCycleGetResult()
        }
    }
    
    // 绑定结果（5s 轮询）
    @objc func bindCycleGetResult() {
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "error_no_net"))
            return
        }
        
        getResultCount += 1
        print("-----------> bindCycleGetResult waitTimerSecount \(waitTimerCount) bindTimerOut:\(bindTimerOut) getResultCount: \(getResultCount)")
        
        waitTimerCount -= onceWaitTime
        bindTimerOut -= onceWaitTime
        
        if !isBindTimerOut {
            if bindTimerOut < 0 {
                isBindTimerOut = true
                print("超时错误")
            }
        }
        
        
        if bindTimerOut < 128 {
            if (bindScanQRCodeView?.nextBtn.isHidden ?? false) {
                
                // 数据封装传递
                let isFeedBackEnable = (bindErrorTypeEnum == nil) ? 0 : 1
                var datas: [String: String] = [:]
                datas["isFeedBackEnable"] = String(isFeedBackEnable)
                datas["nextEnable"] = "1"
                bindScanQRCodeView!.datas = datas
                bindScanQRCodeView?.nextBtn.isEnabled = true
                bindScanQRCodeView?.nextBtn.isHidden = false
            }
        }
        
        // 30s 新旧二维码切换
        if waitTimerCount < 0 {
            print("----------> 新旧二维码切换")
            oldQRCodeStyle = !oldQRCodeStyle
            waitTimerCount = 30
            self.bindScanQRCodeView?.errorView.isHidden = true
            self.bindScanQRCodeView?.qrCodeImgView.image = oldQRCodeStyle ? oldQRCodeImg : newQRCodeImg
            return
        }
    }
    
    // 恢复系统亮度和常亮设置
    private func resetSysSetWithBrightnessAndTimerDisabled() {
        UIScreen.main.brightness = self.currentBrightness
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    
    func jumpToBindConnectWaitViewController(currentStep: Int, serialNumber: String?) {
        self.view.hideToastActivity(block: { })
        
        // 保存成功的Wi-Fi name 和 pwd(防止连接中超时到错误页，返回可直接生成二维码)
        UserDefaults.standard.set(((self.wifiName ?? "") + "," + (self.wifiPwd ?? "")), forKey: "save_last_success_wifi")
        
        // 跳转等待
        self.resetSysSetWithBrightnessAndTimerDisabled()
        
        self.cancleRequest()
        
        let vc = BindConnectWaitViewController()
        vc.bindMode = self.bindMode
        // 是否更换网络
        vc.serialNumber = serialNumber
        vc.currentStep = currentStep
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension BindScanQRCodeViewController {
    override func onStepChange(code: Int) {
        A4xLog("---------> onStepChange code: \(code)")
        
        if code > 1 && code != 4 {
            
            
            jumpToBindConnectWaitViewController(currentStep: code, serialNumber: nil)
        }
    }
    
    override func onGenarateQrCode(newQRCdoe: UIImage?, oldQRCode: UIImage?, wireQRCode: UIImage?) {
        A4xLog("---------> onGenarateQrCode")
        
        self.newQRCodeImg = newQRCdoe
        self.oldQRCodeImg = oldQRCode
        self.bindScanQRCodeView?.qrCodeLoadingImgView.layer.removeAllAnimations()
        self.bindScanQRCodeView?.qrCodeLoadingImgView.isHidden = true
        self.bindScanQRCodeView?.errorView.isHidden = true
        self.bindScanQRCodeView?.qrCodeImgView.image = newQRCdoe
     
        if let wiredQRCodeImg = wireQRCode {
            self.wiredQRCodeImg = wiredQRCodeImg
        }
        
        self.waitTimerCount = 30
        self.beginRequest(total: self.waitTimerCount)
    }
    
    override func onSuccess(code: Int, msg: String?, serialNumber: String?) {
        jumpToBindConnectWaitViewController(currentStep: 4, serialNumber: serialNumber)
    }
    
    override func onError(code: Int, msg: String?) {
        A4xLog("---------> onError")
        self.bindScanQRCodeView?.qrCodeLoadingImgView.layer.removeAllAnimations()
        self.bindScanQRCodeView?.qrCodeLoadingImgView.isHidden = true
        self.bindScanQRCodeView?.qrCodeImgView.image = nil
        self.bindScanQRCodeView?.errorView.isHidden = false
        self.bindScanQRCodeView?.errorMsg.text = msg
    }
}

extension BindScanQRCodeViewController: BluetoothManagerProtocol {
    func onBleBindResult(resStr: String?, code: String?) {
        A4xLog("---------> ble wait SN: \(resStr ?? "") code: \(code ?? "-1")")
    }
}

