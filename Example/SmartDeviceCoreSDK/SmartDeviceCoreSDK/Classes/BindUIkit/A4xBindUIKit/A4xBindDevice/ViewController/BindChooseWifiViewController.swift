import Foundation
import SmartDeviceCoreSDK
import BindInterface
import BaseUI

class BindChooseWifiViewController: BindBaseViewController {
    
    private var bindChooseWifiView: A4xBindChooseWifiView?

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
        bindChooseWifiView = A4xBindChooseWifiView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
        let currentView = bindChooseWifiView
        self.view.addSubview(currentView!)
        
        //获取bind code

        currentView!.nextBtn.addTarget(self, action: #selector(nextActionToScanQRCode), for: .touchUpInside)
        currentView!.backClick = { [weak self] in
            self?.navigationController?.popViewController(animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func nextActionToScanQRCode() {
        self.wifiName = self.bindChooseWifiView?.wifiNameTxtField.text
        self.wifiPwd = self.bindChooseWifiView?.wifiPwdTxtFiled.text
        netxStep()
    }
    
    func netxStep() {
        // AP绑定
        if (self.checkIsAPType() ?? false) {
            self.bindMode = "AP"
            let vc = BindJoinAPNetGuideViewController()
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            self.bindMode = "scanCode"
            let vc = BindScanQRCodeViewController()
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    private func checkIsAPType() -> Bool {
        if selectedBindDeviceModel != nil {
            // 兼容03以下协议
            if selectedBindDeviceModel?.supportApSetWifi != nil {
                return selectedBindDeviceModel?.supportApSetWifi == 1
            } else { // 为空
                if selectedBindDeviceModel?.defaultSupportApSetWifi == 1 {
                    return true
                } else {
                    return false
                }
            }
        }
        return false
    }
    
}
