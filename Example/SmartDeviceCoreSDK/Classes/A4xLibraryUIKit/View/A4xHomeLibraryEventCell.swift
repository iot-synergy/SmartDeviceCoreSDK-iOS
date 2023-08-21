//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xHomeLibraryEventCell: UITableViewCell {

    
    var isEditModel: Bool = false {
        didSet {
            self.chooseButton.isHidden = !self.isEditModel
        }
    }
    
    
    var isBeSelected: Bool = false {
        didSet {
            if isEditModel {
                self.chooseButton.isSelected = isBeSelected
            }
        }
    }
    
    
    var dataSourceChangeBlock: ((RecordEventBean?) -> Void)?
    var dataEventModel: RecordEventBean?
    
    var bytesCount: Int = 0
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.contentImageView) 
        self.contentView.addSubview(self.sourceTypeImageV) 
        self.contentView.addSubview(self.videoTimeLabel) 
        self.contentView.insertSubview(self.layerViewOne , belowSubview: self.contentImageView)
        self.contentView.insertSubview(self.layerViewTwo , belowSubview: self.layerViewOne)
        self.layerViewOne.isHidden = true
        self.layerViewTwo.isHidden = true
        self.contentView.addSubview(self.aTimeLable) 
        self.contentView.addSubview(self.readStateImageV) 
        self.contentView.addSubview(self.aNameLable) 
        self.contentView.addSubview(self.chooseButton)
        
        self.contentImageView.snp.makeConstraints({ (make) in
            make.leading.equalTo(16.auto())
            make.width.equalTo(160.auto())
            make.top.equalTo(self.contentView.snp.top).offset(8)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-11)
        })
        
        self.sourceTypeImageV.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 16, height: 16))
            make.leading.equalTo(self.contentImageView.snp.leading).offset(7.auto())
            make.bottom.equalTo(self.contentImageView.snp.bottom).offset(-8.5.auto())
        })
        
        self.videoTimeLabel.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentImageView.snp.trailing).offset(-7)
            make.bottom.equalTo(self.contentImageView.snp.bottom).offset(-7)
        })
        
        self.layerViewOne.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentImageView.snp.bottom).offset(-6.auto())
            make.leading.equalTo(self.contentImageView.snp.leading).offset(8.auto())
            make.height.equalTo(10.auto())
            make.trailing.equalTo(self.contentImageView.snp.trailing).offset(-8.auto())
        }
        
        self.layerViewTwo.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentImageView.snp.bottom).offset(-2.auto())
            make.leading.equalTo(self.contentImageView.snp.leading).offset(16.auto())
            make.height.equalTo(10.auto())
            make.trailing.equalTo(self.contentImageView.snp.trailing).offset(-16.auto())
        }
        
        self.aTimeLable.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.contentImageView.snp.trailing).offset(10.auto())
            make.top.equalTo(self.contentImageView.snp.top).offset(0)
            make.height.equalTo(25.auto())
        })
        
        self.readStateImageV.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.aTimeLable.snp.trailing).offset(2)
            make.centerY.equalTo(self.aTimeLable.snp.centerY)
            make.size.equalTo(CGSize(width: 24, height: 24))
        })
        
        self.aNameLable.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.contentImageView.snp.trailing).offset(10.auto())
            make.top.equalTo(self.aTimeLable.snp.bottom).offset(2.auto())
            make.width.lessThanOrEqualTo(self.contentView.width - 176.auto() - 14.auto())
            make.height.equalTo(18.5.auto())
        })
        
        self.chooseButton.snp.makeConstraints { make in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-20.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func updateEventSources() {
        
        if self.dataEventModel?.imageUrl != nil {
            weak var weakSelf = self
            self.contentImageView.yy_setImage(with: URL(string: (self.dataEventModel?.imageUrl)!), placeholder: UIImage.init(color: UIColor.colorFromHex("#F5F5F5")), options: .allowInvalidSSLCertificates) { (image, url, type, stage, error) in

            }
            
        } else {
            self.contentImageView.image = nil
        }
        
        self.sourceTypeImageV.isHidden = false
        self.videoTimeLabel.isHidden = false
        if self.dataEventModel?.period != -1 {
            let time = Int64(floorf(self.dataEventModel?.period ?? 0))
            self.videoTimeLabel.text = String(format: "%02d:%02d", time / 60, time % 60)
        } else {
            self.videoTimeLabel.text = "-:-"
        }
        
        if self.dataEventModel?.libraryCount ?? 0 == 2 {
            self.layerViewTwo.isHidden = true
            self.layerViewOne.isHidden = false
        } else if self.dataEventModel?.libraryCount ?? 0 > 2 {
            self.layerViewTwo.isHidden = false
            self.layerViewOne.isHidden = false
        } else  {
            self.layerViewTwo.isHidden = true
            self.layerViewOne.isHidden = true
        }
        
        let timeInterval : TimeInterval = self.dataEventModel?.startTime ?? Date().timeIntervalSince1970
        let endTimeInterval : TimeInterval = self.dataEventModel?.endTime ?? Date().timeIntervalSince1970
        let is24Hr = "".timeFormatIs24Hr()
        let is24HrFormatStr = is24Hr ? kA4xDateFormat_24 : kA4xDateFormat_12

        let languageFormat = "\(is24HrFormatStr)" 
        
        let startDataString = DateFormatter.format(languageFormat).string(from: Date(timeIntervalSince1970: timeInterval))
        let endDataString =  DateFormatter.format(languageFormat).string(from: Date(timeIntervalSince1970: endTimeInterval))
       
        if (self.dataEventModel?.libraryCount ?? 0) > 1 {
            self.aTimeLable.font = is24Hr ? ADTheme.H3 : UIFont.medium(11.5)
            self.aTimeLable.text = startDataString + "—" + endDataString
            self.readStateImageV.snp.updateConstraints({ (make) in
                make.leading.equalTo(self.aTimeLable.snp.trailing).offset(0)
            })
        } else {
            self.aTimeLable.font = ADTheme.H3
            self.aTimeLable.text = startDataString
            self.readStateImageV.snp.updateConstraints({ (make) in
                make.leading.equalTo(self.aTimeLable.snp.trailing).offset(4)
            })
        }
        
        let state : A4xLibraryVideoReadStateType = self.dataEventModel?.getState() ?? .read
        switch (state) {
        case .unread:
            self.readStateImageV.image = bundleImageFromImageName("main_libary_unread_icon")?.rtlImage()
        case .read:
            self.readStateImageV.image = nil
        case .mark:
            self.readStateImageV.image = bundleImageFromImageName("main_libary_mark_icon")?.rtlImage()
        }
        
        self.aNameLable.text = self.dataEventModel?.deviceName
    }

    private lazy var contentImageView: UIImageView = {
        var temp: UIImageView = UIImageView()
        temp.backgroundColor = ADTheme.C5
        temp.clipsToBounds = true
        temp.layer.cornerRadius = 11
        temp.contentMode = .scaleAspectFill
        temp.image = nil
        return temp
    }()
    
    
    private lazy var sourceTypeImageV: UIImageView = {
        var temp: UIImageView = UIImageView()
        temp.image = A4xBaseResource.UIImage(named: "main_libary_video_icon")?.rtlImage()
        return temp
    }()
    
    
    private lazy var videoTimeLabel: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "00:30"
        temp.font = ADTheme.B2
        temp.textColor = UIColor.white
        return temp
    }()
    
    
    private lazy var layerViewOne: UIView = {
        let temp = UIView()
        let bgLayer1 = CALayer()
        temp.frame = CGRect(x: 24.auto(), y: 85.auto(), width: 144.auto(), height: 10.auto())
        bgLayer1.frame = temp.bounds
        bgLayer1.cornerRadius = 5.auto()
        bgLayer1.masksToBounds = true
        bgLayer1.backgroundColor = UIColor(red: 0.77, green: 0.77, blue: 0.77, alpha: 1).cgColor
        temp.layer.addSublayer(bgLayer1)
        return temp
    }()
    
    
    private lazy var layerViewTwo: UIView = {
        let temp = UIView()
        let bgLayer1 = CALayer()
        temp.frame = CGRect(x: 30.auto(), y: 90.auto(), width: 128.auto(), height: 10.auto())
        bgLayer1.frame = temp.bounds
        bgLayer1.cornerRadius = 5.auto()
        bgLayer1.masksToBounds = true
        bgLayer1.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1).cgColor
        temp.layer.addSublayer(bgLayer1)
        return temp
    }()
    
    
    private lazy var aTimeLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "12:00:00-12:00:11"
        temp.font = ADTheme.H3
        temp.textColor = ADTheme.C1
        return temp
    }()
    
    
    private lazy var readStateImageV: UIImageView = {
        var temp: UIImageView = UIImageView()
        temp.contentMode = .center
        return temp
    }()
    
    
    lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "smart_camera")//"Smart Device"
        temp.font = ADTheme.B2
        temp.textAlignment = .left
        temp.lineBreakMode = .byTruncatingTail
        temp.textColor = ADTheme.C4
        return temp
    }()
    
    private lazy var chooseButton : UIButton = {
        var temp = UIButton()
        temp.isUserInteractionEnabled = false
        temp.setImage(bundleImageFromImageName("libary_tag_dis_select_icon")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("libary_tag_select_icon"), for: UIControl.State.selected)
        return temp
    }()

}

