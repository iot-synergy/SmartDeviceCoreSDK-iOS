//
//  A4xSDVideoMaxView.swift
//  AddxAi
//
//  Created by kzhi on 2020/1/11.
//  Copyright © 2020 addx.ai. All rights reserved.
//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xSDVideoMaxView : A4xVideoChildView {
    override init(frame: CGRect = .zero, identifier: String) {
        super.init(frame: frame, identifier: identifier)
        self.lable.isHidden = true
        self.button.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var maxButtonBlock : (()-> Void)?
    
    lazy var lable : UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.H4
        temp.text = A4xBaseManager.shared.getLocalString(key: "live_play")
        self.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY).offset(-30.auto())
            make.centerX.equalTo(self.snp.centerX)
        }
        
        return temp
    }()
    
    
    lazy var button : UIButton = {
        let temp = UIButton()
        temp.layer.cornerRadius = 17.5.auto()
        temp.backgroundColor = ADTheme.Theme
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "go_live"), for: .normal)
        temp.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        temp.titleLabel?.font = ADTheme.B3
        self.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY).offset(5.auto())
            make.centerX.equalTo(self.snp.centerX)
            make.size.equalTo(CGSize(width: 100.auto(), height: 35.auto()))
        }
        
        return temp
    }()
    
    @objc
    func buttonAction() {
        self.maxButtonBlock?()
    }
}
