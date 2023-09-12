//
//  A4xGenerateQrcodeViewController.swift
//  AddxAi
//
//  Created by zhi kuiyu on 2019/5/7.
//  Copyright © 2019 addx.ai. All rights reserved.
//

import UIKit
import AVFoundation
import SmartDeviceCoreSDK
import ScanQR

class A4xScanQrcodeViewController: ScanQRViewController {
    
    var backClickBlock: ((Int) -> Void)?
    
    override init() {
        super.init()
    }
    
    override var scanTitle: String? {
        return A4xBaseManager.shared.getLocalString(key: "scan_the_qr_code")
    }
    
    override var scanTitleDes: String? {
        return A4xBaseManager.shared.getLocalString(key: "share_scan_qr_content")
    }
    
    // 处理自己的业务逻辑
    override func handleScanResult(result: String, frame: CGRect) {
        // 扫描添加设备
        let center = CGPoint(x: frame.midX, y: frame.midY)
        self.joinDevice(qrData: result, center: center)
    }
    
    override func handleSelectQRResult(result: String) {
        self.joinDevice(qrData: result, center: self.view.center)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        self.navView?.leftClickBlock = {
            weakSelf?.backClickBlock?(2)
            weakSelf?.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.loadNavtion()
    }
}

extension A4xScanQrcodeViewController {
    
    // 扫描添加设备
    private func joinDevice(qrData : String , center : CGPoint) {

        weak var weakSelf = self
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        let viewModel = BindDeviceViewModel()
        viewModel.joinDeviceRequest(result: qrData) { code, message, flag in
            if flag ?? true {
                weakSelf?.pushLoadingView()
            } else {
                weakSelf?.view.makeToast(message, completion: { (r) in
                    weakSelf?.startScan()
                })
            }
        }
    }
    
    private func pushLoadingView() {
        let vc = A4xScanQrcodeResultViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
