//


//

//

import UIKit
import SmartDeviceCoreSDK



class BindBootUpGuideViewController: BindBaseViewController {
    
    private var poweredOffCount: Int = 0
    private var unauthorizedCount: Int = 0
    
    private var bindBootUpGuideView: A4xBindBootUpGuideView?
    
    public var isPresent: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        defaultNav()
        navView?.backgroundColor = UIColor(hex: "#F6F7F9")
        self.navView?.lineView?.isHidden = true
        bindBootUpGuideView = A4xBindBootUpGuideView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
        bindBootUpGuideView?.protocol = self
        let currentView = bindBootUpGuideView
        self.view.addSubview(currentView!)
        
        
        self.getBindCode(isReset: true, comple: { code, bindCode in
            
        })
        
        currentView?.backClick = { [weak self] in
            if self?.isPresent ?? false {
                self?.navigationController?.dismiss(animated: true)
            } else {
                self?.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BindCore.getInstance().bleInit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BindCore.getInstance().stopDiscoverDevice()
    }
    
    deinit {
        BindCore.getInstance().bleDeinit()
    }
}

extension BindBootUpGuideViewController: BindBootUpGuideViewProtocol {
    func canNotBoot() {
        
        let vc = BindScanDeviceQrCodeGuideViewController()
        vc.bindErrorTypeEnum = .canNotBoot
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func bindBootUpNextAction() {
        
        if BindCore.getInstance().isBlePermissionGranted() {
            if BindCore.getInstance().isBleOpen() { //开启
                
                self.pushToA4xBindFindDeviceView(isDingDong: false)
            } else { 
                if poweredOffCount > 0 {
                    
                    self.pushToA4xBindFindDeviceView(isDingDong: true)
                } else {
                    
                    poweredOffCount += 1
                }
            }
        } else {
            if (self.unauthorizedCount) > 0 {
                if poweredOffCount > 0 {
                    
                    self.pushToA4xBindFindDeviceView(isDingDong: true)
                } else {
                    
                    self.bleAuthAlertView()
                }
            } else {
                
                self.bleAuthAlertView()
            }
        }
    }
    
    private func bleAuthAlertView() {
        self.bleAuthAlertView(comple: { [weak self] res in
            if !res {
                self?.pushToA4xBindFindDeviceView(isDingDong: true)
            }
        })
    }
    
    
    private func pushToA4xBindFindDeviceView(isDingDong: Bool, source: String = "power_on_page") {
        let vc = BindFindDeviceViewController()
        vc.isDingDong = isDingDong
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

extension BindBootUpGuideViewController {
    override func onBleAuthStateChange(state: BleAuthEnum) {
        switch state {
        case .unknown:
            break
        case .poweredOn:
            self.bleAuthAlert?.hidden(comple: { [weak self] in
                self?.bleAuthAlert = nil
            })
            
            if bleAuthAlertBgView != nil {
                bleAuthAlertBgView?.hiddenInWindow()
            }
            
            if poweredOffCount > 0 {
                poweredOffCount -= 1
            }
            
            if unauthorizedCount > 0 {
                unauthorizedCount -= 1
            }
        case .poweredOff:
            poweredOffCount += 1
        case .unauthorized:
            unauthorizedCount += 1
        default:
            break
        }
    }
}
