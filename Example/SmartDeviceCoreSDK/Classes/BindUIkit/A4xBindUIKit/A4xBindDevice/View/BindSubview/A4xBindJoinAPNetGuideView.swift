//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol A4xBindJoinAPNetGuideViewProtocol: class {
    func joinAPNetGuideNextAction()
}

class A4xBindJoinAPNetGuideView: A4xBindBaseView {
    
    weak var `protocol`: A4xBindJoinAPNetGuideViewProtocol?
    
    var backClick: (()->Void)?
    
    var zendeskChatClick: (()->Void)?

    override var datas: Dictionary<String, String>? {
        didSet {
            if !(datas?["apSSID"]?.isBlank ?? true) {
                let joinAlterMessage = A4xBaseManager.shared.getLocalString(key: "bind_ap_alert_descr_ios", param: [ADTheme.APPName, datas?["apSSID"] ?? ""])
                let joinAlterMessageHeight = joinAlterMessage.textHeightFromTextString(text: joinAlterMessage, textWidth: 290.auto() - 20.auto(), fontSize: 17.auto(), isBold: false)
                let alertHeight = 40.auto() + 20.auto() + 41.auto() + joinAlterMessageHeight + 48.5.auto()
                self.joinAlertView.alertMessage = (joinAlterMessage, joinAlterMessageHeight)
                self.joinAlertView.snp.updateConstraints { make in
                    make.height.equalTo(alertHeight)
                }
            }
        }
    }
    
    lazy var navView: A4xBaseNavView = {
        let temp = A4xBaseNavView()
        temp.backgroundColor = .clear
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
    
    
    lazy var joinAlertView: JoinAlertContentView = {
        var contentView: JoinAlertContentView = JoinAlertContentView()
        return contentView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (self.isUserInteractionEnabled == false || self.isHidden == true || self.alpha <= 0.01) { return nil }
        if !self.point(inside: point, with: event) { return nil }
        let count = self.subviews.count
        for i in (0...count - 1).reversed() {
            let childV = self.subviews[i]
            let childP = self.convert(point, to: childV)
            let fitView = childV.hitTest(childP, with: event)
            if (fitView != nil) {
                return fitView
            }
        }
        return self
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.bounds.offsetBy(dx: 20, dy: 20).contains(point) {
            return true
        }
        return false
    }
    
    private func setupUI() {
        
        self.navView.isHidden = false
        
        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "bind_connect_ap_page_title")
        nextBtn.isEnabled = true
        nextBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "got_it"), for: UIControl.State.normal)
        titleHintTxtView.isHidden = false
        
        titleHintTxtView.text(text: A4xBaseManager.shared.getLocalString(key: "bind_connect_ap_page_descr"), links: ("", "")) {
            height in
        }
        titleHintTxtView.textAlignment = .center
        titleHintTxtView.linkTextColor = UIColor(hex: "#3495E8") ?? UIColor.blue
        titleHintTxtView.textColor = UIColor.colorFromHex("#999999")
        titleHintTxtView.font = UIFont.regular(13)
        titleHintTxtView.snp.remakeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(titleLbl.snp.bottom).offset(8.auto())
            make.width.equalTo(self.snp.width).offset(-62.auto())
        })
        
        //开始动画的播放
        addSubview(self.joinAlertView)
        
        
        titleLbl.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.navView.snp.bottom).offset(0)
            make.width.equalTo(self.snp.width).offset(-62.auto())
        }
        
        self.joinAlertView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.titleHintTxtView.snp.bottom).offset(32.auto())
            make.width.equalTo(290.auto())
            make.height.equalTo(220.auto())
        }
        
        
        nextBtn.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-42.auto())
            make.height.equalTo(50.auto())
            if #available(iOS 11.0,*) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-20.auto())
            } else {
                make.bottom.equalTo(self.snp.bottom).offset(-25.auto())
            }
        }
        nextBtn.addTarget(self, action: #selector(joinAPNetGuideNextAction), for: .touchUpInside)
    }
    
    @objc private func joinAPNetGuideNextAction() {
        self.protocol?.joinAPNetGuideNextAction()
    }
    
}

class JoinAlertContentView: UIView {
    
    var alertMessage: (String, CGFloat)? {
        didSet {
            contentLbl.text = alertMessage?.0 ?? ""
            let messageHeight = alertMessage?.1 ?? 167.auto()
            let bgHeight = max(messageHeight + 40.auto() + 61.auto(), 167.auto())
            guideBgImgView.snp.updateConstraints { make in
                make.height.equalTo(bgHeight)
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.addSubview(self.guideBgImgView)
        
        addSubview(contentLbl)
        
        addSubview(cancelLbl)
        addSubview(okLbl)
        
        addSubview(dotImageView)
        addSubview(fingerImageView)
        
    
        
        guideBgImgView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(0)
            make.width.equalTo(290.auto())
            make.height.equalTo(167.auto())
        }
        
        
        contentLbl.snp.makeConstraints { make in
            make.centerX.equalTo(self.guideBgImgView.snp.centerX)
            make.top.equalTo(self.guideBgImgView.snp.top).offset(40.auto())
            make.width.equalTo(self.guideBgImgView.snp.width).offset(-20.auto())
        }
        
        
        cancelLbl.snp.makeConstraints { make in
            make.leading.equalTo(guideBgImgView.snp.leading).offset(0)
            make.bottom.equalTo(guideBgImgView.snp.bottom).offset(-10.5.auto())
            make.width.equalTo(290.auto() / 2)
        }
        
        
        okLbl.snp.makeConstraints { make in
            make.trailing.equalTo(guideBgImgView.snp.trailing).offset(0)
            make.bottom.equalTo(guideBgImgView.snp.bottom).offset(-10.5.auto())
            make.width.equalTo(290.auto() / 2)
        }
        
        
        dotImageView.snp.makeConstraints { make in
            make.trailing.equalTo(self.guideBgImgView.snp.trailing).offset(-12.auto())
            make.centerY.equalTo(okLbl.snp.centerY)
            make.width.equalTo(30.auto())
            make.height.equalTo(30.auto())
        }
        
        
        fingerImageView.snp.makeConstraints { make in
            make.leading.equalTo(dotImageView.snp.centerX).offset(-10.auto())
            make.top.equalTo(dotImageView.snp.bottom).offset(-6.auto())
            make.width.equalTo(42.auto())
            make.height.equalTo(56.9.auto())
        }
    }
    
    //
    lazy var guideBgImgView: UIImageView = {
        let iv = UIImageView()
        iv.image = bundleImageFromImageName("bind_device_join_ap_guide")?.resizableImage(withCapInsets: UIEdgeInsets(top: 25, left: 25, bottom: 64, right: 25), resizingMode: UIImage.ResizingMode.stretch)
        return iv
    }()
    
    lazy var contentLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = ""
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = UIColor.colorFromHex("#2F3742")
        lbl.font = UIFont.regular(17)
        return lbl
    }()
    
    //
    lazy var cancelLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "cancel")
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        lbl.textColor = UIColor.colorFromHex("#316DE9")
        lbl.font = UIFont.regular(17)
        return lbl
    }()
    
    //
    lazy var okLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "bind_ap_alert_join_ios")
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        lbl.textColor = UIColor.colorFromHex("#316DE9")
        lbl.font = UIFont.regular(17)
        return lbl
    }()
    
    //
    lazy var dotImageView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = bundleImageFromImageName("bind_device_dot_icon")
        return iv
    }()
    
    lazy var fingerImageView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = bundleImageFromImageName("bind_device_finger_icon")?.rtlImage()
        return iv
    }()
    
}
