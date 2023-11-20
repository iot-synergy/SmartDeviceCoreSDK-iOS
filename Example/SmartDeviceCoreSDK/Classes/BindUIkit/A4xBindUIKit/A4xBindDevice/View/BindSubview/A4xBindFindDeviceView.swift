//


//


//

import UIKit
import Lottie
import SmartDeviceCoreSDK
import BaseUI

enum StopScanType {
    case none
    case background
    case bleOffOrUnAuth
    case nextPage
    case keepScan
}

protocol A4xBindFindDeviceViewProtocol: class {
    func devicesCellSelect(model: BindDeviceModel?, clickType: Int)
    func searchTimeout()
    func search_nofindDevice()
    func findDeviceView_dingDongVoiceGuideViewHearNothingClick()
    func findDeviceView_dingDongVoiceGuideViewNextAction()
    func findDeviceView_dingDongVoiceGuideViewVBackClick()
    func findDeviceView_dingDongVoiceGuideViewVoicePlayClick()
    func findDeviceView_dingDongVoiceGuideViewZendeskChatClick()
}

class A4xBindFindDeviceView: A4xBindBaseView {
    
    weak var `protocol` : A4xBindFindDeviceViewProtocol?
    
    let bluetoothSearchBigName = "device_search_big"
    
    let bluetoothSearchSmallName = "device_search_small"
    
    var dataSource: [[BindDeviceModel]]? = []
    
    var cellHeight: CGFloat = 94.5.auto()
    
    var bluetoothTopClickBlock : (()->Void)?
    
    var backClick: (()->Void)?
    
    var zendeskChatClick: (()->Void)?
    
    var nofindAnimationBlock: (()->Void)?
    
    var searchNothingBlock: (()->Void)?
    
    var bindDingDongVoiceGuideView: A4xBindDingDongVoiceGuideView?
    
    
    private let semaphare = DispatchSemaphore(value: 1)
    
    
    let animationSerialQueue = DispatchQueue(label: "com.a4x.ai.FindDeviceAnimation")
    
    
    private var loadingTimerCount : Int = 0
    
    
    private var searchTimeoutCount : Int = 5
    
    
    private var isDingDong: Bool = false
    
    
    
    private var isNoDataView: Bool = false
    
    private var curStopType: StopScanType = .none
    
    private var tableCellNeedAnimation: Bool = false
    
    override var datas: Dictionary<String, String>? {
        didSet {
            if !(datas?["nextEnable"]?.isBlank ?? true) {
                nextBtn.isEnabled = datas?["nextEnable"] == "1" ? true : false
            }
            
            if !(datas?["title"]?.isBlank ?? true) {
                self.titleLbl.text = datas?["title"]
            }
            
        }
    }
    
    lazy var navView: A4xBaseNavView = {
        let temp = A4xBaseNavView()
        temp.backgroundColor = UIColor.white
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
            self?.stopTimer()
            self?.backClick?()
        }
        

        return temp
    }()
    
    
    lazy var bluetoothSerachTopView: A4xBluetoothActionsheetView = {
        let temp = A4xBluetoothActionsheetView(frame: self.bounds)
        temp.closeBlock = { [weak self] in
            self?.bluetoothTopClickBlock?()
        }
        
        temp.devicesCellSelectBlock = { [weak self] model in
            
            self?.protocol?.devicesCellSelect(model: model, clickType: 1)
        }
        
        return temp
    }()
    
    
    
    lazy var bluetoothTableView: UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        temp.delegate = self
        temp.dataSource = self
        temp.backgroundColor = .clear
        temp.tableFooterView = UIView()
        temp.accessibilityIdentifier = "tableView"
        temp.separatorInset = .zero
        temp.separatorColor = ADTheme.C6
        temp.estimatedRowHeight = 80
        temp.rowHeight = UITableView.automaticDimension
        temp.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20.auto(), right: 0)
        return temp
    }()
    
    lazy var searchBigPointView: UIView = {
        var temp =  UIView()
        temp.alpha = 0
        return temp
    }()
    
    lazy var searchBigAniView: LottieAnimationView = {
        var temp : LottieAnimationView
        
        temp = LottieAnimationView(name: bluetoothSearchBigName, bundle: a4xBaseBundle())
        let keypath = AnimationKeypath(keypath: "扩散.**.填充 1.Color");
        let keypath2 = AnimationKeypath(keypath: "背景色.**.填充 1.Color");
        temp.setValueProvider(A4xBindConfig.getLottieColorValueProvider(), keypath: keypath);
        temp.setValueProvider(A4xBindConfig.getLottieColorValueProvider(), keypath: keypath2);
        temp.loopMode = .loop
        return temp
    }()
    
    lazy var searchSmallAniView: LottieAnimationView = {
        var temp : LottieAnimationView
        
        temp = LottieAnimationView(name: bluetoothSearchSmallName, bundle: a4xBaseBundle())
        let keypath = AnimationKeypath(keypath: "扩散.**.填充 1.Color");
        let keypath2 = AnimationKeypath(keypath: "背景色.**.填充 1.Color");
        temp.setValueProvider(A4xBindConfig.getLottieColorValueProvider(), keypath: keypath);
        temp.setValueProvider(A4xBindConfig.getLottieColorValueProvider(), keypath: keypath2);
        temp.loopMode = .loop
        return temp
    }()
    
    lazy var searchTopAniView: LottieAnimationView = {
        var temp : LottieAnimationView
        temp = LottieAnimationView(name: bluetoothSearchSmallName, bundle: a4xBaseBundle())
      
        let keypath = AnimationKeypath(keypath: "扩散.**.填充 1.Color");
        let keypath2 = AnimationKeypath(keypath: "背景色.**.填充 1.Color");
        temp.setValueProvider(A4xBindConfig.getLottieColorValueProvider(), keypath: keypath);
        temp.setValueProvider(A4xBindConfig.getLottieColorValueProvider(), keypath: keypath2);
        temp.loopMode = .loop
        return temp
    }()
    
    lazy var findDeviceImageView: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("bind_find_device_nav")
        temp.isHidden = true
        temp.addActionHandler { [weak self] in
            self?.clickFindDeviceImgOrBubbleImgAnimation()
        }
        return temp
    }()
    
    lazy var findDeviceBubbleImageView: UIImageView = {
        let temp = UIImageView()
        
        temp.isHidden = false
        
        let lbl = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "bt_new_device_pop")
        lbl.font = UIFont.regular(11)
        lbl.textColor = ADTheme.C1
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        let width: CGFloat = 94.auto()
        let height = lbl.getLabelHeight(lbl, width: width)
        lbl.size = CGSize(width: width, height: height)
        temp.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.top.equalTo(17.5)
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
        
        let image = bundleImageFromImageName("bind_find_device_bubble")?.rtlImage()
        temp.image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 15, bottom: 15, right: 15), resizingMode: .stretch)
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.trailing.equalTo(self.findDeviceImageView.snp.trailing).offset(3.auto())
            make.top.equalTo(self.findDeviceImageView.snp.bottom).offset(-10.auto())
            make.size.equalTo(CGSize(width: lbl.width + 30, height: lbl.height + 32.5))
        }
        
        temp.addActionHandler { [weak self] in
            self?.clickFindDeviceImgOrBubbleImgAnimation()
        }
        
        return temp
    }()
    
    
    lazy var searchNothingLbl: A4xBaseURLTextView = {
        var lblTV: A4xBaseURLTextView = A4xBaseURLTextView()
        lblTV.isUserInteractionEnabled = true
        
        lblTV.linkTextColor = UIColor.colorFromHex("#1484E4")
        lblTV.textColor = ADTheme.C3
        lblTV.font = UIFont.regular(14)
        
        lblTV.text(text: "\(A4xBaseManager.shared.getLocalString(key: "bt_no_found_device"))\n \(A4xBaseManager.shared.getLocalString(key: "bt_no_found_device_link"))", links: (A4xBaseManager.shared.getLocalString(key: "bt_no_found_device_link"), "")) { height in}
        lblTV.textAlignment = .center
        
        
        lblTV.addLinkBlock = {[weak self] (urlString ) in
            self?.loadingTimerCount = 6
            self?.searchSmallAniView.isHidden = true
            self?.searchNothingLbl.isHidden = true
            self?.noFindDeviceAnimation(duration: 0.6)
            self?.searchNothingBlock?()
            
            if (self?.dataSource?.count ?? 0) > 0 {
                DispatchQueue.main.a4xAfter(2.0) {
                    self?.topFindDeviceAnimation()
                }
            }
        }
        lblTV.isHidden = true
        return lblTV
    }()
    
    init(frame: CGRect, isDingDong: Bool) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        self.isDingDong = isDingDong
        self.loadingTimerCount = isDingDong ? 6 : 0
        self.searchTimeoutCount = 5
        
        setupUI()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
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
        
        titleHintTxtView.isHidden = true
        nextBtn.isHidden = true
        
        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "bt_searching_device")
        
        navView.isHidden = false
        
        addSubview(searchBigPointView) 
        addSubview(bluetoothTableView)
        addSubview(searchBigAniView)
        
        addSubview(searchSmallAniView)
        addSubview(searchNothingLbl)
        
        setupA4xBindDingDongVoiceGuideView(isHidden: !self.isDingDong)
        
        addSubview(searchTopAniView)
        addSubview(findDeviceImageView)
        
        
        titleLbl.snp.updateConstraints { make in
            make.top.equalTo(UIScreen.navBarHeight)
        }
        titleLbl.layoutIfNeeded()
        
        
        searchTopAniView.snp.makeConstraints { make in
            make.trailing.equalTo(self.navView.snp.trailing).offset(-52.auto())
            make.width.height.equalTo(48.auto())
            make.centerY.equalTo(self.navView.rightBtn!.snp.centerY)
        }
        searchTopAniView.layoutIfNeeded()
        searchTopAniView.alpha = 0
        
        
        findDeviceImageView.snp.makeConstraints { make in
            make.trailing.equalTo(self.navView.snp.trailing).offset(-58.auto())
            make.centerY.equalTo(self.navView.rightBtn!.snp.centerY)
            make.width.height.equalTo(28.auto())
        }
        
        
        findDeviceBubbleImageView.isHidden = true
        
        
        
        searchBigPointView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX).offset(0)
            make.centerY.equalTo(self.snp.centerY).offset(-100.auto())
            make.width.height.equalTo(125.auto())
        }
        
        
        searchBigAniView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX).offset(0)
            make.centerY.equalTo(self.snp.centerY).offset(-100.auto())
            make.width.height.equalTo(125.auto())
        }
        searchBigAniView.play()
        
        
        searchNothingLbl.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom).offset(-33.auto() + 60.auto())
            make.width.equalTo(266.5.auto())
        })
        searchNothingLbl.layoutIfNeeded()
        
        
        searchSmallAniView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.width.height.equalTo(48.auto()) 
            make.bottom.equalTo(self.searchNothingLbl.snp.top).offset(-16.auto() - 60.auto())
        }
        
        searchSmallAniView.layoutIfNeeded()
        searchSmallAniView.alpha = 0
        searchSmallAniView.play()
        
        
        bluetoothTableView.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading).offset(16.auto())
            make.top.equalTo(self.titleLbl.snp.bottom).offset(28.auto())
            make.width.equalTo(self.snp.width).offset(-32.auto())
            make.bottom.equalTo(self.searchNothingLbl.snp.top).offset(-70.auto())
        }
        
        bluetoothTableView.layoutIfNeeded()
        
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            return
        }
        
        
        if !self.isDingDong {
            startTimer(isContinue: false)
        }
    }
    
    private func reSetUpUI(needTimer: Bool) {
        let item = DispatchWorkItem {
            
            self.searchTopAniView.snp.remakeConstraints { make in
                make.trailing.equalTo(self.navView.snp.trailing).offset(-52.auto())
                make.width.height.equalTo(48.auto())
                make.centerY.equalTo(self.navView.rightBtn!.snp.centerY)
            }
            self.searchTopAniView.layoutIfNeeded()
            self.searchTopAniView.alpha = 0
            self.searchTopAniView.isHidden = false
            
            
            self.findDeviceImageView.snp.remakeConstraints { make in
                make.trailing.equalTo(self.navView.snp.trailing).offset(-58.auto())
                make.centerY.equalTo(self.navView.rightBtn!.snp.centerY)
                make.width.height.equalTo(28.auto())
            }
            
            
            self.findDeviceBubbleImageView.isHidden = true
            
            
            self.searchBigAniView.snp.remakeConstraints { make in
                make.centerX.equalTo(self.snp.centerX).offset(0)
                make.centerY.equalTo(self.snp.centerY).offset(-100.auto())
                make.width.height.equalTo(125.auto())
            }
            self.searchBigAniView.alpha = 1
            self.searchBigAniView.isHidden = false
            self.searchBigAniView.play()
            
            
            self.searchNothingLbl.snp.remakeConstraints({ make in
                make.centerX.equalTo(self.snp.centerX)
                make.bottom.equalTo(self.snp.bottom).offset(-33.auto() + 60.auto())
                make.width.equalTo(266.5.auto())
            })
            self.searchNothingLbl.layoutIfNeeded()
            //searchNothingLbl.isHidden = true
            
            
            self.searchSmallAniView.snp.remakeConstraints { make in
                make.centerX.equalTo(self.snp.centerX)
                make.width.height.equalTo(48.auto()) 
                make.bottom.equalTo(self.searchNothingLbl.snp.top).offset(-16.auto() - 60.auto())
            }
            
            self.searchSmallAniView.layoutIfNeeded()
            self.searchSmallAniView.alpha = 0
            self.searchSmallAniView.isHidden = false
            self.searchSmallAniView.play()
            
            
            self.bluetoothTableView.snp.remakeConstraints { make in
                make.leading.equalTo(self.snp.leading).offset(16.auto())
                make.top.equalTo(self.titleLbl.snp.bottom).offset(28.auto())
                make.width.equalTo(self.snp.width).offset(-32.auto())
                make.bottom.equalTo(self.searchNothingLbl.snp.top).offset(-70.auto())
            }
            
            self.bluetoothTableView.layoutIfNeeded()
            self.bluetoothTableView.isHidden = false
        }
        
        animationSerialQueue.sync(execute: item)
        
        if needTimer {
            
            startTimer(isContinue: false)
        }
        
    }
    
    //
    func noNetTry() {
        
        if isNoDataView {
            
            isNoDataView = false
            
            
            if !checkSearchTimeOut() {
                
                if (self.dataSource?.count ?? 0) >= 1 {
                    self.stopTimer()
                    self.bluetoothTableView.isHidden = false
                    
                    DispatchQueue.main.a4xAfter(0.1) {
                        if !self.checkSearchTimeOut() {
                            self.searchSmallAniView.isHidden = true
                            self.searchNothingLbl.isHidden = true
                        }
                        self.findDeviceAnimation(duration: 0.8)
                    }
                    
                    DispatchQueue.main.a4xAfter(5.0) {
                        
                        if A4xUserDataHandle.Handle?.netConnectType != .nonet {
                            
                            
                            
                            if self.searchNothingLbl.isHidden {
                                
                                DispatchQueue.main.a4xAfter(5.0) {
                                    self.noFindDeviceHintAnimaiton()
                                }
                            }
                        }
                    }

                } else {
                    self.reSetSearch()
                }
                
            } else {
                
                
                if (self.dataSource?.count ?? 0) > 0 {
                    
                    self.findDeviceImageView.isHidden = true
                    self.findDeviceBubbleImageView.isHidden = true
                    
                    self.bluetoothTableView.isHidden = true
                    
                    self.bindDingDongVoiceGuideView?.isHidden = false
                    self.bindDingDongVoiceGuideView?.alpha = 1
                    
                    self.searchTopAniView.alpha = 1
                    self.searchTopAniView.isHidden = false
                    self.searchTopAniView.play()
                    
                    self.topFindDeviceAnimation()
                    
                } else {
                    
                    
                    self.bindDingDongVoiceGuideView?.isHidden = false
                    self.bindDingDongVoiceGuideView?.alpha = 1
                    
                    self.searchTopAniView.alpha = 1
                    self.searchTopAniView.isHidden = false
                    self.searchTopAniView.play()
                }
            }
            
        }
    }
    
    func findNewDevice(model: BindDeviceModel) {
        if !(dataSource?.contains(where: { models in
            models[0].userSn == model.userSn
        }) ?? true) {
            var arr: [BindDeviceModel] = []
            arr.append(model)
            dataSource?.append(arr)
            
            
            if checkSearchTimeOut() { 
                
                self.topFindDeviceAnimation()
            } else { 
                
                stopTimer()
                
                updateUI()
                
                if dataSource?.count == 1 {
                    DispatchQueue.main.a4xAfter(0.1) {
                        self.findDeviceAnimation(duration: 0.8)
                    }
                    
                    DispatchQueue.main.a4xAfter(5.0) {
                        
                        if A4xUserDataHandle.Handle?.netConnectType != .nonet {
                            
                            self.noFindDeviceHintAnimaiton()
                        }
                    }
                }
            }
            
        } else { 
            let bindDeviceModelRange = getBindDeviceModel(sn: model.userSn ?? "")
            if bindDeviceModelRange != nil {
                if bindDeviceModelRange?.1 != nil && bindDeviceModelRange?.1 != -1 {
                    tableCellNeedAnimation = false
                    dataSource?[(bindDeviceModelRange?.1)!][0] = model
                    self.bluetoothTableView.reloadData()
                }
            }
        }
    }
    
    func getBindDeviceModel(sn: String) -> (BindDeviceModel?, Int?)? {
        var index = -1
        index = dataSource?.firstIndex(where: { models in
            sn.contains(models[0].userSn ?? "nil")
        }) ?? -1
        
        if index == -1 {
            return nil
        } else {
            return (dataSource?[index][0], index)
        }
    }
    
    
    func updateUI() {
        if (dataSource?.count ?? 0) > 0 {
            self.titleLbl.text = A4xBaseManager.shared.getLocalString(key: "bt_select_device")
        }
        
        tableCellNeedAnimation = true
        self.bluetoothTableView.beginUpdates()
        //更新section
        self.bluetoothTableView.insertSections([(dataSource?.count ?? 0) - 1], with: .none)
        self.bluetoothTableView.endUpdates()
    }
    
    
    private func findDeviceAnimation(duration: TimeInterval) {
        findTransformAnimation(fromV: self.searchBigAniView, toV: self.searchSmallAniView, duration: duration)
    }
    
    
    public func refindDeviceAnimation(duration: TimeInterval) {
        let item = DispatchWorkItem {
            if (self.dataSource?.count ?? 0 > 0) {
                self.findDeviceImageView.isHidden = true
                self.findDeviceImageView.alpha = 1
                self.findDeviceBubbleImageView.isHidden = true
            }
            
            self.searchBigAniView.alpha = 1
            self.searchBigAniView.isHidden = false
        }
        animationSerialQueue.sync(execute: item)
        
        let fromV = self.searchBigAniView
        let toV = self.searchBigPointView
        
        let currentAngle = CGFloat(atan2(Double(fromV.transform.b), Double(fromV.transform.a)))
        let toViewCenter = toV.center
        
        var newTransform = CGAffineTransform.identity
        newTransform = newTransform.scaledBy(x: 1, y: 1)
        newTransform = newTransform.rotated(by: currentAngle)
        
        var voiceGuideTransform = CGAffineTransform.identity
        voiceGuideTransform.ty = self.maxY
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
            let item = DispatchWorkItem {
                fromV.center = toViewCenter
                fromV.transform = newTransform
                fromV.alpha = 1
                
                self.titleLbl.alpha = 1
                self.titleLbl.isHidden = false
                self.bluetoothTableView.alpha = 1
                self.bindDingDongVoiceGuideView?.transform = voiceGuideTransform
                self.bindDingDongVoiceGuideView?.alpha = 0.2
                
                self.searchTopAniView.alpha = 0
                self.searchTopAniView.pause()
            }
            self.animationSerialQueue.sync(execute: item)
        }, completion: { (_) in
            
            let item = DispatchWorkItem {
                self.bindDingDongVoiceGuideView?.isHidden = true
                self.bluetoothTableView.isHidden = false
                self.searchTopAniView.alpha = 0
                fromV.play()
            }
            
            self.animationSerialQueue.sync(execute: item)

            if (self.dataSource?.count ?? 0 > 0) {
                let item = DispatchWorkItem {
                    self.loadingTimerCount = 0
                    self.titleLbl.alpha = 1
                    self.titleLbl.isHidden = false
                    
                    self.bluetoothTableView.reloadData()
                    
                    if !self.checkSearchTimeOut() {
                        self.searchSmallAniView.isHidden = true
                        self.searchNothingLbl.isHidden = true
                    }
                }
                self.animationSerialQueue.sync(execute: item)
                self.findDeviceAnimation(duration: 0.8)
                
                DispatchQueue.main.a4xAfter(5.0) {
                    
                    if A4xUserDataHandle.Handle?.netConnectType != .nonet {
                        
                        self.noFindDeviceHintAnimaiton()
                    }
                }
            } else {
                self.startTimer(isContinue: false)
            }
        })
    }
    
    
    private func noFindDeviceAnimation(duration: TimeInterval) {
        self.nofindAnimationBlock?()
        findTransformAnimation(fromV: self.searchBigAniView, toV: self.searchTopAniView, isTittleHidden: true, duration: duration)
    }
    
    
    private func findTransformAnimation(fromV: LottieAnimationView, toV: LottieAnimationView, isTittleHidden: Bool = false, duration: TimeInterval = 0.8) {
        
        let item = DispatchWorkItem {
            fromV.alpha = 1
            fromV.isHidden = false
            
            let currentAngle = CGFloat(atan2(Double(fromV.transform.b), Double(fromV.transform.a)))
            let toViewCenter = toV.center
            var newTransform = CGAffineTransform.identity
            newTransform = newTransform.scaledBy(x: 0.4, y: 0.4)
            newTransform = newTransform.rotated(by: currentAngle)
            
            var voiceGuideTransform = CGAffineTransform.identity
            if isTittleHidden {
                self.titleLbl.alpha = 0.5
                voiceGuideTransform.ty = -self.maxY
                self.bindDingDongVoiceGuideView?.alpha = 0.6
                self.bindDingDongVoiceGuideView?.isHearNothingLaterClick = true
            }
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
                fromV.center = toViewCenter
                fromV.transform = newTransform
                
                if isTittleHidden {
                    self.titleLbl.alpha = 0.2
                    self.bluetoothTableView.alpha = 0
                    
                    self.bindDingDongVoiceGuideView?.transform = voiceGuideTransform
                    self.bindDingDongVoiceGuideView?.isHidden = false
                    self.bindDingDongVoiceGuideView?.alpha = 0.7
                }
            }, completion: { (_) in
                if isTittleHidden {
                    self.titleLbl.alpha = 0
                    self.bindDingDongVoiceGuideView?.alpha = 1
                    DispatchQueue.main.a4xAfter(3.0) {
                        self.bindDingDongVoiceGuideView?.isHearNothingLaterClick = false
                    }
                    self.bluetoothTableView.isHidden = true
                }
                fromV.alpha = 0
                fromV.pause()
                toV.alpha = 1
                toV.isHidden = false
                toV.play()
            })
        }
        animationSerialQueue.sync(execute: item)
    }
    
    
    private func topFindDeviceAnimation() {
        let item = DispatchWorkItem {
            if self.findDeviceImageView.isHidden {
                if A4xUserDataHandle.Handle?.netConnectType == .nonet {
                    return
                }
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.transitionCrossDissolve], animations: {
                    self.searchTopAniView.alpha = 0
                    self.searchTopAniView.pause()
                }, completion: { (_) in
                    self.findDeviceImageView.isHidden = false
                    self.findDeviceImageView.alpha = 1
                })
            }
        }
        animationSerialQueue.sync(execute: item)
        
        self.findBubbleAnimation()
    }
    
    
    private func topResetDeviceAnimation() {
        let item = DispatchWorkItem {
            if !self.findDeviceImageView.isHidden {
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.transitionCrossDissolve], animations: {
                    self.findDeviceImageView.isHidden = true
                    self.findDeviceImageView.alpha = 1
                    self.findDeviceBubbleImageView.isHidden = true
                }, completion: { (_) in
                    self.searchTopAniView.alpha = 1
                    self.searchTopAniView.isHidden = false
                    self.searchTopAniView.play()
                })
            } else {
                
                self.searchTopAniView.play()
                self.searchTopAniView.isHidden = false
                self.searchTopAniView.alpha = 1
            }
        }
        animationSerialQueue.sync(execute: item)
    }
    
    
    
    private func findBubbleAnimation() {
        let item = DispatchWorkItem {
            var newTransform = CGAffineTransform.identity
            newTransform.ty = 10.auto()
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut], animations: {
                self.searchTopAniView.isHidden = true
                self.searchTopAniView.pause()
            }, completion: { (_) in
                self.findDeviceImageView.isHidden = false
                self.findDeviceImageView.alpha = 1
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut], animations: {
                    self.findDeviceBubbleImageView.transform = newTransform
                    self.findDeviceBubbleImageView.isHidden = false
                }, completion: { (_) in
                    self.searchTopAniView.isHidden = true
                    self.searchTopAniView.pause()
                })
            })
        }
        animationSerialQueue.sync(execute: item)
    }
    
    
    private func noFindDeviceHintAnimaiton() {
        
        //let item = DispatchWorkItem {}
        //animationSerialQueue.sync(execute: item)
        
        var newTransform = CGAffineTransform.identity
        newTransform.ty = -60.auto()
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut], animations: {
            self.searchNothingLbl.transform = newTransform
            self.searchNothingLbl.isHidden = false
        }, completion: { (_) in
            
        })
    }
    
    
    private func clickFindDeviceImgOrBubbleImgAnimation() {
        self.bluetoothTopClickBlock?()
        //
        let isMore = (self.dataSource?.count ?? 0) > 1 ? true : false
        let height = isMore ? UIScreen.height / 3 : (cellHeight + 60.auto()) + UIScreen.barNewHeight
        self.bluetoothSerachTopView.dataSource = self.dataSource
        self.bluetoothSerachTopView.contenView = UIView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.width, height: height))
        self.bluetoothSerachTopView.contenView?.backgroundColor = .white
        self.bluetoothSerachTopView.showInWindow()
        
    }
    
    
    func stopSearch(stopType: StopScanType) {
        let item = DispatchWorkItem {}
        animationSerialQueue.sync(execute: item)
        
        curStopType = stopType
        if checkSearchTimeOut() {
            
            self.searchTopAniView.pause()
            self.searchTopAniView.isHidden = true
        } else {
            
            self.searchSmallAniView.pause()
            self.searchSmallAniView.isHidden = true
            
            if stopType == .bleOffOrUnAuth {
                
                self.bindDingDongVoiceGuideView?.isHidden = false
                self.noFindDeviceAnimation(duration: 0.8)
                DispatchQueue.main.a4xAfter(1.0) {
                    self.searchTopAniView.isHidden = true
                }
                self.loadingTimerCount = 6
                self.stopTimer()
            }
            
        }
        self.findDeviceImageView.isHidden = true
        self.findDeviceBubbleImageView.isHidden = true
    }
    
    
    func startSearch() {
        
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            self.noDataView()
            return
        } else {
            self.hiddNoDataView()
            if isNoDataView {
                self.noNetTry()
                return
            }
        }
        
        if checkSearchTimeOut() {
            
            self.topResetDeviceAnimation()
            
            
            if (self.dataSource?.count ?? 0) > 0 {
                DispatchQueue.main.a4xAfter(1) {
                    self.topFindDeviceAnimation()
                }
            }
            
            
        } else {
            
            
            self.searchBigAniView.play()
            self.searchSmallAniView.play()
            self.searchSmallAniView.isHidden = false
            
            if (self.dataSource?.count ?? 0) > 0 {
                
                self.searchSmallAniView.alpha = 1
                
                self.bluetoothTableView.reloadData()
                
            } else {
                
                self.searchSmallAniView.alpha = 0
            }
            
        }
    }
    
    private func noDataView() {
        
        stopTimer()
        
        isNoDataView = true
        
        searchBigAniView.isHidden = true
        searchNothingLbl.isHidden = true
        searchSmallAniView.isHidden = true
        bluetoothTableView.isHidden = true
        searchTopAniView.isHidden = true
        findDeviceImageView.isHidden = true
        findDeviceBubbleImageView.isHidden = true
        
        if checkSearchTimeOut() {
            bindDingDongVoiceGuideView?.isHidden = true
        }
        
        let repertTitle : String? = A4xBaseManager.shared.getLocalString(key: "please_retry")
        
        weak var weakSelf = self
        
        let img = bundleImageFromImageName("no_wifi_connet_tip")
        
        let err = A4xBaseManager.shared.getLocalString(key: "to_coninue_please_check_internet")
        
        let errorValue = A4xBaseNoDataValueModel.noData(error: err, image: img, retry: true, retryTitle: repertTitle, noDataType: .retry, specialState: A4xBaseNoDataSpecialType.none) {
            
            if A4xUserDataHandle.Handle?.netConnectType == .nonet {
                self.makeToast(A4xBaseManager.shared.getLocalString(key: "phone_no_net"))
            } else {
                
                weakSelf?.noNetTry()
            }
        }
        
        let _ = self.showNoDataView(value: errorValue)
    }
    
    func reSetSearch() {
        self.reSetUpUI(needTimer: true)
    }
    
    
    func viewWillAppear() {
        if checkSearchTimeOut() {
            
            startSearch()
        } else {
            
            
            if (self.dataSource?.count ?? 0) > 0 {
                
                startSearch()
            } else {
                
                reSetSearch()
            }
        }
    }
    
    
    func viewWillDisappear() {
        if checkSearchTimeOut() {
            
            stopSearch(stopType: .nextPage)
        } else {
            
            if (self.dataSource?.count ?? 0) > 0 {
                
                stopSearch(stopType: .nextPage)
            } else {
                
                stopTimer()
                stopSearch(stopType: .nextPage)
            }
            
        }
    }
    
    
    @objc func didBecomeActive() {
        
        //startSearch()
        //startTimer(isContinue: true)
    }
    
    
    @objc func applicationEnterBackground() {
        
        //stopSearch()
        //stopTimer()
    }
    
}

extension A4xBindFindDeviceView {
    
    func setupA4xBindDingDongVoiceGuideView(isHidden: Bool = false) {
        bindDingDongVoiceGuideView = A4xBindDingDongVoiceGuideView(frame: CGRect(x: 0, y: self.maxY, width: self.width, height: self.height))
        var voiceGuideTransform = CGAffineTransform.identity
        voiceGuideTransform.ty = -self.maxY
        if !isHidden {
            self.bindDingDongVoiceGuideView?.transform = voiceGuideTransform
        }
        
        let currentView = bindDingDongVoiceGuideView
        currentView?.isUserInteractionEnabled = true
        currentView?.protocol = self
        currentView?.isHidden = isHidden
        self.addSubview(currentView!)
        
        currentView?.backClick = { [weak self] in
            self?.protocol?.findDeviceView_dingDongVoiceGuideViewVBackClick()
            if BindCore.getInstance().bleAuthAndOpenIsReady() {
                if self?.checkSearchTimeOut() ?? false {
                    self?.refindDeviceAnimation(duration: 0.8)
                    return
                }
            }
            self?.backClick?()
        }
        
        currentView?.zendeskChatClick = { [weak self] in
            self?.protocol?.findDeviceView_dingDongVoiceGuideViewZendeskChatClick()
            //self?.zendeskChatClick?()
        }
        
    }
}

extension A4xBindFindDeviceView: A4xBindDingDongVoiceGuideViewProtocol {
    func dingDongPlayClick() {
        self.protocol?.findDeviceView_dingDongVoiceGuideViewVoicePlayClick()
    }
    
    func hearNothing() {
        self.protocol?.findDeviceView_dingDongVoiceGuideViewHearNothingClick()
    }
    
    func dingDongVoiceGuideViewNextAction() {
        self.protocol?.findDeviceView_dingDongVoiceGuideViewNextAction()
    }
}

extension A4xBindFindDeviceView: UITableViewDelegate, UITableViewDataSource, A4xBindFindDeviceViewCellProtocol {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?[section].count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "A4xBindFindDeviceViewCell"
        var tableCell: A4xBindFindDeviceViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xBindFindDeviceViewCell
        if (tableCell == nil) {
            tableCell = A4xBindFindDeviceViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        tableCell?.model = (self.dataSource?[indexPath.section][indexPath.row], 48.auto())
        cellHeight = tableCell?.getCellHeight() ?? 94.5.auto()
        tableCell?.protocol = self
        return tableCell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataSource?[indexPath.section][indexPath.row]
        self.protocol?.devicesCellSelect(model: model, clickType: 0)
    }
    
    func cellClickAction(model: BindDeviceModel) {
        self.protocol?.devicesCellSelect(model: model, clickType: 0)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
        cell.clipsToBounds = true
        
        let count = self.bluetoothTableView.numberOfRows(inSection: indexPath.section)
        if indexPath.row == count {
            cell.contentView.layer.mask = nil
            return
        }
        
        let bounds = cell.contentView.bounds
        
        var rectCorner: UIRectCorner = UIRectCorner.allCorners
        if count > 1 {
            if indexPath.row == 0 {
                rectCorner = [.topLeft, .topRight]
            } else if indexPath.row == count - 1 {
                rectCorner = [.bottomLeft, .bottomRight]
            } else {
                rectCorner = []
            }
        } else {
            rectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        }
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 10.auto(), height: 10.auto()))
        
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = cell.contentView.bounds
        maskLayer.path = path.cgPath
        cell.contentView.layer.mask = maskLayer
        
        cell.contentView.layer.shadowColor = UIColor.white.cgColor
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.contentView.layer.shadowOpacity = 1
        cell.contentView.layer.shadowRadius = 7.5
        
        if tableCellNeedAnimation {
            tableCellNeedAnimation = !tableCellNeedAnimation
            if let lastIndexPath = tableView.indexPathsForVisibleRows?.last {
                if lastIndexPath.row <= indexPath.row {
                    cell.center.y = cell.center.y - cell.frame.height
                    cell.alpha = 0
                    UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
                        cell.center.y = cell.center.y + cell.frame.height
                        cell.alpha = 1
                    }, completion: nil)
                }
            }
        }
    }
}

extension A4xBindFindDeviceView {
    
    
    private func startTimer(isContinue: Bool) {
        if !isContinue {
            loadingTimerCount = 0
        }
        
        A4xGCDTimer.shared.scheduledDispatchTimer(withName: "BLE_SEARCH_TIMER", timeInterval: 1, queue: DispatchQueue.main, repeats: true) { [weak self] in
            self?.loadingTime()
        }
    }
    
    
    private func stopTimer() {
        A4xGCDTimer.shared.destoryTimer(withName: "BLE_SEARCH_TIMER")
    }
    
    
    @objc private func loadingTime() {
        
        if loadingTimerCount <= searchTimeoutCount {
            loadingTimerCount += 1
            return
        }
        
        if loadingTimerCount == searchTimeoutCount + 1 {
            self.protocol?.searchTimeout()
            self.noFindDeviceAnimation(duration: 0.8)
        }
        
        
        stopTimer()
    }
    
    public func checkSearchTimeOut() -> Bool {
        return loadingTimerCount > searchTimeoutCount
    }
}

