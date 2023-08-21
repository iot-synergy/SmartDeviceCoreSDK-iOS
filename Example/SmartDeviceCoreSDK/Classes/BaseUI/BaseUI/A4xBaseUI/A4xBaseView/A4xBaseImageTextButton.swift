

import Foundation
import UIKit
import SmartDeviceCoreSDK

public class A4xBaseImageTextButton: UIControl {
    public var selectimage : UIImage? {
        didSet {
            if self.isSelected {
                self.imageV?.image = selectimage
            }
        }
    }
    public var normailImage : UIImage?{
        didSet {
            if !self.isSelected && self.isEnabled {
                self.imageV?.image = normailImage
            }
        }
    }
    public var disableImage : UIImage?{
        didSet {
            if !self.isEnabled {
                self.imageV?.image = disableImage
            }
        }
    }
    
    public var selectTitle : String?{
        didSet {
            if self.isSelected {
                self.nameV?.text = selectTitle
            }
        }
    }
    public var normailTitle : String?{
        didSet {
            if !self.isSelected && self.isEnabled {
                self.nameV?.text = normailTitle
            }
        }
    }
    public var disableTitle : String?{
        didSet {
            if !self.isEnabled {
                self.nameV?.text = disableTitle
            }
        }
    }
    
    public override var isSelected: Bool {
        didSet {
            self.nameV?.text = isSelected ? selectTitle : normailTitle
            self.imageV?.image = isSelected ? selectimage : normailImage
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            self.nameV?.text = isEnabled ?  normailTitle : disableTitle
            self.imageV?.image = isEnabled ? normailImage : disableImage
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.nameV?.isHidden = false
        self.imageV?.isHidden = false
    }
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize{
        return CGSize(width: 44.auto(), height: 70.auto())
    }
    
    //MARK:- view 创建
    lazy var imageV : UIImageView? = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("video_replay")?.rtlImage()
        temp.layer.cornerRadius = 22.auto()
        temp.layer.borderColor = UIColor.hex(0xECEDEF).cgColor
        temp.layer.borderWidth = 1
        temp.contentMode = .center
        self.addSubview(temp)

        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(0)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(self.snp.width)
        })
        return temp
    }()
    
    lazy var nameV : UILabel? = {
        let temp = UILabel()
        temp.textColor = UIColor(white: 0.6, alpha: 1)
        temp.font = ADTheme.B2
        temp.numberOfLines = 0
        self.addSubview(temp)
        
        temp.text = A4xBaseManager.shared.getLocalString(key: "replay")
        
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.imageV!.snp.bottom).offset(8.auto())
        })
        return temp
    }()
}
