//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK
import BaseUI

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

//



//





//

    }
    










//










//












    
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
    













//
//















}
