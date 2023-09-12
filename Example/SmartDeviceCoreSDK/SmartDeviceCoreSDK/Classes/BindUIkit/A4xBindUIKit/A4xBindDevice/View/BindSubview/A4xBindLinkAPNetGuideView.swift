//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol A4xBindLinkAPNetGuideViewProtocol: class {
    func nextActionToConnectWait()
}

class A4xBindLinkAPNetGuideView: A4xBindBaseView {
    
    weak var `protocol`: A4xBindLinkAPNetGuideViewProtocol?
    
    var backClick: (()->Void)?
    
    var zendeskChatClick: (()->Void)?
    
    override var datas: Dictionary<String, String>? {
        didSet {
            let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
            if !(datas?["nextEnable"]?.isBlank ?? true) {
                nextBtn.isEnabled = datas?["nextEnable"] == "1" ? true : false
            }
            
            if !(datas?["titleHint"]?.isBlank ?? true) {
                titleHintTxtView.attributedText = attrString(str: "\(A4xBaseManager.shared.getLocalString(key: "bind_ap_help_content", param: [ADTheme.APPName, tempString])) \n \(datas?["titleHint"] ?? "")", subStr: "\(datas?["titleHint"] ?? "")")
                titleHintTxtView.isHidden = false
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
        
        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "bind_ap_title")
        nextBtn.isEnabled = true
        nextBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "next"), for: UIControl.State.normal)
        nextBtn.isHidden = true
       
        
        titleLbl.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.navView.snp.bottom).offset(0)
            make.width.equalTo(self.snp.width).offset(-62.auto())
        }
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        titleHintTxtView.isHidden = false
        titleHintTxtView.text(text: A4xBaseManager.shared.getLocalString(key: "bind_ap_help_content", param: [ADTheme.APPName, tempString]), links: ("", "")) {
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
        
        nextBtn.addTarget(self, action: #selector(nextActionToConnectWait), for: .touchUpInside)
    }
    
    @objc private func nextActionToConnectWait() {
        self.protocol?.nextActionToConnectWait()
    }
    
    private func attrString(str : String, subStr: String) -> NSAttributedString {
        
        let attrString = NSMutableAttributedString(string: str)
        
        let param = NSMutableParagraphStyle()
        param.alignment = .center
        //param.lineSpacing = 3
        
        attrString.addAttribute(.paragraphStyle, value: param, range: NSRange(location: 0, length: attrString.string.count))
        attrString.addAttribute(.font, value: UIFont.regular(13), range: NSRange(location: 0, length: attrString.string.count))
        attrString.addAttribute(.foregroundColor, value: ADTheme.C3, range: NSRange(location: 0, length: attrString.string.count))
        
        attrString.string.ranges(of: "\(subStr)").forEach { [weak attrString](range) in
            attrString?.addAttribute(.foregroundColor, value: ADTheme.Theme, range: range)
            attrString?.addAttribute(.font, value: UIFont.regular(17), range: range)
        }
        return attrString
    }
    
}
