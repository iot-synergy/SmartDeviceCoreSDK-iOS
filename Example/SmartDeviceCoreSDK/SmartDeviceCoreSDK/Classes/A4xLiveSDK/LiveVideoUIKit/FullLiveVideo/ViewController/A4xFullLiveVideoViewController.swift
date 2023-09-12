//


//


//

import Accelerate
import UIKit
import SmartDeviceCoreSDK
import Resolver
import A4xDeviceSettingInterface
import BaseUI


@objc protocol A4xFullLiveVideoViewControllerDelegate {
    func didFinishViewController(controller: UIViewController, currentIndexPath: IndexPath)
}

open class A4xFullLiveVideoViewController: A4xBaseViewController {
    
    public var dataSource: DeviceBean?
    
    var liveVideoViewModel: A4xLiveVideoViewModel? 
    
    public var shouldBackStop: Bool = false
    public var topTipString: String?
    public var currentIndexPath: IndexPath?
    
    
    private var videoRatio: CGFloat = 16.0 / 9.0
    
    weak var delegate: A4xFullLiveVideoViewControllerDelegate?
    
    var mLivePlayer: LivePlayer?
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        
        view.backgroundColor = UIColor.black
        weak var weakSelf = self
        
        guard let data = weakSelf?.dataSource else {
            return
        }
        
     
        mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: data.serialNumber ?? "")
        
        videoRatio = getVideoRatio()
                
        fullLiveVideoControlView.isHidden = false
                
        if liveVideoViewModel == nil {
            liveVideoViewModel = A4xLiveVideoViewModel()
        }
        
        fullLiveVideoControlView.dataSource = dataSource
        
        if let tipSt = topTipString {
            DispatchQueue.main.a4xAfter(0.5) {
                weakSelf?.view.makeToast(tipSt, duration: 2, position: ToastPosition.top(offset: 20), title: nil, image: nil, style: ToastStyle(), completion: nil)
            }
        }
    }

    lazy var fullLiveVideoControlView: A4xFullLiveVideoControlView = {
        let temp = A4xFullLiveVideoControlView(frame: .zero, model: self.dataSource ?? DeviceBean())
        temp.backgroundColor = .clear
        temp.protocol = self
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
            if A4xBaseSysDeviceManager.isIpad && !(dataSource?.isFourByThree() ?? true) {
                make.width.equalTo(self.view.snp.width)
                make.height.equalTo(temp.snp.width).multipliedBy(videoRatio)
            } else {
                make.height.equalTo(self.view.snp.height)
                make.width.equalTo(temp.snp.height).multipliedBy(videoRatio)
            }
        })
        
        return temp
    }()
    
    override public func viewWillAppear(_ animated: Bool) {
        
        
        A4xAppSettingManager.shared.interfaceOrientations = .landscape
        
    }
    
    
    open override var shouldAutorotate : Bool {
        return true
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let data = dataSource else {
            return
        }
        
        fullLiveVideoControlView.alpha = 1
        
        mLivePlayer?.setListener(liveStateListener: self)
        
        
        mLivePlayer?.zoomEnable = true
    
        if mLivePlayer?.state == A4xPlayerStateType.playing.rawValue {
            videoRatio = getVideoRatio()
            mLivePlayer?.sendLiveMessage(customParam: ["videoScale" : A4xPlayerViewScale.aspectFill])
        } else {
            mLivePlayer?.startLive(customParam: ["apToken" : data.apModeModel?.aptoken ?? "", "videoScale" : A4xPlayerViewScale.aspectFit, "lookWhite" : true, "live_player_type" : "landscape"])
        }
        mLivePlayer?.updateLiveState()
        
        let whiteLightEnable = dataSource?.deviceContrl?.whiteLight ?? false
        fullLiveVideoControlView.supperWhitelight = whiteLightEnable
        fullLiveVideoControlView.canRotating = self.dataSource?.deviceContrl?.canRotate ?? false
    }
    
    private func stopLive(reason: A4xPlayerStopReason) {
        mLivePlayer?.stopLive()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        
        
        fullLiveVideoControlView.alpha = 0
        
        
        guard let data = dataSource else {
            return
        }
        
        weak var weakSelf = self
        DispatchQueue.main.a4xAfter(0.1) {
            self.mLivePlayer?.zoomEnable = false
            if weakSelf?.shouldBackStop ?? false {
                weakSelf?.stopLive(reason: .changePage)
            } else {
                self.mLivePlayer?.sendLiveMessage(customParam: ["videoScale": A4xPlayerViewScale.aspectFill])
            }
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func getVideoRatio() -> CGFloat {
        return (dataSource?.isFourByThree() ?? false) ? (4.0 / 3.0) : (A4xBaseSysDeviceManager.isIpad ? 9.0 / 16.0 : 16.0 / 9.0)
    }
    
    private func showAnimail(img: UIImage, view: UIView) {
        A4xBasePhotoManager.default().save(image: img, result: { result, att in
            
            if result {
                self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "save_album"))
            } else {
                let error_msg = A4xBaseManager.shared.getLocalString(key: "shot_fail")
                self.view.makeToast(error_msg)
            }
        })
    }
    
    private func videoFirstImage(fromVideoPath path : String) -> UIImage? {
        let videoURL = URL(fileURLWithPath: path)
        let avAsset = AVAsset(url: videoURL)
        
        //生成视频截图
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0,preferredTimescale: 600)
        var actualTime:CMTime = CMTimeMake(value: 0,timescale: 0)
        guard let imageRef:CGImage = try? generator.copyCGImage(at: time, actualTime: &actualTime) else {
            return nil
        }
        let frameImg = UIImage(cgImage: imageRef)
        return frameImg
    }
}

extension A4xFullLiveVideoViewController: ILiveStateListener {
    
    public func onRenderView(surfaceView: UIView) {
        fullLiveVideoControlView.videoView = surfaceView
    }
    
    public func onPlayerState(stateCode: Int, msg: String) {
        if let state = A4xPlayerStateType.init(rawValue: stateCode) {
            fullLiveVideoControlView.videoState = (stateCode, dataSource?.serialNumber ?? "")
            weak var weakSelf = self

            if state == .playing && dataSource?.deviceContrl?.canRotate ?? false {
                liveVideoViewModel?.searchAllPresetPosition(deviceModel: dataSource) { error in
                    if let e = error {
                        weakSelf?.view.makeToast(e)
                    }
                    
                    weakSelf?.fullLiveVideoControlView.presetListData = weakSelf?.liveVideoViewModel?.presetModelBy(deviceId: weakSelf?.dataSource?.serialNumber ?? "")
                    
                    
                    weakSelf?.fullLiveVideoControlView.autoFollowBtnIsHumanImg = false
                    
                    
                    weakSelf?.fullLiveVideoControlView.isTrackingOpen = weakSelf?.liveVideoViewModel?.isTrackingOpen(deviceId: weakSelf?.dataSource?.serialNumber ?? "") ?? false
                    
                }
            }
            
            fullLiveVideoControlView.audioEnable = mLivePlayer?.getAudioEnable() ?? false
            
            fullLiveVideoControlView.whiteLight = mLivePlayer?.getWhiteLight() ?? false
            
            let index = mLivePlayer?.getVoiceEffect()
            
            fullLiveVideoControlView.whiteLight = mLivePlayer?.getWhiteLight() ?? false
            fullLiveVideoControlView.deviceInfoUpdate()
        }
        
    }
    
    public func onDeviceMsgPush(code: Int) {
        var message = ""
        switch code {
        case 1:
            message = A4xBaseManager.shared.getLocalString(key: "network_low")
            break
        
        default:
            break
        }
        if message.count > 0 {
            if message == A4xBaseManager.shared.getLocalString(key: "network_low") {
                fullLiveVideoControlView.showPoorNetwork = true
                return
            }
            self.view.makeToast(message)
        }
    }
    
    public func onDownloadSpeedUpdate(speed: String) {
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.fullLiveVideoControlView.downloadSpeed = speed
        }
    }
    
    public func onMicFrame(data: [Float]) {
        weak var weakSelf = self
        DispatchQueue.main.async {
            weakSelf?.fullLiveVideoControlView.spackVoiceData = data
        }
    }
    
    public func onRecordState(state: Int, videoPath: String) {
        let s = A4xPlayerRecordState.init(rawValue: state)
        switch s {
        case .start:
            fullLiveVideoControlView.recordState = .start
        case .end:
            fullLiveVideoControlView.recordState = .stop
            if let image = self.videoFirstImage(fromVideoPath: videoPath) {
                A4xFullLiveVideoAnimailView.showThumbnail(tapButton: self.fullLiveVideoControlView.recordButton, image: image, tipString: A4xBaseManager.shared.getLocalString(key: "save_album")) {
                }
            }
            A4xBasePhotoManager.default().save(videoPath: videoPath) { (result, id) in
                if result {
                    UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "record_success"))
                } else {
                    UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "record_failed"))
                }
            }
        case .startError:
            fullLiveVideoControlView.recordState = .stop
        case .endError:
            fullLiveVideoControlView.recordState = .stop
        case .none:
            break
        }
    }
    
}

extension A4xFullLiveVideoViewController {

    private func addPresetAlertLocation(deviceModel: DeviceBean?, image: UIImage?) {
        let (add, error) = liveVideoViewModel?.canAdd(deviceId: deviceModel?.serialNumber ?? "") ?? (true, nil)
        if !add {
            view.makeToast(error)
            return
        }
        weak var weakSelf = self
        
        let alert = A4xAddPresetLocationAlert(frame: CGRect.zero)
        alert.image = image
        let currKeyWindow = UIApplication.shared.keyWindow
        alert.onEditDone = { str in
            
            currKeyWindow?.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading"), completion: { _ in })
            weakSelf?.liveVideoViewModel?.addPreLocationPoint(deviceModel: deviceModel, image: image, name: str, comple: { status, tips in
                
                currKeyWindow?.hideToastActivity()
                if tips != "" {
                    weakSelf?.view.makeToast(tips, position: ToastPosition.bottom(offset: 50))
                }
                weakSelf?.fullLiveVideoControlView.presetListData = weakSelf?.liveVideoViewModel?.presetModelBy(deviceId: deviceModel?.serialNumber ?? "")
            })
        }
        alert.show()
    }
    
    
    private func deletePresetLocaion(deviceId: String?, preset: A4xPresetModel?) {
        
        weak var weakSelf = self
        liveVideoViewModel?.delPresetPosition(deviceId: deviceId, pointId: preset?.presetId ?? 0) { status, tips in
            if status {
                weakSelf?.fullLiveVideoControlView.presetListData = weakSelf?.liveVideoViewModel?.presetModelBy(deviceId: deviceId ?? "")
            } else {
            }
            weakSelf?.view.makeToast(tips)
        }
    }
    
    private func presetClickAction(deviceModel: DeviceBean?, preset: A4xPresetModel?) {
        
        weak var weakSelf = self
        liveVideoViewModel?.setPreLocationPoint(deviceModel: deviceModel, preset: preset) { error in
            if let e = error {
                weakSelf?.view.makeToast(e, position: ToastPosition.bottom(offset: 50))
            }
        }
    }
}


extension A4xFullLiveVideoViewController: A4xFullLiveVideoControlProtocol {
    public func deviceSleepToWakeUp(device: DeviceBean?) {
        
        weak var weakSelf = self
        UIApplication.shared.keyWindow?.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in
        }
        
        DeviceSleepPlanCore.getInstance().setSleep(serialNumber: device?.serialNumber ?? "", enable: false) { code, message in
            weakSelf?.videoReconnect()
        } onError: { code, message in
            let msg = A4xAppErrorConfig(code: code).message()
            weakSelf?.view.makeToast(msg)
            weakSelf?.videoReconnect()
        }
    }
    
    public func presetLocationAction() {
        guard let devideId = dataSource?.serialNumber else {
            return
        }
    }
    
    public func liveMotionTrackChange(enable: Bool, comple: @escaping (_ isSuccess: Bool) -> Void) {
        guard let devideId = dataSource?.serialNumber else {
            return
        }
        weak var weakSelf = self
        liveVideoViewModel?.updateMotionTrackStatus(deviceId: devideId, enable: enable, comple: { error in
            if error != nil {
                weakSelf?.view.makeToast(error)
            }
            
            comple(error == nil)
        })
    }
    
    public func videoDisReconnect() {
        self.stopLive(reason: .none)
    }
    
    public func videoControlWhiteLight(enable: Bool) {
        weak var weakSelf = self
        mLivePlayer?.setWhiteLight(enable: enable, onSuccess: { code, msg in
            weakSelf?.fullLiveVideoControlView.whiteLight = enable
        }, onError: { code, msg in
            weakSelf?.fullLiveVideoControlView.whiteLight = !enable
        })
    }
    
    public func videoZoomChange() {
        mLivePlayer?.setZoomChange()
    }
    
    public func resetLocationAction(type: A4xFullLiveVideoPresetCellType, data: A4xPresetModel?) {
        switch type {
        case .none:
            presetClickAction(deviceModel: dataSource, preset: data)
        case .add:
            
            weak var weakSelf = self
            mLivePlayer?.screenShot(onSuccess: { _code, msg, image in
                weakSelf?.addPresetAlertLocation(deviceModel: self.dataSource, image: image)
            }, onError: { code, msg in
                
            })
        case .delete:
            
            deletePresetLocaion(deviceId: dataSource?.serialNumber, preset: data)
        }
    }
    
    public func deviceRotate(point: CGPoint) {
        mLivePlayer?.setPtz(x: Float(point.x), y: Float(point.y), onSuccess: { code, msg in
        }, onError: { [weak self] code, msg in
            switch code {
            case -6:
                self?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "limit_reached"))
                break
            case -7:
                self?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "calibrating_now_try_later"))
                break
            default:
                break
            }
        })
    }
    
    public func setResolution(type: A4xVideoSharpType) {
        
        mLivePlayer?.setResolution(ratio: type.valueString(), onSuccess: { code, msg in
            if code == 0 {
                onMainThread {
                    self.fullLiveVideoControlView.deviceInfoUpdate()
                }
            }
        }, onError: { [weak self] code, msg in
            self?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "switch_resolution_failed"))
        })
    }
    
    public func videoVolumeAction(enable: Bool) {
        mLivePlayer?.audioEnable(enable: enable)
    }
    
    public func videoRecordVideo(start: Bool) {
        
        A4xBasePhotoManager.default().checkAuthor { [weak self] error in
            if error == .no {
                if start {
                    self?.mLivePlayer?.startRecord(path: NSHomeDirectory() + "/Documents/webrtcTmp.mp4")
                } else {
                    self?.mLivePlayer?.stopRecord()
                }
            } else {
                if error == .reject {
                }
                A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.photo) { [weak self] open in
                    self?.fullLiveVideoControlView.recordState = .stop
                }
            }
        }
    }
    
    public func videoReconnect() {
        if let state = A4xPlayerStateType(rawValue: self.fullLiveVideoControlView.videoState?.0 ?? A4xPlayerStateType.paused.rawValue) {
            
            switch state {
            case .updating:
                
                break
            case .paused:
                
                break
            default:
                break
            }
        }
        
        self.stopLive(reason: .click)
        
        
        mLivePlayer?.startLive(customParam: ["apToken" : dataSource?.apModeModel?.aptoken ?? "", "videoScale": A4xPlayerViewScale.aspectFit, "lookWhite" : true, "live_player_type" : "landscape"])
    }
    
    public func videoBarBackAction() {
        if currentIndexPath != nil {
            //结束当前页面的直播操作
            guard let data = self.dataSource else {
                delegate?.didFinishViewController(controller: self, currentIndexPath: currentIndexPath ?? IndexPath(row: 0, section: 0))
                return
            }
            
            mLivePlayer?.zoomEnable = false
            if self.shouldBackStop {
                self.stopLive(reason: .changePage)
            } else {
                mLivePlayer?.sendLiveMessage(customParam: ["videoScale" : A4xPlayerViewScale.aspectFill])
            }
            delegate?.didFinishViewController(controller: self, currentIndexPath: currentIndexPath ?? IndexPath(row: 0, section: 0))
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    public func videoBarSettingAction() {
        
        Resolver.deviceSettingImpl.pushDevicesSettingViewController(deviceModel: dataSource, fromType: .simple, navigationController: navigationController)
        self.stopLive(reason: .none)
    }
    
    public func videoAlarmAction() {
        weak var weakSelf = self
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
        self.showDeviceAlert( message: A4xBaseManager.shared.getLocalString(key: "do_alarm_tips", param: [tempString]), cancelTitle: A4xBaseManager.shared.getLocalString(key: "cancel"), doneTitle: A4xBaseManager.shared.getLocalString(key: "alarm_on"), image: bundleImageFromImageName("device_send_alert")?.rtlImage(), doneAction: {
            weakSelf?.mLivePlayer?.setAlarm(onSuccess: { code, msg in
                
            }, onError: { code, msg in
                
            })
        }, cancleAction: {
            
        })
    }

    public func videoSpeakAction(enable: Bool) -> Bool {
        let signal = DispatchSemaphore(value: 1)
        var isOpenRecord = false
        openRecordServiceWithBlock { [weak self] flag in
            if !flag {
                A4xBaseAuthorizationViewModel.single.showRequestAlert(type: .audio) { open in
                    if !open {}
                }
                signal.signal()
            } else {
                isOpenRecord = true
                signal.signal()
            }
        }
        
        let result = signal.wait(timeout: .distantFuture)
        if result == .success {
            if enable {
                if !isOpenRecord {
                    return false
                }
                mLivePlayer?.audioEnable(enable: true)
                fullLiveVideoControlView.audioEnable = true
            }
        }
        mLivePlayer?.speakEnable(enable: enable)
        
        return true
    }
    
    public func videoScreenShot(view: UIView) {
        A4xBasePhotoManager.default().checkAuthor { [weak self] error in
            if error == .no {
                self?.mLivePlayer?.screenShot(onSuccess: { _code, msg, image in
                    guard let img = image else {
                        self?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "shot_fail"))
                        return
                    }
                    self?.showAnimail(img: img, view: view)
                }, onError: { code, msg in
                    
                })
            } else {
                if error == .reject {}
                A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.photo) { open in
                    if !open {
                    }
                }
            }
        }
    }
    
    public func resolutionIntroAction() {
        self.fullLiveVideoControlView.tapVideoAction()
    }
    
    public func autoResolutionAction(type: Int?) {
        guard let dateSource = dataSource else {
            return
        }
        switch type {
        case 0:
            dateSource.saveResolutionToCache(type: .auto)
            mLivePlayer?.startLive(customParam: ["live_player_type" : "landscape"])
            break
        case 1:
            mLivePlayer?.startLive(customParam: ["live_player_type" : "landscape", "autoResolutionEnable": false])
            break
        case .none:
            break
        case .some(_):
            break
        }
    }
}


