import UIKit

protocol A4xHomeLibraryHeaderLayoutProduct : class{
    func filterTagCheckShow(indexPatch : IndexPath) -> Bool
    func sizeAtIndex(indexPath : IndexPath) -> CGSize
}


class A4xHomeLibraryHeaderLayout: UICollectionViewFlowLayout {
    
    
    var cellAttriArray : [UICollectionViewLayoutAttributes]? = Array()
    var contentHeiht : CGFloat = 0
    var contentWidth : CGFloat = 0
    weak var mProtocol : A4xHomeLibraryHeaderLayoutProduct?
    
    init(delegate dge : A4xHomeLibraryHeaderLayoutProduct){
        super.init()
        mProtocol = dge
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepare() {
        super.prepare()
        cellAttriArray?.removeAll()
        
        let itemSpace = self.minimumInteritemSpacing
        let sessionInset = self.sectionInset
        
        
        var xValue : CGFloat =  sessionInset.left
        let yValue : CGFloat =  sessionInset.top
        
        let sessionCount : Int = collectionView?.numberOfSections ?? 0
        
        var showItem : Int = 0
        
        for session in 0..<sessionCount {
            let rowCount = collectionView?.numberOfItems(inSection: session) ?? 0
           
            for row in 0..<rowCount {

                var checkShow : Bool = false
                let indexPath = IndexPath(row: row, section: session)

                if let pro = self.mProtocol {
                    checkShow = pro.filterTagCheckShow(indexPatch: indexPath)
                }
                if !checkShow  {
                    continue
                }
                let itemSize : CGSize = self.mProtocol?.sizeAtIndex(indexPath: indexPath) ?? CGSize.zero
                
                showItem += 1
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xValue, y: yValue, width: itemSize.width, height: itemSize.height)
                contentWidth = attributes.frame.maxX
                xValue += itemSize.width + itemSpace
                cellAttriArray?.append(attributes)
            }
        }
        
        contentHeiht = sessionInset.top + itemSize.height + sessionInset.bottom
        contentWidth = contentWidth + sectionInset.right

    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeiht)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        cellAttriArray?.enumerated().forEach({ (index ,element) in
            if (rect.intersects(element.frame)){
                layoutAttributes.append(element)
            }
        })

        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        if indexPath.row < cellAttriArray?.count ?? 0 {
            return cellAttriArray?[indexPath.row]
        } else {
            return nil//cellAttriArray?[0]
        }
    }
}
