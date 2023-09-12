import UIKit
import SmartDeviceCoreSDK
import Resolver
import A4xLiveVideoUIInterface
import A4xDeviceSettingInterface
import BindInterface
import Resolver
import BaseUI

public class A4xDevicesSettingViewController: A4xBaseViewController {
    //var deviceId : String?
    public var deviceModel: DeviceBean?
    var cellInfos : [[A4xDeviceSettingInfoEnum]]?
    var cellHeight: CGFloat?
    var isWifiSignalWeak: Bool? = false
    
    var dataSource : DeviceBean? {
        didSet {
            
        }
    }
    
    
    let group = DispatchGroup()
    
    let queue = DispatchQueue.global()
    
    override init() {
        super.init()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public init(deviceModel: DeviceBean, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.deviceModel = deviceModel
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        self.dataSource = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceModel?.serialNumber ?? "", modeType: deviceModel?.apModeType ?? .WiFi)
        self.loadNavtion()
        
        self.tableView.isHidden = false
        
        self.reloadData()

    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        weak var weakSelf = self
        
        var controlModel = A4xDeviceControlViewModel(deviceModel: weakSelf?.dataSource ?? DeviceBean())
                
        self.dataSource = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceModel?.serialNumber ?? "", modeType: deviceModel?.apModeType ?? .WiFi)
        
        controlModel.loadNetData(device: weakSelf?.dataSource, comple: { (error) in
            weakSelf?.reloadData()
        })
        
        self.tableView.mj_header?.beginRefreshing {
            
            A4xUserDataHandle.Handle?.videoHelper.keepAlive(deviceId: self.deviceModel?.serialNumber ?? "" ) { [weak self ](state, flag) in
                switch state {
                case .start:
                    break
                case  .done(_):
                    
                    self?.loadData(showLoading: false)
                    break
                case let .error(error):
                    self?.view.makeToast(error)
                    self?.tableView.mj_header?.endRefreshing()
                }
            }
        }
        
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    private func loadData(showLoading : Bool = true) {
        queue.async(group: group, execute: {
            self.group.enter()
            self.getSelectSingleDevice(showLoading: showLoading)
        })
        
        
        queue.async(group: group, execute: {
            self.group.enter()
            self.getUserConfig()
        })
    
        group.notify(queue: queue) {
            DispatchQueue.main.async {
                
                self.saveDataToLocal()
                self.reloadData()
                self.tableView.mj_header?.endRefreshing()
            }
        }
        
    }
    
    
    private func saveDataToLocal() {
        A4xUserDataHandle.Handle?.updateDevice(device: self.dataSource)
    }
    
    //
    @objc private func reloadData() {
        let hasVip = A4xDeviceSettingManager.shared.deviceIsVip(deviceId: self.deviceModel?.serialNumber ?? "")
        let offline = self.dataSource?.online ?? 0
        self.cellInfos = A4xDeviceSettingInfoEnum.managerCases(vip: hasVip,
                                                               offline: offline == 0,
                                                               deviceModel: self.dataSource)
        
        
        
        self.isWifiSignalWeak = (self.dataSource?.wifiStrength() ?? .none) == .weak //|| (self.dataSource?.wifiStrength() ?? A4xWiFiStyle.none) == .none
        self.tableView.reloadData()
    }
    
    //
    private func loadNavtion() {
        weak var weakSelf = self
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "device_settings", param: [tempString]).capitalized

        var leftItem = A4xBaseNavItem()
        leftItem.normalImg =  "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
    }
    
    
    private lazy var tableView : UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        temp.delegate = self
        temp.dataSource = self
        temp.backgroundColor = UIColor.clear
        temp.tableFooterView = UIView()
        temp.accessibilityIdentifier = "tableView"
        temp.separatorInset = .zero
        temp.separatorStyle = .none
        temp.separatorColor = UIColor.clear
        temp.estimatedRowHeight = 80;
        temp.rowHeight=UITableView.automaticDimension;
        temp.showsVerticalScrollIndicator = false
        temp.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20.auto(), right: 0)
        weak var weakSelf = self
        temp.mj_header = A4xMJRefreshHeader {
            weakSelf?.tableView.mj_header?.endRefreshing()
        }
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom)
            make.width.equalTo(self.view.snp.width).offset(-32.auto())
            make.centerX.equalTo(self.view.snp.centerX)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        
        return temp
    }()
}

extension A4xDevicesSettingViewController {
    
    private func getSelectSingleDevice(showLoading: Bool = true) {
        if showLoading {
            self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (r) in }
        }
        
        weak var weakSelf = self
        
        DeviceManageUtil.getDeviceSettingInfo(deviceId: deviceModel?.serialNumber ?? "") { (code, msg, model) in
            
            if showLoading {
                weakSelf?.view.hideToastActivity()
            } else {
                weakSelf?.tableView.mj_header?.endRefreshing()
            }
            
            self.group.leave()
            
            if code == 0 {
                /* 和大列表区别主要是更新以下参数*/
                weakSelf?.dataSource?.awake = model?.awake ?? 1
                weakSelf?.dataSource?.signalStrength = model?.signalStrength ?? 0
                
                weakSelf?.dataSource?.sdCard = model?.sdCard
                weakSelf?.dataSource?.packagePush = model?.packagePush
                
                weakSelf?.dataSource?.antiflickerSupport = model?.antiflickerSupport
                weakSelf?.dataSource?.displayGitSha = model?.displayGitSha
                weakSelf?.dataSource?.dormancyPlanSwitch = model?.dormancyPlanSwitch
                
                
                weakSelf?.dataSource?.deviceStatus = model?.deviceStatus ?? 0
                weakSelf?.dataSource?.online = model?.online ?? 1
                weakSelf?.dataSource?.upgradeStatus = model?.upgradeStatus ?? 0
                weakSelf?.dataSource?.batteryLevel = model?.batteryLevel ?? 0
                weakSelf?.dataSource?.signalStrength = model?.signalStrength ?? 0
                weakSelf?.dataSource?.isCharging = model?.isCharging ?? 0
                weakSelf?.dataSource?.firmwareId = model?.firmwareId
                weakSelf?.dataSource?.newestFirmwareId = model?.newestFirmwareId
                weakSelf?.dataSource?.personDetect = model?.personDetect
                weakSelf?.dataSource?.pushIgnored = model?.pushIgnored
                weakSelf?.dataSource?.deviceDormancyMessage = model?.deviceDormancyMessage
                weakSelf?.dataSource?.resolution = model?.resolution
                weakSelf?.dataSource?.deviceSupport?.supportLiveAudioToggle = model?.deviceSupport?.supportLiveAudioToggle ?? NULL_INT_SUPPORT_STATUS
                weakSelf?.dataSource?.deviceSupport?.supportRecordingAudioToggle = model?.deviceSupport?.supportRecordingAudioToggle ?? NULL_INT_SUPPORT_STATUS
                weakSelf?.dataSource?.deviceSupport?.supportLiveSpeakerVolume = model?.deviceSupport?.supportLiveSpeakerVolume ?? NULL_INT_SUPPORT_STATUS
                weakSelf?.dataSource?.liveAudioToggleOn = model?.liveAudioToggleOn
                
                weakSelf?.dataSource?.deviceSupport?.supportMechanicalDingDong = model?.deviceSupport?.supportMechanicalDingDong ?? NULL_BOOL
                
                weakSelf?.dataSource?.deviceSupport?.supportChargeAutoPowerOn = model?.deviceSupport?.supportChargeAutoPowerOn ?? NULL_INT_SUPPORT_STATUS
                
                weakSelf?.dataSource?.otaAutoUpgrade = model?.otaAutoUpgrade
                weakSelf?.dataSource?.deviceInVip = model?.deviceInVip ?? false
                
                weakSelf?.dataSource?.deviceSupport?.supportRotateCalibration = model?.deviceSupport?.supportRotateCalibration ?? NULL_BOOL
            } else {
                weakSelf?.view.makeToast(A4xAppErrorConfig(code: code).message())
            }
        }
    }
    
    
    private func getUserConfig() {
        loadDefaultData()
    }

    
    
    private func loadDefaultData() {
        weak var weakSelf = self
        guard let deviceId = self.deviceModel?.serialNumber else {
            self.group.leave()
            return
        }
        
        
        if !(self.dataSource?.isAdmin() ?? true) {
            self.group.leave()
            return
        }
        
        DeviceManageCore.getInstance().getDeviceSettingConfig(serialNumber: self.deviceModel?.serialNumber ?? "") { code, message, model in
            //数据模型更新处理
            weakSelf?.dataSource?.needMotion  = model?.needMotion
            weakSelf?.dataSource?.motionSensitivity = model?.motionSensitivity
            weakSelf?.dataSource?.motionSensitivityOptionList = model?.motionSensitivityOptionList
            
            weakSelf?.dataSource?.needNightVision = model?.needNightVision
            weakSelf?.dataSource?.nightVisionSensitivity = model?.nightVisionSensitivity
            weakSelf?.dataSource?.nightThresholdLevel = model?.nightThresholdLevel
            
            weakSelf?.dataSource?.needAlarm = model?.needAlarm
            weakSelf?.dataSource?.alarmSeconds = model?.alarmSeconds
            
            weakSelf?.dataSource?.needVideo = model?.needVideo
            weakSelf?.dataSource?.videoSeconds = model?.videoSeconds
            
            weakSelf?.dataSource?.deviceLanguage = model?.deviceLanguage
            
            weakSelf?.dataSource?.nightVisionMode = model?.nightVisionMode
            
            weakSelf?.dataSource?.whiteLightScintillation = model?.whiteLightScintillation
            
            weakSelf?.dataSource?.motionTrack = model?.motionTrack
            weakSelf?.dataSource?.motionTrackMode = model?.motionTrackMode
            
            weakSelf?.dataSource?.deviceSupportLanguage = model?.deviceSupportLanguage
            weakSelf?.dataSource?.antiflickerSwitch = model?.antiflickerSwitch
            weakSelf?.dataSource?.antiflicker = model?.antiflicker
            
            weakSelf?.dataSource?.mirrorFlip = model?.mirrorFlip
            weakSelf?.dataSource?.recLamp = model?.recLamp
            
            weakSelf?.dataSource?.voiceVolumeSwitch = model?.voiceVolumeSwitch
            weakSelf?.dataSource?.voiceVolume = model?.voiceVolume
            
            weakSelf?.dataSource?.cryDetect = model?.cryDetect
            weakSelf?.dataSource?.cryDetectLevel = model?.cryDetectLevel
                           
            weakSelf?.dataSource?.deviceCallToggleOn = model?.deviceCallToggleOn
            
            weakSelf?.dataSource?.mechanicalDingDongSwitch = model?.mechanicalDingDongSwitch
            weakSelf?.dataSource?.mechanicalDingDongDuration = model?.mechanicalDingDongDuration
            
            weakSelf?.dataSource?.chargeAutoPowerOnCapacity = model?.chargeAutoPowerOnCapacity
            weakSelf?.dataSource?.chargeAutoPowerOnSwitch = model?.chargeAutoPowerOnSwitch
            weakSelf?.dataSource?.chargeAutoPowerOnCapacityOptions = model?.chargeAutoPowerOnCapacityOptions
            weakSelf?.dataSource?.alarmWhenRemoveToggleOn = model?.alarmWhenRemoveToggleOn
            
            weakSelf?.dataSource?.liveAudioToggleOn = model?.liveAudioToggleOn
            
            
            weakSelf?.dataSource?.doorBellRingKey = model?.doorBellRingKey
            weakSelf?.dataSource?.supportDoorBellRingKey = model?.supportDoorBellRingKey
            
            
            weakSelf?.dataSource?.deviceSupport?.supportOtaAutoUpgrade = model?.deviceSupport?.supportOtaAutoUpgrade ?? NULL_BOOL
            weakSelf?.dataSource?.otaAutoUpgrade = model?.otaAutoUpgrade
        } onError: { code, message in
            weakSelf?.view.makeToast(message)
        }
    }
}


extension A4xDevicesSettingViewController: A4xDevicesSettingRangeCellProtocol {
    
    func devicesCellClick(index: Int, type: A4xDeviceSettingInfoEnum) {
        if case .boxArr(let tuple) = type {
            
            
            switch tuple.0?[index] {
            case .motion:
                self.pushDeviceMotionSetting()
            case .notifi:
                self.notificationSetting()
                break
            
            case .alarmSetting:
                self.alarmSetting()
                break
            case .videoSetting:
                let videoVC = A4xDeviceSettingVideoSettingViewController()
                videoVC.deviceModel = self.dataSource
                self.navigationController?.pushViewController(videoVC, animated: true)
                break
            case .backvideo:
                self.pushBackVideoViewController()
                break
            case .none:
                break
            }
        }
    }

}

extension A4xDevicesSettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let info : A4xDeviceSettingInfoEnum = self.cellInfos![indexPath.section][indexPath.row]
        if case .header = info {
            return 141.auto()
        } else if case .boxArr = info {
            if (cellHeight ?? 94.auto()) > 0 {
                return cellHeight ?? 94.auto()
            } else {
                return 0.1.auto()
            }
        }
        return 55.auto()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellInfos?[section].count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if cellInfos?[section].count ?? 0 > 0 {
            return 12.auto()
        }
        return 0.1.auto()
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.cellInfos?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info : A4xDeviceSettingInfoEnum = self.cellInfos![indexPath.section][indexPath.row]
        
        if case .header = info { 
            let identifier = "identifier1"
            
            var tableCell : A4xDevicesSettingHeaderView? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesSettingHeaderView
            if (tableCell == nil){
                tableCell = A4xDevicesSettingHeaderView(style: .default, reuseIdentifier: identifier);
            }
            
            tableCell?.dataSource = self.dataSource
            return tableCell!
            
        } else if case .remove = info { 
            let identifier = "identifier2"
            
            var tableCell : A4xDevicesSettingRemoveCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesSettingRemoveCell
            if (tableCell == nil){
                tableCell = A4xDevicesSettingRemoveCell(style: .default, reuseIdentifier: identifier);
            }
            tableCell?.title = info.rawValue(modelCategory: self.dataSource?.modelCategory)?.capitalized
            return tableCell!
        } else if case .boxArr(let tuple) = info { 
            let identifier = "identifier3"
            var tableCell : A4xDevicesSettingRangeCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesSettingRangeCell
            
            if (tableCell == nil) {
                tableCell = A4xDevicesSettingRangeCell(style: .default, reuseIdentifier: identifier)
            }
            tableCell?.isMotionSaveState = self.dataSource?.needMotion == 1 ? true : false //运动检测-状态
            
            tableCell?.protocol = self
            tableCell?.rangeNormalViews(arr: tuple)
            cellHeight = tableCell?.getCellHeight()
            return tableCell!
            
        } else { 
            let identifier = "identifier4"
            
            var tableCell : A4xDevicesSettingCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDevicesSettingCell
            if (tableCell == nil){
                tableCell = A4xDevicesSettingCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            }
            
            tableCell?.title = (info.rawValue(modelCategory: self.dataSource?.modelCategory), true, info.imgValue)
            tableCell?.titleIV.alpha = 1.0
            tableCell?.descTitle = ""
            tableCell?.updatePoint.isHidden = true
            tableCell?.alpha = 1.0
            tableCell?.isUserInteractionEnabled = true
            switch info {
            case .lightSet:
                fallthrough
            case .soundSet:
                fallthrough
            case .share:
                tableCell?.updateNameAndDescriptionLayout(des: "")
                break
            default:
                break
            }
            
            let warmingTitle : String? = nil
            var descTitle : String? = nil
            var shouldUpdate = false
            tableCell?.warmingTitle = warmingTitle
            return tableCell!
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
        cell.clipsToBounds = true
        let count = self.tableView(self.tableView, numberOfRowsInSection: indexPath.section)
        if indexPath.row == count  {
            cell.contentView.layer.mask = nil
            return
        }
        let bounds =  cell.contentView.bounds
        
        var rectCorner : UIRectCorner = UIRectCorner.allCorners
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
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 10.auto() , height: 10.auto() ))
        let maskLayer : CAShapeLayer = CAShapeLayer()
        maskLayer.frame = cell.contentView.bounds
        maskLayer.path = path.cgPath
        cell.contentView.layer.mask = maskLayer
        
        cell.contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.contentView.layer.shadowOpacity = 1
        cell.contentView.layer.shadowRadius = 7.5
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let info : A4xDeviceSettingInfoEnum = self.cellInfos![indexPath.section][indexPath.row]
        
        switch info {
        case .header:
            self.pushDeviceInfo()
            break
        case .boxArr:
            break
        case .lightSet:
            self.pushDeviceLightInfo()
            break
        case .soundSet:
            let vc = A4xDeviceSettingVoiceSettingViewController()
            vc.deviceModel = self.dataSource
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .share:
            self.pushDeviceShareSetting()
            break
        case .remove:
            self.removeDeviceAction()
            break
        }
    }
    
    private func pushBackVideoViewController() {
        let vc = A4xSDVideoHistoryViewController(deviceModel: self.dataSource ?? DeviceBean(serialNumber: self.dataSource?.serialNumber ?? ""))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func notificationSetting() {
        let notiVC = A4xDeviceSettingPushSettingViewController()
        notiVC.deviceModel = self.dataSource
        notiVC.deviceId = self.dataSource?.serialNumber ?? ""
        self.navigationController?.pushViewController(notiVC, animated: true)
    }
    
    
    private func alarmSetting() {
        let notiVC = A4xDeviceSettingAlarmSettingViewController()
        notiVC.deviceModel = self.dataSource
        self.navigationController?.pushViewController(notiVC, animated: true)
    }
    
    private func pushDeviceShareSetting() {
        
        let vc = A4xDevicesShareViewController(deviceModel: self.deviceModel ?? DeviceBean(serialNumber: deviceModel?.serialNumber ?? ""))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushDeviceMotionSetting() {
        let motionVc = A4xDeviceSettingMotionDetecctionViewController()
        motionVc.deviceModel = self.deviceModel
        self.navigationController?.pushViewController(motionVc, animated: true)
    }
    
    private func pushDeviceInfo() {
        let deviceInfoVc = A4xDeviceInformationViewController()
        deviceInfoVc.deviceModel = self.deviceModel
        self.navigationController?.pushViewController(deviceInfoVc, animated: true)
    }
 
    
    private func pushDeviceLightInfo() {
        
        let vc = A4xDeviceSettingLightSettingViewController()
        vc.deviceModel = self.dataSource
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func removeDeviceAction() {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.E1
        config.rightTextColor = UIColor.white
        weak var weakSelf = self
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
        
        let alert = A4xBaseAlertView(param: config, identifier: "delete device")
        alert.title = A4xBaseManager.shared.getLocalString(key: "remove_device_title", param: [tempString])
        alert.message  = A4xBaseManager.shared.getLocalString(key: "remove_device_des", param: [tempString])
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "delete")
        alert.rightButtonBlock = {
            weakSelf?.removeDeviceFormNet()
        }
        alert.show()
    }
    
    private func removeDeviceFormNet() {
        guard self.deviceModel?.serialNumber != nil else {
            return
        }
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (r) in }
        weak var weakSelf = self
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
        
        DeviceManageCore.getInstance().deleteDevice(serialNumber: self.deviceModel?.serialNumber ?? "") { code, message in
            if let strongSelf = weakSelf {
                let stringKey = "\(strongSelf.deviceModel?.serialNumber ?? "")_lastVoiceEnable"
                UserDefaults.standard.removeObject(forKey: stringKey)
                UserDefaults.standard.synchronize()
                
                
                let videosharpKey: String = (strongSelf.deviceModel?.serialNumber ?? "") + "_videosharp"
                UserDefaults.standard.removeObject(forKey: videosharpKey)
                UserDefaults.standard.synchronize()
                
                A4xUserDataHandle.Handle?.removeDevice(device: weakSelf?.dataSource)
                strongSelf.navigationController?.popViewController(animated: true)
                UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "remove_device_success", param: [tempString]))
                A4xObjcWebRtcPlayerManager.instance().destroyPlayer(strongSelf.deviceModel?.serialNumber ?? "")
                LiveManagerInstance.getInstance().destroyLive(deviceId: strongSelf.deviceModel?.serialNumber ?? "")
            }
        } onError: { code, message in
            weakSelf?.view.makeToast(A4xAppErrorConfig(code: code).message())
        }
    }
}
