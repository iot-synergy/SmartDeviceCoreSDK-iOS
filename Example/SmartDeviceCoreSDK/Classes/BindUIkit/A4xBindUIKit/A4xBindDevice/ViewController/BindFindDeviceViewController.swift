//


//


//

import Foundation
import Network
import SmartDeviceCoreSDK
import BaseUI

class BindFindDeviceViewController: BindBaseViewController {
    
    public var isDingDong: Bool = false
    
    private var bindFindDeviceView: A4xBindFindDeviceView?
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        defaultNav()
        self.navView?.lineView?.isHidden = true
        
        bindFindDeviceView = A4xBindFindDeviceView(frame: CGRect(x: 0, y:0, width: self.view.width, height: self.view.height), isDingDong: self.isDingDong, isAPMode: isAPMode ?? false)
        let currentView = bindFindDeviceView
        currentView?.protocol = self
        self.view.addSubview(currentView!)
        
        currentView?.bluetoothTopClickBlock = { [weak self] in
            
            self?.statusBarHidden = !(self?.statusBarHidden ?? false)
        }
        
        currentView?.backClick = { [weak self] in
            self?.navigationController?.popViewController(animated: false)
        }
        
        currentView?.searchNothingBlock = { [weak self] in
            self?.searchNothingClick()
        }
        
        self.getBindCode(comple: { code, bindCode in
            
        })
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isDingDong {
            if self.isAPMode ?? false {
                bindFindDeviceView?.viewWillAppear()
            } else {
                bindFindDeviceView?.stopSearch(stopType: .bleOffOrUnAuth)
            }
        } else {
            bindFindDeviceView?.viewWillAppear()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BindCore.getInstance().discoverDevice { [weak self] model in
            self?.bindFindDeviceView?.findNewDevice(model: model)
        } onDiscoverError: { code, msg in
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bindFindDeviceView?.viewWillDisappear()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    
    @objc func didBecomeActive() {
        
    }
    
    
    @objc func applicationEnterBackground() {
        
    }
    
    private func searchNothingClick() {

    }
    
    
    private func pushToA4xBindFindDeviceView(isDingDong: Bool) {
        
        
        
        
        
        
    }
    
    
    private func pushToBindConnectWaitViewController() {
        self.view.hideToastActivity(block: { })
        
        let vc = BindConnectWaitViewController()
        vc.bindMode = self.bindMode
        // 是否更换网络
        vc.serialNumber = self.selectedBindDeviceModel?.serialNumber
        vc.currentStep = 2
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
    
    private func supportDeviceType() -> Int {
        return A4xBaseThemeConfig.shared.supportDeviceType()
    }
}

extension BindFindDeviceViewController {
    override func onBleAuthStateChange(state: BleAuthEnum) {
        switch state {
        case .unknown:
            break
        case .poweredOn:
            self.bindFindDeviceView?.startSearch()
        case .poweredOff:
            fallthrough
        case .unauthorized:
            self.bindFindDeviceView?.stopSearch(stopType: .bleOffOrUnAuth)
        default:
            break
        }
    }
    
    override func onError(code: Int, msg: String?) {
        switch code {
        case -10306: 
            self.view.hideToastActivity(block: {})
            break
        case -10307: 
            if (selectedBindDeviceModel?.isWired() ?? false) && (selectedBindDeviceModel?.isWireless() ?? false) {
                
                let vc = BindWiredGuideViewController()
                self.navigationController?.pushViewController(vc, animated: false)
            } else {
                
                //viewPageStackPush("A4xBindCableCheckView")
                //A4xBindCableCheckViewController()
                //self.page_ethernet_guide_show()
            }
        default: break
        }
    }
    
    
    @available(iOS 12.0, *)
    private func sendTCPMsg(host: String, port: String, sendTxt: String) {
        
        
        
        let msg = sendTxt
        let hostUDP: NWEndpoint.Host = .init(host)
        let portUDP: NWEndpoint.Port = .init(integerLiteral: UInt16(port) ?? 23450)
            
        let connection = NWConnection(host: hostUDP, port: portUDP, using: .tcp)
        
        connection.stateUpdateHandler = { (newState) in
            print("This is stateUpdateHandler:")
            switch (newState) {
                case .ready:
                    print("---------> ble tcp State: Ready")
                    sendTCP(msg)
                    receiveTCP()
                case .setup:
                    print("---------> ble tcp State: Setup")
                case .cancelled:
                    print("---------> ble tcp State: Cancelled")
                case .preparing:
                    print("---------> ble tcp State: Preparing")
                default:
                    print("---------> ble tcp State not defined")
            }
        }
        
        connection.start(queue: .global())
        
        func sendTCP(_ msg: String) {
            let contentToSend = msg.data(using: String.Encoding.utf8)
            connection.send(content: contentToSend, completion: NWConnection.SendCompletion.contentProcessed({(NWError) in
                if NWError == nil {
                    print("---------> ble tcp send Data was sent to TCP")
                } else {
                    print("---------> ble tcp send ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
                }
            }))
        }
        
        func receiveTCP() {
            connection.receiveMessage { (data, context, isComplete, error) in
                if (isComplete) {
                    print("---------> ble tcp Receive is complete")
                    
                    //self?.jumpToBindConnectWaitViewController()
                    onMainThread {
                        //self?.jumpToBindConnectWaitViewController()
                    }
                    if (data != nil) {
                        let backToString = String(decoding: data!, as: UTF8.self)
                        print("---------> ble tcp Received message: \(backToString)")
                    } else {
                        print("---------> ble tcp Data == nil")
                    }
                }
            }
        }
    }
}


extension BindFindDeviceViewController: A4xBindFindDeviceViewProtocol {
    func searchTimeout() {
        
    }
    
    func findDeviceView_dingDongVoiceGuideViewHearNothingClick() {
        
    }
    
    func findDeviceView_dingDongVoiceGuideViewVBackClick() {
        
    }
    
    func findDeviceView_dingDongVoiceGuideViewVoicePlayClick() {
        
    }
    
    func findDeviceView_dingDongVoiceGuideViewZendeskChatClick() {
        
    }
    
    func devicesCellSelect(model: BindDeviceModel?, clickType: Int) {
        self.bindFindDeviceView?.stopSearch(stopType: .keepScan)
        selectedBindDeviceModel = model
        
        if isAPMode ?? false {
            if model?.supportApConnect == 1 {
                BindCore.getInstance().startBindByApDirect(bindDeviceModel: model)
            } else {
                var config = A4xBaseAlertAnimailConfig()
                config.leftbtnBgColor = UIColor.white
                config.leftTitleColor = UIColor.colorFromHex("#2F3742")
                
                config.rightbtnBgColor = UIColor.white
                config.rightTextColor = ADTheme.Theme
                config.messageColor = UIColor.colorFromHex("#2F3742")
                
                let alert = A4xBaseAlertView(param: config, identifier: "back click")
                alert.message = A4xBaseManager.shared.getLocalString(key: "add_notsupport_hotspot")
                alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "drop_out")
                alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "add_reselect")
                alert.leftButtonBlock = { [weak self] in
                    self?.isAPMode = false
                    
                }
                alert.rightButtonBlock = { [weak self] in
                    self?.navigationController?.popViewController(animated: false)
                }
                alert.show()
            }
        } else {
            // 检测设备支持情况
            self.view.makeToastActivity(title: "loading") { (f) in }
            wiredBindCheck()
        }

        

    }
    

    
    
    func search_nofindDevice() {
        
        
    }
    
    
    func findDeviceView_dingDongVoiceGuideViewNextAction() {
        
        
        if supportDeviceType() == 0 {
            selectedBindDeviceModel = nil
            
            let vc = BindWiredGuideViewController()
            self.navigationController?.pushViewController(vc, animated: false)
            
        } else if supportDeviceType() == 2 {
            
            
            
            if selectedBindDeviceModel != nil { 
                self.view.makeToastActivity(title: "loading") { (f) in }
                //checkNextStep(isWiredAndWireless: false)
            } else {
                
                self.bindMode = "wiredCode"
            }
        } else {
            
            selectedBindDeviceModel = nil
            //viewPageStackPush("A4xBindChooseWifiView")
            //A4xBindChooseWifiViewController()
            //self.page_set_wifi_view(source: "device_scan_result_click")
            let vc = BindChooseWifiViewController()
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
}


