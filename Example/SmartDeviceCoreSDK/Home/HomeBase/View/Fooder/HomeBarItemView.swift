//

//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

typealias ItemSelect = (Int) -> Void

class HomeBarItemView : UIControl {


    var barIndex : Int = 0
    
    var selectBlock : ItemSelect?

    var selectImage : UIImage?

    var nameTitle : String? {
        didSet {
            self.titleLable.text = nameTitle
        }
    }
    
    var normailImage : UIImage? {
        didSet {
            self.iconImageView.image = normailImage
        }
    }
    
    var titleColor : UIColor?{
        didSet {
            self.titleLable.textColor = titleColor
        }
    }
    
    var selectTitleColor : UIColor?
    
    private lazy var iconImageView : UIImageView = {
        let tem: UIImageView = UIImageView()
        tem.contentMode = .scaleAspectFit
        tem.image = bundleImageFromImageName("homepage_video")?.rtlImage()
        self.addSubview(tem)
        tem.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(8)

        }
        return tem;
    }()

    private lazy var titleLable : UILabel = {
        let tem: UILabel = UILabel()
        tem.text = "video"
        tem.font = ADTheme.B2
        tem.textColor = UIColor.black
        self.addSubview(tem)

        tem.snp.makeConstraints { make in
            make.top.equalTo(self.iconImageView.snp.bottom).offset(3)
            make.centerX.equalTo(self.snp.centerX)
        }
        return tem;
    }()
    
    override var isSelected: Bool {
        didSet {
            updateViewStyle(isSelect: isSelected)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if (isHighlighted && isHighlighted != oldValue){
                self.isSelected = true
                if self.selectBlock != nil {
                    self.selectBlock!(self.barIndex)
                }
            }
        }
    }

    private func updateViewStyle (isSelect : Bool){
        if isSelect {
            self.iconImageView.image = self.selectImage
            self.titleLable.textColor = self.selectTitleColor
        }else {
            self.iconImageView.image = self.normailImage
            self.titleLable.textColor = self.titleColor
        }
    }

    convenience init(){
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLable.isHidden = false
        self.iconImageView.isHidden = false
        self.clipsToBounds = true
        self.backgroundColor = UIColor.clear
        updateViewStyle(isSelect: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
