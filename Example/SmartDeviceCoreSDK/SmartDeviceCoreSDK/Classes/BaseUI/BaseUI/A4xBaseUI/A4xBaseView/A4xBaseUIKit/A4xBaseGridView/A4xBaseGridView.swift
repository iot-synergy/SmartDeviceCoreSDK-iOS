//


//


//

import UIKit
import SmartDeviceCoreSDK


public protocol A4xBaseGridViewDelegate: NSObjectProtocol {
    
    func onClickImageView(imageStrs: [String], index: Int)
    func onClickBtnView(btn: UIButton, status: String)
}

public class A4xBaseGridView: UIView {
    public var delegate: A4xBaseGridViewDelegate?
    
    
    public var topSpace: CGFloat = 0 
    public var bottomSpace: CGFloat = 0 
    public var leadingSpace: CGFloat = 0 
    public var trailingSpace: CGFloat = 0 
    public var middleSpace: CGFloat = -1
    public var gridWidth: CGFloat = 320 {
        didSet {
            addCellViews()
        }
    }
    
    public var sleepPlanModelArr: [DeviceSleepPlanBean]? = [] {
        didSet {




//










        }
    }
    
    public var removeOldUI: Bool = false {
        didSet {
            if removeOldUI {
                let sleepPlanDataSource = Dictionary(grouping: sleepPlanModelArr ?? [], by: { $0.period })
                if sleepPlanDataSource.count > 0 {
                    for (key, _) in sleepPlanDataSource {
                        let subV = self.getSubView(name: "UIButton")
                        if subV.count > 0 {
                            subV.forEach { (v) in
                                if v.tag / 1000 == key {
                                    v.removeFromSuperview()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    public var rowTitleArr: [String] = []
    public var columnTitleArr: [String] = []
    
    //var curRowTitleStr: String?
    public var curRowTitleIndex: Int?
    public var curColTitleStr: String?
    public var isTwoRowsTwoColumns: Bool = true  
    
    private var viewBox: UIView!
    
    
    public var imageStrs: [String] = [String]() {
        didSet { }
    }
    
    public var showCurrenTime: Bool = false {
        didSet {
            if showCurrenTime {
                DispatchQueue.main.a4xAfter(0.3) {
                    self.drawCurrenTime()
                }
            }
        }
    }
    
    public var canEdit: Bool = true {
        didSet {}
    }
    
    public var reLoadData: Bool = false {
        didSet {
            if reLoadData {
                self.sleepTimeArea()
            }
        }
    }
    
    public var boxNum: Int? = 0
    
    
    public var rows: Int = 7
    public var columns: Int = 6
    
    
    public var cellWidth: CGFloat = 110
    public var cellHeight: CGFloat = 110
    
    
    public var centerX0 = CGFloat(51.5.auto())
    public var centerY0 = CGFloat(46.auto())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func addCellViews() {
        
        if nil != viewBox {
            viewBox.removeFromSuperview()
        }
        
        let count = self.boxNum //self.imageStrs.count
        if 0 < count ?? 0 {
            viewBox = UIView()
            self.addSubview(viewBox)
            
            viewBox.snp.makeConstraints { (make) in
                make.edges.equalTo(self).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
        
            let index: Int = 0
            var x: CGFloat?
            var y: CGFloat?
            
            
            cellWidth = (self.gridWidth - leadingSpace - trailingSpace - (middleSpace * 6)) / 7
            cellHeight = (self.height - (middleSpace * 5) - centerY0 - CGFloat(23.auto())) / 6
            
            
            //let centerX0 = CGFloat(51.5.auto())
            //let centerY0 = CGFloat(46.auto())
            
            if 4 == count && self.isTwoRowsTwoColumns {
                rows = 2
                columns = 2
            }
            
            
            
           //6 +  
            for i in 0 ..< rows {
                for j in 0 ..< columns {
                    
                    x = centerX0 + CGFloat(i) * (cellWidth + middleSpace)
                    y = centerY0 + CGFloat(j) * (cellHeight + middleSpace)
                    
                    
                    let cell = A4xBaseGridViewCell()
                    cell.index = j * rows + i
                    
                    
                    //let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTapImageView(_:)))
                    cell.imgView.image = UIImage.init(color: (i % 2 == 0 ? UIColor.hex(hex: 0xFFFFFF) : UIColor.hex(hex: 0xFBFDFF)))
                    //cell.imgView.addGestureRecognizer(tap)
                    
                    cell.imgBtn.backgroundColor = .clear//i % 2 == 0 ? UIColor.colorFromHex("#FFFFFF") : UIColor.colorFromHex("#FBFDFF")
                    cell.imgBtn.addTarget(self, action: #selector(onTapBtnView(sender:)), for: .touchUpInside)
                    cell.imgBtn.isEnabled = canEdit
                    //
                    cell.imgBtn.tag = j * rows + i
                    viewBox.addSubview(cell)
                    
                    cell.snp.makeConstraints { (make) in
                        make.leading.equalTo(x!)
                        make.top.equalTo(y!)
                        make.width.equalTo(cellWidth)
                        make.height.equalTo(cellHeight)
                    }
                    
                    
                    if j == 0 {
                        if rowTitleArr.count > i {
                            let weekTitleLbl = UILabel()
                            weekTitleLbl.text = rowTitleArr[i]
                            weekTitleLbl.textColor = showCurrenTime ? (i == curRowTitleIndex ? ADTheme.Theme : ADTheme.C3) : ADTheme.C3
                            
                            weekTitleLbl.textAlignment = .center
                            weekTitleLbl.font = UIFont.medium(10)
                            viewBox.addSubview(weekTitleLbl)
                            
                            weekTitleLbl.snp.makeConstraints { (make) in
                                make.leading.equalTo(x!)
                                make.top.equalTo(0)
                                make.width.equalTo(cellWidth)
                                make.height.equalTo(46.auto())
                            }
                        }
                    }
                    
                    
                    if i == 0 {
                        if columnTitleArr.count > j {
                            let columnTitlelbl = UILabel()
                            columnTitlelbl.text = columnTitleArr[j]
                            columnTitlelbl.textColor = ADTheme.C3
                            columnTitlelbl.textAlignment = .center
                            columnTitlelbl.font = UIFont.medium(10)
                            viewBox.addSubview(columnTitlelbl)
                            
                            columnTitlelbl.snp.makeConstraints { (make) in
                                make.leading.equalTo(0)
                                make.top.equalTo(y! - 6)
                                make.width.equalTo(50.5.auto())
                            }
                            
                            if j == columns - 1 {
                                y = centerY0 + CGFloat(j + 1) * (cellHeight + middleSpace)
                                let columnTitlelbl = UILabel()
                                columnTitlelbl.text = columnTitleArr[columnTitleArr.count - 1]
                                columnTitlelbl.textColor = ADTheme.C3
                                columnTitlelbl.textAlignment = .center
                                columnTitlelbl.font = UIFont.medium(10)
                                viewBox.addSubview(columnTitlelbl)
                                
                                columnTitlelbl.snp.makeConstraints { (make) in
                                    make.leading.equalTo(0)
                                    make.top.equalTo(y! - 6)
                                    make.width.equalTo(50.5.auto())
                                }
                            }
                        }
                    }
                }
                if index == count {
                    break
                }
            }
            
            sleepTimeArea()
        }
    }
    
    private func drawCurrenTime() {
        let subV = self.getSubView(name: "UIView")
        if subV.count > 0 {
            subV.forEach { (v) in
                if v.tag == 9989 {
                    v.removeFromSuperview()
                }
            }
        }
        
        let lineView = UIView()
        lineView.backgroundColor = ADTheme.Theme
        lineView.tag = 9989
        self.addSubview(lineView)
        
        let frameY = self.timeLine(startTimeStr: columnTitleArr[0], endTimeStr: columnTitleArr[columns - 1], curTimerStr: self.curColTitleStr) ?? 0.0
        lineView.snp.makeConstraints({ (make) in
            make.top.equalTo(centerY0 + frameY)
            make.leading.equalTo(41.auto())
            make.width.equalTo(cellWidth * CGFloat(rows) + 4.auto())
            make.height.equalTo(1)
        })
        
        let dotView = UIView()
        dotView.tag = 9989
        dotView.backgroundColor = ADTheme.Theme
        self.addSubview(dotView)
        dotView.snp.makeConstraints({ (make) in
            make.leading.equalTo(lineView.snp.leading).offset(6.auto())
            make.centerY.equalTo(lineView.snp.centerY)
            make.width.height.equalTo(8.auto())
        })
        
        dotView.layoutIfNeeded()
        dotView.clipsToBounds = true
        dotView.filletedCorner(CGSize(width: 4.auto(), height: 4.auto()),UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue | UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
    }
    
    //
    @objc private func onTapImageView(_ sender: UITapGestureRecognizer) {
        if let view = sender.view?.superview as? A4xBaseGridViewCell {
            let selView = SelView()
            selView.frame = view.frame
            //view.addSubview(selView)
            self.addSubview(selView)
            
            self.delegate?.onClickImageView(imageStrs: self.imageStrs, index: view.index!)
        }
    }
    
    
    @objc private func onTapBtnView(sender: UIButton) {
        
        self.delegate?.onClickBtnView(btn: sender, status: "noArea")
    }
    
    @objc private func onSleepPlanBtn(_ sender: UIButton) {
        self.delegate?.onClickBtnView(btn: sender, status: "hasArea")
    }
    
    
    
    
    func sleepTimeArea() {
        
        
        let sleepPlanDataSource = Dictionary(grouping: sleepPlanModelArr ?? [], by: { $0.period })
        
        //let sleepPlanDataSource = sleepPlanModelArr?.reduce(into: [Int: [DeviceSleepPlanBean]]()) {
        
        //}
        
        
        var daySource: [Int : [Int]]? = [:]
        daySource = sleepPlanModelArr?.reduce(into: [Int: [Int]]()) {
            $0[$1.period ?? 1024, default: []].append($1.planDay ?? 0)
        }







        
        
        //var dayDic: [Int : [Int]] = [:]
        //if sleepPlanDataSource.count > 0 {
        
        
        
        
        //}
        
        
        if sleepPlanDataSource.count > 0 {
            for (key, value) in sleepPlanDataSource {
                //print("\(key ?? 1024) is \(value)")
                
                let subV = self.getSubView(name: "UIButton")
                if subV.count > 0 {
                    subV.forEach { (v) in
                        if v.tag / 1000 == key {
                            v.removeFromSuperview()
                        }
                    }
                }
                
                let dayArr = daySource?[key ?? 1024]?.sorted()
                
            
                var keyDay: Int = 0
                var curData: [Int] = []
                var data: [Int : [Int]] = [:]
                for i in 0..<(dayArr?.count ?? 0) {
                    if i + 1 < (dayArr?.count ?? 0 ) {
                        if 1 != (dayArr?[i + 1] ?? 0) - (dayArr?[i] ?? 0) {
                            curData.append(dayArr?[i] ?? 0)
                            data[keyDay] = curData
                            keyDay += 1
                            curData.removeAll()
                        } else {
                            curData.append(dayArr?[i] ?? 0)
                            data[keyDay] = curData
                        }
                    } else {
                        curData.append(dayArr?[i] ?? 0)
                        data[keyDay] = curData
                    }
                }
            
                //var newDayArr: [Int] = []
                for (keyDay, _) in data {
                    let newDayArr:[Int] = data[keyDay] ?? []
                    
                    if newDayArr.count > 0 {
                        let dayStart = newDayArr[0]
                        let dayRange = (newDayArr[(newDayArr.count) - 1] ) - (newDayArr[0]) + 1
                        
                        let planBtnView = UIButton()
                        planBtnView.backgroundColor = UIColor.hex(hex: 0xBCC6E1)
                        planBtnView.setBackgroundImage(UIImage.init(color: UIColor.hex(hex: 0xBCC6E1)), for: .normal)
                        planBtnView.setBackgroundImage(UIImage.init(color: UIColor.hex(hex: 0x8CA7EE)), for: .highlighted)
                        planBtnView.tag = (key ?? 1024) * 1000
                        planBtnView.isEnabled = self.canEdit
                        planBtnView.addTarget(self, action: #selector(onSleepPlanBtn), for: .touchUpInside)
                        self.addSubview(planBtnView)
                        
                        let planFrameY0 = self.timeLine(startTimeStr: columnTitleArr[0], endTimeStr: columnTitleArr[columns - 1], curTimerStr: "\(value[0].startHour ?? 0):\(value[0].startMinute ?? 0)") ?? 0.0
                        let planFrameY1 = self.timeLine(startTimeStr: columnTitleArr[0], endTimeStr: columnTitleArr[columns - 1], curTimerStr: "\(value[0].endHour ?? 0):\(value[0].endMinute ?? 0)") ?? 0.0
                        planBtnView.snp.makeConstraints({ (make) in
                            make.top.equalTo(centerY0 + planFrameY0 + 0.25)
                            make.height.equalTo(planFrameY1 - planFrameY0 - 0.5)
                            make.leading.equalTo(centerX0 + CGFloat(dayStart) * (cellWidth + middleSpace) + 0.25)
                            make.width.equalTo((cellWidth + middleSpace) * CGFloat(dayRange) - 0.5)
                        })
                        
                        planBtnView.layoutIfNeeded()
                        planBtnView.clipsToBounds = true
                        planBtnView.filletedCorner(CGSize(width: 5.5.auto(), height: 5.5.auto()),UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue | UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
                    }
                }
            }
        }
    }
    
    
    public func timeLine(startTimeStr: String?, endTimeStr: String?, curTimerStr: String?) -> CGFloat? {
        let timeArr = startTimeStr?.split(separator: ":")
        let timeNextArr = endTimeStr?.split(separator: ":")
        let curTimerArr = curTimerStr?.split(separator: ":")
        
        if timeArr?.count == 2 && timeNextArr?.count == 2 && curTimerArr?.count == 2 {
            let y0 = centerY0
            let y1 = centerY0 + CGFloat(columns - 1) * (cellHeight + middleSpace)
            let timeCurLag = Float((curTimerArr?[0])!)! - Float(timeArr![0])! + (Float((curTimerArr?[1])!)! - Float(timeArr![1])!) / 60
            let timeLag = Int(timeNextArr![0])! - Int(timeArr![0])!
            let frameY = CGFloat((y1 - y0)) * CGFloat(timeCurLag) / CGFloat(timeLag)
            return frameY
        }
        
        return 0.0
    }
}

class SelView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func draw(_ rect: CGRect) {
        let pathRect = self.bounds.insetBy(dx: 1, dy: 1)
        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: 5.5)
        path.lineWidth = 1
        UIColor.hex(hex: 0x8CA7EE).setFill()
        UIColor.hex(hex: 0x466CD1).setStroke()
        path.fill()
        path.stroke()
        
        //要绘制的文字
        let str = A4xBaseManager.shared.getLocalString(key: "add_sleep")
        //文字样式属性
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attributes = [NSAttributedString.Key.font: ADTheme.B2,
                          NSAttributedString.Key.foregroundColor: UIColor.hex(hex: 0x2B3246),
                           NSAttributedString.Key.paragraphStyle: style]
        //绘制在指定区域
        //(str as NSString ).draw(in: self.bounds, withAttributes: attributes)
        //从指定点开始绘制
        (str as NSString).draw(at: CGPoint(x: self.bounds.midX - str.width() / 2, y: self.bounds.midY - str.height(maxWidth: 26.auto()) / 2), withAttributes: attributes)
    }
}

