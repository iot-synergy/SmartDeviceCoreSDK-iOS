//
//  A4xSdVideoFullVideoViewController.swift
//  AddxAi
//
//  Created by kzhi on 2020/1/9.
//  Copyright © 2020 addx.ai. All rights reserved.
//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xSdVideoFullVideoViewController: A4xBaseViewController {
    
    init(deviceModel: DeviceBean) {
        super.init(nibName: nil, bundle: nil)
        self.deviceModel = deviceModel
        videoRatio = getVideoRatio()
    }
    
    private func getVideoRatio() -> CGFloat {
        return (deviceModel?.isFourByThree() ?? false) ? (4.0 / 3.0) : (A4xBaseSysDeviceManager.isIpad ? 9.0 / 16.0 : 16.0 / 9.0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logDebug("-----------> viewDidLoad func")
        self.view.backgroundColor = .black
        self.videoView.isHidden = false
        mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: deviceModel?.serialNumber ?? "", customParam: ["isAPMode" : deviceModel?.apModeType == .AP])
        
        // 注册进入后台
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // 注册进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(enterActiveGround), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    var deviceModel: DeviceBean?
    
    var mLivePlayer: LivePlayer?
    
    var videoRatio: CGFloat = 16.0 / 9.0 {
        didSet {
        }
    }
    
    var currentStartPlayDate : Date?
    var nextCanPlayData : ((Date?) -> (Date ,A4xVideoTimeModel?))?
    /// 定义SD全屏返回的block
    var isBackFromSDFullBlock : ((Bool) -> Void)?
    var endPlayDate : TimeInterval = Date().timeIntervalSince1970

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        A4xAppSettingManager.shared.interfaceOrientations = .landscape
        //videoView.alpha = 1
        mLivePlayer?.setListener(liveStateListener: self)
    }
    
    // 禁止自动旋转
    override var shouldAutorotate : Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 横竖屏切换处理
        //videoView.alpha = 0
        mLivePlayer?.sendLiveMessage(customParam: ["videoScale": A4xPlayerViewScale.aspectFit])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.a4xAfter(0.1) {
            self.mLivePlayer?.zoomEnable = true
            if let state = self.mLivePlayer?.state {
                if state == A4xPlayerStateType.playing.rawValue {
                    self.mLivePlayer?.sendLiveMessage(customParam: ["videoScale" : A4xPlayerViewScale.aspectFill, "live_player_type" : "sd_full"])
                }
                self.mLivePlayer?.updateLiveState()
            }
            self.videoView.audioEnable = self.mLivePlayer?.getAudioEnable() ?? false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 进入到后台
    @objc func enterBackGround() {
        logDebug("-----------> \(type(of: self)) enterBackGround")
        self.mLivePlayer?.stopSdcard()
    }
    
    // 进入到前台
    @objc func enterActiveGround() {
        logDebug("-----------> \(type(of: self)) enterActiveGround")
        self.videoPlay()
    }
    
    
    lazy var videoView: A4xSDLocalVideoFullView = {
        let vc = A4xSDLocalVideoFullView(model: self.deviceModel ?? DeviceBean())
        vc.protocol = self
        vc.backgroundColor = UIColor.black
        self.view.addSubview(vc)
        
        vc.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
            if A4xBaseSysDeviceManager.isIpad && !(deviceModel?.isFourByThree() ?? true) {
                make.width.equalTo(self.view.snp.width)
                make.height.equalTo(vc.snp.width).multipliedBy(videoRatio)
            } else {
                make.height.equalTo(self.view.snp.height)
                make.width.equalTo(vc.snp.height).multipliedBy(videoRatio)
            }
        })
        return vc
    }()
    
    
}

extension A4xSdVideoFullVideoViewController : ILiveStateListener {
    func onRenderView(surfaceView: UIView) {
        self.videoView.videoView = surfaceView
    }
    
    func onDeviceMsgPush(code: Int) {
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
            message = A4xBaseManager.shared.getLocalString(key: "sdcard_has_no_video")
            break
        case -3:
            message = A4xBaseManager.shared.getLocalString(key: "sdcard_need_format")
            break
        case -4:
            message = A4xBaseManager.shared.getLocalString(key: "SDcard_video_viewers_limit")
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
    
    // 直播结果回调处理 凹
    func onPlayerState(stateCode: Int, msg: String) {
        guard let device = self.deviceModel else {
            return
        }
        self.videoView.videoState = (stateCode, device.serialNumber)
        if stateCode == A4xPlayerStateType.playing.rawValue {
            self.videoView.audioEnable = self.mLivePlayer?.getAudioEnable() ?? false
        }
    }
    
    // 录屏结果回调处理 凹
    func onRecordState(state: Int, videoPath: String) {
        let s = A4xPlayerRecordState.init(rawValue: state)
        switch s {
        case .start:
            self.videoView.recordState = .start
        case .end:
            A4xBasePhotoManager.default().save(videoPath: videoPath) { (result, id) in
                if result {
                    self.live_record_video(result: true, stop_way: "stop")
                    UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "record_success"))
                } else {
                    UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "record_failed"))
                }
            }
            self.videoView.recordState = .stop
        case .startError:
            self.videoView.recordState = .stop
        case .endError:
            self.videoView.recordState = .stop
        case .none: break
        }
    }
    
    func onCurrentSdRecordTime(time: TimeInterval) {
        currentStartPlayDate = Date(timeIntervalSince1970: time)
    }
    
    public func onMagicPixProcessState(status: Int) {
        
    }
    
    public func onProcessImage(_ inputImageData: UnsafeMutablePointer<UInt8>!, w imageWidth: Int32, h imageHeight: Int32, cb callback: ImageAlgorithmCallBack!) {
 
    }
    
    public func onProcessVideoStream_yuv(_ y: UnsafeMutablePointer<UInt8>!, u: UnsafeMutablePointer<UInt8>!, v: UnsafeMutablePointer<UInt8>!, w frameWidth: Int32, h frameHeight: Int32, cb callback: VideoStreamAlgorithmCallback!) {
 
    }
}

extension A4xSdVideoFullVideoViewController : A4xSDLocalVideoFullViewProtocol {
    func videoPlay() {
        logDebug("-----------> A4xSdVideoFullVideoViewController videoPlay func")
        guard let (date, playData) = self.nextCanPlayData?(currentStartPlayDate) else {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "sd_no_data_date"))
            return
        }
        
        if playData == nil {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "sd_no_data_date"))
            return
        }
        
        self.mLivePlayer?.startSdcard(startTime: date.timeIntervalSince1970, hasData: playData != nil, audio: true, customParam: ["videoScale" : A4xPlayerViewScale.aspectFit, "live_player_type" : "sd_full"])
    }
    
    /// SD视频全屏返回
    func videoBarBackAction() {
        if self.mLivePlayer?.isRecord ?? false {
            videoRecordVideo(start: false)
        }
        self.isBackFromSDFullBlock?(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func videoVolumeAction(enable: Bool) {
        self.live_mute_switch_click(enable: enable)
        self.mLivePlayer?.audioEnable(enable: enable)
    }
    
    func videoScreenShot(view: UIView) {
        self.mLivePlayer?.screenShot(onSuccess: { [weak self]  _code, msg, image in
            guard image != nil else {
                return
            }
            A4xBasePhotoManager.default().save(image: image!, result: { (result, att) in
                logDebug("A4xBasePhotoManager save \(result) id \(att ?? "")");
                if result {
                    self?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "record_success"))
                } else {
                    self?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "shot_fail"))
                }
            })
        }, onError: { code, msg in
            
        })
    }
    
    func videoRecordVideo(start: Bool) {
        // 检测是否有录制权限
        A4xBasePhotoManager.default().checkAuthor { [weak self] (error) in
            if error == .no {
                if start {
                    self?.live_record_video(result: true)
                    self?.mLivePlayer?.startRecord(path: NSHomeDirectory() + "/Documents/webrtcTmp.mp4")
                } else {
                    self?.mLivePlayer?.stopRecord()
                }
            } else {
                if error == .reject {
                    self?.live_record_video(result: false, error_msg: "Recording failed. Recording permission is denied", stop_way: "error")
                }
                A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.photo) { (f) in
                }
            }
        }
    }
    
    func videoFull() {
        if self.mLivePlayer?.isRecord ?? false {
            videoRecordVideo(start: false)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func setSDMagicPixEnable(enable: Bool) {
        mLivePlayer?.magicPixEnable(enable: enable)
    }
}

// 埋点
extension A4xSdVideoFullVideoViewController {
    
    // 打点事件（静音）
    private func live_mute_switch_click(enable: Bool) {
//        let playVideoEM = A4xPlayVideoEventModel()
//        playVideoEM.live_player_type = UserDefaults.standard.string(forKey: "live_player_type")
//        playVideoEM.switch_status = "\(enable)"
//        playVideoEM.connect_device = deviceModel?.serialNumber
//        A4xEventManager.liveViewEvent(event:A4xEventLiveViewType.live_mute_switch_click(eventModel: playVideoEM))
    }
    
    // 打点事件（video recording）
    private func live_record_video(result: Bool, error_msg: String? = "", stop_way: String? = "") {
//        let playVideoEM = A4xPlayVideoEventModel()
//        playVideoEM.live_player_type = "fullscreen"
//        playVideoEM.result = "\(result)"
//        playVideoEM.error_msg = error_msg
//        playVideoEM.stop_way = stop_way
//        playVideoEM.storage_space = UIDevice.current.freeDiskSpaceInGB
//        A4xEventManager.liveViewEvent(event:A4xEventLiveViewType.live_record_video(eventModel: playVideoEM))
    }
}

