
import UIKit
import SmartDeviceCoreSDK

public protocol A4xBaseAlertViewProtocol : class{
    
    
    var identifier : String {
        set get
    }
    
    
    var config : A4xBaseAlertConfig {
        set get
    }
    
    
    var onHiddenBlock: ((_ comple: @escaping ()->Void) -> Void)? {
        set get
    }
}

extension A4xBaseAlertViewProtocol {
    
    public func show(isNext : Bool = false , updateBlock: (((A4xBaseAlertViewProtocol & UIView)? )->Void)? = nil) {
        guard let v = self as? UIView & A4xBaseAlertViewProtocol  else {
            return
        }
        A4xBaseAlertViewController.appendAlert(view: v, isNext: isNext, updateBlock: updateBlock)
    }
    
    public func hidden(comple : @escaping ()->Void){
        self.onHiddenBlock? {
            comple()
        }
    }
}

class A4xAlertBgView : UIView {
    var boundsChange : (()->Void)?
    
    override var bounds: CGRect {
        didSet {
            self.boundsChange?()
        }
    }
}

extension UIViewController {
    public func showAlert(view: (A4xBaseAlertViewProtocol & UIView), isClearAll: Bool) {
        weak var weakSelf = self
        
        if self.view == nil {
            return
        }
        
        if isClearAll {
            A4xBaseAlertViewController.alertC?.clear()
        }
        
        self.animailHiddenPosition(view: view)
        view.tag = 20000
        view.onHiddenBlock = { block in
            weakSelf?.hidden(comple: block)
        }
        
        let bgView = A4xAlertBgView()
        bgView.tag = 20001
        bgView.boundsChange = { [weak self] in
            self?.animailShowPosition(view: view)
        }
        bgView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        bgView.frame = self.view.bounds
        self.view.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.size.equalTo(self.view.snp.size)
            make.center.equalTo(self.view.snp.center)
        }
        
        self.view.addSubview(view)
        
        UIView.animate(withDuration: TimeInterval(view.config.duration), delay: 0, usingSpringWithDamping: CGFloat(view.config.damping), initialSpringVelocity: CGFloat(view.config.initialSpringVelocity), options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.animailShowPosition(view: view)  
        }, completion: {  _ in
        })
    }
    
    
    private func hiddenAlertView(view : (UIView & A4xBaseAlertViewProtocol)? , comple : @escaping ()->Void) {
        let completion = { (complete: Bool) -> Void in
            view?.onHiddenBlock = nil
            view?.removeFromSuperview()
            comple()
        }
        guard view != nil else {
            completion(true)
            return
        }
        
        UIView.animate(withDuration: TimeInterval(view!.config.duration), delay: 0, usingSpringWithDamping: CGFloat(view!.config.damping), initialSpringVelocity: CGFloat(view!.config.initialSpringVelocity), options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            
            self.animailHiddenPosition(view: view!)
        }, completion: completion)

    }
    
    
    private func hidden(comple :@escaping ()->Void){
        if let tagView : (A4xBaseAlertViewProtocol & UIView) = self.view.viewWithTag(20000) as? A4xBaseAlertViewProtocol & UIView {
            self.view.viewWithTag(20001)?.removeFromSuperview()
            self.hiddenAlertView(view: tagView, comple: comple)
        }
    }
    
    
    private func animailShowPosition(view : UIView & A4xBaseAlertViewProtocol ) {
        switch view.config.type {
        case let .alert(type):
            
            if case .scale = type {
                view.transform = CGAffineTransform.identity
                view.alpha = 1
                view.center = self.view.center
            }else {
                view.frame = CGRect(x: (self.view.width - view.width) / 2, y: (self.view.height - view.height) / 2, width: view.width, height: view.height)
            }
        case .sheet:
            
            view.frame = CGRect(x: (self.view.width - view.width) / 2, y: self.view.height - view.height, width: view.width, height: view.height)
        }
    }
    
    
    private func animailHiddenPosition(view : UIView & A4xBaseAlertViewProtocol ) {
        let size = view.bounds.size
        if self.view == nil {
            return
        }
        switch view.config.type {
        case let .alert(type):
            
            switch type {
            case .top:
                view.frame = CGRect(x: (self.view.width - size.width) / 2, y: -size.height, width: size.width, height: size.height)
            case .bottom:
                view.frame = CGRect(x: (self.view.width - size.width) / 2, y: self.view.height, width: size.width, height: size.height)
            case .scale:
                
                view.frame = CGRect(x: (self.view.width - size.width) / 2, y: (self.view.height - size.height) / 2, width: size.width, height: size.height)
                view.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
                view.alpha = 0.0
            }
        case .sheet:
            
            view.frame = CGRect(x: (self.view.width - view.width) / 2, y: self.view.height, width: view.width, height: view.height)
        }
    }
}



public class A4xBaseAlertViewController : UIViewController {
    
    
    public static var alertC : A4xBaseAlertViewController?
    
    
    private var alertViewData : [A4xBaseAlertViewProtocol & UIView] = []

    
    public static func alert() -> A4xBaseAlertViewController? {
        return alertC
    }
    
    deinit {
        
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didInterfaceOrientationsChange(interfaceOrientation:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func didInterfaceOrientationsChange(interfaceOrientation: UIInterfaceOrientation) {
        
        
        if UserDefaults.standard.object(forKey: "lastInterfaceOrientation") != nil {
            if A4xAppSettingManager.shared.interfaceOrientations.rawValue == UserDefaults.standard.integer(forKey: "lastInterfaceOrientation") { return }
        }
        
        let device = UIDevice.current
        
        if device.orientation == .faceUp || device.orientation == .faceDown || device.orientation == .unknown ||
        device.orientation == .portraitUpsideDown { return }
        var currentBounds:CGRect = CGRect.init(x: 0, y: 0, width: 375, height: 568)
        //横屏时
        if device.orientation == .landscapeLeft || device.orientation == .landscapeRight{
            currentBounds = CGRect.init(x: 0, y: 0, width: max(UIApplication.shared.keyWindow?.height ?? 568, UIApplication.shared.keyWindow?.width ?? 375), height: min(UIApplication.shared.keyWindow?.height ?? 568, UIApplication.shared.keyWindow?.width ?? 375))
        }
        
        //竖屏时
        if device.orientation == .portrait {
            currentBounds = CGRect.init(x: 0, y: 0, width: min(UIApplication.shared.keyWindow?.height ?? 568, UIApplication.shared.keyWindow?.width ?? 375), height: max(UIApplication.shared.keyWindow?.height ?? 568, UIApplication.shared.keyWindow?.width ?? 375))
        }
        
        
        DispatchQueue.main.async {
            
            //self.alertBounds = currentBounds
            //self.backgroundView.frame = self.alertBounds
            //self.alertWindow?.frame = self.alertBounds
            //let alertView = self.alertViewData.last
            //guard let alert = alertView else {
                //self.hidden{}
                //return
            //}
            
            UserDefaults.standard.setValue(A4xAppSettingManager.shared.interfaceOrientations.rawValue, forKey: "lastInterfaceOrientation")
            //self.showAlertView(view: alert) {}
        }
    }

    
    private func viewNotReady() -> Bool {
        return UIApplication.shared.keyWindow == nil
    }
    
    public override func loadView() {
        super.loadView()
        self.view = nil
    }
    
    
    
    private lazy var previousWindow: UIWindow? = {
        return UIApplication.shared.keyWindow
    }()
    
    
    fileprivate lazy var tapOutsideRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(outHiddenAction(sender:)))
    }()
    
    
    
    private lazy var alertBounds : CGRect = {
        let bounds = UIApplication.shared.keyWindow?.bounds ?? CGRect(x: 0, y: 0, width: 375, height: 568)
        return bounds
    }()
    
    
    private lazy var alertWindow: UIWindow? = {
        if viewNotReady() {
            return nil
        }
        let window = UIWindow(frame: (UIApplication.shared.keyWindow?.bounds)!)
        window.windowLevel = UIWindow.Level(6)
        window.backgroundColor = UIColor.clear
        window.rootViewController = self
        
        return window
    }()
    
    
    private lazy var backgroundView : UIView = {
        let temp = UIView(frame: self.alertBounds)
        temp.backgroundColor = UIColor.black
        temp.isUserInteractionEnabled = true
        temp.alpha = CGFloat(0)
        self.alertWindow?.insertSubview(temp, at: 0)
        temp.addGestureRecognizer(self.tapOutsideRecognizer)
        return temp
    }()
    
    public var isVisable: Bool = true {
        didSet {
            guard let curAlertWindow = self.alertWindow else {
                
                return
            }
            curAlertWindow.isHidden = !isVisable
        }
    }
    
    
    private func appendAlert(view : A4xBaseAlertViewProtocol & UIView , isNext : Bool = false , updateBlock: (((A4xBaseAlertViewProtocol & UIView)? )->Void)?) {
        let count = self.alertViewData.count
        for i in 0..<count{
            let temp = self.alertViewData[i]
            if temp.identifier == view.identifier {
                if i == count - 1 {
                    if let tagView : (A4xBaseAlertViewProtocol & UIView) = self.alertWindow?.viewWithTag(20000) as? A4xBaseAlertViewProtocol & UIView {
                        updateBlock?(tagView)
                    }
                }else {
                    self.alertViewData[i] = view
                }
                return
            }
        }
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)

        var insertIndex  = 0
        if isNext {
            insertIndex = 0
        }else {
            insertIndex = max(self.alertViewData.count - 2, 0)
        }
        self.alertViewData.insert(view, at: insertIndex)
        if self.alertViewData.count == 1 {
            self.visableNext()
        }
    }
    
    
    
    private func hidden(comple :@escaping ()->Void){
        let alertView = self.alertViewData.last
        if self.alertViewData.count > 0 {
            self.alertViewData.remove(at: self.alertViewData.count - 1)
        }
        let isLast = self.alertViewData.count == 0
        weak var weakSelf = self
        self.hiddenAlertView(view: alertView, isLast: isLast) {
            if !isLast {
                weakSelf?.visableNext()
            }else {
                weakSelf?.clear()
            }
            comple()
        }
    }
    
    public func clear() {
        guard let curAlertWindow = self.alertWindow else {
            
            A4xBaseAlertViewController.alertC = nil
            return
        }
        curAlertWindow.rootViewController = nil
        A4xBaseAlertViewController.alertC = nil
    }
    
    
    private func visableNext(){
        let alertView = self.alertViewData.last
        guard let alert = alertView else {
            self.hidden{}
            return
        }
        self.showAlertView(view: alert) {}
    }
    
    
    
    public static func appendAlert (view : A4xBaseAlertViewProtocol & UIView , isNext : Bool = false , updateBlock: (((A4xBaseAlertViewProtocol & UIView)? )->Void)?)  {
        if alertC == nil {
            alertC = A4xBaseAlertViewController()
        }
        self.alertC?.appendAlert(view: view, isNext: isNext, updateBlock: updateBlock)
    }
    
   
}



extension A4xBaseAlertViewController {
    
    
    private func showAlertView(view : UIView & A4xBaseAlertViewProtocol , comple : @escaping ()->Void) {
        weak var weakSelf = self
        if viewNotReady() {
            DispatchQueue.main.a4xAfter(0.1) {
                weakSelf?.showAlertView(view: view, comple: comple)
            }
            return
        }
        self.previousWindow?.isHidden = false
        
        self.animailHiddenPosition(view: view)
        view.tag = 20000
        view.onHiddenBlock = { block in
            weakSelf?.hidden(comple: block)
        }
        //self.alertWindow?.addSubview(view)
        if self.view == nil {
            self.view = UIView(frame: (UIApplication.shared.keyWindow?.bounds)!)
        }
        self.view.insertSubview(view, aboveSubview: self.alertWindow!)
        self.alertWindow?.makeKeyAndVisible()
        
        UIView.animate(withDuration: TimeInterval(view.config.duration), delay: 0, usingSpringWithDamping: CGFloat(view.config.damping), initialSpringVelocity: CGFloat(view.config.initialSpringVelocity), options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.animailShowPosition(view: view)
            self.backgroundView.alpha = CGFloat(view.config.backgroundAlpha)
            
        }, completion: {  _ in
        })
    }
    
    
    private func hiddenAlertView(view : (UIView & A4xBaseAlertViewProtocol)? , isLast : Bool = true , comple : @escaping ()->Void) {
        let completion = { (complete: Bool) -> Void in
            view?.onHiddenBlock = nil
            view?.removeFromSuperview()
            if isLast {
                self.alertWindow?.isHidden = true
                self.previousWindow?.makeKeyAndVisible()
            }
            comple()
        }
        guard view != nil else {
            completion(true)
            return
        }
        
        UIView.animate(withDuration: TimeInterval(view!.config.duration), delay: 0, usingSpringWithDamping: CGFloat(view!.config.damping), initialSpringVelocity: CGFloat(view!.config.initialSpringVelocity), options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            
            self.animailHiddenPosition(view: view!)
        }, completion: completion)

    }
    
    
    private func animailShowPosition(view : UIView & A4xBaseAlertViewProtocol ) {
        switch view.config.type {
        case let .alert(type):
            
            if case .scale = type {
                view.transform = CGAffineTransform.identity
                view.alpha = 1

            }else {
                view.frame = CGRect(x: (self.alertBounds.width - view.width) / 2, y: (self.alertBounds.height - view.height) / 2, width: view.width, height: view.height)
            }
        case .sheet:
            
            view.frame = CGRect(x: (self.alertBounds.width - view.width) / 2, y: self.alertBounds.height - view.height, width: view.width, height: view.height)
        }
    }
    
    
    private func animailHiddenPosition(view : UIView & A4xBaseAlertViewProtocol ) {
        switch view.config.type {
        case let .alert(type):
            
            switch type {
            case .top:
                view.frame = CGRect(x: (self.alertBounds.width - view.width) / 2, y: -view.height, width: view.width, height: view.height)
            case .bottom:
                view.frame = CGRect(x: (self.alertBounds.width - view.width) / 2, y: self.alertBounds.height, width: view.width, height: view.height)
            case .scale:
                view.frame = CGRect(x: (self.alertBounds.width - view.width) / 2, y: (self.alertBounds.height - view.height) / 2, width: view.width, height: view.height)
                view.transform = CGAffineTransform.init(scaleX: 0.01, y: 0.01)
                view.alpha = 0.0
            }
        case .sheet:
            
            view.frame = CGRect(x: (self.alertBounds.width - view.width) / 2, y: self.alertBounds.height, width: view.width, height: view.height)
        }
    }
 
    
    @objc
    func outHiddenAction(sender : UITapGestureRecognizer){
        let alertView = self.alertViewData.last
        if let ish = alertView?.config.outBoundsHidden , ish {
            self.hidden {}
        }
    }
}


extension UIViewController {
    public func showAlert(title : String? = nil , message : String? = nil , cancelTitle : String? = nil , doneTitle : String? = nil, image : UIImage? = nil, doneAction : (() -> Void)? = nil, cancleAction : (() -> Void)? = nil) {
        
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.Theme
        config.rightTextColor = UIColor.white
        config.messageImg = image
        let alert = A4xBaseAlertView(param: config, identifier: "title \(title ?? "")")
        alert.title = title
        alert.message = message
        alert.leftButtonTitle = cancelTitle
        alert.rightButtonTitle = doneTitle
        alert.rightButtonBlock = {
            doneAction?()
        }
        alert.leftButtonBlock = {
            cancleAction?()
        }
        alert.show()
    }
    
    public func showDeviceAlert(title: String? = nil, message: String? = nil, cancelTitle: String? = nil, doneTitle : String? = nil, image: UIImage? = nil, doneAction: (() -> Void)? = nil, cancleAction: (() -> Void)? = nil) {
        
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = UIColor.white
        config.rightbtnBgColor = UIColor.white
        config.leftTitleColor = ADTheme.C1
        config.rightTextColor = ADTheme.E1
        config.messageImg = image
        let alert = A4xBaseAlertView(param: config, identifier: "title \(title ?? "")")
        alert.title = title
        alert.message = message
        alert.leftButtonTitle = cancelTitle
        alert.rightButtonTitle = doneTitle
        alert.rightButtonBlock = {
            doneAction?()
        }
        alert.leftButtonBlock = {
            cancleAction?()
        }
        alert.show()
    }
}
