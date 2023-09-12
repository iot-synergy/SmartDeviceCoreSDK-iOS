//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xLocationPlaceCell : UITableViewCell {
    var checked : Bool = false {
        didSet {
            if checked {
                self.titlelable.textColor = ADTheme.Theme
                self.backgroundColor = ADTheme.C6
                self.checkButton.isHidden = false
            }else {
                self.titlelable.textColor = ADTheme.C2
                self.backgroundColor = UIColor.white
                self.checkButton.isHidden = true

            }
        }
    }
    
    var title : String? {
        didSet {
            self.titlelable.text = title
        }
    }
    
    var cimage : UIImage? {
        didSet {
            self.imageV.image = cimage
            if cimage != nil {
                self.titlelable.snp.updateConstraints { (make) in
                    make.leading.equalTo(44.auto())
                }
            }else {
                self.titlelable.snp.updateConstraints { (make) in
                    make.leading.equalTo(15.auto())
                }
            }
            
        }
    }
    
    
    private
    lazy var imageV : UIImageView = {
        let imageV = UIImageView()
        imageV.tag = 1001
        self.contentView.addSubview(imageV)
        
        imageV.snp.makeConstraints { (make) in
            make.leading.equalTo(15.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        return imageV
    }()
    
    
    
    private
    lazy var titlelable : UILabel = {
        let lable = UILabel()
        lable.tag = 1000
        lable.textColor = ADTheme.C2
        lable.font = ADTheme.H3
        self.contentView.addSubview(lable)
        
        lable.snp.makeConstraints { (make) in
            make.leading.equalTo(44.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        
        return lable
    }()
    
    private lazy var checkButton : UIButton = {
        var temp = UIButton()
        temp.isUserInteractionEnabled = false
        self.contentView.addSubview(temp)
        temp.setImage(bundleImageFromImageName("filter_tag_select_icon"), for: UIControl.State.normal)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-16.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 25.auto(), height: 25.auto()))
        })
        
        return temp
    }()
}
