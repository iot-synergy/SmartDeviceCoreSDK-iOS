import UIKit
import SmartDeviceCoreSDK
import BaseUI

enum A4xFullLiveDeviceMenuType : Int {
    case track      = 10011
    case alert      = 10012
    case location   = 10013
    case light      = 10014
    case setting    = 10015
    
    static func allCase() -> [A4xFullLiveDeviceMenuType] {
        return [.track, .location,.alert ,.light ,.setting]
    }
    
    var stringValue : String {
        switch self {
        case .alert:
            return A4xBaseManager.shared.getLocalString(key: "alert_buttom")
        case .track:
            return A4xBaseManager.shared.getLocalString(key: "motion_tracking")
        case .location:
            return A4xBaseManager.shared.getLocalString(key: "preset_location")
        case .light:
            return A4xBaseManager.shared.getLocalString(key: "white_light")
        case .setting:
            let tempString = A4xBaseManager.shared.getLocalString(key: "device_type_unknown")
            return A4xBaseManager.shared.getLocalString(key: "device_info", param: [tempString])
        }
    }
    
    var noramilImage : UIImage? {
        switch self {
        case .track:
            return A4xLiveUIResource.UIImage(named: "device_live_move_follow_disable")?.rtlImage()
        case .alert:
            return A4xLiveUIResource.UIImage(named: "video_live_warning")?.rtlImage()
        case .location:
            return A4xLiveUIResource.UIImage(named: "home_device_live_edit_modle")?.rtlImage()
        case .light:
            return A4xLiveUIResource.UIImage(named: "device_light_close")?.rtlImage()
        case .setting:
            return A4xLiveUIResource.UIImage(named: "live_video_setting")?.rtlImage()
        }
    }
    
    var selectImage : UIImage? {
        switch self {
        case .track:
            return A4xLiveUIResource.UIImage(named: "device_live_move_fllow")?.rtlImage()
        case .alert:
            return A4xLiveUIResource.UIImage(named: "video_live_warning")?.rtlImage()
        case .location:
            return A4xLiveUIResource.UIImage(named: "home_device_live_edit_modle")?.rtlImage()
        case .light:
            return A4xLiveUIResource.UIImage(named: "device_light_open")?.rtlImage()
        case .setting:
            return A4xLiveUIResource.UIImage(named: "live_video_setting")?.rtlImage()
        }
    }
}


protocol A4xFullLiveVideoMoreMenuViewProtocol : class {
    func deviceMenuClick(type : A4xFullLiveDeviceMenuType , compleAction :@escaping (Bool)->Void)
}

class A4xFullLiveVideoMoreMenuView: UIControl {
    var quitBlock: (() -> Void)?
    var rotateEnable : Bool = true{
        didSet{
            updateInfo()
        }
    }
    
    var supportMotionTrack: Bool = true {
        didSet {
            updateInfo()
        }
    }
    
    var isHuman : Bool = true {
        didSet{
            updateItemInfo(type: A4xFullLiveDeviceMenuType.track)
        }
    }
    var lightEnable : Bool = true{
        didSet{
            updateItemInfo(type: A4xFullLiveDeviceMenuType.light)
        }
    }
    var lightSupper : Bool = true {
        didSet{
            updateInfo()
        }
    }
    
    var fllowEnable :Bool = true {
        didSet {
            updateInfo()
        }
    }
    var isTrackingOpen : Bool = true{
        didSet{
            updateItemInfo(type: A4xFullLiveDeviceMenuType.track)
        }
    }
    
    var supperAlert : Bool = true {
        didSet {
            updateInfo()
        }
    }

    weak var `protocol` : A4xFullLiveVideoMoreMenuViewProtocol? = nil
    
    init(frame: CGRect = .zero, supperAlert : Bool, rotateEnable: Bool, supportMotionTrack: Bool, lightSupper: Bool, fllowEnable: Bool) {
        super.init(frame: frame)
        self.quitBtn.isHidden = false
        //self.collectView.isHidden = false
        self.backgroundColor = UIColor.hex(0x1D1C1C, alpha: 0.8)
        self.addTarget(self, action: #selector(emtry), for: UIControl.Event.touchUpInside)
        self.isUserInteractionEnabled = true
        updateInfo()
    }
    
    func updateFrame(){
        updateInfo()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func emtry() {
        
    }
    
    private lazy var quitBtn: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_quitBtn"
        temp.setImage(A4xLiveUIResource.UIImage(named: "live_video_more_menu_quit")?.rtlImage(), for: .normal)
        temp.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        self.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.top.equalTo(10.auto())
            make.trailing.equalTo(self.snp.trailing).offset(-20.auto())
            make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
        }
        return temp
    }()
    
    @objc private func closeButtonAction() {
        self.quitBlock?()
    }
    
    func updateInfo(){
        
        var showAllCase : [A4xFullLiveDeviceMenuType] = []
        if supportMotionTrack {
            if fllowEnable {
                showAllCase.append(.track)
            }
        }
        
        if rotateEnable {
            showAllCase.append(.location)
        }

        if supperAlert {
            showAllCase.append(.alert)
        }
        
        if lightSupper {
            showAllCase.append(.light)
        }
        showAllCase.append(.setting)
        removeAllSubViews()
        for i in 0..<showAllCase.count {
            let menu = showAllCase.getIndex(i)
            self.loadItems(i: i, type: menu ?? .light , isShow: true)
            self.updateItemInfo(type: menu ?? .light)
        }
    }
    
    func updateItemInfo(type : A4xFullLiveDeviceMenuType){
        let itemButton = self.itemImageView(type: type)
        itemButton?.setImage(type.noramilImage, for: .normal)
        itemButton?.setImage(type.selectImage, for: .selected)
        let titleV = self.itemTitleView(type: type)
        titleV?.text = type.stringValue
        
        
        switch type {
        case .track:
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "device_live_move_follow_disable")?.rtlImage(), for: .normal)
            itemButton?.setImage(A4xLiveUIResource.UIImage(named: "device_live_move_fllow")?.rtlImage(), for: .selected)
            titleV?.text = A4xBaseManager.shared.getLocalString(key: "motion_tracking")
            itemButton?.isSelected = isTrackingOpen
        case .location:
            break
        case .light:
            itemButton?.isSelected = lightEnable
        default:
            break
        }
        guard let itemv = itemButton as? A4xBaseLoadingButton else {
            return
        }
        itemv.isLoading = false
    }
    
    func removeAllSubViews() {
        // 移除子视图 - 重新绘制
        _ = self.subviews.map {
            $0.removeFromSuperview()
        }
        
        self.quitBtn = UIButton()
        self.quitBtn.accessibilityIdentifier = "A4xLiveUIKit_quitBtn"
        self.quitBtn.setImage(A4xLiveUIResource.UIImage(named: "live_video_more_menu_quit")?.rtlImage(), for: .normal)
        self.quitBtn.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        self.addSubview(self.quitBtn)
        self.quitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(10.auto())
            make.trailing.equalTo(self.snp.trailing).offset(-20.auto())
            make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
        }
    }
    
    func loadItems(i: Int, type : A4xFullLiveDeviceMenuType , isShow : Bool){
        
        // 计算行列
        let line = i / 2 // [0,...]
        let row = i % 2 // 0 1
        
        // 背景的contentView
        var contentView : UIControl = UIControl()
        // 设置tag
        contentView.tag = type.rawValue
        contentView.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(row * (Int(self.width) / 2))
            make.width.equalTo(self.width/2)
            make.top.equalTo(self.quitBtn.snp.bottom).offset(10 + 90 * line)
            make.height.equalTo(80)
        }
        
        var contentImageView = A4xBaseLoadingButton()
        contentImageView.tag = 1001
        contentImageView.isUserInteractionEnabled = false
        contentImageView.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        contentImageView.contentMode = .scaleAspectFit
        contentView.addSubview(contentImageView)
        contentImageView.snp.makeConstraints { make in
            make.centerX.top.equalTo(contentView)
            make.height.width.equalTo(60)
        }
        
        var contentTitleView : UILabel = UILabel()
        contentTitleView.tag = 1000
        contentTitleView.textColor = UIColor.white
        contentTitleView.numberOfLines = 0
        contentTitleView.font = ADTheme.B2
        contentTitleView.textAlignment = .center
        contentView.addSubview(contentTitleView)
        contentTitleView.snp.makeConstraints { make in
            make.leading.width.bottom.equalTo(contentView)
            make.height.equalTo(20)
        }
        
    }
    
    @objc
    func buttonAction(sender : UIControl) {
        var checkEnum = A4xFullLiveDeviceMenuType(rawValue: sender.tag)
        if checkEnum == nil {
            checkEnum = A4xFullLiveDeviceMenuType(rawValue: sender.superview?.tag ?? 10) ?? .alert
        }
        guard let clickEnum = checkEnum else {
            return
        }
        
        guard let itemv = self.itemImageView(type: clickEnum) as? A4xBaseLoadingButton else {
            return
        }
        itemv.isLoading = true
        self.protocol?.deviceMenuClick(type: clickEnum, compleAction: { [weak itemv](f) in
            itemv?.isLoading = false
        })
    }
    
    func loadItemBaseInfo(type : A4xFullLiveDeviceMenuType){
        let itemButton = self.itemImageView(type: type)
        itemButton?.setImage(type.noramilImage, for: .normal)
        itemButton?.setImage(type.selectImage, for: .selected)
        
        let infoLable = self.itemTitleView(type: type)
        infoLable?.text = type.stringValue
    }
    
    func itemImageView(type : A4xFullLiveDeviceMenuType) -> UIButton? {
        let itemGroupV : UIControl? = self.viewWithTag(type.rawValue) as? UIControl
        let itemImageV : UIButton?  = itemGroupV?.viewWithTag(1001) as? UIButton
    
        return itemImageV
    }
    
    func itemTitleView(type : A4xFullLiveDeviceMenuType) -> UILabel? {
        let itemGroupV : UIControl? = self.viewWithTag(type.rawValue) as? UIControl
        let itemTitleV : UILabel?   = itemGroupV?.viewWithTag(1000) as? UILabel
        return itemTitleV
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hidView = super.hitTest(point, with: event)
        if hidView == self {
            return nil
        }
        return hidView
    }
}
