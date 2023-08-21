//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xAddLocationCell : UITableViewCell {
    var title : String?
    var placeHolder : String?
    var value : String?
    var type : A4xAddLocationEnum?
    var maxInput : Int = 50
    var editInfoBlock : ((_ type : A4xAddLocationEnum ,_  value : String?)->Void)?
}


class A4xAddLocationRemove: A4xAddLocationCell {
    override var title : String? {
        didSet {
            self.aNameLable.text = title
        }
    }
    var selectBackgroundColor : UIColor? {
        didSet {
            updateSelectBgColor()
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.aNameLable.isHidden = false
        self.selectBackgroundColor = ADTheme.C6
        updateSelectBgColor()
    }
    
    private func updateSelectBgColor() {
        let view = UIView()
        view.backgroundColor = self.selectBackgroundColor
        self.selectedBackgroundView = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.font = UIFont.regular(16)
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let type = self.type else {
            return
        }
        self.editInfoBlock?(type , nil)
    }
}

class A4xAddLocationInputCell: A4xAddLocationCell {
    
    override var placeHolder: String? {
        didSet {
            self.inputV.placeholder = placeHolder
        }
    }
    
    override var title: String? {
        didSet {
            self.titleV.text = title
        }
    }
    
    override var value: String? {
        didSet {
            self.inputV.text = value
        }
    }
    
    override var maxInput: Int {
        didSet {
            self.inputV.setMaxTextsCount(maxChar: maxInput)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.titleV.isHidden = false
        self.inputV.isHidden = false
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleV: UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.B0
        temp.textColor = ADTheme.C1
        temp.text = A4xBaseManager.shared.getLocalString(key: "location_name")
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.contentView.snp.top).offset(15.auto())
            make.leading.equalTo(16.auto())
        })
        return temp
    }()
    
    private lazy var inputV: A4xBaseTextField = {
        var temp: A4xBaseTextField = A4xBaseTextField()
        temp.accessibilityIdentifier = "login_accountV"
        temp.placeholderTextColor = ADTheme.C3
        temp.backgroundColor = UIColor.clear
        temp.font = ADTheme.B1
        temp.textColor = ADTheme.C1
        temp.addTarget(self, action: #selector(editTextView), for: .editingChanged)
        temp.addTarget(self, action: #selector(beginInputAction), for: .editingDidBegin)
        temp.clearButtonMode = .whileEditing
        temp.textAlignment = .left
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.top.equalTo(self.titleV.snp.bottom)
            make.height.equalTo(50.auto())
            make.width.equalTo(self.contentView.snp.width).offset(-32.auto())
            make.bottom.equalTo(self.contentView.snp.bottom).offset(4.auto())
        })
        temp.addLineStyle()
        
        return temp
    }()
    
    @objc func beginInputAction() {
        self.inputV.maxLength = self.maxInput//setMaxTextsCount(maxChar: self.maxInput)
    }
    
    @objc func editTextView() {
        guard let type = self.type else {
            return
        }
        self.editInfoBlock?(type, self.inputV.text?.subCLength(length: self.maxInput))
    }
}

class A4xAddLocationAddressCell : A4xAddLocationCell {
    var locationBlock : (()->Void)?
    var isLocationing : Bool = false //正在定位中
    {
        didSet {
            self.postionV.isEnabled = !isLocationing
        }
    }
   
    override var placeHolder: String?{
        didSet {
            self.infoView.attributedText = self.loadAttrFrame()
        }
    }
    
    override var value: String?{
        didSet {
            self.infoView.attributedText = self.loadAttrFrame()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.postionV.isHidden = false
        self.infoView.isHidden = false
        self.lineV.isHidden = false
        self.selectionStyle = .none
        
        self.infoView.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var infoView: UILabel = {
        let temp = UILabel()
        temp.backgroundColor = UIColor.clear
        temp.font = ADTheme.B1
        temp.textColor = ADTheme.C3
        temp.lineBreakMode = .byWordWrapping
        temp.numberOfLines = 0
        self.contentView.addSubview(temp)
        temp.setContentHuggingPriority(.required, for: .vertical)

        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(15.auto())
            make.leading.equalTo(16.auto())
            make.height.greaterThanOrEqualTo(30.auto())
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-96.auto())
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-10.auto())
        })
        
        return temp
    }()
    
    lazy var postionV: UIButton = {
        let temp = UIButton()
        temp.backgroundColor = UIColor.clear
        temp.contentHorizontalAlignment = .right
        self.contentView.addSubview(temp)
        temp.setTitleColor(UIColor.hex(0x007AFF), for: .normal)
        temp.titleLabel?.font = ADTheme.B2
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "location"), for: .normal)
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "locating"), for: .disabled)
        temp.setImage(A4xLocationResource.UIImage(named: "location_position")?.rtlImage(), for: .normal)
        temp.addTarget(self, action: #selector(locationAction), for: .touchUpInside)
        temp.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0)
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(4.auto())
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-16.auto())
            make.size.equalTo(CGSize(width: 110.auto(), height: 40))
        })
        
        return temp
    }()
    
    
    lazy var lineV: UIView = {
        let nTipView = UIView()
        nTipView.backgroundColor = ADTheme.C3.withAlphaComponent(0.3)
        self.contentView.addSubview(nTipView)
        nTipView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp.bottom).offset(-1)
            make.width.equalTo(self.snp.width).offset(-32.auto())
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.height.equalTo(1)
        }
        return nTipView
    }()
    
    private func loadAttrFrame() -> NSAttributedString {
        let lineSpace : CGFloat = 4
        let str : String = self.value ?? (self.placeHolder ?? "")
        let isPlaceHoder : Bool = self.value == nil
        
        let attrString = NSMutableAttributedString(string: str)
        let param = NSMutableParagraphStyle()
        param.lineSpacing = lineSpace
        param.lineBreakMode = .byWordWrapping
        let attr: [NSAttributedString.Key : Any] = [.font : ADTheme.B1, .foregroundColor : isPlaceHoder ? ADTheme.C3 : ADTheme.C1, .paragraphStyle : param]
        
        attrString.addAttributes(attr, range: NSRange(location: 0, length: attrString.length))
        
        return attrString
    }
    
    @objc func locationAction() {
        self.isLocationing = true
        self.locationBlock?()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let point = touch?.location(in: self) ?? .zero
        if self.infoView.frame.contains(point) {
            if let type = self.type  {
                self.editInfoBlock?(type , nil)
            }
        }
    }
}
