//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol A4xBindWiredGuideViewProtocol: class {
    func clickAction(tag: Int)
}

class A4xBindWiredGuideView: A4xBindBaseView {
    
    weak var `protocol`: A4xBindWiredGuideViewProtocol?
    
    var backClick: (()->Void)?
    
    var zendeskChatClick: (()->Void)?
    
    
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
        sv.backgroundColor = .clear //.hex( 0x000000, alpha: 0.5)
        return sv
    }()
    
    lazy var upView: UIView = {
        var v: UIView = UIView()
        v.layer.cornerRadius = 10.5.auto()
        v.backgroundColor = .white
        v.tag = 101
        return v
    }()
    
    lazy var upGuideImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("bind_device_wireless_guide")?.rtlImage()
        return iv
    }()
    
    lazy var upGuideLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "choose_connect_way_wifi")
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.medium(16)
        return lbl
    }()
    
    lazy var upGuideArrowImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("home_user_info_arrow")?.rtlImage()
        return iv
    }()
    
    lazy var downView: UIView = {
        var v: UIView = UIView()
        v.layer.cornerRadius = 10.5.auto()
        v.backgroundColor = .white
        v.tag = 102
        return v
    }()
    
    lazy var downGuideImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("bind_device_wired_guide")?.rtlImage()
        return iv
    }()
    
    lazy var downGuideLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "choose_connect_way_ethernet")
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.medium(16)
        return lbl
    }()
    
    lazy var downGuideArrowImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("home_user_info_arrow")?.rtlImage()
        return iv
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.navView.isHidden = false
        
        titleHintTxtView.isHidden = true
        nextBtn.isHidden = true
        
        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "choose_connect_way_title")
        
        self.addSubview(currentView)
        
        currentView.addSubview(upView)
        upView.addSubview(upGuideImgView)
        upView.addSubview(upGuideLbl)
        upView.addSubview(upGuideArrowImgView)
    
        currentView.addSubview(downView)
        downView.addSubview(downGuideImgView)
        downView.addSubview(downGuideLbl)
        downView.addSubview(downGuideArrowImgView)
        
        
        titleLbl.snp.remakeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.navView.snp.bottom)
            make.width.equalTo(self.snp.width).offset(-62.auto())
        }

        
        currentView.snp.remakeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(0.auto())
            make.leading.equalTo(0)
            make.width.equalTo(UIScreen.width)
            make.height.equalTo(UIScreen.height - UIScreen.navBarHeight)
        }
        
    
        var upViewHeight = 16.auto()
        
        let upGuideLblStr = A4xBaseManager.shared.getLocalString(key: "choose_connect_way_wifi")
        let upGuideLblHeight = upGuideLblStr.textHeightFromTextString(text: upGuideLblStr, textWidth: self.width - 64.auto(), fontSize: 16.auto(), isBold: true)
        
        upGuideLbl.text = upGuideLblStr
        
        upViewHeight += Double(upGuideLblHeight)
        
        upViewHeight += 16.auto()
        
        upViewHeight += 110.auto()
        
        upViewHeight += 22.5.auto()
        
        
        upView.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.currentView.snp.centerY).offset(-5.auto() - UIScreen.navBarHeight)
            make.size.equalTo(CGSize(width: 343.auto() * 0.95, height: upViewHeight * 0.95))
        })
        
        
        upGuideLbl.snp.makeConstraints({ make in
            make.top.equalTo(upView.snp.top).offset(16.auto() * 0.95)
            make.centerX.equalTo(upView.snp.centerX)
            make.width.equalTo(upView.snp.width).offset(-32.auto())
        })
        
        
        upGuideImgView.snp.makeConstraints({ make in
            make.top.equalTo(self.upGuideLbl.snp.bottom).offset(16.auto())
            make.centerX.equalTo(self.upView.snp.centerX)
            make.width.equalTo(187.auto() * 0.95)
            make.height.equalTo(110.auto() * 0.95)
        })
        
        
        upGuideArrowImgView.snp.makeConstraints({ make in
            make.centerY.equalTo(upView.snp.centerY)
            make.trailing.equalTo(upView.snp.trailing).offset(-16.auto())
        })
        
        var downViewHeight = 16.auto()
        
        let downGuideLblStr = A4xBaseManager.shared.getLocalString(key: "choose_connect_way_ethernet")
        let downGuideLblHeight = upGuideLblStr.textHeightFromTextString(text: downGuideLblStr, textWidth: self.width - 64.auto(), fontSize: 16.auto(), isBold: true)
        
        downGuideLbl.text = downGuideLblStr
        
        downViewHeight += Double(downGuideLblHeight)
        
        downViewHeight += 16.auto()
        
        downViewHeight += 110.auto()
        
        downViewHeight += 22.5.auto()

        
        downView.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(upView.snp.bottom).offset(10.auto() * 0.95)
            make.size.equalTo(CGSize(width: 343.auto() * 0.95, height: downViewHeight * 0.95))
        })
        
        
        downGuideLbl.snp.makeConstraints({ make in
            make.top.equalTo(downView.snp.top).offset(16.auto() * 0.95)
            make.centerX.equalTo(downView.snp.centerX)
            make.width.equalTo(downView.snp.width).offset(-32.auto())
        })

        
        downGuideImgView.snp.makeConstraints({ make in
            make.top.equalTo(self.downGuideLbl.snp.bottom).offset(16.auto())
            make.centerX.equalTo(self.downView.snp.centerX)
            make.width.equalTo(187.auto() * 0.95)
            make.height.equalTo(110.auto() * 0.95)
        })
        
        
        downGuideArrowImgView.snp.makeConstraints({ make in
            make.centerY.equalTo(downView.snp.centerY)
            make.trailing.equalTo(downView.snp.trailing).offset(-16.auto())
        })
        
        upView.addOnClickListener(target: self, action: #selector(clickAction(tap:)))
        downView.addOnClickListener(target: self, action: #selector(clickAction(tap:)))
    }
    
    @objc func clickAction(tap: Any) {
        let sender = tap as! UITapGestureRecognizer
        let tag = sender.view?.tag
        
        self.protocol?.clickAction(tag: tag ?? 101)
    }
}


