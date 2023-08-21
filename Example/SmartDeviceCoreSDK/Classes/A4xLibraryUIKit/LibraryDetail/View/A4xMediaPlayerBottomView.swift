//


//


//
import UIKit
import SmartDeviceCoreSDK
import BaseUI

public enum A4xMediaPlayerItemType : Int {
    case delete     = 1000
    case share      = 1001
    case mark       = 1002
    case download   = 1003

    public static func sdStyle() -> Set<A4xMediaPlayerItemType> {
        return Set(arrayLiteral: share,download)
    }
    
    public static func defaultStyle() -> Set<A4xMediaPlayerItemType>{
        return Set(arrayLiteral: delete,download)
    }
    
    public static func `default`() -> Set<A4xMediaPlayerItemType>{
        return Set(arrayLiteral: delete,share,download,mark)
    }
}

public class A4xMediaPlayerBottomView: UIView {
    
    public var bottomSelectBlock: ((A4xMediaPlayerItemType) -> Void)?
    
    public var styleItem: Set<A4xMediaPlayerItemType> {
        didSet {
            updateItems()
        }
    }
    
    public func updateItems() {
        self.subviews.forEach { (view) in
            if view is A4xMediaPlayerBarItem {
                view.snp.removeConstraints()
                view.isHidden = true
            }
        }
        
        var proBy:Float = 0.0
        proBy = 1.0 / Float(max(styleItem.count, 1)) 
        
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
    
    lazy var lineView: UIView = {
        let tem: UIView = UIView()
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
    
    lazy var deleteView: A4xMediaPlayerBarItem = {
        let tem: A4xMediaPlayerBarItem = A4xMediaPlayerBarItem()
        tem.highlightedSelected = false
        self.addSubview(tem)
        tem.barType = .delete
        tem.imageName = "resouce_bottom_white_delete" 
        tem.nameTitle = A4xBaseManager.shared.getLocalString(key: "delete")
        tem.selectBlock = { [weak self] (result) in
            self?.selectType(type: result)
        }
        return tem
    }()
    
    lazy var shareView: A4xMediaPlayerBarItem = {
        let tem: A4xMediaPlayerBarItem = A4xMediaPlayerBarItem()
        tem.highlightedSelected = false
        tem.barType = .share
        tem.imageName = "resouce_bottom_white_share"
        tem.nameTitle = A4xBaseManager.shared.getLocalString(key: "share")
        tem.selectBlock = { [weak self] (result) in
            self?.selectType(type: result)
        }
        self.addSubview(tem)
        return tem
    }()
    
    lazy var downloadView: A4xMediaPlayerBarItem = {
        let tem: A4xMediaPlayerBarItem = A4xMediaPlayerBarItem()
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
    
    lazy var markView: A4xMediaPlayerBarItem = {
        let tem: A4xMediaPlayerBarItem = A4xMediaPlayerBarItem()
        tem.highlightedSelected = false
        tem.barType = .mark
        tem.imageName = "main_libary_unmark_white_mark_icon"
        tem.nameTitle = A4xBaseManager.shared.getLocalString(key: "mark")
        tem.selectBlock = { [weak self] (result) in
            self?.selectType(type: result)
        }
        self.addSubview(tem)
        return tem
    }()
    
    private func selectType(type: A4xMediaPlayerItemType) {
        if self.bottomSelectBlock != nil {
            self.bottomSelectBlock?(type)
        }
    }
    
    init(items: Set<A4xMediaPlayerItemType>) {
        self.styleItem = items
        super.init(frame: CGRect.zero)
        self.backgroundColor = ADTheme.Theme
        self.deleteView.isHidden = true
        self.shareView.isHidden = true
        self.downloadView.isHidden = true
        self.markView.isHidden = true
        self.lineView.isHidden = true
        updateItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
