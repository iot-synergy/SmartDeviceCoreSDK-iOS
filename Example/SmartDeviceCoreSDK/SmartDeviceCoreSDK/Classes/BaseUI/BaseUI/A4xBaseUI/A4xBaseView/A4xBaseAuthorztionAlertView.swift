//


//


//

import Foundation
import YogaKit
import UIKit
import SmartDeviceCoreSDK

public class A4xBaseAuthorztionAlertView: UIView, A4xBaseAlertViewProtocol {
    public var identifier: String = "A4xBaseAuthorztionAlertView"
    public var config: A4xBaseAlertConfig
    public var onHiddenBlock: ((@escaping () -> Void) -> Void)?
    public var onResultAction : ((Bool , A4xBaseAuthorizationType)->Void)?
    public var authorType : A4xBaseAuthorizationType
    var alterWidth: Float = 0.0
    
    public init(frame: CGRect = CGRect.zero ,
                config : A4xBaseAlertConfig = A4xBaseAlertConfig(),
                type : A4xBaseAuthorizationType) {
        self.identifier = "authorztion_alert_view"
        self.config = config
        self.authorType = type
        super.init(frame: frame)
        
        self.layer.cornerRadius = 5
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.yoga.isEnabled = true
   
        self.yoga.alignItems = .center
        self.yoga.flexDirection = .column
        self.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        
        
        //let size = UIApplication.shared.keyWindow?.frame.size ?? CGSize.zero
        self.yoga.width = YGValue(floatLiteral: Float(min(UIScreen.width , UIScreen.height) * (self.isLandscape() ? 0.90 : 0.75)))
        alterWidth = Float(min(UIScreen.width , UIScreen.height) * (self.isLandscape() ? 0.90 : 0.75))

        self.titleView.text = type.authInfo().title
        self.desLabel.text = type.authInfo().descLable
        
        if type.authInfo().image != nil {
            self.imageView.image = type.authInfo().image
        } else {
            self.desLabel.yoga.marginTop = YGValue(floatLiteral: 12.auto())
            self.openButton.yoga.marginTop = YGValue(floatLiteral: 34.auto())
        }
        
        if let (tipImage ,tipName) = type.authInfo().tipImage {
            self.tipImage.image = tipImage
            self.tipLabel.text = tipName
            
            //self.tipLabel.yoga.marginLeft = YGValue(floatLiteral: (type.authInfo().tip1Left ?? false) ? 16.5.auto() : (self.isLandscape() ? 41.5.auto() : 55.auto()))
            
            self.tipLabel.snp.remakeConstraints { make in
                make.centerY.equalTo(self.tipImage.snp.centerY)
                make.leading.equalTo(self.tipImage.snp.leading).offset((type.authInfo().tip1Left ?? false) ? 16.5.auto() : (self.isLandscape() ? 41.5.auto() : 55.auto()))
                make.width.equalTo(128.5.auto())
            }
            
            if !(type.authInfo().tipImageRightStr?.isBlank ?? true) {
                self.tipLabel.text = type.authInfo().tipImageRightStr ?? ""
                let tiplblHeight = self.tipLabel.getLabelHeight(self.tipLabel, width: 128.5.auto())
                let height = max(tiplblHeight + 34.auto(), 56.auto())
                self.tipleftImg.image = bundleImageFromImageName("authorization_location_icon")
                self.tipImage.snp.remakeConstraints { make in
                    make.centerX.equalTo(self.imageView.snp.centerX)
                    make.top.equalTo(self.imageView.snp.top).offset(16.auto())
                    make.height.equalTo(height)
                }
                self.tipImage.layoutIfNeeded()
                self.tipImage.image = tipImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0), resizingMode: UIImage.ResizingMode.stretch)
            }
        }
        
        if let (tip2Image, tip2Name) = type.authInfo().tip2Image {
            self.tip2Image.image = tip2Image
            self.tip2Label.text = tip2Name
            self.tip2Label.yoga.marginLeft = YGValue(floatLiteral: (type.authInfo().tip2Left ?? false) ? 16.5.auto() : 55.auto())
            self.tip2Label.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        }
        
        if !(type.authInfo().okBtnTitle?.isBlank ?? true) {
            self.openButton.setTitle(type.authInfo().okBtnTitle, for: .normal)
        }
        
        if !(type.authInfo().cancelBtnTitle?.isBlank ?? true) {
            self.cancleButton.setTitle(type.authInfo().cancelBtnTitle, for: .normal)
            self.cancleButton.setTitleColor(ADTheme.Theme, for: .normal)
        }
        
        self.openButton.isHidden = false
        self.cancleButton.isHidden = false
        if type.authInfo().cancelBtnHiden ?? false {
            self.cancleButton.removeFromSuperview()
            self.yoga.padding = 20
            self.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: YGDimensionFlexibility.flexibleHeight)
            return
        }
        self.yoga.padding = 10
        self.yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: YGDimensionFlexibility.flexibleHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleView : UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.H2
        temp.textColor = ADTheme.C1
        temp.textAlignment = .center
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        temp.yoga.isEnabled = true
        temp.yoga.alignSelf = .center
        temp.yoga.width = YGValue(value: 90, unit: YGUnit.percent)
        temp.yoga.marginTop = YGValue(floatLiteral: 10.auto())
        temp.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        self.addSubview(temp)

        return temp
    }()
    
    private lazy var desLabel : UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        temp.font = self.isLandscape() ? ADTheme.B2 : ADTheme.B1
        temp.textColor = ADTheme.C3
        self.addSubview(temp)
        
        temp.yoga.isEnabled = true
        temp.yoga.width = YGValue(value: self.isLandscape() ? 100 : 80, unit: YGUnit.percent)
        temp.yoga.alignSelf = .center
        temp.yoga.marginTop = YGValue(floatLiteral: 8.auto())
        temp.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        return temp
    }()
    
    private lazy var imageView : UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        self.addSubview(temp)
        
        temp.yoga.isEnabled = true
        temp.yoga.flexDirection = .column
        temp.yoga.alignSelf = .center
        temp.yoga.width = YGValue(floatLiteral: self.isLandscape() ? 162.4.auto() : 203.auto())
        temp.yoga.height = YGValue(floatLiteral: self.isLandscape() ? 130.auto() : 162.5.auto())
        temp.yoga.marginTop = YGValue(floatLiteral: 16.auto())
        temp.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        return temp
    }()
    
    private lazy var tipImage : UIImageView = {
        let temp = UIImageView()
        //temp.contentMode = .scaleAspectFit
        self.imageView.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.centerX.equalTo(self.imageView.snp.centerX)
            make.top.equalTo(self.imageView.snp.top).offset(16.auto())
            //make.height.equalTo(56.auto())
        }
        temp.layoutIfNeeded()
        
        temp.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        return temp
    }()
    
    private lazy var tipLabel : UILabel = {
        let temp = UILabel()
        temp.font = UIFont.regular(14)
        temp.textColor = ADTheme.C1
        temp.numberOfLines = 0
        self.tipImage.addSubview(temp)
        temp.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        //temp.yoga.isEnabled = true
        //temp.yoga.marginLeft = YGValue(floatLiteral: self.isLandscape() ? 41.5.auto() : 41.auto())
        temp.snp.makeConstraints { make in
            make.centerY.equalTo(self.tipImage.snp.centerY)
            make.leading.equalTo(self.tipImage.snp.leading).offset(self.isLandscape() ? 41.5.auto() : 41.auto())
            make.width.equalTo(128.5.auto())
        }
        return temp
    }()
    
    private lazy var tipRightLabel : UILabel = {
        let temp = UILabel()
        temp.font = UIFont.regular(14)
        temp.textColor = ADTheme.C1
        self.tipImage.addSubview(temp)
        temp.yoga.isEnabled = true
        temp.textAlignment = .right
        temp.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        temp.snp.makeConstraints { make in
            make.centerY.equalTo(self.tipImage.snp.centerY)
            make.trailing.equalTo(self.tipImage.snp.trailing).offset(31.auto())
        }
        return temp
    }()
    
    private lazy var tipleftImg : UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        self.tipImage.addSubview(temp)
        temp.yoga.isEnabled = true
        temp.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        temp.snp.makeConstraints { make in
            make.centerY.equalTo(self.tipImage.snp.centerY)
            make.leading.equalTo(self.tipImage.snp.leading).offset(16.auto())
            make.width.height.equalTo(22.auto())
        }
        return temp
    }()
    
    private lazy var tip2Image : UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        self.imageView.addSubview(temp)
        temp.yoga.isEnabled = true
        temp.yoga.flexDirection = .row
        temp.yoga.alignSelf = .center
        temp.yoga.width = YGValue(value: 80, unit: YGUnit.percent)
        temp.yoga.aspectRatio = 3.8
        temp.yoga.marginTop = YGValue(floatLiteral: 1.auto())
        temp.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        return temp
    }()
    
    private lazy var tip2Label : UILabel = {
        let temp = UILabel()
        temp.font = UIFont.regular(14)
        temp.textColor = ADTheme.C4
        self.tip2Image.addSubview(temp)
        temp.yoga.isEnabled = true
        temp.yoga.marginLeft = YGValue(floatLiteral: 55.auto())
        temp.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        return temp
    }()
    
    
    private lazy var openButton : UIButton = {
        var temp = UIButton()
        temp.accessibilityIdentifier = "openButton"
        temp.titleLabel?.font = ADTheme.B1
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "go_open"), for: UIControl.State.normal)
        temp.setTitleColor(ADTheme.C4, for: UIControl.State.disabled)
        temp.setTitleColor(UIColor.white, for: UIControl.State.normal)
        temp.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
        temp.setBackgroundImage(UIImage.buttonPressImage , for: .highlighted)
        temp.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .disabled)
        temp.layer.cornerRadius = 20.auto()
        temp.clipsToBounds = true
        temp.addTarget(self, action: #selector(openButtonAction), for: .touchUpInside)
        self.addSubview(temp)
        temp.yoga.isEnabled = true
        temp.yoga.alignSelf = .center
        temp.yoga.height = YGValue(floatLiteral: 40.auto())
        temp.yoga.width = YGValue(value: 90, unit: YGUnit.percent)
        temp.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        return temp
    }()
    
    private lazy var cancleButton : UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "cancle_button"
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "not_open_now"), for: .normal)
        temp.setTitleColor(ADTheme.C3, for: .normal)
        temp.titleLabel?.font = ADTheme.B1
        temp.isAccessibilityElement = false
        temp.addTarget(self, action: #selector(closeAlertAction), for: .touchUpInside)
        self.addSubview(temp)
        
        temp.yoga.isEnabled = true
        temp.yoga.alignSelf = .center
        temp.yoga.height = YGValue(floatLiteral: 40.auto())
        temp.yoga.marginTop = YGValue(floatLiteral: 5.auto())
        temp.yoga.width = YGValue(value: 90, unit: YGUnit.percent)
        temp.yoga.direction = A4xBaseManager.shared.isRTL() ? .RTL : .LTR
        return temp
        
    }()
    
    @objc private func openButtonAction(){
        self.onHiddenBlock? { [weak self] in
            if let type = self?.authorType {
                self?.onResultAction?(true , type)
            }
        }
        
    }
    
    @objc private func closeAlertAction(){
        self.onHiddenBlock? { [weak self] in
            if let type = self?.authorType {
                self?.onResultAction?(false , type)
            }
        }
        
    }
    
    
    private func isLandscape() -> Bool {
        if A4xAppSettingManager.shared.interfaceOrientations == .landscape {
            return true
        } else {
            return false
        }
    }
    
    private func isRTL() -> Bool {
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            return true
        }
        return false
    }
}
