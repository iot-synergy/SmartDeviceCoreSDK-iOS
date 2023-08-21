//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol A4xActivityZoneViewCellProtocol: class {
    func devicesCellClick(sender: UIImageView, indexPath: IndexPath)
}

class A4xActivityZoneViewCell: UITableViewCell {
    weak var `protocol`: A4xActivityZoneViewCellProtocol?
    var cellHeight: CGFloat = 0
    var indexPath: IndexPath?
    var dataSource : ZoneBean? {
        didSet {
            if dataSource == nil {
                self.messageView.dataSource = []
            } else {
                
                if ((dataSource?.errPoint ?? 0) != 0) {
                    self.settingIcon.image = A4xDeviceSettingResource.UIImage(named: "device_activity_del")?.rtlImage()
                    self.settingIcon.tag = 1
                } else {
                    self.settingIcon.image = A4xDeviceSettingResource.UIImage(named: "device_activity_setting")?.rtlImage()
                    self.settingIcon.tag = 0
                }
                self.messageView.dataSource = [dataSource!]
            }
            self.titleLabel.text = dataSource?.zoneName
            guard let sernum = dataSource?.serialNumber else {
                self.messageImageV.image = nil
                return
            }
            self.messageImageV.image = thumbImage(deviceID: sernum)
            self.updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.errorTipLbl.isHidden = true
        self.bgView.isHidden = false
        self.messageImageV.isHidden = false
        self.messageView.isHidden = false
        self.settingIcon.isHidden = false
        self.titleLabel.isHidden = false
        self.backgroundColor = UIColor.clear
        self.titleLabel.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    lazy var errorTipLbl: UILabel = {
        let temp = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "wrong_az_tips")
        temp.textColor = UIColor.colorFromHex("#E04F33")
        temp.numberOfLines = 0
        temp.textAlignment = .left
        temp.font = ADTheme.B3
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.contentView.snp.top)
            make.leading.equalTo(self.contentView.snp.leading).offset(16.auto())
            make.width.lessThanOrEqualTo(self.contentView.snp.width).offset(16.auto())
        })
        temp.layoutIfNeeded()
        cellHeight += temp.height
        return temp
    }()

    lazy var bgView: UIView = {
        let temp = UIView()
        self.contentView.addSubview(temp)
        temp.layer.cornerRadius = 8.auto()
        temp.clipsToBounds = true
        temp.backgroundColor = UIColor.white
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.errorTipLbl.isHidden ? self.contentView.snp.top : self.errorTipLbl.snp.bottom).offset(5.auto())
            make.height.equalTo(60.auto())
            make.width.equalTo(self.contentView.snp.width).offset(-30.auto())
            make.centerX.equalToSuperview()
        })
        temp.layoutIfNeeded()
        cellHeight += temp.height + 5.auto() + 5.auto()
        return temp
    }()
    
    lazy var messageImageV: UIImageView = {
        let temp = UIImageView()
        temp.backgroundColor = UIColor.black
        temp.layer.cornerRadius = 8.auto()
        temp.clipsToBounds = true
        temp.image = A4xDeviceSettingResource.UIImage(named: "acticity_cell_default")?.rtlImage()
        self.bgView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.messageView.snp.edges)
        })
        temp.layoutIfNeeded()
        return temp
    }()
    
    lazy var messageView: A4xActivityZoneRectView = {
        let temp = A4xActivityZoneRectView()
        self.bgView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(8.auto())
            make.centerY.equalTo(self.bgView.snp.centerY)
            make.size.equalTo(CGSize(width: 78.5.auto(), height: 44.auto()))
        })
        temp.layoutIfNeeded()
        return temp
    }()
    
    lazy var titleLabel: UILabel = {
        let temp = UILabel()
        temp.backgroundColor = ADTheme.C1
        temp.font = ADTheme.B1
        temp.lineBreakMode = .byTruncatingTail
        self.bgView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.messageView.snp.trailing).offset(14.auto())
            make.centerY.equalTo(self.messageView.snp.centerY)
            make.width.lessThanOrEqualTo(200.auto())
        })
        return temp
    }()
    
    lazy var settingIcon: UIImageView = {
        let temp = UIImageView()
        self.bgView.addSubview(temp)
        temp.isUserInteractionEnabled = true
        temp.image = A4xDeviceSettingResource.UIImage(named: "device_activity_setting")?.rtlImage()
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.bgView.snp.trailing).offset(-8.auto())
            make.centerY.equalTo(self.bgView.snp.centerY)
        })
        temp.addActionHandler { [weak self] in
            self?.protocol?.devicesCellClick(sender: temp, indexPath: self?.indexPath ?? IndexPath(row: 0, section: 0))
        }
        return temp
    }()
    
    func getCellHeight() -> CGFloat {
        return cellHeight
    }
    
    func updateUI() {
        self.bgView.snp.remakeConstraints({ (make) in
            make.top.equalTo(self.errorTipLbl.isHidden ? self.contentView.snp.top : self.errorTipLbl.snp.bottom).offset(5.auto())
            make.height.equalTo(60.auto())
            make.width.equalTo(self.contentView.snp.width).offset(-30.auto())
            make.centerX.equalToSuperview()
        })
        
        if self.errorTipLbl.isHidden {
            cellHeight = bgView.height + 5.auto() + 5.auto()
        }
        self.layoutIfNeeded()
    }
}
