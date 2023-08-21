//


import Foundation
import SmartDeviceCoreSDK
import AVFoundation
import BaseUI


open class ScanQRViewController: BaseNavViewController {
    
    private var isScaning : Bool = false
    private var isError : Bool = false
    
    
    open var scanTitle: String? {
        return nil
    }
    
    open var scanTitleDes: String? {
        return nil
    }
    
    public override init(){
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        guard self.previewLayer != nil else {
            return
        }
        self.view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.mastBgView.isHidden = false
        self.scanImage.isHidden = true
        self.titleView.isHidden = false
        self.tipScanTip.isHidden = false
        self.scuessImage.isHidden = true
        self.loadNavtion()

        self.scanAnimailImage.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        A4xUserDataHandle.Handle?.addWifiChange(targer: self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestAccessForCamera { (flag) in
            DispatchQueue.main.a4xAfter(0) {
                if flag {
                    self.startScan()
                } else {
                    self.scanError(error: A4xBaseManager.shared.getLocalString(key: "no_camera_auth"), buttonStr: A4xBaseManager.shared.getLocalString(key: "camera_permission"))
                }
            }
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        if self.isScaning {
            self.stopScan()
        }
    }
    
    
    open func handleScanResult(result: String, frame: CGRect) {
        NSException(
            name: .internalInconsistencyException,
            reason: "You must override \(NSStringFromSelector(#function)) in a subclass",
            userInfo: nil).raise()
        abort()
    }
    
    open func handleSelectQRResult(result: String) {
        NSException(
            name: .internalInconsistencyException,
            reason: "You must override \(NSStringFromSelector(#function)) in a subclass",
            userInfo: nil).raise()
        abort()
    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        self.navView?.tintColor = UIColor.white
        
        self.navView?.title = ""
        self.navView?.leftItem?.normalImg = "qrcode_back"
        self.navView?.backgroundColor = UIColor.clear
        
        if let navView = self.navView {
            weakSelf?.view.bringSubviewToFront(navView)
        }
    }
    
    private lazy var deviceInput: AVCaptureDeviceInput? = {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        guard device != nil else {
            return nil
        }
        do {
            let temp = try AVCaptureDeviceInput.init(device: device!)
            return temp
        } catch {
            return nil
        }
    }()
    
    private lazy var dataOutput: AVCaptureMetadataOutput? = {
        let temp = AVCaptureMetadataOutput()
        temp.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        temp.rectOfInterest = self.scanRectOfInterest()
        return temp
    }()
    
    private lazy var session: AVCaptureSession? = {
        let temp = AVCaptureSession()
        if let input = self.deviceInput {
            if temp.canAddInput(input) {
                temp.addInput(input)
            }
        }
        if let out = self.dataOutput {
            if temp.canAddOutput(out) {
                temp.addOutput(out)
            }
        }
        if self.dataOutput?.availableMetadataObjectTypes.contains(.qr) ?? false {
            self.dataOutput?.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        }
        return temp
    }()
    
    private func scanRectOfInterest() -> CGRect {
        let rect = scanRect()
        let sc_width = self.view.width
        let sc_height = self.view.height
        
        return CGRect(x: rect.minY / sc_height, y: rect.minX / sc_width , width: rect.height / sc_height , height: rect.width / sc_width)
    }
    
    public func scanRect() -> CGRect {
        let sc_width = self.view.width
        let scanSize = CGSize(width: sc_width, height: sc_width * 1.1)
        return CGRect(x: (sc_width - scanSize.width) / 2.0, y: 130.auto() , width: scanSize.width, height: scanSize.height)
    }
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer? = {
        guard self.session != nil else {
            return nil
        }
        let temp = AVCaptureVideoPreviewLayer(session: self.session! )
        temp.videoGravity = AVLayerVideoGravity.resizeAspectFill
        temp.frame = UIScreen.main.bounds
        return temp
    }()
    
    private lazy var maskView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.1)
        self.view.insertSubview(view, belowSubview: self.view)
        
        view.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.view.snp.bottom).offset(-20)
            make.top.equalTo(0)
            make.width.equalTo(self.view.snp.width)
            make.leading.equalTo(0)
        })
        
        return view
    }()
    
    private lazy var scuessImage: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .center
        self.view.addSubview(temp)
        temp.image = bundleImageFromImageName("qrcode_scuess")
        temp.frame = self.scanRect()
        
        return temp
    }()
    
    
    private lazy var errorTipView: ScanErrorTipView = {
        let temp = ScanErrorTipView()
        self.view.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY).offset(15.auto())
            make.width.equalTo(self.view.snp.width)
        }
        return temp
    }()
    
    @objc func toSystemSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private lazy var scanAnimailImage: UIImageView = {
        let temp = UIImageView()
        self.view.addSubview(temp)
        let rect = self.scanRect()
        temp.image = bundleImageFromImageName("join_device_scan_animail")?.rtlImage()
        temp.frame = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.width * 0.456)
        return temp
    }()
    
    private lazy var mastBgView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 0.1)
        self.view.insertSubview(view, belowSubview: self.view)
        
        view.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.view.snp.bottom)
            make.top.equalTo(0)
            make.width.equalTo(self.view.snp.width)
            make.leading.equalTo(0)
        })
        
        return view
    }()
    
    private lazy var titleView: UILabel = {
        let lable = UILabel()
        lable.font = ADTheme.H1
        lable.textColor = UIColor.white
        lable.textAlignment = .center
        lable.numberOfLines = 0
        self.view.addSubview(lable)
        lable.text = self.scanTitle
        
        lable.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width).offset(-62.auto())
            make.top.equalTo(self.navView!.snp.bottom)
        }
        return lable
    }()
    
    private lazy var tipScanTip: UILabel = {
        let lable = UILabel()
        lable.font = ADTheme.B2
        lable.numberOfLines = 0
        lable.textColor = UIColor.white
        lable.textAlignment = .center
        self.view.addSubview(lable)
        lable.text = self.scanTitleDes
        let rect = self.scanRect()

        lable.snp.makeConstraints({ (make) in
            make.top.equalTo(self.titleView.snp.bottom).offset(8.auto())
            make.width.equalTo(self.view.snp.width).offset(-30.auto())
            make.centerX.equalTo(self.view.snp.centerX)
        })
        return lable
    }()
    
    
    private lazy var scanImage: UIImageView = {
        let temp = UIImageView()
        self.view.addSubview(temp)
        
        temp.image = bundleImageFromImageName("join_device_scan")?.rtlImage()
        temp.frame = self.scanRect()
        
        return temp
    }()
    
    public func startScan() {
        isScaning = true
        self.scuessImage.isHidden = true
        self.scanAnimailImage.isHidden = false
        
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            self.scanError(error: A4xBaseManager.shared.getLocalString(key: "phone_no_net"), buttonStr: nil)
            return
        }
        
        let rect = self.scanRect()
        let fromeValue = CGPoint(x: self.scanAnimailImage.midX, y: rect.minY + self.scanAnimailImage.height / 2)
        let toValue = CGPoint(x: self.scanAnimailImage.midX, y: rect.maxY  - self.scanAnimailImage.height / 2 +  6.auto())
        self.session?.startRunning()
        let radius2Down = CABasicAnimation(keyPath: "position")
        
        radius2Down.toValue = toValue
        radius2Down.fromValue = fromeValue
        radius2Down.repeatCount = MAXFLOAT
        radius2Down.duration = 2.5
        radius2Down.fillMode = .forwards
        radius2Down.isRemovedOnCompletion = true
        
        self.scanAnimailImage.layer.add(radius2Down, forKey: "fd")
    }
    
    private func stopScan() {
        isScaning = false
        self.session?.stopRunning()
        self.scanAnimailImage.layer.removeAllAnimations()
        self.scanAnimailImage.isHidden = true
        
    }
    
    @objc func becomeActive() {
        if self.isScaning {
            self.errorTipView.isHidden = true
            self.startScan()
        }
    }
    
    private func scanError(error: String?, buttonStr: String?) {
        if error != nil {
            self.errorTipView.setTitle(title: error!, buttom: buttonStr) { [weak self] in
                self?.toSystemSetting()
            }
            self.errorTipView.isHidden = false
            self.session?.stopRunning()
            self.scanAnimailImage.layer.removeAllAnimations()
            self.scanAnimailImage.isHidden = true
        } else {
            self.errorTipView.isHidden = true
            if isScaning {
                self.startScan()
            }
            let bpath = UIBezierPath(rect: UIScreen.main.bounds)
            bpath.append(UIBezierPath(rect: self.scanRect().insetBy(dx: 4, dy: 4)).reversing())
            let shareLayer = CAShapeLayer()
            shareLayer.path = bpath.cgPath
            self.scanAnimailImage.isHidden = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ScanQRViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
       
        guard metadataObjects.count > 0 else {
            return
        }
        
        if let firstResult = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            let result = firstResult.stringValue
            guard let scaData = result else {
                return
            }
            
            let code = self.previewLayer?.transformedMetadataObject(for: firstResult)
            guard let frame = code?.bounds else {
                return
            }
            
            self.stopScan()
            let center = CGPoint(x: frame.midX, y: frame.midY)
            let scuessSize : CGSize = CGSize(width: 40, height: 40)
            self.scuessImage.frame = CGRect(x: center.x - scuessSize.width / 2 , y: center.y - scuessSize.height / 2, width: scuessSize.width, height: scuessSize.height)
            self.scuessImage.isHidden = false
            
            self.handleScanResult(result: scaData, frame: frame)
            print("--------------> qrData result \(scaData)")
        }
    }
}

extension ScanQRViewController: A4xUserDataHandleWifiProtocol {
    public func wifiInfoUpdate(status: A4xReaStatus) {
        
        if case .nonet = status {
            self.scanError(error: A4xBaseManager.shared.getLocalString(key: "phone_no_net"), buttonStr: nil)
        }else {
            self.scanError(error: nil, buttonStr: nil)
        }
    }
}
