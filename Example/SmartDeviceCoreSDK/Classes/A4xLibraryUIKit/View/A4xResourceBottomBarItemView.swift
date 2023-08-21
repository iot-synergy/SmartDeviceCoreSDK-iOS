//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

typealias SelectType = (A4xResourceBottomStyle) -> Void


class A4xResourceBottomBarItemView: UIControl {
    static let defaultSelectTextColor =  UIColor.white
    static let defaultSelectBgColor =  UIColor.white

    static let defaultDisEnableTextColor =  UIColor.white.withAlphaComponent(1.0)
    
    static let defaultTextColor =  ADTheme.C4
    static let defaultBgColor =  UIColor.white
    
    var selectedTextColor: UIColor = defaultSelectTextColor {
        didSet {updateViewStyle()}
    }
    var selectedBgColor: UIColor = defaultSelectBgColor{
        didSet {updateViewStyle()}
    }
    
    var textColor: UIColor = defaultTextColor{
        didSet {updateViewStyle()}
    }
    
    var bgColor: UIColor = defaultBgColor{
        didSet {updateViewStyle()}
    }

    var barType: A4xResourceBottomStyle {
        didSet {
            self.tag = barType.rawValue
        }
    }
    var selectBlock: SelectType?
    
    var highlightedSelected: Bool = true
    
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
        tem.contentMode = .scaleAspectFit
        tem.image = bundleImageFromImageName("homepage_video")?.rtlImage()
        self.addSubview(tem)
        tem.snp.makeConstraints { make in
            make.height.equalTo(24.auto())
            make.width.equalTo(24.auto())
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(7)
        }
        return tem
    }()
    
    private lazy var titleLable: UILabel = {
        let tem: UILabel = UILabel()
        tem.text = "video"
        tem.font = ADTheme.B1
        tem.textColor = UIColor.black
        self.addSubview(tem)
        
        tem.snp.makeConstraints { make in
            make.top.equalTo(self.iconImageView.snp.bottom).offset(1)
            make.centerX.equalTo(self.snp.centerX)
        }
        return tem
    }()
    
    override var isEnabled: Bool {
        didSet {
            if oldValue != isEnabled {
                updateViewStyle()
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateViewStyle()

        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if (isHighlighted != oldValue){
                if highlightedSelected {
                    self.isSelected = true
                }
                updateViewStyle()
                if self.selectBlock != nil && isHighlighted{
                    self.selectBlock!(self.barType)
                }
            }
        }
    }
    
    private func updateViewStyle() {
        if !self.isEnabled { 
            self.backgroundColor = ADTheme.Theme
            self.titleLable.textColor = A4xResourceBottomBarItemView.defaultDisEnableTextColor
            if let name = self.imageName {
                self.iconImageView.image = bundleImageFromImageName(name)?.rtlImage()
                self.iconImageView.alpha = 0.7
            }
        } else {
            if self.isSelected {
                if let name = self.selectImageName {
                    self.iconImageView.image = bundleImageFromImageName(name)?.rtlImage()
                    self.iconImageView.alpha = 1

                }
            } else {
                if let name = self.imageName {
                    self.iconImageView.image = bundleImageFromImageName(name)?.rtlImage()
                    self.iconImageView.alpha = 1
                }
            }
            self.titleLable.textColor = A4xResourceBottomBarItemView.defaultSelectTextColor

        }
   
      
    }
    
    convenience init(style : A4xResourceBottomStyle){
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
        updateViewStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
