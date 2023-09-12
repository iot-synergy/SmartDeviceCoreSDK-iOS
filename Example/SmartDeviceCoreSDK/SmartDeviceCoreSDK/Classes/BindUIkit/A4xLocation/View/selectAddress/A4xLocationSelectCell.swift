//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xLocationSelectCell : UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleView.isHidden = false
        self.lineView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var title : (value : String? , placeHoder : Bool)? {
        didSet {
            self.titleView.text = self.title?.value
            if self.title?.placeHoder ?? false {
                self.titleView.textColor = ADTheme.C4
            }else {
                self.titleView.textColor = ADTheme.C1
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.lineView.isHidden = !isSelected
        }
    }
    
    private
    lazy var titleView : UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.B2
        temp.textColor = ADTheme.C1
        temp.setContentHuggingPriority(.required, for: .horizontal)
        self.addSubview(temp)
        temp.text = A4xBaseManager.shared.getLocalString(key: "district_country")
        temp.snp.makeConstraints({ (make) in


//

            make.leading.equalTo(15.auto())
            make.trailing.equalTo(self.snp.trailing).offset(-15.auto())
            make.centerY.equalTo(self.snp.centerY)

        })
        
        return temp
    }()
    
    private
    lazy var lineView : UIView = {
        let temp = UIView()
        temp.backgroundColor = ADTheme.Theme
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(2)
            make.width.equalTo(22.auto())
            make.centerX.equalTo(self.snp.centerX)
        })
        
        return temp
    }()
}
