//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol LiveTopBarViewProtocol: class {
    func deviceSettingAction()
}

class LiveTopBarView: UIView {
    weak var `protocol` : LiveTopBarViewProtocol?
    
    var videoStyle: A4xVideoCellStyle {
        didSet {
            updateViews()
            updataData()
        }
    }
    
    var deviceModel: DeviceBean? {
        didSet {}
    }
    
    //MARK:- 生命周期
    init(frame: CGRect = CGRect.zero, videoStyle: A4xVideoCellStyle = .`default`) {
        self.videoStyle = videoStyle
        
        super.init(frame: frame)
        
        self.nameV?.isHidden = false
        self.state1IV.isHidden     = true 
        self.state2IV.isHidden     = true 
        self.batterV.isHidden      = true 
        self.settingV.isHidden     = true 
        self.updatePoint.isHidden  = true

        self.backgroundColor = UIColor.white
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateViews() {
        
        self.imageV.isHidden = videoStyle != .`default`
        self.state1IV.isHidden = videoStyle != .`default` || !(checkHaveOneState().1 > 0)
        self.state2IV.isHidden = videoStyle != .`default` || !(checkHaveOneState().1 > 1)
        
        self.batterV.isHidden      = videoStyle != .`default` || !(deviceModel?.supperBatter() ?? false)
        self.settingV.isHidden     = videoStyle != .`default`
        
        self.nameV?.snp.updateConstraints({ (make) in
            make.width.lessThanOrEqualTo(videoStyle != .`default` ? 150.auto() : 130.auto())
        })
        
        
        self.nameV?.snp.remakeConstraints({ (make) in
            
            if videoStyle == .`default` {
                make.leading.equalTo(self.imageV.snp.trailing).offset(7.auto())
            } else { 
                make.leading.equalTo(5.auto())
            }
            make.width.lessThanOrEqualTo(videoStyle != .`default` ? 150.auto() : 130.auto())
            
            if checkHaveOneState().0 { 
                make.top.equalTo(8.auto())
            } else { 
                make.centerY.equalTo(self.snp.centerY)
            }
        })
    }
    
    
    private func loadSubStateUI() {
        
        if checkHaveOneState().0 { 
            switch checkHaveOneState().1 {
            case 1: 
                state1IV.isHidden = videoStyle != .`default`
                if checkHaveOneState().2 == 1 {
                    state1IV.image = A4xLiveUIResource.UIImage(named: "homepage_support_motion_detection")?.rtlImage()
                } else {
                    state1IV.image = deviceModel?.wifiStrength().verticalImgValue
                }
                state2IV.isHidden = true
                
                
                self.batterV.isHidden = videoStyle != .`default` || !(deviceModel?.supperBatter() ?? false)
                
                self.batterV.snp.remakeConstraints({ (make) in
                    make.leading.equalTo(self.state1IV.snp.trailing).offset(16.auto())
                    make.width.equalTo(20.auto())
                    make.height.equalTo(12.auto())
                    make.centerY.equalTo(self.state1IV.snp.centerY)
                })
                
                break
            case 2: 
                
                
                state1IV.isHidden = videoStyle != .`default`
                state1IV.image = A4xLiveUIResource.UIImage(named: "homepage_support_motion_detection")?.rtlImage()
                
                
                state2IV.isHidden = videoStyle != .`default`
                state2IV.image = deviceModel?.wifiStrength().verticalImgValue
                
                
                self.batterV.isHidden = videoStyle != .default || !(deviceModel?.supperBatter() ?? false)
                
                self.batterV.snp.remakeConstraints({ (make) in
                    make.leading.equalTo(self.state2IV.snp.trailing).offset(16.auto())
                    make.width.equalTo(20.auto())
                    make.height.equalTo(12.auto())
                    make.centerY.equalTo(self.state1IV.snp.centerY)
                })
                
                break
            default: 
                state1IV.isHidden = true
                state2IV.isHidden = true
                
                
                self.batterV.isHidden = videoStyle != .`default` || !(deviceModel?.supperBatter() ?? false)
                
                self.batterV.snp.remakeConstraints({ (make) in
                    make.leading.equalTo(self.nameV!.snp.leading)
                    make.width.equalTo(20.auto())
                    make.height.equalTo(12.auto())
                    make.centerY.equalTo(self.state1IV.snp.centerY)
                })
                
                break
            }
        }
    }
    
    
    
    private func checkHaveOneState() -> (Bool, Int, Int) {
        var stateCount = 0
        var haveOneState = false
        var oneCountIndex = 0
        
        if isMotionOpen() {
            stateCount += 1
            oneCountIndex = 1
            haveOneState = true
        }
        
        
        if deviceModel?.supportWiFiLevel() ?? false {
            stateCount += 1
            oneCountIndex = 2
            haveOneState = true
        }
        
        
        if deviceModel?.supperBatter() ?? false {
            haveOneState = true
        }
        
        return (haveOneState, stateCount, oneCountIndex)
    }
    
    
    private func isMotionOpen() -> Bool {
        let isMotionOpen = self.deviceModel?.needMotion == 1 ? true : false
        if isMotionOpen {
            return true
        } else {
            return false
        }
    }
    
    //MARK:- view 创建
    func updataData() {
        self.nameV?.text = deviceModel?.deviceName
        
        loadSubStateUI()

        let imageName = (deviceModel?.isAdmin() ?? false) ? "video_add_members" : "video_members"
        let image = A4xLiveUIResource.UIImage(named: imageName)?.rtlImage()
        
        var isOnline = deviceModel?.online ?? 0 == 1

        self.batterV.setBatterInfo(leavel: deviceModel?.batteryLevel ?? 0, isCharging: deviceModel?.isCharging ?? 0, isOnline: isOnline, quantityCharge: deviceModel?.quantityCharge ?? false)
        
        self.imageV.yy_setImage(with: URL(string: self.deviceModel?.smallIcon ?? ""), placeholder: bundleImageFromImageName("device_icon_default")?.rtlImage())
       
        var shouldUpdate = false

        if self.deviceModel?.canUpdate() ?? false {
            if deviceModel?.isAdmin() ?? false {
                shouldUpdate = true
            }
        }
        
        let isde = videoStyle == .`default` && shouldUpdate

        self.updatePoint.isHidden = !isde
    }
    
    
    lazy var imageV: UIImageView = {
        let temp = UIImageView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_imageV"
        temp.contentMode = .scaleAspectFit
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(15.auto())
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
        })
        return temp
    }()
    
    //
    lazy var nameV: UILabel? = {
        let temp = UILabel()
        self.addSubview(temp)
        temp.accessibilityIdentifier = "A4xLiveUIKit_nameV"
        temp.contentHuggingPriority(for: NSLayoutConstraint.Axis.horizontal)
        temp.text = "Camera 1"
        temp.font = ADTheme.B2
        temp.textColor = ADTheme.C1
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(8.auto())
            make.leading.equalTo(self.imageV.snp.trailing).offset(7.auto())
            make.width.lessThanOrEqualTo(130.auto())
        })
        return temp
    }()
    
    
    lazy var state1IV: UIImageView = {
        let temp = UIImageView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_state1IV"
        temp.image = A4xLiveUIResource.UIImage(named: "homepage_support_motion_detection")
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.nameV!.snp.leading)
            make.width.equalTo(16.auto())
            make.height.equalTo(16.auto())
            make.top.equalTo(self.nameV!.snp.bottom).offset(0)
        })
        return temp
    }()
    
    
    lazy var state2IV: UIImageView = {
        let temp = UIImageView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_state2IV"
        temp.image = bundleImageFromImageName("live_video_vertical_wifi_strong")
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.state1IV.snp.trailing).offset(16.auto())
            make.width.equalTo(16.auto())
            make.height.equalTo(16.auto())
            make.centerY.equalTo(self.state1IV.snp.centerY)
        })
        return temp
    }()
    
    
    lazy var batterV: A4xBaseBatteryView = {
        let temp = A4xBaseBatteryView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_batterV"
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.state2IV.snp.trailing).offset(16.auto())
            make.width.equalTo(20.auto())
            make.height.equalTo(12.auto())
            make.centerY.equalTo(self.state1IV.snp.centerY)
        })
        return temp
    }()
    
    lazy var settingV: UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_settingV"
        temp.addTarget(self, action: #selector(settingBtnAction), for: .touchUpInside)
        temp.setImage(A4xLiveUIResource.UIImage(named: "video_setting")?.rtlImage(), for: UIControl.State.normal)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-12.auto())
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize(width: 35.auto(), height: 35.auto()))
        })
        return temp
    }()
    
    lazy var updatePoint: UIView = {
        let temp = UIView()
        temp.accessibilityIdentifier = "A4xLiveUIKit_updatePoint"
        temp.layer.cornerRadius = 3.auto()
        temp.isUserInteractionEnabled = false
        temp.clipsToBounds = true
        temp.backgroundColor = ADTheme.E1
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.settingV.snp.top).offset(4.auto())
            make.trailing.equalTo(self.settingV.snp.trailing).offset(-5.auto())
            make.width.equalTo(6.auto())
            make.height.equalTo(6.auto())
        })
        return temp
    }()

    @objc private func settingBtnAction(){
        self.protocol?.deviceSettingAction()
    }
}
