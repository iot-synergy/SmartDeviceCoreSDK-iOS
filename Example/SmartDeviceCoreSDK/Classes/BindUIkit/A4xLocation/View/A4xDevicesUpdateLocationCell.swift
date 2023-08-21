//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDevicesUpdateLocationCell: UITableViewCell{
    var title : String? {
        didSet {
            self.aNameLable.text = title
        }
    }
    
    var checked : Bool = false {
        didSet {
            self.checkImageV.isHidden = editMode || !self.checked
        }
    }
    
    var editMode : Bool = false {
        didSet {
            self.checkImageV.isHidden = editMode || !self.checked
            self.editImageV.isHidden = !editMode
        }
    }
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.aNameLable.isHidden = false
        self.checkImageV.isHidden = true
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private
    lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.B1
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(32.auto())
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-80.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp;
    }();
    
    private
    lazy var editImageV : UIImageView = {
        var temp = UIImageView()
        temp.contentMode = .center
        temp.image = A4xLocationResource.UIImage(named: "location_manager_edit")?.rtlImage()
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-32.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
    
    
    private
    lazy var checkImageV : UIImageView = {
        var temp = UIImageView()
        temp.contentMode = .center
        temp.image = bundleImageFromImageName("device_location_checked")
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-32.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
}


class A4xDevicesCreateLocationCell: UITableViewCell{
    
    
    var title : String? {
        didSet {
            self.aNameLable.text = title
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.aNameLable.isHidden = false
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private
    lazy var borderLayer : CAShapeLayer = {
        let temp = CAShapeLayer()
        temp.fillColor = UIColor.clear.cgColor
        temp.strokeColor = ADTheme.C5.cgColor
        temp.lineWidth = 2
        temp.lineDashPattern = [5,5]
        self.contentView.layer.insertSublayer(temp, at: 0)
        return temp
    }()
    
    private
    lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel();
        temp.textColor = ADTheme.C4
        temp.font = ADTheme.B1
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.contentView.snp.centerY).offset(5.auto())
            make.centerX.equalTo(self.contentView.snp.centerX)
        })
        return temp;
    }();
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = self.contentView.height - 12.auto()
        let rect = CGRect(x: height / 2.0 , y: 10.auto(), width: self.contentView.width - height , height: height)
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: height/2)
        self.borderLayer.path = path.cgPath
        
    }
    
}
