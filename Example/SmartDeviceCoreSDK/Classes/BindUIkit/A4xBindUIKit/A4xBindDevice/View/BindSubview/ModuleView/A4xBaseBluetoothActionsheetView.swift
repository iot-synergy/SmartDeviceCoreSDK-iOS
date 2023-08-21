//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public class A4xBaseBluetoothActionsheetView: UIView {
    public func addNewSubview(_ view: UIView) {}
    public func updateSubUI(_ view: UIView) {}
    
    public var closeBlock : (()->Void)?
    
    public var contenView: UIView? {
        didSet {
            setUpContent()
        }
    }
    
    public var isShow: Bool? {
        return self.contenView != nil
    }
    
    public var contenHeight: CGFloat? {
        didSet {
            self.updateUI()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var quitBtn: UIButton?
    
    public func setUpContent() {
        if self.contenView != nil {
            self.addSubview(self.contenView!)
            self.contenView?.layoutIfNeeded()
            self.contenView?.clipsToBounds = true
            self.contenView?.filletedCorner(CGSize(width: 22.5.auto(), height: 22.5.auto()), UIRectCorner(rawValue: (UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
            
            quitBtn = UIButton()
            quitBtn?.setBackgroundImage(bundleImageFromImageName("bind_device_bluetooth_close"), for: .normal)
            self.contenView?.addSubview(quitBtn ?? UIButton())
            quitBtn?.addTarget(self, action: #selector(quitBtnClick), for: .touchUpInside)
            quitBtn?.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
                make.top.equalTo(UIScreen.barNewHeight + 2)
                make.trailing.equalTo(-16.auto())
            }
            
            self.addNewSubview(self.contenView ?? self)
        }
        self.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.4)
        self.isUserInteractionEnabled = true
        
    }
    
    @objc func quitBtnClick() {
        hiddenView()
    }
    
    
    @objc func dismissView() {
        hiddenView()
    }
    
    public func hiddenView() {
        self.closeBlock?()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: CGFloat(0.8), initialSpringVelocity: CGFloat(0.5), options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.alpha = 0
            self.contenView?.y -= (self.contenView?.height ?? 0) / 2
        }, completion: { _ in
            self.removeFromSuperview()
            self.contenView?.removeFromSuperview()
        })
    }
    
    
    public func showInView(superView: UIView) {
        guard (contenView != nil) else {
            return
        }
        
        superView.addSubview(self)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: CGFloat(0.8), initialSpringVelocity: CGFloat(0.5), options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.alpha = 1.0
            self.contenView?.y = 0
        }, completion: {  _ in
            
        })
    }
    
    
    public func showInWindow() {
        UIApplication.shared.keyWindow?.addSubview(self)
        self.contenView?.y -= (self.contenView?.height ?? 0) / 2
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: CGFloat(0.8), initialSpringVelocity: CGFloat(0.5), options: .curveEaseOut, animations: { () -> Void in
            self.alpha = 1.0
            self.contenView?.y += (self.contenView?.height ?? 0) / 2
        }, completion: {  _ in
            
        })
    }
    
    
    public func updateUI() {
        self.contenView? = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.width, height: self.contenHeight ?? 254.auto()))
        self.contenView?.backgroundColor = .white
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: CGFloat(0.8), initialSpringVelocity: CGFloat(0.5), options: .curveEaseOut, animations: { () -> Void in
            self.alpha = 1.0
            self.contenView?.y = 0
        }, completion: {  _ in
            self.updateSubUI(self.contenView!)
        })
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !(touches.first?.view!.isKind(of: NSClassFromString("UITableViewCellContentView")!))! {
            dismissView()
        }
    }
}
