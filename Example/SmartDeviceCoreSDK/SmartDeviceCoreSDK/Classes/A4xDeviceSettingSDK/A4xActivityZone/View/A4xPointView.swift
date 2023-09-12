//


//


//

import UIKit
import SmartDeviceCoreSDK

enum PointAlign {
    case left
    case right
    case center
}

enum A4xMoveModel {
    case point(moveIndex: Int, point: CGPoint)
    case rect(point: CGPoint)
}

struct A4xIntersectionUnit {
    //***************点积判点是否在线段上***************
    func dblcmp(_ a: Double, _ b: Double) -> Int {
        if (abs(a - b) <= 1E-6) {
            return 0
        }
        if (a > b) {
            return 1
        } else {
            return -1
        }
    }
    
    //点积
    func dot(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) -> Double {
        return x1 * x2 + y1 * y2
    }
    
    //求a点是不是在线段bc上，>0不在，=0与端点重合，<0在。
    func point_on_line(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Int {
        return self.dblcmp(self.dot(Double(b.x - a.x), Double(b.y - a.y), Double(c.x - a.x), Double(c.y - a.y)), 0)
    }
    
    //**************************************************
    func cross(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) -> Double {
        return x1 * y2 - x2 * y1
    }
    
    //ab与ac的叉积
    func ab_cross_ac(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) ->Double {
        return self.cross(Double(b.x - a.x), Double(b.y - a.y), Double(c.x - a.x), Double(c.y - a.y))
    }
    
    //求ab是否与cd相交，交点为p。1规范相交，0交点是一线段的端点，-1不相交。
    func ab_cross_cd(_ a : CGPoint , _ b : CGPoint , _ c : CGPoint , _ d : CGPoint ) -> Int {
        var p : CGPoint = CGPoint.zero
        var d1 : Int ,d2 : Int ,d3 : Int ,d4 : Int
        let s1 : CGFloat = CGFloat(self.ab_cross_ac(a, b, c))
        let s2 : CGFloat = CGFloat(self.ab_cross_ac(a, b, d))
        let s3 : CGFloat = CGFloat(self.ab_cross_ac(c, d, a))
        let s4 : CGFloat = CGFloat(self.ab_cross_ac(c, d, b))
        
        d1 = self.dblcmp(Double(s1) , 0)
        d2 = self.dblcmp(Double(s2) , 0)
        d3 = self.dblcmp(Double(s3) , 0)
        d4 = self.dblcmp(Double(s4) , 0)
        
        //如果规范相交则求交点
        if ((d1^d2) == -2 && ( d3^d4 ) == -2) {
            p.x =  ((c.x * s2 - d.x * s1) / (s2 - s1))
            p.y =  ((c.y * s2 - d.y * s1) / (s2 - s1))
            return 1
        }
        
        //如果不规范相交
        if (d1 == 0 && self.point_on_line(c, a, b) <= 0) {
            p = c
            return 0
        }
        if (d2 == 0 && self.point_on_line(d, a, b) <= 0) {
            p = d
            return 0
        }
        if (d3 == 0 && self.point_on_line(a, c, d) <= 0) {
            p = a
            return 0
        }
        if (d4 == 0 && self.point_on_line(b, c, d) <= 0) {
            p = b
            return 0
        }
        //如果不相交
        return -1
    }
    
    func checkCross(points: [CGPoint]) -> Bool {
        let isCorss : Bool = false
        for i in 0..<(points.count - 1) {
            for j in (i + 1)..<points.count {
                var point3 : CGPoint
                if (j == points.count - 1) {
                    point3 = points[0]
                } else {
                    point3 = points[j + 1]
                }
                
                let point = points[i]
                let point1 = points[i+1]
                let point2 = points[j]
                
                let c =  self.ab_cross_cd(point, point1, point2, point3)
                
                if c == 1 {
                    return true
                }
            }
        }
        return isCorss
    }
}


class A4xPointView: UIView {
    private var numberPoints : Int = 7
    private var radioAsset : CGFloat = 0.3
    private var moveModle : A4xMoveModel?
    private let maxDistance : CGFloat = 20
    
    var lineColor : Int = A4xBaseActivityZonePointColorsValue[0]
    
    var editMode : ((Bool)->Void)?
    
    private var currentPath : UIBezierPath?
    
    var points : [CGPoint] = []
    
    var defaultRect : Bool = false
    
    var defaultPoints : [CGPoint]? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    init(frame: CGRect = .zero, pointNum: Int = 8, isRect: Bool = false, defaultPoints: [CGPoint]? = nil) {
        self.numberPoints = pointNum
        self.defaultRect = isRect
        self.defaultPoints = defaultPoints
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if points.count == 0 && self.bounds.size.width > 0 {
            loadDefaultPoints()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func reset() {
        points.removeAll()
        self.layoutSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = event?.allTouches?.first else {
            return
        }
        
        let point = touch.location(in: self)
        self.updatePoint(point: point, isMove: false)
        if moveModle != nil {
            self.editMode?(true)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = event?.allTouches?.first else {
            return
        }
        let point = touch.location(in: self)
        self.updatePoint(point: point, isMove: true)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if moveModle != nil {
            self.editMode?(false)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if moveModle != nil {
            self.editMode?(false)
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard self.points.count > 0 else {
            return
        }
        
        UIColor.hex(lineColor).setFill()

        self.points.forEach { (point) in
            let pointPath = UIBezierPath(arcCenter: point, radius: 4, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            pointPath.fill()
        }
        
        guard self.points.count > 1 else {
            return
        }
        UIColor.hex(lineColor).setStroke()
        UIColor.hex(lineColor, alpha: 0.3).setFill()
        
        let pointPath = UIBezierPath()
        pointPath.lineWidth = 2
        pointPath.move(to: self.points.first!)
        for index in 1..<self.points.count {
            pointPath.addLine(to: self.points[index])
        }
        pointPath.close()
        pointPath.stroke()
        pointPath.fill()
        
        currentPath = pointPath
    }
    
}

extension A4xPointView {
    func updatePoint(point: CGPoint, isMove: Bool) {
        if !isMove {
            let pointIndex = findPoint(point: point)
            if pointIndex >= 0 {
                moveModle = .point(moveIndex: pointIndex, point: point)
            } else if currentPath?.cgPath.contains(point) ?? false {
                moveModle = .rect(point: point)
            } else {
                moveModle = nil
            }
            
        } else {
            guard let modle = moveModle else {
                return
            }
            
            if case let .point(index , _) = modle {
                let boundSize = self.bounds.size
                var p = point
                self.vaild(minV: 0, maxV: boundSize.width, value: &p.x)
                self.vaild(minV: 0, maxV: boundSize.height, value: &p.y)
                
                if !self.vaildIntersection(index: index, currentPoint: p) {
                    if (self.vaildAnglePolygon(index: index, currentPoint: p)) {
                        points[index] = p
                        self.setNeedsDisplay()
                    }
                }
            } else if case let .rect(OldPoint) = modle {
                let (isMove , npoints) = moveRect(oldPoint: OldPoint, newPoint: point)
                if isMove && npoints != nil {
                    self.points = npoints!
                    self.moveModle = .rect(point: point)
                    self.setNeedsDisplay()

                }
            }
        }
    }
}

extension A4xPointView {
    private func moveRect(oldPoint: CGPoint, newPoint: CGPoint ) -> (Bool, [CGPoint]?) {
        let offsetX = oldPoint.x - newPoint.x
        let offsetY = oldPoint.y - newPoint.y
        
        var isMoved : Bool = true

        let width = self.width
        let height = self.height
        let point = self.points.map { (p) -> CGPoint in
            let noint = CGPoint(x: p.x - offsetX , y: p.y - offsetY)
            if noint.x < 3 || noint.x > width - 3 {
                isMoved = false
                return noint
            }
            if noint.y < 3 || noint.y > height - 3 {
                isMoved = false
                return noint
            }
            return noint
        }
        
        return (isMoved , point)
    }
    
    
    private func loadDefaultPoints() {
        if defaultPoints?.count ?? 0 > 0 {
            var pts : [CGPoint] = []
            let width = self.width
            let height = self.height
            defaultPoints?.forEach({ (point) in
                pts.append(CGPoint(x: point.x * width , y: point.y * height))
            })
            self.points = pts
        } else {
            if defaultRect {
                guard numberPoints % 2 == 0 else {
                    return
                }
                let linePointCount = self.numberPoints / 4 + 1
                let lineWidth : CGFloat = min(self.bounds.width, self.bounds.height) * radioAsset * 2
                let sepWidth  : CGFloat = lineWidth / CGFloat(linePointCount - 1)
                
                let top     : CGFloat = (self.height - lineWidth) / 2
                let bottom  : CGFloat = top + lineWidth
                let left    : CGFloat = (self.width - lineWidth) / 2
                let right   : CGFloat = left + lineWidth
                
                
                for index in 0..<linePointCount {
                    var point = CGPoint()
                    point.x = left + sepWidth * index.toCGFloat
                    point.y = top
                    self.points.append(point)
                }
                
                
                for index in 1..<linePointCount {
                    var point = CGPoint()
                    point.x = right
                    point.y = top + sepWidth * index.toCGFloat
                    self.points.append(point)
                }
                
                
                for index in 1..<linePointCount {
                    var point = CGPoint()
                    point.x = right - sepWidth * index.toCGFloat
                    point.y = bottom
                    self.points.append(point)
                }
                
                
                for index in (1..<(linePointCount - 1)) {
                    var point = CGPoint()
                    point.x = left
                    point.y = bottom - sepWidth * index.toCGFloat
                    self.points.append(point)
                }
            } else {
                let center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
                let radio = min(self.bounds.size.height , self.bounds.size.width) * self.radioAsset
                let angle = CGFloat.pi * 2.0 / CGFloat(numberPoints)
                
                var startAngle : CGFloat = angle / 2.0
                if numberPoints % 2 == 1 {
                    startAngle = angle / 4.0
                }
                
                for index in 0..<numberPoints {
                    var point = CGPoint()
                    point.x = center.x + radio * cos( startAngle + angle * CGFloat(index + 1))
                    point.y = center.y + radio * sin( startAngle + angle * CGFloat(index + 1))
                    self.points.append(point)
                }
            }
        }
        
        
        self.setNeedsDisplay()
    }
    
    private func vaildIntersection(index: Int, currentPoint: CGPoint) -> Bool {
        var checkPoint = self.points
        checkPoint[index] = currentPoint
        return A4xIntersectionUnit().checkCross(points: checkPoint)
    }
    
    private func vaildAnglePolygon(index: Int, currentPoint: CGPoint) -> Bool {
        
        let leftPoints = getAdjacentTwoPoints(index: index, ailgen: .left)
        guard leftPoints.count == 2 else {
            return false
        }
        let leftAngle = getAnglesWithThreePoints(p1: currentPoint, p2: leftPoints[0], p3: leftPoints[1])
        guard leftAngle > 3 else {
            return false
        }
        
        let rightPoints = getAdjacentTwoPoints(index: index, ailgen: .right)
        guard rightPoints.count == 2 else {
            return false
        }
        let rightAngle = getAnglesWithThreePoints(p1: currentPoint , p2: rightPoints[0], p3: rightPoints[1])
        guard rightAngle > 3 else {
            return false
        }
        
        
        let centerPoints = getAdjacentTwoPoints(index: index, ailgen: .center)
        guard centerPoints.count == 2 else {
            return false
        }
        let centerAngle = getAnglesWithThreePoints(p1: centerPoints[0] , p2:  currentPoint, p3: centerPoints[1])
        guard centerAngle > 3 else {
            return false
        }
        return true
    }
    
    private
    func getAdjacentTwoPoints(index: Int, ailgen: PointAlign) -> [CGPoint] {
        var _points : [CGPoint] = []
        var currentIndex = index
        if ailgen == .left {
            currentIndex = (currentIndex + 1) >= self.points.count ? 0 : currentIndex + 1
            _points.append(self.points[currentIndex])
            currentIndex = (currentIndex + 1) >= self.points.count ? 0 : currentIndex + 1
            _points.append(self.points[currentIndex])
        }else if ailgen == .right {
            currentIndex = (currentIndex - 1) < 0 ? self.points.count - 1 : currentIndex - 1
            _points.append(self.points[currentIndex])
            currentIndex = (currentIndex - 1) < 0 ? self.points.count - 1 : currentIndex - 1
            _points.append(self.points[currentIndex])
        }else if ailgen == .center {
            let temp = currentIndex
            currentIndex = (temp - 1) < 0 ? self.points.count - 1 : temp - 1
            _points.append(self.points[currentIndex])
            currentIndex = (temp + 1) >= self.points.count ? 0 : temp + 1
            
            _points.append(self.points[currentIndex])
        }
        return _points
    }
    
    
    
    private func vaild(minV: CGFloat, maxV: CGFloat, value: inout CGFloat) {
        value = min(max(minV + 5, value), maxV - 5)
    }
    
    private func findPoint(point: CGPoint) -> Int {
        var lessPoint : Int = -1
        var minDistan : CGFloat = 1000
        for index in 0..<self.points.count {
            let between = self.distanceBetweenPoints(first: self.points[index], second: point)
            if between < minDistan {
                lessPoint = index
                minDistan = between
            }
        }
        if minDistan > self.maxDistance {
            return -1
        }
        return lessPoint
    }
    
    
    func getAnglesWithThreePoints(p1: CGPoint, p2: CGPoint, p3: CGPoint) -> Double {
        
        let x1 = p1.x - p2.x
        let y1 = p1.y - p2.y
        let x2 = p3.x - p2.x
        let y2 = p3.y - p2.y
        
        let x = x1 * x2 + y1 * y2
        let y = x1 * y2 - x2 * y1
        let angle = acos(x / sqrt(x * x + y * y))
        return Double(angle * 180.0) / Double.pi       //弧度值
    }
    
    private func lineIntersection(line1Start: CGPoint, line1End: CGPoint, line2Start: CGPoint , line2End: CGPoint) -> Bool {
        
        let a1 = line1End.y - line1Start.y
        let b1 = line1Start.x - line1End.x
        let c1 = a1 * line1Start.x + b1 * line1Start.y
        
        //转换成一般式: Ax+By = C
        let a2 = line2End.y - line2Start.y
        let b2 = line2Start.x - line2End.x
        let c2 = a2 * line2Start.x + b2 * line2Start.y
        
        
        let d = a1 * b2 - a2 * b1
        
        
        if (d == 0) {
            return false
        } else {
            let x = (b2*c1 - b1*c2) / d
            let y = (a1*c2 - a2*c1) / d
            
            
            
            if ((self.isInBetween(a: line1Start.x, b: x , c: line1End.x) || self.isInBetween(a: line1Start.y, b: y , c: line1End.y))
                &&
                (self.isInBetween(a: line2Start.x, b: x , c: line2End.x) || self.isInBetween(a: line2Start.y, b: y , c: line2End.y))) {
                return true
            }
        }
        return false
    }
    
    
    private func isInBetween(a: CGFloat, b: CGFloat, c: CGFloat) -> Bool {
        
        
        if (abs( a - b) < 2 ||  abs(b - c) < 2) {
            return false
        }
        return (a < b && b < c) || (c < b && b < a)
    }
    
    private func distanceBetweenPoints (first: CGPoint, second: CGPoint) -> CGFloat {
        let deltaX : CGFloat = second.x - first.x
        let deltaY : CGFloat = second.y - first.y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
}
