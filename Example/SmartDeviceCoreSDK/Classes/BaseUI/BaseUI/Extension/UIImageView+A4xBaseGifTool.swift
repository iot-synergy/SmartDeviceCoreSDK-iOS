//

//

import ImageIO
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


let _gifImageKey = malloc(4)
let _cacheKey = malloc(4)
let _currentImageKey = malloc(4)
let _displayOrderIndexKey = malloc(4)
let _syncFactorKey = malloc(4)
let _haveCacheKey = malloc(4)
let _loopCountKey = malloc(4)
let _displayingKey = malloc(4)
let _isPlayingKey = malloc(4)
let _animationManagerKey = malloc(4)
let _delegateKey = malloc(4)

@objc public protocol A4xBaseGifToolDelegate {
    @objc optional func gifDidStart(sender: UIImageView)
    @objc optional func gifDidLoop(sender: UIImageView)
    @objc optional func gifDidStop(sender: UIImageView)
    @objc optional func gifURLDidFinish(sender: UIImageView)
    @objc optional func gifURLDidFail(sender: UIImageView)
}

public extension UIImageView {
    
    
    
    /**
     Convenience initializer. Creates a gif holder (defaulted to infinite loop).
     - Parameter gifImage: The UIImage containing the gif backing data
     - Parameter manager: The manager to handle the gif display
     */
    convenience init(gifImage:UIImage, manager:A4xBaseGifManager = A4xBaseGifManager.defaultManager, loopCount: Int = -1) {
        self.init()
        setGifImage(gifImage,manager: manager, loopCount: loopCount);
    }
    
    /**
     Convenience initializer. Creates a gif holder (defaulted to infinite loop).
     - Parameter gifImage: The UIImage containing the gif backing data
     - Parameter manager: The manager to handle the gif display
     */
    convenience init(gifURL: URL?, manager:A4xBaseGifManager = A4xBaseGifManager.defaultManager, loopCount: Int = -1) {
        self.init()
        
        setGifFromURL(gifURL, manager: manager, loopCount: loopCount)
    }
    
    /**
     Set a gif image and a manager to an existing UIImageView.
     WARNING : this overwrite any previous gif.
     - Parameter gifImage: The UIImage containing the gif backing data
     - Parameter manager: The manager to handle the gif display
     - Parameter loopCount: The number of loops we want for this gif. -1 means infinite.
     */
    func setGifImage(_ gifImage: UIImage, manager: A4xBaseGifManager = A4xBaseGifManager.defaultManager, loopCount: Int = -1) {
        if let imageData = gifImage.imageData, gifImage.imageCount < 1 {
            image = UIImage(data: imageData as Data)
            return
        }
        
        self.loopCount = loopCount
        self.gifImage = gifImage
        self.animationManager = manager
        self.syncFactor = 0
        self.displayOrderIndex = 0
        self.cache = NSCache()
        self.haveCache = false

        if let source = gifImage.imageSource,
            let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) {
            self.currentImage = UIImage(cgImage: cgImage)
            
            if manager.addImageView(self) {
                startDisplay()
                startAnimatingGif()
            }
        }
    }
    
    /**
     Download gif image and sets it
     - Parameter url: The URL pointing to the gif data
     - Parameter manager: The manager to handle the gif display
     - Parameter loopCount: The number of loops we want for this gif. -1 means infinite.
     - Parameter showLoader: Show UIActivityIndicatorView or not
     */
    func setGifFromURL(_ url: URL?, manager: A4xBaseGifManager = A4xBaseGifManager.defaultManager, loopCount: Int = -1, showLoader: Bool = true) {
        
        guard let url = url else {
            print("Invalid Gif URL")
            return
        }
        
        let loader = UIActivityIndicatorView()
        
        if showLoader {
            self.addSubview(loader)
            loader.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[subview]-0-|",
                options: .directionLeadingToTrailing,
                metrics: nil,
                views: ["subview": loader]))
            self.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[subview]-0-|",
                options: .directionLeadingToTrailing,
                metrics: nil,
                views: ["subview": loader]))
            loader.startAnimating()
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _ , _) in
            DispatchQueue.main.async {
                loader.removeFromSuperview()
                if let data = data {
                    self.setGifImage(UIImage.init(gifData: data), manager: manager, loopCount: loopCount)
                    self.delegate?.gifURLDidFinish?(sender: self)
                } else {
                    self.delegate?.gifURLDidFail?(sender: self)
                }
            }
        }
        task.resume()
    }

    
    
    /**
     Start displaying the gif for this UIImageView.
     */
    fileprivate func startDisplay() {
        self.displaying = true
        updateCache()
    }
    
    /**
     Stop displaying the gif for this UIImageView.
     */
    fileprivate func stopDisplay() {
        self.displaying = false
        updateCache()
        
    }
    
    /**
     Start displaying the gif for this UIImageView.
     */
    func startAnimatingGif() {
        self.isPlaying = true
    }
    
    /**
     Stop displaying the gif for this UIImageView.
     */
    func stopAnimatingGif() {
        self.isPlaying = false
    }
    
    /**
     Check if this imageView is currently playing a gif
     - Returns wether the gif is currently playing
     */
    func isAnimatingGif() -> Bool{
        return self.isPlaying
    }
    
    /**
     Show a specific frame based on a delta from current frame
     - Parameter delta: The delsta from current frame we want
     */
    func showFrameForIndexDelta(_ delta: Int) {
        guard let gifImage = gifImage else { return }
        var nextIndex = self.displayOrderIndex + delta
        
        while nextIndex >= gifImage.framesCount(){
            nextIndex -= gifImage.framesCount()
        }
        
        while nextIndex < 0 {
            nextIndex += gifImage.framesCount()
        }
        
        showFrameAtIndex(nextIndex)
    }
    
    /**
     Show a specific frame
     - Parameter index: The index of frame to show
     */
    func showFrameAtIndex(_ index: Int) {
        displayOrderIndex = index
        updateFrame()
    }
    
    /**
     Update cache for the current imageView.
     */
    func updateCache() {
        guard let animationManager = animationManager else { return }
        if animationManager.hasCache(self) && !self.haveCache {
            prepareCache()
            haveCache = true
        }else if !animationManager.hasCache(self) && self.haveCache {
            cache?.removeAllObjects()
            haveCache = false
        }
    }
    
    /**
     Update current image displayed. This method is called by the manager.
     */
    func updateCurrentImage() {
        
        if displaying {
            updateFrame()
            updateIndex()
            if loopCount == 0 || !isDisplayedInScreen(self)  || !isPlaying {
                stopDisplay()
            }
        } else {
            if isDisplayedInScreen(self) && loopCount != 0 && isPlaying {
                startDisplay()
            }
            if isDiscarded(self) {
                animationManager?.deleteImageView(self)
            }
        }
    }
    
    /**
     Force update frame
     */
    fileprivate func updateFrame() {
        if haveCache, let image = cache?.object(forKey: self.displayOrderIndex as AnyObject) as? UIImage {
            currentImage = image
        } else {
            currentImage = frameAtIndex(index: currentFrameIndex())
        }
    }
    
    /**
     Get current frame index
     */
    func currentFrameIndex() -> Int{
        return displayOrderIndex
    }

    /**
     Get frame at specific index
     */
    func frameAtIndex(index: Int) -> UIImage {
        guard let gifImage = gifImage,
            let imageSource = gifImage.imageSource,
            let displayOrder = gifImage.displayOrder, index < displayOrder.count,
            let cgImage = CGImageSourceCreateImageAtIndex(imageSource, displayOrder[index], nil) else {
                return UIImage()
        }
        return UIImage(cgImage: cgImage)
    }
    
    /**
     Check if the imageView has been discarded and is not in the view hierarchy anymore.
     - Returns : A boolean for weather the imageView was discarded
     */
    func isDiscarded(_ imageView: UIView?) -> Bool{
        return imageView?.superview == nil
    }
    
    /**
     Check if the imageView is displayed.
     - Returns : A boolean for weather the imageView is displayed
     */
    
    func isDisplayedInScreen(_ imageView: UIView?) ->Bool{
        guard !self.isHidden, let imageView = imageView else  {
            return false
        }
        
        let screenRect = UIScreen.main.bounds
        let viewRect = imageView.convert(self.bounds, to:nil)
        
        let intersectionRect = viewRect.intersection(screenRect);
        if (intersectionRect.isEmpty || intersectionRect.isNull) {
            return false
        }
        return (self.window != nil)
    }
    
    func clear() {
        if let gifImage = gifImage {
            gifImage.clear()
            
        }
        gifImage = nil
        currentImage = nil
        cache?.removeAllObjects()
        animationManager = nil
        image = nil
    }
    
    /**
     Update loop count and sync factor.
     */
    fileprivate func updateIndex() {
        guard let gif = self.gifImage,
            let displayRefreshFactor = gif.displayRefreshFactor,
            displayRefreshFactor > 0 else {
                return
        }
        
        syncFactor = (syncFactor+1) % displayRefreshFactor
        if syncFactor == 0,
            let imageCount = gif.imageCount,
            imageCount > 0 {
            
            displayOrderIndex = (displayOrderIndex+1) % imageCount
            if displayOrderIndex == 0 {
                if loopCount == -1 {
                    delegate?.gifDidLoop?(sender: self)
                } else if loopCount > 1 {
                    delegate?.gifDidLoop?(sender: self)
                    loopCount -= 1
                } else {
                    delegate?.gifDidStop?(sender: self)
                    loopCount -= 1
                }
            }
        }
    }
    
    /**
     Prepare the cache by adding every images of the gif to an NSCache object.
     */
    fileprivate func prepareCache() {
        guard let cache = self.cache else { return }
        
        cache.removeAllObjects()
        
        guard let gif = self.gifImage,
            let displayOrder = gif.displayOrder,
            let imageSource = gif.imageSource else { return }
        
        for (i, order) in displayOrder.enumerated() {
            guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, order, nil) else { continue }
            
            cache.setObject(UIImage(cgImage: cgImage), forKey: i as AnyObject)
        }
    }
    
    

    fileprivate func value<T>(_ key:UnsafeMutableRawPointer?, _ defaultValue:T) -> T {
        return (objc_getAssociatedObject(self, key!) as? T) ?? defaultValue
    }

    fileprivate func possiblyNil<T>(_ key:UnsafeMutableRawPointer?) -> T? {
        let result = objc_getAssociatedObject(self, key!)
        if result == nil {
            return nil
        }
        return (result as? T)
    }

    var gifImage: UIImage? {
        get {
            return possiblyNil(_gifImageKey)
        }
        set {
            objc_setAssociatedObject(self, _gifImageKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    var currentImage: UIImage? {
        get {
            return possiblyNil(_currentImageKey)
        }
        set {
            objc_setAssociatedObject(self, _currentImageKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    fileprivate var displayOrderIndex: Int {
        get {
            return value(_displayOrderIndexKey, 0)
        }
        set {
            objc_setAssociatedObject(self, _displayOrderIndexKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    fileprivate var syncFactor: Int {
        get {
            return value(_syncFactorKey, 0)
        }
        set {
            objc_setAssociatedObject(self, _syncFactorKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    var loopCount: Int {
        get {
            return value(_loopCountKey, 0)
        }
        set {
            objc_setAssociatedObject(self, _loopCountKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    var animationManager: A4xBaseGifManager? {
        get {
            return (objc_getAssociatedObject(self, _animationManagerKey!) as? A4xBaseGifManager)
        }
        set {
            objc_setAssociatedObject(self, _animationManagerKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    var delegate: A4xBaseGifToolDelegate? {
        get {
            return (objc_getAssociatedObject(self, _delegateKey!) as? A4xBaseGifToolDelegate)
        }
        set {
            objc_setAssociatedObject(self, _delegateKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    fileprivate var haveCache: Bool {
        get {
            return value(_haveCacheKey, false)
        }
        set {
            objc_setAssociatedObject(self, _haveCacheKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    var displaying: Bool {
        get {
            return value(_displayingKey, false)
        }
        set {
            objc_setAssociatedObject(self, _displayingKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    fileprivate var isPlaying: Bool {
        get {
            return value(_isPlayingKey, false)
        }
        set {
            
            objc_setAssociatedObject(self, _isPlayingKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            if newValue {
                self.delegate?.gifDidStart?(sender: self)
            } else {
                self.delegate?.gifDidStop?(sender: self)
            }
        }
    }
    
    fileprivate var cache: NSCache<AnyObject, AnyObject>? {
        get {
            return (objc_getAssociatedObject(self, _cacheKey!) as? NSCache)
        }
        set {
            objc_setAssociatedObject(self, _cacheKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}
