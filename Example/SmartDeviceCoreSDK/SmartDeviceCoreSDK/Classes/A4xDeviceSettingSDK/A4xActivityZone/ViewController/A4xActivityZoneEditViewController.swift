//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public class A4xActivityZoneEditViewController: A4xBaseViewController {
    
    public var deviceModel: DeviceBean?
    private var dataSource : DeviceBean?
    

    var zonePoint: ZoneBean?
    
    var videoRatio: CGFloat = 16.0 / 9.0
    
    var backClickActionBlock: (() -> Void)?
    
    var mLivePlayer: LivePlayer?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //该页面显示时可以横竖屏切换
        A4xAppSettingManager.shared.interfaceOrientations = .landscape
        
        if #available(iOS 16.0, *) {
            
        } else {
            controlView.alpha = 1
        }

    }
    
    
    public override var shouldAutorotate : Bool {
        return true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let device = self.dataSource else {
            return
        }
        
        mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: device.serialNumber ?? "")
        
        mLivePlayer?.setListener(liveStateListener: self)
        
        DispatchQueue.main.a4xAfter(0.1) {
            
            if let state = self.mLivePlayer?.state {
                if state == A4xPlayerStateType.playing.rawValue {
                    self.mLivePlayer?.sendLiveMessage(customParam: ["videoScale" : A4xPlayerViewScale.aspectFill])
                    self.mLivePlayer?.updateLiveState()
                } else {
                    self.mLivePlayer?.startLive(customParam: ["apToken" : device.apModeModel?.aptoken ?? "", "videoScale" : A4xPlayerViewScale.aspectFit, "lookWhite" : true, "live_player_type" : "azoneFull"])
                }
            }
            self.mLivePlayer?.zoomEnable = true
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //页面退出时还原强制竖屏状态
        if #available(iOS 16.0, *) {
            
        } else {
            controlView.alpha = 0
        }
        
        A4xAppSettingManager.shared.interfaceOrientations = .portrait
        
        mLivePlayer?.zoomEnable = false
        
        mLivePlayer?.sendLiveMessage(customParam: ["videoScale": A4xPlayerViewScale.aspectFill])
    }

    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = A4xUserDataHandle.Handle?.getDevice(deviceId: self.deviceModel?.serialNumber ?? "", modeType: self.deviceModel?.apModeType ?? .WiFi)
        videoRatio = getVideoRatio()
        
        self.view.backgroundColor = UIColor.black
        DispatchQueue.main.a4xAfter(0.1) {
            self.controlView.isHidden = false
            self.controlView.videoState = (A4xPlayerStateType.playing.rawValue, self.dataSource?.serialNumber)
            self.controlView.deviceId = self.dataSource?.serialNumber
            self.controlView.zonePoint = self.zonePoint ?? ZoneBean()
        }
    }
    
    lazy var controlView: A4xActivityZoneVideoControlFullView = {
        let temp = A4xActivityZoneVideoControlFullView()
        temp.protocol = self
        temp.zonePoint = self.zonePoint ?? ZoneBean()
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
            if A4xBaseSysDeviceManager.isIpad && !(dataSource?.isFourByThree() ?? true) {
                make.width.equalTo(self.view.snp.width)
                make.height.equalTo(temp.snp.width).multipliedBy(videoRatio)
            } else {
                make.height.equalTo(self.view.snp.height)
                make.width.equalTo(temp.snp.height).multipliedBy(videoRatio)
            }
            //make.edges.equalTo(self.view.snp.edges)
        })
        return temp
    }()
    
    private func getVideoRatio() -> CGFloat {
        return (dataSource?.isFourByThree() ?? false) ? (4.0 / 3.0) : (A4xBaseSysDeviceManager.isIpad ? 9.0 / 16.0 : 16.0 / 9.0)
    }
   
}

extension A4xActivityZoneEditViewController {
    private func showSaveAlert(zone: ZoneBean , block : @escaping ()->Void) {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.Theme
        config.rightTextColor = UIColor.white
        weak var weakSelf = self
        
        let alert = A4xBaseAlertView(param: config, identifier: "show Save Alert")
        alert.message  = A4xBaseManager.shared.getLocalString(key: "change_not_save")
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "no")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "yes")
        alert.rightButtonBlock = {
            weakSelf?.saveRectInfo(zone: zone)
        }
        alert.leftButtonBlock = {
            weakSelf?.backClickActionBlock?()
            weakSelf?.navigationController?.popViewController(animated: true)
        }
      
        alert.show()
        
    }
    
    private func removeDeviceAction(zone: ZoneBean) {
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
            weakSelf?.deleteRect(zone: zone)
        }
        alert.show()
    }
}

extension A4xActivityZoneEditViewController : A4xActivityZoneVideoControlFullViewProtocol {
    
    func deleteRect(zone: ZoneBean) {
        guard let deviceId = zone.serialNumber else {
            return
        }
        
        let id = zone.zoneId
        if id == NULL_INT {
            self.backClickActionBlock?()
            self.navigationController?.popViewController(animated: true)
            return
        }

        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (a) in }
        weak var weakSelf = self
        DeviceActivityZoneCore.getInstance().removeActivityZone(serialNumber: deviceId, zoneId: id) { code, message in
            weakSelf?.view.hideToastActivity()
            
            weakSelf?.backClickActionBlock?()
            weakSelf?.navigationController?.popViewController(animated: true)
        } onError: { code, message in
            weakSelf?.view.hideToastActivity()
        }
    }
    
    func saveRectInfo(zone: ZoneBean) {
        guard let deviceId = zone.serialNumber else {
            return
        }
        guard let vertices = zone.vertices else {
            return
        }
        
        guard let zoneName = zone.zoneName else {
            return
        }
        
        guard let device = self.dataSource else {
            return
        }
        
        mLivePlayer?.screenShot(onSuccess: { _code, msg, image in
            
        }, onError: { code, msg in
            
        })
        
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (a) in }
        weak var weakSelf = self
        let zoneId = zone.zoneId
        
        if zoneId == NULL_INT {
            
            let zonebean = ZoneBean()
            zonebean.serialNumber = deviceId
            zonebean.vertices = vertices
            zonebean.zoneName = zoneName
            DeviceActivityZoneCore.getInstance().addActivityZone(zone: zonebean) { code, message in
                weakSelf?.view.hideToastActivity()
                weakSelf?.backClickActionBlock?()
                weakSelf?.navigationController?.popViewController(animated: true)
            } onError: { code, message in
                weakSelf?.view.hideToastActivity()
            }
        } else {
            
            let zonebean = ZoneBean()
            zonebean.zoneId = zoneId
            zonebean.serialNumber = deviceId
            zonebean.vertices = vertices
            zonebean.zoneName = zoneName
            DeviceActivityZoneCore.getInstance().updateActivityZone(zone: zonebean) { code, message in
                weakSelf?.view.hideToastActivity()
                weakSelf?.backClickActionBlock?()
                weakSelf?.navigationController?.popViewController(animated: true)
            } onError: { code, message in
                weakSelf?.view.hideToastActivity()
            }
        }
    }
    
    func videoBarBackAction(zone: ZoneBean, isChange: Bool) {
        

        if isChange {
            showSaveAlert(zone: zone) { [weak self] in
                self?.backClickActionBlock?()
                self?.navigationController?.popViewController(animated: true)
            }
        }else {
            self.backClickActionBlock?()
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    func videoReconnect() {
        
        guard let device = self.dataSource else {
            return
        }
        mLivePlayer?.startLive(customParam: ["apToken" : device.apModeModel?.aptoken ?? "", "videoScale" : A4xPlayerViewScale.aspectFit, "live_player_type" : "azone"])
    }
    
    func videoSaveRects(zone: ZoneBean, isChange: Bool) {
        
        if !isChange {
            return
        }
        saveRectInfo(zone: zone)
    }
    
    func videoDeleteRects(zone: ZoneBean) {
        
        removeDeviceAction(zone: zone)
    }
}

extension A4xActivityZoneEditViewController : ILiveStateListener {
    public func onRenderView(surfaceView: UIView) {
        self.controlView.videoNewView.playerView = surfaceView
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
        self.controlView.videoState = (stateCode, dataSource?.serialNumber ?? "")
    }
}
