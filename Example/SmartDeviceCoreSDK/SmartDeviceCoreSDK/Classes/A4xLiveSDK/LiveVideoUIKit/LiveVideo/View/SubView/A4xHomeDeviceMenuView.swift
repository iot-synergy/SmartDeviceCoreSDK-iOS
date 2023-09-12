//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xTestLable : UILabel {
    override var intrinsicContentSize: CGSize {
        return super.intrinsicContentSize
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return super.sizeThatFits(size)
    }
    
    var _frame: CGRect = .zero
    override var frame: CGRect {
        set {
            var resultFrame = newValue
            if newValue.width > 0 {
                let width = newValue.width
                let height = self.sizeThatFits(CGSize(width: width, height: 100 )).height
                resultFrame = CGRect(x: newValue.minX, y: newValue.minY, width: width, height: height)
            }
            
            super.frame = resultFrame
        }
        get {
           return _frame
        }
    }
    
}

public enum LiveMenuActionType: Int {
    case sound      = 10000
    case alert      = 10001
    case magicPix   = 10002
    case track      = 10003
    case location   = 10004
    case light      = 10015
    case more       = 10016
    
    static func allCase() -> [LiveMenuActionType] {
        return [.sound, .alert, .magicPix, .track, .more, .location, .light]
    }
    
    var stringValue: String {
        switch self {
        case .sound:
            return A4xBaseManager.shared.getLocalString(key: "sound")
        case .alert:
            return A4xBaseManager.shared.getLocalString(key: "alert_buttom")
        case .magicPix:
            return "MagicPix"
        case .track:
            return A4xBaseManager.shared.getLocalString(key: "motion_tracking")
        case .location:
            return A4xBaseManager.shared.getLocalString(key: "preset_location")
        case .light:
            return A4xBaseManager.shared.getLocalString(key: "white_light")
        case .more:
            return A4xBaseManager.shared.getLocalString(key: "more")
        }
    }
}

protocol A4xHomeDeviceMenuViewProtocol: class {
   
    
    func deviceVoiceIsOn() -> Bool
    func deviceSupportMotionTrack() -> Bool
    func deviceRotateEnable() -> Bool
    func deviceMoveIsHuman() -> Bool
    func deviceIsAdmin() -> Bool
    func deviceLightEnable() -> Bool
    func deviceLightisOn() -> Bool
    func deviceIsShowMore() -> Bool
    func deviceIsAlerting() -> Bool
    func devcieSupperAlert() -> Bool
    func deviceIsTrackingOpen() -> Bool
    func deviceSupportVoiceEffect() -> Bool
    //设置声音按钮是否置灰
    func deviceIsLiveAudioToggleOn() -> Bool
    
    func deviceMagicPixEnable() -> Bool
    func deviceMagicPixProcessState() -> Int
    func deviceSupportMagicPix() -> Bool
    
    
    func deviceMenuClick(type: LiveMenuActionType, comple :@escaping (Bool)->Void)
}

class A4xHomeDeviceMenuView: UIView {
    weak var `protocol` : A4xHomeDeviceMenuViewProtocol?
    
    let gifManager = A4xBaseGifManager(memoryLimit: 60)


    var dataDic: [String: Any]? {
        didSet {
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isAlerting : Bool = false
    
    fileprivate static let maxMenuCount : Int = 4
    
    public static var menuHeight : CGFloat = 0
    
    private var showCase: [LiveMenuActionType]?
    
    
    private var maxItemsHeight: [CGFloat] = [0.0, 0.0, 0.0, 0.0]
    
    
    
    func initMenuUI() {
        let rotateEnable : Bool = self.protocol?.deviceRotateEnable() ?? false
        let supportMotionTrack: Bool = self.protocol?.deviceSupportMotionTrack() ?? false
        let lightEnable  : Bool = self.protocol?.deviceLightEnable() ?? false
        let showMore     : Bool = self.protocol?.deviceIsShowMore() ?? false
        let isAdmin      : Bool = self.protocol?.deviceIsAdmin() ?? false
        let alertSupper  : Bool = self.protocol?.devcieSupperAlert() ?? false
        let supportVoiceEffect: Bool = self.protocol?.deviceSupportVoiceEffect() ?? false
        let supportMagicPix: Bool = self.protocol?.deviceSupportMagicPix() ?? false
        
        var needShowCase : [LiveMenuActionType] = []
        needShowCase.append(.sound)
        
        if alertSupper {
            needShowCase.append(.alert)
        }
        
        if supportMagicPix {
            needShowCase.append(.magicPix)
        }
        
        if supportMotionTrack {
            if isAdmin {
                needShowCase.append(.track)
            }
        }
        
        if rotateEnable {
            needShowCase.append(.location)
        }
        
        if lightEnable {
            needShowCase.append(.light)
        }
        

        if needShowCase.count > A4xHomeDeviceMenuView.maxMenuCount {
            if showMore {
                needShowCase.insert(.more, at: A4xHomeDeviceMenuView.maxMenuCount - 1)
            } else { 
                
                needShowCase = Array(needShowCase[0..<3]) as [LiveMenuActionType]
                needShowCase.append(.more)
            }
        }

        let group = DispatchGroup()
        group.enter()
        
        //移除所有子视图
        self.removeAllSubViews(group: group)
        
        
        maxItemsHeight = [0.0, 0.0, 0.0, 0.0]
        
        
        showCase = needShowCase
        
        
        for i in 0..<needShowCase.count {
            autoreleasepool {
                
                self.loadItems(menuType: needShowCase[i], index: i, totalCount: needShowCase.count, isShow: true)
                
                
                self.updateItemInfo(type: needShowCase[i])
            }
        }
    }
    
    
    func updateUIState(type: LiveMenuActionType, param: [String : Any] = [:]) {
        
        self.updateItemInfo(type: type)
    }
    
    func loadItems(menuType: LiveMenuActionType, index: Int, totalCount: Int, isShow: Bool) {
        
        var itemGroupV : UIControl?     = self.viewWithTag(menuType.rawValue) as? UIControl
        
        var itemTitleV : UILabel?       = itemGroupV?.viewWithTag(1000) as? UILabel
        var itemImageV : UIButton?      = itemGroupV?.viewWithTag(1001) as? UIButton
        
        if isShow {
            
            let columnCount = min(A4xHomeDeviceMenuView.maxMenuCount, totalCount)
            
            let itemWidth = ((UIApplication.shared.keyWindow?.width ?? 375) - 16.auto()) / CGFloat(columnCount)
            
            var titleStr = menuType.stringValue
            
            
            
            let titleStrHeight = titleStr.textHeightFromTextString(text: titleStr, textWidth: itemWidth - 4.auto(), fontSize: 13.auto(), isBold: false)
            let itemHeight = 44.auto() + 8.auto() + titleStrHeight + 2.auto()
            
            
            
            maxItemsHeight[index / A4xHomeDeviceMenuView.maxMenuCount] = max(itemHeight, maxItemsHeight[index / A4xHomeDeviceMenuView.maxMenuCount])
            
            itemGroupV = UIControl()
            itemGroupV?.accessibilityIdentifier = "A4xLiveSDK_itemGroupV_\(menuType.rawValue)"
            itemGroupV?.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
            itemGroupV?.tag = menuType.rawValue
            itemGroupV?.isHidden = !isShow
            //itemGroupV?.backgroundColor = index % 2 == 0 ? .brown : .green
            self.addSubview(itemGroupV ?? UIControl())
            itemGroupV!.snp.makeConstraints { make in
                
                var nextHeight = maxItemsHeight[0]
                if index / A4xHomeDeviceMenuView.maxMenuCount > 0 {
                    nextHeight = maxItemsHeight[index / A4xHomeDeviceMenuView.maxMenuCount - 1]
                }
                make.top.equalTo(CGFloat(index / columnCount) * (nextHeight + 16.auto()))
                make.leading.equalTo(CGFloat(index % columnCount) * itemWidth)
                make.width.equalTo(itemWidth)
                make.height.equalTo(itemHeight)
            }
            
            itemImageV = A4xBaseLoadingButton()
            itemImageV?.backgroundColor = UIColor.hex(0xF6F6F6)
            //itemImageV?.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            itemImageV?.tag = 1001
            itemImageV?.isUserInteractionEnabled = false
            itemImageV?.layer.cornerRadius = 22.auto()
            itemImageV?.clipsToBounds = true
            itemImageV?.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
            itemImageV?.contentMode = .scaleAspectFit
            itemGroupV?.addSubview(itemImageV!)
            
            resetItemsInfo(type: menuType)
            itemImageV!.snp.makeConstraints { make in
                make.top.equalTo(0)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 44.auto(), height: 44.auto()))
            }
            
            itemTitleV = A4xTestLable()
            itemTitleV?.tag = 1000
            //itemTitleV?.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
            itemTitleV?.textColor = ADTheme.C1
            itemTitleV?.numberOfLines = 0
            //itemTitleV?.lineBreakMode = .byWordWrapping
            itemTitleV?.font = ADTheme.B2
            itemTitleV?.textAlignment = .center
            itemTitleV?.text = titleStr
            //itemTitleV?.backgroundColor = .lightText
            itemGroupV?.addSubview(itemTitleV!)
            
            itemTitleV!.snp.makeConstraints { make in
                make.top.equalTo(itemImageV!.snp.bottom).offset(8.auto())
                make.centerX.equalToSuperview()
                make.width.equalTo(itemWidth - 4.auto())
            }
        }
        
    }
    
    public func getMenuHeight(isMore: Bool) -> CGFloat {
        if isMore {
            var lineCount: Int = 0
            if (showCase?.count ?? 0) > A4xHomeDeviceMenuView.maxMenuCount {
                lineCount = (showCase?.count ?? 0) / A4xHomeDeviceMenuView.maxMenuCount
            }
            return maxItemsHeight.reduce(0, +) + CGFloat(lineCount * 16.auto())
        } else {
            return maxItemsHeight[0]
        }
    }
    
    private func isRTL() -> Bool {
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            return true
        }
        return false
    }
    
    
    @objc func buttonAction(sender : UIControl) {
        var checkEnum = LiveMenuActionType(rawValue: sender.tag)
        if checkEnum == nil {
            checkEnum = LiveMenuActionType(rawValue: sender.superview?.tag ?? 10) ?? .sound
        }
        
        guard let clickEnum = checkEnum else {
            return
        }
        
        guard let itemv = self.itemImageView(type: clickEnum) as? A4xBaseLoadingButton else {
            return
        }
        
        itemv.isLoading = true
        self.protocol?.deviceMenuClick(type: clickEnum, comple: { [weak itemv , weak self] (isScuess) in
            itemv?.isLoading = false
            if isScuess {
                if case .alert = clickEnum {
                    self?.isAlerting = true
                    self?.updateItemInfo(type: .alert)
                    DispatchQueue.main.a4xAfter(5) {
                        self?.isAlerting = false
                        self?.updateItemInfo(type: .alert)
                    }
                }
            }
            
        })

    }
    
    func itemEnable(type : LiveMenuActionType) -> Bool {
        return self.itemImageView(type: type)?.isSelected ?? false
    }
    
    func itemImageView(type : LiveMenuActionType) -> UIButton? {
        let itemGroupV : UIControl? = self.viewWithTag(type.rawValue) as? UIControl
        let itemImageV : UIButton?  = itemGroupV?.viewWithTag(1001) as? UIButton
        return itemImageV
    }
    
    func itemTitleView(type : LiveMenuActionType) -> UILabel? {
        let itemGroupV : UIControl? = self.viewWithTag(type.rawValue) as? UIControl
        let itemTitleV : UILabel?   = itemGroupV?.viewWithTag(1000) as? UILabel
        return itemTitleV
    }
    
    
    func updateItemInfo(type: LiveMenuActionType) {
        let itemButton = self.itemImageView(type: type)
        let titleV = self.itemTitleView(type: type)
        titleV?.text = type.stringValue
        
        switch type {
        case .sound:
            let soundEnable = self.protocol?.deviceVoiceIsOn() ?? false
            
       
            let volumeButtonStatus = self.protocol?.deviceIsLiveAudioToggleOn() ?? true
            if volumeButtonStatus {
                
                itemButton?.isSelected = soundEnable
                itemButton?.alpha = 1.0
            } else {
                
                itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_voice_disable"), for: .normal)
                itemButton?.alpha = 0.5
            }
            break
        case .alert:
            if self.isAlerting {
                itemButton?.backgroundColor = ADTheme.E1
                self.showAlertGif(v: itemButton!)
            } else {
                gifManager.clear()
                itemButton?.backgroundColor = UIColor.hex(0xF6F6F6)
                itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_alert"), for: .normal)
                if let tagview : UIImageView = itemButton?.viewWithTag(666) as? UIImageView {
                    tagview.stopAnimatingGif()
                    tagview.removeFromSuperview()
                }
            }
            break
        case .magicPix:
            let magicPixEnable = self.protocol?.deviceMagicPixEnable() ?? false
            itemButton?.isSelected = magicPixEnable
            let magicPixProcessState = self.protocol?.deviceMagicPixProcessState() ?? 0
            itemButton?.backgroundColor = (magicPixProcessState > 0) ? UIColor.hex(0xF5E449) : UIColor.hex(0xF6F6F6)
            break
        case .track:
            
            itemButton?.setImage(bundleImageFromImageName("home_device_auto_move_default"), for: .disabled)
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_auto_move_fllow"), for: .selected)
            titleV?.text = A4xBaseManager.shared.getLocalString(key: "motion_tracking")  
    
            let isTrackingOpen = self.protocol?.deviceIsTrackingOpen() ?? false
            itemButton?.isSelected = isTrackingOpen
            break
        case .location:
            break
        case .light:
            let lightOn = self.protocol?.deviceLightisOn() ?? false
            itemButton?.isSelected = lightOn
            break
        case .more:
            let showMore = self.protocol?.deviceIsShowMore() ?? false
            if (showMore) {
                itemButton?.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi)
            } else {
                itemButton?.transform = CGAffineTransform.identity
            }
            break
        
        }
    }
    
    
    private func rotateArrow(_ btn: UIButton, open: Bool) {
        var rotate = Double.pi
        if !open {
            rotate = -Double.pi
        }
        UIView.animate(withDuration: 0.3, animations: { () -> () in
            btn.transform = btn.transform.rotated(by: CGFloat(rotate))
        })
    }
    
    func resetItemsInfo(type: LiveMenuActionType) {
        let itemButton = self.itemImageView(type: type)

        switch type {
        case .sound:
            
            let volumeButtonStatus = self.protocol?.deviceIsLiveAudioToggleOn() ?? true
            if volumeButtonStatus {
                itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_voice_disable"), for: .normal)
                itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_voice_enable"), for: .selected)
            } else {
                
                itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_voice_disable"), for: .normal)
                itemButton?.alpha = 0.5
            }
        case .alert:
            itemButton?.backgroundColor = ADTheme.E1
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_alert"), for: .normal)
        case .magicPix:
            itemButton?.backgroundColor = UIColor.hex(0xF6F6F6)
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_magic_pix_off"), for: .normal)
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_magic_pix_auto"), for: .selected)
            break
        case .track:
            itemButton?.setImage(bundleImageFromImageName("home_device_auto_move_default"), for: .normal)
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_auto_move_fllow"), for: .selected)
        case .location:
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_location"), for: .disabled)
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_location"), for: .normal)
        case .light:
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_white_close"), for: .normal)
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_white_open"), for: .selected)
        case .more:
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_more"), for: .normal)
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "home_device_more"), for: .selected)
            
        
        }
    }
    
    func showAlertGif(v: UIButton) {
        let view = UIImageView()
        view.frame = v.imageView?.frame ?? v.bounds
        v.addSubview(view)
        view.tag = 6666
        v.setImage(nil, for: .normal)

        let gifImage = A4xLiveUIResource.UIImage(gifName: "alert_device.gif")
        view.setGifImage(gifImage, manager: gifManager ,loopCount: 3)
    }
    
    
    static func height(forWidth: CGFloat, alertSupper: Bool, supportMagicPix: Bool, rotateEnable rotate: Bool, supportMotionTrack: Bool, whiteLight light: Bool, supportVoiceEffect: Bool, showMore: Bool) -> CGFloat {
    
        var needShowCase: [LiveMenuActionType] = []
        needShowCase.append(.sound)
        
        if alertSupper {
            needShowCase.append(.alert)
        }
        
        if supportMagicPix {
            needShowCase.append(.magicPix)
        }
        
        if supportMotionTrack {
            needShowCase.append(.track)
        }
        
        if rotate {
            needShowCase.append(.location)
        }
        
        if light {
            needShowCase.append(.light)
        }
        
        
        
        var allCase = LiveMenuActionType.allCase()
        if needShowCase.count > maxMenuCount {
            allCase.insert(.more, at: maxMenuCount - 1)
            if showMore {
                needShowCase.insert(.more, at: maxMenuCount - 1)
            } else {
                needShowCase = Array(needShowCase[0..<3]) as [LiveMenuActionType]
                needShowCase.append(.more)
            }
        }
        
        let session: CGFloat = 16.auto()
        let imageHeight: CGFloat = 44.auto()
        let lableTop: CGFloat = 9.auto()
        
        var tmpMenuHeight: CGFloat = 0
        var maxOneLineHeight: CGFloat = 0
        
        let columnCount = min(A4xHomeDeviceMenuView.maxMenuCount, needShowCase.count)
        let itemWidth = forWidth / CGFloat(columnCount)
        
        for index in 0..<needShowCase.count {
            
            let titleStr = needShowCase[index].stringValue
            
            let titleStrHeight = titleStr.textHeightFromTextString(text: titleStr, textWidth: itemWidth - 4.auto(), fontSize: 13, isBold: false)
            
            maxOneLineHeight = max(titleStrHeight, maxOneLineHeight)
            
            
            if index % A4xHomeDeviceMenuView.maxMenuCount == 0 && index > 0 {
                if maxOneLineHeight > 0 {
                    tmpMenuHeight += (maxOneLineHeight + session + imageHeight + lableTop + maxOneLineHeight)
                }
                //重置0，计算下一行的最大行高
                maxOneLineHeight = 0
            }
        }
        
        
        
        if maxOneLineHeight != 0 {
            tmpMenuHeight += (maxOneLineHeight + imageHeight + lableTop + maxOneLineHeight)
        }
        
        menuHeight = tmpMenuHeight
        return tmpMenuHeight
    }
}
