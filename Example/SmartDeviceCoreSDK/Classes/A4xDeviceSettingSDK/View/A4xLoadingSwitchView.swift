//
//  A4xLoadingSwitchView.swift
//  AddxAi
//
//  Created by 郭建恒 on 2022/4/8.
//  Copyright © 2022 addx.ai. All rights reserved.
//  开关网络请求 LoadingView

import UIKit
import SmartDeviceCoreSDK
import BaseUI

@objc public class A4xLoadingSwitchView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.loadingSwitch.isHidden = false
        self.loadingImageView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // loadingImageView
    lazy var loadingImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("home_video_loading")?.rtlImage()
        temp.contentMode = .center
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.bottom.left.right.equalTo(self)
        })
        return temp
    }()
    
    private lazy var animail: CABasicAnimation = {
        let baseAnil = CABasicAnimation(keyPath: "transform.rotation")
        baseAnil.fromValue = 0
        baseAnil.toValue = Double.pi * 2
        baseAnil.duration = 1.5
        baseAnil.repeatCount = MAXFLOAT
        return baseAnil
    }()
    
    /// loading 开关
    public lazy var loadingSwitch: UISwitch = {
        let temp = UISwitch()
        temp.onTintColor = ADTheme.Theme
        temp.tintColor = ADTheme.C5
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.bottom.left.right.equalTo(self)
        })
        return temp
    }()
    
    /// 开始加载
    @objc public func startLoading() {
        self.loadingSwitch.isHidden = true
        self.loadingImageView.isHidden = false
        self.loadingImageView.layer.add(animail, forKey: "loading")
    }
    
    /// 停止Loading
    @objc public func stopLoading() {
        self.loadingSwitch.isHidden = false
        self.loadingImageView.isHidden = true
        self.loadingImageView.layer.removeAllAnimations()
    }

}
