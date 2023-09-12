

import UIKit
import AutoInch
import SmartDeviceCoreSDK

public class A4xBasePageControlView: UIView {
    
    private var currentPage: NSInteger?
    public var autoPlay: Bool? {
        didSet {
            if self.autoPlay == true {
                self.startAutoPlay()
            }
        }
    }
    
    public var delay: TimeInterval?
    
    public var tipImgs: [UIImage]?
    public var tipStrings: [String]?
    
    public var tipTuple:([String]?, [UIImage]?) {
        didSet {
            setup()
        }
    }

    public var pageCount: Int?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var contentSize: CGSize? {
        didSet {
            updateUI()
        }
    }
    
    public override init(frame:CGRect = .zero) {
        super.init(frame: frame)
    }
    
    public func setup() {
        
        let oneLineHeight = "title".textHeightFromTextString(text: "title", textWidth: self.width - 80.auto(), fontSize: 20.auto(), isBold: false)
        let titleStr = A4xBaseManager.shared.getLocalString(key: "confirm_model_number")
        let itemHeight = titleStr.textHeightFromTextString(text: titleStr, textWidth: self.width - 80.auto(), fontSize: 20.auto(), isBold: false)
        let titleLineCount = Int(itemHeight / oneLineHeight)
        if titleLineCount >= 2 {
            
        }
        
        self.currentPage = 0
        self.pageControl.isHidden = false
        self.pageControl.numberOfPages = tipTuple.1?.count ?? 0
        self.pageControl.currentPage = 0
        self.pageCount = tipTuple.1?.count ?? 0
        
        let width = UIScreen.width
        var height: CGFloat = 0//373.5.auto()
        let imageHeight: CGFloat = 200.auto()
        
        self.scrollView.snp.remakeConstraints { (make) in
            make.left.equalTo(0)
            make.width.equalTo(width)
            make.height.equalTo(404.auto())
            make.top.equalTo(0)
        }
        
        var tipLblHeightArr: [CGFloat] = []
        for i in 0..<(self.tipTuple.1?.count ?? 0) {
            
            let tipIV = UIImageView()
            tipIV.contentMode = .center
            tipIV.image = self.tipTuple.1?[i]
            self.scrollView.addSubview(tipIV)
            tipIV.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.scrollView.snp.centerX).offset(0 + width * CGFloat(i))
                make.top.equalTo(36.auto())
                make.width.height.equalTo(imageHeight)
            }
            
            
            let tipLbl = UILabel()
            tipLbl.numberOfLines = 0
            tipLbl.textAlignment = .center
            tipLbl.font = UIFont.regular(14)
            tipLbl.text = self.tipTuple.0?[i]
            tipLbl.lineBreakMode = .byWordWrapping
            self.scrollView.addSubview(tipLbl)
            tipLbl.snp.makeConstraints { (make) in
                make.top.equalTo(tipIV.snp.bottom).offset(0)
                make.bottom.equalTo(self.pageControl.snp.top).offset(0)
                make.centerX.equalTo(tipIV.snp.centerX)
                make.width.equalTo(self.scrollView.snp.width).offset(-64.auto())
            }
            let tipLblHight = self.tipTuple.0?[i].textHeightFromTextString(text: self.tipTuple.0?[i] ?? "", textWidth: self.width - 64.auto(), fontSize: 14.auto(), isBold: false) ?? 0
            tipLblHeightArr.append(tipLblHight)
        }
        
        height += 36.auto() + imageHeight
        height += tipLblHeightArr.max() ?? 60.auto()
        height = max(height, 404.auto())
        self.scrollView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        self.scrollView.layoutIfNeeded()
        self.scrollView.contentSize = CGSize(width: width * CGFloat(pageCount ?? 1), height: height)
        self.contentSize = CGSize(width: width, height: height + 20.auto())
    }
    
    func updateUI() {
        
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
            make.centerX.equalToSuperview()
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
        return temp
    }()
    
    
    private func getTipAttrString(string: String) -> NSAttributedString {
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
        self.perform(#selector(A4xBasePageControlView.nextPage), with: nil, afterDelay: delay!)
        if self.pageControl.currentPage == 0 { 
        } else { 
        }
    }
    
    @objc func nextPage() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(A4xBasePageControlView.nextPage), object: nil)
        
        var nextPage = self.pageControl.currentPage + 1
        if nextPage < self.pageControl.numberOfPages {} else {
            nextPage = 0
        }
        
        self.scrollView.setContentOffset(CGPoint(x: nextPage * Int(self.scrollView.width) * nextPage, y: 0), animated: true)
        
        self.pageControl.currentPage = nextPage
        self.perform(#selector(A4xBasePageControlView.nextPage), with: nil, afterDelay: delay ?? 4)
    }
    
    @objc func pauseAutoPage() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(A4xBasePageControlView.nextPage), object: nil)
    }
}

extension A4xBasePageControlView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let page = Int(offset) / Int(scrollView.width) //round(offset / max(scrollView.contentSize.width, scrollView.width))
        self.pageControl.currentPage = Int(page)
        //pauseAutoPage()

    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //startAutoPlay()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //startAutoPlay()
    }
}


