//


//


//

import Foundation
import SystemConfiguration.CaptiveNetwork
import AudioToolbox
import SmartDeviceCoreSDK
import BaseUI

enum LiveSpeakActionEnum {
    case down
    case up
    case tap
}

protocol A4xHomeDeviceCommandViewProtocol : class {
    func deviceCommandSpeak(type : LiveSpeakActionEnum)
    func deviceCommandRotate() -> Bool
}

class A4xHomeDeviceSpeakButton: UIView, UIGestureRecognizerDelegate {
   
    var touchAction: ((LiveSpeakActionEnum)->Void)?
    var defaultIconColor: UIColor = ADTheme.C6
    
    var selectImage: UIImage?
    
    var nameTitle: String? {
        didSet {
            self.titleLable.text = nameTitle
        }
    }
    
    var generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)

    private lazy var iconImageView: UIButton = {
        let tem: UIButton = UIButton()
        tem.accessibilityIdentifier = "A4xLiveUIKit_iconImageView"
        tem.setImage(A4xLiveUIResource.UIImage(named: "home_video_speak")?.rtlImage(), for: .normal)
        tem.backgroundColor = ADTheme.C6
        tem.isUserInteractionEnabled = false
        tem.cornerRadius = 34.auto()
        tem.clipsToBounds = true
        self.addSubview(tem)
        tem.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.titleLable.snp.top).offset(-8.auto())
            make.width.equalTo(68.auto())
            make.height.equalTo(68.auto())
        }
        return tem
    }()

    private lazy var titleLable: UILabel = {
        let tem: UILabel = UILabel()
        tem.accessibilityIdentifier = "A4xLiveUIKit_titleLable"
        tem.text = "video"
        tem.font = ADTheme.B2
        tem.numberOfLines = 0
        tem.textAlignment = .center
        tem.textColor = UIColor.black
        self.addSubview(tem)

        tem.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom).offset(-8.auto())
            make.width.equalTo(self.snp.width).offset(32.auto())
            make.centerX.equalTo(self.snp.centerX)
        }
        return tem
    }()


    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override var frame: CGRect {
        didSet {
            self.titleLable.text = A4xBaseManager.shared.getLocalString(key: "hold_speak")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLable.isHidden = false
        self.iconImageView.isHidden = false
        self.backgroundColor = UIColor.clear
        
        self.titleLable.text = A4xBaseManager.shared.getLocalString(key: "hold_speak")
        
        let oneTap = UITapGestureRecognizer(target: self, action:#selector(oneClick(sender:)))
        self.addGestureRecognizer(oneTap)
        oneTap.numberOfTapsRequired = 1
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(sender:)))
        longPress.minimumPressDuration = 0.2
        longPress.delegate = self
        self.addGestureRecognizer(longPress)

        oneTap.require(toFail:longPress )
    }
   
    @objc private func oneClick(sender: UITapGestureRecognizer){
        touchAction?(.tap)
        generator.prepare()
        generator.impactOccurred()
    }
    
    @objc private func longTap(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            self.iconImageView.backgroundColor = ADTheme.C5
            self.titleLable.text = A4xBaseManager.shared.getLocalString(key: "release_stop")
            
            touchAction?(.down)
            generator.prepare()
            generator.impactOccurred()
        case .failed:
            fallthrough
        case .cancelled:
            fallthrough
        case .ended:
            touchAction?(.up)
            self.iconImageView.backgroundColor = defaultIconColor
            self.titleLable.text = A4xBaseManager.shared.getLocalString(key: "hold_speak")
        default:
            break
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

class A4xHomeDeviceCommandView: UIView {
    weak var `protocol` : A4xHomeDeviceCommandViewProtocol? = nil
   
    var videoStyle: A4xVideoCellType = .default

    weak var dragTapProtocol: A4xDeviceRockerControlViewProtocol? = nil {
        didSet {
            self.drawTapView.protocol = dragTapProtocol
        }
    }
    
    
    func updateView() {
        switch videoStyle {
        case .default:
            fallthrough
        case .locations:
            fallthrough
        case .locations_edit:
            self.isHidden = true
        //case .options_more:
            //fallthrough
        case .playControl:
            if self.protocol?.deviceCommandRotate() ?? false {
                self.isHidden = false
                self.drawTapView.isHidden = false
                self.speakBtn.isHidden = false
                self.speakBtn.nameTitle = A4xBaseManager.shared.getLocalString(key: "hold_speak")
                speakBtn.snp.remakeConstraints { make in
                    make.top.equalTo(38.auto())
                    make.leading.equalTo(self.drawTapView.snp.trailing).offset(25.auto())
                    make.size.equalTo(CGSize(width: 68.auto(), height: 106.auto()))
                }
            } else {
                self.isHidden = false
                self.drawTapView.isHidden = true
                self.speakBtn.isHidden = false
                self.speakBtn.nameTitle = A4xBaseManager.shared.getLocalString(key: "hold_speak")
                speakBtn.snp.remakeConstraints { make in
                    make.top.equalTo(20.auto())
                    make.centerX.equalToSuperview()
                    make.size.equalTo(CGSize(width: 68.auto(), height: 106.auto()))
                }
            }
        }
    }
    
    private lazy var speakBtn: A4xHomeDeviceSpeakButton = {
        let temp = A4xHomeDeviceSpeakButton()
        temp.accessibilityIdentifier = "A4xLiveSDK_speakBtn"
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.top.equalTo(20.auto())
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 68.auto(), height: 106.auto()))
        }
        temp.touchAction = {[weak self]type in
            
            self?.protocol?.deviceCommandSpeak(type: type)
        }
        return temp
    }()
    
    private lazy var drawTapView: A4xDeviceRockerControlView = {
        let temp = A4xDeviceRockerControlView()
        temp.visableColors = [UIColor.hex(0xEBEBEB), UIColor.hex(0xFAFAFA)]
        temp.lineColor = UIColor.hex(0xDEDEDE)
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 145.auto(), height: 145.auto()))
        }
        return temp
    }()
}


