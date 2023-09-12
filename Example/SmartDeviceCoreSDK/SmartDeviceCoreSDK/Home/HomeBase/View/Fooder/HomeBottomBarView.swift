//

//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public typealias SelectItemBlock = (Int) -> Void

public class HomeBottomBarView: UIView {
    
    
    lazy var barTitleArr: [String] = Array()
    
    var barImgTuple: [(UIImage?, UIImage?)] = Array()
    
    var barIdentifierArr: [String] = Array()
    
    
    public var currentIndex: Int = 0 {
        didSet {
            if currentIndex != oldValue {
                self.bottomSelectBlock?(currentIndex)
            }
            updateSelect()
        }
    }

    public var bottomSelectBlock: SelectItemBlock?

    public func updateInfo() {

        
        for i in 0..<Int(barTitleArr.count) {
            if self.getSubViewByTag(tag: i + 100).count > 0 {
                let subView = self.getSubViewByTag(tag: i + 100)[0] as? HomeBarItemView
                subView?.nameTitle = barTitleArr[i]
            }
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
            make.leading.equalTo(0)
        })
        return tem
    }()


    public init() {
        super.init(frame: CGRect.zero)
        



        
        createBarView()
        self.lineView.isHidden = false
        
        updateSelect()
    }
    
    public func createBarView() {
        
        
        _ = self.subviews.map {
            $0.removeFromSuperview()
        }
        barTitleArr.removeAll()
        barImgTuple.removeAll()
        barIdentifierArr.removeAll()
        
        
        barTitleArr.append(A4xBaseManager.shared.getLocalString(key: "home"))
        barImgTuple.append((bundleImageFromImageName("homepage_video")?.rtlImage(), bundleImageFromImageName("homepage_video_select")?.rtlImage()))
        barIdentifierArr.append("home_video")
        
        
        barTitleArr.append(A4xBaseManager.shared.getLocalString(key: "gallery"))
        barImgTuple.append((bundleImageFromImageName("homepage_libary")?.rtlImage(), bundleImageFromImageName("homepage_libary_select")?.rtlImage()))
        barIdentifierArr.append("libary_video")
        
        barTitleArr.append(A4xBaseManager.shared.getLocalString(key: "mine"))
        barImgTuple.append((bundleImageFromImageName("homepage_user")?.rtlImage(), bundleImageFromImageName("homepage_user_select")?.rtlImage()))
        barIdentifierArr.append("setting_video")
        
        let sliceCount = Float(barTitleArr.count)
        for i in 0..<Int(sliceCount) {
            
            let tem: HomeBarItemView = HomeBarItemView()
            tem.accessibilityIdentifier = self.barIdentifierArr[i]
            tem.barIndex = i
            tem.tag = i + 100
            tem.normailImage = self.barImgTuple[i].0
            tem.selectImage = self.barImgTuple[i].1
            tem.selectTitleColor = ADTheme.Theme
            tem.titleColor = ADTheme.C3
            tem.nameTitle = barTitleArr[i]
            tem.selectBlock = { (index) in
                self.currentIndex = index
            }
            
            self.addSubview(tem)

            let proBy: Float = 1.0 / sliceCount
            tem.snp.makeConstraints { make in
                make.top.equalTo(self.snp.top)
                make.height.equalTo(self.snp.height)
                make.width.equalTo(self.snp.width).multipliedBy(proBy)
                make.leading.equalTo(0 + UIScreen.width * CGFloat(proBy) * CGFloat(i))
            }
        }
        
    }
    
    private func updateSelect() {



        for i in 0..<Int(barTitleArr.count) {
            let subView = self.getSubViewByTag(tag: i + 100)[0] as? HomeBarItemView
            subView?.isSelected = (subView?.barIndex == currentIndex)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
