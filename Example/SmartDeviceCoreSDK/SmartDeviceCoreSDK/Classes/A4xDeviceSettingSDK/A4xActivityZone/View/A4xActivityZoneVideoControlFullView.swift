//


//


//

import UIKit
import SmartDeviceCoreSDK
import Resolver
import A4xLiveVideoUIKit
import BaseUI

protocol A4xActivityZoneVideoControlFullViewProtocol : class {
    func videoBarBackAction(zone : ZoneBean , isChange : Bool) 
    func videoReconnect()
    func videoSaveRects(zone : ZoneBean , isChange : Bool)
    func videoDeleteRects(zone : ZoneBean)
}


class A4xActivityZoneVideoControlFullView: UIView {
    weak var `protocol` : A4xActivityZoneVideoControlFullViewProtocol?
    var zonePoint : ZoneBean {
        didSet {
            self.rectView.defaultPoints = zonePoint.verticesPoints()
            self.textFieldView.text = zonePoint.zoneName
            self.rectView.lineColor = self.zonePoint.rectColor ?? A4xBaseActivityZonePointColorsValue[0]

        }
    }
    
    var deviceId: String?

    init(frame: CGRect = .zero , editModle : Bool = false) {
        self.editModle = editModle
        self.zonePoint = ZoneBean()

        super.init(frame: frame)
        self.videoNewView.isHidden = false
        self.noneStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        self.zonePoint = ZoneBean()

        self.editModle = false
        super.init(coder: aDecoder)
    }

    var editModle: Bool

    
    var videoState: (Int, String?)? = (A4xPlayerStateType.paused.rawValue, nil) {
        didSet {
            if oldValue?.0 != videoState?.0 {
                self.videoStateUpdate()
            }
        }
    }
    
    lazy var videoNewView: A4xLiveVideoView = {
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

    lazy var textFieldView: A4xActivityZoneTextField = {
        let temp = A4xActivityZoneTextField()
        temp.backgroundColor = UIColor.clear
        temp.textColor = UIColor.white
        temp.font = ADTheme.H3
        self.addSubview(temp)
        
        let lineV = A4xBaseTextField()
        lineV.backgroundColor = UIColor.white
        temp.addSubview(lineV)
        
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.backButton.snp.centerY)
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(50.auto())
        })
        
        lineV.snp.makeConstraints({ (make) in
            make.width.equalTo(temp.snp.width).offset(24.auto())
            make.height.equalTo(1.auto())
            make.bottom.equalTo(temp.snp.bottom).offset(-10.auto())
            make.centerX.equalTo(temp.snp.centerX)

        })
        return temp
    }()
    
    //MARK:- view 创建
    lazy var loadingView: A4xBaseLoadingView = {
        let temp = A4xBaseLoadingView()
        temp.loadingImg.image = bundleImageFromImageName("live_video_loading")?.rtlImage()
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX).offset(8.auto())
            make.centerY.equalTo(self.snp.centerY)
        })
        return temp
    }()

    lazy var errorView: LiveErrorView = {
        let temp = LiveErrorView(frame: .zero, maxWidth: 500)
        self.addSubview(temp)
        temp.buttonClickAction = { [weak self] type in
            if case .video = type  {
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

    lazy var backButton: UIButton = {
        let temp = UIButton()
        temp.setImage(A4xDeviceSettingResource.UIImage(named: "ac_icon_back_write")?.rtlImage(), for: .normal)
        temp.backgroundColor = UIColor.clear
        self.addSubview(temp)
        temp.addTarget(self, action: #selector(videoBarBackAction), for: UIControl.Event.touchUpInside)
        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let left = 12

        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(left)
            make.top.equalTo(top)
            make.size.equalTo(CGSize(width: 40.auto(), height: 40.auto()))
        })
        return temp
    }()
    
    lazy var doneButton: UIButton = {
        let temp = UIButton()
        temp.setImage(A4xDeviceSettingResource.UIImage(named: "activity_edit_done"), for: .normal)
        temp.addTarget(self, action: #selector(videoDoneAction), for: UIControl.Event.touchUpInside)
        self.addSubview(temp)

        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let right = 12
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-right)
            make.top.equalTo(top)
            make.size.equalTo(CGSize(width: 40.auto(), height: 40.auto()))
        })
        return temp
    }()
    
    lazy var deleteButton: UIButton  = {
        let temp = UIButton()
        temp.setImage(A4xDeviceSettingResource.UIImage(named: "activity_edit_delete")?.rtlImage().tinColor(color: UIColor.white), for: .normal)
        temp.addTarget(self, action: #selector(videoDeleteAction), for: UIControl.Event.touchUpInside)
        self.addSubview(temp)

        let top = UIScreen.horStatusBarHeight
        let itHeight = ItemLandscapeHeight
        let right = 12
        
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-right)
            make.bottom.equalTo(self.snp.bottom).offset(-top)
            make.size.equalTo(CGSize(width: 40.auto(), height: 40.auto()))
        })
        return temp
    }()
    
    lazy var topImageV: UIImageView? = {
        let temp = UIImageView()
        temp.backgroundColor = UIColor.clear
        temp.image = bundleImageFromImageName("video_play_top_share")?.rtlImage()//?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 2, bottom: 0, right: 2))
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.snp.top)
            make.height.equalTo(60.auto())
            make.leading.equalTo(0)
            make.width.equalTo(self.snp.width)
        })
        
        return temp
    }()
    
    lazy var bottomImageV: UIImageView? = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("video_play_bottom_shard_bg")?.rtlImage().resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 1, bottom: 0, right: 1))
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(60.auto())
            make.leading.equalTo(0)
            make.width.equalTo(self.snp.width)
        })
        
        return temp
    }()

    lazy var rectView: A4xPointView = {
        let temp = A4xPointView(frame: .zero, pointNum: 8, isRect: true)
        self.insertSubview(temp, at: 1)
        weak var weakSelf = self
        temp.editMode = { mod in
            weakSelf?.editingStyle(isedit: mod)
        }
        
        temp.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.snp.edges)
        })
        return temp
    }()

    //MARK:- view 创建
    lazy var playBtn: UIButton = {
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

extension A4xActivityZoneVideoControlFullView{

    @objc func connectionVideoAction() {
        self.protocol?.videoReconnect()
    }

    @objc func videoDeleteAction() {
        if zonePoint.serialNumber == nil {
            zonePoint.serialNumber = deviceId
        }

        self.protocol?.videoDeleteRects(zone: self.zonePoint)
    }
    
    @objc func videoDoneAction() {
        let isChange = checkAnSave(isCancle: false)
        _ = textFieldView.resignFirstResponder()
        if isChange.0 {
            self.protocol?.videoSaveRects(zone: self.zonePoint, isChange: isChange.0)
        } else {
            if isChange.1 != "empty" {
                self.protocol?.videoBarBackAction(zone: self.zonePoint, isChange: isChange.0)
            }
        }
    }
    
    @objc func videoBarBackAction() {
        let name = self.textFieldView.text
        guard name?.count ?? 0 > 0 else {
            UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "name_required"))
            return
        }
        
        let isChange = checkAnSave(isCancle: true)
        self.protocol?.videoBarBackAction(zone: self.zonePoint, isChange: isChange.0)
    }
    
    func checkAnSave(isCancle : Bool) -> (Bool, String) {
        var isChange : Bool = true
        var rePoint : [CGPoint] = []
        let width = self.width
        let height = self.height
        let name = self.textFieldView.text

        guard name?.count ?? 0 > 0 else {
            if !isCancle {
                UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "name_required"))
            }
            return (false, "empty")
        }
        
        self.rectView.points.forEach { (rea) in
            rePoint.append(CGPoint(x: rea.x / width , y: rea.y / height ))
        }

        let vers = ZoneBean.pointsToVertices(points: rePoint)

        if name == self.zonePoint.zoneName && vers == self.zonePoint.vertices {
            isChange = false
        } else {
            self.zonePoint.zoneName = name
            self.zonePoint.vertices = vers
            isChange = true
        }
        zonePoint.serialNumber = deviceId






        
        return (isChange, "")
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
            case .updating:
                let err = A4xBaseManager.shared.getLocalString(key: "device_is_updating")
                errorStyle(error: err)
            case .needUpdate:
                break
            case .forceUpdate:
                break
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
        self.rectView.isHidden = false

        self.errorView.isHidden = false
        self.backButton.isHidden = false
        self.doneButton.isHidden = true
        self.deleteButton.isHidden = true
        self.textFieldView.isHidden = true
        self.errorView.error = ""
    }
    
    private func loadingStyle() {
        self.loadingView.startAnimail()
        self.playBtn.isHidden = true
        self.loadingView.isHidden = false
        self.errorView.isHidden = true
        self.backButton.isHidden = false
        self.doneButton.isHidden = true
        self.deleteButton.isHidden = true
        self.rectView.isHidden = true
        self.textFieldView.isHidden = true

    }
    
    private func aiplayingStyle() {
        self.loadingView.stopAnimail()
        self.playBtn.isHidden = true
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.backButton.isHidden = false
        self.doneButton.isHidden = false
        self.deleteButton.isHidden = false
        self.rectView.isHidden = false
        self.textFieldView.isHidden = false
    }
    
    private func playingStyle() {
        self.loadingView.stopAnimail()
        self.playBtn.isHidden = true
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.backButton.isHidden = false
        self.doneButton.isHidden = false
        self.deleteButton.isHidden = false
        self.rectView.isHidden = false
        self.textFieldView.isHidden = false

    }
    
    private func editingStyle(isedit : Bool){
        if self.videoState?.0 != A4xPlayerStateType.playing.rawValue {
            return
        }
        self.textFieldView.isHidden = isedit
        self.backButton.isHidden = isedit
        self.doneButton.isHidden = isedit
        self.deleteButton.isHidden = isedit
    }
    
    private func doneStyle() {
        
    }
    
    private func errorStyle(error: String) {
        self.loadingView.isHidden = true
        self.playBtn.isHidden = true

        self.loadingView.stopAnimail()
        self.errorView.error = error
        self.errorView.isHidden = false
        self.backButton.isHidden = false
        self.doneButton.isHidden = true
        self.deleteButton.isHidden = true
        self.rectView.isHidden = true
        self.textFieldView.isHidden = true

    }
    
    private func pausedStyle() {
        self.loadingView.isHidden = true
        self.errorView.isHidden = true
        self.backButton.isHidden = false
        self.doneButton.isHidden = true
        self.deleteButton.isHidden = true
        self.rectView.isHidden = true
        self.textFieldView.isHidden = true
        self.playBtn.isHidden = false

    }
}
