//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI


class A4xFullLiveVideoAnimailView: UIView {
    
    static func showThumbnail(tapButton : UIView , image : UIImage , tipString : String , comple :@escaping ()->Void ){
        
        func isRTL() -> Bool {
            if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
                return true
            }
            return false
        }
        
        guard let keyWindown : UIWindow = UIApplication.shared.keyWindow else {
            comple()
            return
        }
        
        let bgView = UIView(frame: keyWindown.bounds)
        keyWindown.addSubview(bgView)
        
        let imageView: UIImageView = UIImageView()
        imageView.image = image
        imageView.frame = CGRect(x: 5, y: 5, width: 140, height: 80)
        imageView.layer.cornerRadius = 6
        imageView.alpha = 0
        bgView.addSubview(imageView)
        //imageView.resetFrameToFitRTL()
        
        let lable: UILabel = UILabel()
        lable.textAlignment = .center
        lable.textColor = ADTheme.C3
        lable.alpha = 0
        lable.numberOfLines = 0
        lable.font = ADTheme.B3
        lable.text = tipString
        bgView.addSubview(lable)
        let lableSize = lable.sizeThatFits(CGSize(width: 140, height: 100))
        lable.frame = CGRect(x: 5, y: imageView.maxY + 3, width: 140, height: lableSize.height)
        //lable.resetFrameToFitRTL()
        let resultFrame = CGRect(x: A4xBaseManager.shared.isRTL() ? (tapButton.minX - 10 - imageView.width) : tapButton.maxX + 10, y: tapButton.midY - imageView.height / 2 - 10, width: imageView.width + 10, height: lable.maxY + 3)
        
        
        UIView.animate(withDuration: 0.3) {
            bgView.backgroundColor = UIColor.white
        } completion: { (f) in
            UIView.animate(withDuration: 0.3) {
                bgView.cornerRadius = 10
                bgView.frame = resultFrame
            } completion: { (f) in
                UIView.animate(withDuration: 1) {
                    lable.alpha = 1
                    imageView.alpha = 1
                } completion: { (f) in
                    UIView.animate(withDuration: 0.5) {
                        bgView.frame = CGRect(x: -bgView.width, y: bgView.minY, width: bgView.width, height: bgView.height)
                        bgView.resetFrameToFitRTL()
                    } completion: { (f) in
                        bgView.removeFromSuperview()
                        comple()
                    }

                }
            }
        }
    }
}

public class A4xFullLiveAutoRessolutionAnimailView: UIView {
    
    public var resolutionToAutoActionBlock: (() -> Void)?
    
    public var autoTipsStr: (String, String)? {
        didSet {
            let linkStr = (autoTipsStr?.0 ?? "")
            let txtStr = (autoTipsStr?.1 ?? "")
            autoTipTxtView.text(text: txtStr, links: (linkStr, "")) {
                height in
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.quitBtn.isHidden = false
        self.autoTipTxtView.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var quitBtn: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_quitBtn"
        temp.setImage(A4xLiveUIResource.UIImage(named: "live_video_full_auto_quit")?.rtlImage(), for: .normal)
        self.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(self.snp.leading).offset(16.auto())
            make.width.height.equalTo(24.auto())
        }
        temp.addTarget(self, action: #selector(quitAction), for: .touchUpInside)
        return temp
    }()
    
    //
    lazy var autoTipTxtView: A4xBaseURLTextView = {
        let txtView: A4xBaseURLTextView = A4xBaseURLTextView()
        let linkStr = A4xBaseManager.shared.getLocalString(key: "switch_to_auto_now")
        let txtStr = A4xBaseManager.shared.getLocalString(key: "switch_to_auto_reminder") + " " + linkStr
        txtView.text(text: txtStr, links: (linkStr, "")) {
            height in
        }
        txtView.textColor = .white
        txtView.linkTextColor = ADTheme.Theme
        txtView.font = UIFont.regular(14)
        txtView.setDirectionConfig()
        self.addSubview(txtView)
        txtView.snp.makeConstraints({ (make) in
            make.centerY.equalTo(quitBtn.snp.centerY)
            make.leading.equalTo(quitBtn.snp.trailing).offset(8.auto())
            make.height.equalTo(20.auto())
        })
        return txtView
    }()
    
    @objc func quitAction() {
        hiddenAni()
    }
    
    public func showAni() {
        var newTransform = CGAffineTransform.identity
        let tx = A4xBaseManager.shared.isRTL() ? -20.auto() : 20.auto()
        newTransform.tx = tx
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn], animations: {
            self.isHidden = false
            self.alpha = 0.6
            self.transform = newTransform
        }, completion: { (_) in
            self.alpha = 1
            self.autoHiddenTime()
        })
    }
    
    public func hiddenAni() {
        if A4xGCDTimer.shared.isExistTimer(withName: "AUTO_HIDDEN_TIMER") {
            A4xGCDTimer.shared.destoryTimer(withName: "AUTO_HIDDEN_TIMER")
        }
        var newTransform = CGAffineTransform.identity
        let tx = A4xBaseManager.shared.isRTL() ? 20.auto() : -20.auto()
        newTransform.tx = tx
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut], animations: {
            self.isHidden = false
            self.alpha = 0.6
            self.transform = newTransform
        }, completion: { (_) in
            self.isHidden = true
            self.alpha = 0
        })
    }
    
    private func autoHiddenTime() {
        var timeCount = 0
        let timeout = 10
        A4xGCDTimer.shared.scheduledDispatchTimer(withName: "AUTO_HIDDEN_TIMER", timeInterval: 1, queue: DispatchQueue.main, repeats: true) { [weak self] in
            timeCount += 1
            if timeCount >= timeout {
                self?.hiddenAni()
            }
        }
    }
}
