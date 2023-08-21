//


//


//
import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xBindScanQRCodeView: A4xBindBaseView {
    
    var backClick: (()->Void)?
    
    var zendeskChatClick: (()->Void)?

    var scrollEnable : Bool = false {
        didSet {
            self.qrCodeIntroView.scrollEnable = scrollEnable
        }
    }
    
    
    override var datas: Dictionary<String, String>? {
        didSet {
            if !(datas?["isFeedBackEnable"]?.isBlank ?? true) {
                scanQRCodeFeedBackLbl.isHidden = datas?["isFeedBackEnable"] == "1" ? false : true
                if datas?["isFeedBackEnable"] == "1" {
                    updateUI("feedback")
                }
            }
            
            if !(datas?["nextEnable"]?.isBlank ?? true) {
                nextBtn.isEnabled = datas?["nextEnable"] == "1" ? true : false
                updateUI("scanQRError")
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
    
    
    lazy var qrCodeImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = UIImage.init(color: UIColor.colorFromHex("#F5F5F5"))
        iv.size = CGSize(width: UIScreen.width - 55.auto(), height: UIScreen.width - 55.auto())
        return iv
    }()
    
    
    lazy var qrCodeLoadingImgView: UIImageView = {
        let iv = UIImageView()
        iv.image = bundleImageFromImageName("home_video_loading")?.rtlImage()
        iv.size = CGSize(width: 25.auto(), height: 25.auto() )
        return iv
    }()
    
    
    lazy var qrCodeLoadingAnimail: CABasicAnimation = {
        let baseAnil = CABasicAnimation(keyPath: "transform.rotation")
        baseAnil.fromValue = 0
        baseAnil.toValue = Double.pi * 2
        baseAnil.duration = 1.5
        baseAnil.repeatCount = MAXFLOAT
        return baseAnil
    }()
    
    
    
    private lazy var qrCodeIntroView: A4xBindScanQRTipsView = {
        var v: A4xBindScanQRTipsView = A4xBindScanQRTipsView()
        v.backgroundColor = .clear
        return v
    }()


    
    lazy var errorView : UIControl = {
        let c = UIControl()
        c.isHidden = true
        return c
    }()

    
    lazy var errorIcon: UIImageView = {
        let iv:UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("join_device_qrcode_error")?.rtlImage()
        return iv
    }()

    
    lazy var errorMsg: UILabel = {
        let lbl = UILabel()
        lbl.backgroundColor = UIColor.clear
        lbl.text = A4xBaseManager.shared.getLocalString(key: "error_message")
        lbl.font = ADTheme.B2
        lbl.textAlignment = .center
        lbl.lineBreakMode = .byWordWrapping
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C2
        return lbl
    }()
    
    
    lazy var bottomBtnView: UIView = {
        var v: UIView = UIView()
        v.backgroundColor = .clear//UIColor.colorFromHex("#000000", alpha: 0.3)
        return v
    }()
    
    
    lazy var scanQRCodeFeedBackLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "bind_device_scan_failed_2")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.backgroundColor = .clear
        lbl.numberOfLines = 0
        lbl.isHidden = true
        lbl.textColor = ADTheme.Theme
        lbl.font = ADTheme.B1
        //lbl.backgroundColor = .gray
        return lbl
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.navView.isHidden = false
    
         addSubview(qrCodeImgView)
         qrCodeImgView.addSubview(qrCodeLoadingImgView)
         addSubview(qrCodeIntroView)

         addSubview(bottomBtnView)
         nextBtn.removeFromSuperview()
         bottomBtnView.addSubview(nextBtn)
         bottomBtnView.addSubview(scanQRCodeFeedBackLbl)
  
        addSubview(errorView)
        errorView.addSubview(errorIcon)
        errorView.addSubview(errorMsg)
        //addSubview(scanQRCodeSuccessHintLbl)

        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "scan_the_qr_code")
        
        
        titleLbl.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(navView.snp.bottom).offset(0.auto())
            make.width.equalTo(self.snp.width).offset(-62.auto())
        }
        
        
        nextBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "bind_device_scan_failed"), for: .normal)
        nextBtn.setTitleColor(ADTheme.C1, for: .normal)
        nextBtn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .normal)
        let image = UIImage.init(color: ADTheme.C5)
        let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.C5, by: 0.9)
        nextBtn.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.C5), for: .highlighted)
        nextBtn.isHidden = true
        
        
        qrCodeImgView.snp.makeConstraints({ make in
            make.top.equalTo(self.titleLbl.snp.bottom).offset(15.5.auto())
            make.centerX.equalTo(self.snp.centerX).offset(0)
            make.width.height.equalTo(UIScreen.width - 55.auto())
        })
        
        
        qrCodeLoadingImgView.snp.makeConstraints { (make) in
            make.center.equalTo(qrCodeImgView.snp.center)
        }
        
        self.layoutIfNeeded()
        qrCodeIntroView.snp.makeConstraints { (make) in
            make.top.equalTo(self.qrCodeImgView.snp.bottom).offset(7.auto())
            make.width.equalTo(UIScreen.width - 55.auto())
            make.height.equalTo(UIScreen.height - UIScreen.navBarHeight - qrCodeImgView.frame.maxY)
            make.centerX.equalTo(self.snp.centerX).offset(0)
        }
        
         
        
        let attrString = NSMutableAttributedString(string: titleHintStr)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 1.5.auto()
        let attr: [NSAttributedString.Key : Any] = [.font: UIFont.regular(13) ,.foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1),.paragraphStyle:style]
        attrString.addAttributes(attr, range: NSRange(location: 0, length: attrString.length))
        

        
        let titleHintTxtViewHeight: CGFloat = titleHintTxtView.sizeThatFits(CGSize(width:313.auto(), height: CGFloat(MAXFLOAT))).height
        titleHintTxtView.snp.remakeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom).offset(8.auto())
            make.height.equalTo(titleHintTxtViewHeight)
            make.width.equalTo(self.snp.width).offset(-62.auto())
        })
        titleHintTxtView.isHidden = true

        
        errorView.snp.makeConstraints({ (make) in
            make.center.equalTo(qrCodeImgView.snp.center)
            make.width.equalTo(qrCodeImgView.snp.width)
            make.height.equalTo(qrCodeImgView.snp.height)
        })

        
        errorIcon.snp.makeConstraints({ (make) in
            make.centerX.equalTo(errorView.snp.centerX)
            make.centerY.equalTo(errorView.snp.centerY).offset(-12)
        })

        
        errorMsg.snp.makeConstraints({ (make) in
            make.top.equalTo(errorIcon.snp.bottom).offset(5)
            make.centerX.equalTo(errorIcon.snp.centerX)
            make.width.equalTo(errorView.snp.width).offset(-70)
        })
        
        
        bottomBtnView.snp.remakeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.top.equalTo(self.snp.bottom).offset(0)
            make.height.equalTo(102.auto())
        })
        
        
        nextBtn.snp.remakeConstraints({ (make) in
            make.centerX.equalTo(bottomBtnView.snp.centerX)
            make.width.equalTo(bottomBtnView.snp.width).offset(-42.auto())
            make.bottom.equalTo(bottomBtnView.snp.bottom).offset(-35.auto())
            make.height.equalTo(50.auto())
        })

        
        scanQRCodeFeedBackLbl.snp.makeConstraints({ (make) in
            make.bottom.equalTo(bottomBtnView.snp.bottom).offset(-15.auto())
            make.centerX.equalTo(bottomBtnView.snp.centerX)
            make.width.equalTo(bottomBtnView.snp.width).offset(-42.auto())
            make.height.equalTo(40.auto())
        })
    }
    
    private func updateUI(_ type: String) {
        
        switch type {
        case "feedback":
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            }) { (result) in }
            
            UIView.animate(withDuration: 0.4) {
                self.bottomBtnView.transform = CGAffineTransform.init(translationX: 0, y: -102.auto())
            }
            
            UIView.transition(with: self.qrCodeIntroView, duration: 0.8 , options: .curveEaseIn, animations: {
                
                self.nextBtn.snp.remakeConstraints({ (make) in
                    make.centerX.equalTo(self.bottomBtnView.snp.centerX)
                    make.bottom.equalTo(self.scanQRCodeFeedBackLbl.snp.top)
                    make.width.equalTo(self.bottomBtnView.snp.width).offset(-42.auto())
                    make.height.equalTo(50.auto())
                })
                
                //
                self.qrCodeIntroView.snp.updateConstraints { (make) in
                    make.top.equalTo(self.qrCodeImgView.snp.bottom).offset(7.auto())
                    make.width.equalTo(UIScreen.width - 55.auto())
                    make.height.equalTo(UIScreen.height - UIScreen.navBarHeight - self.qrCodeImgView.frame.maxY - 102.auto() - 15.5.auto() - 10)
                    make.centerX.equalTo(self.snp.centerX).offset(0)
                }
            }, completion: nil)
            break
        case "scanQRError":
            UIView.animate(withDuration: 0.4) {
                self.bottomBtnView.transform = CGAffineTransform.init(translationX: 0, y: -102.auto())
            }
            
            UIView.transition(with: self.qrCodeIntroView, duration: 0.8 , options: .curveEaseIn, animations: {
                self.qrCodeIntroView.snp.updateConstraints { (make) in
                    make.top.equalTo(self.qrCodeImgView.snp.bottom).offset(7.auto())
                    make.width.equalTo(UIScreen.width - 55.auto())
                    make.height.equalTo(UIScreen.height - UIScreen.navBarHeight - self.qrCodeImgView.frame.maxY - 102.auto()) 
                    make.centerX.equalTo(self.snp.centerX).offset(0)
                }
            }, completion: nil)
            break
        default:
            break
        }
        
    }
}
