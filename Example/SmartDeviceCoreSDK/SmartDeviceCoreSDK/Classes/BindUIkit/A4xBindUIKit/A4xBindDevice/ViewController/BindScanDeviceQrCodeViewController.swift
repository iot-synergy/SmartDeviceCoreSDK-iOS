//


//


import UIKit
import AVFoundation
import SmartDeviceCoreSDK
import BindInterface
import ScanQR
import BaseUI

class BindScanDeviceQrCodeViewController: ScanQRViewController {
    
    var bindErrorTypeEnum: BindErrorTypeEnum?
    var isFirst : Bool = true
    public var bindCode: String?
    public var bindLocalCode: String?
    public var bindFrom: String? = "addCamera"

    override var scanTitle: String? {
        return A4xBaseManager.shared.getLocalString(key: "scan_camera_qr_code")
    }

    override func handleScanResult(result: String, frame: CGRect) {
        
        self.searchDeviceNoBySN(qrData: result)
    }
    
    override func handleSelectQRResult(result: String) {
        self.searchDeviceNoBySN(qrData: result)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isFirst = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
}

extension BindScanDeviceQrCodeViewController {
    
    private func searchDeviceNoBySN(qrData: String) {
        
        
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            let errorStr = A4xBaseManager.shared.getLocalString(key: "phone_no_net")
            self.view.makeToast(errorStr)
        }
        
        BindNetworkAPI.shared.searchDeviceModeNo(qrData: qrData, bindCode: self.bindCode ?? "") { [weak self] (code, msg, model) in
            if code == 0 {
                
                self?.pushToWebView(modle: model)
            } else {
                self?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "shared_invalid_qr_code"))
                self?.startScan()
            }
        }
    }
    
    private func pushToWebView(modle: A4xDeviceZendeskModel?) {
        
    }
    
    
}
