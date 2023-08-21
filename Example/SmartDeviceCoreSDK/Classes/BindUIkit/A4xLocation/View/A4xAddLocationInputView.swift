//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xLocationInputView : UIView {

    var nameDes : String? {
        didSet {
            self.nameV.text = self.nameDes
        }
    }
    
    var placeHolder : String? {
        didSet {
            self.InputV.placeholder = self.placeHolder
        }
    }
    
    var text : String?{
        set {
            self.InputV.text = newValue
        }
        get {
            return self.InputV.text
        }
    }
    
    var isMust : Bool = false {
        didSet {
            self.mustInputV.isHidden = !isMust
        }
    }
    
    init(tipName : String = "" , placeHolder : String = "" , text : String = ""){
        super.init(frame: CGRect.zero)
        self.nameV.text = tipName
        self.InputV.placeholder = placeHolder
        self.InputV.text = text
        self.mustInputV.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var nameV : UILabel = {
        var tipV = UILabel()
        tipV.font = ADTheme.B2
        tipV.textColor = UIColor.hex(0x000000)
        self.addSubview(tipV)
        
        tipV.snp.makeConstraints({ (make) in
            make.top.equalTo(0)
            make.leading.equalTo(0)
        })
        
        return tipV
    } ()
    
    private lazy var mustInputV : UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.B2
        temp.textColor = UIColor.red
        self.addSubview(temp)
        temp.text = "*"
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.nameV.snp.trailing)
            make.top.equalTo(self.nameV.snp.top)
        })
        return temp
    }()
    
    lazy var InputV : A4xBaseTextField = {
        var temp: A4xBaseTextField = A4xBaseTextField()
        temp.font = ADTheme.B2
        temp.contentVerticalAlignment = .center
        temp.textColor = UIColor(white: 0, alpha: 0.8)
        temp.clearButtonMode = .whileEditing
        temp.textAlignment = .left
        temp.accessibilityIdentifier = "add_location"
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(0)
            make.top.equalTo(self.nameV.snp.bottom)
            make.height.equalTo(30.auto())
            make.width.equalTo(self.snp.width)
            make.bottom.equalTo(self.snp.bottom)
        })
        temp.addLineStyle()
        
        return temp
    }()
}
