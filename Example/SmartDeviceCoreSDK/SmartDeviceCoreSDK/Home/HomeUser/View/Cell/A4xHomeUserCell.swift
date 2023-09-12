//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xHomeContentView : UIView {
    
    override var intrinsicContentSize: CGSize {
        let tempsize = self.aNameLable.sizeThatFits(CGSize(width: self.width, height: 1000))
        let tempheight = tempsize.height
        let tempwidth = self.size.width
        let size = CGSize(width: tempwidth,height: tempheight)
        
        let tipSize = self.desLable.sizeThatFits(CGSize(width: self.width, height: 1000))
        
        if tipSize.height < 5 || tipSize.height.isNaN  {
            let nameFrame : CGRect = CGRect(x: 0, y: 2.auto(), width: size.width, height: size.height)
            self.aNameLable.frame = nameFrame
            self.desLable.frame = .zero
            return CGSize(width: self.width, height: nameFrame.maxY + 2.auto())
        }else {
            let nameFrame : CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            self.aNameLable.frame = nameFrame
            let desFrame : CGRect = CGRect(x: 0, y: nameFrame.maxY + 5.auto(), width: tipSize.width, height: tipSize.height)
            
            self.desLable.frame = desFrame
            return CGSize(width: self.width, height: desFrame.maxY )
        }
    }
    
    var tipAttrString : NSAttributedString? {
        didSet {
            self.desLable.attributedText = tipAttrString
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        }
    }
    
    var titleString : String? {
        didSet {
            self.aNameLable.text = titleString
            self.invalidateIntrinsicContentSize()
            self.layoutIfNeeded()
        }
    }
    
    
    private lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "test"
        temp.textAlignment = .left
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.B1
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        self.addSubview(temp)
        return temp;
    }();
    
    
    private lazy var desLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.B2
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        self.addSubview(temp)
        return temp;
    }();
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class A4xHomeUserCell : UITableViewCell {

    var iconImage : UIImage? {
        didSet {
            self.iconImageV.image = iconImage
        }
    }
    
    var tipAttrString : NSAttributedString? {
        didSet {
            self.textView.tipAttrString = tipAttrString
        }
    }
    
    var title : String? {
        didSet {
            self.textView.titleString = title
        }
    }
    
    var showPoint : Bool = false {
        didSet {
            self.updatePoint.isHidden = !showPoint
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.iconImageV.isHidden = false
        self.textView.isHidden = false
        self.arrowImageV.isHidden = false
        self.updatePoint.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy
    var textView : A4xHomeContentView = {
        let temp = A4xHomeContentView()
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(54.auto())
            make.trailing.equalTo(self.arrowImageV.snp.leading).offset(14.auto())
            make.top.equalTo(17.auto())
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-17.auto())
        }
        
        return temp
    }()
    
    private lazy
    var iconImageV : UIImageView = {
        var temp : UIImageView = UIImageView()
        self.contentView.addSubview(temp)
        temp.backgroundColor = UIColor.clear
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(13)
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        temp.image = bundleImageFromImageName("filter_tag_camera_icon")?.rtlImage()
        return temp;
    }()
    
    public lazy var arrowImageV : UIImageView = {
        var temp = UIImageView()
        temp.contentMode = .center
        temp.image = bundleImageFromImageName("home_user_info_arrow")?.rtlImage()
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-11)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 24, height: 24))
        })
        
        return temp
    }()
    
    lazy var updatePoint : UIView = {
        let temp = UIView()
        temp.layer.cornerRadius = 3.auto()
        temp.isUserInteractionEnabled = false
        temp.clipsToBounds = true
        temp.backgroundColor = ADTheme.E1
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.arrowImageV.snp.leading).offset(2.auto())
            make.width.equalTo(6.auto())
            make.height.equalTo(6.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        
        return temp
    }()
}

