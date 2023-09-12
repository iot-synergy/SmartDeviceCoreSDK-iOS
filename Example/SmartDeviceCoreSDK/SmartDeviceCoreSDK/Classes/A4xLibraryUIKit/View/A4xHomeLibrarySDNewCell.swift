//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI


class A4xHomeLibrarySDNewCell: UITableViewCell {
    
    var dataEventModel: RecordEventBean? {
        didSet {
            
            let timeInterval : TimeInterval = self.dataEventModel?.startTime ?? Date().timeIntervalSince1970
            let endTimeInterval : TimeInterval = self.dataEventModel?.endTime ?? Date().timeIntervalSince1970
            let is24Hr = "".timeFormatIs24Hr()
            let is24HrFormatStr = is24Hr ? kA4xDateFormat_24 : kA4xDateFormat_12
            let languageFormat = "\(is24HrFormatStr)" 
            
            let startDataString = DateFormatter.format(languageFormat).string(from: Date(timeIntervalSince1970: timeInterval))
            let endDataString =  DateFormatter.format(languageFormat).string(from: Date(timeIntervalSince1970: endTimeInterval))
           
            if (self.dataEventModel?.libraryCount ?? 0) > 1 {
                self.titleLabel.font = is24Hr ? ADTheme.H3 : UIFont.medium(11.5)
                self.titleLabel.text = startDataString + "—" + endDataString
            } else {
                self.titleLabel.font = ADTheme.H3
                self.titleLabel.text = startDataString
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.bgView)
        self.bgView.addSubview(self.titleLabel)
        self.bgView.addSubview(self.subtitleLabel)
        self.bgView.addSubview(self.arrowImgView)
        
        self.bgView.snp.makeConstraints { make in
            make.top.equalTo(8.auto())
            make.leading.equalTo(16.auto())
            make.trailing.equalTo(-16.auto())
            make.height.equalTo(63.auto())
        }
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(16.auto())
            make.top.equalTo(8.auto())
            make.trailing.equalTo(self.arrowImgView.snp.leading).offset(-8.auto())
            make.height.equalTo(25.auto())
        }
        self.subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(16.auto())
            make.top.equalTo(self.titleLabel.snp.bottom).offset(4.auto())
            make.trailing.equalTo(self.arrowImgView.snp.leading).offset(-8.auto())
            make.height.equalTo(18.auto())
        }
        self.arrowImgView.snp.makeConstraints { make in
            make.trailing.equalTo(self.bgView.snp.trailing).offset(-16.auto())
            make.centerY.equalTo(self.bgView)
            make.size.equalTo(CGSize(width: 16.auto(), height: 16.auto()))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var bgView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        temp.layer.cornerRadius = 12.auto()
        temp.layer.masksToBounds = true
        return temp
    }()
    
    private lazy var titleLabel: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "时间1 - 时间2"
        temp.textAlignment = .left
        temp.font = UIFont.medium(18)
        temp.textColor = UIColor.colorFromHex("#333333")
        temp.numberOfLines = 1
        return temp
    }()
    
    private lazy var subtitleLabel: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "智能相机"
        temp.textAlignment = .left
        temp.font = UIFont.regular(13)
        temp.textColor = UIColor.colorFromHex("#999999")
        temp.numberOfLines = 1
        return temp
    }()
    
    private lazy var arrowImgView: UIImageView = {
        var temp: UIImageView = UIImageView()
        temp.image = bundleImageFromImageName("home_user_info_arrow")?.rtlImage()
        return temp
    }()
}
