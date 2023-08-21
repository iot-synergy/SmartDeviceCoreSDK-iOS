//


//


//

import UIKit
import FSCalendar
import SmartDeviceCoreSDK
import BaseUI

protocol A4xDevicesSleepPlanCellProtocol: class {
    func devicesCellSwicth(flag: Bool, type: A4xDevicesSleepPlanEnum?)
    func devicesCellSelect(type: A4xDevicesSleepPlanEnum?)
    func devicesCellClick(sender: UIButton, type: A4xDevicesSleepPlanEnum?)
}

class A4xDevicesSleepPlanOpenCell: UITableViewCell {
    weak var `protocol`: A4xDevicesSleepPlanCellProtocol?
    var type: A4xDevicesSleepPlanEnum?
    
    var cellHeight: CGFloat = 0
    
    var isLoading: Bool = false {
        didSet {
            
            if isLoading {
                self.loadingView.isHidden = false
                self.loadingView.layer.add(animail, forKey: "ddd")
                self.switchButton.isHidden = true
            } else {
                self.loadingView.isHidden = true
                self.loadingView.layer.removeAllAnimations()
                if isSwitchModle {
                    self.switchButton.isHidden = false
                }
            }
        }
    }
    
    var nameString: String? {
        didSet {
            self.switchNameLbl.text = nameString
        }
    }
    
    var `switch`: Bool = true {
        didSet {
            isSwitchModle = true
            self.switchButton.isHidden = false
            self.switchButton.isOn = self.switch
            if self.switchButton.isOn {
                self.sleepImgView.image = A4xDeviceSettingResource.UIImage(named: "device_sleep_plan")?.rtlImage()
            } else {
                self.sleepImgView.image = A4xDeviceSettingResource.UIImage(named: "device_sleep_plan_off")?.rtlImage()
            }
            
            self.selectionStyle = .none
        }
    }
    
    private lazy var animail: CABasicAnimation = {
        let baseAnil = CABasicAnimation(keyPath: "transform.rotation")
        baseAnil.fromValue = 0
        baseAnil.toValue = Double.pi * 2
        baseAnil.duration = 1.5
        baseAnil.repeatCount = MAXFLOAT
        return baseAnil
    }()
    
    private var isSwitchModle: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
        
        sleepImgView.isHidden = false
        sleepPlanIntroLbl.isHidden = false
        switchNameLbl.isHidden = false
        switchButton.isHidden = false
        loadingView.isHidden = true
        //addPlanBtn.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var sleepImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = A4xDeviceSettingResource.UIImage(named: "device_sleep_plan")?.rtlImage()
        self.contentView.addSubview(iv)
        iv.snp.makeConstraints({ (make) in
            make.top.equalTo(self.contentView.snp.top).offset(15.5.auto())
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.size.equalTo(CGSize(width: 101.auto(), height: 101.auto()))
        })
        iv.layoutIfNeeded()
        cellHeight += 101.auto() + 15.5.auto()
        return iv
    }()
    
    
    private lazy var sleepPlanIntroLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "sleep_prompt")
        lbl.textColor = UIColor.colorFromHex("#2F3742")
        lbl.font = UIFont.regular(16)
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.top.equalTo(self.sleepImgView.snp.bottom).offset(15.5.auto())
            make.centerX.equalTo(self.sleepImgView.snp.centerX)
            make.width.equalTo((343.5.auto() - 32.auto()))
        })
        lbl.layoutIfNeeded()
        cellHeight += lbl.getLabelHeight(lbl, width: 343.5.auto() - 32.auto()) + 15.5.auto()
        return lbl
    }()
    
    
    private lazy var switchNameLbl: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.B1
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(15)
            make.top.equalTo(self.sleepPlanIntroLbl.snp.bottom).offset(35.auto())
        })
        temp.layoutIfNeeded()
        return temp
    }()
    
    
    private lazy var switchButton: UISwitch = {
        let temp = UISwitch()
        temp.onTintColor = ADTheme.Theme
        temp.tintColor = ADTheme.C5
        temp.addTarget(self, action: #selector(switchButtonAction(sender:)), for: .valueChanged)
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-15)
            make.centerY.equalTo(self.switchNameLbl.snp.centerY)
        })
        temp.layoutIfNeeded()
        cellHeight += max(temp.height, self.switchNameLbl.height) + 18.5.auto() + 35.auto()
        return temp
    }()
    
    
    private lazy var loadingView: UIImageView = {
        let loadingV = UIImageView()
        loadingV.image = bundleImageFromImageName("home_video_loading")?.rtlImage()
        loadingV.size = CGSize(width: 25.auto(), height: 25.auto())
        self.contentView.addSubview(loadingV)
        loadingV.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 25.auto(), height: 25.auto()))
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-20.auto())
            make.centerY.equalTo(self.switchButton.snp.centerY)
        }
        return loadingV
    }()
    
    
    @objc func switchButtonAction(sender: UISwitch) {
        self.protocol?.devicesCellSwicth(flag: sender.isOn, type: self.type)
    }
    
    func getCellHeight() -> CGFloat {
        return cellHeight
    }
}

class A4xDevicesSleepPlanCell: UITableViewCell {
    weak var `protocol`: A4xDevicesSleepPlanCellProtocol?
    var isLoading: Bool = false {
        didSet {
            
            if isLoading {
                self.loadingView.isHidden = false
                self.loadingView.layer.add(animail, forKey: "ddd")
                self.infoLabel.isHidden = true
                self.arrowImageV.isHidden = true
                self.switchButton.isHidden = true
            } else {
                self.loadingView.isHidden = true
                self.loadingView.layer.removeAllAnimations()
                if isSwitchModle {
                    self.switchButton.isHidden = false
                } else {
                    self.infoLabel.isHidden = false
                    self.arrowImageV.isHidden = false
                }
            }
        }
    }
    
    private lazy var animail: CABasicAnimation = {
        let baseAnil = CABasicAnimation(keyPath: "transform.rotation")
        baseAnil.fromValue = 0
        baseAnil.toValue = Double.pi * 2
        baseAnil.duration = 1.5
        baseAnil.repeatCount = MAXFLOAT
        return baseAnil
    }()
    
    private var isSwitchModle: Bool = false
    var type: A4xDevicesSleepPlanEnum?
    var title: String? {
        didSet {
            self.aNameLable.text = title
        }
    }
    
    var selectBackgroundColor: UIColor? {
        didSet {
            updateSelectBgColor()
        }
    }
    
    var tipString: String? {
        didSet {
            isSwitchModle = false
            self.switchButton.isHidden = true
            self.infoLabel.isHidden = false
            self.arrowImageV.isHidden = false
            self.infoLabel.text = tipString
            self.selectionStyle = .default
        }
    }
    
    var nameString: String? {
        didSet {
            self.aNameLable.text = nameString
        }
    }
    
    var `switch`: Bool = true {
        didSet {
            isSwitchModle = true
            self.switchButton.isHidden = false
            self.infoLabel.isHidden = true
            self.arrowImageV.isHidden = true
            self.switchButton.isOn = self.switch
            self.selectionStyle = .none
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
        self.loadingView.isHidden = true
        self.aNameLable.isHidden = false
        self.selectBackgroundColor = ADTheme.C6
        self.infoLabel.isHidden = true
        self.switchButton.isHidden = false
        updateSelectBgColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateSelectBgColor() {
        let view = UIView()
        view.backgroundColor = self.selectBackgroundColor
        self.selectedBackgroundView = view
    }
    
    private lazy var loadingView: UIImageView = {
        let loadingV = UIImageView()
        loadingV.image = bundleImageFromImageName("home_video_loading")?.rtlImage()
        loadingV.size = CGSize(width: 25.auto() , height: 25.auto() )
        self.contentView.addSubview(loadingV)
        
        loadingV.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 25.auto() , height: 25.auto()))
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-20.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        return loadingV
    }()
    
    private lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.font = UIFont.regular(16)
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(15);
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
    
    private lazy var switchButton: UISwitch = {
        let temp = UISwitch()
        temp.onTintColor = ADTheme.Theme
        temp.tintColor = ADTheme.C5
        temp.addTarget(self, action: #selector(switchButtonAction(sender:)), for: .valueChanged)
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-15)
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
    
    private lazy var infoLabel: UILabel = {
        var temp: UILabel = UILabel();
        temp.text = "test"
        temp.textColor = ADTheme.Theme
        temp.font = ADTheme.B1
        self.contentView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.arrowImageV.snp.leading)
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
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-10)
            make.centerY.equalTo(self.contentView.snp.centerY)
        })
        return temp
    }()
    
    @objc func switchButtonAction(sender: UISwitch) {
        self.protocol?.devicesCellSwicth(flag: sender.isOn, type: self.type)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool){
        super.setSelected(selected, animated: animated)
        if self.isLoading {
            return
        }
        
        guard self.switchButton.isHidden && selected else {
            return
        }
        
        self.protocol?.devicesCellSelect(type: self.type)
    }
}

protocol A4xDevicesSetSleepPlanCellProtocol: class {
    func devicesCellSwicth(flag: Bool, type: A4xDevicesSetSleepPlanEnum?)
    func devicesCellSelect(type: A4xDevicesSetSleepPlanEnum?)
    func devicesCellClick(sender: UIButton, type: A4xDevicesSetSleepPlanEnum?)
    func devicesBtnClick(sender: UIButton, status: String, type: A4xDevicesSetSleepPlanEnum?)
}

class A4xDevicesSetSleepPlanCell: UITableViewCell {
    weak var `protocol`: A4xDevicesSetSleepPlanCellProtocol?
    var type: A4xDevicesSetSleepPlanEnum?
    
    func setModelCategory(modelCategory: Int) {
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: modelCategory)
        self.sleepPlanIntroLbl.text = A4xBaseManager.shared.getLocalString(key: "sleep_period_etting", param: [tempString])
    }

    var updateUI: String? {
        didSet { }
    }
    
    var cellHeight: CGFloat = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
        sleepImgView.isHidden = false
        sleepPlanIntroLbl.isHidden = false
        addPlanBtn.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var sleepImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = A4xDeviceSettingResource.UIImage(named: "device_sleep_set")?.rtlImage()
        self.contentView.addSubview(iv)
        iv.snp.makeConstraints({ (make) in
            make.top.equalTo(self.contentView.snp.top).offset(15.5.auto())
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.size.equalTo(CGSize(width: 101.auto(), height: 101.auto()))
        })
        iv.layoutIfNeeded()
        cellHeight += 101.auto() + 15.5.auto()
        return iv
    }()
    
    
    private lazy var sleepPlanIntroLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "sleep_period_etting")
        lbl.textColor = UIColor.colorFromHex("#2F3742")
        lbl.font = UIFont.regular(16)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.top.equalTo(self.sleepImgView.snp.bottom).offset(15.5.auto())
            make.centerX.equalTo(self.sleepImgView.snp.centerX)
            make.width.equalTo(192.auto())
        })
        lbl.layoutIfNeeded()
        cellHeight += lbl.height + 15.5.auto()
        return lbl
    }()
    
    
    lazy var addPlanBtn: UIButton = {
        var btn: UIButton = UIButton()
        btn.titleLabel?.font = ADTheme.B1
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.textAlignment = .center
        btn.setTitle(A4xBaseManager.shared.getLocalString(key: "add_sleep_plan"), for: UIControl.State.normal) 
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        btn.setImage(A4xDeviceSettingResource.UIImage(named: "device_sleep_plan_add")?.rtlImage(), for: .normal)
        btn.setImage(A4xDeviceSettingResource.UIImage(named: "device_sleep_plan_add")?.rtlImage(), for: .highlighted)
       
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        btn.setBackgroundImage(UIImage.buttonNormallImage, for: .normal)
        let image = btn.currentBackgroundImage
        let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.Theme, by: 0.9)
        btn.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
        btn.layer.cornerRadius = 25.auto()
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(addPlanBtnAction(_:)), for: .touchUpInside)
        self.contentView.addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            make.top.equalTo(self.sleepPlanIntroLbl.snp.bottom).offset(31.auto())
            make.centerX.equalTo(self.contentView.snp.centerX)
            make.height.equalTo(50.auto())
            make.width.equalTo(self.contentView.snp.width).offset(-32.auto())
        })
        btn.layoutIfNeeded()
        cellHeight += 50.auto() + 31.auto() + 32.auto()
        return btn
    }()
    
    
    @objc func addPlanBtnAction(_ sender: UIButton) {
        self.protocol?.devicesCellClick(sender: sender, type: self.type)
    }
    
    func getCellHeight() -> CGFloat {
        return cellHeight
    }
}

class A4xDevicesShowSleepPlanCell: UITableViewCell, A4xBaseGridViewDelegate {
    func onClickImageView(imageStrs: [String], index: Int) {
        
    }
    
    func onClickBtnView(btn: UIButton, status: String) {
        self.protocol?.devicesBtnClick(sender: btn, status: status, type: self.type)
    }
    
    weak var `protocol`: A4xDevicesSetSleepPlanCellProtocol?
    var type: A4xDevicesSetSleepPlanEnum?
    
    let weekName = [A4xBaseManager.shared.getLocalString(key: "sunday"),A4xBaseManager.shared.getLocalString(key: "monday"),A4xBaseManager.shared.getLocalString(key: "tuesday"),A4xBaseManager.shared.getLocalString(key: "wednesday"),A4xBaseManager.shared.getLocalString(key: "thursday"),A4xBaseManager.shared.getLocalString(key: "friday"),A4xBaseManager.shared.getLocalString(key: "saturday")]
    
    let timeName = ["00:00","04:00","08:00","12:00","16:00","20:00","24:00"]
    
    var sleepPlanModels: [A4xDeviceSleepPlanBean]? {
        didSet {
            
            DispatchQueue.main.a4xAfter(0.3) { [weak self] in
                self?.weekGridView.isHidden = false
                
                self?.weekGridView.rowTitleArr = self?.weekName ?? []
                
                //self?.weekGridView.curRowTitleStr = self?.weekName[Date().getTimes()[1].intValue()]
                self?.weekGridView.curRowTitleIndex = Date().getTimes()[1].intValue()
                
                self?.weekGridView.curColTitleStr = Date().getTimes()[0]
                
                self?.weekGridView.columnTitleArr = self?.timeName ?? []
                
                self?.weekGridView.removeOldUI = true
                self?.weekGridView.sleepPlanModelArr = self?.sleepPlanModels
                self?.weekGridView.boxNum = 42
                self?.weekGridView.showCurrenTime = true
                self?.weekGridView.canEdit = true
                self?.weekGridView.gridWidth = (self?.contentView.width ?? 343.auto()) - 51.5.auto()
            }
        }
    }
    
    var cellHeight: CGFloat = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        self.selectionStyle = .none
        self.workTimeView.isHidden = false
        self.workTimeLbl.isHidden = false
        self.sleepTimeView.isHidden = false
        self.sleepTimeLbl.isHidden = false
        self.lineView.isHidden = false
        self.weekGridView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var workTimeView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        self.contentView.addSubview(v)
        v.snp.makeConstraints({ (make) in
            make.top.equalTo(self.contentView.snp.top).offset(24.auto())
            make.leading.equalTo(self.contentView.snp.leading).offset(16.5.auto())
            make.height.equalTo(6.auto())
            make.width.equalTo(24.auto())
        })
        v.layoutIfNeeded()
        v.clipsToBounds = true
        v.filletedCorner(CGSize(width: 1.5, height: 1.5),UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue | UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.colorFromHex("#E8E8E8").cgColor
        return v
    }()
     
    
    lazy var workTimeLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "sleep_work_time")
        lbl.font = ADTheme.B2
        lbl.textAlignment = .left
        lbl.textColor = ADTheme.C1
        lbl.lineBreakMode = .byTruncatingTail
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.workTimeView.snp.centerY)
            make.leading.equalTo(self.workTimeView.snp.trailing).offset(8.auto())
            make.width.lessThanOrEqualTo(self.contentView.width / 2 - 24.auto())
        })
        return lbl
    }()
    
    
    lazy var sleepTimeView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.colorFromHex("#BCC6E1")
        self.contentView.addSubview(v)
        v.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.workTimeView.snp.centerY)
            make.leading.equalTo(self.workTimeLbl.snp.trailing).offset(32.auto())
            make.height.equalTo(6.auto())
            make.width.equalTo(24.auto())
        })
        v.layoutIfNeeded()
        v.clipsToBounds = true
        v.filletedCorner(CGSize(width: 1.5, height: 1.5),UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue | UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
        return v
    }()
    
    
    lazy var sleepTimeLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "sleep_period")
        lbl.font = ADTheme.B2
        lbl.textAlignment = .left
        lbl.textColor = ADTheme.C1
        lbl.lineBreakMode = .byTruncatingTail
        self.contentView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.sleepTimeView.snp.centerY)
            make.leading.equalTo(self.sleepTimeView.snp.trailing).offset(8.auto())
            make.width.lessThanOrEqualTo(self.contentView.width / 2 - 24.auto() - 16.auto())
        })
        return lbl
    }()
    
    
    private lazy var lineView : UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.colorFromHex("#F0F0F0")//UIColor.black.withAlphaComponent(0.4)
        self.contentView.addSubview(v)
        v.snp.makeConstraints({ (make) in
            make.top.equalTo(self.workTimeView.snp.bottom).offset(21.5.auto())
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalToSuperview()
        })
        return v
    }()
    
    
    lazy var weekGridView: A4xBaseGridView = {
        let gv = A4xBaseGridView()
        gv.delegate = self
        self.contentView.addSubview(gv)
        gv.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp.top).offset(51.5.auto())
            make.leading.equalTo(self.contentView.snp.leading).offset(0)
            make.width.equalTo(self.contentView.snp.width)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-23.auto())
        }
        return gv
    }()
    
    
    @objc func addPlanBtnAction(_ sender: UIButton) {
        self.protocol?.devicesCellClick(sender: sender, type: self.type)
    }
    
    func getCellHeight() -> CGFloat {
        return cellHeight
    }
}
