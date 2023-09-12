//
//  BindReSetGuideViewController.swift
//  BindUIkit
//
//  Created by wei jin on 2023/8/7.
//

import UIKit
import SmartDeviceCoreSDK

class BindReSetGuideViewController: BindBaseViewController {
    
    private var bindReSetGuideView: A4xBindReSetGuideView?
    
    public var sourceFromEnum: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        bindReSetGuideView = A4xBindReSetGuideView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
        let currentView = bindReSetGuideView
        currentView?.protocol = self
        self.view.addSubview(currentView!)
        
        var datas: [String : String] = [:]
        datas["sourceFrom"] = "\(sourceFromEnum ?? 0)"
        currentView!.datas = datas
        
        
        currentView?.backClick = { [weak self] in
            if self?.bindReSetGuideView?.sourceFrom == 3 {
                self?.popToBindFindDeviceViewController()
                return
            }
            self?.navigationController?.popViewController(animated: false)
        }
        
        
    }
    
    private func popToBindFindDeviceViewController() {
        let vcs =  self.navigationController?.viewControllers.filter({ (vc) -> Bool in
            return vc is BindFindDeviceViewController
        })
            
        guard let toViewController = vcs?.last as? BindFindDeviceViewController else {
            return
        }
        toViewController.isDingDong = !BindCore.getInstance().bleAuthAndOpenIsReady()
        self.navigationController?.popToViewController(toViewController, animated: false)
    }
}

extension BindReSetGuideViewController: A4xBindReSetGuideViewProtocol {
    func reSetGuideViewNextAction() {
        if bindReSetGuideView?.sourceFrom == 1 || bindReSetGuideView?.sourceFrom == 2 {
            popToBindFindDeviceViewController()
            
        } else if bindReSetGuideView?.sourceFrom == 3 {
            // 有线绑定处理
        } else {
            let vc = BindChooseWifiViewController()
            self.navigationController?.pushViewController(vc, animated: false)
        }
     }
     
     // reset page 遇到问题点击
     func fallIntoTrouble() {
         let vc = BindScanDeviceQrCodeGuideViewController()
         if bindReSetGuideView?.sourceFrom == 1 || bindReSetGuideView?.sourceFrom == 2 {
             vc.bindErrorTypeEnum = .canNotFindAPNet
         } else {
             vc.bindErrorTypeEnum = .canNotBoot
         }
         self.navigationController?.pushViewController(vc, animated: true)
     }
}

