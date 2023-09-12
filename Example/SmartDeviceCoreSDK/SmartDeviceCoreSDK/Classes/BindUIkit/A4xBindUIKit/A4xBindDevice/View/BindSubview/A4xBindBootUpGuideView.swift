//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol BindBootUpGuideViewProtocol: class {
    func canNotBoot()
    func bindBootUpNextAction()
}

class A4xBindBootUpGuideView: A4xBindBaseView {
    
    weak var `protocol`: BindBootUpGuideViewProtocol?
    
    var backClick: (()->Void)?
    
    var zendeskChatClick: (()->Void)?
    
    var alreadyHeadVoiceCheck: Bool = false {
        didSet {
            if alreadyHeadVoiceCheck {
                nextBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
                nextBtn.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
            } else {
                nextBtn.setTitleColor(ADTheme.C4, for: .normal)
                nextBtn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .normal)
            }
            let image = nextBtn.currentBackgroundImage //UIImage.buttonNormallImage
            let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.Theme, by: 0.9)
            nextBtn.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
        }
    }
    
    
    override var datas: Dictionary<String, String>? {
        didSet {
        }
    }
    
    
    lazy var alreadyHeadVoiceCheckBoxBtn: A4xBaseCheckBoxButton = {
        var checkBoxBtn = A4xBaseCheckBoxButton()
        checkBoxBtn.backgroundColor = UIColor.clear
        checkBoxBtn.addx_expandSize(size: 10)
        checkBoxBtn.setImage(image: bundleImageFromImageName("rember_voice_check_unselect")?.rtlImage(), state: A4xBaseCheckBoxState.normail)
        checkBoxBtn.setImage(image: bundleImageFromImageName("rember_voice_check_select"), state: A4xBaseCheckBoxState.selected)
        return checkBoxBtn
    }()
    
    lazy var navView: A4xBaseNavView = {
        let temp = A4xBaseNavView()
        temp.backgroundColor = .clear//UIColor.white
        temp.lineView?.isHidden = true
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(0)
            make.trailing.equalTo(self.snp.trailing)
            make.top.equalTo(0)
        })
        
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        temp.leftItem = leftItem
        
        temp.leftClickBlock = { [weak self] in
            self?.backClick?()
        }
        return temp
    }()
    
    
    private lazy var currentView: UIScrollView = {
        var sv: UIScrollView = UIScrollView()
        sv.contentSize = CGSize(width: self.width, height: UIScreen.height - 230.auto())
        let y: CGFloat = sv.bounds.height + 150
        sv.frame = CGRect(x: 0, y: y, width: self.bounds.width, height: sv.bounds.height)
        sv.bounces = true
        sv.isScrollEnabled = true
        sv.alwaysBounceVertical = true
        sv.scrollsToTop = true
        sv.backgroundColor = .clear //.hex( 0x000000, alpha: 0.5)
        return sv
    }()
    
    lazy var upView: UIView = {
        var v: UIView = UIView()
        v.layer.cornerRadius = 10.5.auto()
        v.backgroundColor = .white
        return v
    }()
    
    lazy var upGuideImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("bind_device_guide_up")?.rtlImage()
        return iv
    }()
    
    lazy var upGuideLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "battery_camera")
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.medium(16)
        return lbl
    }()
    
    lazy var upGuideTipsLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "battery_camera_tips")
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C3
        lbl.font = UIFont.regular(13)
        return lbl
    }()
    
    
    private lazy var line1View: UIView = {
        let v = UIView()
        v.backgroundColor = ADTheme.C2
        return v
    }()
    
    
    lazy var lineOrLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "or")
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C2
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    
    private lazy var line2View: UIView = {
        let v = UIView()
        v.backgroundColor = ADTheme.C2
        return v
    }()
    
    
    lazy var downView: UIView = {
        var v: UIView = UIView()
        v.layer.cornerRadius = 10.5.auto()
        v.backgroundColor = .white
        return v
    }()
    
    lazy var downGuideImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("bind_device_guide_down")?.rtlImage()
        return iv
    }()
    
    lazy var downGuideLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "plugin_camera")
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.medium(16)
        return lbl
    }()
    
    lazy var downGuideTipsLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "plugin_camera_tips")
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C3
        lbl.font = UIFont.regular(13)
        return lbl
    }()
    
    
    lazy var alreadyHeadVoiceLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "hear_beep")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        //lbl.backgroundColor = .blue
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    
    lazy var canNotBootLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "can_not_power_up")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.Theme
        //lbl.backgroundColor = .gray
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        navView.isHidden = false
        
        titleHintTxtView.isHidden = true
        
        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "turn_on_camera")
        nextBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "next"), for: .normal)
        
        insertSubview(currentView, at: 0)
        
        
        addSubview(alreadyHeadVoiceCheckBoxBtn)
        addSubview(alreadyHeadVoiceLbl)
        
        nextBtn.isEnabled = true
        
        nextBtn.setTitleColor(ADTheme.C4, for: UIControl.State.disabled)
        
        //nextBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        nextBtn.setTitleColor(ADTheme.C4, for: .normal)
        
        //nextBtn.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
        nextBtn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .normal)

        let image = nextBtn.currentBackgroundImage //UIImage.buttonNormallImage
        let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.Theme, by: 0.9)
        nextBtn.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
        nextBtn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .disabled)
        
        addSubview(canNotBootLbl)
        
        
        titleLbl.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(navView.snp.bottom).offset(0.auto())
            make.width.equalTo(self.snp.width).offset(-62.auto())
        }
        
        
        currentView.snp.remakeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(0.auto())
            make.leading.equalTo(0)
            make.width.equalTo(UIScreen.width)
            make.height.equalTo(UIScreen.height - UIScreen.navBarHeight)
        }
    
        switch A4xBaseThemeConfig.shared.supportBindType() {
        case 0:
            supportAllTypeDeviceTypeUI()
            break
        case 1:
            onlySupportLowPowerDeviceUI()
            break
        case 2:
            onlySupportKeepChargingDeviceUI()
            break
        default:
            supportAllTypeDeviceTypeUI()
        }
        
        
        let alreadyHeadVoiceLblWith = min(alreadyHeadVoiceLbl.getLabelWidth(alreadyHeadVoiceLbl, height: 30.auto()), UIScreen.width * 0.8)
        alreadyHeadVoiceLbl.snp.makeConstraints({ make in
            make.centerX.equalTo(nextBtn.snp.centerX).offset(15.auto())
            make.bottom.equalTo(nextBtn.snp.top).offset(-16.auto())
            make.width.equalTo(alreadyHeadVoiceLblWith)
            make.height.greaterThanOrEqualTo(30.auto())
        })

        
        alreadyHeadVoiceCheckBoxBtn.snp.makeConstraints({ make in
            make.trailing.equalTo(alreadyHeadVoiceLbl.snp.leading).offset(-10.auto())
            make.centerY.equalTo(alreadyHeadVoiceLbl.snp.centerY)
            make.size.equalTo(CGSize(width: 20.auto(), height: 20.auto()))
        })
        
        
        nextBtn.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-42.auto())
            make.height.equalTo(50.auto())
            make.bottom.equalTo(self.snp.bottom).offset(-81.auto())
        }
        
        
        canNotBootLbl.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom).offset(-33.auto())
            make.width.lessThanOrEqualTo(UIScreen.width - 32.auto())
            //make.width.equalTo(266.5.auto())
        })
        
        
        alreadyHeadVoiceCheckBoxBtn.addTarget(self, action: #selector(alreadyHeadVoiceCheckBoxAction(sender:)), for: UIControl.Event.touchUpInside)
        
        
        alreadyHeadVoiceLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alreadyHeadVoiceLblClick)))
        
        
        canNotBootLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(canNotBoot)))
        
        
        nextBtn.addTarget(self, action: #selector(nextAction(sender:)), for: .touchUpInside)
    }
    
    
    private func supportAllTypeDeviceTypeUI() {
        
        currentView.addSubview(upView)
        upView.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.currentView.snp.top).offset(24.auto())
            make.size.equalTo(CGSize(width: 343.auto() * 0.95, height: 174.5.auto() * 0.95))
        })
        
        
        upView.addSubview(upGuideImgView)
        upGuideImgView.snp.makeConstraints({ make in
            make.trailing.equalTo(self.upView.snp.trailing)
            make.centerY.equalTo(self.upView.snp.centerY)
            make.width.equalTo(158.auto() * 0.95)
            make.height.equalTo(174.5.auto() * 0.95)
        })
        
        
        upView.addSubview(upGuideLbl)
        upGuideLbl.snp.makeConstraints({ make in
            make.top.equalTo(upView.snp.top).offset(34.auto() * 0.95)
            make.leading.equalTo(upView.snp.leading).offset(32.auto() * 0.95)
            make.trailing.equalTo(upGuideImgView.snp.leading).offset(-10.auto() * 0.95)
        })
        
        
        upView.addSubview(upGuideTipsLbl)
        upGuideTipsLbl.snp.makeConstraints({ make in
            make.top.equalTo(upGuideLbl.snp.bottom).offset(5.auto() * 0.95)
            make.leading.equalTo(upGuideLbl.snp.leading)
            make.trailing.equalTo(upGuideImgView.snp.leading).offset(-10.auto() * 0.95)
            make.bottom.lessThanOrEqualTo(upView.snp.bottom).offset(-2.auto() * 0.95)
        })
        
        
        currentView.addSubview(lineOrLbl)
        lineOrLbl.snp.makeConstraints({ (make) in
            make.top.equalTo(self.upView.snp.bottom).offset(8.auto() * 0.95)
            make.centerX.equalTo(self.currentView.snp.centerX)
        })
        
        
        currentView.addSubview(line1View)
        line1View.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.lineOrLbl.snp.centerY).offset(0)
            make.leading.equalTo(upView.snp.leading)
            make.height.equalTo(1)
            make.trailing.equalTo(self.lineOrLbl.snp.leading).offset(-8.auto())
        })
        
        
        currentView.addSubview(line2View)
        line2View.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.lineOrLbl.snp.centerY).offset(0)
            //make.trailing.equalTo(-16.auto())
            make.width.equalTo(line1View.snp.width)
            make.height.equalTo(1)
            make.leading.equalTo(self.lineOrLbl.snp.trailing).offset(8.auto())
        })
        
        
        currentView.addSubview(downView)
        downView.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(lineOrLbl.snp.bottom).offset(12.auto() * 0.95)
            make.size.equalTo(CGSize(width: 343.auto() * 0.95, height: 174.5.auto() * 0.95))
        })
        
        
        downView.addSubview(downGuideImgView)
        downGuideImgView.snp.makeConstraints({ make in
            make.trailing.equalTo(downView.snp.trailing)
            make.centerY.equalTo(downView.snp.centerY)
            make.width.equalTo(158.auto() * 0.95)
            make.height.equalTo(174.5.auto() * 0.95)
        })
        
        
        downView.addSubview(downGuideLbl)
        downGuideLbl.snp.makeConstraints({ make in
            make.top.equalTo(downView.snp.top).offset(34.auto() * 0.95)
            make.leading.equalTo(downView.snp.leading).offset(32.auto() * 0.95)
            make.trailing.equalTo(downGuideImgView.snp.leading).offset(-10.auto() * 0.95)
        })
        
        
        downView.addSubview(downGuideTipsLbl)
        downGuideTipsLbl.snp.makeConstraints({ make in
            make.top.equalTo(downGuideLbl.snp.bottom).offset(5.auto() * 0.95)
            make.leading.equalTo(downGuideLbl.snp.leading)
            make.trailing.equalTo(downGuideImgView.snp.leading).offset(-10.auto() * 0.95)
            make.bottom.lessThanOrEqualTo(downView.snp.bottom).offset(-2.auto() * 0.95)
        })
    }
    
    
    private func onlySupportLowPowerDeviceUI() {
        
        currentView.addSubview(upView)
        upView.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.currentView.snp.centerY).offset(-150)
            make.size.equalTo(CGSize(width: 343.auto(), height: 216.auto()))
        })
        
        
        
        upView.addSubview(upGuideImgView)
        upGuideImgView.snp.makeConstraints({ make in
            make.trailing.equalTo(self.upView.snp.trailing)
            make.centerY.equalTo(self.upView.snp.centerY)
            make.width.equalTo(158.auto())
            make.height.equalTo(216.auto())
        })
        
        
        upView.addSubview(upGuideLbl)
        upGuideLbl.snp.makeConstraints({ make in
            make.top.equalTo(upView.snp.top).offset(54.auto())
            make.leading.equalTo(upView.snp.leading).offset(32.auto())
            make.trailing.equalTo(upGuideImgView.snp.leading).offset(-10.auto())
        })
        
        
        upView.addSubview(upGuideTipsLbl)
        upGuideTipsLbl.snp.makeConstraints({ make in
            make.top.equalTo(upGuideLbl.snp.bottom).offset(5.auto())
            make.leading.equalTo(upGuideLbl.snp.leading)
            make.trailing.equalTo(upGuideImgView.snp.leading).offset(-10.auto())
            make.bottom.lessThanOrEqualTo(upView.snp.bottom).offset(-2.auto())
        })
        
    }
    
    
    private func onlySupportKeepChargingDeviceUI() {
        
        currentView.addSubview(downView)
        downView.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.currentView.snp.centerY).offset(-150)
            make.size.equalTo(CGSize(width: 343.auto(), height: 216.auto()))
        })
        
        
        downView.addSubview(downGuideImgView)
        downGuideImgView.snp.makeConstraints({ make in
            make.trailing.equalTo(downView.snp.trailing)
            make.centerY.equalTo(downView.snp.centerY)
            make.width.equalTo(158.auto())
            make.height.equalTo(216.auto())
        })
        
        
        downView.addSubview(downGuideLbl)
        downGuideLbl.snp.makeConstraints({ make in
            make.top.equalTo(downView.snp.top).offset(54.auto())
            make.leading.equalTo(downView.snp.leading).offset(32.auto())
            make.trailing.equalTo(downGuideImgView.snp.leading).offset(-10.auto())
        })
        
        
        downView.addSubview(downGuideTipsLbl)
        downGuideTipsLbl.snp.makeConstraints({ make in
            make.top.equalTo(downGuideLbl.snp.bottom).offset(5.auto())
            make.leading.equalTo(downGuideLbl.snp.leading)
            make.trailing.equalTo(downGuideImgView.snp.leading).offset(-10.auto())
            make.bottom.lessThanOrEqualTo(downView.snp.bottom).offset(-2.auto())
        })
        
    }
    
    
    @objc private func alreadyHeadVoiceCheckBoxAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        alreadyHeadVoiceCheck = sender.isSelected
    }
    
    
    @objc private func alreadyHeadVoiceLblClick() {
        alreadyHeadVoiceCheck = !alreadyHeadVoiceCheck
        alreadyHeadVoiceCheckBoxBtn.isSelected = alreadyHeadVoiceCheck
    }
    
    
    @objc private func canNotBoot() {
        self.protocol?.canNotBoot()
    }
    
    @objc private func nextAction(sender: UIButton) {
        
        if alreadyHeadVoiceCheck {
            self.protocol?.bindBootUpNextAction()
        } else {
            alreadyHeadVoiceAlert()
        }
    }
    
    
    
    private func alreadyHeadVoiceAlert() {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.Theme
        config.rightTextColor = UIColor.white
        weak var weakSelf = self
        
        let alert = A4xBaseAlertView(param: config, identifier: "show Save Alert")
        alert.message = A4xBaseManager.shared.getLocalString(key: "bind_device_guide_confirm_window")
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "no")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "yes")
        alert.rightButtonBlock = {
            weakSelf?.protocol?.bindBootUpNextAction()
        }
        
        alert.leftButtonBlock = {
            
        }
      
        alert.show()
    }
    
    
    private func supportBindType() -> Int {
        return A4xBaseThemeConfig.shared.supportBindType()
    }
    
}
