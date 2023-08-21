//


//


//

import UIKit
import SmartDeviceCoreSDK

public class A4xBaseAlertView: UIView, A4xBaseAlertViewProtocol {
    public var onHiddenBlock: ((@escaping () -> Void) -> Void)?
    
    public var identifier: String
    
    public var config: A4xBaseAlertConfig
    
    public var title: String? {
        didSet {
            self.setUpView()
        }
    }
    
    public var titleAttr: NSAttributedString? {
        didSet {
            self.setUpView()
        }
    }
    
    public var showClose: Bool = false {
        didSet {
            self.setUpView()
        }
    }

    public var message: String? {
        didSet {
            self.setUpView()
        }
    }
    
    public var remindAgainTip: String? {
        didSet {
            self.setUpView()
        }
    }
    
    public var messageAttr: NSAttributedString? {
        didSet {
            self.setUpView()
        }
    }
    
    public var specialMsg: (String?, String?) {
        didSet {
            self.setUpView()
        }
    }
    
    public var leftButtonTitle: String? {
        didSet {
            self.setUpView()
        }
    }
    
    public var rightButtonTitle: String? {
        didSet {
            self.setUpView()
        }
    }
    
    private var remindAgainCheck: Bool = false
    
    public var rightButtonBlock: (()->Void)?
    
    public var leftButtonBlock: (()->Void)?

    public var closeButtonBlock: (()->Void)?

    public var alertConfigInfo: A4xBaseAlertAnimailConfig {
        didSet {
           self.setUpView()
        }
    }
    
    private let gifManager = A4xBaseGifManager(memoryLimit: 50)
    
    private lazy var titleView: UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.numberOfLines = 0
        //temp.backgroundColor = .blue
        temp.lineBreakMode = .byWordWrapping
        self.addSubview(temp)
        return temp
    }()
    
    private lazy var messageView: UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.numberOfLines = 0
        temp.isHidden = true
        temp.lineBreakMode = .byWordWrapping
        self.addSubview(temp)
        return temp
    }()
    
    private lazy var remindAgainTipLbl: UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.numberOfLines = 0
        temp.isHidden = true
        temp.lineBreakMode = .byWordWrapping
        temp.isUserInteractionEnabled = true
        temp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(remindAgainTipLblClick)))
        self.addSubview(temp)
        return temp
    }()
    
    lazy var remindAgainTipCheckBoxBtn: A4xBaseCheckBoxButton = {
        var checkBoxBtn = A4xBaseCheckBoxButton()
        checkBoxBtn.backgroundColor = UIColor.clear
        checkBoxBtn.addx_expandSize(size: 12.auto())
        checkBoxBtn.setImage(image: bundleImageFromImageName("rember_voice_check_unselect")?.rtlImage(), state: A4xBaseCheckBoxState.normail)
        checkBoxBtn.setImage(image: bundleImageFromImageName("rember_voice_check_select"), state: A4xBaseCheckBoxState.selected)
        checkBoxBtn.addTarget(self, action: #selector(remindAgainTipCheckBoxAction(sender:)), for: UIControl.Event.touchUpInside)
        self.addSubview(checkBoxBtn)
        return checkBoxBtn
    }()
    
    
    
    private lazy var specialMsgView: UIView = {
        let v = UIView()
        v.isHidden = true
        self.addSubview(v)
        return v
    }()
    
    
    private lazy var specialMsgWiFiNameTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.regular(14)
        lbl.textColor = ADTheme.C2
        lbl.text = A4xBaseManager.shared.getLocalString(key: "wifi_name")
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        self.specialMsgView.addSubview(lbl)
        return lbl
    }()
    
    
    private lazy var specialMsgWiFiNameLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.heavy(13)
        lbl.textColor = ADTheme.C1
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        self.specialMsgView.addSubview(lbl)
        return lbl
    }()
    
    
    private lazy var specialMsgWiFiPwdTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.text = A4xBaseManager.shared.getLocalString(key: "wifi_password")
        lbl.font = UIFont.regular(14)
        lbl.textColor = ADTheme.C2
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        self.specialMsgView.addSubview(lbl)
        return lbl
    }()
    
    
    private lazy var specialMsgWiFiPwdLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.heavy(13)
        lbl.textColor = ADTheme.C1
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        self.specialMsgView.addSubview(lbl)
        return lbl
    }()
    
    
    private lazy var msgImgView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = bundleImageFromImageName("remember_wifi_intro_info")?.rtlImage()
        self.addSubview(iv)
        return iv
    }()
    
    private lazy var closeView: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "select_place_close"
        temp.setImage(bundleImageFromImageName("select_place_close")?.rtlImage(), for: .normal)
        temp.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        self.addSubview(temp)
        return temp
    }()
    
    private lazy var leftView: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "alert_left_button"
        temp.addTarget(self, action: #selector(leftButtonAction), for: .touchUpInside)
        self.addSubview(temp)
        return temp
    }()
    
    private lazy var rightView: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "alert_right_button"
        temp.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        self.addSubview(temp)
        return temp
    }()
    
    public init(frame: CGRect = CGRect.zero, config: A4xBaseAlertConfig = A4xBaseAlertConfig(), param: A4xBaseAlertAnimailConfig = A4xBaseAlertAnimailConfig(), identifier: String) {
        self.identifier = identifier
        self.config = config
        self.alertConfigInfo = param
        super.init(frame: frame)
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadAttrTitle() -> NSAttributedString? {
        guard self.titleAttr == nil else {
            return self.titleAttr
        }
        guard let t = title else {
            return nil
        }
        let attr = NSMutableAttributedString(string: t)
        attr.addAttribute(NSAttributedString.Key.font, value: alertConfigInfo.alertTitleFont, range: NSRange(location: 0, length: t.count))
        attr.addAttribute(NSAttributedString.Key.foregroundColor, value: alertConfigInfo.titleColor, range: NSRange(location: 0, length: t.count))
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alertConfigInfo.titleAlignment
        paragraphStyle.lineSpacing = 3
        paragraphStyle.lineBreakMode = .byWordWrapping
        attr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: t.count))
        return attr
    }
    
    func loadSpecialMsg() -> (String?, String?)? {
        guard self.specialMsg.0 != nil else {
            return nil
        }
        return self.specialMsg
    }
    
    func loadMessage() -> NSAttributedString? {
        guard self.messageAttr == nil else {
            return self.messageAttr
        }
        
        guard let t = message else {
            return nil
        }
        
        let attr = NSMutableAttributedString(string: t)
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        if t == "\(A4xBaseManager.shared.getLocalString(key: "motion_alarm", param: [tempString]))\n\(A4xBaseManager.shared.getLocalString(key: "Indoor_motion_alarm"))" {
            attr.addAttribute(NSAttributedString.Key.font, value: UIFont.regular(17), range: NSRange(location: 0, length: t.count))
            attr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.colorFromHex("#2F3742"), range: NSRange(location: 0, length: t.count))
            
            attr.string.ranges(of: A4xBaseManager.shared.getLocalString(key: "Indoor_motion_alarm")).forEach { [weak attr](range) in
                attr?.addAttribute(.foregroundColor, value: ADTheme.C2, range: range)
                attr?.addAttribute(.font, value: UIFont.regular(14), range: range)
            }
            
        } else {
            attr.addAttribute(NSAttributedString.Key.font, value: alertConfigInfo.messageFont, range: NSRange(location: 0, length: t.count))
            attr.addAttribute(NSAttributedString.Key.foregroundColor, value: alertConfigInfo.messageColor, range: NSRange(location: 0, length: t.count))
        }
        
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = CGFloat(alertConfigInfo.messageLinespace) //大小调整
        paragraphStyle.alignment = alertConfigInfo.messageAlignment
        attr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attr.string.count))
        
        return attr
    }
    
    func loadLeftButtonStyle() {
        self.leftView.isHidden = true
        self.leftView.titleLabel?.font = alertConfigInfo.buttonFont
        self.leftView.setTitleColor(alertConfigInfo.leftTitleColor, for: .normal)
        self.leftView.backgroundColor = alertConfigInfo.leftbtnBgColor
    }
    
    func loadRightButtonStyle() {
        self.rightView.isHidden = true
        self.rightView.titleLabel?.font = alertConfigInfo.buttonFont
        self.rightView.setTitleColor(alertConfigInfo.rightTextColor, for: .normal)
        self.rightView.backgroundColor = alertConfigInfo.rightbtnBgColor
    }
    
    @objc func closeAction() {
        self.onHiddenBlock?{}
        self.closeButtonBlock?()
    }
    
    @objc func leftButtonAction() {
        weak var weakSelf = self
        self.onHiddenBlock?{
            weakSelf?.leftButtonBlock?()
        }
    }
    
    @objc func rightButtonAction() {
        weak var weakSelf = self
        self.onHiddenBlock? {
            weakSelf?.rightButtonBlock?()
        }
    }
    
    @objc private func remindAgainTipCheckBoxAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        remindAgainCheck = sender.isSelected
        saveRemindAgainStateToCache()
    }
    
    @objc private func remindAgainTipLblClick() {
        remindAgainCheck = !remindAgainCheck
        remindAgainTipCheckBoxBtn.isSelected = remindAgainCheck
        saveRemindAgainStateToCache()
    }
    
    private func saveRemindAgainStateToCache() {
        let remindAgainSaveKey = alertConfigInfo.remindAgainSaveKey ?? "REMIND_AGAIN_CHECK"
        UserDefaults.standard.set(remindAgainCheck, forKey: remindAgainSaveKey)
        UserDefaults.standard.synchronize()
    }
    
    deinit {
        
    }
}


extension A4xBaseAlertView {
    
    private func setUpView(){
        var maxHeight : CGFloat = 0
        let width = CGFloat(alertConfigInfo.alertWidth - alertConfigInfo.padding * 2)
        
        loadColseButton(width: width, maxY: &maxHeight)
        
        loadTitleView(width: width, maxY: &maxHeight)
        
        loadMessageImgView(width: width, maxY: &maxHeight)
        
        loadMessageView(width: width, maxY: &maxHeight)
        
        //loadSpecialMsgView(width: width , maxY: &maxHeight)
        
        loadBottomItem(width: width, maxY: &maxHeight)
        
        loadContentView( maxY: maxHeight)

    }
    
    private func loadContentView(maxY: CGFloat) {
        self.backgroundColor = UIColor.white
        self.isUserInteractionEnabled = true
        self.layer.cornerRadius = CGFloat(alertConfigInfo.cornerRadius)
        self.frame = CGRect(x: 20, y: 100, width: CGFloat(alertConfigInfo.alertWidth), height: maxY)
    }
    
    private func loadColseButton(width: CGFloat, maxY: inout CGFloat) {
        self.closeView.isHidden = !self.showClose

        if self.showClose {
            self.closeView.frame = CGRect(x: width - 20, y: CGFloat(alertConfigInfo.padding) - 10, width: 40, height: 40)
            maxY += CGFloat(alertConfigInfo.buttonSectionExtraGap)
        }
    }
    
    private func loadTitleView(width: CGFloat, maxY: inout CGFloat) {
        
        if let title = self.loadAttrTitle() {
            maxY +=  CGFloat(alertConfigInfo.topSectionExtraGap)
            
            self.titleView.attributedText = title
            self.titleView.textAlignment = alertConfigInfo.titleAlignment
            self.titleView.isHidden = false
            let size = self.titleView.sizeThatFits(CGSize(width: width - CGFloat(alertConfigInfo.padding * 2), height:  100))
            //self.titleView.frame = CGRect(x: CGFloat(alertConfigInfo.padding * 2), y: maxY, width: size.width, height: size.height)
            self.titleView.frame = CGRect(x: CGFloat(alertConfigInfo.padding) + (width - size.width)/2.0, y: maxY, width: size.width, height: size.height)
            maxY += size.height + CGFloat(alertConfigInfo.innerPadding)
        } else {
            self.titleView.isHidden = true
            maxY +=  CGFloat(alertConfigInfo.buttonSectionExtraGap) + CGFloat(alertConfigInfo.padding)
            
        }
    }
    
    private func loadSpecialMsgView(width: CGFloat, maxY: inout CGFloat) {
        if let message = self.loadSpecialMsg() {
            self.specialMsgView.isHidden = false
            let inMaxY = maxY
            
            let wifiNameTitleSize = self.specialMsgWiFiNameTitleLbl.sizeThatFits(CGSize(width: 1000, height: 20))
            let wifiPwdTitleSize = self.specialMsgWiFiPwdTitleLbl.sizeThatFits(CGSize(width: 1000, height: 20))
            let minWifiTitleSizeWidth = min(wifiNameTitleSize.width, wifiPwdTitleSize.width)
    
            let wifiNameTitleHeightSize = self.specialMsgWiFiNameTitleLbl.sizeThatFits(CGSize(width: minWifiTitleSizeWidth, height: 100))
            self.specialMsgWiFiNameTitleLbl.frame = CGRect(x: CGFloat(alertConfigInfo.padding * 2) + 8, y: 0 , width: minWifiTitleSizeWidth, height: wifiNameTitleHeightSize.height)
            
            self.specialMsgWiFiNameLbl.text = message.0
            let wifiNameSize = self.specialMsgWiFiNameLbl.sizeThatFits(CGSize(width: width - minWifiTitleSizeWidth - CGFloat(alertConfigInfo.padding * 4), height:  100))
            
            self.specialMsgWiFiNameLbl.frame = CGRect(x: CGFloat(alertConfigInfo.padding * 2) + minWifiTitleSizeWidth + 16, y: 0, width: wifiNameSize.width, height: max(wifiNameSize.height, 20))
            
            maxY += max(wifiNameTitleHeightSize.height, self.specialMsgWiFiNameLbl.height)
            
            let wifiPwdTitleHeightSize = self.specialMsgWiFiPwdTitleLbl.sizeThatFits(CGSize(width: minWifiTitleSizeWidth, height: 100))
            self.specialMsgWiFiPwdTitleLbl.frame = CGRect(x: CGFloat(alertConfigInfo.padding * 2) + 8, y: self.specialMsgWiFiNameLbl.height, width: minWifiTitleSizeWidth, height: wifiPwdTitleHeightSize.height)
            
            self.specialMsgWiFiPwdLbl.text = message.1
            let wifiPwdSize = self.specialMsgWiFiPwdLbl.sizeThatFits(CGSize(width: width - minWifiTitleSizeWidth - CGFloat(alertConfigInfo.padding * 4), height: 100))
            self.specialMsgWiFiPwdLbl.frame = CGRect(x: CGFloat(alertConfigInfo.padding * 2) + minWifiTitleSizeWidth + 16, y: self.specialMsgWiFiNameLbl.height, width: wifiPwdSize.width, height: max(wifiPwdSize.height, 20))
            
            maxY += max(wifiPwdTitleHeightSize.height, self.specialMsgWiFiPwdLbl.height)
            self.specialMsgView.frame = CGRect(x: 0, y: inMaxY, width: CGFloat(alertConfigInfo.alertWidth), height: max(maxY, 20))
            
            maxY += CGFloat(alertConfigInfo.buttonSectionExtraGap)
            
            if self.titleView.isHidden {
                maxY += CGFloat(alertConfigInfo.padding)
            }
        } else {
            self.specialMsgView.isHidden = true
        }
    }
    
    private func loadMessageView(width: CGFloat, maxY: inout CGFloat) {
        if let message = self.loadMessage() {
            self.messageView.isHidden = false
            self.messageView.textAlignment = alertConfigInfo.messageAlignment
            self.messageView.attributedText = message
            let size = self.messageView.sizeThatFits(CGSize(width: width  - CGFloat(alertConfigInfo.padding * 2), height: CGFloat(MAXFLOAT)))
            self.messageView.frame = CGRect(x: CGFloat(alertConfigInfo.padding) + (width - size.width) / 2.0, y: maxY, width: size.width, height: max(size.height, 30))
            maxY += self.messageView.height + CGFloat(alertConfigInfo.buttonSectionExtraGap)
            
            if !(remindAgainTip?.isBlank ?? true) {
                self.remindAgainTipLbl.isHidden = false
                self.remindAgainTipLbl.textAlignment = .left
                self.remindAgainTipLbl.textColor = ADTheme.C3
                self.remindAgainTipLbl.text = remindAgainTip
                let size = self.remindAgainTipLbl.sizeThatFits(CGSize(width: width  - CGFloat(alertConfigInfo.padding * 2), height: CGFloat(MAXFLOAT)))
                var remindAgainTipLblX = CGFloat(alertConfigInfo.padding) + (width - size.width) / 2.0 + 14.auto()
                if self.isRTL() {
                    remindAgainTipLblX = CGFloat(alertConfigInfo.padding) + (width - size.width) / 2.0 - 14.auto()
                }
                self.remindAgainTipLbl.frame = CGRect(x: remindAgainTipLblX, y: maxY, width: size.width, height: min(size.height, 63.auto()))
                
                self.remindAgainTipCheckBoxBtn.isHidden = false
                let remindAgainSaveKey = alertConfigInfo.remindAgainSaveKey ?? "REMIND_AGAIN_CHECK"
                let isRemindAgain = UserDefaults.standard.bool(forKey: remindAgainSaveKey)
                self.remindAgainTipCheckBoxBtn.isSelected = isRemindAgain
                var remindAgainTipCheckBoxBtnX = remindAgainTipLbl.minX - 8.auto() - 12.auto()
                if self.isRTL() {
                    remindAgainTipCheckBoxBtnX = remindAgainTipLbl.maxX + 8.auto()
                }
                self.remindAgainTipCheckBoxBtn.frame = CGRect(x: remindAgainTipCheckBoxBtnX, y: self.remindAgainTipLbl.midY - 6.auto(), width: 12.auto(), height: 12.auto())
                
                maxY += self.remindAgainTipLbl.height + CGFloat(alertConfigInfo.buttonSectionExtraGap)
            }
            
            if self.titleView.isHidden {
                maxY += CGFloat(alertConfigInfo.padding)
            }
            
        } else {
            self.messageView.isHidden = true
        }
    }
    
    private func loadMessageImgView(width: CGFloat, maxY: inout CGFloat) {
        if self.loadMessage() != nil && alertConfigInfo.messageImg != nil {
            self.msgImgView.isHidden = false
            
            let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
            if message == "\(A4xBaseManager.shared.getLocalString(key: "motion_alarm", param: [tempString]))\n\(A4xBaseManager.shared.getLocalString(key: "Indoor_motion_alarm"))" {
                self.msgImgView.setGifImage(alertConfigInfo.messageImg ?? UIImage(gifName: "device_alarm.gif"), manager: gifManager, loopCount: -1)
                self.msgImgView.frame = CGRect(x: (width - 81.5.auto() + CGFloat(alertConfigInfo.padding * 2)) / 2.0, y: 20, width: 81.5.auto(), height: 96.5.auto())
            } else {
                self.msgImgView.image = alertConfigInfo.messageImg
                self.msgImgView.frame = CGRect(x: (width - 30) / 2.0, y: 20, width: 40, height: 40)
            }
            
            maxY += self.msgImgView.height + CGFloat(alertConfigInfo.buttonSectionExtraGap)
            
            if self.titleView.isHidden {
                maxY += CGFloat(alertConfigInfo.padding)
            }
        } else {
            self.messageView.isHidden = true
        }
    }
    
    private func shouldAddBorder(view: UIView) -> Bool {
        if view.backgroundColor == nil {
            return true
        }
        if view.backgroundColor! == UIColor.white || view.backgroundColor! == UIColor.clear {
            return true
        }
        return false
    }
    
    private func loadBottomItem(width: CGFloat, maxY: inout CGFloat) {
        self.loadLeftButtonStyle()
        self.loadRightButtonStyle()
        
        self.leftView.setTitle(self.leftButtonTitle, for: .normal)
        self.rightView.setTitle(self.rightButtonTitle, for: .normal)
        self.leftView.isHidden = self.leftButtonTitle == nil
        self.rightView.isHidden = self.rightButtonTitle == nil
        
        if self.leftButtonTitle != nil || self.rightButtonTitle != nil {
            if self.leftButtonTitle != nil && self.rightButtonTitle != nil {
                switch alertConfigInfo.bottomAlignment {
                case .horizontal:
                    let itemWidth = alertConfigInfo.alertWidth / 2
                    self.leftView.frame = CGRect(x: 0, y: maxY, width: CGFloat(itemWidth), height: CGFloat(alertConfigInfo.buttonHeight))
                    self.leftView.resetFrameToFitRTL()
                    if self.shouldAddBorder(view: self.leftView) {
                        self.leftView.addBorder(toSide: UIView.ViewSide.Top, withColor: alertConfigInfo.buttonBorderColor, andThickness: 1)
                        self.leftView.addBorder(toSide: self.isRTL() ? UIView.ViewSide.Left : UIView.ViewSide.Right, withColor: alertConfigInfo.buttonBorderColor, andThickness: 1)
                    }
                   
                    self.rightView.frame = CGRect(x: A4xBaseManager.shared.isRTL() ? 0 : self.leftView.frame.maxX, y: maxY, width: CGFloat(itemWidth), height: CGFloat(alertConfigInfo.buttonHeight))
                    //self.rightView.resetFrameToFitRTL()
                    if self.shouldAddBorder(view: self.rightView) {
                        self.rightView.addBorder(toSide: UIView.ViewSide.Top, withColor: alertConfigInfo.buttonBorderColor, andThickness: 1)
                    }
                    maxY += CGFloat(alertConfigInfo.buttonHeight)
                case .vertical:
                    self.leftView.frame = CGRect(x: 0, y: maxY, width: CGFloat(alertConfigInfo.alertWidth), height: CGFloat(alertConfigInfo.buttonHeight))
                    if self.shouldAddBorder(view: self.leftView) {
                        self.leftView.addBorder(toSide: UIView.ViewSide.Top, withColor: alertConfigInfo.buttonBorderColor, andThickness: 1)
                        self.leftView.addBorder(toSide: UIView.ViewSide.Bottom, withColor: alertConfigInfo.buttonBorderColor, andThickness: 1)
                    }
                   
                    maxY += CGFloat(alertConfigInfo.buttonHeight)
                    self.rightView.frame = CGRect(x: 0, y: maxY, width: CGFloat(alertConfigInfo.alertWidth), height: CGFloat(alertConfigInfo.buttonHeight))
                    maxY += CGFloat(alertConfigInfo.buttonHeight)
                }
            } else {
                let v = self.leftButtonTitle == nil ? self.rightView : self.leftView
                v.frame = CGRect(x: 0, y: maxY, width: CGFloat(alertConfigInfo.alertWidth), height: CGFloat(alertConfigInfo.buttonHeight))
                if self.shouldAddBorder(view: v) {
                    v.addBorder(toSide: UIView.ViewSide.Top, withColor: alertConfigInfo.buttonBorderColor, andThickness: 1)
                }
                maxY += CGFloat(alertConfigInfo.buttonHeight)
            }
        }
    }
    
    private func isRTL() -> Bool {
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            return true
        }
        return false
    }
}


public extension UIView {
    enum ViewSide {
        case Top, Bottom, Left, Right
    }

    func addBorder(toSide side: ViewSide, withColor color: UIColor, andThickness thickness: CGFloat) {

        let border = CALayer()
        border.backgroundColor = color.cgColor

        switch side {
        case .Top:
            border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: thickness)
        case .Bottom:
            border.frame = CGRect(x: 0, y: frame.size.height - thickness, width: frame.size.width, height: thickness)
        case .Left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.size.height)
        case .Right:
            border.frame = CGRect(x: frame.size.width - thickness, y: 0, width: thickness, height: frame.size.height)
        }

        layer.addSublayer(border)
    }
}
