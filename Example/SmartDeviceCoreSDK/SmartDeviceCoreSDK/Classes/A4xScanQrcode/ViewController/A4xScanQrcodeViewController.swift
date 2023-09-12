//
//  A4xGenerateQrcodeViewController.swift
//  AddxAi
//
//  Created by zhi kuiyu on 2019/5/7.
//  Copyright © 2019 addx.ai. All rights reserved.
//

import UIKit
import AVFoundation
import A4xNetwork
import A4xBaseSDK
import A4xFeedback
import A4xVideoPushManager
import A4xBindSDK

import ScanQR

class A4xScanQrcodeViewController: ScanQRViewController {

    var isPushProblemFeedbackScanVC: Bool = false // 是意见反馈就返回上一级
    var fromVCType: FromViewControllerEnum? //  来自不同VC
    
    var problemStr: String? // zendesk 问题标签
    
    var isComeFromBind: Bool = false  // true 客服和意见反馈都会有push，false只push意见反馈
    
    var backClickBlock: ((Int) -> Void)?
    
    override var scanTitle: String? {
        return A4xBaseManager.shared.getLocalString(key: "scan_the_qr_code")
    }
    
    override var scanTitleDes: String? {
        return A4xBaseManager.shared.getLocalString(key: "share_scan_qr_content")
    }
    
    // 处理自己的业务逻辑
    override func handleScanResult(result: String, frame: CGRect) {
        
        if isPushProblemFeedbackScanVC { // 1
            // 无网络处理
            if A4xUserDataHandle.Handle?.netConnectType == .nonet {
                let errorStr = A4xBaseManager.shared.getLocalString(key: "phone_no_net")
                self.view.makeToast(errorStr)
            }
            // 判断扫描的二维码是否有效
            A4xBaseBindInterface.shared.searchDeviceModeNo(qrData: result, bindCode: "") { [weak self] (code, msg, model) in
                if code == 0 {
                    if self?.fromVCType == .homeUserFeedBack {
                        self?.popToFeedbackSelectFaultyDeviceVC(scanStr: result)
                    } else {
                        self?.pushUserFeedbackVC(scanStr: result)
                    }
                    
                } else {
                    self?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "shared_invalid_qr_code"))
                    self?.startScan()
                }
            }
        } else {
            // 扫描添加设备
            let center = CGPoint(x: frame.midX, y: frame.midY)
            self.joinDevice(qrData: result, center: center)
        }
    }
    
    override func handleSelectQRResult(result: String) {
        self.joinDevice(qrData: result, center: self.view.center)
    }
    
    init(isPushProblemFeedbackScanVC: Bool = false, fromVCType: FromViewControllerEnum? = nil, problemStr: String? = nil, isComeFromBind: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.isPushProblemFeedbackScanVC = isPushProblemFeedbackScanVC
        self.fromVCType = fromVCType
        self.problemStr = problemStr
        self.isComeFromBind = isComeFromBind
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var infoView : A4xScanQrcodeBottomView = {
        let temp = A4xScanQrcodeBottomView()
        weak var weakSelf = self
        temp.bottomActionBlock = {
            A4xLog("A4xScanQrcodeBottomView button")
            weakSelf?.toHelperCenter()
        }
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.view.snp.bottom)
            make.width.equalTo(self.view.snp.width)
            make.centerX.equalTo(self.view.snp.centerX)
        })
        return temp
    }()
    
    private func toHelperCenter(){
        let articleUrl = A4xBaseManager.shared.getArticleUrl(articleId: "360041802153")
        let viewC = A4xBaseWebViewController(urlString: articleUrl)
        self.navigationController?.pushViewController(viewC, animated: true)
    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        self.navView?.leftClickBlock = {
            weakSelf?.backClickBlock?(2)
            if weakSelf?.fromVCType == .registeredVC { // 来自注册完成-返回到首页
                A4xAppRouter.router.open(fromClassName: "ScanQrcodeVC")
            } else {
                weakSelf?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.infoView.isHidden = false
        self.loadNavtion()
        // 设置推送类型为添加新摄像机模式
        A4xPushMsgManager.default().pushType = .addCamera
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        A4xVideoPushManager.shared.setPushVideoEnable(false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        A4xPushMsgManager.default().pushType = .foreground
    }

}

extension A4xScanQrcodeViewController {
    
    private func popToFeedbackSelectFaultyDeviceVC(scanStr: String) {
        guard let viewControllers = self.navigationController?.viewControllers else {
            return
        }
        for aViewController in viewControllers {
            guard let selectVC = aViewController as? A4xFeedbackSelectFaultyDeviceViewController else {
                continue
            }
            selectVC.scanSN = scanStr
            _ = self.navigationController?.popToViewController(selectVC, animated: true)
        }
    }
    
    // 扫码成功跳 feedback
    private func pushUserFeedbackVC(scanStr: String) {
        let vc = A4xUserFeedbackViewController() // 意见反馈
        if self.isComeFromBind { // 从客服中心来
            vc.isComeFromBind = true
        } else {
            vc.isComeFromBind = false // 默认从设置页来
        }
        vc.jumpToScanQrCodeVCBlock = { [weak self] (isPushProblemFeedbackScanVC, fromVCType, problemStr, isComeFromBind) in
            let scanQrVC = A4xScanQrcodeViewController(isPushProblemFeedbackScanVC: true, fromVCType: fromVCType, problemStr: problemStr, isComeFromBind: isComeFromBind)
            self?.navigationController?.pushViewController(scanQrVC, animated: true)
        }
        
        vc.isShowFeedbackHistoryList = false // 隐藏反馈列表
        vc.problemStr = self.problemStr// zendesk 问题标签
        vc.sn = scanStr
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 扫描添加设备
    private func joinDevice(qrData : String , center : CGPoint) {

        weak var weakSelf = self
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        let viewModel = A4xBindDeviceViewModel()
        viewModel.joinDeviceRequest(result: qrData) { (flag, error) in
            weakSelf?.view.hideToastActivity()
            if flag {
                weakSelf?.pushLoadingView()
            } else {
                weakSelf?.view.makeToast(error, completion: { (r) in
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
