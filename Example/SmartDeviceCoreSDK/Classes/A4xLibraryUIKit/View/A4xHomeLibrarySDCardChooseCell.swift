

import Foundation
import SmartDeviceCoreSDK
import BaseUI

public enum A4xHomeLibrarySDCardChooseCellType {
    case offlineMode
    case normalMode
    case noCareMode
    case sleepMode
}

class A4xHomeLibrarySDCardChooseCell: UITableViewCell {
    
    override var isSelected: Bool {
        didSet {
            chooseButton.isSelected = isSelected
        }
    }
    
    var deviceModel: DeviceBean? {
        didSet {
            self.iconImgView.image = thumbImage(deviceID: deviceModel?.serialNumber ?? "")
            if deviceModel?.deviceState() == .sleep {
                self.type = .sleepMode
            } else if deviceModel?.deviceState() != .online {
                self.type = .offlineMode
            } else if (!(deviceModel?.hasSdCardAndSupport() ?? false))  {
                self.type = .noCareMode
            } else {
                self.type = .normalMode
            }
            self.titleLabel.text = deviceModel?.deviceName
        }
    }
    
    private var type: A4xHomeLibrarySDCardChooseCellType = .normalMode {
        didSet {
            switch type {
            case .offlineMode:
                self.shadowBgView.isHidden = false
                self.typeImgView.image = bundleImageFromImageName("sd_offline_mode")
                self.chooseButton.isEnabled = false
                self.titleLabel.textColor = UIColor.colorFromHex("#EFEFEF")
                break
            case .noCareMode:
                self.shadowBgView.isHidden = false
                self.typeImgView.image = bundleImageFromImageName("sd_no_card_mode")
                self.chooseButton.isEnabled = false
                self.titleLabel.textColor = UIColor.colorFromHex("#EFEFEF")
                break
            case .sleepMode:
                self.shadowBgView.isHidden = false
                self.typeImgView.image = bundleImageFromImageName("sd_sleep_mode")
                self.chooseButton.isEnabled = false
                self.titleLabel.textColor = UIColor.colorFromHex("#EFEFEF")
                break
            case .normalMode:
                self.shadowBgView.isHidden = true
                self.typeImgView.backgroundColor = .clear
                self.chooseButton.isEnabled = true
                self.titleLabel.textColor = UIColor.colorFromHex("#333333")
                break
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.iconImgView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.chooseButton)
        self.iconImgView.addSubview(self.shadowBgView)
        self.shadowBgView.addSubview(self.typeImgView)
        
        self.iconImgView.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.leading.equalTo(16.auto())
            make.size.equalTo(CGSizeMake(80, 45))
        }
        self.shadowBgView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(self.iconImgView)
        }
        self.typeImgView.snp.makeConstraints { make in
            make.size.equalTo(CGSizeMake(24, 24))
            make.centerX.centerY.equalTo(self.iconImgView)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.iconImgView.snp.trailing).offset(16.auto())
            make.trailing.equalTo(self.chooseButton.snp.leading).offset(-16.auto())
            make.centerY.equalTo(self)
            make.height.equalTo(22)
        }
        self.chooseButton.snp.makeConstraints { make in
            make.size.equalTo(CGSizeMake(16.auto(), 16.auto()))
            make.trailing.equalTo(-16.auto())
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var iconImgView: UIImageView = {
        var temp: UIImageView = UIImageView()
        temp.layer.masksToBounds = true
        temp.backgroundColor = .cyan
        temp.layer.cornerRadius = 5.5
        return temp
    }()
    
    private lazy var shadowBgView: UIView = {
        var temp: UIView = UIView()
        temp.layer.masksToBounds = true
        temp.layer.cornerRadius = 5.5
        temp.backgroundColor = UIColor.colorFromHex("#000000",alpha: 0.5)
        return temp
    }()
    
    private lazy var typeImgView: UIImageView = {
        var temp: UIImageView = UIImageView()
        return temp
    }()
    
    private lazy var titleLabel: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "Don’t want to miss any moment? Upgrade to get 30 days of video history."
        temp.textAlignment = .left
        temp.font = UIFont.regular(15)
        temp.textColor = UIColor.colorFromHex("#333333")
        temp.numberOfLines = 1
        return temp
    }()
    
    
    private lazy var chooseButton : UIButton = {
        var temp = UIButton()
        temp.isUserInteractionEnabled = false
        temp.setImage(bundleImageFromImageName("libary_tag_dis_select_icon")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("libary_tag_select_icon"), for: UIControl.State.selected)
        temp.setImage(bundleImageFromImageName("filter_tag_dis_select_icon"), for: UIControl.State.disabled)
        return temp
    }()
}
