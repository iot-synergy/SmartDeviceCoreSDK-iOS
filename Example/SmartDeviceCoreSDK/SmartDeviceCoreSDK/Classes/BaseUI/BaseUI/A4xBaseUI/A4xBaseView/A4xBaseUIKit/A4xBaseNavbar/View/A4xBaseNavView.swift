//


//


//


import UIKit

public protocol A4xBaseNavProtocol {
    
    var title : String?{
        set get
    }
    var leftItem : A4xBaseNavItem?{
        set get
    }
    var rightItem : A4xBaseNavItem?{
        set get
    }
    var rightClickBlock : (() -> Void)? {
        set get
    }
    var leftClickBlock : (() -> Void)? {
        set get
    }
    
    func hideLeft(_ isHidden : Bool )
    
    func hideRight(_ isHidden : Bool )
}

public let ItemWidth = 115.0
public let ItemHeight = 44.0
public let ItemLandscapeHeight = 24.0

open class A4xBaseNavView : UIView , A4xBaseNavProtocol {
    
    open var landscape : Bool = false {
        didSet {
            updateFrame()
        }
    }
    
    open var title: String?{
        didSet {
            self.titleLab?.text = title
        }
    }
    
    open var leftItem: A4xBaseNavItem?{
        didSet {
            self.leftBtn?.navItem = leftItem
        }
    }
    
    open var rightItem: A4xBaseNavItem?{
        didSet {
            self.rightBtn?.navItem = rightItem
        }
    }
    
    open var titleColor : UIColor = ADTheme.C1{
        didSet {
            self.titleLab?.textColor = titleColor
        }
    }
    
    open var landscapeTitleColor : UIColor = UIColor.white
    
    open var subtitle: String?{
        didSet {
            self.subtitleLab?.text = subtitle
            self.updateFrame()
        }
    }
    
    open var showTitleLabel: Bool? {
        didSet {
            self.titleLab?.isHidden = !(showTitleLabel ?? false)
            updateFrame()
        }
    }
    
    open var showSubtitleLabel: Bool? {
        didSet {
            self.subtitleLab?.isHidden = !(showSubtitleLabel ?? false)
        }
    }
    
    open override var backgroundColor: UIColor? {
        didSet {
            self.bgImageV?.image = nil
            self.bgImageV?.backgroundColor = backgroundColor
        }
    }
    
    open var bgImage : UIImage? {
        didSet {
            self.bgImageV?.image = bgImage
        }
    }
    
    open var rightClickBlock: (() -> Void)?
    
    open var leftClickBlock: (() -> Void)?
    
    open func hideLeft(_ isHidden : Bool = false) {
        self.leftBtn?.isHidden = isHidden
    }
    
    open func hideRight(_ isHidden : Bool = false) {
        self.rightBtn?.isHidden = isHidden
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.bgImageV?.isHidden = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func leftBtnAction() {
        if leftClickBlock != nil {
            self.leftClickBlock!()
        }
    }
    
    @objc
    func rightBtnAction() {
        if rightClickBlock != nil {
            self.rightClickBlock!()
        }
    }
    
    private func updateFrame() {
        self.titleLab?.textAlignment = landscape ? .left : .center
        self.titleLab?.textColor = landscape ? self.landscapeTitleColor : self.titleColor

        let top = landscape ? UIScreen.horStatusBarHeight : UIScreen.statusBarHeight
        var titleTop = top
        if self.subtitle?.count ?? 0 > 0 {
            titleTop -= 10
        }
        let itHeight = landscape ? ItemLandscapeHeight : ItemHeight
        let left = 0
        
        var leftWidth : Double = landscape ? 120.auto() : ItemWidth//Double(self.leftBtn!.sizeThatFits(CGSize(width: 100, height: 40)).width + 20)
        var rightWidth : Double = landscape ? 200.auto() : ItemWidth 

        if !(showTitleLabel ?? true) {
            leftWidth = UIScreen.width/2
            rightWidth = UIScreen.width/2
        }
        
        self.leftBtn?.snp.updateConstraints({ (make) in
            make.leading.equalTo(left)
            make.top.equalTo(top)
            make.size.equalTo(CGSize(width: leftWidth, height: itHeight))
        })
        
        self.rightBtn?.snp.updateConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-left)
            make.top.equalTo(top)
            make.size.equalTo(CGSize(width: rightWidth, height: itHeight))
        })
        
        self.titleLab?.snp.updateConstraints({ (make) in
            make.top.equalTo(titleTop)
            make.height.equalTo(itHeight)
        })

    }
    
    private func navtionHeight() -> CGFloat {
        return landscape ? UIScreen.horNavBarHeight : UIScreen.navBarHeight
    }
    
    public lazy var leftBtn : A4xBaseNavBarButton? = {
        let temp = A4xBaseNavBarButton()
        temp.contentHorizontalAlignment = .left
        temp.titleLabel?.font = ADTheme.H4

        temp.imageView?.contentMode = .scaleAspectFit
        temp.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        temp.addTarget(self, action: #selector(leftBtnAction), for: UIControl.Event.touchUpInside)
        self.addSubview(temp)
        let top = landscape ? UIScreen.horStatusBarHeight : UIScreen.statusBarHeight
        let itHeight = landscape ? ItemLandscapeHeight : ItemHeight
        let left = landscape ? 15 : 0

        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(left)
            make.top.equalTo(top)
            make.size.equalTo(CGSize(width: ItemWidth, height: itHeight))
        })
        return temp
    } ()

    public lazy var rightBtn : A4xBaseNavBarButton? = {
        let temp = A4xBaseNavBarButton()
        temp.titleLabel?.font = ADTheme.H4
        temp.contentHorizontalAlignment = .right
        temp.imageView?.contentMode = .scaleAspectFit
        temp.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        temp.addTarget(self, action: #selector(rightBtnAction), for: UIControl.Event.touchUpInside)
        self.addSubview(temp)
        
        let left = landscape ? 15 : 0
        let top = landscape ? UIScreen.horStatusBarHeight : UIScreen.statusBarHeight
        let itHeight = landscape ? ItemLandscapeHeight : ItemHeight
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.snp.trailing).offset(-left)
            make.top.equalTo(top)
            make.width.equalTo(ItemWidth)
            make.height.equalTo(itHeight)
        })
        return temp
    } ()
    
    private lazy var titleLab: UILabel? = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.textColor = UIColor.black
        temp.backgroundColor = UIColor.clear
        temp.textColor = landscape ? UIColor.white : UIColor.black
        temp.font = ADTheme.H2
        self.insertSubview(temp, at: 1)
        let top = landscape ? UIScreen.horStatusBarHeight : UIScreen.statusBarHeight
        let left = landscape ? 15 : 0
        let itHeight = landscape ? ItemLandscapeHeight : ItemHeight
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(ItemWidth / 2 )
            make.trailing.equalTo(self.snp.trailing).offset(-(ItemWidth / 2))
            make.top.equalTo(top)
            make.height.equalTo(itHeight)
        })
        
        return temp
    }()
    
    public lazy var subtitleLab: UILabel? = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.textColor = UIColor.lightGray
        temp.font = ADTheme.B2
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(ItemWidth + 6)
            make.trailing.equalTo(self.snp.trailing).offset(-(ItemWidth + 6))
            make.top.equalTo(self.titleLab!.snp.bottom).offset(-11)
        })
        return temp
    }()
    
    lazy private var bgImageV: UIImageView? = {
        let temp = UIImageView()
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.snp.edges)
        })
        return temp
    }()
    
    public lazy var lineView: UIView? = {
        let temp = UIView()
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(0)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(1)
            make.bottom.equalTo(self.snp.bottom)
        })
        
        temp.backgroundColor = ADTheme.C5
        return temp
    }()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
        self.updateFrame()
    }
    
    open override var intrinsicContentSize: CGSize {
        let hasSub = subtitle?.count ?? 0 > 0
        let navHeight = landscape ? UIScreen.horNavBarHeight : UIScreen.navBarHeight
        let totleHeight = hasSub ? navHeight + 2: navHeight
        return CGSize(width: 0, height: totleHeight)
    }
}
