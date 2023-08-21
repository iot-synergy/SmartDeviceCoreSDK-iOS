//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK

open class A4xBaseTextField: UITextField {
    
    public var isTextFieldDelegate : Bool = false 

    public var maxLength : Int = 30 {
        didSet {
            self.setMaxTextsCount(maxChar: maxLength)
        }
    }
    public var inset : UIEdgeInsets = UIEdgeInsets.zero
    let iconPadding : CGFloat = 5.auto()
    let iconSize : CGSize = CGSize(width: 24, height: 24)
    
    public var showLookPwd : Bool = false {
        didSet {
            self.offDoubleByteInput = true
            self.isSecureTextEntry = showLookPwd
            self.lookPwd.isHidden = false
            if showLookPwd {
                self.lookPwd.setImage(bundleImageFromImageName("device_wifi_secure")?.rtlImage(), for: UIControl.State.normal)
            }
        }
    }
    
    public var openPwdEye : Bool = false {
        didSet {
            if openPwdEye {
                self.lookPwd.setImage(bundleImageFromImageName("device_wifi_look")?.rtlImage(), for: UIControl.State.normal)
            } else {
                self.lookPwd.setImage(bundleImageFromImageName("device_wifi_secure")?.rtlImage(), for: UIControl.State.normal)
            }
        }
    }
    
    public var hiddenPwdEye : Bool = false {
        didSet {
            if hiddenPwdEye {
                self.lookPwd.isHidden = hiddenPwdEye
            } else {
                self.lookPwd.isHidden = false
            }
        }
    }
    
    var isSecureInset : UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 40.auto())
         
    @objc private func lookPwdAction(){
        if self.isSecureTextEntry {
            self.isSecureTextEntry = false
            self.lookPwd.setImage(bundleImageFromImageName("device_wifi_look")?.rtlImage(), for: UIControl.State.normal)
        }else {
            self.isSecureTextEntry = true
            self.lookPwd.setImage(bundleImageFromImageName("device_wifi_secure")?.rtlImage(), for: UIControl.State.normal)
        }
    }
    
    private lazy var lookPwd : UIButton = {
        let temp = UIButton()
        temp.addTarget(self, action: #selector(lookPwdAction), for: .touchUpInside)
        temp.setImage(bundleImageFromImageName("device_wifi_secure")?.rtlImage(), for: UIControl.State.normal)
        self.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-20.auto())//-inset.right
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(self.snp.height)
            make.width.equalTo(self.snp.height).multipliedBy(1)
        }
        
        return temp
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.lookPwd.isHidden = true
        self.setMaxTextsCount(maxChar: maxLength)
        //self.textAlignment = .left
        //self.setDirectionConfig()
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange), name: UITextField.textDidChangeNotification, object: nil)

    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public var placeholderTextColor : UIColor? = ADTheme.C4 {
        didSet {
            let pla = self.placeholder
            self.placeholder = pla
        }
    }
    
    public override var placeholder: String? {
        set {
            if newValue == nil {
                self.attributedPlaceholder = nil
                return
            }
            
            let placeholderAtt = NSMutableAttributedString(string: newValue!)
            
            if let font = self.font {
                placeholderAtt.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: newValue!.count))
            }
            
            if let color = self.placeholderTextColor {
                placeholderAtt.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0, length: newValue!.count))
            }
            









            
            self.attributedPlaceholder = placeholderAtt
        }
        get {
            return self.attributedPlaceholder?.string
        }
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        //判断点击位置，如果是自己想点击的位置就将触摸事件传给自己，如果不是就将点击事件传给父视图
        for view in self.subviews {
            
            let current_point = self.convert(point, to: view)
            
            if view.hitTest(current_point, with: event) != nil {
                return view;
            }
        }
        return hitView
    }
    
    @objc private func textFieldTextDidChange() {
        
        if !isTextFieldDelegate { 
            if !showLookPwd || self.text?.count ?? 0 == 0 {
                //self.lookPwd.isHidden = true
                return
            }
            self.lookPwd.isHidden = false
        }
    }

    public var leftImage: UIImage? {
        didSet {
            self.leftImgV.image = leftImage
            let imageSize = (leftImage?.size ?? CGSize.zero).auto()
            self.leftImgV.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            self.leftView = self.leftImgV
            self.leftViewMode = .always
        }
    }
    
    private lazy var leftImgV: UIImageView = {
        let img = UIImageView()
        img.backgroundColor = UIColor.clear
        img.contentMode = .center
        return img
    }()
    
    public var rightImage: UIImage? {
        didSet {
            self.rightImgV.image = rightImage
            let imageSize = (rightImage?.size ?? CGSize.zero).auto()
            self.rightImgV.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            self.rightView = self.rightImgV
            self.rightViewMode = .always
        }
    }
    
    public var leftAction: (()->Void)? {
        didSet {
            guard let block = rightAction else {
                return
            }
            self.leftImgV.addActionHandler(block)
        }
    }
    
    public var rightAction: (()->Void)? {
        didSet {
            guard let block = rightAction else {
                return
            }
            self.rightImgV.addActionHandler(block)
        }
    }
    
    private lazy var rightImgV: UIImageView = {
        let img = UIImageView()
        img.backgroundColor = UIColor.clear
        img.contentMode = .center
        return img
    }()
 




//





//







//



//



//



//







//

//

//



//
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.placeholderRect(forBounds: bounds)

//






//

//

//





//

//

        
        var frameTemp = rect
        let labelWidth = (self.placeholder?.width(font: UIFont.regular(15) , wordSpace: 0) ?? 0 )
        
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            let x = CGFloat(rect.width) - frameTemp.origin.x - labelWidth
            frameTemp.origin.x = x
        }
        rect = frameTemp
        return rect
    }
//



//



//








//

//



    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
