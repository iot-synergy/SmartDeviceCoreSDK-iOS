//


//


//

import UIKit
import Lottie
import SmartDeviceCoreSDK
import BaseUI


class A4xMediaPlayScrollLibraryCell: UITableViewCell {
    
    var dataSourceModel : RecordBean? { 
        didSet {
            updateSourcesEvent()
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

    var cellHeight: CGFloat = 16.auto() + 81.auto() + 8.auto()
    var imgsHeight: CGFloat = 0.0
    var rowNum : Int = 0
    
    
    var resourceVideoDesTags : ([A4xLibraryVideoAiTagType]?, [String]?) {
        didSet {
            let tuple: (CGFloat, Bool) = self.mediaTypeImg?.configResourceLineFeedTags(isEvent: true, hasPossibleSubcategory: self.dataSourceModel?.hasPossibleSubcategory ?? false, sources: resourceVideoDesTags) ?? (0, false)
            cellHeight = tuple.0
            self.mediaTypeImg?.snp.remakeConstraints({ make in
                make.leading.trailing.equalTo(0)
                make.top.equalTo(self.contentImage.snp.bottom).offset(8.auto())
                make.height.equalTo(cellHeight)
            })
            
            
            imgsHeight = self.pureAiImages.configBottomTagAiImageView(sources: resourceVideoDesTags)
            self.pureAiImages.snp.makeConstraints { make in
                make.leading.trailing.equalTo(0)
                make.height.equalTo(imgsHeight)
                make.top.equalTo(self.contentImage.snp.bottom).offset(8.auto())
            }
        }
    }
    
    var statusPlay: A4xMediaPlayScrollType = .playComple {
        didSet {
            
            
            updateFrame()
            
            switch statusPlay {
            case .playeStart: 
                self.bePlayingAnimationView.isHidden = false
                self.bePlayingAnimationView.play()
                self.sourceTypeImageV.isHidden = true
                self.aTimeLable.textColor = ADTheme.Theme
                
                self.mediaTypeImg?.isHidden = false
                
                self.pureAiImages.isHidden = true
                break
            case .playStop: 
                fallthrough
            case .playComple: 
                self.bePlayingAnimationView.isHidden = true
                self.bePlayingAnimationView.stop()
                self.aTimeLable.textColor = ADTheme.C3
                
                self.sourceTypeImageV.isHidden = false
                
                self.mediaTypeImg?.isHidden = true
                
                self.pureAiImages.isHidden = false
                break
            case .playPause: 
                self.aTimeLable.textColor = ADTheme.Theme
                
                self.sourceTypeImageV.isHidden = false
                
                self.mediaTypeImg?.isHidden = false
                
                self.pureAiImages.isHidden = true
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
        self.bgView.snp.makeConstraints ({ (make) in
            make.leading.equalTo(32.auto())
            make.trailing.equalTo(-16.auto())
            make.top.equalTo(0.auto())
            make.bottom.equalTo(-8.auto())
        })
        
        
        self.bgView.addSubview(self.contentImage)
        self.contentImage.snp.makeConstraints({ (make) in
            make.top.equalTo(8.auto())
            make.leading.equalTo(8.auto())
            make.width.equalTo(144.auto())
            make.height.equalTo(81.auto())
        })
        
        
        self.contentImage.addSubview(self.sourceTypeImageV)
        self.sourceTypeImageV.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 16, height: 16))
            make.leading.equalTo(self.contentImage.snp.leading).offset(8.auto())
            make.bottom.equalTo(self.contentImage.snp.bottom).offset(-5.auto())
        })
        
        
        self.contentImage.addSubview(self.videoTimeLabel)
        self.videoTimeLabel.snp.makeConstraints({ (make) in
            make.trailing.equalTo(-8.auto())
            make.centerY.equalTo(self.sourceTypeImageV)
        })
        
        
        self.bgView.addSubview(self.aTimeLable)
        self.aTimeLable.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.contentImage.snp.trailing).offset(12.auto())
            make.top.equalTo(self.contentImage.snp.top).offset(20.auto())
            make.height.equalTo(24.auto())
        })
        
        
        self.bgView.addSubview(self.readStateImageV)
        self.readStateImageV.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.aTimeLable.snp.trailing).offset(2.auto())
            make.centerY.equalTo(self.aTimeLable.snp.centerY)
            make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
        })
        
        self.bgView.addSubview(self.mediaTypeImg!)
        self.bgView.addSubview(self.pureAiImages)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - 事件列表
    private func updateSourcesEvent() { 
        
        let timeInterval : TimeInterval = self.dataSourceModel?.time ?? Date().timeIntervalSince1970
        let is24HrFormatStr = "".timeFormatIs24Hr() ? kA4xDateFormat_24 : kA4xDateFormat_12
        let languageFormat = "\(is24HrFormatStr)" 
        let dataString = DateFormatter.format(languageFormat).string(from: Date(timeIntervalSince1970: timeInterval))
        self.aTimeLable.text = dataString
        
        
        let type : A4xLibraryResourcesType = self.dataSourceModel?.getType() ?? .image
        switch type {
        case .video:
            self.videoTimeLabel.isHidden = false
            if self.dataSourceModel?.period != -1 {
                let time = Int64(floorf(self.dataSourceModel?.period ?? 0))
                self.videoTimeLabel.text = String(format: "%02d:%02d", time / 60, time % 60)
            } else {
                self.videoTimeLabel.text = "-:-"
            }
        case .image:
            self.sourceTypeImageV.isHidden = true
            self.videoTimeLabel.isHidden = true
        }
        
        
        let state : A4xLibraryVideoReadStateType = self.dataSourceModel?.getState() ?? .read
        switch (state) {
        case .unread:
            self.readStateImageV.image = nil
        case .read:
            self.readStateImageV.image = nil
        case .mark:
            self.readStateImageV.image = bundleImageFromImageName("main_libary_mark_icon")?.rtlImage()
        }
        
        
        if self.dataSourceModel?.image != nil {
            self.contentImage.yy_setImage(with: URL(string: (self.dataSourceModel?.image)!), options: .ignorePlaceHolder)
        } else {
            self.contentImage.image = nil
        }
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
    
    
    private lazy var contentImage: UIImageView = {
        var temp: UIImageView = UIImageView()
        temp.backgroundColor = ADTheme.C5
        temp.clipsToBounds = true
        temp.layer.cornerRadius = 6.5
        temp.contentMode = .scaleAspectFill
        return temp
    }()
    
    
    private lazy var sourceTypeImageV : UIImageView = {
        var temp: UIImageView = UIImageView()
        temp.image = bundleImageFromImageName("main_libary_video_icon")?.rtlImage()
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
    
    
    private lazy var bePlayingAnimationView: LottieAnimationView = {
        var temp = LottieAnimationView(name: "library_player_play", bundle: a4xBaseBundle())
        self.contentImage.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 28.auto(), height: 28.auto()))
            make.centerX.equalTo(self.contentImage.snp.centerX)
            make.centerY.equalTo(self.contentImage.snp.centerY)
        }
        temp.loopMode = .loop
        temp.backgroundColor = ADTheme.Theme
        temp.layer.cornerRadius = 4.auto()
        temp.layer.masksToBounds = true
        return temp
    }()
    
    
    private lazy var videoTimeLabel: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "00:30"
        temp.font = ADTheme.B2
        temp.textColor = UIColor.white
        return temp
    }()

    
    private lazy var aTimeLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "AM 00:30"
        temp.font = ADTheme.H3
        temp.textColor = ADTheme.C3
        return temp
    }()
    
    
    private lazy var readStateImageV: UIImageView = {
        var temp: UIImageView = UIImageView()
        temp.contentMode = .center
        return temp
    }()
    
    
    private lazy var mediaTypeImg: A4xMediaVideoTagsView? = {
        let temp = A4xMediaVideoTagsView()
        self.addSubview(temp)
        return temp
    }()
    
    
    private lazy var pureAiImages: A4xMediaVideoAiTagImageView = {
        let temp = A4xMediaVideoAiTagImageView()
        return temp
    }()
}

//MARK: -

extension A4xMediaPlayScrollLibraryCell {
    
    func getCellHeight() -> CGFloat {
        var currentHeight = 0.0
        switch statusPlay {
        
        case .playPause:
            currentHeight = 89.auto() + 8.auto() + cellHeight + 16.auto()
            return currentHeight
        case .playeStart:
            
            if self.dataSourceModel?.videoTags().count ?? 0 > 0 {
                currentHeight = 89.auto() + 8.auto() + cellHeight + 16.auto()
            } else {
                currentHeight = 89.auto() + 16.auto()
            }
            return currentHeight
        case .playComple:
           fallthrough
        case .playStop:
            return 89.auto() + 8.auto() + imgsHeight + 16.auto()
        }
    }
}
