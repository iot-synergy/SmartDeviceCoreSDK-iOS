//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xBindAddNewLocationAlertView: UIView, A4xBaseAlertViewProtocol {
    var identifier: String
    var config: A4xBaseAlertConfig
    var onHiddenBlock: ((@escaping () -> Void) -> Void)?
    var awidth : CGFloat = 0
    let paddingvertical : CGFloat = 15.auto()
    var onEditDone : ((String?)->Void)?
   
    var moveYValue : CGFloat = 0
    
    public override init(frame: CGRect = CGRect.zero ) {
        self.config = A4xBaseAlertConfig()
        self.config.outBoundsHidden = false
        self.config.type = .alert(A4xBaseAlertAnimailType.scale)
        self.identifier = "A4xBindAddNewLocationAlertView"
        awidth = 280.auto()
        super.init(frame: frame)
        self.setUpView()
        addNotcation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removeNotcation()
        
    }
    
    private func setUpView() {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 11.auto()
        self.clipsToBounds = true
        self.frame = CGRect(x: 0, y: 0, width: awidth, height:  162.auto() )
        self.nameLable.isHidden = false
        self.leftView.isHidden = false
        self.rightView.isHidden = false
        self.nameLable.isHidden = false
        self.textField.isHidden = false
    }
    
    private lazy var nameLable: UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.textColor = UIColor.hex(0x2F3742)
        temp.font = ADTheme.B0
        temp.text = A4xBaseManager.shared.getLocalString(key: "create_location")
        self.addSubview(temp)

        temp.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.leading.equalTo(0)
            make.width.equalTo(self.snp.width)
        }
        return temp
    }()
    
    private lazy var textField: A4xBaseTextField = {
        let temp = A4xBaseTextField()
        temp.inset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        temp.layer.cornerRadius = 6.auto()
        temp.layer.borderColor = UIColor.hex(0xDADBE0).cgColor
        temp.layer.borderWidth = 1
        temp.textColor = ADTheme.C1
        temp.textAlignment = .left
        self.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.top.equalTo(self.nameLable.snp.bottom).offset(16.auto())
            make.leading.equalTo(18.auto())
            make.width.equalTo(self.snp.width).offset(-40.auto())
            make.height.equalTo(36.auto())
        }
        return temp
    }()
    
    
    private lazy var leftView: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "alert_left_button"
        temp.addTarget(self, action: #selector(leftButtonAction), for: .touchUpInside)
        temp.titleLabel?.font = ADTheme.B1
        temp.setTitleColor(UIColor.hex(0x2F3742), for: .normal)
        self.addSubview(temp)
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "cancel"), for: .normal)

        temp.snp.makeConstraints { (make) in
            make.leading.equalTo(0)
            make.bottom.equalTo(self.snp.bottom)
            make.width.equalTo(self.snp.width).multipliedBy(0.5)
            make.height.equalTo(50.auto())

        }
        return temp
    }()
    
    private lazy var rightView: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "alert_right_button"
        temp.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        temp.titleLabel?.font = ADTheme.B1
        temp.setTitleColor(ADTheme.Theme, for: .normal)
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "confirm"), for: .normal)
        self.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.snp.trailing)
            make.bottom.equalTo(self.snp.bottom)
            make.width.equalTo(self.snp.width).multipliedBy(0.5)
            make.height.equalTo(50.auto())

        }
        return temp
    }()
    
    private func addNotcation() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    private func removeNotcation() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(noti: NSNotification) {
        guard noti.userInfo != nil else {
            return
        }
        
        let keyBoardHeight = ( noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey]  as? NSValue)?.cgRectValue.minY ?? 0
        let canShowMaxY = (UIScreen.main.bounds.height ) - keyBoardHeight
        let toFrameMinx = canShowMaxY - self.height
        let yOffset = self.minY + moveYValue - toFrameMinx
        if abs(yOffset) < 1 {
            return
        }
        moveYValue = yOffset
        
        let animilTime = ( noti.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]  as? NSNumber)?.floatValue ?? 0

        UIView.beginAnimations("keyshow", context: nil)
        UIView.setAnimationDuration(TimeInterval(animilTime))
        self.frame = CGRect(x: self.minX, y: toFrameMinx, width: self.width, height: self.height)
        UIView.commitAnimations()
    }
    
    @objc func keyboardWillHide(noti: NSNotification) {
        let animilTime = ( noti.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]  as? NSNumber)?.floatValue ?? 0

        UIView.beginAnimations("keyshow", context: nil)
        UIView.setAnimationDuration(TimeInterval(animilTime))
        self.frame = CGRect(x: self.minX, y: self.minY + moveYValue , width: self.width, height: self.height)
        UIView.commitAnimations()
        moveYValue = 0
    }
    

    @objc private func rightButtonAction() {
        self.onEditDone?(self.textField.text)

        let _ = self.textField.resignFirstResponder()
        let stripped = self.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        if stripped?.count ?? 0 > 0 {
            self.onHiddenBlock? {}
        }
    }
    
    @objc private func leftButtonAction() {
        
        self.onEditDone?("")
        let _ = self.textField.resignFirstResponder()
        self.onHiddenBlock? {}
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        
        ctx?.move(to: CGPoint(x: 0, y: self.height - 50.auto()))
        ctx?.addLine(to: CGPoint(x: self.width, y: self.height - 50.auto()))
        ctx?.move(to: CGPoint(x: self.width / 2 , y: self.height))
        ctx?.addLine(to: CGPoint(x: self.width / 2, y: self.height - 50.auto()))
        ctx?.setLineWidth(1)
        ctx?.setStrokeColor(UIColor.hex(0x000050, alpha: 0.1).cgColor)
        ctx?.drawPath(using: .stroke)

    }
}
