//
//  A4xSDVideoMinView.swift
//  AddxAi
//
//  Created by kzhi on 2020/1/11.
//  Copyright © 2020 addx.ai. All rights reserved.
//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xSDVideoMinView: A4xVideoChildView {
    override init(frame: CGRect = .zero, identifier: String) {
        super.init(frame: frame, identifier: identifier)
        self.lable.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var lable: UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.textColor = ADTheme.C3
        temp.font = ADTheme.B2
        temp.text = A4xBaseManager.shared.getLocalString(key: "sdcard_no_more_video")
        self.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY).offset(5)
            make.centerX.equalTo(self.snp.centerX)
        }
        
        return temp
    }()
    
}
