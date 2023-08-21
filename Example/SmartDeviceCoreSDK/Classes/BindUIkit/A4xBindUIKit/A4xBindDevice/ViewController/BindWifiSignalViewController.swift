import UIKit
import Lottie
import SmartDeviceCoreSDK
import BaseUI

class BindWifiSignalViewController: A4xBaseViewController {
    var deviceModel: DeviceBean?
    
    var deviceId: String?
    var needUpdate: Bool? = false
    var newFirmwareId: String?
    
    var bindCode: String?
    var bindFrom: String?
    var bindMode: String?
    
    var serialNumber: String?
    var isChangeWifi: Bool?
    var isHomeNav: Bool = true
    
    var isFromNewBind: Bool = false
    var updateWifiStrengthTimer : Timer?
    
    let wifiSearchAniName = "getting_wifi"
    var isAnailing: Bool = true
    var wifiState: A4xWiFiStyle {
        set {
            if A4xUserDataHandle.Handle?.netConnectType == .nonet {
                _wifiState = .none
                return
            }
            _wifiState = newValue
        }
        
        get {
            return _wifiState
        }
    }
    
    var _wifiState: A4xWiFiStyle = .none {
        didSet {
            if !self.isAnailing {
                self.updateWifiSignal()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.scrollView.isHidden = false
        self.titleLbl.isHidden = false
        self.wifiSignalImgView.isHidden = false
        self.wifiSignalAniView.isHidden = false
        self.wifiTitleLbl.isHidden = false
        self.wifiDescLbl.isHidden = false
        self.doneButton.isHidden = false
        
        updateWifiStrengthTimer = Timer(timeInterval: 5, target: self, selector: #selector(updateDeviceWifiStrength), userInfo: nil, repeats: true)
        RunLoop.current.add(updateWifiStrengthTimer!, forMode: .common)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getSelectSingleDevice()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateWifiStrengthTimer?.invalidate()
        updateWifiStrengthTimer = nil
    }
    
    // 计时器函数 - 每5秒拿一次
    @objc func updateDeviceWifiStrength() {
        guard let dataId = self.deviceId else {
            return
        }
        DeviceManageUtil.getDeviceSettingInfo(deviceId: dataId) {  [weak self]  (code, msg, model) in
            if code == 0 {
                self?.wifiState = model?.wifiStrength() ?? .none
            } else {
                self?.wifiState = A4xUserDataHandle.Handle?.getDevice(deviceId: dataId)?.wifiStrength() ?? .none
            }
        }
    }
    
    private func getSelectSingleDevice(showLoading: Bool = true) {
        if showLoading {
            self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (r) in }
        }
        
        weak var weakSelf = self
        DeviceManageUtil.getDeviceSettingInfo(deviceId: deviceId ?? "") { (code, msg, model) in
            weakSelf?.view.hideToastActivity()
            if code == 0 {
                self.deviceModel = model
                self.wifiState = model?.wifiStrength() ?? .none
                DispatchQueue.main.a4xAfter(2) { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.isAnailing = false
                    self.updateWifiSignal()
                }
            } else {
                weakSelf?.view.makeToast(A4xAppErrorConfig(code: code).message())
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    lazy var scrollView: UIScrollView = {
        let temp = UIScrollView()
        temp.showsVerticalScrollIndicator = false
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width)
            make.top.equalTo(self.navView!.snp.bottom)
            make.bottom.equalTo(self.doneButton.snp.top)
        })
        return temp
    }()
    
    lazy var titleLbl: UILabel = {
        var temp: UILabel = UILabel()
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        temp.text = A4xBaseManager.shared.getLocalString(key: "check_wifi_0", param: [tempString])
        temp.textColor = ADTheme.C1
        temp.numberOfLines = 0
        temp.textAlignment = .center
        self.scrollView.addSubview(temp)
        temp.font = UIFont.medium(20)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.scrollView.snp.top).offset(0)
            make.centerX.equalTo(self.scrollView.snp.centerX)
            make.width.equalTo(self.scrollView.snp.width).offset(-48.auto())
        })
        return temp
    }()
    
    lazy var wifiSignalImgView: UIImageView = {
        let temp = UIImageView()
        temp.alpha = 0
        self.scrollView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.scrollView.snp.centerY).offset(-20.auto())
            make.centerX.equalTo(self.scrollView.snp.centerX)
            make.width.equalTo(115.auto())
            make.height.equalTo(122.auto())
        })
        
        return temp
    }()
    
    
    lazy var wifiSignalAniView: LottieAnimationView = {
        var temp: LottieAnimationView?
        
        temp = LottieAnimationView(name: wifiSearchAniName, bundle: a4xBaseBundle())
        let keypath = AnimationKeypath(keypath: "**.**.**.**.**.描边 1.Color")
        temp?.setValueProvider(A4xBindConfig.getLottieColorValueProvider(), keypath: keypath)
        temp?.loopMode = .autoReverse
        self.scrollView.addSubview(temp ?? LottieAnimationView(name: wifiSearchAniName))
        temp?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.scrollView.snp.centerY).offset(-20.auto())
            make.centerX.equalTo(self.scrollView.snp.centerX)
            make.width.equalTo(115.auto())
            make.height.equalTo(122.auto())
        })
        temp?.play()
        return temp!
    }()
    
    
    lazy var wifiTitleLbl: UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.H3
        temp.textColor = ADTheme.C1
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        temp.textAlignment = .center
        temp.attributedText = self.loadWifiSignalNoneText()
        self.scrollView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.wifiSignalImgView.snp.bottom).offset(26.auto())
            make.centerX.equalTo(self.scrollView.snp.centerX)
            make.width.equalTo(self.scrollView.snp.width).offset(-32.auto())
        })
        
        return temp
    }()
    
    lazy var wifiDescLbl: UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.B1
        temp.textColor = ADTheme.C3
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        temp.textAlignment = .center
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        temp.text = A4xBaseManager.shared.getLocalString(key: "check_wifi_3", param: [tempString])
        self.scrollView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.wifiTitleLbl.snp.bottom).offset(6.auto())
            make.centerX.equalTo(self.scrollView.snp.centerX)
            make.width.equalTo(self.scrollView.snp.width).offset(-32.auto())
        })
        
        return temp
    }()
    
    
    // 更新Wi-Fi强度
    private func updateWifiSignal() {
        self.wifiSignalAniView.stop()
        self.wifiSignalAniView.isHidden = true
        self.wifiSignalImgView.alpha = 1
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        var image : UIImage? = UIImage()
        switch(self.wifiState) {
        case .offline:
            fallthrough
        case .none:
            image = bundleImageFromImageName("ad_install_wifi_none")?.rtlImage()
            self.wifiDescLbl.text = A4xBaseManager.shared.getLocalString(key: "check_wifi_no", param: [tempString])
        case .weak:
            image = bundleImageFromImageName("ad_install_wifi_weak")?.rtlImage()
            self.wifiDescLbl.text = A4xBaseManager.shared.getLocalString(key: "check_wifi_4", param: [tempString])
        case .normail:
            image = self.processByPixel(in: bundleImageFromImageName("ad_install_wifi_normail")?.rtlImage() ?? UIImage())
            self.wifiDescLbl.text = A4xBaseManager.shared.getLocalString(key: "check_wifi_3", param: [tempString])
        case .strong:
            image = self.processByPixel(in: bundleImageFromImageName("ad_install_wifi_strong")?.rtlImage() ?? UIImage())
            self.wifiDescLbl.text = A4xBaseManager.shared.getLocalString(key: "check_wifi_3", param: [tempString])
        }
        self.wifiSignalImgView.image = image
        
        wifiTitleLbl.attributedText = self.loadWifiSignalText()
        let tsize = wifiTitleLbl.sizeThatFits(CGSize(width: wifiTitleLbl.width, height: 200))
        wifiTitleLbl.height = tsize.height
        
        let size = wifiDescLbl.sizeThatFits(CGSize(width: wifiDescLbl.width, height: 200))
        wifiDescLbl.height = size.height
        self.loadViewIfNeeded()
    }
    
    // 播放完getting_wifi.json后,把图片修改成主题色
    func processByPixel(in image: UIImage) -> UIImage? {
        
        guard let inputCGImage = image.cgImage else {
            print("unable to get cgImage")
            return nil
        }
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = inputCGImage.width
        let height           = inputCGImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = A4xRGBA32.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            print("Cannot create context!")
            return nil
        }
        context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            print("Cannot get context data!")
            return nil
        }
        
        let pixelBuffer = buffer.bindMemory(to: A4xRGBA32.self, capacity: width * height)
        
        for row in 0 ..< Int(height) {
            for column in 0 ..< Int(width) {
                let offset = row * width + column
                
                if pixelBuffer[offset].redComponent >= 80 && pixelBuffer[offset].redComponent <= 110 && pixelBuffer[offset].greenComponent >= 180 && pixelBuffer[offset].greenComponent <= 220 &&
                    pixelBuffer[offset].blueComponent >= 160 && pixelBuffer[offset].blueComponent != 190 &&
                    pixelBuffer[offset].alphaComponent >= 150 {
                    pixelBuffer[offset] = .theme
                }
                
            }
        }
        
        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        
        return outputImage
    }
    
    
    
    func loadWifiSignalNoneText() -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: A4xBaseManager.shared.getLocalString(key: "check_wifi_1") + "                       ")
        attrString.addAttribute(.font, value: ADTheme.H3, range: NSRange(location: 0, length: attrString.string.count))
        attrString.addAttribute(.foregroundColor, value: ADTheme.C1, range: NSRange(location: 0, length: attrString.string.count))
        let param = NSMutableParagraphStyle()
        param.lineBreakMode = .byWordWrapping
        param.alignment = .center
        attrString.addAttribute(.paragraphStyle, value: param, range: NSRange(location: 0, length: attrString.string.count))
        
        return attrString
    }
    
    
    func loadWifiSignalText() -> NSAttributedString {
        let wifiSignalValue = self.wifiState.singleValue
        
        let attrString = NSMutableAttributedString(string: A4xBaseManager.shared.getLocalString(key: "check_wifi_2") + " " + wifiSignalValue)
        attrString.addAttribute(.font, value: ADTheme.H3, range: NSRange(location: 0, length: attrString.string.count))
        attrString.addAttribute(.foregroundColor, value: ADTheme.C1, range: NSRange(location: 0, length: attrString.string.count))
        
        if let range = attrString.string.ranges(of: wifiSignalValue, options: [String.CompareOptions.backwards]).first {
            
            if range.length > 0 {
                switch self.wifiState {
                case .offline:
                    attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: ADTheme.E1, range: range)
                case .none:
                    attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: ADTheme.E1, range: range)
                case .weak:
                    attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.colorFromHex("#de350b"), range: range)
                case .normail:
                    attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: ADTheme.Theme, range: range)
                case .strong:
                    attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: ADTheme.Theme, range: range)
                }
            }
        }
        
        let param = NSMutableParagraphStyle()
        param.lineBreakMode = .byWordWrapping
        param.alignment = .center
        attrString.addAttribute(.paragraphStyle, value: param, range: NSRange(location: 0, length: attrString.string.count))
        
        return attrString
    }
    
    func loadWifiDesc(str: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: str)
        attrString.addAttribute(.font, value: ADTheme.B1, range: NSRange(location: 0, length: attrString.string.count))
        attrString.addAttribute(.foregroundColor, value: ADTheme.C3, range: NSRange(location: 0, length: attrString.string.count))
        
        let param = NSMutableParagraphStyle()
        param.lineSpacing = 4
        param.firstLineHeadIndent = 20.0//首行缩进
        param.lineBreakMode = .byWordWrapping
        param.alignment = .center
        attrString.addAttribute(.paragraphStyle, value: param, range: NSRange(location: 0, length: attrString.string.count))
        return attrString
    }
    
    
    lazy var doneButton: UIButton = {
        let temp = UIButton()
        temp.titleLabel?.font = ADTheme.B1
        temp.setTitleColor(ADTheme.C1, for: UIControl.State.disabled)
        temp.setTitleColor(UIColor.white, for: UIControl.State.normal)
        temp.layer.borderColor = ADTheme.Theme.cgColor
        temp.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
        temp.setBackgroundImage(UIImage.buttonPressImage , for: .highlighted)
        temp.setBackgroundImage(UIImage.init(color: UIColor.white), for: .disabled)
        
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "next"), for: .normal)
        temp.layer.borderWidth = 1
        temp.layer.cornerRadius = 25.auto()
        temp.clipsToBounds = true
        temp.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width).offset(-70.auto())
            make.height.equalTo(50.auto())
            if #available(iOS 11.0,*) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-16.auto())
            } else {
                make.bottom.equalTo(self.view.snp.bottom).offset(-20.auto())
            }
        })
        return temp
    }()
    
    @objc func doneAction() {
        
        self.navigationController?.popToRootViewController(animated: false)
    }
}

