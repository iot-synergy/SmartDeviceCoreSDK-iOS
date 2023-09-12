//


//


//

import Foundation
import UIKit

protocol A4xBindEditDeviceNameLayoutProtocol: class {
    func sizeAtIndex(indexPath: IndexPath) -> CGSize
    func headerHeight() -> CGFloat
}

class A4xBindEditDeviceNameLayout: UICollectionViewFlowLayout {
    var cellAttriArray: [UICollectionViewLayoutAttributes] = Array()
    var headerAttriArray: [UICollectionViewLayoutAttributes] = Array()

    var contentHeiht: CGFloat = 0
    var contentWidth: CGFloat = 0
    weak var mProtocol: A4xBindEditDeviceNameLayoutProtocol?
    
    init(delegate dge: A4xBindEditDeviceNameLayoutProtocol) {
        super.init()
        mProtocol = dge
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepare() {
        super.prepare()
        cellAttriArray.removeAll()
        headerAttriArray.removeAll()

        let itemSpace = self.minimumInteritemSpacing
        let sessionInset = self.sectionInset
        
        var xValue: CGFloat = sessionInset.left
        let marright: CGFloat = sessionInset.right
        var yValue: CGFloat = sessionInset.top
        let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(row: 0, section: 0))
        let wdith = (self.collectionView?.frame.size.width ?? 320) - sessionInset.left - sessionInset.right
        
        headerAttributes.frame = CGRect(x: sessionInset.left, y: 0, width: wdith, height: self.mProtocol?.headerHeight() ?? 260.auto())
        headerAttriArray.append(headerAttributes)
        yValue = headerAttributes.frame.maxY
        
        let sessionCount: Int = collectionView?.numberOfSections ?? 0

        var lastRowHeight: CGFloat = 50
        for session in 0..<sessionCount {
            let rowCount = collectionView?.numberOfItems(inSection: session) ?? 0
            
            for row in 0..<rowCount {
                let indexPath = IndexPath(row: row, section: session)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

                let itemSize: CGSize = self.mProtocol?.sizeAtIndex(indexPath: indexPath) ?? CGSize.zero
                if xValue + itemSize.width + marright > collectionView?.frame.width ?? 0 {
                    xValue = sessionInset.left
                    yValue += 55.auto()
                }
                
                attributes.frame = CGRect(x: xValue, y: yValue, width: itemSize.width, height: itemSize.height)
                contentWidth = attributes.frame.maxX
                xValue += itemSize.width + itemSpace
                yValue = attributes.frame.minY
                lastRowHeight = attributes.frame.size.height
                cellAttriArray.append(attributes)
            }
        }
        
        contentHeiht = yValue + sessionInset.bottom + lastRowHeight
        contentWidth = collectionView?.bounds.size.width ?? 0
        
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeiht)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        cellAttriArray.enumerated().forEach({ (index ,element) in
            if (rect.intersects(element.frame)){
                layoutAttributes.append(element)
            }
        })
        let offsetX = self.collectionView?.contentOffset.x ?? 0
        let xValue : CGFloat =  self.sectionInset.left + (self.collectionView?.contentInset.left ?? 0)

        headerAttriArray.forEach({ (element) in
            element.frame = CGRect(x: offsetX + xValue , y: element.frame.minY, width: element.frame.width, height: element.frame.height)
        
                layoutAttributes.append(element)
        })
        
        return layoutAttributes
    }
    
   override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
           return cellAttriArray[indexPath.row]
       }
       
}
