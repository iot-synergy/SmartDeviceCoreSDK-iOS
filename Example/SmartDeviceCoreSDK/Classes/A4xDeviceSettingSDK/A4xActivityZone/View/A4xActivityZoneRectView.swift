//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public class A4xActivityZoneRectView: UIView {

    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public var dataSource : [ZoneBean]?{
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        dataSource?.reversed().forEach({ (point) in
            let pointPath = UIBezierPath()
            pointPath.lineWidth = 2
            guard let points = point.verticesPoints() else {
                return
            }
            
            guard points.count > 0 else {
                return
            }
            var color : UIColor = ADTheme.Theme
            let recolor = point.rectColor
            if recolor != NULL_INT {
                color = UIColor.hex(recolor)
            }
            
            color.setStroke()
            color.withAlphaComponent(0.3).setFill()
            pointPath.move(to: getPointValue(point: points.first!))
            for index in 1..<points.count{
                pointPath.addLine(to: getPointValue(point: points[index]))
            }
            pointPath.close()
            pointPath.stroke()
            pointPath.fill()
        })
    }
    
    private func getPointValue(point : CGPoint) -> CGPoint {
        let width = self.bounds.width
        let height = self.bounds.height
        
        return CGPoint(x: width * point.x , y: height * point.y )
    }
}
