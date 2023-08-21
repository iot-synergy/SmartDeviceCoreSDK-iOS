//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK

enum ADScrollDirection {
    case left
    case right
    case none
}

extension Date {
    func dateIntCount() -> Int {
        return self.dateString().intValue()
    }
    
}

class A4xVideoTimerView: UIView, UIScrollViewDelegate {
    
    weak var videoDelegate : A4xVideoTimerViewProtocol?
    var showDayCount: Int = 7
    init(frame: CGRect = .zero , delegate : A4xVideoTimerViewProtocol, showDayCount: Int) {
        super.init(frame: frame)
        self.showDayCount = showDayCount
        self.videoDelegate = delegate
        self.scrollView.isHidden = false
        self.timerView.isHidden = false
        self.scrollView.isHidden = false
        self.slider.isHidden = false
        self.indicatorView.isHidden = false
        self.leftDateView.isHidden = false
        self.rightDateView.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var minDate: Date {
        get {
            return self.timerView.minDate
        }
        set {
            self.timerView.minDate = newValue
        }
    }
    
    var childViews: [A4xVideoChildView] = []
    
    var currentIsChange : Bool = true
    
    private var lastShowDay : Int = 0
    private var dayCount : Int? {
        didSet {
            if let d = dayCount, let old = oldValue  {
                if d > old {
                    self.showRightTime()
                    lastShowDay = d
                }else if d < old {
                    self.showLeftTime()
                    lastShowDay = d
                }
            }
        }
    }
    
    
    private var selectDate: Date? {
        didSet {
            if let d = selectDate {
                self.videoDelegate?.timerView(timerView: self, willSelectDate: d)
                if !self.scrollView.isDragging && !self.scrollView.isDecelerating {
                    self.timerView.currentDate = d
                    self.resetTimer()
                    self.dayCount = d.dateIntCount()

                }
                self.indicatorView.setDate(date: d, show: self.scrollView.isDragging)                
            }
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let temp = UIScrollView()
        temp.decelerationRate = .init(rawValue: 0.1)
        temp.delegate = self
        temp.bounces = false
        self.addSubview(temp)
        return temp
    }()
    
    deinit {
        A4xLog(type(of: self).description() + "deinit")
    }
    
    lazy var timerView: A4xVideoTimerContontView = {
        weak var weakSelf = self

        let temp = A4xVideoTimerContontView { [weak self](from, to, comple) in
            if let strongself = weakSelf {
                strongself.videoDelegate?.timerLoadDate(timerView: strongself, fromDate: from, toDate: to, comple: { (flag, datas) in
                    
                    comple(!flag, datas, from, to)
                })
            }
        }
        
        temp.zoomChangeBlock = { (zoom , unit) in
            weakSelf?.slider.value = zoom
        }
        
        temp.leftViewBlock = {
            return weakSelf?.loadMinView()
        }
        
        temp.rightViewBlock = {
            return weakSelf?.loadMaxView()
        }
        self.scrollView.addSubview(temp)
        return temp
    }()
    
    private lazy var indicatorView: A4xSDTimerIndicator = {
        let temp = A4xSDTimerIndicator()
        self.insertSubview(temp, belowSubview: self.slider)
        return temp
    }()
    
    private lazy var slider: A4xTimerSliderView = {
        let temp = A4xTimerSliderView()
        self.addSubview(temp)
        weak var weakSelf = self
        temp.valueChangeBlock = { value in
            weakSelf?.timerView.zoom = value
        }
        temp.timeUnitBlock = {
            return weakSelf?.timerView.timeStep ?? 60
        }
        return temp
    }()
    
    private lazy var leftDateView: A4xTimerDateView = {
        let temp = A4xTimerDateView()
        self.addSubview(temp)

        return temp
    }()
    
    private lazy var rightDateView: A4xTimerDateView = {
        let temp = A4xTimerDateView()
        self.addSubview(temp)
        return temp
    }()
    
    
    private func updateFrame() {
        self.scrollView.frame = self.bounds
        self.timerView.frame = CGRect(x: 0, y: 0, width: self.bounds.width * 3, height: self.bounds.height)
        self.scrollView.contentSize = CGSize(width: self.bounds.width * 3, height: self.bounds.height)
        self.slider.frame = CGRect(x: 60 , y: self.bounds.maxY - 80 - 15, width: (self.bounds.width - 120 ), height: 84)
        self.indicatorView.frame = CGRect(x: self.bounds.width / 2 - 1, y: 40, width: 2, height: self.slider.minY + 20)
        self.leftDateView.frame = CGRect(x: -64 , y: self.bounds.midY - 64 / 2 , width: 64, height: 55)
        self.rightDateView.frame = CGRect(x: self.bounds.maxX, y: self.bounds.midY - 64 / 2 , width: 64, height: 55)
        let defaultCenterX = self.bounds.width
        self.scrollView.delegate = nil
        self.scrollView.contentOffset = CGPoint(x: defaultCenterX, y: 0)
        self.scrollView.delegate = self

        self.leftDateView.date = Date()
        self.rightDateView.date = Date()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }
    
    func loadMinView() -> A4xVideoChildView? {
        let timerMinView = self.videoDelegate?.timerMinView(timerView: self)
        if let t : A4xVideoChildView = timerMinView {
            self.childViews = self.childViews.map({ (child) -> A4xVideoChildView in
                if child.identifier == t.identifier {
                    return t
                }
                return child
            })
        }
        return timerMinView
    }
    
    func loadMaxView() -> A4xVideoChildView? {
        let timerMaxView = self.videoDelegate?.timerMaxView(timerView: self)
        if let t : A4xVideoChildView = timerMaxView {
            self.childViews = self.childViews.map({ (child) -> A4xVideoChildView in
                if child.identifier == t.identifier {
                    return t
                }
                return child
            })
        }
        return timerMaxView
    }
    
    func updateTimerView(){
        A4xLog("A4xVideoTimerView updateTimerView")
        let defaultCenterX = self.bounds.width
        let offset = self.scrollView.contentOffset.x
        timerView.moveLocation(value: offset - defaultCenterX)
        self.scrollView.contentOffset = CGPoint(x: defaultCenterX, y: 0)
    }
    
    func resetTimer(){
        A4xLog("A4xVideoTimerView resetTimer")
        let defaultCenterX = self.bounds.width
        self.scrollView.contentOffset = CGPoint(x: defaultCenterX, y: 0)
    }
    
    private func getScrollDirection(_ scrollView: UIScrollView) -> ADScrollDirection {
        let vel = scrollView.panGestureRecognizer.velocity(in: scrollView)
        if vel.x < -5 {
            //向上拖动
            //NSLog("向左拖动")
            return .left
        }else if vel.x > 5 {
            //向下拖动
            //NSLog("向右拖动")
            return .right
        }else if vel.x == 0 {
            //停止拖拽
            //NSLog("停止拖拽")
            return .none
        }
        return .none
    }
    
    private func checkUpdateTimeView(type : A4xDateType) {
        A4xLog("A4xVideoTimerView checkUpdateTimeView \(type)")
        let scrollDirection = getScrollDirection(self.scrollView)
        switch type {
        case .none:
            return
        case .min:
            if scrollDirection == .right {
                scrollView.panGestureRecognizer.isEnabled = false
                scrollView.panGestureRecognizer.isEnabled = true
            }
        case .max:
            if scrollDirection == .left {
                scrollView.panGestureRecognizer.isEnabled = false
                scrollView.panGestureRecognizer.isEnabled = true
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultCenterX = self.bounds.width
        let offset = scrollView.contentOffset.x
        A4xLog("A4xVideoTimerView scrollViewDidScroll \(scrollView.contentOffset.x)")
        let (_,type) = timerView.getTime(withMove: offset - defaultCenterX)
        checkUpdateTimeView(type: type)
        let (date,_) = timerView.getTime(withMove: offset - defaultCenterX)
        self.selectDate = date
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        A4xLog("A4xVideoTimerView DidEndDecelerating \(scrollView.contentOffset.x)")
        self.updateTimerView()
        let currentData = timerView.currentDate
        let (selectDate, date) = self.timerView.hasDataDate(date: currentData)
        self.videoDelegate?.timerView(timerView: self, didSelectDate: date, inData: selectDate)
      
    }
            
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee.x
        A4xLog("A4xVideoTimerView WillEndDragging targetOffset \(targetOffset) current \(scrollView.contentOffset.x)")
        let defaultCenterX = self.bounds.width
        let temp = timerView.toBounds(withMove: targetOffset - defaultCenterX)
        if CGFloat(temp) != targetOffset - defaultCenterX {
            targetContentOffset.pointee = CGPoint(x: CGFloat(temp) + defaultCenterX, y: 0)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        A4xLog("A4xVideoTimerView didEndDragging  \(scrollView.contentOffset.x)  decelerate \(decelerate ? "正在" : "不在") 减速")
        if !decelerate {
            self.updateTimerView()
            if let date = self.selectDate {
                let (selectDate , date) = self.timerView.hasDataDate(date: date)
                self.videoDelegate?.timerView(timerView: self, didSelectDate: date, inData: selectDate)
            }
        }
    }
}


extension A4xVideoTimerView : A4xVideoTimerViewInterface {
  
    
    func timerCurrentInfo(date: Date? = nil) -> (Date, A4xVideoTimeModel?) {
        let currentDate = (date == nil ? self.selectDate : date)
        let (currentData, date) = self.timerView.hasDataDate(date: currentDate ?? Date())
        return (date, currentData)
    }
    
    var timerSelectDate: Date? {
        set {
            if newValue == nil {
                return
            }
            if currentIsChange && timerSelectDate != nil {
                return
            }
            
            self.selectDate = newValue
        }
        get {
            return self.selectDate
        }
    }
    
    var `protocol` : A4xVideoTimerViewProtocol? {
        set {
            self.videoDelegate = newValue
        }
        get {
            return self.videoDelegate
        }
    }
    var timerMinDate: Date {
        get {
            return self.timerView.minDate
        }
    }
    
    var timerMaxDate: Date {
        get {
            return self.timerView.maxShowDate
        }
    }
    
    func timerMinView(of Identifier: String) -> A4xVideoChildView? {
        var childView : A4xVideoChildView? = nil
        self.childViews.forEach({ (child) in
            if child.identifier == Identifier {
                childView = child
            }
        })
        return childView
    }
    
    func timerMaxView(of Identifier: String) -> A4xVideoChildView? {
        var childView : A4xVideoChildView? = nil
        self.childViews.forEach({ (child) in
            if child.identifier == Identifier {
                childView = child
            }
        })
        return childView
    }
    
    func reloadDate(comple: @escaping (() -> Void) = {}) {
        self.timerView.reloadDate(comple: comple)
    }
}

extension A4xVideoTimerView {
    func showLeftTime(){
        //print("show showLeftTime ")
        self.leftDateView.date = self.selectDate
        UIView.animateKeyframes(withDuration: 2, delay: 0, options:
            UIView.KeyframeAnimationOptions.layoutSubviews, animations: {
                let xvalue = self.leftDateView.frame.minX
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                    self.leftDateView.frame = CGRect(x: 0, y: self.leftDateView.frame.minY, width: self.leftDateView.bounds.width, height: self.leftDateView.bounds.height)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                    self.leftDateView.frame = CGRect(x: xvalue, y: self.leftDateView.frame.minY, width: self.leftDateView.bounds.width, height: self.leftDateView.bounds.height)
                }
        }) { (f) in
            
        }
    }
    
    func showRightTime(){
        //print("show showRightTime ")
        let xvalue = self.bounds.width
        self.rightDateView.date = self.selectDate

        self.rightDateView.frame = CGRect(x: xvalue, y: self.rightDateView.frame.minY, width: self.rightDateView.bounds.width, height: self.rightDateView.bounds.height)

        UIView.animateKeyframes(withDuration: 2, delay: 0, options:
            UIView.KeyframeAnimationOptions.layoutSubviews, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                    self.rightDateView.frame = CGRect(x: self.bounds.width - self.rightDateView.bounds.width, y: self.rightDateView.frame.minY, width: self.rightDateView.bounds.width, height: self.rightDateView.bounds.height)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                    self.rightDateView.frame = CGRect(x: xvalue, y: self.rightDateView.frame.minY, width: self.rightDateView.bounds.width, height: self.rightDateView.bounds.height)
                }
        }) { (f) in
            
        }
    }
}
