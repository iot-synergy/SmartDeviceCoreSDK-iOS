//


//


//

import UIKit

import SmartDeviceCoreSDK
import BaseUI

class A4xDevicesSleepPlanSetViewController: A4xBaseViewController {
    //var deviceId: String
    private var controlModel: A4xDeviceControlViewModel?
   
    var deviceModel: DeviceBean?
    
    private var cellInfos: [[A4xDevicesSetSleepPlanModel]]?
    private var editCells: [A4xDevicesSetSleepPlanEnum] = [] {
        didSet {
             self.reloadData()
        }
    }
    
    private var deviceSetup: Bool = false
    
    var weekName = [A4xBaseManager.shared.getLocalString(key: "sunday"),A4xBaseManager.shared.getLocalString(key: "monday"),A4xBaseManager.shared.getLocalString(key: "tuesday"),A4xBaseManager.shared.getLocalString(key: "wednesday"),A4xBaseManager.shared.getLocalString(key: "thursday"),A4xBaseManager.shared.getLocalString(key: "friday"),A4xBaseManager.shared.getLocalString(key: "saturday")]
    var timeName = ["00:00","04:00","08:00","12:00","16:00","20:00","24:00"]
    

    var sleepPlanModels: [A4xDeviceSleepPlanBean]? = []
    var setSleepPlanNew: Bool? = true
    var period : Int?
    
    var planStartDay: [Int]? = [1,2,3,4,5]
    var startHour: Int? = 9
    var startMinute: Int? = 0
    var endHour: Int? = 18
    var endMinute: Int? = 0
    
    init(deviceModel: DeviceBean, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.deviceModel = deviceModel
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadNavtion()
        
        self.currentView.isHidden = false
        self.sleepTimeLbl.isHidden = false
        
        self.fromView.isHidden = false
        self.fromLbl.isHidden = false
        self.fromTimeLbl.isHidden = false
        
        self.toView.isHidden = false
        self.toLbl.isHidden = false
        self.toTimeLbl.isHidden = false
        self.nextDayLbl.isHidden = true
        
        self.startWeekLbl.isHidden = false
        self.startWeekView.isHidden = false
        
        self.sleepPlanGridView.isHidden = false
        self.workTimeView.isHidden = false
        self.workTimeLbl.isHidden = false
        self.sleepTimeView.isHidden = false
        self.sleepTimeLbl.isHidden = false
        self.lineView.isHidden = false
        self.weekGridView.isHidden = false
        
        //self.weekGridView.isHidden = false
        






        
        self.delPlanBtn.isHidden = true
        
        
        
        //self.tableView.isHidden = false
        //
        self.deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: self.deviceModel?.serialNumber ?? "", modeType: self.deviceModel?.apModeType ?? .WiFi)
        
        
        controlModel = A4xDeviceControlViewModel.loadLocalData(deviceModel: self.deviceModel ?? DeviceBean(serialNumber: self.deviceModel?.serialNumber ?? ""), comple: { [weak self] (error) in
            self?.view.makeToast(error)
            self?.reloadData()
        })
        
        
        //controlModel?.resolution = self.deviceModel?.resolution
        //self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        
        
        //controlModel?.loadNetData(comple: { [weak self] (error) in
            //self?.view.hideToastActivity()
            //self?.view.makeToast(error)
            //self?.reloadData()
        //})
        
        loadData()
    }
    
    private func loadData() {
        if setSleepPlanNew ?? true {
            
            planStartDay?.forEach({ (planDay) in
                var sleepModel = A4xDeviceSleepPlanBean()
                sleepModel.period = 1024
                sleepModel.startHour = startHour
                sleepModel.startMinute = startMinute
                sleepModel.endHour = endHour
                sleepModel.endMinute = endMinute
                sleepModel.planDay = planDay
                sleepPlanModels?.append(sleepModel)
            })
            
            self.fromTimeLbl.text = "\(String(format: "%02d", self.startHour ?? 9)):\(String(format: "%02d", self.startMinute ?? 0))"
            self.toTimeLbl.text = "\(String(format: "%02d", self.endHour ?? 18)):\(String(format: "%02d", self.endMinute ?? 0))"
            
        } else {
            self.delPlanBtn.isHidden = false
            let model = sleepPlanModels?[0]
            self.startHour = model?.startHour
            self.startMinute = model?.startMinute
            self.endHour = model?.endHour
            self.endMinute = model?.endMinute
            //self.period = model?.period
            
            self.fromTimeLbl.text = "\(String(format: "%02d", self.startHour ?? 9)):\(String(format: "%02d", self.startMinute ?? 0))"
            self.toTimeLbl.text = "\(String(format: "%02d", self.endHour ?? 18)):\(String(format: "%02d", self.endMinute ?? 0))"
            
        }
        
        self.weekGridView.rowTitleArr = self.weekName
        //self.weekGridView.curRowTitleStr = self.weekName[Date().getTimes()[1].intValue()]
        self.weekGridView.curRowTitleIndex = Date().getTimes()[1].intValue()
        self.weekGridView.curColTitleStr = Date().getTimes()[0]
        self.weekGridView.columnTitleArr = self.timeName
        self.weekGridView.boxNum = 42
        self.weekGridView.canEdit = !(setSleepPlanNew ?? true)
        self.weekGridView.sleepPlanModelArr = sleepPlanModels
        self.weekGridView.showCurrenTime = false
        self.weekGridView.gridWidth = (self.sleepPlanGridView.width) - 51.5.auto()
        
    }
    
    private func reloadData() {
        sleepPlanModels?.removeAll()
        
        var period = 1024, range = 1
        planStartDay = planStartDay?.sorted()
        
        
        if (self.endHour ?? 18) < (self.startHour ?? 9) {
            
            for index in 0..<(planStartDay?.count ?? 0) {
                var sleepModel = A4xDeviceSleepPlanBean()
                if index + 1 < (planStartDay?.count ?? 0) {
                    if range != (planStartDay?[index + 1] ?? 0) - (planStartDay?[index] ?? 0) {
                        
                        sleepModel.period = period
                        sleepModel.startHour = startHour
                        sleepModel.startMinute = startMinute
                        sleepModel.endHour = 23
                        sleepModel.endMinute = 30
                        sleepModel.planDay = planStartDay?[index] ?? 0
                        sleepPlanModels?.append(sleepModel)
                        period += 1
                    } else {
                        sleepModel.period = period
                        sleepModel.startHour = startHour
                        sleepModel.startMinute = startMinute
                        sleepModel.endHour = 23
                        sleepModel.endMinute = 30
                        sleepModel.planDay = planStartDay?[index] ?? 0
                        sleepPlanModels?.append(sleepModel)
                    }
                } else {
                    var sleepModel = A4xDeviceSleepPlanBean()
                    sleepModel.period = period
                    //sleepModel.planStartDay = planStartDay?.sorted()
                    sleepModel.startHour = startHour
                    sleepModel.startMinute = startMinute
                    sleepModel.endHour = 23
                    sleepModel.endMinute = 30
                    sleepModel.planDay = planStartDay?[index] ?? 0
                    sleepPlanModels?.append(sleepModel)
                }
            }
            
            var key: Int = 0
            var curData: [Int] = []
            var data: [Int : [Int]] = [:]
            for i in 0..<(planStartDay?.count ?? 0) {
                if i + 1 < (planStartDay?.count ?? 0 ) {
                    if range != (planStartDay?[i + 1] ?? 0) - (planStartDay?[i] ?? 0) {
                        curData.append(planStartDay?[i] ?? 0)
                        data[key] = curData
                        key += 1
                        curData.removeAll()
                    } else {
                        curData.append(planStartDay?[i] ?? 0)
                        data[key] = curData
                    }
                } else {
                    curData.append(planStartDay?[i] ?? 0)
                    data[key] = curData
                }
            }
        
            var nextPlanStartDay: [Int] = []
            for (key, _) in data {
                let arr:[Int] = data[key] ?? []
                let arr2 = arr.map { $0 + 1 }
                nextPlanStartDay.append(contentsOf: arr2)
                nextPlanStartDay.sort()
                if nextPlanStartDay[nextPlanStartDay.count - 1] == 7 {
                    nextPlanStartDay.remove(at: nextPlanStartDay.count - 1)
                    nextPlanStartDay.append(0)
                }
            }
//
            nextPlanStartDay.sort()
            
            var nextPeriod = 2024
            
            for index in 0..<nextPlanStartDay.count {
                var sleepModel = A4xDeviceSleepPlanBean()
                if index + 1 < nextPlanStartDay.count {
                    if range != (nextPlanStartDay[index + 1] - nextPlanStartDay[index]) {
                        
                        sleepModel.period = nextPeriod
                        sleepModel.startHour = 0
                        sleepModel.startMinute = 0
                        sleepModel.endHour = endHour
                        sleepModel.endMinute = endMinute
                        sleepModel.planDay = nextPlanStartDay[index]
                        sleepPlanModels?.append(sleepModel)
                        nextPeriod += 1
                    } else {
                        sleepModel.period = nextPeriod
                        sleepModel.startHour = 0
                        sleepModel.startMinute = 0
                        sleepModel.endHour = endHour
                        sleepModel.endMinute = endMinute
                        sleepModel.planDay = nextPlanStartDay[index]
                        sleepPlanModels?.append(sleepModel)
                    }
                } else {
                    var sleepModel = A4xDeviceSleepPlanBean()
                    sleepModel.period = nextPeriod
                    sleepModel.startHour = 0
                    sleepModel.startMinute = 0
                    sleepModel.endHour = endHour
                    sleepModel.endMinute = endMinute
                    sleepModel.planDay = nextPlanStartDay[index]
                    sleepPlanModels?.append(sleepModel)
                }
            }
        } else {
            for index in 0..<(planStartDay?.count ?? 0) {
                var sleepModel = A4xDeviceSleepPlanBean()
                if index + 1 < (planStartDay?.count ?? 0) {
                    if range != (planStartDay?[index + 1] ?? 0) - (planStartDay?[index] ?? 0) {
                        
                        sleepModel.period = period
                        sleepModel.startHour = startHour
                        sleepModel.startMinute = startMinute
                        sleepModel.endHour = endHour
                        sleepModel.endMinute = endMinute
                        sleepModel.planDay = planStartDay?[index] ?? 0
                        sleepPlanModels?.append(sleepModel)
                        period += 1
                    } else {
                        sleepModel.period = period
                        sleepModel.startHour = startHour
                        sleepModel.startMinute = startMinute
                        sleepModel.endHour = endHour
                        sleepModel.endMinute = endMinute
                        sleepModel.planDay = planStartDay?[index] ?? 0
                        sleepPlanModels?.append(sleepModel)
                    }
                } else {
                    var sleepModel = A4xDeviceSleepPlanBean()
                    sleepModel.period = period
                    //sleepModel.planStartDay = planStartDay?.sorted()
                    sleepModel.startHour = startHour
                    sleepModel.startMinute = startMinute
                    sleepModel.endHour = endHour
                    sleepModel.endMinute = endMinute
                    sleepModel.planDay = planStartDay?[index] ?? 0
                    sleepPlanModels?.append(sleepModel)
                }
            }
        }
        self.weekGridView.removeOldUI = true
        self.weekGridView.sleepPlanModelArr = sleepPlanModels
        self.weekGridView.reLoadData = true
    }
    
    //private func reloadData() {
        //self.cellInfos = A4xDevicesSetSleepPlanEnum.cases(showPlan: true, deviceModle: self.deviceModel)
        //self.tableView.reloadData()
    //}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //A4xUserDataHandle.Handle?.videoHelper.stopAlive(deviceId: self.deviceId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //A4xUserDataHandle.Handle?.videoHelper.keepAlive(deviceId: self.deviceId, isHeartbeat: true, comple: { [weak self] (state, flag) in
            //self?.deviceSetup = flag
        //})
    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "schedule_time").capitalized
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
        
        var rightItem = A4xBaseNavItem()
        rightItem.title = A4xBaseManager.shared.getLocalString(key: "save")
        rightItem.titleColor = ADTheme.Theme
        rightItem.disableColor = ADTheme.Theme.withAlphaComponent(0.3)
        self.navView?.rightItem = rightItem
        self.navView?.rightClickBlock = { [weak self] in
            if self?.setSleepPlanNew ?? true {
                
                self?.createSleepPlan()
            } else {
                self?.editSleepPlan()
            }
        }
    }
    
    private lazy var currentView: UIScrollView = {
        var sv: UIScrollView = UIScrollView()
        sv.contentSize = CGSize(width: self.view.width, height: UIScreen.height)
        let y: CGFloat = sv.bounds.height
        //sv.frame = CGRect(x: 0, y: y, width: self.view.width, height: sv.bounds.height)
        sv.bounces = true
        sv.isScrollEnabled = true
        sv.alwaysBounceVertical = true
        sv.scrollsToTop = true
        sv.backgroundColor = .clear //.hex( 0x000000, alpha: 0.5)
        
        self.view.addSubview(sv)
        sv.snp.makeConstraints { (make) in
            make.leading.equalTo(0)
            make.top.equalTo(UIScreen.navBarHeight)
            make.height.equalTo(UIScreen.height - UIScreen.navBarHeight)
            make.width.equalToSuperview()
        }
        return sv
    }()
    
    
    private lazy var sleepTimeTitleLbl: UILabel = {
        let lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "sleep_period")
        lbl.textColor = ADTheme.C3
        lbl.font = UIFont.regular(14)
        lbl.textAlignment = .left
        self.currentView.addSubview(lbl)
        lbl.snp.makeConstraints { (make) in
            make.leading.equalTo(16.auto())
            make.top.equalTo(10.auto())
        }
        return lbl
    }()
    
    
    private lazy var fromView: UIView = {
        let v: UIView = UIView()
        v.backgroundColor = .white
        self.currentView.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.top.equalTo(sleepTimeTitleLbl.snp.bottom).offset(10.auto())
            make.leading.equalTo(16.auto())
            make.height.equalTo(80.auto())
            make.width.equalTo((UIScreen.width - 32.auto() - 10.auto()) / 2)
        }
        v.layoutIfNeeded()
        v.clipsToBounds = true
        v.filletedCorner(CGSize(width: 11.auto(), height: 11.auto()),UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue | UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
        return v
    }()
    
    private lazy var fromLbl: UILabel = {
        let lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "from_time")
        lbl.textColor = ADTheme.C3
        lbl.font = UIFont.regular(14)
        lbl.textAlignment = .left
        self.fromView.addSubview(lbl)
        lbl.snp.makeConstraints { (make) in
            make.leading.equalTo(8.auto())
            make.top.equalTo(fromView.snp.top).offset(8.auto())
        }
        return lbl
    }()
    
    private lazy var fromTimeLbl: UILabel = {
        let lbl: UILabel = UILabel()
        lbl.text = "09:00"
        lbl.textColor = ADTheme.C1
        lbl.font = A4xBaseResource.UIFont(name: "BebasNeue", ofType: "otf", size: 30.auto()) ?? ADTheme.H0
        lbl.textAlignment = .left
        lbl.tag = 1
        lbl.isUserInteractionEnabled = true
        self.fromView.addSubview(lbl)
        let oneTap = UITapGestureRecognizer(target: self, action:#selector(selectTime(tap:)))
        oneTap.numberOfTapsRequired = 1
        oneTap.delegate = self
        lbl.addGestureRecognizer(oneTap)
        lbl.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return lbl
    }()
    
    
    private lazy var toView: UIView = {
        let v: UIView = UIView()
        v.backgroundColor = .white
        self.currentView.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.top.equalTo(fromView.snp.top)
            make.leading.equalTo(fromView.snp.trailing).offset(10.auto())
            make.height.equalTo(80.auto())
            make.width.equalTo((UIScreen.width - 32.auto() - 10.auto()) / 2)
        }
        v.layoutIfNeeded()
        v.clipsToBounds = true
        v.filletedCorner(CGSize(width: 11.auto(), height: 11.auto()),UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue | UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
        return v
    }()
    
    private lazy var toLbl: UILabel = {
        let lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "to_time")
        lbl.textColor = ADTheme.C3
        lbl.font = UIFont.regular(14)
        lbl.textAlignment = .left
        self.toView.addSubview(lbl)
        lbl.snp.makeConstraints { (make) in
            make.leading.equalTo(8.auto())
            make.top.equalTo(toView.snp.top).offset(8.auto())
        }
        return lbl
    }()
    
    private lazy var nextDayLbl: UILabel = {
        let lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "nest_day")
        lbl.textColor = ADTheme.C3
        lbl.font = UIFont.regular(14)
        lbl.textAlignment = .left
        //lbl.tag = 2
        //lbl.adjustsFontSizeToFitWidth = true
        //lbl.isUserInteractionEnabled = true
        self.toView.addSubview(lbl)
        //let oneTap = UITapGestureRecognizer(target: self, action:#selector(selectTime(tap:)))
        //oneTap.numberOfTapsRequired = 1
        //oneTap.delegate = self
        //lbl.addGestureRecognizer(oneTap)
        lbl.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.toLbl.snp.centerY)
            make.leading.equalTo(self.toLbl.snp.trailing).offset(6)
            make.width.lessThanOrEqualTo(140.auto())
        }
        return lbl
    }()
    
    private lazy var toTimeLbl: UILabel = {
        let lbl: UILabel = UILabel()
        lbl.text = "18:00"
        lbl.textColor = ADTheme.C1
        lbl.font = A4xBaseResource.UIFont(name: "BebasNeue", ofType: "otf", size: 30.auto()) ?? ADTheme.H0
        lbl.textAlignment = .left
        lbl.tag = 2
        lbl.isUserInteractionEnabled = true
        self.toView.addSubview(lbl)
        let oneTap = UITapGestureRecognizer(target: self, action:#selector(selectTime(tap:)))
        oneTap.numberOfTapsRequired = 1
        oneTap.delegate = self
        lbl.addGestureRecognizer(oneTap)
        lbl.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return lbl
    }()
    
    
    private lazy var startWeekLbl: UILabel = {
        let lbl: UILabel = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "sleep_start")
        lbl.textColor = ADTheme.C3
        lbl.font = UIFont.regular(14)
        lbl.textAlignment = .left
        self.currentView.addSubview(lbl)
        lbl.snp.makeConstraints { (make) in
            make.leading.equalTo(16.auto())
            make.top.equalTo(fromView.snp.bottom).offset(15.auto())
        }
        return lbl
    }()
    
    
    private lazy var startWeekView: UIView = {
        let v: UIView = UIView()
        v.backgroundColor = .white
        self.currentView.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.top.equalTo(startWeekLbl.snp.bottom).offset(10.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(self.view.snp.width).offset(-32.auto())
            make.height.equalTo(80.auto())
        }
        v.layoutIfNeeded()
        v.clipsToBounds = true
        v.filletedCorner(CGSize(width: 11.auto(), height: 11.auto()),UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue | UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
        
        let btnPading: CGFloat = (v.width - 32.auto() - 35.auto() * 7) / 6
        for i in 0..<7 {
            let btn = UIButton()
            btn.setTitle(weekName[i], for: .normal)
            btn.setTitleColor(ADTheme.C3, for: .normal)
            btn.setTitleColor(UIColor.colorFromHex("#FFFFFF"), for: .selected)
            btn.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#F6F7F9")), for: .normal)
            btn.setBackgroundImage(UIImage.init(color: ADTheme.Theme), for: .selected)
            btn.layer.cornerRadius = 17.5.auto()
            self.planStartDay?.forEach({ (item) in
                if item == i {
                    btn.isSelected = true
                }
            })
            btn.clipsToBounds = true
            btn.tag = i
            btn.addTarget(self, action: #selector(weekClickAction(sender:)), for: .touchUpInside)
            v.addSubview(btn)
            let leftPading: CGFloat = CGFloat(i) * (35.auto() + btnPading)
            btn.snp.makeConstraints { (make) in
                make.width.height.equalTo(35.auto())
                make.leading.equalTo(16.auto() + leftPading)
                make.centerY.equalToSuperview()
            }
        }
        
        return v
    }()
    
    
    private lazy var sleepPlanGridView: UIView = {
        let v: UIView = UIView()
        v.backgroundColor = .white
        self.currentView.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.top.equalTo(startWeekView.snp.bottom).offset(10.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(self.view.snp.width).offset(-32.auto())
            make.height.equalTo(331.5.auto())
        }
        v.layoutIfNeeded()
        v.clipsToBounds = true
        v.filletedCorner(CGSize(width: 11.auto(), height: 11.auto()),UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue | UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
        return v
    }()
    
    
    lazy var workTimeView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        self.sleepPlanGridView.addSubview(v)
        v.snp.makeConstraints({ (make) in
            make.top.equalTo(self.sleepPlanGridView.snp.top).offset(24.auto())
            make.leading.equalTo(self.sleepPlanGridView.snp.leading).offset(16.5.auto())
            make.height.equalTo(6.auto())
            make.width.equalTo(24.auto())
        })
        v.layoutIfNeeded()
        v.clipsToBounds = true
        v.filletedCorner(CGSize(width: 1.5, height: 1.5),UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue | UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.colorFromHex("#E8E8E8").cgColor
        return v
    }()
     
    
    lazy var workTimeLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "sleep_work_time")
        lbl.font = ADTheme.B2
        lbl.textAlignment = .left
        lbl.textColor = ADTheme.C1
        lbl.lineBreakMode = .byTruncatingTail
        self.sleepPlanGridView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.workTimeView.snp.centerY)
            make.leading.equalTo(self.workTimeView.snp.trailing).offset(8.auto())
            make.width.lessThanOrEqualTo(self.sleepPlanGridView.width / 2 - 24.auto())
        })
        return lbl
    }()
    
    
    lazy var sleepTimeView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.colorFromHex("#BCC6E1")
        self.sleepPlanGridView.addSubview(v)
        v.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.workTimeView.snp.centerY)
            make.leading.equalTo(self.workTimeLbl.snp.trailing).offset(32.auto())
            make.height.equalTo(6.auto())
            make.width.equalTo(24.auto())
        })
        v.layoutIfNeeded()
        v.clipsToBounds = true
        v.filletedCorner(CGSize(width: 1.5, height: 1.5),UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue | UIRectCorner.bottomLeft.rawValue) | (UIRectCorner.bottomRight.rawValue)))
        return v
    }()
    
    
    lazy var sleepTimeLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = A4xBaseManager.shared.getLocalString(key: "sleep_period")
        lbl.font = ADTheme.B2
        lbl.textAlignment = .left
        lbl.textColor = ADTheme.C1
        lbl.lineBreakMode = .byTruncatingTail
        self.sleepPlanGridView.addSubview(lbl)
        lbl.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.sleepTimeView.snp.centerY)
            make.leading.equalTo(self.sleepTimeView.snp.trailing).offset(8.auto())
            make.width.lessThanOrEqualTo(self.sleepPlanGridView.width / 2 - 24.auto() - 16.auto())
        })
        return lbl
    }()
    
    
    private lazy var lineView : UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.colorFromHex("#F0F0F0")//UIColor.black.withAlphaComponent(0.4)
        self.sleepPlanGridView.addSubview(v)
        v.snp.makeConstraints({ (make) in
            make.top.equalTo(self.workTimeView.snp.bottom).offset(21.5.auto())
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
            make.width.equalToSuperview()
        })
        return v
    }()
    
    
    private lazy var weekGridView: A4xBaseGridView = {
        let gv = A4xBaseGridView()
        self.sleepPlanGridView.addSubview(gv)
        gv.snp.makeConstraints { (make) in
            make.top.equalTo(self.sleepPlanGridView.snp.top).offset(46.auto())
            make.leading.equalTo(self.sleepPlanGridView.snp.leading).offset(0)
            make.width.equalTo(self.sleepPlanGridView.snp.width)
            make.bottom.equalTo(self.sleepPlanGridView.snp.bottom).offset(-23.auto())
        }
        gv.layoutIfNeeded()
        return gv
    }()
    
    
    private lazy var delPlanBtn: UIButton = {
        let btn  = UIButton()
        btn.setTitle(A4xBaseManager.shared.getLocalString(key: "delete"), for: .normal)
        btn.setTitleColor(UIColor.colorFromHex("#E04F33"), for: .normal)
        btn.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#FFFFFF")), for: .normal)
        //btn.setBackgroundImage(UIImage.init(color: ADTheme.Theme), for: .selected)
        btn.layer.cornerRadius = 11.auto()
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(delPlanClickAction(sender:)), for: .touchUpInside)
        self.currentView.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(sleepPlanGridView.snp.bottom).offset(9.5.auto())
            make.leading.equalTo(16.auto())
            make.height.equalTo(56.auto())
            make.width.equalTo(self.view.snp.width).offset(-32.auto())
        }
        return btn
    }()
    
    private func keepDeviceAlive(comple: @escaping (_ isScuess: Bool)->Void) {
        if self.deviceSetup {
            comple(true)
        } else {
            A4xUserDataHandle.Handle?.videoHelper.keepAlive(deviceId: self.deviceModel?.serialNumber ?? "", isHeartbeat: false, comple: { [weak self] (state, flag) in
                self?.deviceSetup = flag
                comple(flag)
            })
        }
    }
}

extension A4xDevicesSleepPlanSetViewController {
    
    
    @objc private func selectTime(tap: Any) {
        let sender = tap as! UITapGestureRecognizer
        let tag = sender.view?.tag
        
        let pickerHourData: [String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"] //第一级数据
        let pickerMinuteData: [String] = ["00","30"] //第二级数据
        
        var selectIndex = (1,1)
        if tag == 1 {
            var index0 = 0, index1 = 0
            for i in 0..<pickerHourData.count {
                if pickerHourData[i].intValue() == self.startHour {
                    index0 = i
                }
            }
            
            if pickerMinuteData[0].intValue() == startMinute {
                index1 = 0
            } else {
                index1 = 1
            }
            
            //self?.fromTimeLbl.text = "\(pickerHourData[index.0] ):\(pickerMinuteData[index.1])"
            selectIndex = (index0,index1)
        } else {
            var index0 = 0, index1 = 0
            for i in 0..<pickerHourData.count {
                if pickerHourData[i].intValue() == self.endHour {
                    index0 = i
                }
            }
            
            if pickerMinuteData[0].intValue() == endMinute {
                index1 = 0
            } else {
                index1 = 1
            }
            
            //self?.toTimeLbl.text = "\(pickerHourData[index.0] ):\(pickerMinuteData[index.1])"
            selectIndex = (index0,index1)
        }
       
        let compleBlock: (((Int, Int)) -> Void) = { [weak self] index in
            if tag == 1 {
                self?.fromTimeLbl.text = "\(pickerHourData[index.0] ):\(pickerMinuteData[index.1])"
                self?.startHour = Int(pickerHourData[index.0])
                self?.startMinute = Int(pickerMinuteData[index.1])
                self?.dataCheck()
            } else {
                self?.toTimeLbl.text = "\(pickerHourData[index.0] ):\(pickerMinuteData[index.1])"
                self?.endHour = Int(pickerHourData[index.0])
                self?.endMinute = Int(pickerMinuteData[index.1])
                self?.dataCheck()
            }
            self?.reloadData()
        }

        let closeBlock:() -> Void = {}
        let cancleBlock:() -> Void = {}
        
        //self.changeStatusLed(selectIndex: &selectIndex, resultBlock: &compleBlock)

        var config = A4xBaseActionsheetConfig()
        config.sheetHeight = 304.auto() + UIScreen.safeAreaHeight
      
        let sheet = A4xBaseDatePickerView(config: config,
                                     titleItem: tag == 1 ? A4xBaseActionSheetType.title(A4xBaseManager.shared.getLocalString(key: "sleep_start_time")) : A4xBaseActionSheetType.title( A4xBaseManager.shared.getLocalString(key: "sleep_end_time")),
                                     cancleItem: A4xBaseActionSheetType.cancle(A4xBaseManager.shared.getLocalString(key: "cancel"), cancleBlock),
                                     okItem: A4xBaseActionSheetType.ok(A4xBaseManager.shared.getLocalString(key: "done"), compleBlock),
                                     outHidden: A4xBaseActionSheetType.close(closeBlock),
                                     select: A4xBaseActionSheetType.dataTimeSource((pickerHourData, pickerMinuteData), selectIndex))
        
        sheet.show()
    }
    
    private func dataCheck() {
        if (self.endHour ?? 18) < (self.startHour ?? 9) {
            self.nextDayLbl.isHidden = false
            self.fromTimeLbl.textColor = ADTheme.C1
            self.toTimeLbl.textColor = ADTheme.C1
            self.navView?.rightBtn?.isEnabled = true
        } else if (self.endHour ?? 18) == (self.startHour ?? 9) && (self.endMinute ?? 18) == (self.startMinute ?? 9) {
            self.fromTimeLbl.textColor = .red
            self.toTimeLbl.textColor = .red
            self.nextDayLbl.isHidden = true
            self.navView?.rightBtn?.isEnabled = false
        } else {
            self.nextDayLbl.isHidden = true
            self.fromTimeLbl.textColor = ADTheme.C1
            self.toTimeLbl.textColor = ADTheme.C1
            self.navView?.rightBtn?.isEnabled = true
        }
    }
    
    
    @objc private func weekClickAction(sender: UIButton) {
        if sender.isSelected && (planStartDay?.count ?? 0) > 1 {
            sender.isSelected = !sender.isSelected
            planStartDay?.removeAll { $0 == sender.tag }
        } else if !sender.isSelected {
            sender.isSelected = !sender.isSelected
            planStartDay?.append(sender.tag)
        }
        self.reloadData()
    }
    
    
    private func createSleepPlan() {
        weak var weakSelf = self
        
        if (self.endHour ?? 18) < (self.startHour ?? 9) {
            self.endHour! += 24
        }
        
        self.controlModel?.createSleepPlan(planStartDay: self.planStartDay ?? [], startHour: startHour ?? 8, startMinute: startMinute ?? 0, endHour: endHour ?? 20, endMinute: endMinute ?? 0, comple: { (res) in
            
            if res != nil {
                weakSelf?.view.makeToast(res)
            } else {
                weakSelf?.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    
    @objc private func delPlanClickAction(sender: UIButton) {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = UIColor.white //ADTheme.C5
        config.leftTitleColor = UIColor.colorFromHex("#2F3742") //ADTheme.C1
        
        config.rightbtnBgColor = UIColor.white
        config.rightTextColor = ADTheme.E1
        config.messageColor = UIColor.colorFromHex("#2F3742")
        weak var weakSelf = self
        
        let alert = A4xBaseAlertView(param: config, identifier: "delete device")
        //alert.title = A4xBaseManager.shared.getLocalString(key: "remove_device_title")
        alert.message  = A4xBaseManager.shared.getLocalString(key: "delete_sleep_time")
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "delete")
        alert.rightButtonBlock = {
            weakSelf?.deleteSleepPlan()
        }
        alert.show()
    }
    
    private func deleteSleepPlan() {
        weak var weakSelf = self
        self.controlModel?.deleteSleepPlan(period: self.period ?? 1024, comple: { (res) in
            
            if res != nil {
                weakSelf?.view.makeToast(res)
            } else {
                weakSelf?.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    private func editSleepPlan() {
        weak var weakSelf = self
        
        if (self.endHour ?? 18) < (self.startHour ?? 9) {
            self.endHour! += 24
        }
        self.controlModel?.editSleepPlan(period: self.period ?? 0, planStartDay: self.planStartDay ?? [], startHour: startHour ?? 8, startMinute: startMinute ?? 0, endHour: endHour ?? 20, endMinute: endMinute ?? 0, comple: { (res) in
            
            if res != nil {
                weakSelf?.view.makeToast(res)
            } else {
                weakSelf?.navigationController?.popViewController(animated: true)
            }
        })
    }
}

extension A4xDevicesSleepPlanSetViewController: A4xDevicesSetSleepPlanCellProtocol {
    func devicesBtnClick(sender: UIButton, status: String, type: A4xDevicesSetSleepPlanEnum?) {
        
    }

    func devicesCellClick(sender: UIButton, type: A4xDevicesSetSleepPlanEnum?) {
        
    }
    
    func devicesCellSwicth(flag: Bool, type: A4xDevicesSetSleepPlanEnum?) {
        guard let switchType: A4xDevicesSetSleepPlanEnum = type else {
            return
        }
        
        let resultBlock: (String?) -> Void = { [weak self] (error) in
            self?.view.makeToast(error)
            if let index = self?.editCells.firstIndex(of: switchType) {
                self?.editCells.remove(at: index)
            }
        }
        
        let compleBlock:() -> Void = { [weak self] in
            self?.keepDeviceAlive(comple: { (isSuccess) in
                if isSuccess {
                    switch switchType {
                    case .showPlan:
                        self?.controlModel?.sleepToWakeUP(enable: flag, comple: resultBlock)
                        break
                    //case .editPlan:
                        //self?.controlModel?.setSleepPlanStatus(enable: flag, comple: resultBlock)
                    default:
                        return
                    }
                } else {
                    resultBlock(A4xBaseManager.shared.getLocalString(key: "request_error"))
                }
            })
        }
        
        if type == .showPlan && !flag {
            self.editCells.append(switchType)
            compleBlock()
        } else if type == .editPlan && !flag {
            self.editCells.append(switchType)
            compleBlock()
        }
    }
    
    func devicesCellSelect(type: A4xDevicesSetSleepPlanEnum?) {
        guard type != nil else {
            return
        }
        
        switch type {
        case .editPlan:
            //let vc = A4xDevicesSleepPlanShowViewController()
            //self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            return
        }
    }
}

