//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xMediaPlayerBarItem: UIControl {
    static let defaultSelectTextColor =  UIColor.black
    static let defaultSelectBgColor =  UIColor.lightGray

    static let defaultTextColor =  UIColor.lightGray
    static let defaultBgColor =  UIColor(white: 1, alpha: 1)
    
    var selectedTextColor : UIColor = defaultSelectTextColor {
        didSet {updateViewStyle(isSelect: self.isSelected)}
    }
    var selectedBgColor : UIColor = defaultSelectBgColor{
        didSet {updateViewStyle(isSelect: self.isSelected)}
    }
    
    var textColor : UIColor = defaultTextColor{
        didSet {updateViewStyle(isSelect: self.isSelected)}
    }
    var bgColor : UIColor = defaultBgColor{
        didSet {updateViewStyle(isSelect: self.isSelected)}
    }

    var barType : A4xMediaPlayerItemType {
        didSet {
            self.tag = barType.rawValue
        }
    }
    var selectBlock : ((A4xMediaPlayerItemType)->Void)?
    
    var highlightedSelected : Bool = true
    
    override var isSelected: Bool {
        didSet{
            updateViewStyle(isSelect: isSelected)
        }
    }
    
    var nameTitle: String? {
        didSet {
            self.titleLable.text = nameTitle
        }
    }
    
    var imageName: String? {
        didSet {
            self.iconImageView.image = bundleImageFromImageName(imageName ?? "")?.rtlImage()
        }
    }
    
    var selectImageName: String?
    
    private lazy var iconImageView: UIImageView = {
        let tem: UIImageView = UIImageView()
        tem.isUserInteractionEnabled = false
        self.addSubview(tem)
        tem.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(24)
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(8)
        }
        return tem
    }()
    
    private lazy var titleLable: UILabel = {
        let tem: UILabel = UILabel()
        tem.text = "video"
        tem.font = ADTheme.B2
        tem.textColor = .white
        tem.isUserInteractionEnabled = false
        self.addSubview(tem)
        
        tem.snp.makeConstraints { make in
            make.top.equalTo(self.iconImageView.snp.bottom)
            make.centerX.equalTo(self.snp.centerX)
        }
        return tem
    }()
    
    private func updateViewStyle(isSelect: Bool) {
   
        UIView.animate(withDuration: 0.3) {
            if isSelect{
                if let name = self.selectImageName {
                    self.iconImageView.image = bundleImageFromImageName(name)?.rtlImage()
                }
            }else {
                if let name = self.imageName {
                    self.iconImageView.image = bundleImageFromImageName(name)?.rtlImage()
                }
            }
        }
    }
    
    convenience init(style: A4xMediaPlayerItemType) {
        self.init(frame: CGRect.zero)
        self.barType = style
    }
    
    override init(frame: CGRect = .zero) {
        self.barType = .delete
        super.init(frame: frame)
        self.backgroundColor = ADTheme.Theme
        self.titleLable.isHidden = false
        self.iconImageView.isHidden = false
        self.clipsToBounds = true
        updateViewStyle(isSelect: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateViewStyle(isSelect: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.selectBlock != nil {
            self.selectBlock!(self.barType)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
