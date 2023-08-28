//


//


//

import Foundation
import MJRefresh
import SmartDeviceCoreSDK

class A4xLoadView : UIView ,CAAnimationDelegate {
    enum A4xLoadState {
        case `default`
        case loading
        case stop
    }
    
    var progress : Float = 0 {
        didSet {
            self.updateProgerss()
        }
    }
    
    var state : A4xLoadState = .default {
        didSet {
            self.updateState()

        }
    }
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    lazy var share1Layer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 3
        layer.backgroundColor = UIColor.clear.cgColor
        layer.strokeColor = ADTheme.Theme.cgColor
        layer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(layer)
        return layer
    }()
    
    lazy var share2Layer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 3
        layer.backgroundColor = UIColor.clear.cgColor
        layer.strokeColor = ADTheme.Theme.cgColor
        layer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(layer)
        return layer
    }()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.share1Layer.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func updateProgerss() {
        if self.state == .loading {
            return
        }else if self.state == .stop {
            self.state = .default
            return
        }
      
        let current = max(min(self.progress, 1), 0)
        let start = -Float.pi / 2
        let end = start + Float.pi * 2 * current

        let path = UIBezierPath(arcCenter: CGPoint(x: self.bounds.midX , y:self.bounds.midY  ), radius: self.bounds.width/2.0 - self.share1Layer.lineWidth / 2, startAngle: CGFloat(start), endAngle: CGFloat(end), clockwise: true)
        self.share1Layer.path = path.cgPath
    }

    
    private func updateState() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        switch self.state {
        case .default:
            self.share1Layer.frame = self.bounds
            self.share1Layer.borderColor = UIColor.clear.cgColor
    
            self.share2Layer.frame = CGRect.zero
            self.share2Layer.borderColor = UIColor.clear.cgColor
        case .loading:


            self.share1Layer.frame = self.bounds
            self.share1Layer.borderWidth = 3
            self.share1Layer.cornerRadius = self.bounds.width/2
            self.share1Layer.borderColor = ADTheme.Theme.cgColor
            self.share1Layer.path = nil

            self.share2Layer.frame = CGRect(x: self.bounds.midX, y: self.bounds.midY, width: 0, height: 0)
            self.share2Layer.borderColor = ADTheme.Theme.cgColor
            self.share2Layer.borderWidth = 3
            self.share2Layer.cornerRadius = 0
            self.share2Layer.path = nil
            self.startLoading()
        default:
            break
        }
        CATransaction.commit()
    }
    
    private func startLoading(){
        self.share2Layer.removeAllAnimations()
        self.share2Layer.bounds = CGRect.zero
        self.share1Layer.removeAllAnimations()
        self.share1Layer.bounds = self.bounds
        self.share1Layer.opacity = 1
        
        let alpha1Anim = CABasicAnimation(keyPath: "opacity")
        alpha1Anim.fromValue = 1
        alpha1Anim.toValue = 0
        alpha1Anim.duration = 0.4
        alpha1Anim.fillMode = .forwards
        alpha1Anim.isRemovedOnCompletion = false

        let animl1Group  = CAAnimationGroup()
        animl1Group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animl1Group.fillMode = .forwards
        animl1Group.isRemovedOnCompletion = true
        animl1Group.duration = 0.6
        animl1Group.animations = [alpha1Anim]

        self.share1Layer.add(animl1Group, forKey: "share1Layer")
        
        let scale2Down = CABasicAnimation(keyPath: "bounds")
        scale2Down.fromValue = CGRect.zero
        scale2Down.toValue = self.bounds
        scale2Down.duration = 0.6
        scale2Down.fillMode = .forwards
        scale2Down.isRemovedOnCompletion = true

        let position2Down = CABasicAnimation(keyPath: "position")
        position2Down.fromValue = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        position2Down.toValue = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        position2Down.duration = 0.6
        position2Down.fillMode = .forwards
        position2Down.isRemovedOnCompletion = true


        let radius2Down = CABasicAnimation(keyPath: "cornerRadius")
        radius2Down.fromValue = 0
        radius2Down.toValue = self.bounds.width/2
        radius2Down.duration = 0.6
        radius2Down.fillMode = .forwards
        radius2Down.isRemovedOnCompletion = true
        
        
        let animl2Group  = CAAnimationGroup()
        animl2Group.delegate = self
        animl2Group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animl2Group.fillMode = .forwards
        animl2Group.isRemovedOnCompletion = true
        animl2Group.duration = 0.6
        animl2Group.animations = [scale2Down,position2Down,radius2Down]
        self.share2Layer.add(animl2Group, forKey: "animl2Group")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if self.state == .loading {
            self.startLoading()
        }
    }
}

public class A4xMJRefreshHeader: MJRefreshHeader {
    lazy var arrowImageView : A4xLoadView = {
        let temp = A4xLoadView()
        temp.size = CGSize(width: 36, height: 36)
        self.addSubview(temp)

        return temp
    }()
    
    private var autoLoadingTimeoutTimer: Timer?
    private var autoLoadingTimerCount : Int = 0
    
    public override var pullingPercent : CGFloat {
        didSet {
            self.arrowImageView.progress = Float(pullingPercent)

        }
    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        let centerY : CGFloat = self.height / 2.0
        let arrowXValue : CGFloat = self.width / 2.0
        self.arrowImageView.center = CGPoint(x: arrowXValue, y: centerY)
    }
    
    public override func prepare() {
        super.prepare()
    }
    
    public override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                logDebug("A4xMJRefreshHeader idle stop")
                self.arrowImageView.state = .stop
                releaseAutoTimer()
            case .pulling:
                self.arrowImageView.state = .default
                logDebug("A4xMJRefreshHeader pulling")
            case .refreshing:
                self.arrowImageView.state = .loading
                startTimeLoading()
                logDebug("A4xMJRefreshHeader refreshing")
            case .willRefresh:
                self.arrowImageView.state = .stop
                releaseAutoTimer()
                logDebug("A4xMJRefreshHeader willRefresh")
            case .noMoreData:
                logDebug("A4xMJRefreshHeader noMoreData")
            }
        }
    }
    
    
    private func startTimeLoading() {
        if autoLoadingTimeoutTimer != nil {
            autoLoadingTimeoutTimer?.invalidate()
            autoLoadingTimeoutTimer = nil
        }
        autoLoadingTimerCount = 0
        autoLoadingTimeoutTimer = Timer(timeInterval: 1, target: self, selector: #selector(loadingTime), userInfo: nil, repeats: true)
        RunLoop.current.add(autoLoadingTimeoutTimer!, forMode: .common)
        autoLoadingTimeoutTimer?.fire()
    }
    
    
    private func stopTimeLoading() {
        autoLoadingTimeoutTimer?.invalidate()
        autoLoadingTimeoutTimer = nil
        autoLoadingTimerCount = 0
        
        self.arrowImageView.state = .default
        state = MJRefreshState.idle
    }
    
    
    private func releaseAutoTimer(){
        autoLoadingTimeoutTimer?.invalidate()
        autoLoadingTimeoutTimer = nil
        autoLoadingTimerCount = 0
    }
    
    
    @objc private func loadingTime() {
        if autoLoadingTimerCount < 35 {
            autoLoadingTimerCount += 1
            return
        }
        
        stopTimeLoading()
    }
}
