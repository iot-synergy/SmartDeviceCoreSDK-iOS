//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public class A4xActivityZoneViewController: A4xBaseViewController {
    private var motionEnable : Bool = true
            
    public var deviceModel : DeviceBean?
    private var dataSource : DeviceBean?
    var cellHeight: CGFloat = 85.auto()
    var viewForHeaderInSectionHeight: CGFloat = 30.auto()
    
    var actityZonePoints : [ZoneBean]?
    var cellInfos: [[ZoneBean]]?
    
    var firstErrTipSection: Int? = 0
    
    var videoRatio: CGFloat = 9.0 / 16.0
    
    var mLivePlayer: LivePlayer?

    let defaultZoneNames: [String] = [A4xBaseManager.shared.getLocalString(key: "zone_1") , A4xBaseManager.shared.getLocalString(key: "zone_2"), A4xBaseManager.shared.getLocalString(key: "zone_3")]
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ADTheme.C6
        
        
        
        weak var weakSelf = self
        
        self.updateDeviceInfo(deviceId: self.deviceModel?.serialNumber ?? "") { isComplete in
            weakSelf?.loadNavtion()
            weakSelf?.cellInfos = []
            
            weakSelf?.videoView.isHidden = false
            weakSelf?.tipLabel.isHidden = false
            weakSelf?.videoView.protocol = self
        }
        
    }
    
    
    private func updateDeviceInfo(deviceId: String, _ comple: @escaping ((Bool) -> Void)) {
        if A4xDeviceSettingManager.shared.deviceIsVip(deviceId: self.deviceModel?.serialNumber ?? "") == false {
            
            DeviceManageUtil.getDeviceSettingInfo(deviceId: self.deviceModel?.serialNumber ?? "") { code, message, model in
                if code == 0 {
                    A4xUserDataHandle.Handle?.updateDevice(device: model)
                    comple(true)
                } else {
                    comple(false)
                }
            }
        } else {
            
            comple(true)
        }
    }
    
    private func loadResponse() {
        guard let deviceId = deviceModel?.serialNumber else {
            return
        }
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (r) in }
        weak var weakSelf = self
        DeviceActivityZoneCore.getInstance().getAllZonesList(serialNumber: deviceId) { code, message, models in
            weakSelf?.view.hideToastActivity(duration: 0.0)
            weakSelf?.cellInfos?.removeAll()
            weakSelf?.actityZonePoints = models
            weakSelf?.videoView.rectlist = models
            
            let pointsNormalArr = weakSelf?.actityZonePoints?.filter{$0.errPoint == 0}
            if pointsNormalArr?.count ?? 0 > 0 {
                weakSelf?.cellInfos?.append(pointsNormalArr ?? [])
            }
            
            let pointsErrArr = weakSelf?.actityZonePoints?.filter{$0.errPoint == 1}
            if pointsErrArr?.count ?? 0 > 0 {
                weakSelf?.cellInfos?.append(pointsErrArr ?? [])
            }
            if weakSelf?.actityZonePoints?.count ?? 0 > 0 {
                weakSelf?.tipLabel.isHidden = true
                weakSelf?.tableView.snp.remakeConstraints({ (make) in
                    make.top.equalTo(self.tipLabel.isHidden ? self.videoView.snp.bottom : self.tipLabel.snp.bottom).offset(8.auto())
                    make.width.equalTo(self.view.snp.width)
                    make.leading.equalTo(0)
                    make.bottom.equalTo(self.view.snp.bottom)
                })
            } else {
                weakSelf?.tipLabel.isHidden = false
            }
            weakSelf?.tableView.layoutIfNeeded()
            weakSelf?.tableView.hiddNoDataView()
            weakSelf?.tableView.reloadData()
        } onError: { code, message in
            weakSelf?.view.hideToastActivity(duration: 0.0)
            
            weakSelf?.tableView.showNoDataView(value: A4xBaseNoDataValueModel.error(error: A4xBaseManager.shared.getLocalString(key: "failed_get_infomation", param: ["\(code)"]), comple: {
                weakSelf?.loadResponse()
            }))
        }
    }
    
    
    private func reloadData(error : String?){
        if error != nil { } else { }
    }
  
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let contains : Bool = self.navigationController?.viewControllers.contains(self) ?? false
        if !contains {
            mLivePlayer?.stopLive()
        }

    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.dataSource = A4xUserDataHandle.Handle?.getDevice(deviceId: self.deviceModel?.serialNumber ?? "", modeType: self.deviceModel?.apModeType ?? .WiFi)
        videoRatio = (self.dataSource?.isFourByThree() ?? false) ? (3.0 / 4.0) : (9.0 / 16.0)
        

        guard let device = self.dataSource else {
            return
        }
        
        mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: device.serialNumber ?? "")
        mLivePlayer?.setListener(liveStateListener: self)
        
        
        
        
        DispatchQueue.main.a4xAfter(0.1) {
            self.loadResponse()
            
            self.videoView.snp.remakeConstraints({ (make) in
                make.top.equalTo(self.navView!.snp.bottom)
                make.centerX.equalTo(self.view.snp.centerX)
                make.width.equalTo(self.view.snp.width)
                make.height.equalTo(self.view.snp.width).multipliedBy(self.videoRatio)
            })
            
            if let state = self.mLivePlayer?.state {
                if state == A4xPlayerStateType.playing.rawValue {
                    self.videoView.videoState = (state, device.serialNumber ?? "")
                    DispatchQueue.main.a4xAfter(0.2) {
                        
                        self.mLivePlayer?.updateLiveState()
                    }
                } else {
                    self.mLivePlayer?.startLive(customParam: ["apToken" : device.apModeModel?.aptoken ?? "", "videoScale" : A4xPlayerViewScale.aspectFit, "lookWhite" : true, "live_player_type" : "azone"])
                }
            }
        }
    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "activity_zones")
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
        
        var rightItem = A4xBaseNavItem()
        rightItem.normalImg = "device_manager_nav_add"
        self.navView?.rightItem = rightItem
        self.navView?.rightBtn?.isHidden = false
        self.navView?.rightClickBlock = {
            weakSelf?.addNewZone()
        }
    }
  
    lazy var videoView: A4xActivityZoneLiveVideo = {
        let vc = A4xActivityZoneLiveVideo()

        vc.backgroundColor = UIColor.black
        self.view.addSubview(vc)

        vc.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width)
            make.height.equalTo(self.view.snp.width).multipliedBy(videoRatio)
        })
        return vc
    }()
    
    lazy var tipLabel: UILabel = {
        let temp = UILabel()
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.width.equalTo(self.view.snp.width).offset(-30.auto())
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(self.videoView.snp.bottom).offset(18.auto())
        })
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
        var attrString = NSMutableAttributedString(string: A4xBaseManager.shared.getLocalString(key: "activity_zone_tips",param: [tempString]))
        let param = NSMutableParagraphStyle()
        param.lineSpacing = 3
        let attr: [NSAttributedString.Key : Any] = [.font:  ADTheme.B2 ,.foregroundColor: ADTheme.C3 ,.paragraphStyle : param ]
        attrString.addAttributes(attr, range: NSRange(location: 0, length: attrString.length))
        temp.attributedText = attrString
        return temp
    }()
    
    lazy var tableView: UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: .grouped)
        temp.delegate = self
        temp.dataSource = self
        temp.isScrollEnabled = false
        temp.backgroundColor = UIColor.clear
        temp.tableFooterView = UIView()
        temp.accessibilityIdentifier = "tableView"
        temp.separatorInset = .zero
        temp.separatorColor = ADTheme.C6
        temp.estimatedRowHeight = 70
        temp.sectionHeaderHeight = UITableView.automaticDimension
        temp.rowHeight = UITableView.automaticDimension
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.tipLabel.isHidden ? self.videoView.snp.bottom : self.tipLabel.snp.bottom).offset(8.auto())
            make.width.equalTo(self.view.snp.width)
            make.leading.equalTo(0)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        
        return temp
    }()
    
}

extension A4xActivityZoneViewController : UITableViewDelegate , UITableViewDataSource {

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return max(cellHeight, 70.auto())
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellInfos?[section].count ?? 0
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let pointModelArr = cellInfos?[section][0]
        if pointModelArr?.errPoint == 1 {
            return max(viewForHeaderInSectionHeight + 10.auto(), 30.auto()) 
        } else {
            return 0.1
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let pointModelArr = cellInfos?[section][0]
        if pointModelArr?.errPoint == 1 {
            
            let view = UIView()
            view.backgroundColor = .clear
            let errorTipLbl = UILabel()
            errorTipLbl.text = A4xBaseManager.shared.getLocalString(key: "wrong_az_tips")
            errorTipLbl.textColor = UIColor.colorFromHex("#E04F33")
            errorTipLbl.numberOfLines = 0
            errorTipLbl.adjustsFontSizeToFitWidth = true
            errorTipLbl.textAlignment = .left
            errorTipLbl.font = UIFont.regular(12)
            view.addSubview(errorTipLbl)
            errorTipLbl.snp.makeConstraints { (make) in
                make.leading.equalTo(16.auto())
                make.width.equalTo(view.snp.width).offset(-32.auto())
                make.centerY.equalTo(view.snp.centerY)
            }
            errorTipLbl.layoutIfNeeded()
            viewForHeaderInSectionHeight = errorTipLbl.height + 16.auto()
            view.height = viewForHeaderInSectionHeight
            return view
        }
        return UIView()
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return cellInfos?.count ?? 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pointModel = cellInfos?[indexPath.section][indexPath.row]
        let identifier = "identifier2"
        var tableCell : A4xActivityZoneViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xActivityZoneViewCell
        if (tableCell == nil) {
            tableCell = A4xActivityZoneViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
        }
        tableCell?.dataSource = pointModel
        tableCell?.protocol = self
        tableCell?.indexPath = indexPath
        cellHeight = tableCell?.getCellHeight() ?? 70.auto()
        return tableCell!
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    private func addNewZone(){
        if self.actityZonePoints?.count ?? 0 >= 3 {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "toast_add_zone_total_3"))
            return
        }

        let viewControllrs = self.navigationController?.viewControllers
        var has : Bool = false

        viewControllrs?.forEach({ (vc) in
            if vc is A4xActivityZoneEditViewController {
                has = true
            }
        })
        if has {
            return
        }

        let vc = A4xActivityZoneEditViewController()
        vc.deviceModel = dataSource
        vc.zonePoint = getDefaultZone()
        vc.backClickActionBlock = { [weak self] in
            self?.updateLiveState()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getDefaultZone() -> ZoneBean {
        var zonePoint = ZoneBean()
        
        var currentNames : [String] = []
        actityZonePoints?.forEach({ (p) in
            guard let name = p.zoneName else {
                return
            }
            currentNames.append(name)
        })
        
        let name = self.defaultZoneNames.filter { (str) -> Bool in
           return !currentNames.contains(str)
        }.first ?? defaultZoneNames.last!
        zonePoint.zoneName = name
        let colorIndex : Int = min(2, currentNames.count)
        zonePoint.rectColor = A4xBaseActivityZonePointColorsValue[colorIndex]
        return zonePoint
    }
    
    private func updateLiveState() {
    }
}

extension A4xActivityZoneViewController : ILiveStateListener {
    public func onRenderView(surfaceView: UIView) {
        self.videoView.videoView = surfaceView
        mLivePlayer?.setRenderView(renderView: self.videoView)
    }
    
    public func onDeviceMsgPush(code: Int) {
        var message = ""
        switch code {
        case 1:
            message = A4xBaseManager.shared.getLocalString(key: "network_low")
            break
        case 2:
            message = A4xBaseManager.shared.getLocalString(key: "live_viewers_limit")
            break
        case 3:
            A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.localNet) { [weak self](f) in
                if !f {
                } else {
                    self?.mLivePlayer?.sendLiveMessage(customParam: ["isLocalNetLimit": true])
                }
            }
            break
        case -1:
            message = A4xBaseManager.shared.getLocalString(key: "sd_card_not_exist")
            break
        case -2:
            let message = A4xBaseManager.shared.getLocalString(key: "sdcard_has_no_video")
            break
        case -3:
            let message = A4xBaseManager.shared.getLocalString(key: "sdcard_need_format")
            break
        case -4:
            let message = A4xBaseManager.shared.getLocalString(key: "SDcard_video_viewers_limit")
            break
        case -5:
            message = A4xBaseManager.shared.getLocalString(key: "other_error_with_code")
            break
        default:
            break
        }
        if message.count > 0 {
            self.view.makeToast(message)
        }
    }
    
    public func onPlayerState(stateCode: Int, msg: String) {
        
        self.videoView.videoState = (stateCode, dataSource?.serialNumber)
    }
}


extension A4xActivityZoneViewController {
    
    private func toSetViewController() {
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
        guard let device = A4xUserDataHandle.Handle?.getDevice(deviceId: self.deviceModel?.serialNumber ?? "", modeType: self.deviceModel?.apModeType ?? .WiFi) else {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "device_offline", param: [tempString]) + " no data")
            return
        }
        
        if device.online ?? 0 == 1 {
            let vc = A4xDeviceSettingMotionDetecctionViewController()
            vc.deviceModel = self.deviceModel
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "device_offline", param: [tempString]))
        }
        
    }
    
    private func toBuyViewController() {
      
    }
}

extension A4xActivityZoneViewController : A4xActivityZoneVideoControlProtocol {
    
    func videoBarBackAction() {}
    
    func videoReconnect() {
        guard let db = self.dataSource else {
            return
        }
        mLivePlayer?.startLive(customParam: ["apToken" : db.apModeModel?.aptoken ?? "", "live_player_type" : "azone"])
    }
}

extension A4xActivityZoneViewController : A4xActivityZoneViewCellProtocol {
    func devicesCellClick(sender: UIImageView, indexPath: IndexPath) {
        if sender.tag == 1 {
            self.deleteRect(zone: self.cellInfos?[indexPath.section][indexPath.row], comple: { [weak self] res in
                if res {
                    
                    self?.loadResponse()
                }
            })
        } else {
            let viewControllrs = self.navigationController?.viewControllers
            var has : Bool = false
            viewControllrs?.forEach({ (vc) in
                if vc is A4xActivityZoneEditViewController {
                    has = true
                }
            })
            if has {
                return
            }
            let vc = A4xActivityZoneEditViewController()
            vc.deviceModel = dataSource
            vc.zonePoint = self.cellInfos?[indexPath.section][indexPath.row]
            vc.backClickActionBlock = { [weak self] in
                self?.updateLiveState()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func removeDeviceAction(zone: ZoneBean?, comple: @escaping (_ isScuess: Bool)->Void) {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.E1
        config.rightTextColor = UIColor.white
        weak var weakSelf = self
        
        let alert = A4xBaseAlertView(param: config, identifier: "show delete Alert")
        alert.message  = A4xBaseManager.shared.getLocalString(key: "sure_to_delete_zone")
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "delete")
        alert.rightButtonBlock = {
            weakSelf?.deleteRect(zone: zone, comple: { res in
                comple(res)
            })
        }
        alert.show()
    }
    
    private func deleteRect(zone: ZoneBean?, comple: @escaping (_ isScuess: Bool)->Void) {
        guard let deviceId = zone?.serialNumber else {
            return
        }
        
        let id = zone?.zoneId
        if id == NULL_INT {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (a) in }
        
        weak var weakSelf = self
        DeviceActivityZoneCore.getInstance().removeActivityZone(serialNumber: deviceId, zoneId: id ?? NULL_INT) { code, message in
            weakSelf?.view.hideToastActivity()
            comple(true)
        } onError: { code, message in
            weakSelf?.view.hideToastActivity()
            let errorMsg = A4xAppErrorConfig(code: code).message() ?? message
            weakSelf?.view.makeToast(errorMsg)
            comple(false)
        }
    }
}
