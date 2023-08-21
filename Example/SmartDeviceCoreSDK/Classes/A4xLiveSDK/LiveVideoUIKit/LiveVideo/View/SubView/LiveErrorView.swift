//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public enum A4xHomeVideoErrorType {
    case `default`
    case simple
}

public enum A4xHomeVideoButtonStyle : Int {
    case theme
    case line
    case normal
    case none
}

public struct A4xLiveVideoBtnActionItem {
    public init(style: A4xHomeVideoButtonStyle, action: A4xVideoAction) {
        self.style = style
        self.action = action
    }
    
    public var style : A4xHomeVideoButtonStyle
    public var action : A4xVideoAction
    
    public static func `default` (title : String) -> A4xLiveVideoBtnActionItem {
        return A4xLiveVideoBtnActionItem(style: .line, action: .video(title: title, style: .line))
    }
    
    static func upgrade(title : String) -> A4xLiveVideoBtnActionItem {
        return A4xLiveVideoBtnActionItem(style: .theme, action: .upgrade(title: title, style: .theme, clickState: .uptate))
    }
}

class LiveErrorBtnView : UIView {
    var buttonClickAction : ((_ action : A4xVideoAction)->Void)?
    
    
    var buttonItems : [A4xLiveVideoBtnActionItem]? {
        didSet {
            loadItems()
        }
    }
    
    private func loadItems () {
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        guard let itemsSub = buttonItems else {
            return
        }
        
        var tempView : UIView? = nil
        let count = itemsSub.count
        for index in 0 ..< count {
            let item = itemsSub[index]
            let temp : UIButton = UIButton()
            temp.tag = index + 2000
            temp.accessibilityIdentifier = "A4xLiveSDKUIKit_tempView_\(index + 2000)"
            temp.layer.cornerRadius = 35/2
            temp.layer.masksToBounds = true
            temp.titleLabel?.font = ADTheme.B2
            if item.style == .theme {
                temp.setBackgroundImage(UIImage.init(color: ADTheme.Theme), for: .normal)
                temp.setTitleColor(UIColor.white , for: .normal)
                temp.setTitle(item.action.title() , for: .normal)
            } else if item.style == .none {
                temp.setTitleColor(UIColor.white , for: .normal)
                temp.setTitle(item.action.title() , for: .normal)
            } else if item.style == .line {
                temp.setTitleColor(ADTheme.Theme , for: .normal)
                temp.setTitle(item.action.title() , for: .normal)
                temp.titleLabel?.font = ADTheme.B1
            } else if item.style == .normal {
                temp.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#ffffff" ,alpha: 0.2)), for: .normal)
                temp.setTitleColor(UIColor.white , for: .normal)
                temp.setTitle(item.action.title() , for: .normal)
            }
            temp.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
            //temp.titleLabel?.numberOfLines = 0
            temp.titleLabel?.lineBreakMode = .byTruncatingTail
            
            let titleSize = temp.titleLabel?.sizeThatFits(CGSize(width: 150, height: 35))
            self.addSubview(temp)
            
            if count % 2 == 0 { 
                temp.snp.makeConstraints { (make) in
                    
                    make.centerX.equalTo(self.snp.centerX)
                    
                    if item.style == .none || item.style == .line {
                        make.width.equalTo(max(190, (titleSize?.width ?? 0) + 24))
                    } else {
                        make.width.equalTo(max(150, (titleSize?.width ?? 0) + 78))
                    }
                    make.height.equalTo(max(35, (titleSize?.height ?? 0)))
                    
                    if let uTemp = tempView {
                        make.top.equalTo(uTemp.snp.bottom).offset(3.auto())
                    } else {
                        make.top.equalTo(0)
                    }
                    
                    if index == count - 1 {
                        make.trailing.equalTo(self.snp.trailing)
                    }
                }
                
                tempView = temp
                
            } else {  
                
                var topOffset = 0
                var centerXOffset = 0
                
                if index == 0 {
                    if count > 1 {
                        centerXOffset = -95.auto() / 2 - 8
                    }
                } else if index == 1 {
                    centerXOffset = 95.auto() / 2 + 8
                } else if index == count - 1 {
                    topOffset = 38
                }
                
                temp.snp.makeConstraints { (make) in
                    if item.style == .none || item.style == .line {
                        make.width.equalTo(max(190, (titleSize?.width ?? 0) + 24))
                    } else {
                        make.width.equalTo(95.auto())
                    }
                    make.top.equalTo(self.snp.top).offset(topOffset)
                    make.centerX.equalTo(self.snp.centerX).offset(centerXOffset)
                    
                    if count > 1 && index > 0 {
                        if A4xBaseManager.shared.isRTL() {
                            make.leading.equalTo(self.snp.leading)
                        } else {
                            make.trailing.equalTo(self.snp.trailing)
                        }
                    } else {
                        if index == count - 1 {
                            if A4xBaseManager.shared.isRTL() {
                                make.leading.equalTo(self.snp.leading)
                            } else {
                                make.trailing.equalTo(self.snp.trailing)
                            }
                        }
                    }
                    
                    make.height.equalTo(max(35, (titleSize?.height ?? 0)))
                }
            }
            
            
            let loadingV = UIImageView()
            loadingV.image = A4xLiveUIResource.UIImage(named: "live_night_white_loading")?.rtlImage()
            loadingV.size = CGSize(width: 25.auto() , height: 25.auto() )
            temp.addSubview(loadingV)
            loadingV.isHidden = true
            loadingV.tag = index + 1000
            loadingV.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 25.auto(), height: 25.auto()))
                make.center.equalTo(temp.snp.center)
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
    
    private func buttonAttributedString(_ title : String?) -> NSAttributedString? {
        guard let bTitle = title else {
            return nil
        }
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: UIColor.white,
            .underlineColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font : ADTheme.B2
        ]
        let attrString = NSAttributedString(string: bTitle, attributes: attributes)
        return attrString
    }
    
    @objc private func buttonAction(sender : UIButton) {
        let index = sender.tag - 2000
        guard let item = self.buttonItems?.getIndex(index) else {
            return
        }
        
        //if item.action
        self.buttonClickAction?(item.action)
    }
}

public class LiveErrorView: UIView {
    
    private var maxWidth: Float
    
    public var error: String = A4xBaseManager.shared.getLocalString(key: "other_error_with_code") {
        didSet {
            //self.errorMsgLbl.text = error
            //updateStyle()
        }
    }
    
    public var type: A4xHomeVideoErrorType = .default {
        didSet {
            updateStyle()
        }
    }
    
    public var tipIcon: UIImage? {
        didSet {
            if tipIcon != nil {
                self.imageTipV.isHidden = false
                self.imageTipV.image = tipIcon
            } else {
                self.imageTipV.isHidden = true
            }
        }
    }
    
    public var buttonItems: [A4xLiveVideoBtnActionItem]? {
        didSet {
            self.errorBtn.buttonItems = buttonItems
        }
    }
    
    public var buttonClickAction: ((_ action : A4xVideoAction)->Void)? {
        didSet {
            self.errorBtn.buttonClickAction = buttonClickAction
        }
    }
    
    public func defaultButton() {
        self.buttonItems = [A4xLiveVideoBtnActionItem.default(title: A4xBaseManager.shared.getLocalString(key: "reconnect"))]
    }
    
    public func forceUpgradeButton() {
        self.buttonItems = [A4xLiveVideoBtnActionItem(style: .theme, action: .upgrade(title: A4xBaseManager.shared.getLocalString(key: "update"), style: .theme, clickState: .uptate) )]
    }
    
    public func upgradeButton() {
        self.buttonItems = [A4xLiveVideoBtnActionItem(style: .normal, action: .upgrade(title: A4xBaseManager.shared.getLocalString(key: "do_not_update"), style: A4xVideoButtonStyle.theme, clickState: .later)), A4xLiveVideoBtnActionItem(style: .theme, action: .upgrade(title: A4xBaseManager.shared.getLocalString(key: "update"), style: A4xVideoButtonStyle.theme, clickState: .uptate)), A4xLiveVideoBtnActionItem(style: .line, action: .upgrade(title: A4xBaseManager.shared.getLocalString(key: "firmware_update_skip"), style: A4xVideoButtonStyle.none, clickState: .igonre))]
    }
    
    public func sleepPlanButton() {
        self.buttonItems = [A4xLiveVideoBtnActionItem(style: .theme, action: .sleepPlan(title: A4xBaseManager.shared.getLocalString(key: "camera_wake_up"), style: .theme) )]
    }
    
    public func notRecvFirstFrameButton() {
        self.buttonItems = [A4xLiveVideoBtnActionItem(style: .theme, action: .notRecvFirstFrame(title: A4xBaseManager.shared.getLocalString(key: "live_failure_auto_try_btn"), style: A4xVideoButtonStyle.theme, clickState: .start)), A4xLiveVideoBtnActionItem(style: .line, action: .notRecvFirstFrame(title: A4xBaseManager.shared.getLocalString(key: "live_failure_auto_thanks"), style: A4xVideoButtonStyle.theme, clickState: .noThanks))]
    }
    
    private lazy var imageTipV: UIImageView = {
        let temp = UIImageView()
        self.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.errorMsgLbl.snp.top).offset(-10)
            make.centerX.equalTo(self.snp.centerX)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        return temp
    }()
    
    lazy var errorMsgLbl: UILabel = {
        let temp = UILabel()
        temp.accessibilityIdentifier = "A4xLiveSDK_errorMsgLbl"
        temp.numberOfLines = 0
        temp.backgroundColor = UIColor.clear
        temp.lineBreakMode = .byWordWrapping
        temp.font = ADTheme.B2
        temp.textColor = .white
        temp.textAlignment = .center
        temp.text = self.error
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.centerX.equalTo(self.snp.centerX)
            make.leading.equalTo(self.snp.leading).offset(15.auto())
            make.trailing.equalTo(self.snp.trailing).offset(-15.auto())
            make.height.lessThanOrEqualTo(120.auto())
        })
        
        return temp
    } ()
    
    lazy var errorBtn: LiveErrorBtnView = {
        let temp = LiveErrorBtnView()
        temp.accessibilityIdentifier = "A4xLiveSDK_errorBtn"
        self.addSubview(temp)
        temp.snp.remakeConstraints { (make) in
            make.top.equalTo(self.errorMsgLbl.snp.bottom).offset(15.auto()).priority(.high)
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom)
        }
        return temp
    }()
    
    
    public init(frame: CGRect = .zero , maxWidth : Float = 300) {
        self.maxWidth = maxWidth
        super.init(frame: .zero)
        self.errorMsgLbl.isHidden = false
        self.errorBtn.isHidden = false
        self.backgroundColor = UIColor.clear
    }
    
    private func updateStyle() {
        switch self.type {
        case .`default`:
            self.imageTipV.isHidden = false
            self.errorMsgLbl.text = error
            self.errorMsgLbl.isHidden = false
            self.errorMsgLbl.snp.updateConstraints { (make) in
                if self.errorBtn.buttonItems?.count ?? 0 > 0 {
                    make.centerY.equalTo(self.snp.centerY).offset(-10)
                } else {
                    make.centerY.equalTo(self.snp.centerY)
                }
                make.leading.equalTo(self.snp.leading).offset(15.auto())
                make.trailing.equalTo(self.snp.trailing).offset(-15.auto())
            }
            self.errorBtn.isHidden = false
        case .simple:
            self.imageTipV.isHidden = true
            self.errorMsgLbl.text = error
            self.errorMsgLbl.isHidden = false
            self.errorMsgLbl.snp.updateConstraints { (make) in
                make.centerY.equalTo(self.snp.centerY)
                make.leading.equalTo(self.snp.leading).offset(10.auto())
                make.trailing.equalTo(self.snp.trailing).offset(-10.auto())
            }
            self.errorBtn.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if self.type == .simple && buttonItems?.count == 1 {
            self.buttonClickAction?(.video(title: nil, style: nil))
        }
    }
}
