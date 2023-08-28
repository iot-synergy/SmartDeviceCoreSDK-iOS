//


//


//

import UIKit
import SmartDeviceCoreSDK

class A4xVideoTimerContontView: UIView {
    static let defaultItemWidth: CGFloat = 120
    static let itemMaxWidth: CGFloat = 160
    static let itemMinWidth: CGFloat = 80
    //static let saftWidht: CGFloat = 21
    static let dataLineHeight : CGFloat = 24
    
    var startReloadData : Bool = false
    
    private var _itemWidth: CGFloat = A4xVideoTimerContontView.defaultItemWidth
    
    var itemWidth: CGFloat = A4xVideoTimerContontView.itemMinWidth
    
    var leftViewBlock: (() -> A4xVideoChildView?)?
    var rightViewBlock: (() -> A4xVideoChildView?)?
    
    var timeStep: Int
    
    var currentDate: Date = Date() {
        didSet {
            logDebug("currentDate update currentDate: \(currentDate)")
            self.setNeedsDisplay()
        }
    }
    
    var minDate: Date {
        didSet {
            logDebug("minDate update currentDate: \(currentDate) minDate: \(minDate)")
            self.setNeedsDisplay()
        }
    }
    
    func reloadDate(comple: @escaping (()->Void ) = {}) {
        startReloadData = true
        if leftView != nil {
            leftView?.removeFromSuperview()
            leftView = nil
        }
        
        if rightView != nil {
            rightView?.removeFromSuperview()
            rightView = nil
        }
        
        if let leftView = self.leftViewBlock?() {
            self.addSubview(leftView)
            self.leftView = leftView
            
        }
        
        if let rightView = self.rightViewBlock?() {
            self.addSubview(rightView)
            self.rightView = rightView
        }
        self.viewModel.clearData()
        self.loadMoreDate(lastDrawDate: self.minDate, comple: comple)
    }
    
    var rightView: A4xVideoChildView?
    var leftView: A4xVideoChildView?
    var viewModel: A4xVideoTimerViewModel
    
    var maxShowDate: Date {
        return Date()
    }
    
    private var timeMaxDrawDate: Date {
        return self.maxShowDate.videoDrawMaxDate()
    }
    
    var isFirstMin: Bool = true
    
    
    func hasDataDate(date: Date) -> (A4xVideoTimeModel?, Date) {
        
        var hasData: A4xVideoTimeModel? = nil
        
        let timeInterval = date.timeIntervalSince1970
        
        var resultDate: Date = date
        
        
        self.viewModel.dataSources.forEach({ (modle) in
            if modle.start != 0, modle.end != 0 {
                if modle.start <= Int64(timeInterval) && modle.end >= Int64(timeInterval) && hasData == nil {
                    hasData = modle
                }
            }
        })
        
        let adjoinTime = (CGFloat(self.timeStep) / CGFloat(itemWidth)) * A4xVideoTimerContontView.dataLineHeight / 2
        
        
        if hasData == nil {
            
            self.viewModel.dataSources.forEach({ (modle) in
                
                if modle.start != 0, modle.end != 0 {
                    //
                    if (modle.start - Int64(adjoinTime)) <= Int64(timeInterval) && (modle.end + Int64(adjoinTime)) >= Int64(timeInterval) && hasData == nil {
                        hasData = modle
                        
                        
                        if modle.start > Int64(timeInterval) {
                            resultDate = Date(timeIntervalSince1970: TimeInterval(modle.start))
                        } else if modle.end < Int64(timeInterval) {
                            
                            resultDate = Date(timeIntervalSince1970: TimeInterval(modle.end))
                        }
                    }
                }
            })
        }
        return (hasData, resultDate)
    }
    
    var zoom: Float {
        set {
            setProgress(progress: newValue)
        }
        get {
            return getProgress()
        }
    }
    
    var zoomChangeBlock: ((Float, _ timeUnit: Int) -> Void)? {
        didSet {
            self.zoomChangeBlock?(self.zoom, self.timeStep)
        }
    }
    
    override init(frame: CGRect = .zero) {
        self.timeStep = A4xSDVideoPlaySpacers.default()
        minDate = Date()
        viewModel = A4xVideoTimerViewModel(loadDataBlock: { _,_,_  in })
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.addGestureRecognizer(pinchRecognizer)
    }
    
    init(frame: CGRect = .zero, loadDataBlock: @escaping ((_ fromDate: Date, _ toDate: Date, _ comple: @escaping ((_ isError : Bool, _ dateSourde: [A4xVideoTimeModel]?, _  fromDate: Date, _ toDate: Date) -> Void))-> Void )) {
        self.timeStep = A4xSDVideoPlaySpacers.default()
        minDate = Date()
        viewModel = A4xVideoTimerViewModel(loadDataBlock: loadDataBlock)
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addGestureRecognizer(pinchRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var pinchRecognizer: UIPinchGestureRecognizer = {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognizer(sender:)))
        return pinch
    }()
    
    func reset(type: A4xDateType) {
        switch type {
        case .min:
            self.currentDate = self.minDate
        case .max:
            self.currentDate = self.maxShowDate
        default:
            break
        }
    }
    
    func moveLocation(value: CGFloat) {
        let tempMinTimeStep =  CGFloat(self.timeStep) / CGFloat(itemWidth)
        let offsetTime = tempMinTimeStep * value
        let startDrawDate: Date = currentDate.addingTimeInterval(TimeInterval(offsetTime))
        self.currentDate = startDrawDate
    }
    
    func toBounds(withMove value: CGFloat) -> Int {
        let tempMinTimeStep =  CGFloat(self.timeStep) / CGFloat(itemWidth)
        let offsetTime = tempMinTimeStep * value
        let date = currentDate.addingTimeInterval(TimeInterval(offsetTime))
        if date.timeIntervalSince1970 <= self.minDate.timeIntervalSince1970  {
            return Int((self.minDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970) / Double(tempMinTimeStep))
        } else if date.timeIntervalSince1970 >= self.maxShowDate.timeIntervalSince1970 {
            return Int((self.maxShowDate.timeIntervalSince1970 - currentDate.timeIntervalSince1970) / Double(tempMinTimeStep))
        } else {
            return Int(value)
        }
    }
    
    func getTime(withMove value: CGFloat) -> (Date, A4xDateType) {
        let tempMinTimeStep =  CGFloat(self.timeStep) / CGFloat(itemWidth)
        let offsetTime = tempMinTimeStep * value
        var type : A4xDateType = .none
        
        var date = currentDate.addingTimeInterval(TimeInterval(offsetTime))
        
        if date.timeIntervalSince1970 <= self.minDate.timeIntervalSince1970 {
            type = .min
            date = self.minDate
        } else if date.timeIntervalSince1970 >= self.maxShowDate.timeIntervalSince1970 {
            type = .max
            date = self.maxShowDate
            
        }
        return (date, type)
    }
    
    @objc private func pinchRecognizer(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        sender.scale = 1
        let tempMinTimeStep = CGFloat(itemWidth) / CGFloat(self.timeStep)
        let toPxTimer = CGFloat(tempMinTimeStep) * CGFloat(scale)
        let tempWidth = toPxTimer * CGFloat(self.timeStep)
        
        defer {
            self.zoomChangeBlock?(self.zoom , self.timeStep)
        }
        
        if tempWidth <= A4xVideoTimerContontView.itemMinWidth {
            let greatSetp = A4xSDVideoPlaySpacers.great(self.timeStep)
            if self.timeStep == greatSetp {
                itemWidth = A4xVideoTimerContontView.itemMinWidth
                self.setNeedsDisplay()
                return
            }
            self.timeStep = A4xSDVideoPlaySpacers.great(self.timeStep)
        } else if tempWidth >= A4xVideoTimerContontView.itemMaxWidth {
            let greatSetp = A4xSDVideoPlaySpacers.less(self.timeStep)
            if self.timeStep == greatSetp {
                itemWidth = A4xVideoTimerContontView.itemMaxWidth
                self.setNeedsDisplay()
                return
            }
            self.timeStep = A4xSDVideoPlaySpacers.less(self.timeStep)
        }
        self.itemWidth = CGFloat(self.timeStep) * toPxTimer
        self.setNeedsDisplay()
        
    }
    
    private func loadMoreDate(lastDrawDate: Date, comple: @escaping (()->Void ) = {}) {
        
        
        
        let timerange = CGFloat(self.timeStep) / CGFloat(itemWidth) * self.width
        
        logDebug("A4xVideoTimerContontView loadMoreDate canLoadMoreData currentDate: \(currentDate)【\(currentDate.timeIntervalSince1970)】 lastDrawDate: \(lastDrawDate) 【\(lastDrawDate.timeIntervalSince1970)】 timerange: \(timerange)")
        
        
        //maxTimeRange:最大时间区间
        self.viewModel.loadData(currentTime: currentDate, maxTimeRange: TimeInterval(timerange)) { [weak self] (datas) in
            if datas.count >  0 {
                self?.setNeedsDisplay()
            }
            comple()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !startReloadData {
            return
        }
        
        let ctx = UIGraphicsGetCurrentContext()
        let pointSize = CGSize(width: 2, height: 2)
        let drawInfos = self.itemInfo(stepWidth: itemWidth, stepTimer: TimeInterval(self.timeStep))
        
        let itemsInfos: [A4xSDVideoTimeItem] = drawInfos.drawTimeDatas //self.itemInfo(stepWidth: itemWidth, stepTimer: TimeInterval(self.timeStep))
        
        itemsInfos.forEach { (item) in
            switch item {
            case .point(let center , let alpha):
                let bepath = UIBezierPath(roundedRect: CGRect(x: center.x -  pointSize.width / 2, y: center.y -  pointSize.height / 2 , width: pointSize.width, height: pointSize.height), cornerRadius: pointSize.height / 2)
                
                ctx?.addPath(bepath.cgPath)
                ctx?.setFillColor(UIColor.black.withAlphaComponent(CGFloat(alpha)).cgColor)
                ctx?.drawPath(using: .fill)
            case .text(let center, let text, let alpha):
                let attrsting : NSMutableAttributedString = NSMutableAttributedString(string: text ?? "")
                
                let attr: [NSAttributedString.Key : Any] = [.font:  UIFont.systemFont(ofSize: 12) ,.foregroundColor: UIColor(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 1).withAlphaComponent(CGFloat(alpha))]
                attrsting.addAttributes(attr, range: NSRange(location: 0, length: attrsting.string.count))
                let size = attrsting.boundingRect(with: CGSize(width: 100, height: 20), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size
                attrsting.draw(in: CGRect(x: center.x - size.width / 2, y: center.y - size.height / 2 , width: size.width, height: size.height))
                
            }
        }
        
        let startDrawDate: Date = drawInfos.drawMinDate
        let endDrawDate: Date = drawInfos.drawMaxDate
        
        let path = drawUserDatas(startDate: startDrawDate, endDate: endDrawDate)
        UIColor(red: 0.8, green: 0.81, blue: 0.83, alpha: 1).setStroke()
        path.stroke()
        
        
        logDebug("-------------> startDrawDate: \(startDrawDate)")
        self.loadMoreDate(lastDrawDate: startDrawDate)
        
        if let leftView: UIView = self.leftView {
            
            leftView.isHidden = true
            if startDrawDate.timeIntervalSince1970 < self.minDate.timeIntervalSince1970 {
                leftView.isHidden = false
                let xlocation = getXLocation(dateTimeInte: self.minDate.timeIntervalSince1970)
                let toMinWidth = self.bounds.width / 6
                leftView.frame = CGRect(x: xlocation - toMinWidth, y: 0, width: toMinWidth, height: self.bounds.height)
            }
        }
        
        if let rightView: UIView = self.rightView {
            rightView.isHidden = true
            if endDrawDate.timeIntervalSince1970  > self.maxShowDate.timeIntervalSince1970 {
                rightView.isHidden = false
                let xlocation = getXLocation(dateTimeInte: self.maxShowDate.timeIntervalSince1970)
                let toMinWidth = self.bounds.width / 6
                rightView.frame = CGRect(x: xlocation, y: 0, width: toMinWidth, height: self.bounds.height )
            }
        }
    }
}


extension A4xVideoTimerContontView {
    
    private func itemInfo(stepWidth: CGFloat, stepTimer: TimeInterval) -> (drawTimeDatas: [A4xSDVideoTimeItem], drawMinDate: Date, drawMaxDate: Date) {
        
        var itemInfos: [A4xSDVideoTimeItem] = []
        let offsetTime = currentDate.timeIntervalSince1970.truncatingRemainder(dividingBy: TimeInterval(stepTimer))
        
        let offsetX = (offsetTime / stepTimer) * Double(stepWidth)
        let yValue: CGFloat = 23
        
        let centerX = self.bounds.width / 2
        
        var leftCenterX =  self.bounds.width / 2 -  CGFloat(offsetX)
        
        let startDrawDate: Date = currentDate.addingTimeInterval(-offsetTime)
        
        var index = 0
        
        var minDrawDate: Date?
        var maxDrawDate: Date?
        
        while leftCenterX > -stepWidth {
            
            let data =  startDrawDate.addingTimeInterval(TimeInterval(-Double(index) * stepTimer))
            
            if data.timeIntervalSince1970 >= self.minDate.timeIntervalSince1970 && data.timeIntervalSince1970 <= self.timeMaxDrawDate.timeIntervalSince1970 {
                
                itemInfos.append(A4xSDVideoTimeItem.text(center: CGPoint(x: leftCenterX, y: yValue), text: dateString(date: data), alpha: 1 ))
                
                let xvalue = leftCenterX + stepWidth / 2
                
                if xvalue < centerX {
                    itemInfos.append(A4xSDVideoTimeItem.point(center: CGPoint(x: leftCenterX + stepWidth / 2, y: yValue), alpha: 1 ))
                }
            } else {
                if data.timeIntervalSince1970 < self.minDate.timeIntervalSince1970 {
                    minDrawDate = data
                } else if data.timeIntervalSince1970 > self.timeMaxDrawDate.timeIntervalSince1970 {
                    maxDrawDate = data
                }
            }
            leftCenterX -= stepWidth
            index += 1
        }
        
        if minDrawDate == nil {
            minDrawDate = startDrawDate.addingTimeInterval(TimeInterval(-Double(index) * stepTimer))
        }
        
        var rightCenterX = (stepWidth - CGFloat(offsetX)) + self.bounds.width / 2
        index = 0
        
        while rightCenterX < self.bounds.width + stepWidth {
            index += 1
            let data = startDrawDate.addingTimeInterval(TimeInterval(Double(index) * stepTimer))
            
            if data.timeIntervalSince1970 >= self.minDate.timeIntervalSince1970 && data.timeIntervalSince1970 <= self.timeMaxDrawDate.timeIntervalSince1970 {
                
                let pointXvalue = rightCenterX - stepWidth / 2
                if pointXvalue > centerX {
                    itemInfos.append(A4xSDVideoTimeItem.point(center: CGPoint(x: pointXvalue , y: yValue), alpha: 1 ))
                }
                
                itemInfos.append(A4xSDVideoTimeItem.text(center: CGPoint(x: rightCenterX, y: yValue), text: dateString(date: data), alpha: 1 ))
            } else {
                
                if data.timeIntervalSince1970 < self.minDate.timeIntervalSince1970 {
                    minDrawDate = data
                } else if data.timeIntervalSince1970 > self.timeMaxDrawDate.timeIntervalSince1970 {
                    maxDrawDate = data
                }
            }
            rightCenterX += stepWidth
            
        }
        
        if maxDrawDate == nil {
            maxDrawDate =  startDrawDate.addingTimeInterval(TimeInterval(Double(index) * stepTimer))
        }
        return (itemInfos, minDrawDate!, maxDrawDate!)
    }
    
    private func drawUserDatas(startDate: Date, endDate: Date) -> UIBezierPath {
        
        let startTimeInterval = startDate.timeIntervalSince1970
        let endTimeInterval = endDate.timeIntervalSince1970
        let dataBezierPath: UIBezierPath = UIBezierPath()
        dataBezierPath.lineCapStyle = .round
        dataBezierPath.lineWidth = A4xVideoTimerContontView.dataLineHeight
        
        guard self.viewModel.dataSources.count > 0 else {
            return dataBezierPath
        }
        
        var tempBezierPath: UIBezierPath? = nil
        var lastXvalue: CGFloat?
        let yvalue = self.bounds.midY - 10
        
        self.viewModel.dataSources.forEach { (timerModel) in
            let start = timerModel.start ?? 0
            let end = timerModel.end ?? 0
            
            if start > end {
                return
            }
            
            if start <= Int64(endTimeInterval) && end > Int64(startTimeInterval) {
                let startXValue = getXLocation(dateTimeInte: Double(start))
                let endXValue = getXLocation(dateTimeInte: Double(end))
                if let lastX = lastXvalue {
                    if lastX + A4xVideoTimerContontView.dataLineHeight > startXValue {
                        lastXvalue = endXValue
                        return
                    } else {
                        if let path = tempBezierPath {
                            path.addLine(to: CGPoint(x: lastX, y: yvalue))
                            dataBezierPath.append(path)
                        }
                    }
                    lastXvalue = nil
                }
                
                tempBezierPath = UIBezierPath()
                tempBezierPath?.move(to: CGPoint(x: startXValue, y: yvalue))
                lastXvalue = endXValue
            }
        }
        
        if let path = tempBezierPath {
            if let lastX = lastXvalue {
                path.addLine(to: CGPoint(x: lastX, y: yvalue))
            }
            
            dataBezierPath.append(path)
        }
        
        return dataBezierPath
    }
    
    
    func getXLocation(dateTimeInte: Double) -> CGFloat {
        let tempMinTimeStep =  Double(self.timeStep) / Double(itemWidth)
        let currentDataTimeInter = currentDate.timeIntervalSince1970
        
        let x = self.bounds.midX + CGFloat(dateTimeInte - currentDataTimeInter) / CGFloat(tempMinTimeStep)
        return x
    }
    
    private func dateString(date: Date) -> String {
        let is24HrFormatStr = "".timeFormatIs24Hr() ? kA4xDateFormat_24 : kA4xDateFormat_12
        let fmt = DateFormatter();
        fmt.dateFormat = is24HrFormatStr;
        fmt.locale = Locale.current;
        fmt.timeZone = NSTimeZone.local;
        return fmt.string(from: date)
    }
}

extension A4xVideoTimerContontView {
    func getProgress() -> Float {
        let setpProgress = 1.0 / Float(A4xSDVideoPlaySpacers.timeSpacers.count)
        var currentIndex = 0
        if let index = A4xSDVideoPlaySpacers.timeSpacers.firstIndex(of: self.timeStep) {
            currentIndex = index
        }
        let subProgress = Float(self.itemWidth -  A4xVideoTimerContontView.itemMinWidth) / Float(A4xVideoTimerContontView.itemMaxWidth - A4xVideoTimerContontView.itemMinWidth) * Float(setpProgress)
        
        let progress = max(0, min(1, 1 - (Float(currentIndex) * setpProgress + subProgress)))
        setProgress(progress: progress)
        return progress
    }
    
    func setProgress(progress pro: Float) {
        let progress = 1 - pro
        
        let setpProgress = 1.0 / Float(A4xSDVideoPlaySpacers.timeSpacers.count)
        let index : Int = Int(floor(progress / setpProgress))
        
        let subProgress = progress - Float(index) * setpProgress
        
        let toWidth = subProgress * Float(A4xVideoTimerContontView.itemMaxWidth - A4xVideoTimerContontView.itemMinWidth) / Float(setpProgress) + Float(A4xVideoTimerContontView.itemMinWidth)
        
        if index < 0 ||  index + 1 > A4xSDVideoPlaySpacers.timeSpacers.count {
            return
        }
        
        self.timeStep = A4xSDVideoPlaySpacers.timeSpacers[index]
        self.itemWidth = CGFloat(toWidth)
        self.setNeedsDisplay()
    }
    
}
