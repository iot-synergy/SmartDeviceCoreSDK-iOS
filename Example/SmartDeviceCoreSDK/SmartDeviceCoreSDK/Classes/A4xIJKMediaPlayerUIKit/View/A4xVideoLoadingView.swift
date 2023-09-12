//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xVideoLoadingView : UIView {
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0, alpha: 0.3)
        self.loadingView.isHidden = false
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- view 创建
    lazy var loadingView : A4xBaseLoadingView = {
        let temp = A4xBaseLoadingView()
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX).offset(8.auto())
            make.centerY.equalTo(self.snp.centerY)
        })
        return temp
    }()
    
    func startAnimail(){
        self.loadingView.startAnimail()
        self.isHidden = false
    }
    
    func stopAnimail(){
        self.loadingView.stopAnimail()
        self.isHidden = true
    }
}
