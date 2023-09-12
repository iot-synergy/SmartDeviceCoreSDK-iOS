//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xBindScanQRTipsView: UIView {
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.scrollView.isHidden = false
        self.tipLoopView.isHidden = false
        self.scanQRCodeLabel.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit ----->  \(type(of: self))")
    }
    
    var scrollEnable : Bool = true {
        didSet {
            if scrollEnable {
                self.tipLoopView.startAutoPlay()
            }else {
                self.tipLoopView.pauseAutoPage()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tipLoopView.layoutIfNeeded()
        let height = self.tipLoopView.intrinsicContentSize.height + 15.auto()
        let tipHeight = scanQRCodeLabel.sizeThatFits(CGSize(width: self.width - 55.auto(), height: 1000)).height
        
        if (height + tipHeight) < self.height {
            self.scanQRCodeLabel.snp.remakeConstraints { (make) in
                make.centerX.equalTo(self.scrollView.snp.centerX)
                make.top.equalTo(self.tipLoopView.snp.bottom)
                make.width.equalTo(self.scrollView.snp.width)
                if #available(iOS 11.0, *) {
                    make.height.equalTo(max(self.height - height - 20.auto() - self.safeAreaInsets.bottom, tipHeight))
                } else {
                    make.height.equalTo(max(self.height - height - 20.auto() , tipHeight))
                }
            }
            self.scrollView.contentSize = CGSize(width: self.scrollView.width, height: self.scrollView.height)
        } else {
            self.scanQRCodeLabel.snp.remakeConstraints { (make) in
                make.centerX.equalTo(self.scrollView.snp.centerX)
                make.top.equalTo(self.tipLoopView.snp.bottom).offset(10.auto())
                make.width.equalTo(self.scrollView.snp.width)
            }
            self.scrollView.contentSize = CGSize(width: self.scrollView.width, height: (height + tipHeight))
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let temp = UIScrollView()
        temp.showsHorizontalScrollIndicator = false
        temp.showsVerticalScrollIndicator = false
        self.insertSubview(temp, at: 0)
        //temp.rtl_DirectionConfig()
        temp.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.width.equalTo(UIScreen.width - 55.auto())
            make.height.equalTo(self.snp.height)
            make.top.equalTo(0)
        }
        return temp
    }()
    
    private lazy var tipLoopView: A4xBindScrollLoopView = {
        let temp = A4xBindScrollLoopView()
        self.scrollView.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(0)
        }
        return temp
    }()
    
    
    private lazy var scanQRCodeLabel: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "bind_device_skip")
        lbl.isUserInteractionEnabled = true
        lbl.textAlignment = .center
        lbl.backgroundColor = UIColor.clear
        lbl.numberOfLines = 0
        lbl.textColor = ADTheme.C3
        lbl.font = UIFont.regular(16)
        self.scrollView.addSubview(lbl)
        
        lbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.scrollView.snp.centerX)
            make.top.equalTo(self.tipLoopView.snp.bottom)
            make.width.equalTo(self.scrollView.snp.width).offset(-11.auto())
        }
        return lbl
    }()
}

//自定义代理方法
@objc protocol A4xBindScrollLoopViewDelegate: NSObjectProtocol {

}

class A4xBindScrollLoopView: UIView {
    private let gifManager = A4xBaseGifManager(memoryLimit: 60)

    private var currentPage: NSInteger?
    private var autoPlay: Bool?
    private var delay: TimeInterval?
    
    private var tipString: String?
    private var gifImage: UIImage?
    
    var delegate: A4xBindScrollLoopViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        var height: CGFloat = 0
        var imageHeight: CGFloat = 0
        var textHeight: CGFloat = 0
        if let imageSources = self.gifImage?.imageSource {
            if let cgImage = CGImageSourceCreateImageAtIndex(imageSources, 0, nil) {
                imageHeight = UIImage(cgImage: cgImage).size.height / 2
                height = imageHeight + 20.auto()
            }
        }
        
        let width = UIScreen.main.bounds.width - 55.auto()
        if let tipString = self.tipString {
            let attr = self.getTipAttrString(string: tipString)
            textHeight = attr.boundingRect(with: CGSize(width: width - 30.auto(), height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size.height
            height = max(textHeight + 5.auto(), height)
        }
        
        self.scrollView.snp.remakeConstraints { (make) in
            make.left.equalTo(0)
            make.width.equalTo(width)
            make.height.equalTo(height)
            make.top.equalTo(0)
        }
        
        self.gifImageView.snp.remakeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.width.equalTo(self.scrollView.snp.width)
            make.height.equalTo(imageHeight)
        }
        
        self.tipLable.snp.remakeConstraints { (make) in
            make.left.equalTo(self.gifImageView.snp.right).offset(15.auto())
            make.top.equalTo((height - textHeight) / 2  - 5.auto())
            make.width.equalTo(self.scrollView.snp.width).offset(-30.auto())
        }
        self.scrollView.layoutIfNeeded()
        self.scrollView.contentSize = CGSize(width: width * 2, height: height)
        
        return CGSize(width: width, height: height  + 20.auto())
    }
    
    convenience init() {
        self.init(frame: .zero, autoPlay: true, delay: 5, tipString: A4xBaseManager.shared.getLocalString(key: "bind_device_scan"), gifImage: UIImage(gifName: "decive_add_guide.gif"))
    }
    
    init(frame:CGRect = .zero ,autoPlay:Bool = true, delay:TimeInterval = 5 , tipString : String = A4xBaseManager.shared.getLocalString(key: "scan_qr_code_des") , gifImage : UIImage = UIImage(gifName: "decive_add_guide.gif")){
        super.init(frame: frame)
        
        self.gifImage = gifImage
        self.tipString = tipString
        self.autoPlay = autoPlay
        self.delay = delay
        self.currentPage = 0
        self.pageControl.isHidden = false
        self.pageControl.numberOfPages = 2
        self.pageControl.currentPage = 0
        self.tipLable.attributedText = self.getTipAttrString(string: tipString)
        self.gifImageView.setGifImage(gifImage, manager: gifManager, loopCount: 1)
        self.gifTipLable.isHidden = false
        if self.autoPlay == true {
            self.startAutoPlay()
        }
    }
    
    deinit {
        
    }
    
    private lazy var pageControl: UIPageControl = {
        let temp = UIPageControl(frame: .zero)
        temp.isUserInteractionEnabled = false
        temp.pageIndicatorTintColor = ADTheme.C5

        temp.currentPageIndicatorTintColor = ADTheme.Theme
        self.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.width.equalTo(self.snp.width)
        }
        return temp
    }()
    
    private lazy var scrollView: UIScrollView = {
        let temp = UIScrollView()
        temp.delegate = self
        temp.isPagingEnabled = true
        temp.showsHorizontalScrollIndicator = false
        temp.showsVerticalScrollIndicator = false
        self.insertSubview(temp, at: 0)
        //temp.rtl_DirectionConfig()
        return temp
    }()
    
    private lazy var tipLable: UILabel = {
        let temp = UILabel()
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        self.scrollView.addSubview(temp)
        return temp
    }()
    
    private lazy var gifImageView: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        self.scrollView.addSubview(temp)
        return temp
    }()
    
    private lazy var gifTipLable: UILabel = {
        let temp = UILabel()
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        temp.font = ADTheme.B2
        temp.textAlignment = .center
        temp.textColor = ADTheme.C3
        temp.text = A4xBaseManager.shared.getLocalString(key: "distance")
        self.scrollView.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.top.equalTo(self.gifImageView.snp.bottom)
            make.centerX.equalTo(self.gifImageView.snp.centerX)
            make.width.equalTo(self.gifImageView.snp.width).offset(-30.auto())
        }
        
        return temp
    }()
    
    private func getTipAttrString(string : String) -> NSAttributedString {
        let attr = NSMutableAttributedString(string: string)
        attr.addAttribute(NSAttributedString.Key.font, value: ADTheme.B1 , range: NSRange(location: 0, length: attr.string.count))
        attr.addAttribute(NSAttributedString.Key.foregroundColor, value: ADTheme.C1, range: NSRange(location: 0, length: attr.string.count))
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.auto() //大小调整
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping
        attr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attr.string.count))
        return attr
    }

    @objc func startAutoPlay() {
        pauseAutoPage()
        self.perform(#selector(A4xBindScrollLoopView.nextPage), with: nil, afterDelay: delay!)
        if self.pageControl.currentPage == 0 {
            if let gifi = self.gifImage {
                self.gifImageView.setGifImage(gifi, manager: gifManager, loopCount: 1)
                self.gifImageView.startAnimatingGif()
            }
        }else {
            self.gifImageView.showFrameAtIndex(0)
            self.gifImageView.stopAnimatingGif()
        }
    }
    
    @objc func nextPage() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(A4xBindScrollLoopView.nextPage), object: nil)
        var nextPage = self.pageControl.currentPage + 1
        
        if nextPage < self.pageControl.numberOfPages {
        } else {
            nextPage = 0
        }
        
        self.scrollView.setContentOffset(CGPoint(x: nextPage * Int(self.scrollView.width) * nextPage, y: 0), animated: true)
        
        self.pageControl.currentPage = nextPage
        self.perform(#selector(A4xBindScrollLoopView.nextPage), with: nil, afterDelay: delay ?? 4)
    }
    
    @objc func pauseAutoPage() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(A4xBindScrollLoopView.nextPage), object: nil)
    }
}

extension A4xBindScrollLoopView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let page = round(offset / max(scrollView.contentSize.width, scrollView.width))
        self.pageControl.currentPage = Int(page)
        pauseAutoPage()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startAutoPlay()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        startAutoPlay()
    }
}
