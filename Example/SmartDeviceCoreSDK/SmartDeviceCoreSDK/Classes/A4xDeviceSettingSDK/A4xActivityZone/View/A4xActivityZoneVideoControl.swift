//


//


//

import UIKit
import SmartDeviceCoreSDK
import A4xLiveVideoUIKit
import BaseUI

protocol A4xActivityZoneVideoControlProtocol : class {
    func videoBarBackAction() 
    func videoReconnect()
}

class A4xActivityZoneVideoControl : UIView {
    weak var `protocol` : A4xActivityZoneVideoControlProtocol?

    var rectlist : [ZoneBean]? {
        didSet {
            self.videoRectView.dataSource = rectlist
        }
    }

    
    init(frame: CGRect = .zero , editModle : Bool = false) {
        self.editModle = editModle
        super.init(frame: frame)
        self.videoNewView.isHidden = false
        self.videoRectView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.editModle = false
        super.init(coder: aDecoder)
    }
    
    var editModle : Bool
    
    lazy var videoNewView : A4xLiveVideoView = {
        let temp = A4xLiveVideoView()
        temp.clipsToBounds = true
        temp.isUserInteractionEnabled = true
        self.addSubview(temp)

        weak var weakSelf = self
        temp.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.snp.edges)
        })
        return temp
    }()

    
    var videoState : (Int, String?)? = (A4xPlayerStateType.paused.rawValue, nil) {
        didSet {
            
            if oldValue?.0 != videoState?.0 {
                self.videoStateUpdate()
            }
        }
    }
    
    lazy var videoRectView : A4xActivityZoneRectView = {
        let temp = A4xActivityZoneRectView()
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.snp.edges)
        })
        return temp
    }()
    
    //MARK:- view 创建
    lazy var loadingView : A4xBaseLoadingView = {
        let temp = A4xBaseLoadingView()
        temp.loadingImg.image = bundleImageFromImageName("live_video_loading")?.rtlImage()
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX).offset(8.auto())
            make.centerY.equalTo(self.snp.centerY)
        })
        return temp
    }()
    
    lazy var errorView : LiveErrorView = {
        let temp = LiveErrorView(frame: .zero, maxWidth: 500)
        self.addSubview(temp)
        temp.buttonClickAction = {[weak self] type in
            if case .video = type {
                self?.protocol?.videoReconnect()
            }
        }
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: 200, height: 150))
        })
        return temp
    }()

    //MARK:- view 创建
    lazy var playBtn : UIButton = {
        let temp = UIButton()
        temp.setImage(bundleImageFromImageName("video_play")?.rtlImage(), for: UIControl.State.normal)
        temp.addTarget(self, action: #selector(connectionVideoAction), for: .touchUpInside)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
        })
        return temp
    }()

    deinit {
        
    }
}

extension A4xActivityZoneVideoControl{
    @objc private func connectionVideoAction() {
        self.protocol?.videoReconnect()
    }


    func videoStateUpdate() {
        var image : UIImage? = nil
        self.videoNewView.blueEffectEnable = false
        if let state = A4xPlayerStateType(rawValue: self.videoState?.0 ?? A4xPlayerStateType.paused.rawValue) {
            switch state {
            case .loading:
                loadingStyle()
                self.videoNewView.blueEffectEnable = true
            case .playing:
                aiplayingStyle()
                 self.videoNewView.image = nil
                return
            case .needUpdate:
                break
            case .forceUpdate:
                break
            case .updating:
                let err = A4xBaseManager.shared.getLocalString(key: "device_is_updating")
                errorStyle(error: err)
            case .paused:
                pausedStyle()
            case .nonet:
                fallthrough
            case .offline:
                fallthrough
            case .lowerShutDown:
                fallthrough
            case .keyShutDown:
                fallthrough
            case .solarShutDown:
                fallthrough
            case .sleep:
                fallthrough
            case .timeout:
                fallthrough
            case .notRecvFirstFrame:
                fallthrough
            case .apOffline:
                fallthrough
            case .noAuth:
                if let deviceId = self.videoState?.1 {
                    A4xLiveVideoViewModel.playStateUIInfo(state: state, deviceId: deviceId) { [weak self] error, action, icon in
                        if let err = error {
                            self?.errorStyle(error: err)
                        }
                    }
                }
                break
            case .connectionLimit:
                pausedStyle()
                break
            }
        }
        if let deviceId = self.videoState?.1 {
            guard let device = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceId, modeType: .WiFi) else {
                return
            }
            let videoRatio = device.isFourByThree() ? 1 : 0
            image = thumbImage(deviceID: deviceId, videoRatio: videoRatio)
        }
        self.videoNewView.thumbImage = image
    }
    
    private func noneStyle() {
        self.playBtn.isHidden = false
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.videoRectView.isHidden = true
        self.errorView.isHidden = false
        self.errorView.error = ""
        self.loadingView.stopAnimail()
    }
    
    private func loadingStyle() {
        self.playBtn.isHidden = true
        self.loadingView.isHidden = false
        self.videoRectView.isHidden = true
        self.errorView.isHidden = true
        self.loadingView.startAnimail()
    }
    
    private func aiplayingStyle() {
        self.loadingView.stopAnimail()
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.videoRectView.isHidden = false
    }
    
    private func playingStyle() {
        self.loadingView.stopAnimail()
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.videoRectView.isHidden = false
        self.playBtn.isHidden = true
    }
    
    private func doneStyle() {
        
    }
    
    private func errorStyle(error : String) {
        self.loadingView.stopAnimail()
        self.loadingView.isHidden = true
        self.errorView.error = error
        self.loadingView.isHidden = true
        self.errorView.isHidden = false
        self.videoRectView.isHidden = true
        self.playBtn.isHidden = true
    }
    
    private func pausedStyle() {
        self.loadingView.stopAnimail()
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.videoRectView.isHidden = true
        self.playBtn.isHidden = false

    }
}
