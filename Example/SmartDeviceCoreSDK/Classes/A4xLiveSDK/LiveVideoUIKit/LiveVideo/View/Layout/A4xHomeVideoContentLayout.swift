//


//


//

import UIKit


public enum A4xVideoCellType {
    static let defaultHorSpace      : CGFloat   = 8.auto()
    static let defaultVerSpace      : CGFloat   = 10.auto() 

    case `default`
    case locations
    case locations_edit
    case playControl(isShowMore: Bool)
    
    public static func == (lhs: A4xVideoCellType, rhs: A4xVideoCellType) -> Bool {
        switch (lhs, rhs) {
        case (.default, .default): return true
        case (.locations, .locations): return true
        case (.locations_edit, .locations_edit): return true
        case (.playControl, .playControl): return true
        case _: return false
        }
    }
    
    public static func != (lhs: A4xVideoCellType, rhs: A4xVideoCellType) -> Bool {
        switch (lhs, rhs) {
        case (.default, .default): return false
        case (.locations, .locations): return false
        case (.locations_edit, .locations_edit): return false
        case (.playControl, .playControl): return false
        case _: return true
        }
    }
}

protocol A4xHomeVideoCellContentProtocol: class {
    func getDefaultCellType(rowIndex: Int) -> A4xVideoCellType
    func getCellHeight(forRow row: Int, itemWidth: CGFloat) -> CGFloat
}

class A4xHomeLiveVideoCollectLayout: UICollectionViewFlowLayout {
    
    var cellAttriArray: [UICollectionViewLayoutAttributes]? = Array()
    var contentHeight: Float = 0

    var cellSectionCount: Int = 1
    weak var mProtocol: A4xHomeVideoCellContentProtocol?
    
    init(delegate dge: A4xHomeVideoCellContentProtocol) {
        self.mProtocol = dge
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepare() {
        super.prepare()

   
        cellAttriArray?.removeAll()
        
        for section in 0..<(collectionView?.numberOfSections ?? 0) {
            if (collectionView?.numberOfSections ?? 1) > 1 {
                if section == 0 {
                    let edgeSpace       : CGFloat   = 0 
                    let verticalSpace   : CGFloat   = 10.auto() 
                    let subViewWidth    : CGFloat   = (self.collectionView?.frame.width ?? UIApplication.shared.keyWindow?.width) ?? 375
                    var xValue : CGFloat = edgeSpace
                    var yValue : CGFloat = 0
                    let indexPath = IndexPath(row: 0, section: section)
                    let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    let lineCount       : Int       = 1
                    let edgeCount = lineCount + 1
                    let itemWidth       : CGFloat   = (self.collectionView!.frame.width - edgeSpace * CGFloat(edgeCount)) / CGFloat(lineCount)
                    let itemHeight : CGFloat = 50.auto()
                    let frame = CGRect(x: CGFloat(xValue), y: CGFloat(yValue), width: CGFloat(itemWidth), height: itemHeight)
                    attr.frame = frame
                    xValue += itemWidth + edgeSpace
                    if (xValue + itemWidth) > subViewWidth {
                        xValue = edgeSpace
                        yValue += (itemHeight + verticalSpace)
                    }
                    cellAttriArray?.append(attr)
                    contentHeight = frame.maxY.toFloat
                    contentHeight += Float(8.auto())
                } else {
                    layoutAttributes(section: section, containAp: true)
                }
            } else {
                layoutAttributes(section: section, containAp: false)
            }
        }
    }
    
    private func layoutAttributes(section: Int, containAp: Bool) {
        
        
        let lineCount       : Int       = 1
        
        let rowCount        : Int       = collectionView?.numberOfItems(inSection: section) ?? 1
        
        let edgeSpace       : CGFloat   = A4xVideoCellType.defaultHorSpace
        
        let verticalSpace   : CGFloat   = A4xVideoCellType.defaultVerSpace
        
        let subViewWidth    : CGFloat   = (self.collectionView?.frame.width ?? UIApplication.shared.keyWindow?.width) ?? 375
        
        let edgeCount = lineCount + 1
        let itemWidth       : CGFloat   = (self.collectionView!.frame.width - edgeSpace * CGFloat(edgeCount)) / CGFloat(lineCount)
        
        var xValue : CGFloat = edgeSpace
        var yValue : CGFloat = containAp ? 58.auto() : 0
        
        var itemHeight : CGFloat = 0
        
        for index in 0 ..< rowCount {
            
            let indexPath = IndexPath(row: index, section: section)
            
            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            if let cellHeight = self.mProtocol?.getCellHeight(forRow: index, itemWidth: itemWidth) {
                itemHeight = cellHeight
            }
            
            let frame = CGRect(x: CGFloat(xValue), y: CGFloat(yValue), width: CGFloat(itemWidth), height: itemHeight)
            
            attr.frame = frame
            //
            
            xValue += itemWidth + edgeSpace
            if (xValue + itemWidth) > subViewWidth {
                xValue = edgeSpace
                yValue += (itemHeight + verticalSpace)
            }
            
            cellAttriArray?.append(attr)
            
            contentHeight = frame.maxY.toFloat
        }
        
        contentHeight += Float(50)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.collectionView?.width ?? 0, height: CGFloat(self.contentHeight))
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //
      
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        cellAttriArray?.enumerated().forEach({ (index ,element) in
            if (rect.intersects(element.frame)){
                layoutAttributes.append(element)
            }
        })
        
        return layoutAttributes
    }

}
