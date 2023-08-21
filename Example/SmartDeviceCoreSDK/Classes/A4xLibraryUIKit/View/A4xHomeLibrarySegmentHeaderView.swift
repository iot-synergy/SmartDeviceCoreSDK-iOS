//


//


//

import Foundation
import JXSegmentedView
import SmartDeviceCoreSDK
import BaseUI

public typealias A4xHomeLibrarySegmentCalendayClickBlock = (_ show: Bool) -> Void

public class A4xHomeLibrarySegmentHeaderView: UIView {
    
    let segmentHeight : CGFloat = 40
    let indicatorHeight : CGFloat = 32
    let totalItemWidth: CGFloat = 184
    
    var segmentClickAtIndex: ((_ index: Int) -> Void)?
    
    var canClickCalenday: Bool = false {
        didSet {
            if canClickCalenday { 
                self.infoView.titleLabel.textColor = ADTheme.C1
                self.infoView.isUserInteractionEnabled = true
            } else {
                self.infoView.titleLabel.textColor = ADTheme.C3
                self.infoView.isUserInteractionEnabled = false
            }
        }
    }
    
    public func reloadTitleLanguage() {
        let newtitles = [A4xBaseManager.shared.getLocalString(key: "library_cloud"), A4xBaseManager.shared.getLocalString(key: "library_sdcard")]
        self.segmentedDataSource.titles = newtitles
        self.segmentedView.reloadData()
    }
    
    var segmengtCalendayClickBlock: A4xHomeLibrarySegmentCalendayClickBlock? {
        didSet {
            weak var weakSelf = self
            self.infoView.headerShowBlock = {(result ) in
                if weakSelf?.segmengtCalendayClickBlock != nil {
                    weakSelf?.segmengtCalendayClickBlock?(result)
                }
            }
        }
    }
    
    public var title : String? {
        didSet {
            self.infoView.title = title
        }
    }
    
    public var showCalenday : Bool? {
        didSet {
            if let s = showCalenday {
                self.infoView.headerShowType = s ? .Show : .Hidden
                self.infoView.updateType(ani : false);
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.topBackgroundView)
        self.addSubview(self.infoView)
        self.addSubview(self.segmentedView)
        
        self.topBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(0)
            make.height.equalTo(UIScreen.statusBarHeight + 16)
        }
        self.infoView.snp.makeConstraints({ (make) in
            make.leading.equalTo(16.auto())
            make.width.lessThanOrEqualTo(self.snp.width).offset(88)
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(44.auto())
        })
        self.segmentedView.snp.makeConstraints { make in
            make.trailing.equalTo(-16.auto())
            make.width.equalTo(totalItemWidth+16)
            make.centerY.equalTo(self.infoView.snp.centerY)
            make.height.equalTo(segmentHeight)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var infoView: A4xHomeBaseHeaderUIControl = {
        var temp: A4xHomeBaseHeaderUIControl = A4xHomeBaseHeaderUIControl()
        temp.alignment = .left
        return temp
    }()
    
    private lazy var topBackgroundView: UIView = {
        let temp = UIView()
        return temp
    }()
    
    
    public lazy var segmentedView: JXSegmentedView = {
        let temp = JXSegmentedView()
        temp.delegate = self
        temp.dataSource = self.segmentedDataSource
        temp.layer.masksToBounds = true
        temp.layer.cornerRadius = segmentHeight / 2
        temp.backgroundColor = UIColor.colorFromHex("#EBEBEC")
        
        let indicator = JXSegmentedIndicatorBackgroundView()
        indicator.indicatorHeight = indicatorHeight
        indicator.indicatorWidthIncrement = 0
        indicator.indicatorColor = UIColor.white
        temp.indicators = [indicator]
        return temp
    }()
    
    
    private lazy var segmentedDataSource: JXSegmentedTitleDataSource = {
        let titles = [A4xBaseManager.shared.getLocalString(key: "library_cloud"), A4xBaseManager.shared.getLocalString(key: "library_sdcard")]
        let titleDataSource = JXSegmentedTitleDataSource()
        titleDataSource.itemWidth = totalItemWidth/CGFloat(titles.count)
        titleDataSource.titles = titles
        titleDataSource.isTitleMaskEnabled = true
        titleDataSource.titleNormalColor = UIColor.colorFromHex("#666666")
        titleDataSource.titleSelectedColor = UIColor.colorFromHex("#333333")
        titleDataSource.itemSpacing = 0
        return titleDataSource
    }()
    
}


extension A4xHomeLibrarySegmentHeaderView: JXSegmentedViewDelegate {
    public func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
        segmentClickAtIndex?(index)
    }
}
