//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xHomeLibraryTableHeaderCell: UICollectionViewCell {
    var name : String? {
        didSet {
            self.nameLabel.text = name
        }
    }
    var indexPath : IndexPath?
    var deleteActionBlock : ((IndexPath?) -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.deleteBtn.isHidden = false
        self.nameLabel.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var deleteBtn: UIButton = {
        var temp: UIButton = UIButton();
        temp.setImage(bundleImageFromImageName("home_libary_header_delete")?.rtlImage(), for: UIControl.State.normal)
        temp.addTarget(self, action: #selector(deleteAction(id:)), for: UIControl.Event.touchUpInside)
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.leading.equalTo(4)
            make.size.equalTo(CGSize(width: 18, height: 18))
        })
        return temp;
    }();
    
    private lazy var nameLabel: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "Filter name"
        temp.font = ADTheme.B2
        temp.textColor = ADTheme.C2
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.deleteBtn.snp.trailing).offset(4);
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
        })
        return temp;
    }();
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.height/2
        self.clipsToBounds = true
        self.contentView.backgroundColor = ADTheme.C5
    }
    
    @objc func deleteAction(id : UIButton){
        if let b = deleteActionBlock {
            b(self.indexPath)
        }
    }
}
