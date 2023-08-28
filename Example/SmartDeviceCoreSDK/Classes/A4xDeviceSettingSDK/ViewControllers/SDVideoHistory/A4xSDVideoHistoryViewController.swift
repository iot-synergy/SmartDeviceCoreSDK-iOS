//
//  A4xSDVideoHistoryViewController.swift
//  AddxAi
//
//  Created by kzhi on 2020/1/8.
//  Copyright © 2020 addx.ai. All rights reserved.
//

import UIKit
import FSCalendar
import SmartDeviceCoreSDK
import Resolver
import A4xLiveVideoUIInterface
import BaseUI

class A4xSDVideoHistoryViewController: A4xBaseViewController {
    
    var selectDate: Date? {
        didSet {
            
            let format = A4xBaseAppLanguageType.language() == .chinese ? "MM月dd日" : "MMM,dd"
            
            let title = (self.selectDate ?? Date()).string(formatStr: format)
            
            self.navView?.leftItem?.title = title
            self.headerView.title = title
        }
    }
    
    /// 是不是从SD卡全屏回来的,默认不是
    var isSDFullBack : Bool = false
    
    var hasDataDates: Set<String> = []
    
    var hasDataDatesStartTime: TimeInterval?
    
    var minDate: Date = Date()
    
    var deviceModel: DeviceBean?
    
    var videoRatio: CGFloat = 9.0 / 16.0
    
    var endPlayDate: TimeInterval = Date().timeIntervalSince1970
    
    var isQuite: Bool = false
    
    var earliestVideoSlice: A4xVideoTimeModel?
    
    var mLivePlayer: LivePlayer?
    
    var hasDaysBlock: ((_ isScuess: Bool, _ dateSource: [A4xVideoTimeModel]?) -> Void)?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(deviceModel: DeviceBean, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.deviceModel = deviceModel
        videoRatio = (self.deviceModel?.isFourByThree() ?? false) ? (3.0 / 4.0) : (9.0 / 16.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        
        self.videoView.isHidden = true
        self.timeControlView.isHidden = true
        self.calendar.isHidden = false
        self.calendarViewBg.isHidden = true
        self.loadNavtion()
        self.navView?.alpha = 0
        
        // 选择历史天数
        self.selectDate = Date.sdMaxSelect()
        
        // 赋值
        timeControlView.timerSelectDate = self.selectDate
        
        self.view.clipsToBounds = true
        guard let device = self.deviceModel else {
            return
        }
        
        self.loadData()
        
        mLivePlayer = LiveManagerInstance.getInstance().creatLivePlayer(serialNumber: device.serialNumber ?? "", customParam: ["isAPMode" : device.apModeType == .AP])
        mLivePlayer?.reCreateRenderView()
        
        // 注册进入后台
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // 注册进入前台
        NotificationCenter.default.addObserver(self, selector: #selector(enterActiveGround), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let device = self.deviceModel else {
            return
        }
        
        mLivePlayer?.setListener(liveStateListener: self)
        
        DispatchQueue.main.a4xAfter(0.1) {
            
            if let state = self.mLivePlayer?.state {
                if state == A4xPlayerStateType.playing.rawValue {
                    self.videoView.videoState = (state, device.serialNumber ?? "")
                    self.videoView.videoView = self.mLivePlayer?.playView
                }
            }
            
            self.videoView.audioEnable = self.mLivePlayer?.getAudioEnable() ?? false
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let contains: Bool = self.navigationController?.viewControllers.contains(self) ?? false
        if !contains {
            mLivePlayer?.stopSdcard()
            mLivePlayer?.removeRenderView()
        }
        self.videoView.videoView = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 进入到后台
    @objc func enterBackGround() {
        logDebug("-----------> \(type(of: self)) enterBackGround")
        sdVideoStop()
    }
    
    // 进入到前台
    @objc func enterActiveGround() {
        logDebug("-----------> \(type(of: self)) enterActiveGround")
    }
    
    private func updateDatas(hasLoadData: Bool, videoErrorString error: String?){
        let status: A4xDeviceSDState = deviceModel?.sdcardState() ?? .noCard
        if status != .normal {
            self.sdErrorcardState()
            return
        } else {
            
            var currentHasData: Bool = false
            
            let checkSliceEnable: Int64 = earliestVideoSlice?.start ?? 0
            
            if (checkSliceEnable > 1000 && checkSliceEnable < Int64(Date().timeIntervalSince1970)) || self.hasDataDates.count >  0 {
                currentHasData = true
            }
            
            if hasLoadData {
                if currentHasData {
                    self.view.hiddNoDataView()
                    showHasData()
                } else {
                    dataErrorState(errorStr: error)
                }
            } else if let error = error {
                UIApplication.shared.keyWindow?.hideToastActivity(block: {})
                if !currentHasData {
                    self.dataErrorState(errorStr: error)
                }
            }
        }
    }
    
    private func dataErrorState(errorStr: String? = A4xBaseManager.shared.getLocalString(key: "sdcard_has_no_video")) {
        self.videoView.isHidden = true
        self.timeControlView.isHidden = true
        self.calendar.isHidden = true
        self.calendarViewBg.isHidden = true
        self.headerView.isHidden = false
        self.headerView.infoView.isEnabled = false
        let repertTitle : String? = A4xBaseManager.shared.getLocalString(key: "reconnect")//retry()
        
        weak var weakSelf = self
        
        // 服务器超时
        var img = errorStr == A4xBaseManager.shared.getLocalString(key: "network_low") ? A4xDeviceSettingResource.UIImage(named: "sd_play_timeout")?.rtlImage() : A4xDeviceSettingResource.UIImage(named: "sd_list_error")?.rtlImage()
        var err = errorStr == A4xBaseManager.shared.getLocalString(key: "network_low") ? A4xBaseManager.shared.getLocalString(key: "videolist_timeout") : errorStr
        
        // 服务器异常 服务器繁忙/返回错误码
        img = errorStr == A4xBaseManager.shared.getLocalString(key: "sd_card_emtpy") ? A4xDeviceSettingResource.UIImage(named:"sd_list_error")?.rtlImage() : img
        err = errorStr == A4xBaseManager.shared.getLocalString(key: "sd_card_emtpy") ? A4xBaseManager.shared.getLocalString(key: "sd_card_emtpy") : err
        
        let errorValue = A4xBaseNoDataValueModel.noData(error: err, image: img, retry: true, retryTitle: repertTitle, noDataType: .retry, specialState: .sd) {
            UIApplication.shared.keyWindow?.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading"), completion: { (f) in})
            weakSelf?.timeControlView.reloadDate(comple: {
                UIApplication.shared.keyWindow?.hideToastActivity(block: {
                })
            })
        }
        
        let _ = self.view.showNoDataView(value: errorValue , isShareAdmin: deviceModel?.isAdmin() ?? true)
        
        self.view.bringSubviewToFront(self.headerView)
    }
    
    private func showHasData() {
        let status : A4xDeviceSDState = deviceModel?.sdcardState() ?? .noCard
        if status != .normal {
            return
        }
        self.videoView.isHidden = false
        self.timeControlView.isHidden = false
        self.calendar.isHidden = false
        self.calendarViewBg.isHidden = true
        self.headerView.isHidden = false
        self.headerView.infoView.isEnabled = true
    }
    
    private func sdErrorcardState() {
        let status : A4xDeviceSDState = deviceModel?.sdcardState() ?? .noCard
        if status == .normal {
            self.view.hiddNoDataView()
            return
        }
    }
    

    private var isFirstData: Bool = false
    
    // 加载列表信息: 先获取列表数据，再获取本年的日历数据
    func loadVideoData(from: TimeInterval, toDate: TimeInterval, comple: @escaping (_ isScuess: Bool, _ dateSourde: [A4xVideoTimeModel]?) -> Void) {
        
        hasDaysBlock = comple
        
        logDebug("-----------> SDVideoHistoryView loadVideoData fromDate: \(from)  fromDate(1970世界时间): \(Date.init(timeIntervalSince1970: from)) toDate: \(toDate) toDate(1970世界时间): \(Date.init(timeIntervalSince1970: toDate))")
        
        let resultBlock: (A4xVideoTimeModelResponse)->Void = { [weak self] model in
            UIApplication.shared.keyWindow?.hideToastActivity(block: {})

            var hasLoadData: Bool = false
            if let startTime = model.earliestVideoSlice?.start, startTime > 10 { //startTime > 100
                hasLoadData = true
                self?.minDate = Date(timeIntervalSince1970: TimeInterval(startTime)).videoMinData(of: 0)
                self?.timeControlView.minDate = Date(timeIntervalSince1970: TimeInterval(startTime)).videoMinData(of: 0)
                self?.loadAllDates(startTime: from, videoslices: model.videoSlices)
            } else {
                // 获取list数据为0，查询本年日历
            }
            
            let monthStartDay = Date.startOfCurrentYear()//Date.startOfCurrentMonth()
            self?.getSdHasVideoDays(startTime: monthStartDay.timeIntervalSince1970)
            
            logDebug("-----------> hasDataDates.count: \(self?.hasDataDates.count ?? 0)")
            self?.isFirstData = self?.hasDataDates.count ?? 0 == 0
            self?.earliestVideoSlice = model.earliestVideoSlice
            
            // 需要在有数据或者错误的时候处理
            self?.updateDatas(hasLoadData: hasLoadData, videoErrorString: nil)
            
            self?.hasDaysBlock?(true, model.videoSlices)
        }
        
        isFirstData = self.hasDataDates.count == 0
        
        if deviceModel!.isWebRtcDevice {
            
            mLivePlayer?.getSDVideoList(startTime: from, stopTime: toDate, customParam: ["apToken" : deviceModel?.apModeModel?.aptoken ?? ""], { [weak self] sliceModel, error in
                onMainThread {
                    resultBlock(sliceModel)
                    if error  != .none {
                        self?.sdErrorLimit(error: error)
                        return
                    }
                }
            })
        } else {
            A4xBaseLiveInterface.shared.ijk_sdVideo(deviceId: self.deviceModel?.serialNumber ?? "", from: from, toDate: toDate) { (code, msg, model) in
                if code == 0 {
                    if let m = model {
                        resultBlock(m)
                    }
                } else {
                    self.hasDaysBlock?(false, nil)
                }
            }
        }
    }
    
    // 加载sd卡列表视频数据
    private func loadAllDates(startTime: TimeInterval, videoslices: [A4xVideoTimeModel]?) {
        guard let deviceModle = self.deviceModel else {
            return
        }
        
        // CB系列设备
        if deviceModle.isDeviceCGB() {
        } else { // CQ or CG设备
            videoslices?.forEach({ (model) in
                if model.start != 0 {
                    let currentStr = Date(timeIntervalSince1970: TimeInterval(model.start)).dateString()
                    logDebug("-----------> hasDataDates currentStr2: \(currentStr)")
                    self.hasDataDates.insert(currentStr)
                }
            })
            
            self.calendar.reloadData()
            
            self.showHasData()
        }
    }
    
    private func getSdHasVideoDays(startTime: TimeInterval) {
        
        logDebug("-----------> getSdHasVideoDays startTime: \(startTime) startDate: \(Date.init(timeIntervalSince1970: startTime))")
        
        guard self.deviceModel != nil else {
            return
        }
        
        if hasDataDatesStartTime == nil {
            hasDataDatesStartTime = Date().timeIntervalSince1970
        }
        
        let requestData = A4xSDStateModelRequest(endTime: startTime)
        
        mLivePlayer?.getSdHasVideoDays(startTime: startTime, videoslices: [], comple: { [weak self] data in
            onMainThread {
                self?.hasDataDatesStartTime = requestData.startTime
                var videoSlices: [A4xVideoTimeModel] = []
                data?.videoInfo?.forEach({ (model) in
                    if let start = model.startTime {
                        let currentStr = Date(timeIntervalSince1970: TimeInterval(start)).dateString()
                        logDebug("-----------> hasDataDates currentStr: \(currentStr)")
                        let tmpModel = A4xVideoTimeModel()
                        tmpModel.start = Int64(model.startTime ?? 0)
                        videoSlices.append(tmpModel)
                        self?.hasDataDates.insert(currentStr)
                    }
                })
                
                if videoSlices.count > 0 {
                    self?.earliestVideoSlice = videoSlices[0]
                    self?.minDate = Date(timeIntervalSince1970: TimeInterval(videoSlices[0].start)).videoMinData(of: 0)
                    self?.timeControlView.minDate = Date(timeIntervalSince1970: TimeInterval(videoSlices[0].start )).videoMinData(of: 0)
                    
                    //  显示有数据
                    self?.showHasData()
                } else {
                    
                    // 获取列表异常
                    self?.dataErrorState()
                }
               
                // 日历刷新
                self?.calendar.reloadData()
             
            }
        })
    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        var leftItem = A4xBaseNavItem()
        leftItem.title =  "Sept.20"
        leftItem.titleColor = ADTheme.C1
        self.navView?.leftItem = leftItem
        
        var rightItem = A4xBaseNavItem()
        rightItem.normalImg =  "home_device_preset_close"
        self.navView?.rightItem = rightItem
        
        self.headerView.isHidden = false
        self.calendar.isHidden = false
        self.configCalendar()
        self.navView?.rightClickBlock = {
            weakSelf?.hiddenCalendarView()
        }
    }
    
    private lazy var headerView: A4xBaseCalendarView = {
        let temp: A4xBaseCalendarView = A4xBaseCalendarView()
        temp.leftImage = bundleImageFromImageName("icon_back_gray")?.rtlImage()
        temp.titleType = .Arrow
        temp.title = "Feb"
        weak var weakSelf = self
        temp.headInfoClickBlock = {(_ type: HeaderPostion, _ show: Bool) in
            weakSelf?.headerAction(type: type, show: show)
        }
        self.view.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.height.equalTo(UIScreen.navBarHeight).priority(.high)
        }
        
        let line = UIView()
        line.backgroundColor = ADTheme.C5
        temp.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.leading.equalTo(0)
            make.bottom.equalTo(temp.snp.bottom)
            make.height.equalTo(0.5)
            make.width.equalTo(temp.snp.width)
        }
        
        return temp
    }()
    
    private lazy var calendar: FSCalendar = {
        let temp = FSCalendar(frame: CGRect(x: 0, y: -330 , width: UIScreen.main.bounds.width, height: 330))
        self.view.addSubview(temp)
        temp.accessibilityIdentifier = "calendar"
        return temp
    }()
    
    // SD卡播放展示view
    lazy var videoView: A4xSDLocalVideoView = {
        let vc = A4xSDLocalVideoView()
        vc.dataSource = self.deviceModel
        vc.protocol = self
        vc.isUserInteractionEnabled = true
        vc.backgroundColor = .black
        self.view.addSubview(vc)
        
        vc.snp.makeConstraints({ (make) in
            make.top.equalTo(self.headerView.snp.bottom)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width)
            make.height.equalTo(self.view.snp.width).multipliedBy(videoRatio)
        })
        return vc
    }()
    
    lazy var timeControlView: A4xVideoTimerView = {
        weak var weakSelf = self
        var showdayCount = 7
        if self.deviceModel != nil  && self.deviceModel!.isWebRtcDevice{
            showdayCount = 1
        } else {
            showdayCount = 7
        }
        let temp = A4xVideoTimerView(delegate: self, showDayCount: showdayCount)
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.top.equalTo(self.videoView.snp.bottom).priority(.high)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width)
            
            if #available(iOS 11.0,*) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            }else {
                make.bottom.equalTo(self.view.snp.bottom)
            }
        }
        return temp
    }()
    
    private lazy var calendarWeekdayLine: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor(red: 0.85, green: 0.86, blue: 0.88, alpha: 1)
        self.calendar.calendarWeekdayView.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.leading.equalTo(16.auto())
            make.width.equalTo(self.calendar.snp.width).offset(-32.auto())
            make.height.equalTo(1)
            make.bottom.equalTo(self.calendar.calendarWeekdayView.snp.bottom).offset(-8.auto())
        }
        
        return temp
    }()
    
    private lazy var calendarViewBg: UIControl = {
        let temp = UIControl()
        temp.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        temp.addTarget(self, action: #selector(hiddenCalendarView) , for: .touchUpInside)
        self.view.insertSubview(temp, belowSubview: self.calendar)
        temp.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.snp.edges)
        }
        return temp
    }()
    
    private func sdErrorLimit(error: A4xSDVideoError) {
        switch error {
        case .videoLimit:
            if !isQuite {
                isQuite = true
                UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "SDcard_video_viewers_limit"), completion: { [weak self](f) in
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        case .localNetLimit:
            self.backAction()
        default:
            break
        }
    }
    
    private func headerAction(type: HeaderPostion, show: Bool) {
        switch type {
        case .Left:
            self.backAction()
        case .Center:
            self.showCalendarView()
        case .Right:
            break
        }
    }
    
    private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func hiddenCalendarView() {
        self.headerView.titleInfoShow = false
        UIView.animate(withDuration: 0.3, animations: {
            self.calendarViewBg.alpha = 0
            self.calendar.frame = CGRect(x: 0, y: -self.calendar.height, width: self.calendar.width, height: self.calendar.height)
            self.navView?.alpha = 0
        }) { (f) in
            self.calendarViewBg.isHidden = true
        }
    }
    
    private func showCalendarView() {
        self.calendarViewBg.isHidden = false
        self.calendarViewBg.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.calendarViewBg.alpha = 1
            self.calendar.frame = CGRect(x: 0, y: UIScreen.navBarHeight, width: self.calendar.width, height: self.calendar.height)
            self.navView?.alpha = 1
        }
    }
    
    
}

extension A4xSDVideoHistoryViewController: FSCalendarDelegate, FSCalendarDataSource {
    func configCalendar() {
        self.calendar.isHidden = false
        self.calendar.backgroundColor = UIColor.white
        self.calendar.collectionViewLayout.sectionInsets = UIEdgeInsets.zero
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.headerHeight = 0
        self.calendar.weekdayHeight = 60
        self.calendar.appearance.eventDefaultColor = ADTheme.Theme
        self.calendar.appearance.eventSelectionColor = ADTheme.Theme
        self.calendar.allowsMultipleSelection = false
        self.calendar.appearance.caseOptions = .weekdayUsesSingleUpperCase
        self.calendar.appearance.weekdayTextColor = ADTheme.C4
        self.calendar.appearance.selectionColor = ADTheme.Theme
        self.calendar.appearance.todayColor = UIColor.hex(0x000000, alpha: 0.1)
        self.calendar.appearance.titleTodayColor = ADTheme.C1
        self.calendar.appearance.titleFont = ADTheme.B2
        self.calendar.calendarWeekdayView.backgroundColor = UIColor.clear
        self.calendar.scope = .month
        self.calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
        self.calendar.locale = CurrentLocale()
        self.calendarWeekdayLine.isHidden = false
        self.calendar.calendarWeekdayView.configureAppearance()
        
        
        let path = UIBezierPath(roundedRect: self.calendar.bounds, byRoundingCorners: [.bottomRight,.bottomLeft], cornerRadii: CGSize(width: 15.auto(), height: 15.auto()))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.calendar.bounds
        maskLayer.path = path.cgPath
        self.calendar.layer.mask = maskLayer
        
        self.calendar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        self.calendar.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.calendar.layer.shadowOpacity = 1
        self.calendar.layer.shadowRadius = 7.5
    }
    
    //MARK: FSCalendarDelegate
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.hiddenCalendarView()
        let defaultData = date.addingTimeInterval(12 * 60 * 60)
        self.selectDate = defaultData
        timeControlView.timerSelectDate = defaultData
        
        guard self.deviceModel != nil else {
            return
        }
        
        let (vdata, date) = timeControlView.timerView.hasDataDate(date: defaultData)
        
        
        mLivePlayer?.startSdcard(startTime: date.timeIntervalSince1970, hasData: vdata != nil, audio: true, customParam: ["live_player_type" : "sd_half"])
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendar.frame = CGRect(x: 0, y: self.calendar.minY, width: self.calendar.width, height: bounds.height)
    }
    
    //MARK: FSCalendarDataSource
    func minimumDate(for calendar: FSCalendar) -> Date {
        return self.minDate
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let currentStr = date.dateString()
        if self.hasDataDates.contains(currentStr) {
            return 1
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCell", for: date, at: position)
        return cell
    }
    
    private func loadData() {
        guard let deviceId = self.deviceModel?.serialNumber else {
            return
        }
        
        /// 从SD卡返回不展示Loading
        if self.isSDFullBack != true {
            UIApplication.shared.keyWindow?.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (r) in }
        }
        
        weak var weakSelf = self
        if self.deviceModel?.apModeType == .AP {
            self.timeControlView.reloadDate(comple: {
                UIApplication.shared.keyWindow?.hideToastActivity()
            })
        } else {
            DeviceManageUtil.getDeviceSettingInfo(deviceId: deviceId) { (code, msg, model) in
                if code == 0 {
                    weakSelf?.deviceModel = model
                    
                    let status : A4xDeviceSDState = model?.sdcardState() ?? .noCard
                    weakSelf?.updateDatas(hasLoadData: false, videoErrorString: nil)
                    
                    if status.rawValue != A4xDeviceSDState.normal.rawValue {
                        UIApplication.shared.keyWindow?.hideToastActivity(block: {})
                        return
                    }
                    
                    weakSelf?.timeControlView.reloadDate(comple: {
                        UIApplication.shared.keyWindow?.hideToastActivity()
                    })
                } else {
                    UIApplication.shared.keyWindow?.hideToastActivity()
                    // SD卡视频信息失败处理
                    if code == -2002 || code == -2132 || code == -102 {
                        // 被admin删除处理
                        
                    } else if code == 1001 {
                        // 更新列表UI - 服务器超时
                        weakSelf?.updateDatas(hasLoadData: true, videoErrorString: A4xAppErrorConfig(code: code).message())
                        return
                    }
                    // 更新列表UI - 异常 服务器繁忙/返回错误码
                    weakSelf?.updateDatas(hasLoadData: true, videoErrorString: A4xBaseManager.shared.getLocalString(key: "videolist_error"))
                }
            }
        }
    }
    
    private func toastDateString(date: Date) -> String {
        let is24HrFormatStr = "".timeFormatIs24Hr() ? kA4xDateFormat_24 : kA4xDateFormat_12
        let languageFormat = "\(is24HrFormatStr):ss"
        let dataString = DateFormatter.format(languageFormat).string(from: date)
        return dataString
    }
    
    
}


extension A4xSDVideoHistoryViewController: ILiveStateListener {
    func onRenderView(surfaceView: UIView) {
        self.videoView.videoView = surfaceView
    }
    
    
    func onDeviceMsgPush(code: Int) {
        var message = ""
        switch code {
        case 1:
            message = A4xBaseManager.shared.getLocalString(key: "network_low")
            break
        case 2:
            message = A4xBaseManager.shared.getLocalString(key: "live_viewers_limit")
            break
        case 3:
            A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.localNet) { [weak self](f) in
                if !f {
                } else {
                    self?.mLivePlayer?.sendLiveMessage(customParam: ["isLocalNetLimit": true])
                }
            }
            break
        case -1:
            message = A4xBaseManager.shared.getLocalString(key: "sd_card_not_exist")
            break
        case -2:
            message = A4xBaseManager.shared.getLocalString(key: "sdcard_has_no_video")
            break
        case -3:
            message = A4xBaseManager.shared.getLocalString(key: "sdcard_need_format")
            break
        case -4:
            message = A4xBaseManager.shared.getLocalString(key: "SDcard_video_viewers_limit")
            break
        case -5:
            message = A4xBaseManager.shared.getLocalString(key: "other_error_with_code")
            break
        default:
            break
        }
        if message.count > 0 {
            UIApplication.shared.keyWindow?.makeToast(message)
        }
    }
    
    // 直播结果回调处理 凹
    func onPlayerState(stateCode: Int, msg: String) {
        guard let device = self.deviceModel else {
            return
        }
        
        if let state = A4xPlayerStateType(rawValue: stateCode) {
            if state.isErrorType() {
                // 数据列表
                self.updateDatas(hasLoadData: false, videoErrorString: A4xBaseManager.shared.getLocalString(key: "sdvideo_error"))
                
 
            }
            
            logDebug("-----------> A4xSDVideoHistoryViewController onPlayerState: \(state) isFirstData: \(isFirstData)")
            
            if case .playing = state {
                timeControlView.currentIsChange = false
                self.videoView.audioEnable = mLivePlayer?.getAudioEnable() ?? false
            }
            
            self.videoView.videoState = state == .playing ? (stateCode, device.serialNumber ?? "") : (isFirstData ? (A4xPlayerStateType.paused.rawValue, device.serialNumber ?? "") : (stateCode, device.serialNumber ?? ""))
        }
        
        
    }
    
    // 录屏结果回调处理 凹
    func onRecordState(state: Int, videoPath: String) {
        let s = A4xPlayerRecordState.init(rawValue: state)
        switch s {
        case .start:
            self.videoView.recordState = .start
        case .end:
            self.videoView.recordState = .stop
            A4xBasePhotoManager.default().save(videoPath: videoPath) { (result, id) in
                if result {
                    self.live_record_video(result: true, stop_way: "stop")
                    UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "record_success"))
                } else {
                    UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "record_failed"))
                }
            }
        case .startError:
            self.videoView.recordState = .stop
        case .endError:
            self.videoView.recordState = .stop
        case .none:
            break
        }
    }
    
    func onCurrentSdRecordTime(time: TimeInterval) {
        self.selectDate = Date(timeIntervalSince1970: time)
        self.timeControlView.timerSelectDate = self.selectDate
        if let playDate = self.selectDate {
            logDebug("A4xSDVideoHistoryViewController playerhelper \(self.toastDateString(date: playDate))")
        }
    }
    
    public func onMagicPixProcessState(status: Int) {
        
    }
    
    public func onProcessImage(_ inputImageData: UnsafeMutablePointer<UInt8>!, w imageWidth: Int32, h imageHeight: Int32, cb callback: ImageAlgorithmCallBack!) {
        
    }
    
    public func onProcessVideoStream_yuv(_ y: UnsafeMutablePointer<UInt8>!, u: UnsafeMutablePointer<UInt8>!, v: UnsafeMutablePointer<UInt8>!, w frameWidth: Int32, h frameHeight: Int32, cb callback: VideoStreamAlgorithmCallback!) {
        
    }
}

extension A4xSDVideoHistoryViewController: A4xVideoTimerViewProtocol {
    
    func timerView(timerView: A4xVideoTimerView , minDate date: Date) {}
    
    func timerViewMaxDate(timerView: A4xVideoTimerView ) -> Date {
        return Date()
    }
    
    func timerView(timerView: A4xVideoTimerView, willSelectDate date: Date) {}
    
    func timerView(timerView: A4xVideoTimerView, didSelectDate date: Date, inData: A4xVideoTimeModel?) {
        
        guard self.deviceModel != nil else {
            return
        }
        
        self.selectDate = date
        var log: String = "没有数据"
        if let dat = inData {
            log = dat.log()
        }
        
        logDebug("A4xSDVideoHistoryViewController \(self.toastDateString(date: date))-\(log)")
        if inData == nil {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "sd_no_data_date"))
            sdVideoStop()
            return
        }
        timeControlView.currentIsChange = true
        
        mLivePlayer?.startSdcard(startTime: date.timeIntervalSince1970, hasData: inData != nil, audio: true, customParam: ["live_player_type" : "sd_half"])
        
        logDebug("timerView \(date) \(inData != nil)")
    }
    
    func timerMinView(timerView: A4xVideoTimerView) -> A4xVideoChildView? {
        let identifier: String = "timerMinView"
        var cell = timerView.timerMinView(of: identifier)
        if cell == nil {
            cell = A4xSDVideoMinView(identifier: identifier)
        }
        return cell
    }
    
    func timerMaxView(timerView: A4xVideoTimerView ) -> A4xVideoChildView? {
        let identifier : String = "timerMaxView"
        var cell =  timerView.timerMaxView(of: identifier)
        if cell == nil {
            let temp = A4xSDVideoMaxView(identifier: identifier)
            weak var weakSelf = self
            temp.maxButtonBlock = {
                weakSelf?.toLiveVideoViewController()
            }
            cell = temp
        }
        return cell
    }
    
    // getSdVideoList
    // 拖动逻辑是：停留位置播放，并继续获取停留位置的下两天的数据
    func timerLoadDate(timerView: A4xVideoTimerView, fromDate: Date, toDate: Date, comple: @escaping A4xTimerLoadCompleBlock) {
        self.loadVideoData(from: fromDate.timeIntervalSince1970, toDate: toDate.timeIntervalSince1970, comple: comple)
    }
    
    func toLiveVideoViewController() {
        guard let device = self.deviceModel else {
            return
        }
        
        mLivePlayer?.stopSdcard()
        Resolver.liveUIImpl.pushFullLiveVideoViewController(deviceModel: device, shouldBackStop: true, topTipString: nil, navigationViewController: self.navigationController)
    }
    
    private func dateString(date: Date) -> String {
        let is24HrFormatStr = "".timeFormatIs24Hr() ? kA4xDateFormat_24 : kA4xDateFormat_12
        
        let languageFormat = "\(A4xUserDataHandle.Handle?.getBaseDateFormatStr() ?? A4xBaseManager.shared.getLocalString(key: "terminated_format")) \(is24HrFormatStr)"
        
        let fmt = DateFormatter()
        fmt.dateFormat = languageFormat
        fmt.locale = Locale.current
        fmt.timeZone = NSTimeZone.local
        return fmt.string(from: date)
    }
}

extension A4xSDVideoHistoryViewController: A4xSDLocalVideoViewProtocol {
    // sd卡回看点击播放按钮
    func sdVideoPlay(comple: @escaping (Bool) -> Void) {
        logDebug("-----------> A4xSDVideoHistoryViewController sdVideoPlay func")
        let (date, videoData) = self.timeControlView.timerCurrentInfo()
        guard self.deviceModel != nil else {
            comple(false)
            return
        }
        if videoData == nil {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "sd_no_data_date"))
            sdVideoStop()
            comple(false)
            return
        }
        isFirstData = false
        comple(true)
        // 包含sd卡的起始和结束时间
        mLivePlayer?.startSdcard(startTime: date.timeIntervalSince1970, hasData: videoData != nil, audio: true, customParam: ["live_player_type" : "sd_half"])
    }
    
    // sd卡回看点击暂停按钮
    func sdVideoStop() {
        logDebug("-----------> A4xSDVideoHistoryViewController sdVideoStop func")
        mLivePlayer?.stopSdcard()
    }
    
    // 设置是否开启声音
    func sdVideoVolumeAction(enable: Bool) {
        logDebug("sdVideoVolumeAction enable: \(enable)")
        live_mute_switch_click(enable: enable)
        mLivePlayer?.audioEnable(enable: enable)
    }
    
    func sdVideoScreenShot(view: UIView) {
        mLivePlayer?.screenShot(onSuccess: {  [weak self] _code, msg, image in
            guard image != nil else {
                return
            }
            A4xBasePhotoManager.default().save(image: image!, result: { (result, att) in
                logDebug("A4xBasePhotoManager save \(result) id \(att ?? "")")
                if result {
                    self?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "record_success"))
                } else {
                    self?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "shot_fail"))
                }
            })
        }, onError: { code, msg in
            
        })
    }
    
    func sdVideoRecordVideo(start: Bool) {
        logDebug("sdVideoRecordVideo start: \(start)")
        // 检测是否有录制权限 （可封装-重复代码）
        A4xBasePhotoManager.default().checkAuthor { [weak self] (error) in
            if error == .no {
                if start {
                    self?.live_record_video(result: true)
                    self?.mLivePlayer?.startRecord(path: NSHomeDirectory() + "/Documents/webrtcTmp.mp4")
                } else {
                    self?.mLivePlayer?.stopRecord()
                }
            } else {
                if error == .reject {
                    self?.live_record_video(result: false, error_msg: "Recording failed. Recording permission is denied", stop_way: "error")
                }
                A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.photo) { (f) in}
            }
        }
    }
    
    func sdVideoFull() {
        if mLivePlayer?.isRecord ?? false {
            sdVideoRecordVideo(start: false)
        }
        
        let vc = A4xSdVideoFullVideoViewController(deviceModel: self.deviceModel ?? DeviceBean(serialNumber: self.deviceModel?.serialNumber ?? ""))
        vc.endPlayDate = self.endPlayDate
        
        weak var weakSelf = self
        vc.nextCanPlayData = { date in
            if let (selectdate , videoData) = weakSelf?.timeControlView.timerCurrentInfo() {
                return (selectdate , videoData)
            }
            return (Date() , nil)
        }
        vc.isBackFromSDFullBlock = { isBack in
            weakSelf?.isSDFullBack = isBack
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 设置夜视增强功能
    func setSDMagicPixEnable(enable: Bool) {
        mLivePlayer?.magicPixEnable(enable: enable)
    }
}

// 埋点
extension A4xSDVideoHistoryViewController {
    
    // 打点事件（静音）
    private func live_mute_switch_click(enable: Bool) {
//        let playVideoEM = A4xPlayVideoEventModel()
//        playVideoEM.live_player_type = UserDefaults.standard.string(forKey: "live_player_type")
//        playVideoEM.switch_status = "\(enable)"
//        playVideoEM.connect_device = deviceModel?.serialNumber
//        A4xEventManager.liveViewEvent(event:A4xEventLiveViewType.live_mute_switch_click(eventModel: playVideoEM))
    }
    
    // 打点事件（video recording）
    private func live_record_video(result: Bool, error_msg: String? = "", stop_way: String? = "") {
//        let playVideoEM = A4xPlayVideoEventModel()
//        playVideoEM.live_player_type = "fullscreen"
//        playVideoEM.result = "\(result)"
//        playVideoEM.error_msg = error_msg
//        playVideoEM.stop_way = stop_way
//        playVideoEM.storage_space = UIDevice.current.freeDiskSpaceInGB
//        A4xEventManager.liveViewEvent(event:A4xEventLiveViewType.live_record_video(eventModel: playVideoEM))
    }
}
