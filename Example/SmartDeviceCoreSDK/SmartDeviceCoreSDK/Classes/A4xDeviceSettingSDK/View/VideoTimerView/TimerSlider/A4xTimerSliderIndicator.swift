//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK

class A4xSliderIndicator : UIView {
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.imageV.isHidden = false
        self.timeLable.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var text : String? {
        didSet {
            self.timeLable.text = text
        }
    }
    
    override var frame: CGRect {
        didSet {
            self.imageV.frame = CGRect(x: (self.bounds.width - 27) / 2, y: 0, width: 27, height: 33)
            self.timeLable.frame = CGRect(x: 0, y: 3, width: 27, height: 20)
        }
    }
    
    private
    lazy var imageV : UIImageView = {
        let temp = UIImageView()
        temp.image = A4xDeviceSettingResource.UIImage(named: "slider_indicator")?.rtlImage()
        self.addSubview(temp)
        return temp
    }()
    
    private
    lazy var timeLable : UILabel = {
        let temp =  UILabel()
        self.addSubview(temp)
        temp.font = UIFont.systemFont(ofSize: 12)
        temp.textColor = UIColor.white
        temp.textAlignment = .center
        temp.text = "2h"
        return temp
    }()
}
