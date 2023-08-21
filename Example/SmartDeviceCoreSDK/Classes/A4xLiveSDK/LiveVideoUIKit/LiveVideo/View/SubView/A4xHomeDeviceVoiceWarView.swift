//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK

class LiveVoiceAnimationView: UIView {
    
    private var voiceAniTimer : Timer?
    var maxLines : Int = 30
    var lineWidth : CGFloat = 1.5
    var pointLocation : [Float]? = Array(repeating: 0.1, count: 50) {
        didSet {
            
        }
    }
    let horPadding : CGFloat = 16.auto()
    let centerSpace : CGFloat = 0.auto()
    
    deinit {
        
    }
    
    override var isHidden: Bool {
        didSet {
            self.voiceAniTimer?.fireDate = isHidden ? Date.distantFuture : Date()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        pointLocation?.removeAll()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func free() {
        self.voiceAniTimer?.invalidate()
    }
    
    func load() {
        self.voiceAniTimer = Timer(timeInterval: 1.0 / 15.0 , target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        RunLoop.current.add(self.voiceAniTimer!, forMode: .common)
    }
    
    @objc private func updateProgress() {
        self.setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard self.pointLocation?.count ?? 0 > 0 else {
            return
        }
        
        let pointPath = UIBezierPath()
        pointPath.lineWidth = CGFloat(lineWidth)
        pointPath.lineCapStyle = .round
        
        let between : CGFloat = 3
        let height = (rect.height - CGFloat(lineWidth * 2)) * 0.8
        let color = UIColor.white
        color.set()
        let centerY = rect.height / 2
        
        for index in 0..<min(self.pointLocation!.count, maxLines) {
            let value = self.pointLocation![index]
            let absValue = fabsf(value)
            let itemHeight = max(CGFloat(min(absValue, 1)) * height, lineWidth)
            let rect = CGRect(x: (between + lineWidth) * index.toCGFloat , y: centerY - itemHeight / 2.0 , width: lineWidth, height: itemHeight)
            if rect.minX > horPadding && self.bounds.width - rect.maxX > horPadding {
                let path = UIBezierPath(roundedRect: rect, cornerRadius: lineWidth / 2 )
                pointPath.append(path)
            }
        }
        
        pointPath.stroke()
        color.set() 
    }
}
