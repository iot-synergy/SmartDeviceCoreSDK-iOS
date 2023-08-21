//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xMediaPlayScrollLibrarySDCell: UITableViewCell {
    
    var dataSourceModel : RecordBean? { 
        didSet {
            let timeInterval : TimeInterval = self.dataSourceModel?.time ?? Date().timeIntervalSince1970
            let is24HrFormatStr = "".timeFormatIs24Hr() ? kA4xDateFormat_24 : kA4xDateFormat_12
            let languageFormat = "\(is24HrFormatStr)" 
            let dataString = DateFormatter.format(languageFormat).string(from: Date(timeIntervalSince1970: timeInterval))
            self.aTimeLable.text = dataString
        }
    }

    var editMode : Bool = false {
        didSet {
            self.checkButton.isHidden = !self.editMode
        }
    }
    
    var checked : Bool = false {
        didSet {
            if editMode {
                self.checkButton.isSelected = checked
            }
        }
    }
    
    
    var statusPlay: A4xMediaPlayScrollType = .playComple {
        didSet {
            
            
            updateFrame()
            
            switch statusPlay {
            case .playeStart: 
                self.aTimeLable.textColor = ADTheme.Theme
                break
            case .playStop: 
                fallthrough
            case .playComple: 
                self.aTimeLable.textColor = ADTheme.C3
                break
            case .playPause: 
                self.aTimeLable.textColor = ADTheme.Theme
                break
            }
        }
    }
    
    func updateFrame() {
        if statusPlay == .playeStart {
            self.leftLineCircle.layer.borderColor = ADTheme.Theme.cgColor
            self.leftLine.backgroundColor = ADTheme.Theme
        } else {
            self.leftLineCircle.layer.borderColor = UIColor.colorFromHex("#E0E0E1").cgColor
            self.leftLine.backgroundColor = UIColor.colorFromHex("#E0E0E1")
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        self.selectionStyle = .none
        
        
        self.contentView.addSubview(self.leftLineCircle)
        self.contentView.addSubview(self.leftLine)
        self.leftLineCircle.snp.makeConstraints({ (make) in
            make.top.equalTo(0.auto())
            make.leading.equalTo(12.auto())
            make.size.equalTo(CGSize(width: 8.auto(), height: 8.auto()))
        })
        self.leftLine.snp.makeConstraints ({ (make) in
            make.top.equalTo(self.leftLineCircle.snp.bottom)
            make.width.equalTo(1.auto())
            make.centerX.equalTo(self.leftLineCircle.snp.centerX)
            make.bottom.equalTo(self.snp.bottom)
        })
        
        
        
        self.contentView.addSubview(self.bgView)
        self.bgView.addSubview(self.aTimeLable)
        self.bgView.addSubview(self.checkButton)
        
        self.bgView.snp.makeConstraints ({ (make) in
            make.leading.equalTo(32.auto())
            make.trailing.equalTo(-16.auto())
            make.top.equalTo(0.auto())
            make.bottom.equalTo(-8.auto())
        })
        self.aTimeLable.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.bgView.snp.leading).offset(8.auto())
            make.trailing.equalTo(self.checkButton.snp.trailing).offset(-12.auto())
            make.height.equalTo(24.auto())
            make.centerY.equalTo(self.bgView)
        })
        self.checkButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
            make.trailing.equalTo(self.bgView.snp.trailing).offset(-12.auto())
            make.centerY.equalTo(self.aTimeLable.snp.centerY)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    
    private lazy var leftLineCircle : UIView = {
        var temp: UIView = UIView()
        temp.layer.masksToBounds = true
        temp.layer.borderColor = UIColor.colorFromHex("#E0E0E1").cgColor
        temp.layer.borderWidth = 2.auto()
        temp.layer.cornerRadius = 4.auto()
        return temp
    }()
    
    
    private lazy var leftLine : UIView = {
        var temp: UIView = UIView()
        temp.backgroundColor = UIColor.colorFromHex("#E0E0E1")
        return temp
    }()
    
    
    private lazy var bgView: UIView = {
        var temp = UIView()
        temp.backgroundColor = .white
        temp.layer.cornerRadius = 12.auto()
        return temp
    }()
    
    
    lazy var checkButton : UIButton = {
        var temp = UIButton()
        temp.imageView?.contentMode = .center
        temp.isUserInteractionEnabled = false
        temp.setImage(bundleImageFromImageName("libary_tag_dis_select_icon")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("libary_tag_select_icon"), for: UIControl.State.selected)
        //self.contentView.bringSubviewToFront(temp)
        self.bgView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
            make.trailing.equalTo(self.bgView.snp.trailing).offset(-12.auto())
            make.centerY.equalTo(self.aTimeLable.snp.centerY)
        })
        return temp
    }()
    
    
    private lazy var aTimeLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "AM 00:30"
        temp.font = ADTheme.H3
        temp.textColor = ADTheme.C3
        return temp
    }()
    
}


