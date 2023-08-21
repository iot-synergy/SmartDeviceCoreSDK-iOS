//
//  A4xScanQrcodeBottomView.swift
//  AddxAi
//
//  Created by zhi kuiyu on 2019/5/7.
//  Copyright © 2019 addx.ai. All rights reserved.
//

import Foundation
import UIKit
import A4xBaseSDK

class A4xScanQrcodeBottomView: UIView {
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.loadData()
    }
    
    var bottomActionBlock : (() -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: 0, height: 177 + UIScreen.safeAreaHeight)
    }
    
    private func loadData() {
        self.buttonV.isHidden = false
        self.buttonTitle.isHidden = false
        self.buttonImage.isHidden = false
//        self.titleLabel.text = A4xBaseManager.shared.getLocalString(key: "scan_info_title")
//
//        let desAttr = NSMutableAttributedString(string: A4xBaseManager.shared.getLocalString(key: "scan_info_des"))
//        desAttr.addAttribute(.font, value: ADTheme.B2 , range: NSRange(location: 0, length: desAttr.string.count))
//        desAttr.addAttribute(.foregroundColor, value: ADTheme.Theme , range: NSRange(location: 0, length: desAttr.string.count))
//
//        let param = NSMutableParagraphStyle()
//        param.lineSpacing = 6
//        param.alignment = .center
//        param.lineBreakMode = .byWordWrapping
//        desAttr.addAttribute(.paragraphStyle, value: param, range: NSRange(location: 0, length: desAttr.string.count))
//
//        self.desLabel.attributedText = desAttr
    }
    
//    private lazy var leftTopImage : UIView = {
//        let temp = UIImageView()
//        temp.image = bundleImageFromImageName("join_device_bottom_left")?.rtlImage()
//        self.addSubview(temp)
//        temp.snp.makeConstraints({ (make) in
//            make.leading.equalTo(0)
//            make.top.equalTo(0)
//        })
//        return temp
//    }()
//
//    private lazy var rightTopImage : UIView = {
//        let temp = UIImageView()
//        temp.image = bundleImageFromImageName("join_device_bottom_right")?.rtlImage()
//        self.addSubview(temp)
//        temp.snp.makeConstraints({ (make) in
//            make.trailing.equalTo(self.snp.trailing)
//            make.top.equalTo(0)
//        })
//        return temp
//    }()
//
//    private lazy var bgView : UIView = {
//        let temp = UIView()
//        self.addSubview(temp)
//        temp.backgroundColor = UIColor.white
//        temp.snp.makeConstraints({ (make) in
//            make.top.equalTo(rightTopImage.snp.bottom)
//            make.bottom.equalTo(self.snp.bottom)
//            make.width.equalTo(self.snp.width)
//            make.leading.equalTo(0)
//        })
//        return temp
//    }()
    
    private lazy var buttonV : UIControl = {
        let temp = UIControl()
        temp.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.width.equalTo(self.snp.width).offset(-50)
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(-5.auto())
            make.height.equalTo(44.auto())
        })
        return temp
    }()
      
    
    lazy var buttonTitle : UILabel = {
        let temp = UILabel()
        temp.isUserInteractionEnabled = false
        temp.textColor = UIColor.white
        temp.textAlignment = .center
        temp.font = ADTheme.B1
        temp.numberOfLines = 0
        temp.text = A4xBaseManager.shared.getLocalString(key: "can_not_find_qr_code")
        self.buttonV.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.buttonV.snp.centerX).offset(-10)
            make.width.lessThanOrEqualTo(self.buttonV.snp.width).offset(-32.auto())
            make.centerY.equalTo(self.buttonV.snp.centerY)
        })
        
        return temp
    }()
    
    private lazy var buttonImage : UIImageView = {
        let temp = UIImageView()
        temp.isUserInteractionEnabled = false
        temp.image = bundleImageFromImageName("add_dialog_arrow")?.rtlImage().tinColor(color: UIColor.white)
        self.buttonV.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.leading.equalTo(self.buttonTitle.snp.trailing).offset(2.auto())
            make.centerY.equalTo(self.buttonV.snp.centerY)
        }
        return temp
    }()
    
    @objc
    private func buttonAction() {
        self.bottomActionBlock?()
    }
    
//    private lazy var titleLabel : UILabel = {
//        let temp = UILabel()
//        temp.textColor = ADTheme.C2
//        temp.textAlignment = .center
//        temp.font = ADTheme.B2
//        self.addSubview(temp)
//        temp.snp.makeConstraints({ (make) in
//            make.top.equalTo(44)
//            make.width.equalTo(self.snp.width).offset(-50)
//            make.centerX.equalTo(self.snp.centerX)
//        })
//        return temp
//    }()
//
//
//    private lazy var desLabel : UILabel = {
//        let temp = UILabel()
//        temp.textColor = ADTheme.Theme
//        temp.lineBreakMode = .byWordWrapping
//        temp.numberOfLines = 0
//        temp.textAlignment = .center
//        temp.font = ADTheme.B2
//        self.addSubview(temp)
//        temp.snp.makeConstraints({ (make) in
//            make.top.equalTo(self.titleLabel.snp.bottom).offset(6)
//            make.width.equalTo(self.snp.width).offset(-80)
//            make.centerX.equalTo(self.snp.centerX)
//        })
//        return temp
//    }()
}
