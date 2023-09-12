//


//




import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol A4xMediaPlayerProtocol {
    static var playAspectRatio: Float { get }



    
    var authorityLaybel: UILabel? {
        get
    }
    
    var dateLaybel: UILabel? {
        get
    }
    
    var mediaTypeImg: A4xMediaVideoTagsView? {
        get
    }
}

extension A4xMediaPlayerProtocol {
    static var playAspectRatio: Float {
        return 0.56
    }
}

protocol A4xMediaBaseScrollProtocol: class {
    func numberOfCount() -> Int
    func selectIndex(index: Int, cell: A4xMediaPlayScrollCell)
    func cellForIndex(index: Int) -> A4xMediaPlayScrollCell
}


protocol A4xMediaBaseScrollCellProtocol {
    var isActivty: Bool {
        set get
    }
    
    var isLandscape: Bool {
        get
    }
    
    var controlBarHidden: ((Bool) ->Void)? {
        set get
    }
}


class A4xMediaBaseScrollCell: UIView, A4xMediaBaseScrollCellProtocol {
    
    var controlBarHidden: ((Bool) -> Void)?
    var isLandscape: Bool {
        get {
            return A4xAppSettingManager.shared.orientationIsLandscape()

        }
    }
    var isActivty: Bool

    override init(frame: CGRect = .zero) {
        self.isActivty = false
        //self.isLandscape = false
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class A4xMediaDetailScrollView: UIScrollView, UIScrollViewDelegate {
    weak var `protocol`: A4xMediaBaseScrollProtocol?
    
    var leftView: A4xMediaPlayScrollCell?
    var rightView: A4xMediaPlayScrollCell?
    var centerView: A4xMediaPlayScrollCell?
    
    
    private var currentOrientation: UIInterfaceOrientationMask?
    
    var isLandscape: Bool { 
        get {
            return A4xAppSettingManager.shared.orientationIsLandscape()
        }
    }
    
    var selectIndex: Int = 0 {
        didSet {
            currentIndex = selectIndex
            self.reladData(dataChange: true)
        }
    }
    
    private var currentIndex: Int
    
    var absoluteIndex: Int = 0
    
    var showCell: A4xMediaPlayScrollCell? {
        if absoluteIndex == 0 {
            return leftView
        } else if absoluteIndex == 1 {
            return centerView
        } else if absoluteIndex == 2 {
            return rightView
        }
        return nil
    }
    
    init(frame: CGRect, prot: A4xMediaBaseScrollProtocol, page: Int = 0) {
        self.currentIndex = page
        self.protocol = prot
        super.init(frame: frame)
        self.delegate = self
        updateSelect()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            let isL = A4xAppSettingManager.shared.orientationIsLandscape()

            
        
            let tmpOrientation: UIInterfaceOrientationMask = isL ? .landscapeRight : .portrait
            if currentOrientation != tmpOrientation {
                if currentOrientation == nil {
                    
                    
                } else {
                    
                    
                    
                    if isL {
                        self.isScrollEnabled = false
                    } else {
                        self.isScrollEnabled = true
                    }
                    
                    reloadUI()
                }
                currentOrientation = tmpOrientation
            } else {
                
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    deinit {
        
    }
    
    func reladData(dataChange: Bool) {
        if dataChange {
            let count =  self.protocol?.numberOfCount() ?? 0
            currentIndex = min(max(0, currentIndex), count - 1)
            
            self.leftView?.isActivty = false
            self.centerView?.isActivty = false
            self.rightView?.isActivty = false
            
            let subLeftViews = self.leftView?.getAllSubViews()
            if (subLeftViews?.count ?? 0) > 0 {
                for i in 0..<(subLeftViews?.count ?? 0) {
                    subLeftViews?[i].removeFromSuperview()
                }
            }
            
            let subRightViews = self.rightView?.getAllSubViews()
            if (subRightViews?.count ?? 0) > 0 {
                for i in 0..<(subRightViews?.count ?? 0) {
                    subRightViews?[i].removeFromSuperview()
                }
            }
            
            let subCenterViews = self.centerView?.getAllSubViews()
            if (subCenterViews?.count ?? 0) > 0 {
                for i in 0..<(subCenterViews?.count ?? 0) {
                    subCenterViews?[i].removeFromSuperview()
                }
            }
            
            self.leftView?.removeFromSuperview()
            self.rightView?.removeFromSuperview()
            self.centerView?.removeFromSuperview()
            
            guard count > 0 else {
                return
            }
            
            
            if count < 4 || currentIndex == 0 {
                absoluteIndex = 0
                if count > 0 {
                    self.leftView = self.protocol?.cellForIndex(index: 0)
                    self.addSubview(self.leftView!)
                }
                
                if count > 1 {
                    self.centerView = self.protocol?.cellForIndex(index: 1)
                    self.addSubview(self.centerView!)
                }
                
                if count > 2 {
                    self.rightView = self.protocol?.cellForIndex(index: 2)
                    self.addSubview(self.rightView!)
                }
                
                if count < 4 {
                    absoluteIndex = currentIndex
                }
            } else if (currentIndex == count - 1) { 
                absoluteIndex = 2

                self.leftView = self.protocol?.cellForIndex(index: currentIndex - 2)
                self.addSubview(self.leftView!)
                
                self.centerView = self.protocol?.cellForIndex(index: currentIndex - 1)
                self.addSubview(self.centerView!)
                
                self.rightView = self.protocol?.cellForIndex(index: currentIndex)
                self.addSubview(self.rightView!)
            } else { 
                absoluteIndex = 1

                self.leftView = self.protocol?.cellForIndex(index: currentIndex - 1)
                self.addSubview(self.leftView!)
                
                self.centerView = self.protocol?.cellForIndex(index: currentIndex)
                self.addSubview(self.centerView!)
                
                self.rightView = self.protocol?.cellForIndex(index: currentIndex + 1)
                self.addSubview(self.rightView!)
                
                self.contentOffset = CGPoint(x: self.width, y: 0)
            }
        }
        
        updateFrame()
        
        //if dataChange {
            //updateCurrentSelect()
        //}
        
        updateCurrentSelect()
        self.contentOffset = CGPoint(x: self.width * CGFloat(absoluteIndex), y: 0)
    }
    
    func reloadUI() {
        updateFrame()
        
        self.contentOffset = CGPoint(x: UIScreen.width * CGFloat(absoluteIndex), y: 0)
    }
    
    func resetAllPlayView() {
        self.leftView?.isActivty = false
        self.rightView?.isActivty = false
        self.centerView?.isActivty = false
    }
    
    private func updateFrame() {
        let count = self.protocol?.numberOfCount() ?? 0
        
        self.contentSize = CGSize(width: CGFloat(min(3, count)) * UIScreen.width, height: 0)
        self.leftView?.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height)
        self.centerView?.frame = CGRect(x: UIScreen.width, y: 0, width: UIScreen.width, height: UIScreen.height)
        self.rightView?.frame = CGRect(x: UIScreen.width * 2, y: 0, width: UIScreen.width, height: UIScreen.height)
    }
    
    
    private func updateSelect() {
        let page = self.contentOffset.x / UIScreen.width
        
        guard Int(page) != absoluteIndex else {
            return
        }
        
        let count =  self.protocol?.numberOfCount() ?? 0
        let offsetX = self.contentOffset.x
        
        if count < 4 {
            currentIndex = Int(round(offsetX / UIScreen.width))
        } else {
            if currentIndex == 0 && page == 0 {
                currentIndex = 0
            } else if page == 1 {
                if currentIndex == 0 {
                    currentIndex = 1
                } else {
                    currentIndex -= 1
                }
            } else if page == 0 {
                currentIndex -= 1
                reladData(dataChange: true)
                return
            } else if page == 2 {
                currentIndex += 1
                reladData(dataChange: true)
                return
            }
        }
        
        absoluteIndex = Int(self.contentOffset.x / UIScreen.width)
        updateCurrentSelect()
    }
    
    func updateCurrentSelect() {
        var cell: A4xMediaPlayScrollCell?
        if absoluteIndex == 0 {
            leftView?.isActivty = false
            centerView?.isActivty = false
            rightView?.isActivty = false
            cell = leftView
        } else if absoluteIndex == 1 {
            centerView?.isActivty = false
            leftView?.isActivty = false
            rightView?.isActivty = false
            cell = centerView
        } else if absoluteIndex == 2 {
            rightView?.isActivty = false
            centerView?.isActivty = false
            leftView?.isActivty = false
            cell = rightView
        }
        
        guard cell != nil else {
            return
        }
        self.protocol?.selectIndex(index: currentIndex, cell: cell!)
    }
    
    //视图滚动中一直触发
    func scrollViewDidScroll(_ scrollView: UIScrollView) {//
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateSelect()
        scrollView.isUserInteractionEnabled = true
    }
    
    //开始拖动（以某种速率和偏移量）
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelect()
        scrollView.isUserInteractionEnabled = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollView.isUserInteractionEnabled = false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let v = super.hitTest(point, with: event)
        return v
    }
}
