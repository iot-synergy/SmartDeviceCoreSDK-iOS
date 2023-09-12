//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI


class A4xDevicesSettingCell: UITableViewCell {
    var title: (String?, Bool?, UIImage?) {
        didSet {
            self.titleIV.image = title.2
            
            if title.0 == A4xBaseManager.shared.getLocalString(key: "sd_management") {
                self.aNameLable.text = title.0?.capitalized
                self.aNameLable.text = self.aNameLable.text?.replacingOccurrences(of: "Sd", with: "SD")
            } else if title.0 == A4xBaseManager.shared.getLocalString(key: "set_pan_tilt_settings") {
                
                self.aNameLable.text = title.0
            }else {
                self.aNameLable.text = title.0?.capitalized
            }
            self.aNameLable.textColor = (title.1 ?? true) ? ADTheme.C1 : UIColor.black.withAlphaComponent(0.4)
        }
    }
    
    var selectBackgroundColor: UIColor? {
        didSet {
            updateSelectBgColor()
        }
    }
    
    var shouldUpdate: Bool = false {
        didSet {
            self.updatePoint.isHidden = !shouldUpdate
        }
    }
    
    var warmingTitle: String? {
        didSet {
            self.warmLable.text = warmingTitle
            self.arrowImageV.isHidden = warmingTitle?.count ?? 0 > 0
        }
    }
    
    var descTitle: String? {
        didSet {
            self.descLable.text = descTitle
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.titleIV.isHidden = false
        self.aNameLable.isHidden = false
        self.arrowImageV.isHidden = false
        self.selectBackgroundColor = ADTheme.C6
        self.updatePoint.isHidden = true
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        updateSelectBgColor()
        self.selectionStyle = .none
    }
    
    
    func updateNameAndDescriptionLayout(des: String) {
        
        if des == ""
        {
            
            self.aNameLable.snp.remakeConstraints({ (make) in
                make.leading.equalTo(self.titleIV.snp.trailing).offset(14.auto())
                make.centerY.equalTo(self.contentView.snp.centerY)
                make.width.lessThanOrEqualTo(240.auto())
            })
        } else {
            
            self.aNameLable.snp.remakeConstraints({ (make) in
                make.leading.equalTo(self.titleIV.snp.trailing).offset(14.auto())
                make.centerY.equalTo(self.contentView.snp.centerY)
                make.width.lessThanOrEqualTo(self.contentView.width / 3)
            })
        }
        
    }
    
    private func updateSelectBgColor() {



    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            
        }
        self.contentView.backgroundColor = highlighted ? ADTheme.C5 : UIColor.white
    }
    
    lazy var titleIV: UIImageView = {
        var iv: UIImageView = UIImageView()
        self.contentView.addSubview(iv)
        iv.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.leading.equalTo(16.auto())
            make.width.height.equalTo(24.auto())
        })
        return iv
    }()
    
    lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.numberOfLines = 0
        temp.font = UIFont.regular(16)
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.titleIV.snp.trailing).offset(14.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
            //make.trailing.equalTo(self.arrowImageV.snp.leading).offset(-16.5.auto())
            
            make.width.lessThanOrEqualTo(240.auto())
        })
        return temp
    }()
    
    private lazy var descLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "test"
        temp.textColor = ADTheme.C1.withAlphaComponent(0.3)
        temp.textAlignment = .right
        //temp.adjustsFontSizeToFitWidth = true
        temp.numberOfLines = 0
        temp.font = ADTheme.B1
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.arrowImageV.snp.leading).offset(-5.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.width.lessThanOrEqualTo(self.contentView.width / 2)
        })
        return temp
    }()
    
    private lazy var warmLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "test"
        temp.textColor = UIColor.hex(0xFF5500)
        temp.textAlignment = .right
        temp.numberOfLines = 0
        temp.font = ADTheme.B1
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-16.5.auto())
            make.width.equalTo(self.contentView.size.width * 0.6)
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
    
    private lazy var arrowImageV: UIImageView = {
        var temp = UIImageView()
        temp.contentMode = .center
        temp.image = bundleImageFromImageName("home_user_info_arrow")?.rtlImage()
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-16.5.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 24, height: 24))
        })
        
        return temp
    }()
    
    lazy var updatePoint: UIView = {
        let temp = UIView()
        temp.layer.cornerRadius = 3.auto()
        temp.isUserInteractionEnabled = false
        temp.clipsToBounds = true
        temp.backgroundColor = ADTheme.E1
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.arrowImageV.snp.leading).offset(-2.auto())
            make.width.equalTo(6.auto())
            make.height.equalTo(6.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        
        return temp
    }()
}

protocol A4xDevicesSettingRangeCellProtocol: class {
    func devicesCellClick(index: Int, type: A4xDeviceSettingInfoEnum)
}


class A4xDevicesSettingRangeCell: UITableViewCell {
    var cellHeight: CGFloat = 0
    weak var `protocol`: A4xDevicesSettingRangeCellProtocol?
   
    /**
     第一个参数： 添加 [.motion,（运动检测） .analysis,（AI 分析） .notifi] 方块模块个数
     第二个参数： 添加 [.motion,（运动检测） .analysis,（AI 分析） .notifi] 方块模块中 开启、未开启等文案
     */
    var contentTuple: ([A4xDeviceSettingSubInfoEnum]?, [String]?)
   
    var selectBackgroundColor: UIColor? {
        didSet {
            updateSelectBgColor()
        }
    }
    
    var isMotionSaveState: Bool = true 

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.width = UIScreen.width - 32.auto()
        self.selectBackgroundColor = ADTheme.C6
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = ADTheme.C6//.white
        self.selectionStyle = .none
        
    }
    
    private func updateSelectBgColor() {
        let view = UIView()
        view.backgroundColor = self.selectBackgroundColor
        self.selectedBackgroundView = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func rangeNormalViews(arr: ([A4xDeviceSettingSubInfoEnum]?, [String]?)) {
        cellHeight = 0
        
        _ = self.contentView.subviews.map {
            $0.removeFromSuperview()
        }
        
        guard let arrCount = arr.0?.count else { return }
        contentTuple = arr
        if arrCount % 2 == 0 { 
            
            rangeSubView(row: (arr.0?.count ?? 0) / 2) //3
        } else {  
            
            let row = (arr.0?.count ?? 0) / 2
            if row != 0 { 
                rangeSubView(row: row)
            }
            
            
            let type = contentTuple.0?[arrCount-1] ?? .motion
            boxView(type: type, i: row, style: 2, titleLineCount: 1)
            
            self.cellHeight += CGFloat((83.5 + 10).auto())
        }
    }
    
    
    func rangeSubView(row: Int) {
        
        let oneLineHeight = "title".textHeightFromTextString(text: "title", textWidth: self.contentView.width - 32.auto(), fontSize: 16.auto(), isBold: false)
        //

        for i in 0..<row { 
            
            let titleStr1 = contentTuple.0?[i * 2].rawValue
            let titleStr2 = contentTuple.0?[i * 2 + 1].rawValue
            let curWidth = (self.contentView.width - 10.auto()) / 2
            let item1Height = titleStr1?.textHeightFromTextString(text: titleStr1 ?? "", textWidth: curWidth - 32.auto(), fontSize: 16.auto(), isBold: false)
            let item2Height = titleStr2?.textHeightFromTextString(text: titleStr2 ?? "", textWidth: curWidth - 32.auto(), fontSize: 16.auto(), isBold: false)
            //
            let titleLineCount = Int(max(item1Height ?? 0, item2Height ?? 0) / oneLineHeight)
            let boxHeight = (titleLineCount > 1 ? 106.auto() : 83.5.auto())
            
            let leftType = contentTuple.0?[i*2]
            boxView(type: leftType ?? .motion, i: i, style: 0, titleLineCount: titleLineCount)
            
            let rightType = contentTuple.0?[i*2+1]
            boxView(type: rightType ?? .motion, i: i, style: 1, titleLineCount: titleLineCount)
            self.cellHeight += CGFloat(boxHeight)
            
        }
        
        self.cellHeight += CGFloat((row - 1) * 10.auto())
        //self.cellHeight += CGFloat(83.5.auto() * row) + CGFloat((row - 1) * 10.auto())
    }
    
    
    func boxView(type: A4xDeviceSettingSubInfoEnum, i: Int, style: Int, titleLineCount: Int) {
        //
        let boxHeight = (titleLineCount > 1 ? 106.auto() : 83.5.auto())
        
        let isLeft: Bool = style == 0 || style == 2
        
        let index = style == 2 ? (contentTuple.0?.count ?? 1) - 1 : i
        
        let boxView = UIView()
        boxView.tag = style == 2 ? index : isLeft ? index * 2 : index * 2 + 1
        boxView.addOnClickListener(target: self, action: #selector(boxViewClick(tap:)))
        boxView.backgroundColor = .white
        boxView.cornerRadius = 11.auto()
        self.contentView.addSubview(boxView)
        
        boxView.snp.makeConstraints({ (make) in
            if isLeft {
                make.leading.equalTo(self.contentView.snp.leading)
            } else {
                make.trailing.equalTo(self.contentView.snp.trailing)
            }
            
            
            let offsetHeight: CGFloat = style == 2 ? self.cellHeight + 10.auto() : self.cellHeight + 10.auto() * CGFloat(i)
            make.top.equalTo(self.contentView.snp.top).offset(offsetHeight)
            make.height.equalTo(boxHeight)
            if style == 2 {
                make.width.equalTo((self.contentView.width))
            } else {
                make.width.equalTo((self.contentView.width - 10.auto()) / 2)
            }
        })
        
        
        let titleIV: UIImageView = UIImageView()
        let img = style == 2 ? contentTuple.0?[index].imgValue() : contentTuple.0?[isLeft ? index * 2 : index * 2 + 1].imgValue()
        titleIV.image = img
        boxView.addSubview(titleIV)
        titleIV.snp.makeConstraints({ (make) in
            make.top.equalTo(8.auto())
            make.leading.equalTo(8.auto())
            make.width.height.equalTo(37.auto())
        })
        
        //AI分析 名称
        let titleLbl: UILabel = UILabel()
        let txt = style == 2 ? contentTuple.0?[index].rawValue : contentTuple.0?[isLeft ? index * 2 : index * 2 + 1].rawValue
        
        
        if txt == A4xBaseManager.shared.getLocalString(key: "sdcard_7_24") {
            titleLbl.text = txt?.capitalized
            titleLbl.text = titleLbl.text?.replacingOccurrences(of: "Sd", with: "SD")
        } else {
            titleLbl.text = txt?.capitalized
        }
        
        if case .motion = type {
            titleLbl.textColor = ADTheme.C1
        } else if case .alarmSetting = type {
            titleLbl.textColor = ADTheme.C1
        } else if case .videoSetting = type {
            titleLbl.textColor = ADTheme.C1
        } else {
            titleLbl.textColor = ADTheme.C1
        }
        titleLbl.font = UIFont.regular(16)
        titleLbl.textAlignment = .left
        titleLbl.numberOfLines = 0
        boxView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints({ (make) in
            make.leading.equalTo(8.auto())
            make.top.equalTo(titleIV.snp.bottom).offset(8.auto())
            make.width.equalTo(boxView.snp.width).offset(-32.auto())
        })
    }
    
    func getCellHeight() -> CGFloat {
        return cellHeight
    }
    
    
    @objc func boxViewClick(tap: Any) {
        let sender = tap as! UITapGestureRecognizer
        let tag = sender.view?.tag
        
        self.protocol?.devicesCellClick(index: tag ?? 1024, type: .boxArr(self.contentTuple))
    }
    
}



public class A4xDevicesSettingRemoveCell : UITableViewCell {
    
    public var title: String? {
        didSet {
            self.aNameLable.text = title?.capitalized
        }
    }
    
    var selectBackgroundColor: UIColor? {
        didSet {
            updateSelectBgColor()
        }
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.aNameLable.isHidden = false
        self.selectBackgroundColor = ADTheme.C6

        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none

    }
    
    private func updateSelectBgColor() {
        let view = UIView()
        view.backgroundColor = self.selectBackgroundColor
        self.selectedBackgroundView = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.font = UIFont.regular(16)
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(15)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-15)
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
}


