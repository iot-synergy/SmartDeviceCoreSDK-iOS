//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol A4xBindManuallyAddAPNetGuideViewProtocol: class {
    func noFindNetLblClick()
    func nextActionToSysSetting()
}

class A4xBindManuallyAddAPNetGuideView: A4xBindBaseView {
    
    weak var `protocol`: A4xBindManuallyAddAPNetGuideViewProtocol?
    
    var backClick: (()->Void)?
    
    var zendeskChatClick: (()->Void)?

    override var datas: Dictionary<String, String>? {
        didSet {
            if !(datas?["nextEnable"]?.isBlank ?? true) {
                nextBtn.isEnabled = datas?["nextEnable"] == "1" ? true : false
            }
            
            if !(datas?["nextBtnTitle"]?.isBlank ?? true) {
                nextBtn.setTitle(datas?["nextBtnTitle"] ?? "", for: .normal)
            }
            
            if !(datas?["apNetName"]?.isBlank ?? true) {
                hintLbl.text = A4xBaseManager.shared.getLocalString(key: "bind_ap_content", param: [datas?["apNetName"] ?? "",ADTheme.APPName])
                self.upWALNContentView.needNetNameLbl.text = datas?["apNetName"] ?? ""
            }
            
            if !(datas?["apNetPwd"]?.isBlank ?? true) {
                hintPwdLbl.text = A4xBaseManager.shared.getLocalString(key: "bind_ap_help_wifi_pw") + (datas?["apNetPwd"] ?? "")
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
    
    
    lazy var upWALNContentView: WLANContentView = {
        var contentView: WLANContentView = WLANContentView()
        return contentView
    }()
    
    //
    lazy var hintLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "bind_ap_content", param: ["******",ADTheme.APPName])
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C3
        lbl.font = UIFont.regular(13)
        return lbl
    }()
    
    
    lazy var hintPwdLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = "" //******
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.regular(16)
        return lbl
    }()
    
    
    lazy var noFindNetLbl: UILabel = {
        var lbl: UILabel = UILabel()
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        lbl.text = A4xBaseManager.shared.getLocalString(key: "bind_ap_no_found_ap", param: [tempString])
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.Theme
        lbl.font = UIFont.regular(16)
        return lbl
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
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "bind_ap_help_title", param: [tempString])
        nextBtn.isEnabled = true
        nextBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "go_set"), for: UIControl.State.normal)
        titleHintTxtView.isHidden = true
        
        //开始动画的播放
        addSubview(self.upWALNContentView)
        
        addSubview(hintLbl)
        addSubview(hintPwdLbl)
        addSubview(noFindNetLbl)
        
        
        titleLbl.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.navView.snp.bottom).offset(0)
            make.width.equalTo(self.snp.width).offset(-62.auto())
        }
        
        self.upWALNContentView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(-120.auto())
            make.width.equalTo(262.4.auto())
            make.height.equalTo(215.5.auto())
        }
        
        
        hintLbl.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.upWALNContentView.snp.bottom).offset(42.5.auto())
            make.width.equalTo(self.snp.width).offset(-32.auto())
        }
        
        hintPwdLbl.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(hintLbl.snp.bottom).offset(8.auto())
            make.width.equalTo(self.snp.width).offset(-32.auto())
        }
        
        
        nextBtn.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-42.auto())
            make.height.equalTo(50.auto())
            if #available(iOS 11.0,*) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-20.auto())
            }else {
                make.bottom.equalTo(self.snp.bottom).offset(-25.auto())
            }
        }
        
        
        noFindNetLbl.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(nextBtn.snp.top).offset(-25.auto())
            make.width.equalTo(self.snp.width).offset(-32.auto())
        }
        
        noFindNetLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(noFindNetLblClick)))
        
        nextBtn.addTarget(self, action: #selector(nextActionToSysSetting), for: .touchUpInside)
    }
    
    
    @objc private func noFindNetLblClick() {
        self.protocol?.noFindNetLblClick()
    }
    
    @objc private func nextActionToSysSetting() {
        self.protocol?.nextActionToSysSetting()
    }
    
}

class WLANContentView: UIView {
    
    var needLinkApName: String? {
        didSet {
            needNetNameLbl.text = needLinkApName
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
        
        addSubview(netTitleLbl)
        addSubview(default1NetNameLbl)
        addSubview(default1NetNameIcon)
        
        addSubview(needNetBgImgView)
        addSubview(needNetNameLbl)

        addSubview(default2NetNameLbl)
        addSubview(default2NetNameIcon)
        
    
        
        guideBgImgView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(0)
            make.width.equalTo(262.4.auto())
            make.height.equalTo(215.5.auto())
        }
        
        
        netTitleLbl.snp.makeConstraints { make in
            make.centerX.equalTo(self.guideBgImgView.snp.centerX)
            make.top.equalTo(self.guideBgImgView.snp.top).offset(50.5.auto())
            make.width.equalTo(self.guideBgImgView.snp.width).offset(-64.auto())
        }
        
        
        default1NetNameLbl.snp.makeConstraints { make in
            make.centerX.equalTo(self.guideBgImgView.snp.centerX)
            make.top.equalTo(netTitleLbl.snp.bottom).offset(15.5.auto())
            make.width.equalTo(self.guideBgImgView.snp.width).offset(-86.auto())
        }
        
        
        default1NetNameIcon.snp.makeConstraints { make in
            make.trailing.equalTo(self.guideBgImgView.snp.trailing).offset(-39.5.auto())
            make.centerY.equalTo(default1NetNameLbl.snp.centerY)
            make.width.equalTo(16.auto())
            make.height.equalTo(16.auto())
        }
        
        
        needNetBgImgView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(default1NetNameLbl.snp.bottom).offset(2.auto())
            make.width.equalTo(262.5.auto())
            make.height.equalTo(65.auto())
        }
        
        
        needNetNameLbl.snp.makeConstraints { make in
            make.leading.equalTo(needNetBgImgView.snp.leading).offset(43.auto())
            make.centerY.equalTo(needNetBgImgView.snp.centerY).offset(-2)
            make.width.equalTo(needNetBgImgView.snp.width).offset(-80.auto())
        }
        
        
        default2NetNameLbl.snp.makeConstraints { make in
            make.centerX.equalTo(self.guideBgImgView.snp.centerX)
            make.top.equalTo(needNetBgImgView.snp.bottom).offset(1.auto())
            make.width.equalTo(self.guideBgImgView.snp.width).offset(-86.auto())
        }
        
        
        default2NetNameIcon.snp.makeConstraints { make in
            make.trailing.equalTo(self.guideBgImgView.snp.trailing).offset(-39.5.auto())
            make.centerY.equalTo(default2NetNameLbl.snp.centerY)
            make.width.equalTo(16.auto())
            make.height.equalTo(16.auto())
        }
    }
    
    //
    lazy var guideBgImgView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = bundleImageFromImageName("bind_device_link_ap_guide_bg")
        return iv
    }()
    
    lazy var netTitleLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "wifi") //"无线局域网"//
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.regular(17)
        return lbl
    }()
    
    //
    lazy var default1NetNameLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = "WiFi—internal" //A4xBaseManager.shared.getLocalString(key: "heard_scaning_sound")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .left
        lbl.textColor = ADTheme.C3
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    //
    lazy var default1NetNameIcon: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = bundleImageFromImageName("bind_device_bluetooth_wifi")
        return iv
    }()
    
    //
    lazy var needNetBgImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = bundleImageFromImageName("bind_device_link_ap_guide")
        return iv
    }()
    
    //
    lazy var needNetNameLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = "IPC-XXXXXXXX0000"//A4xBaseManager.shared.getLocalString(key: "heard_scaning_sound")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .left
        lbl.lineBreakMode = .byTruncatingTail
        lbl.textColor = UIColor.colorFromHex("#1A1F3C")
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    //
    lazy var default2NetNameLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = "R101i-178za"//A4xBaseManager.shared.getLocalString(key: "heard_scaning_sound")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .left
        lbl.textColor = ADTheme.C3
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    //
    lazy var default2NetNameIcon: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = bundleImageFromImageName("bind_device_bluetooth_wifi")
        return iv
    }()
    
}
