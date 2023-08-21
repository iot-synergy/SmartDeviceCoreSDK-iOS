//


//


//
import UIKit
import SmartDeviceCoreSDK
import BaseUI

public enum A4xResourceBottomStyle : Int {
    case delete     = 1000
    case share      = 1001
    case download   = 1002
    
    public static func defaultStyle() -> Set<A4xResourceBottomStyle>{
        return Set(arrayLiteral: delete,download)
    }
    
    public static func shareStyle() -> Set<A4xResourceBottomStyle>{
        return Set(arrayLiteral: delete,share,download)
    }
}

public typealias SelectTypeBlock = (A4xResourceBottomStyle) -> Void

public class A4xResourceBottomBarView: UIView {
    
    public var bottomSelectBlock: SelectTypeBlock?
    
    public var enable : Bool = true {
        didSet {
            self.downloadView.isEnabled = enable
            self.deleteView.isEnabled = enable
            self.shareView.isEnabled = enable
        }
    }
    
    public func updateTitle(){
        self.deleteView.nameTitle = A4xBaseManager.shared.getLocalString(key: "delete")
        self.shareView.nameTitle = A4xBaseManager.shared.getLocalString(key: "share")
        self.downloadView.nameTitle = A4xBaseManager.shared.getLocalString(key: "download")
        
    }

    
    public var styleItem: Set<A4xResourceBottomStyle> {
        didSet {
            updateItems()
        }
    }
    
    public func updateItems() {
        
        self.subviews.forEach { (view) in
            if view.tag != 100 {
                view.snp.removeConstraints()
                view.isHidden = true
            }
        }

        let proBy:Float = 1.0 / Float(max(styleItem.count, 1))
        var lastView: UIView? = nil
        let item = styleItem.sorted { (b1, b2) -> Bool in
            return b1.rawValue < b2.rawValue
        }
        
        item.forEach { (style) in
            let view = self.viewWithTag(style.rawValue)
            view?.isHidden = false
            view?.snp.makeConstraints({ (make) in
                make.top.equalTo(self.snp.top)
                make.height.equalTo(self.snp.height)
                make.width.equalTo(self.snp.width).multipliedBy(proBy)
                make.leading.equalTo(lastView == nil ? 0 : lastView!.snp.trailing)
            })
  
            lastView = view
        }
    }
    
    lazy var deleteView: A4xResourceBottomBarItemView = {
        let tem: A4xResourceBottomBarItemView = A4xResourceBottomBarItemView()
        tem.highlightedSelected = false
        self.addSubview(tem)
        tem.barType = .delete
        tem.imageName = "resouce_bottom_white_delete" 
        tem.nameTitle = A4xBaseManager.shared.getLocalString(key: "delete")
        tem.selectBlock = { [weak self] result in
            self?.selectType(type: result)
        }
        return tem
    }()
    
    
    lazy var shareView: A4xResourceBottomBarItemView = {
        let tem: A4xResourceBottomBarItemView = A4xResourceBottomBarItemView()
        tem.highlightedSelected = false
        tem.barType = .share
        tem.imageName = "resouce_bottom_white_share"
        tem.nameTitle = A4xBaseManager.shared.getLocalString(key: "share")
        tem.selectBlock = { [weak self]  result in
            self?.selectType(type: result)
        }
        self.addSubview(tem)
        return tem
    }()
    
    lazy var downloadView: A4xResourceBottomBarItemView = {
        let tem: A4xResourceBottomBarItemView = A4xResourceBottomBarItemView()
        tem.highlightedSelected = false
        tem.barType = .download
        tem.imageName = "resouce_bottom_white_download"
        tem.nameTitle = A4xBaseManager.shared.getLocalString(key: "download")
        tem.selectBlock = { [weak self] (result) in
            self?.selectType(type: result)
        }
        self.addSubview(tem)
        return tem
    }()
    
    lazy var lineView: UIView = {
        let tem: UIView = UIView()
        tem.tag = 100
        tem.backgroundColor = ADTheme.C6
        self.addSubview(tem)
        tem.snp.makeConstraints({ (make) in
            make.top.equalTo(0)
            make.height.equalTo(1)
            make.width.equalTo(self.snp.width)
            make.leading.equalTo( 0)
        })
        return tem
    }()
    
    private func selectType(type: A4xResourceBottomStyle) {
        if self.bottomSelectBlock != nil {
            self.bottomSelectBlock?(type)
        }
    }
    
    init(items: Set<A4xResourceBottomStyle>) {
        self.styleItem = items
        super.init(frame: CGRect.zero)
        self.backgroundColor = ADTheme.Theme
        self.deleteView.isHidden = true
        self.shareView.isHidden = true
        self.downloadView.isHidden = true
        self.lineView.isHidden = false
        updateItems()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
