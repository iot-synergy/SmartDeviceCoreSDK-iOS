//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol A4xBindReSetGuideViewProtocol: class {
    func reSetGuideViewNextAction()
    func fallIntoTrouble()
}

class A4xBindReSetGuideView: A4xBindBaseView {
    
    weak var `protocol` : A4xBindReSetGuideViewProtocol?
    
    var backClick: (()->Void)?
    
    var zendeskChatClick: (()->Void)?
    
    var alreadyHeadVoiveNothingCheck: Bool = false
    
    var sourceFrom: Int = 0 // 0,扫码；1,蓝牙；2,AP直连；3，有线连接
    
    override var datas: Dictionary<String, String>? {
        didSet {
            if !(datas?["nextEnable"]?.isBlank ?? true) {
                nextBtn.isEnabled = datas?["nextEnable"] == "1" ? true : false
            }
            
            if !(datas?["sourceFrom"]?.isBlank ?? true) {
                sourceFrom = datas?["sourceFrom"]?.intValue() ?? 0
            }
        }
    }
    
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
    
    
    //
    lazy var aboutBatteryLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "for_battery_cameras")
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.heavy(20)
        return lbl
    }()
    
    //
    lazy var aboutBatteryTipsLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "double_click_power_button")
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C2
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    //
    lazy var aboutBatteryImgView: UIImageView = {
      let iv = UIImageView()
        iv.image = bundleImageFromImageName("scan_qrcode_voice_type1")?.rtlImage()
        return iv
    }()
    
    //
    lazy var aboutElectricPowerLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "for_plugin_cameras")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        //lbl.backgroundColor = .blue
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.heavy(20)
        return lbl
    }()
    
    //
    lazy var aboutElectricPowerTipsLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "long_press_reset_button")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C2
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    //
    lazy var aboutElectricPowerImgView: UIImageView = {
      let iv = UIImageView()
        iv.image = bundleImageFromImageName("scan_qrcode_voice_type2")?.rtlImage()
        return iv
    }()
    
    
    
    lazy var alreadyHeadVoiceCheckBoxBtn: A4xBaseCheckBoxButton = {
        var checkBoxBtn = A4xBaseCheckBoxButton()
        checkBoxBtn.backgroundColor = UIColor.clear
        checkBoxBtn.addx_expandSize(size: 10)
        checkBoxBtn.setImage(image: bundleImageFromImageName("rember_voice_check_unselect")?.rtlImage(), state: A4xBaseCheckBoxState.normail)
        checkBoxBtn.setImage(image: bundleImageFromImageName("rember_voice_check_select"), state: A4xBaseCheckBoxState.selected)
        return checkBoxBtn
    }()
    
    
    lazy var alreadyHeadVoiceLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "heard_scaning_sound")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    
    lazy var fallIntoTroubleLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "have_problem")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.Theme
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.navView.isHidden = false
        
        titleLbl.isHidden = true
        titleHintTxtView.isHidden = true
        nextBtn.isEnabled = false
        
        let alreadyHeadVoiceStr = A4xBaseManager.shared.getLocalString(key: "heard_scaning_sound")
        let attrString = NSMutableAttributedString(string:alreadyHeadVoiceStr)
        let param = NSMutableParagraphStyle()
        param.alignment = .left
        attrString.addAttribute(.paragraphStyle, value: param, range: NSRange(location: 0, length: attrString.string.count))
        attrString.addAttribute(.font, value: UIFont.regular(15), range: NSRange(location: 0, length: attrString.string.count))
        attrString.addAttribute(.foregroundColor, value: ADTheme.C1, range: NSRange(location: 0, length: attrString.string.count))
        alreadyHeadVoiceLbl.attributedText = attrString
        
        
        let tip1Str = A4xBaseManager.shared.getLocalString(key: "double_click_power_button")
        let tip1AttrString = NSMutableAttributedString(string:tip1Str)
        let tip1Param = NSMutableParagraphStyle()
        tip1Param.alignment = .left
        tip1AttrString.addAttribute(.paragraphStyle, value: tip1Param, range: NSRange(location: 0, length: tip1AttrString.string.count))
        tip1AttrString.addAttribute(.font, value: UIFont.regular(15), range: NSRange(location: 0, length: tip1AttrString.string.count))
        tip1AttrString.addAttribute(.foregroundColor, value: ADTheme.C2, range: NSRange(location: 0, length: tip1AttrString.string.count))
        tip1AttrString.string.ranges(of: A4xBaseManager.shared.getLocalString(key: "change_net_device_power_des_key_point")).forEach { [weak tip1AttrString] (range) in
            tip1AttrString?.addAttribute(.foregroundColor, value: ADTheme.Theme, range: range)
            tip1AttrString?.addAttribute(.font, value: UIFont.heavy(18), range: range)
        }
        aboutBatteryTipsLbl.attributedText = tip1AttrString

        
        let tip2Str = A4xBaseManager.shared.getLocalString(key: "long_press_reset_button")
        let tip2AttrString = NSMutableAttributedString(string:tip2Str)
        let tip2Param = NSMutableParagraphStyle()
        tip2Param.alignment = .left
        tip2AttrString.addAttribute(.paragraphStyle, value: tip2Param, range: NSRange(location: 0, length: tip2AttrString.string.count))
        tip2AttrString.addAttribute(.font, value: UIFont.regular(15), range: NSRange(location: 0, length: tip2AttrString.string.count))
        tip2AttrString.addAttribute(.foregroundColor, value: ADTheme.C2, range: NSRange(location: 0, length: tip2AttrString.string.count))
        tip2AttrString.string.ranges(of: A4xBaseManager.shared.getLocalString(key: "add_device_power_des_key_point")).forEach { [weak tip2AttrString] (range) in
            tip2AttrString?.addAttribute(.foregroundColor, value: ADTheme.Theme, range: range)
            tip2AttrString?.addAttribute(.font, value: UIFont.heavy(18), range: range)
        }
        aboutElectricPowerTipsLbl.attributedText = tip2AttrString
        
        addSubview(aboutBatteryLbl)
        addSubview(aboutBatteryTipsLbl)
        addSubview(aboutBatteryImgView)
        
        addSubview(aboutElectricPowerLbl)
        addSubview(aboutElectricPowerTipsLbl)
        addSubview(aboutElectricPowerImgView)
        
        addSubview(alreadyHeadVoiceCheckBoxBtn)
        addSubview(alreadyHeadVoiceLbl)
        addSubview(fallIntoTroubleLbl)
        
        
        titleLbl.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.navView.snp.bottom).offset(0)
            make.width.equalTo(self.snp.width).offset(-62.auto())
        }
        
        
        nextBtn.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-42.auto())
            make.height.equalTo(50.auto())
            make.bottom.equalTo(self.snp.bottom).offset(-81.auto())
        }
        
        
        aboutBatteryLbl.snp.remakeConstraints { make in
            make.top.equalTo(self.navView.snp.bottom).offset(0)
            make.leading.equalTo(self.snp.leading).offset(16.auto())
            make.width.equalTo(self.snp.width).offset(-32.auto())
        }
        
        
        aboutBatteryTipsLbl.snp.remakeConstraints { make in
            make.top.equalTo(aboutBatteryLbl.snp.bottom).offset(8.auto())
            make.leading.equalTo(aboutBatteryLbl.snp.leading).offset(0)
            make.width.equalTo(self.snp.width).offset(-32.auto())
        }
        
        
        aboutBatteryImgView.snp.remakeConstraints { make in
            make.top.equalTo(aboutBatteryTipsLbl.snp.bottom).offset(7.5.auto())
            make.centerX.equalTo(self.snp.centerX).offset(0)
            make.size.equalTo(CGSize(width: 283.5.auto(), height: 121.5.auto()))
        }
        
        
        aboutElectricPowerLbl.snp.remakeConstraints { make in
            make.top.equalTo(aboutBatteryImgView.snp.bottom).offset(16.5.auto())
            make.leading.equalTo(self.snp.leading).offset(16.auto())
            make.width.equalTo(self.snp.width).offset(-32.auto())
        }
        
        
        aboutElectricPowerTipsLbl.snp.remakeConstraints { make in
            make.top.equalTo(aboutElectricPowerLbl.snp.bottom).offset(7.5.auto())
            make.leading.equalTo(aboutElectricPowerLbl.snp.leading).offset(0)
            make.width.equalTo(self.snp.width).offset(-32.auto())
        }
        
        
        aboutElectricPowerImgView.snp.remakeConstraints { make in
            make.top.equalTo(aboutElectricPowerTipsLbl.snp.bottom).offset(7.5.auto())
            make.centerX.equalTo(self.snp.centerX).offset(0)
            make.size.equalTo(CGSize(width: 283.5.auto(), height: 121.5.auto()))
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
        
        
        fallIntoTroubleLbl.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom).offset(-33.auto())
            make.width.equalTo(266.5.auto())
        })
        
        
        alreadyHeadVoiceCheckBoxBtn.addTarget(self, action: #selector(alreadyHeadVoiveNothingCheckBoxAction(sender:)), for: UIControl.Event.touchUpInside)
        
        
        alreadyHeadVoiceLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alreadyHeadVoiveNothingLblClick)))
        
        
        nextBtn.addTarget(self, action: #selector(reSetGuideViewNextAction), for: .touchUpInside)
        
        
        fallIntoTroubleLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fallIntoTrouble)))
        
        
    }
    
    
    @objc func alreadyHeadVoiveNothingCheckBoxAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        alreadyHeadVoiveNothingCheck = sender.isSelected
        nextBtn.isEnabled = sender.isSelected
    }
    
    
    @objc func alreadyHeadVoiveNothingLblClick() {
        alreadyHeadVoiveNothingCheck = !alreadyHeadVoiveNothingCheck
        alreadyHeadVoiceCheckBoxBtn.isSelected = alreadyHeadVoiveNothingCheck
        nextBtn.isEnabled = alreadyHeadVoiveNothingCheck
    }
    
    
    @objc func reSetGuideViewNextAction() {
        self.protocol?.reSetGuideViewNextAction()
    }
    
    
    @objc func fallIntoTrouble() {
        self.protocol?.fallIntoTrouble()
    }
}
