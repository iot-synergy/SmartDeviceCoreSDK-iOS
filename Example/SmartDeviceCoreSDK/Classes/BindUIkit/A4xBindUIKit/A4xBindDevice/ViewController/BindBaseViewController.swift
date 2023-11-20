import UIKit
import SmartDeviceCoreSDK
import BindInterface
import BaseUI
import Resolver

private class BindBaseCommonBean: NSObject {
    
    public static let shared = BindBaseCommonBean()
    
    public var bindCode: String?
    public var bindLocalCode: String?
    public var bindFrom: String? = "addCamera"
    public var bindFromType: BindFromTypeEnum? = .top_menu_add
    public var bindMode: String? = "unknown"
    public var isAPMode: Bool? = false
    public var isAPQuickLink: Bool? = false
    public var selectedBindDeviceModel: BindDeviceModel?
    public var wifiName: String? = ""
    public var wifiPwd: String? = ""
}

public class BindBaseViewController: A4xBaseViewController {
    
    public var bindCode: String? {
        set {
            BindBaseCommonBean.shared.bindCode = newValue
        }
        get {
            return BindBaseCommonBean.shared.bindCode
        }
    }
    
    public var isAPMode: Bool? {
        set {
            BindBaseCommonBean.shared.isAPMode = newValue
        }
        get {
            return BindBaseCommonBean.shared.isAPMode
        }
    }
    
    public var bindLocalCode: String? {
        set {
            BindBaseCommonBean.shared.bindLocalCode = newValue
        }
        get {
            return BindBaseCommonBean.shared.bindLocalCode
        }
    }
    public var sourceFrom: String? = "addCamera"
    public var bindFromType: BindFromTypeEnum? {
        set {
            BindBaseCommonBean.shared.bindFromType = newValue
        }
        get {
            return BindBaseCommonBean.shared.bindFromType
        }
    }
    public var bindErrorTypeEnum: BindErrorTypeEnum?
    public var bindMode: String? = "unknown"
    public var isAPQuickLink: Bool? = false
    
    var viewModel: BindDeviceViewModel? = BindDeviceViewModel()
    var selectedBindDeviceModel: BindDeviceModel? {
        set {
            BindBaseCommonBean.shared.selectedBindDeviceModel = newValue
        }
        get {
            return BindBaseCommonBean.shared.selectedBindDeviceModel
        }
    }
    
    var wifiName: String? {
        set {
            BindBaseCommonBean.shared.wifiName = newValue
        }
        get {
            return BindBaseCommonBean.shared.wifiName
        }
    }
    
    var wifiPwd: String? {
        set {
            BindBaseCommonBean.shared.wifiPwd = newValue
        }
        get {
            return BindBaseCommonBean.shared.wifiPwd
        }
    }
    
    var bleAuthAlert: A4xBaseAuthorztionAlertView?
    var bleAuthAlertBgView: A4xBleAuthAlertView? //
    
    public var statusBarHidden = false {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        get {
            return self.statusBarHidden
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        BindCore.getInstance().setListener(bindStateListener: self)
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func getBindCode(isReset: Bool = false, comple: @escaping (_ code: Int, _ bindCode: String?) -> Void) {
        if isReset {
            self.bindCode = nil
        }
        if self.bindCode == nil {
            BindNetworkAPI.shared.getBindCode { (code, msg, res) in
                if code == 0 {
                    self.bindCode = res
                    comple(0, self.bindCode)
                } else {
                    
                    comple(-1, nil)
                }
            }
        } else {
            comple(0, self.bindCode)
        }
    }
    
    
    func bleAuthAlertView(comple: @escaping (_ res: Bool) -> Void) {
        if bleAuthAlertBgView == nil {
            bleAuthAlertBgView = A4xBleAuthAlertView()
            bleAuthAlertBgView?.bleAuthAlertBtnClick = { [weak self] flag in
                if flag {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        comple(true)
                    }
                } else {
                    
                    self?.bleAuthAlertBgView?.hiddenInWindow()
                    comple(false)
                }
            }
        }
        bleAuthAlertBgView?.showInWindow()
    }
    
    private func jumpToBindConnectWaitViewController(currentStep: Int, serialNumber: String?) {
        self.view.hideToastActivity(block: { })
   
        let vc = BindConnectWaitViewController()
        vc.bindMode = self.bindMode
        // 是否更换网络
        vc.serialNumber = serialNumber
        vc.currentStep = currentStep
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 有线绑定处理
    public func wiredBindCheck() {
        if selectedBindDeviceModel?.isWired() ?? false {
            BindCore.getInstance().startBindByWire(bindDeviceModel: self.selectedBindDeviceModel)
            //self.jumpToBindConnectWaitViewController(currentStep: 2, serialNumber: nil)
        } else {
            self.view.hideToastActivity(block: {})
            // 仅无线 - 去Wi-Fi配网页
            //self.page_set_wifi_view(source: "device_scan_result_click")
            let vc = BindChooseWifiViewController()
            vc.sourceFrom = "device_scan_result_click"
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}

extension BindBaseViewController: IBindtateListener {
    public func onBleAuthStateChange(state: BleAuthEnum) {}
    
    public func onDiscoverDevice(_ model: BindDeviceModel) {
        if self.selectedBindDeviceModel?.userSn == model.userSn {
            self.selectedBindDeviceModel = model
        }
    }
    
    public func onStepChange(code: Int) {
        if code > 1 && code != 4 {
//            if self.bindStep != 0 {
//                return
//            }
//            self.bindStep = code
            jumpToBindConnectWaitViewController(currentStep: code, serialNumber: nil)
        }
    }
    
    public func onGenarateQrCode(newQRCdoe: UIImage?, oldQRCode: UIImage?, wireQRCode: UIImage?) {}
   
    public func onSuccess(code: Int, msg: String?, serialNumber: String?) {

        if isAPMode ?? false {
            Resolver.liveUIImpl.pushHotlinkLiveVideoViewController(fromVCType: .apModeBind, navigationViewController: self.navigationController)
            return
        }
        jumpToBindConnectWaitViewController(currentStep: 4, serialNumber: serialNumber)
    }
    
    public func onError(code: Int, msg: String?) {}
}
