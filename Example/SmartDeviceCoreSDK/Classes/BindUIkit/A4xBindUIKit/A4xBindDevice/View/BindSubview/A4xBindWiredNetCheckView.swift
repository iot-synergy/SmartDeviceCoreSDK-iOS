//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol A4xBindWiredNetworkCheckViewProtocol: class {
    func wiredNetworkCheckNextAction()
}

class A4xBindWiredNetworkCheckView: A4xBindBaseView {
    
    weak var `protocol`: A4xBindWiredNetworkCheckViewProtocol?
    
    var backClick: (()->Void)?
    
    var zendeskChatClick: (()->Void)?
    
    private let gifManager = A4xBaseGifManager(memoryLimit: 50)
    private var gifImage: UIImage?
    
    var connectToInternetCheck: Bool = false {
        didSet {
            if connectToInternetCheck {
                nextBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
                nextBtn.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
            } else {
                nextBtn.setTitleColor(ADTheme.C4, for: .normal)
                nextBtn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .normal)
            }
            let image = nextBtn.currentBackgroundImage
            let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.Theme, by: 0.9)
            nextBtn.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
        }
    }
    
    
    override var datas: Dictionary<String, String>? {
        didSet {
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
    
    
    private lazy var currentView: UIScrollView = {
        var sv: UIScrollView = UIScrollView()
        sv.contentSize = CGSize(width: self.width, height: UIScreen.height - 230.auto())
        let y: CGFloat = sv.bounds.height + 150
        sv.frame = CGRect(x: 0, y: y, width: self.bounds.width, height: sv.bounds.height)
        sv.bounces = true
        sv.isScrollEnabled = true
        sv.alwaysBounceVertical = true
        sv.scrollsToTop = true
        sv.backgroundColor = .clear
        return sv
    }()
    
    lazy var gifGuideImgView: UIImageView = {
        let iv = UIImageView()
        iv.image = bundleImageFromImageName("bind_wired_online_guide")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    
    lazy var connectToInternetCheckBoxBtn: A4xBaseCheckBoxButton = {
        var checkBoxBtn = A4xBaseCheckBoxButton()
        checkBoxBtn.backgroundColor = UIColor.clear
        checkBoxBtn.addx_expandSize(size: 10)
        checkBoxBtn.setImage(image: bundleImageFromImageName("rember_voice_check_unselect")?.rtlImage(), state: A4xBaseCheckBoxState.normail)
        checkBoxBtn.setImage(image: bundleImageFromImageName("rember_voice_check_select"), state: A4xBaseCheckBoxState.selected)
        return checkBoxBtn
    }()
    
    
    lazy var connectToInternetLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "ethernet_internet_failed_check_box")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        //lbl.backgroundColor = .blue
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.regular(14)
        return lbl
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.navView.isHidden = false
        
        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "ethernet_wire_connect_title")
        
        
        titleLbl.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.navView.snp.bottom)
            make.width.equalTo(self.snp.width).offset(-62.auto())
        }
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        let titleHintStr = A4xBaseManager.shared.getLocalString(key: "ethernet_internet_failed_content", param: [tempString])
        
        titleHintTxtView.text(text: titleHintStr, links: ("", "")) {
            height in
        }
        
        titleHintTxtView.textAlignment = .center
        titleHintTxtView.linkTextColor = UIColor(hex: "#3495E8") ?? UIColor.blue
        titleHintTxtView.textColor = UIColor.colorFromHex("#999999")
        titleHintTxtView.font = UIFont.regular(13)
        
        //let titleHintTxtViewHeight = titleHintStr.textHeightFromTextString(text: titleHintStr, textWidth: self.width - 48.auto(), fontSize: 13.auto(), isBold: false)
        titleHintTxtView.snp.remakeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(titleLbl.snp.bottom).offset(8.auto())
            make.width.equalTo(self.snp.width).offset(-48.auto())
            //make.height.equalTo(titleHintTxtViewHeight)
        })
        
        nextBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "next"), for: .normal)
        
        insertSubview(currentView, at: 0)
        
        currentView.addSubview(gifGuideImgView)
        
        addSubview(connectToInternetCheckBoxBtn)
        addSubview(connectToInternetLbl)
        
        nextBtn.isEnabled = true
        
        nextBtn.setTitleColor(ADTheme.C4, for: UIControl.State.disabled)
        
        //nextBtn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        nextBtn.setTitleColor(ADTheme.C4, for: .normal)
        
        //nextBtn.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
        nextBtn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .normal)

        let image = nextBtn.currentBackgroundImage
        let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.Theme, by: 0.9)
        nextBtn.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
        nextBtn.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .disabled)
        
        
        
        currentView.snp.remakeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(0.auto())
            make.leading.equalTo(0)
            make.width.equalTo(UIScreen.width)
            make.height.equalTo(UIScreen.height - UIScreen.navBarHeight)
        }
        
        
        gifGuideImgView.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.titleHintTxtView.snp.bottom).offset(20.5.auto())
            make.size.equalTo(CGSize(width: self.width, height: 250.auto()))
        })
        
        
        let connectToInternetLblWith = min(connectToInternetLbl.getLabelWidth(connectToInternetLbl, height: 30.auto()), UIScreen.width * 0.8)
        connectToInternetLbl.snp.makeConstraints({ make in
            make.centerX.equalTo(nextBtn.snp.centerX).offset(15.auto())
            make.bottom.equalTo(nextBtn.snp.top).offset(-16.auto())
            make.width.equalTo(connectToInternetLblWith)
            make.height.greaterThanOrEqualTo(30.auto())
        })

        
        connectToInternetCheckBoxBtn.snp.makeConstraints({ make in
            make.trailing.equalTo(connectToInternetLbl.snp.leading).offset(-10.auto())
            make.centerY.equalTo(connectToInternetLbl.snp.centerY)
            make.size.equalTo(CGSize(width: 20.auto(), height: 20.auto()))
        })
        
        
        nextBtn.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-42.auto())
            make.height.equalTo(50.auto())
            if #available(iOS 11.0,*) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-20.auto())
            }else {
                make.bottom.equalTo(self.snp.bottom).offset(-25.auto())
            }
        }
        
        
        connectToInternetCheckBoxBtn.addTarget(self, action: #selector(connectToInternetCheckBoxAction(sender:)), for: UIControl.Event.touchUpInside)
        
        
        connectToInternetLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(connectToInternetLblClick)))
        
        
        nextBtn.addTarget(self, action: #selector(nextAction(sender:)), for: .touchUpInside)
    }
    
    
    @objc private func connectToInternetCheckBoxAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        connectToInternetCheck = sender.isSelected
    }
    
    
    @objc private func connectToInternetLblClick() {
        connectToInternetCheck = !connectToInternetCheck
        connectToInternetCheckBoxBtn.isSelected = connectToInternetCheck
    }
    
    @objc private func nextAction(sender: UIButton) {
        if connectToInternetCheck {
            self.protocol?.wiredNetworkCheckNextAction()
        } else {
            connectToInternetAlert()
        }
    }
    
    
    
    private func connectToInternetAlert() {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.Theme
        config.rightTextColor = UIColor.white
        weak var weakSelf = self
        
        let alert = A4xBaseAlertView(param: config, identifier: "show Save Alert")
        alert.message = A4xBaseManager.shared.getLocalString(key: "ethernet_wire_connect_confirm_window")
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "no")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "yes")
        alert.rightButtonBlock = {
            weakSelf?.protocol?.wiredNetworkCheckNextAction()
        }
        
        alert.leftButtonBlock = {
            
        }
      
        alert.show()
    }
    
}
