//


//


//

import UIKit
import SmartDeviceCoreSDK

class A4xActivityZoneTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tipImageV.isHidden = false
        self.delegate = self
        self.setMaxTextsCount(maxChar: 30)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tipImageV.isHidden = false
        self.delegate = self
        self.setMaxTextsCount(maxChar: 30)
    }
    
    var tipImage : UIImage?
    override var text: String?{
        didSet {
            self.layoutIfNeeded()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        defer {
            self.layoutIfNeeded()
        }
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        defer {
            self.layoutIfNeeded()
        }
        return super.resignFirstResponder()
    }
    
    lazy
    var tipImageV : UIImageView = {
        let temp = UIImageView()
        self.addSubview(temp)
        temp.isHidden = true

        let image = A4xDeviceSettingResource.UIImage(named: "device_edit_icon")?.rtlImage()
        temp.image = image
        let imageSize = image?.size ?? CGSize(width: 20.auto(), height: 20.auto())
        temp.frame = CGRect(x: 0, y: 0, width: imageSize.width , height: imageSize.height)
        return temp
    }()
    
    lazy
    var clearButton : UIButton = {
        let temp = UIButton()
        temp.addTarget(self, action: #selector(clearTextAction), for: .touchUpInside)
        self.addSubview(temp)
        temp.isHidden = true
        
        let image = A4xDeviceSettingResource.UIImage(named: "textfield_clear_button")?.rtlImage()
        temp.setImage(image, for: .normal)
        let imageSize = image?.size ?? CGSize(width: 26.auto(), height: 26.auto())
        temp.frame = CGRect(x: 0, y: 0, width: imageSize.width , height: imageSize.height)
        return temp
    }()
    
    override func layoutSubviews() {
        let buttonFrame = CGRect(x: self.width - 26.auto() , y: (self.height - 26.auto()) / 2, width: 26.auto(), height: 26.auto())
        clearButton.frame = buttonFrame
        tipImageV.frame = buttonFrame
        
        
        clearButton.isHidden = !self.isFirstResponder
        tipImageV.isHidden = self.isFirstResponder
        
        self.subviews.forEach { (v) in
            if let sc = v as? UIScrollView {
                sc.isScrollEnabled = false
                sc.setContentOffset(CGPoint.zero, animated: false)
                sc.contentInset = .zero
            }
        }
        super.layoutSubviews()
  
    }
    
    override var intrinsicContentSize: CGSize{
        let attrStr = self.attributedText
        var textSize = CGSize.zero
        if let atext = attrStr {
            textSize = atext.boundingRect(with: self.bounds.size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size
        }
        return CGSize(width: textSize.width + 30.auto(), height: 0)
    }
    
    @objc
    func clearTextAction() {
        self.text = ""
    }
    
    @objc
    func textValueChange() {
        self.layoutIfNeeded()
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        rect = CGRect(x: rect.origin.x , y: rect.origin.y, width: rect.width - 20.auto(), height: rect.height)
        return rect
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        rect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width - 20.auto(), height: rect.height)
        return rect
    }
}


extension A4xActivityZoneTextField : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
