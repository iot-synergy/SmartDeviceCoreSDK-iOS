//


//


//

import UIKit
//import SwiftyGif
import AudioToolbox
import AVFoundation
import SmartDeviceCoreSDK
import BaseUI

protocol A4xBindDingDongVoiceGuideViewProtocol: class {
    func hearNothing()
    func dingDongVoiceGuideViewNextAction()
    func dingDongPlayClick()
}

class A4xBindDingDongVoiceGuideView: A4xBindBaseView {
    
    weak var `protocol`: A4xBindDingDongVoiceGuideViewProtocol?
    
    var backClick: (()->Void)?
    
    var zendeskChatClick: (()->Void)?
    
    private let gifManager = A4xBaseGifManager(memoryLimit: 50)
    private var gifImage: UIImage?
    
    private var alreadyHeadVoiveGuideCheck: Bool = false {
        didSet {
            if alreadyHeadVoiveGuideCheck {
                nextBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
                nextBtn.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
            } else {
                nextBtn.setTitleColor(ADTheme.C4, for: .normal)
                nextBtn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .normal)
            }
            let image = nextBtn.currentBackgroundImage //UIImage.buttonNormallImage
            let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.Theme, by: 0.9)
            nextBtn.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
        }
    }
    
    private var audioPlay: AVAudioPlayer!
    var openAudio: Bool = false {
        didSet {
            self.playAudio(open: openAudio)
        }
    }
    
    override var datas: Dictionary<String, String>? {
        didSet {
            
            if !(datas?["nextTitle"]?.isBlank ?? true) {
                nextBtn.setTitle(datas?["nextTitle"], for: .normal)
            }
        }
    }
    
    private var audioAniEnable: Bool = false {
        didSet {
            if audioAniEnable {
                voiceTipsImgView.startAnimating()
            } else {
                voiceTipsImgView.stopAnimating()
            }
        }
    }
    
    lazy var navView: A4xBaseNavView = {
        let temp = A4xBaseNavView()
        temp.backgroundColor = .clear//UIColor.white
        temp.lineView?.isHidden = true
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(0)
            make.trailing.equalTo(self.snp.trailing)
            make.top.equalTo(0)
        })
        
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        temp.leftItem = leftItem
        
        temp.leftClickBlock = { [weak self] in
            self?.backClick?()
        }
        

        return temp
    }()
    
    //
    lazy var voiceTipsImgView: UIImageView = {
        let iv = UIImageView()
        iv.image = bundleImageFromImageName("scan_qrcode_voice_3")?.rtlImage()
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    //
    lazy var gifVoiceTipsImgView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    
    
    lazy var alreadyHeadVoiceCheckBoxBtn: A4xBaseCheckBoxButton = {
        var checkBoxBtn = A4xBaseCheckBoxButton()
        checkBoxBtn.backgroundColor = UIColor.clear
        checkBoxBtn.addx_expandSize(size: 10)
        checkBoxBtn.setImage(image: bundleImageFromImageName("rember_voice_check_unselect")?.rtlImage(), state: A4xBaseCheckBoxState.normail)
        checkBoxBtn.setImage(image: bundleImageFromImageName("rember_voice_check_select"), state: A4xBaseCheckBoxState.selected)
        return checkBoxBtn
    }()
    
    
    lazy var alreadyHeadVoiceLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "heard_scaning_sound")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    
    var isHearNothingLaterClick: Bool = true
    lazy var hearNothingLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "did_not_hear_scanning_sound")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.Theme
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = .white
        self.isUserInteractionEnabled = true
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (self.isUserInteractionEnabled == false || self.isHidden == true || self.alpha <= 0.01) { return nil }
        if !self.point(inside: point, with: event) { return nil }
        let count = self.subviews.count
        for i in (0...count - 1).reversed() {
            let childV = self.subviews[i]
            let childP = self.convert(point, to: childV)
            let fitView = childV.hitTest(childP, with: event)
            if (fitView != nil) {
                return fitView
            }
        }
        return self
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.bounds.offsetBy(dx: 20, dy: 20).contains(point) {
            return true
        }
        return false
    }
    
    private func setupUI() {
        
        self.navView.isHidden = false
        
        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "confirm_scanning_sound")
    
        titleHintTxtView.text(text:A4xBaseManager.shared.getLocalString(key: "ding_dong"), links: (ChildStr: "", LinksURL: "")) {
            height in
        }
        titleHintTxtView.textAlignment = .center
        titleHintTxtView.textColor = ADTheme.Theme
        titleHintTxtView.font = UIFont.heavy(16)
        //titleHintTxtView.backgroundColor = .blue
        
        gifImage = UIImage(gifName: "qrcode_voice.gif")
        self.gifVoiceTipsImgView.setGifImage(gifImage ?? UIImage(gifName: "qrcode_voice.gif"), manager: gifManager, loopCount: -1)
        
        let alreadyHeadVoiceStr = A4xBaseManager.shared.getLocalString(key: "heard_scaning_sound")
        let attrString = NSMutableAttributedString(string:alreadyHeadVoiceStr)
        let param = NSMutableParagraphStyle()
        param.alignment = .left
        attrString.addAttribute(.paragraphStyle, value: param, range: NSRange(location: 0, length: attrString.string.count))
        attrString.addAttribute(.font, value: UIFont.regular(14), range: NSRange(location: 0, length: attrString.string.count))
        attrString.addAttribute(.foregroundColor, value: ADTheme.C1, range: NSRange(location: 0, length: attrString.string.count))
        
        alreadyHeadVoiceLbl.attributedText = attrString
        
        nextBtn.isEnabled = true
        
        nextBtn.setTitleColor(ADTheme.C4, for: UIControl.State.disabled)
        nextBtn.setTitleColor(ADTheme.C4, for: .normal)
        nextBtn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .normal)
        let image = nextBtn.currentBackgroundImage
        let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.Theme, by: 0.9)
        nextBtn.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
        nextBtn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .disabled)
        
        var images: Array<UIImage> = []
        for i in 0 ..< 4 {
            let imageName = "scan_qrcode_voice_\(i)"
            let image = bundleImageFromImageName(imageName)?.rtlImage()
            images.append(image ?? UIImage())
        }
        
        //设置图像视图的动画图片属性
        voiceTipsImgView.animationImages = images
        //设置帧动画的时长为1.6秒
        voiceTipsImgView.animationDuration = 1.55
        //设置动画循环次数，0为无限播放
        voiceTipsImgView.animationRepeatCount = 0
        //开始动画的播放
        //voiceTipsImgView.startAnimating()
        //voiceTipsImgView.stopAnimating()
        
        addSubview(voiceTipsImgView)
        addSubview(gifVoiceTipsImgView)
        addSubview(alreadyHeadVoiceCheckBoxBtn)
        addSubview(alreadyHeadVoiceLbl)
        addSubview(hearNothingLbl)
        
        
        titleLbl.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.navView.snp.bottom).offset(0)
            make.width.equalTo(self.snp.width).offset(-62.auto())
        }
        
        
        titleHintTxtView.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX).offset(-17.5.auto())
            make.top.equalTo(self.titleLbl.snp.bottom).offset(9.auto())
            make.width.lessThanOrEqualTo(self.snp.width).offset(-88.auto())
        }
        
        
        nextBtn.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-42.auto())
            make.height.equalTo(50.auto())
            make.bottom.equalTo(self.snp.bottom).offset(-81.auto())
        }
        
        
        gifVoiceTipsImgView.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX).offset(0)
            make.centerY.equalTo(self.snp.centerY).offset(-UIScreen.navBarHeight)
            make.size.equalTo(CGSize(width: 165.auto(), height: 165.auto()))
        }
        
        
        voiceTipsImgView.snp.remakeConstraints { make in
            make.centerY.equalTo(titleHintTxtView.snp.centerY).offset(0)
            make.leading.equalTo(titleHintTxtView.snp.trailing).offset(11.auto())
            make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
        }
        
        
        let alreadyHeadVoiceLblWith = min(alreadyHeadVoiceLbl.getLabelWidth(alreadyHeadVoiceLbl, height: 30.auto()), UIScreen.width * 0.8)
        alreadyHeadVoiceLbl.snp.makeConstraints({ make in
            make.centerX.equalTo(nextBtn.snp.centerX).offset(15.auto())
            make.bottom.equalTo(nextBtn.snp.top).offset(-16.auto())
            make.width.equalTo(alreadyHeadVoiceLblWith)
            make.height.greaterThanOrEqualTo(30.auto())
        })
        
        
        alreadyHeadVoiceCheckBoxBtn.snp.makeConstraints({ make in
            make.trailing.equalTo(alreadyHeadVoiceLbl.snp.leading).offset(-10.auto())
            make.centerY.equalTo(alreadyHeadVoiceLbl.snp.centerY)
            make.size.equalTo(CGSize(width: 20.auto(), height: 20.auto()))
        })
        
        
        hearNothingLbl.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom).offset(-33.auto())
            make.width.equalTo(266.5.auto())
        })
        
        voiceTipsImgView.addActionHandler { [weak self] in
            self?.protocol?.dingDongPlayClick()
            self?.openAudio = !(self?.openAudio ?? false)
        }
        
        alreadyHeadVoiceCheckBoxBtn.addTarget(self, action: #selector(alreadyHeadVoiveGuideCheckBoxAction(sender:)), for: UIControl.Event.touchUpInside)
        
        alreadyHeadVoiceLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alreadyHeadVoiveGuideLblClick)))
        
        nextBtn.addTarget(self, action: #selector(dingDongVoiceGuideViewNextAction), for: .touchUpInside)
        
        hearNothingLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hearNothing)))
        
        
    }
    
    @objc private func alreadyHeadVoiveGuideCheckBoxAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        alreadyHeadVoiveGuideCheck = sender.isSelected
    }
    
    @objc private func alreadyHeadVoiveGuideLblClick() {
        alreadyHeadVoiveGuideCheck = !alreadyHeadVoiveGuideCheck
        alreadyHeadVoiceCheckBoxBtn.isSelected = alreadyHeadVoiveGuideCheck
    }
    
    @objc private func hearNothing() {
        self.openAudio = false
        if isHearNothingLaterClick {
            self.protocol?.hearNothing()
            DispatchQueue.main.a4xAfter(5.0) {
                self.isHearNothingLaterClick = false
            }
            return
        }
        self.protocol?.hearNothing()
    }
    
    @objc private func dingDongVoiceGuideViewNextAction() {
        if alreadyHeadVoiveGuideCheck {
            self.openAudio = false
            self.protocol?.dingDongVoiceGuideViewNextAction()
        } else {
            alreadyHeadVoiveGuideAlert()
        }
    }
    
    
    private func playAudio(open: Bool) {
        if open {
            guard let path = a4xBaseBundle().path(forResource: "scan_qrcode", ofType: ".mp3") else {
                return
            }
            let url = NSURL(fileURLWithPath: path)
            audioPlay = try? AVAudioPlayer(contentsOf: url as URL)
            
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try! AVAudioSession.sharedInstance().setActive(true)
            audioPlay.numberOfLoops = -1
            audioPlay.volume = 1
            audioPlay.enableRate = true
            audioPlay.rate = 1
            audioPlay.prepareToPlay()
            audioPlay.play()
            audioAniEnable = true
            return
        }
        audioAniEnable = false
        if audioPlay != nil {
            audioPlay.stop()
        }
    }
    
    
    private func alreadyHeadVoiveGuideAlert() {
        
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.Theme
        config.rightTextColor = UIColor.white
        
        let alert = A4xBaseAlertView(param: config, identifier: "show Save Alert")
        alert.message = A4xBaseManager.shared.getLocalString(key: "bind_device_guide_confirm_window")
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "no")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "yes")
        alert.rightButtonBlock = { [weak self] in
            self?.openAudio = false
            self?.protocol?.dingDongVoiceGuideViewNextAction()
        }
        alert.show()
    }
    
}
