import UIKit
import Lottie
import Network
import SmartDeviceCoreSDK
import BindInterface
import BaseUI

class BindConnectWaitViewController: BindBaseViewController {
    
    var needSendBindText: String?
    var operationId: String?
    var fromManuallyAP: Bool = false
    
    private var apInfoDetailModel: A4xBindAPDeviceInfoModel? // 连接ap和发送tcp消息用
    
    private var isLocalNetLimit: Bool = false
    
    private var startTime: TimeInterval = 0
    
    var serialNumber: String?
    var launchWay: String?
    // event end
    
    // APP是否活跃
    private var isAppActive: Bool = false
    
    var currentStep: Int = 1 {
        didSet {
            print("\(self.currentStep)")
        }
    }
    
    //wifi(logo)放大、背景等待、wifi(logo)缩小、绑定成功
    private var logoToBigAniView: LottieAnimationView?
    private var connectWaittingBGAniView: LottieAnimationView?
    private var logoToSmailAniView: LottieAnimationView?
    private var connectSuccessAniView: LottieAnimationView?
    
    
    private var animailStep1ConnectView: LottieAnimationView?
    private var animailStep2ConnectView: LottieAnimationView?
    private var animailStep3ConnectView: LottieAnimationView?
    private var animailStep4ConnectView: LottieAnimationView?
    
    
    private var animailStep1SuccessView: LottieAnimationView?
    private var animailStep2SuccessView: LottieAnimationView?
    private var animailStep3SuccessView: LottieAnimationView?
    private var animailStep4SuccessView: LottieAnimationView?
    
    
    private var animailStep2FailedView: LottieAnimationView?
    private var animailStep3FailedView: LottieAnimationView?
    private var animailStep4FailedView: LottieAnimationView?
    
    
    private var waitStep2View: UIImageView?
    private var waitStep3View: UIImageView?
    private var waitStep4View: UIImageView?
    
    // 分步提示文案
    private var linkDeviceStep1Lbl: UILabel?
    private var searchDeviceStep2Lbl: UILabel?
    private var registerCloudStep3Lbl: UILabel?
    private var initDeviceStep4Lbl: UILabel?
    
    // 计算最大字宽
    private var maxLblWith: CGFloat?
    // 连接成功动画
    let aniSuccessName = "device_connect_success"
    // 连接失败动画
    let aniFailedName = "device_connect_failed"
    // 连接中动画
    let aniConnectingName = "device_connecting"
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        defaultNav()
        self.navView?.lineView?.isHidden = true
        
        self.titleLable.isHidden = false
        self.titleHintLabel.isHidden = !(checkIsAPType() && !fromManuallyAP)
        
        self.loadingView.isHidden = false
        
        self.setupUI()
        
        startTime = Date().timeIntervalSince1970 * 1000
                
        // 开始连接ap
        if checkIsAPType() && !fromManuallyAP {
            self.waitAPLinkUI(alpha: 0)
            let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
            self.titleLable.text = A4xBaseManager.shared.getLocalString(key: "bind_ap_help_title", param: [tempString])
            
            let jsonData = (self.selectedBindDeviceModel?.apInfo ?? "").data(using: String.Encoding.utf8, allowLossyConversion: false) ?? Data()
            // json to model
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            apInfoDetailModel = try? decoder.decode(A4xBindAPDeviceInfoModel.self, from: jsonData)
            self.titleHintLabel.attributedText = self.attrString(str: "\(A4xBaseManager.shared.getLocalString(key: "bind_ap_help_content", param: [ADTheme.APPName, tempString])) \n \(apInfoDetailModel?.ssid ?? " ")", subStr: apInfoDetailModel?.ssid ?? " ")
            if selectedBindDeviceModel?.isWired() ?? false || selectedBindDeviceModel?.isNetConnected() ?? false {
                let multicastInfoModel = selectedBindDeviceModel?.getMulticastInfoModel()
                if multicastInfoModel?.ip?.isBlank ?? true {
                    BindCore.getInstance().startBindByAp(ssid: self.wifiName, ssidPassword: self.wifiPwd, bindDeviceModel: self.selectedBindDeviceModel)
                }
            } else {
                BindCore.getInstance().startBindByAp(ssid: self.wifiName, ssidPassword: self.wifiPwd, bindDeviceModel: self.selectedBindDeviceModel)
            }
            self.loadNextLoadingAnimail()
            self.connectingUI()
        } else {
            // 默认步骤1完成,步骤2等待
            if self.currentStep > 1 {
                self.loadNextLoadingAnimail()
                self.connectingUI()
                if currentStep == 4 {
                    DispatchQueue.main.a4xAfter(3) {
                        self.bindSuccess(serialNumber: self.serialNumber)
                    }
                } else {
                    bindCheckStepAnimil(step: self.currentStep, animName: "", serialNumber: nil, isFailed: false)
                }
            } else {
                bindCheckStepAnimil(step: 2, animName: "", serialNumber: nil, isFailed: false)
            }
        }
        
        // 开始动画
        self.startLoadingAnimail()
        
        // 注册切换到前台监听
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        // 注册切换后台监听
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // 注册Wi-Fi监听
        A4xUserDataHandle.Handle?.addWifiChange(targer: self)
    }
    
    private func setupUI() {
        
        //  logo 放大动画
        logoToBigAniView = LottieAnimationView(name: "device_wait_logo_big_animail", bundle: a4xBaseBundle())
        
        logoToBigAniView!.tag = 1000
        let bigKeypath = AnimationKeypath(keypath: "**.**.**.Color");
        let bigValueProvider = A4xBindConfig.getLottieColorValueProvider()
        logoToBigAniView?.setValueProvider(bigValueProvider, keypath: bigKeypath);
        self.loadingView.addSubview(logoToBigAniView!)
        
        logoToBigAniView!.snp.makeConstraints { (make) in
            make.center.equalTo(self.loadingView.snp.center)
            make.width.equalTo(self.loadingView.snp.width).multipliedBy(0.4)
            make.height.equalTo(self.loadingView.snp.height).multipliedBy(0.4)
        }
        
        logoToBigAniView!.layoutIfNeeded()
        logoToBigAniView!.backgroundColor = UIColor.clear
        logoToBigAniView!.contentMode = .scaleAspectFit
        
        
        connectWaittingBGAniView = LottieAnimationView(name: "device_wait_loading_animail", bundle: a4xBaseBundle())
        let connectWaittingBGAniViewKeypath = AnimationKeypath(keypath: "**.**.**.**.**.填充 1.Color");
        connectWaittingBGAniView?.setValueProvider(A4xBindConfig.getLottieColorValueProvider(), keypath: connectWaittingBGAniViewKeypath);
        self.loadingView.insertSubview(connectWaittingBGAniView!, belowSubview: logoToBigAniView!)
        connectWaittingBGAniView!.snp.makeConstraints { (make) in
            make.center.equalTo(self.loadingView.snp.center)
            make.width.equalTo(self.loadingView.snp.width)
            make.height.equalTo(self.loadingView.snp.height)
        }
        
        connectWaittingBGAniView!.layoutIfNeeded()
        connectWaittingBGAniView!.contentMode = .scaleAspectFit
        
        // wifi(logo) 缩小动画
        logoToSmailAniView = LottieAnimationView(name: "device_wait_logo_smail_animail", bundle: a4xBaseBundle())
        let smallKeypath = AnimationKeypath(keypath: "**.**.**.Color");
        let smallValueProvider = A4xBindConfig.getLottieColorValueProvider()
        logoToSmailAniView?.setValueProvider(smallValueProvider, keypath: smallKeypath);
        self.loadingView.addSubview(logoToSmailAniView!)
        logoToSmailAniView!.snp.makeConstraints { (make) in
            make.center.equalTo(self.loadingView.snp.center)
            make.width.equalTo(self.loadingView.snp.width).multipliedBy(0.4)
            make.height.equalTo(self.loadingView.snp.height).multipliedBy(0.4)
        }
        logoToSmailAniView?.isHidden = true
        logoToSmailAniView!.layoutIfNeeded()
        logoToSmailAniView!.backgroundColor = UIColor.clear
        logoToSmailAniView!.contentMode = .scaleAspectFit
        
        // 连接成功大对勾动画
        
        connectSuccessAniView = LottieAnimationView(name: "device_wait_scuess_animail", bundle: a4xBaseBundle())
        let connectSuccessAniViewKeypath = AnimationKeypath(keypath: "形状图层 2.**.描边 1.Color");
        let connectSuccessAniViewKeypath2 = AnimationKeypath(keypath: "形状图层 1.**.描边 1.Color");
        let connectSuccessAniViewProvider = A4xBindConfig.getLottieColorValueProvider()
        connectSuccessAniView?.setValueProvider(connectSuccessAniViewProvider, keypath: connectSuccessAniViewKeypath);
        connectSuccessAniView?.setValueProvider(connectSuccessAniViewProvider, keypath: connectSuccessAniViewKeypath2);
        self.loadingView.addSubview(connectSuccessAniView!)
        connectSuccessAniView!.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.leading.equalTo(0)
            make.width.equalTo(self.loadingView.snp.width)
            make.height.equalTo(self.loadingView.snp.height)
        }
        connectSuccessAniView!.layoutIfNeeded()
        connectSuccessAniView!.contentMode = .scaleAspectFit
        connectSuccessAniView!.loopMode = .playOnce
        
        /// --------------------------------------------------- step start
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        // 分步宽度
        let step1Size = NSString(string: A4xBaseManager.shared.getLocalString(key: "connect_to_wifi")).size(withAttributes: [NSAttributedString.Key.font : UIFont.regular(16)])
        let step2Size = NSString(string: A4xBaseManager.shared.getLocalString(key: "connect_find_device")).size(withAttributes: [NSAttributedString.Key.font : UIFont.regular(16)])
        let step3Size = NSString(string: A4xBaseManager.shared.getLocalString(key: "connect_register")).size(withAttributes: [NSAttributedString.Key.font : UIFont.regular(16)])
        let step4Size = NSString(string: A4xBaseManager.shared.getLocalString(key: "connect_initialize", param: [tempString])).size(withAttributes: [NSAttributedString.Key.font : UIFont.regular(16)])
        // 计算最大字宽 - 适配屏幕居中位置
        let maxStepLblWith = max(step1Size.width, step2Size.width, step3Size.width, step4Size.width)
        // 适配宽度
        maxLblWith = maxStepLblWith < (UIScreen.width * 0.8) ? maxStepLblWith : UIScreen.width * 0.8
        
        /// --------------------------------------------------- step 1 start
        // 连接设备到Wi-Fi - 文案1  - 底部UI参考系
        linkDeviceStep1Lbl = UILabel()
        linkDeviceStep1Lbl!.text = A4xBaseManager.shared.getLocalString(key: "connect_to_wifi")
        linkDeviceStep1Lbl!.textColor = ADTheme.C3
        linkDeviceStep1Lbl?.numberOfLines = 0
        linkDeviceStep1Lbl!.textAlignment = .left
        self.loadingView.addSubview(linkDeviceStep1Lbl!)
        linkDeviceStep1Lbl!.font = UIFont.regular(16)
        linkDeviceStep1Lbl!.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.loadingView.snp.centerY).offset(154.auto())
            make.width.equalTo((self.maxLblWith ?? UIScreen.width * 0.8) + 5)
            make.centerX.equalTo(self.loadingView.snp.centerX).offset(18.auto())
        })
        
        // 连接动画属性
        let connectingKeypath = AnimationKeypath(keypath: "椭圆形.**.描边 1.Color");
        // 连接成功动画属性
        let connSuccessKeypath = AnimationKeypath(keypath: "椭圆形.**.填充 1.Color");
        // 动画颜色
        let connectProvider = A4xBindConfig.getLottieColorValueProvider()
        
        // 连接中动画1
    
        animailStep1ConnectView = LottieAnimationView(name: aniConnectingName, bundle: a4xBaseBundle())
        animailStep1ConnectView?.setValueProvider(connectProvider, keypath: connectingKeypath)
        self.loadingView.addSubview(animailStep1ConnectView!)
        animailStep1ConnectView!.snp.makeConstraints { (make) in
            make.trailing.equalTo(linkDeviceStep1Lbl!.snp.leading).offset(-8.auto())
            make.centerY.equalTo(linkDeviceStep1Lbl!.snp.centerY).offset((0))
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        animailStep1ConnectView!.layoutIfNeeded()
        animailStep1ConnectView!.backgroundColor = UIColor.clear
        animailStep1ConnectView!.contentMode = .scaleAspectFit
        
        // 连接成功动画1
        animailStep1SuccessView = LottieAnimationView(name: aniSuccessName, bundle: a4xBaseBundle())
        
        animailStep1SuccessView?.setValueProvider(connectProvider, keypath: connSuccessKeypath);
        self.loadingView.addSubview(animailStep1SuccessView!)
        animailStep1SuccessView!.snp.makeConstraints { (make) in
            make.trailing.equalTo(linkDeviceStep1Lbl!.snp.leading).offset(-8.auto())
            make.centerY.equalTo(linkDeviceStep1Lbl!.snp.centerY).offset((0))
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        animailStep1SuccessView!.layoutIfNeeded()
        animailStep1SuccessView!.backgroundColor = UIColor.clear
        animailStep1SuccessView!.contentMode = .scaleAspectFit
        
        /// --------------------------------------------------- step 2 start
        // 等待图标2
        waitStep2View = UIImageView()
        waitStep2View?.image = bundleImageFromImageName("wait_connect")?.rtlImage()
        self.loadingView.addSubview(waitStep2View!)
        waitStep2View!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep1SuccessView!.snp.centerX)
            make.bottom.equalTo(linkDeviceStep1Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        
        // 连接中动画2
        animailStep2ConnectView = LottieAnimationView(name: aniConnectingName, bundle: a4xBaseBundle())
        // 设置颜色
        animailStep2ConnectView?.setValueProvider(connectProvider, keypath: connectingKeypath)
        self.loadingView.addSubview(animailStep2ConnectView!)
        animailStep2ConnectView!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep1SuccessView!.snp.centerX)
            make.bottom.equalTo(linkDeviceStep1Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        animailStep2ConnectView!.layoutIfNeeded()
        animailStep2ConnectView!.backgroundColor = UIColor.clear
        animailStep2ConnectView!.contentMode = .scaleAspectFit
        
        // 连接成功动画2
    
        animailStep2SuccessView = LottieAnimationView(name: aniSuccessName, bundle: a4xBaseBundle())
        animailStep2SuccessView?.setValueProvider(connectProvider, keypath: connSuccessKeypath);
        self.loadingView.addSubview(animailStep2SuccessView!)
        animailStep2SuccessView!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep1SuccessView!.snp.centerX)
            make.bottom.equalTo(linkDeviceStep1Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        animailStep2SuccessView!.layoutIfNeeded()
        animailStep2SuccessView!.backgroundColor = UIColor.clear
        animailStep2SuccessView!.contentMode = .scaleAspectFit
        
        // 连接失败动画2
        
        animailStep2FailedView = LottieAnimationView(name: aniFailedName, bundle: a4xBaseBundle())
        animailStep2FailedView!.isHidden = true
        self.loadingView.addSubview(animailStep2FailedView!)
        animailStep2FailedView!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep1SuccessView!.snp.centerX)
            make.bottom.equalTo(linkDeviceStep1Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        animailStep2FailedView!.layoutIfNeeded()
        animailStep2FailedView!.backgroundColor = UIColor.clear
        animailStep2FailedView!.contentMode = .scaleAspectFit
        
        
        // 搜索到设备 - 文案2
        searchDeviceStep2Lbl = UILabel()
        searchDeviceStep2Lbl!.text = A4xBaseManager.shared.getLocalString(key: "connect_find_device")
        searchDeviceStep2Lbl!.textColor = ADTheme.C3
        searchDeviceStep2Lbl!.numberOfLines = 0
        searchDeviceStep2Lbl!.textAlignment = .left
        searchDeviceStep2Lbl!.font = UIFont.regular(16)
        self.loadingView.addSubview(searchDeviceStep2Lbl!)
        searchDeviceStep2Lbl!.snp.makeConstraints({ (make) in
            make.centerY.equalTo(animailStep2SuccessView!.snp.centerY).offset(0)
            make.leading.equalTo(animailStep2SuccessView!.snp.trailing).offset(8.auto())
            make.trailing.equalTo(self.view.snp.trailing).offset(-31)
        })
        
      
        /// --------------------------------------------------- step 3 start
        // waitStep3View
        waitStep3View = UIImageView()
        waitStep3View?.image = bundleImageFromImageName("wait_connect")?.rtlImage()
        self.loadingView.addSubview(waitStep3View!)
        waitStep3View!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep2SuccessView!.snp.centerX)
            make.bottom.equalTo(searchDeviceStep2Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        
        // 连接中动画3
        animailStep3ConnectView = LottieAnimationView(name: aniConnectingName, bundle: a4xBaseBundle())
        animailStep3ConnectView?.setValueProvider(connectProvider, keypath: connectingKeypath)
        self.loadingView.addSubview(animailStep3ConnectView!)
        animailStep3ConnectView!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep2SuccessView!.snp.centerX)
            make.bottom.equalTo(searchDeviceStep2Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        
        animailStep3ConnectView!.layoutIfNeeded()
        animailStep3ConnectView!.backgroundColor = UIColor.clear
        animailStep3ConnectView!.contentMode = .scaleAspectFit
        
        //  连接成功动画3
        animailStep3SuccessView = LottieAnimationView(name: aniSuccessName, bundle: a4xBaseBundle())
        animailStep3SuccessView!.tag = 2002
        animailStep3SuccessView?.setValueProvider(connectProvider, keypath: connSuccessKeypath);
        self.loadingView.addSubview(animailStep3SuccessView!)
        animailStep3SuccessView!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep2SuccessView!.snp.centerX)
            make.bottom.equalTo(searchDeviceStep2Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        
        animailStep3SuccessView!.layoutIfNeeded()
        animailStep3SuccessView!.backgroundColor = UIColor.clear
        animailStep3SuccessView!.contentMode = .scaleAspectFit
        
        // 连接失败动画3
        animailStep3FailedView = LottieAnimationView(name: aniFailedName, bundle: a4xBaseBundle())
        animailStep3FailedView!.isHidden = true
        self.loadingView.addSubview(animailStep3FailedView!)
        animailStep3FailedView!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep2SuccessView!.snp.centerX)
            make.bottom.equalTo(searchDeviceStep2Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        animailStep3FailedView!.layoutIfNeeded()
        animailStep3FailedView!.backgroundColor = UIColor.clear
        animailStep3FailedView!.contentMode = .scaleAspectFit
        
        // 注册到云服务 - 文案3
        registerCloudStep3Lbl = UILabel()
        registerCloudStep3Lbl!.text = A4xBaseManager.shared.getLocalString(key: "connect_register")
        registerCloudStep3Lbl!.textColor = ADTheme.C3
        registerCloudStep3Lbl!.numberOfLines = 0
        registerCloudStep3Lbl!.textAlignment = .left
        registerCloudStep3Lbl!.font = UIFont.regular(16)
        self.loadingView.addSubview(registerCloudStep3Lbl!)
        registerCloudStep3Lbl!.snp.makeConstraints({ (make) in
            make.centerY.equalTo(animailStep3SuccessView!.snp.centerY).offset(0)
            make.leading.equalTo(animailStep3SuccessView!.snp.trailing).offset(8.auto())
            make.trailing.equalTo(self.view.snp.trailing).offset(-31)
        })
        
        /// --------------------------------------------------- step 4 start
        // waitStep4View
        waitStep4View = UIImageView()
        waitStep4View?.image = bundleImageFromImageName("wait_connect")?.rtlImage()
        self.loadingView.addSubview(waitStep4View!)
        waitStep4View!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep3SuccessView!.snp.centerX)
            make.bottom.equalTo(registerCloudStep3Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        
        // 连接中动画4
        animailStep4ConnectView = LottieAnimationView(name: aniConnectingName, bundle: a4xBaseBundle())
        animailStep4ConnectView?.setValueProvider(connectProvider, keypath: connectingKeypath)
        self.loadingView.addSubview(animailStep4ConnectView!)
        animailStep4ConnectView!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep3SuccessView!.snp.centerX)
            make.bottom.equalTo(registerCloudStep3Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        animailStep4ConnectView!.layoutIfNeeded()
        animailStep4ConnectView!.backgroundColor = UIColor.clear
        animailStep4ConnectView!.contentMode = .scaleAspectFit
        
        // 连接成功动画4
        animailStep4SuccessView = LottieAnimationView(name: aniSuccessName, bundle: a4xBaseBundle())
        animailStep4SuccessView?.setValueProvider(connectProvider, keypath: connSuccessKeypath);
        self.loadingView.addSubview(animailStep4SuccessView!)
        animailStep4SuccessView!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep3SuccessView!.snp.centerX)
            make.bottom.equalTo(registerCloudStep3Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        animailStep4SuccessView!.layoutIfNeeded()
        animailStep4SuccessView!.backgroundColor = UIColor.clear
        animailStep4SuccessView!.contentMode = .scaleAspectFit
        
        // 连接失败动画4
        animailStep4FailedView = LottieAnimationView(name: aniFailedName, bundle: a4xBaseBundle())
        animailStep4FailedView!.isHidden = true
        self.loadingView.addSubview(animailStep4FailedView!)
        animailStep4FailedView!.snp.makeConstraints { (make) in
            make.centerX.equalTo(animailStep3SuccessView!.snp.centerX)
            make.bottom.equalTo(registerCloudStep3Lbl!.snp.bottom).offset(31.auto())
            make.size.equalTo(CGSize(width: 18.auto(), height: 18.auto()))
        }
        animailStep4FailedView!.layoutIfNeeded()
        animailStep4FailedView!.backgroundColor = UIColor.clear
        animailStep4FailedView!.contentMode = .scaleAspectFit
        
        // 初始化设备 - 文案4
        initDeviceStep4Lbl = UILabel()
        initDeviceStep4Lbl!.text = A4xBaseManager.shared.getLocalString(key: "connect_initialize", param: [tempString])
        initDeviceStep4Lbl!.textColor = ADTheme.C3
        initDeviceStep4Lbl!.numberOfLines = 0
        initDeviceStep4Lbl!.textAlignment = .left
        initDeviceStep4Lbl!.font = UIFont.regular(16)
        self.loadingView.addSubview(initDeviceStep4Lbl!)
        initDeviceStep4Lbl!.snp.makeConstraints({ (make) in
            make.centerY.equalTo(animailStep4SuccessView!.snp.centerY).offset(0)
            make.leading.equalTo(animailStep4SuccessView!.snp.trailing).offset(8.auto())
            make.trailing.equalTo(self.view.snp.trailing).offset(-31)
        })
        
        /// --------------------------------------------------- step final
        
    }
    
    //
    override func defaultNav() {
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_write"
        self.navView?.leftItem = leftItem
        self.navView?.leftBtn?.isHidden = false
        self.navView?.backgroundColor = UIColor.clear
        weak var weakSelf = self
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
    }
    
    //
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除监听
        A4xUserDataHandle.Handle?.removeWifiChangeProtocol(target: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    // 系统wifi设置切换到当前app
    @objc func didBecomeActive() {
        
        A4xLog("---------> didBecomeActive")
        // 无网络处理
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            // 判断是否ap模式下
            if self.checkIsAPType() {
                return
            }
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "error_no_net"))
            return
        }
        
        self.currentStep = 2
        self.resetAnimail()
        isAppActive = true
        
    }
    
    // 系统切换到后台
    @objc func applicationEnterBackground() {
        isAppActive = false
    }
    
    // titleLabel
    lazy var titleLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "connecting")
        temp.textColor = ADTheme.C1
        temp.textAlignment = .center
        self.view.addSubview(temp)
        temp.font = ADTheme.H1
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom).offset(10.auto())
            make.centerX.equalTo(self.view.snp.centerX)
        })
        return temp
    }()
    
    // titleHintLabel
    lazy var titleHintLabel: UILabel = {
        var temp: UILabel = UILabel()
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        temp.text = A4xBaseManager.shared.getLocalString(key: "bind_ap_help_content", param: [ADTheme.APPName, tempString])
        temp.textColor = ADTheme.C1
        temp.numberOfLines = 0
        temp.textAlignment = .center
        self.view.addSubview(temp)
        temp.font = UIFont.regular(13)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.titleLable.snp.bottom).offset(8.auto())
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width).offset(-16.auto())
        })
        return temp
    }()
    
    
    // loadingView
    lazy var loadingView: UIView = {
        let temp = UIView()
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY).offset(-30.auto())
            make.width.equalTo(self.view.snp.width).multipliedBy(0.8)
            make.height.equalTo(temp.snp.width).multipliedBy(0.8)
        })
        return temp
    }()
    
    // ap绑定提示
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
    
    private func bindSuccess(serialNumber: String?) {
        self.viewModel?.saveBindWifiToCache(wifiName: self.wifiName ?? "", wifiPwd: self.wifiPwd ?? "" )
        self.currentStep = 4
        self.serialNumber = serialNumber
        self.bindCheckStepAnimil(step: 4, animName: "", serialNumber: serialNumber, isFailed: false)
    }
}

extension BindConnectWaitViewController: A4xUserDataHandleWifiProtocol {
    func wifiInfoUpdate(status: A4xReaStatus) {
        switch status {
        case .nonet:
            break
        case .unknown:
            break
        case .wifi:
            break
        case .wwan:
            break
        }
    }
}

//
extension BindConnectWaitViewController {
    
    private func checkIsAPType() -> Bool {
        if selectedBindDeviceModel != nil {
            // 兼容03以下协议
            if selectedBindDeviceModel?.supportApSetWifi != nil {
                if selectedBindDeviceModel?.supportApSetWifi == 1 {
                    return selectedBindDeviceModel?.multicastInfo == nil
                } else {
                    return false
                }
            } else { // 为空
                if selectedBindDeviceModel?.defaultSupportApSetWifi == 1 {
                    return selectedBindDeviceModel?.multicastInfo == nil
                } else {
                    return false
                }
            }
        }
        return false
    }
    
    // 添加设备成功
    private func currentBindDeviceSuccess(serialNumber: String?) {
        
        self.titleLable.text = A4xBaseManager.shared.getLocalString(key: "connect_success")
        guard let deviceId = serialNumber else {
            return
        }
        
        // 设备连接成功
        startFinishAnimail {
            DispatchQueue.main.a4xAfter(2) {
                self.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    // 绑定设备失败处理
    func currentBindDeviceError(errorCode: Int) {
        // 无网络处理
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            // 判断是否ap模式下
            if !self.checkIsAPType() {
                self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "error_no_net"))
                return
            }
        }
        
        if self.bindMode?.contains("wired") ?? false {
            
            let vc = BindReSetGuideViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        // 跳转到错误页面
//        let vc = BindDeviceErrorViewController()
//        vc.launchWay = self.launchWay
//        vc.isAutoEnter = true
//        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    // 开始加载等待动画
    private func startLoadingAnimail() {
        A4xLog("---------> startLoadingAnimail")
        logoToBigAniView?.isHidden = false
        logoToBigAniView!.play { (result) in }
        loadNextLoadingAnimail()
    }
    
    // 加载下一个动画 - 循环调用
    @objc private func loadNextLoadingAnimail() {
        A4xLog("---------> loadNextLoadingAnimail")
        connectWaittingBGAniView?.isHidden = false
        connectWaittingBGAniView!.loopMode = .loop
        connectWaittingBGAniView!.play()
    }
    
    // 分步动画 - 代码过度冗余需优化
    private func bindCheckStepAnimil(step: Int, animName: String, serialNumber: String?, isFailed: Bool) {
        // dirty code - start 需优化
        if isFailed {
            if step == 2 {
                animailStep2ConnectView!.loopMode = .playOnce
                animailStep2ConnectView!.isHidden = true
                animailStep2FailedView!.isHidden = false
                animailStep2FailedView!.play { (result) in
                    
                }
            }
            if step == 3 {
                animailStep3ConnectView!.loopMode = .playOnce
                animailStep3ConnectView!.isHidden = true
                animailStep3FailedView!.isHidden = false
                animailStep3FailedView!.play { (result) in
                    
                }
            }
            if step == 4 {
                animailStep4FailedView!.isHidden = false
                animailStep4FailedView!.play { (result) in
                    
                }
            }
        }
      
        if step == 2 {
            
            DispatchQueue.main.a4xAfter(1) {
                self.animailStep1ConnectView!.isHidden = false
                self.animailStep1ConnectView!.play { [weak self](result) in
                    self?.animailStep1ConnectView!.isHidden = true
                    self?.animailStep1SuccessView!.isHidden = false
                    self?.animailStep1SuccessView!.play { (result) in }
                    self?.linkDeviceStep1Lbl!.textColor = ADTheme.C1
                }
            }
            
            animailStep2ConnectView!.loopMode = .loop
            DispatchQueue.main.a4xAfter(2) {
                self.waitStep2View!.isHidden = true
                self.animailStep2ConnectView!.isHidden = false
                self.animailStep2ConnectView!.play { (result) in }
            }

        } else if step == 3 {
            
            animailStep2ConnectView!.loopMode = .playOnce
            DispatchQueue.main.a4xAfter(1) {
                self.waitStep2View?.isHidden = true
                self.animailStep2ConnectView!.isHidden = false
                self.animailStep2ConnectView!.play { [weak self](result) in
                    self?.animailStep2ConnectView!.isHidden = true
                    self?.animailStep2SuccessView!.isHidden = false
                    self?.animailStep2SuccessView!.play { (result) in }
                    self?.searchDeviceStep2Lbl!.textColor = ADTheme.C1
                }
            }
            
            animailStep3ConnectView!.loopMode = .loop
            DispatchQueue.main.a4xAfter(2) {
                self.waitStep3View?.isHidden = true
                self.animailStep3ConnectView!.isHidden = false
                self.animailStep3ConnectView!.play { (result) in }
            }
            
        } else if step == 4 {
            
            if currentStep == 2 {
                
                self.animailStep2ConnectView!.loopMode = .playOnce
                DispatchQueue.main.a4xAfter(2) {
                    self.waitStep2View?.isHidden = true
                    self.animailStep2ConnectView!.isHidden = false
                    self.animailStep2ConnectView!.play { [weak self](result) in
                        self?.animailStep2ConnectView!.isHidden = true
                        self?.animailStep2SuccessView!.isHidden = false
                        self?.animailStep2SuccessView!.play { (result) in }
                        self?.searchDeviceStep2Lbl!.textColor = ADTheme.C1
                    }
                }
                
                self.animailStep3ConnectView!.loopMode = .playOnce
                DispatchQueue.main.a4xAfter(3) {
                    self.waitStep3View?.isHidden = true
                    self.animailStep3ConnectView!.isHidden = false
                    self.animailStep3ConnectView!.play { [weak self](result) in
                        self?.animailStep3ConnectView!.isHidden = true
                        self?.animailStep3SuccessView!.isHidden = false
                        self?.animailStep3SuccessView!.play { (result) in }
                        self?.registerCloudStep3Lbl!.textColor = ADTheme.C1
                    }
                }
                
                DispatchQueue.main.a4xAfter(4) {
                    self.waitStep4View?.isHidden = true
                    self.animailStep4ConnectView!.isHidden = false
                    self.animailStep4ConnectView!.play { [weak self](result) in
                        self?.animailStep4ConnectView!.isHidden = true
                        self?.animailStep4SuccessView!.isHidden = false
                        self?.animailStep4SuccessView!.play { (result) in }
                        self?.initDeviceStep4Lbl!.textColor = ADTheme.C1
                        // 绑定成功动画结束，处理跳转逻辑
                        self?.currentBindDeviceSuccess(serialNumber: serialNumber)
                    }
                }
                
            } else if currentStep == 3 {
                
                self.animailStep3ConnectView!.loopMode = .playOnce
                DispatchQueue.main.a4xAfter(1) {
                    self.waitStep3View?.isHidden = true
                    self.animailStep3ConnectView!.isHidden = false
                    self.animailStep3ConnectView!.play { [weak self](result) in
                        self?.animailStep3ConnectView!.isHidden = true
                        self?.animailStep3SuccessView!.isHidden = false
                        self?.animailStep3SuccessView!.play { (result) in }
                        self?.registerCloudStep3Lbl!.textColor = ADTheme.C1
                    }
                }
                
                DispatchQueue.main.a4xAfter(2) {
                    self.waitStep4View?.isHidden = true
                    self.animailStep4ConnectView!.isHidden = false
                    self.animailStep4ConnectView!.play { [weak self](result) in
                        self?.animailStep4ConnectView!.isHidden = true
                        self?.animailStep4SuccessView!.isHidden = false
                        self?.animailStep4SuccessView!.play { (result) in }
                        self?.initDeviceStep4Lbl!.textColor = ADTheme.C1
                        // 绑定成功动画结束，处理跳转逻辑
                        self?.currentBindDeviceSuccess(serialNumber: serialNumber)
                    }
                }
                
            } else if currentStep == 4 {
                self.animailStep2ConnectView!.loopMode = .playOnce
                DispatchQueue.main.a4xAfter(2) {
                    self.waitStep2View?.isHidden = true
                    self.animailStep2ConnectView!.isHidden = false
                    self.animailStep2ConnectView!.play { [weak self](result) in
                        self?.animailStep2ConnectView!.isHidden = true
                        self?.animailStep2SuccessView!.isHidden = false
                        self?.animailStep2SuccessView!.play { (result) in }
                        self?.searchDeviceStep2Lbl!.textColor = ADTheme.C1
                    }
                }
                
                self.animailStep3ConnectView!.loopMode = .playOnce
                DispatchQueue.main.a4xAfter(3) {
                    self.waitStep3View?.isHidden = true
                    self.animailStep3ConnectView!.isHidden = false
                    self.animailStep3ConnectView!.play { [weak self](result) in
                        self?.animailStep3ConnectView!.isHidden = true
                        self?.animailStep3SuccessView!.isHidden = false
                        self?.animailStep3SuccessView!.play { (result) in }
                        self?.registerCloudStep3Lbl!.textColor = ADTheme.C1
                    }
                }
                
                DispatchQueue.main.a4xAfter(4) {
                    self.waitStep4View?.isHidden = true
                    self.animailStep4ConnectView!.isHidden = false
                    self.animailStep4ConnectView!.play { [weak self](result) in
                        self?.animailStep4ConnectView!.isHidden = true
                        self?.animailStep4SuccessView!.isHidden = false
                        self?.animailStep4SuccessView!.play { (result) in }
                        self?.initDeviceStep4Lbl!.textColor = ADTheme.C1
                        // 绑定成功动画结束，处理跳转逻辑
                        self?.currentBindDeviceSuccess(serialNumber: serialNumber)
                    }
                }
            }
        }
        // dirty code - end
    }
    
    private func waitAPLinkUI(alpha: CGFloat) {
        
        animailStep1SuccessView?.alpha = alpha
        animailStep2SuccessView?.alpha = alpha
        animailStep3SuccessView?.alpha = alpha
        animailStep4SuccessView?.alpha = alpha
        
        animailStep2FailedView?.alpha = alpha
        animailStep3FailedView?.alpha = alpha
        animailStep4FailedView?.alpha = alpha
        
        waitStep2View?.alpha = alpha
        waitStep3View?.alpha = alpha
        waitStep4View?.alpha = alpha
        
        linkDeviceStep1Lbl?.alpha = alpha
        searchDeviceStep2Lbl?.alpha = alpha
        registerCloudStep3Lbl?.alpha = alpha
        initDeviceStep4Lbl?.alpha = alpha
    }
    
    // 重置动画属性
    private func resetAnimail() {
        
        self.searchDeviceStep2Lbl?.textColor = ADTheme.C3
        self.registerCloudStep3Lbl?.textColor = ADTheme.C3
        self.initDeviceStep4Lbl?.textColor = ADTheme.C3
        
        self.waitStep2View?.isHidden = false
        self.waitStep3View?.isHidden = false
        self.waitStep4View?.isHidden = false
        
        self.animailStep2ConnectView?.isHidden = true
        self.animailStep3ConnectView?.isHidden = true
        self.animailStep4ConnectView?.isHidden = true
        
        self.animailStep2SuccessView?.isHidden = true
        self.animailStep3SuccessView?.isHidden = true
        self.animailStep4SuccessView?.isHidden = true
        
        self.logoToSmailAniView?.isHidden = false
        self.connectSuccessAniView?.isHidden = true
        
    }
    
    // 开始结束动画 -  绑定成功
    private func startFinishAnimail(comple :@escaping () -> Void ){
        
        logoToBigAniView?.isHidden = true
        connectWaittingBGAniView?.isHidden = true
        
        // 执行关联动画
        logoToSmailAniView?.isHidden = false
        logoToSmailAniView?.play { [weak self](finish) in
            if finish {
                self?.logoToSmailAniView?.isHidden = true
                DispatchQueue.main.a4xAfter(0.2) {
                    self?.connectSuccessAniView?.isHidden = false
                    self?.connectSuccessAniView?.play { (result) in
                        comple()
                    }
                }
            }
        }
    }
}

// MARK: - 绑定监听和处理
extension BindConnectWaitViewController {
    override func onStepChange(code: Int) {
        A4xLog("---------> onStepChange code: \(code)")
        if self.currentStep != code {
            self.currentStep = code
            self.bindCheckStepAnimil(step: code, animName: "", serialNumber: nil, isFailed: false)
        }
        
    }
    
    override func onGenarateQrCode(newQRCdoe: UIImage?, oldQRCode: UIImage?, wireQRCode: UIImage?) {
        A4xLog("---------> onGenarateQrCode")
    }
    
    override func onSuccess(code: Int, msg: String?, serialNumber: String?) {
        A4xLog("---------> onSuccess")
        self.viewModel?.saveBindWifiToCache(wifiName: self.wifiName ?? "", wifiPwd: self.wifiPwd ?? "" )
        
        // 打点事件（发送后端）
        //self.logBindComplete(model?.opretionId, step)
        self.bindSuccess(serialNumber: serialNumber)
    }
    
    override func onError(code: Int, msg: String?) {
        A4xLog("---------> onError code: \(code) msg: \(msg)")
        var errType: BindErrorTypeEnum? = .none
        switch code {
        case -10203: // 密码错误
            errType = .pwd
            pushBack(type: errType ?? .connect)
            break
        case -10204: // 找不到SSID
            errType = .ap
            pushBack(type: errType ?? .connect)
            break
        case -10205: // 认证方式错误
            errType = .auth
            pushBack(type: errType ?? .connect)
            break
        case -10206: // DHCP 错误
            errType = .ip
            pushBack(type: errType ?? .connect)
            break
        case -10207: // 无线连接失败
            errType = .wirelessErr
            pushBack(type: errType ?? .connect)
            break
        case -10208: // 服务器连接超时
            errType = .connect
            pushBack(type: errType ?? .connect)
            break
        case -10209: //绑定校验失败
            errType = .auth
            pushBack(type: errType ?? .connect)
            break
        case -10311, -10308: // 连接ap失败
            self.jumpA4xBindScanQRCodeViewController()
            break
        case -10313: // 连接ap超时
            self.jumpBindManuallyAddAPNetGuideViewController()
            break
        case -10003: // 本地网络权限
            // 弹窗授权窗
            A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.localNet) { (f) in
                if !f {
                   // 点击暂不开启 - 回调 - 返回上一页
                } else {
                    self.isLocalNetLimit = true
                }
            }
        case -10314: // 有线IP为空
            BindCore.getInstance().startBindByAp(ssid: self.wifiName, ssidPassword: self.wifiPwd, bindDeviceModel: self.selectedBindDeviceModel)
            break
        default:
            break
        }
    }
}

// MARK: -
extension BindConnectWaitViewController {
    // 处理连接中
    private func connectingUI() {
        A4xLog("---------> ble connectingUI")
        
        // 更改状态
        UIView.animate(withDuration: 0.6, animations: {
            self.titleLable.text = A4xBaseManager.shared.getLocalString(key: "connecting")
            self.titleHintLabel.alpha = 0
        }, completion: { (_) in
            self.titleHintLabel.isHidden = true
        })
        
        self.animailStep2ConnectView!.loopMode = .loop
        self.animailStep2ConnectView?.isHidden = false
        self.animailStep2ConnectView!.play { (result) in }
        
        self.waitAPLinkUI(alpha: 1)
        
        self.loadNextLoadingAnimail()
        
        self.resetAnimail()
        
        self.bindCheckStepAnimil(step: 2, animName: "", serialNumber: nil, isFailed: false)
        
    }
    
    // 连接AP热点超时 - 跳转
    func jumpBindManuallyAddAPNetGuideViewController() {

        
//        let vc = BindManuallyAddAPNetGuideViewController()
//        vc.apInfoDetailModel  = self.apInfoDetailModel
//        vc.needSendBindText = self.needSendBindText
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 跳转
    func jumpA4xBindScanQRCodeViewController(errMsg: String = "") {
        
        let vc = BindScanQRCodeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushBack(type: BindErrorTypeEnum) {
        
        let vcs = self.navigationController?.viewControllers.filter({ (vc) -> Bool in
            return vc is BindChooseWifiViewController
        })
            
        guard let toViewController = vcs?.last as? BindChooseWifiViewController else {
            return
        }
        toViewController.bindErrorTypeEnum = type
        self.navigationController?.popToViewController(toViewController, animated: false)
    }
}

