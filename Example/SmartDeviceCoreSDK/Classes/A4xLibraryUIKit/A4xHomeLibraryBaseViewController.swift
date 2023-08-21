// shouldSelectIndexPath

import Foundation
import FSCalendar
import MJRefresh
import SmartDeviceCoreSDK
import JXSegmentedView
import BaseUI
import YYWebImage

public class A4xHomeLibraryBaseViewController: A4xHomeBaseViewController {
    
    public var libraryEditBtnClickCallback: ((Bool) -> Void)?
    
    private var selectEventResouce : Set<String> = Set() {
        didSet {
            self.sectionHeaderView?.editLeftBtn.isSelected = selectEventResouce.count > 0 && (self.selectEventResouce.count == self.dataEventSource?.count)
        }
    }
    
    private var hasDataTimes: Set<String>? = Set() {
        didSet {
            self.calenday.reloadData()
        }
    }
    
    private var libraryVM = A4xLibraryViewModel()
    private var editMode : Bool = false
    private var currentMonth : Date = Date()
    private var selectDate: Date?
    private var visableMonth: Int = -1

    
    var cloudDataEventSource : [RecordEventBean]?
    var sdDataEventSource : [RecordEventBean]?
    var dataEventSource : [RecordEventBean]? {
        set {
            if isSDMode {
                sdDataEventSource = newValue
            } else {
                cloudDataEventSource = newValue
            }
        }
        get {
            if isSDMode {
                return sdDataEventSource
            } else {
                return cloudDataEventSource
            }
        }
    }
    var filterTagModel : A4xVideoLibraryFilterModel?
    var netDeviceImagesData : [ZoneBean]?
    private var eventCount: Int = 0
    private var libraryCount: Int = 0 
    private let sectionHeight = 64.auto()
    private let sectionCollectionHeight = 38.auto()
    private var videoEventKey: String?
    private var videoEventArray: [Int] = [] 
    private var videoUrlArray: [String] = [] 
    var dataSourceEvent : [RecordEventBean]? 
    
    var closeButton: UIButton!
    
    var isBannerHiddenBySD = false
    var sectionHeaderView: A4xHomeLibrarySectionHeaderView?
    var isSDMode: Bool = false 
    var selectSDDeviceSN: String = ""
    var selectSDDeviceName: String = ""
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.tableView.mj_header == nil {
            self.configTableView()
            
        }
        let datas = A4xUserDataHandle.Handle?.deviceModels
        let isContain = datas?.contains { model in
            return model.hasSdCardAndSupport()
        }
        self.topView.segmentedView.isHidden = !(isContain ?? false)
        self.tableView.mj_header?.beginRefreshing()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.calenday.maximumDate < Date() || self.calenday.minimumDate > Date() {
            self.calenday.reloadData()
            self.calenday.today = Date()
        }
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        self.view.addSubview(self.topView)
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(self.SDCardView)
        self.SDCardView.isHidden = true
        self.view.addSubview(self.calenday)
        self.view.addSubview(self.tableView)
        self.bottomView.isHidden = true
        self.markSubviews() 
        self.configCalendar()
        self.addCalendayObserver()
        self.setDefaultCalenday() 
        self.configTableView()
        self.initLanguageChangeNotification()
        
    }
    
    private func markSubviews () {
        self.topView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(UIScreen.statusBarHeight + 16 + 44)
        }
        self.SDCardView.snp.makeConstraints { make in
            make.top.equalTo(UIScreen.statusBarHeight + 16 + 44)
            make.leading.trailing.bottom.equalTo(0)
        }
        self.calenday.snp.makeConstraints({ (make) in
            make.top.equalTo(self.topView.snp.bottom)
            make.trailing.equalTo(self.view.snp.trailing)
            make.leading.equalTo(0)
            make.height.equalTo(330)
        })
        self.tableView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.calenday.snp.bottom).offset(0.auto())
            make.trailing.equalTo(self.view.snp.trailing)
            make.leading.equalTo(self.view.snp.leading)
            make.bottom.equalTo(self.view.snp.bottom)
        })
    }
    
    public required init(nav: UINavigationController?) {
        super.init(nav: nav)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
 
        NotificationCenter.default.removeObserver(self)
        A4xLog("-----> A4xHomeLibraryBaseViewController deinit")
    }
    
    private func initLanguageChangeNotification() {
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: LanguageChangeNotificationKey, object: nil, queue: OperationQueue.main) { _ in
            weakSelf?.topView.reloadTitleLanguage()
            weakSelf?.SDCardView.updateLanguage()
        }
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        A4xLog("gestureRecognizerShouldBegin")
        switch self.calenday.scope {
        case .month:
            let velocity = self.scopeGesture.velocity(in: self.view)
            return velocity.y < 0
        case .week:
            return false
        @unknown default:
            fatalError()
        }
    }
    
    private func updateNavTitle() {
        self.sectionHeaderView?.editLeftBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "select_all"), for: .normal)
        self.sectionHeaderView?.editLeftBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "deselect_all"), for: .selected)
        self.sectionHeaderView?.editRightBtn.setTitle(A4xBaseManager.shared.getLocalString(key: "done"), for: .normal)
        
        let format = A4xBaseAppLanguageType.language() == .chinese ? "MM月" : "MMM"
        self.topView.title = (self.calenday.selectedDate ?? Date()).string(formatStr: format)
    }
    
    
    func selectDate(_ date: Date) {
        self.selectDate = date
        self.topView.title = date.monthstr()
        loadHasDataTimes(date: date, isFoct: false)
    }
    
    public override var shouldAutorotate : Bool {
        return false
    }
    
    func reloadData(error: String?) {
        self.tableView.reloadData()
        
        var errorStr = error
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            errorStr = A4xBaseManager.shared.getLocalString(key: "phone_no_net")
        }
        
        self.tableView.hiddNoDataView()
    }
    
    
    private func headerAction (show: Bool){
        self.calenday.setScope(show ? .month : .week, animated: true)
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
        self.topView.showCalenday = show
    }
    
    
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath! == "scope") {
            if  let newValue:UInt = change?[.newKey] as? UInt {
                if FSCalendarScope.init(rawValue: UInt(newValue)) == .week && self.topView.showCalenday == true {
                    self.topView.showCalenday = false
                }
                A4xLog("------------observeValue------------------")
            }
        }
    }
    
    private lazy var topView: A4xHomeLibrarySegmentHeaderView = {
        let temp = A4xHomeLibrarySegmentHeaderView()
        temp.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        weak var weakSelf = self
        temp.segmengtCalendayClickBlock = {(_ show: Bool) in
            weakSelf?.headerAction(show: show) 
        }
        temp.segmentClickAtIndex = {(_ index: Int) in
            if index == 0 {
                weakSelf?.sectionHeaderView?.isSDCardMode = false
                weakSelf?.SDCardView.isHidden = true
                weakSelf?.topView.canClickCalenday = true
                weakSelf?.calenday.alpha = 1
                weakSelf?.calenday.isUserInteractionEnabled = true
                if weakSelf?.isSDMode == false { 
                    return
                }
                weakSelf?.hasDataTimes = []
                weakSelf?.closeP2P() 
                A4xVideoLibraryFilterModel.clear() 
                weakSelf?.sdDataEventSource? = []
                weakSelf?.cloudDataEventSource? = []
                weakSelf?.tableView.reloadData()
                weakSelf?.tableView.mj_footer?.isHidden = true

                DispatchQueue.main.a4xAfter(0.3) {
                    if weakSelf?.isBannerHiddenBySD ?? false {
                        weakSelf?.tableView.beginUpdates()
                        weakSelf?.tableView.endUpdates()
                        weakSelf?.isBannerHiddenBySD = false
                    }
                }
                
            } else {
                if weakSelf?.isSDMode == true { 
                    return
                }
                weakSelf?.editManager(flag: false)
                weakSelf?.SDCardView.isHidden = false
                weakSelf?.topView.canClickCalenday = false
                weakSelf?.SDCardView.show()
                weakSelf?.calenday.alpha = 0.7
                weakSelf?.calenday.isUserInteractionEnabled = false
            }
        }
        return temp
    }()
    
    
    private lazy var SDCardView: A4xHomeLibrarySDCardChooseView = {
        let temp = A4xHomeLibrarySDCardChooseView()
        temp.tag = 30001
        temp.hideSDCardViewBlock = {[weak self] in
            self?.topView.segmentedView.selectItemAt(index: 0)
            self?.closeP2P()
        }
        temp.confirmClick = { [weak self] deviceSN in
            let deviceModel = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceSN, modeType: .WiFi) ?? DeviceBean()
            
            if deviceModel.supportSdCooldown() {
                self?.SDCardView.isHidden = true
                
                LibraryCore.getInstance().rtcconnectionOpen(serialNumber: deviceSN) { code, msg in
                    
                } onFail: { code, msg in
                    
                }
                
                let modelCategoryName = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: deviceModel.modelCategory ?? 0)
                self?.comfirmClick(deviceName: modelCategoryName , comple: { 
                    
                    self?.hasDataTimes = []
                    self?.selectSDDeviceSN = deviceSN
                    self?.selectSDDeviceName = deviceModel.deviceName ?? ""
                    self?.isSDMode = true
                    self?.sectionHeaderView?.isSDCardMode = true
                    
                    self?.eventCount = 0
                    self?.libraryCount = 0
                    self?.topView.canClickCalenday = true
                    self?.calenday.alpha = 1
                    self?.calenday.isUserInteractionEnabled = true
                    A4xVideoLibraryFilterModel.clear()
                    self?.sdDataEventSource? = []
                    self?.cloudDataEventSource? = []
                    self?.tableView.reloadData()
                    self?.tableView.mj_footer?.isHidden = true

                })
            } else {
                self?.topView.segmentedView.selectItemAt(index: 0)
            }
            
        }
        return temp
    }()
    
    func comfirmClick(deviceName: String ,comple: @escaping () -> Void) {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.Theme
        config.rightTextColor = UIColor.white
        
        let alert = A4xBaseAlertView(param: config, identifier: "show Save Alert")
        alert.message = A4xBaseManager.shared.getLocalString(key: "library_sdcard_wake_device", param: [deviceName])
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "no")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "yes")
        weak var weakSelf = self
        alert.rightButtonBlock = {
            comple()
        }
        alert.leftButtonBlock = {
            weakSelf?.topView.segmentedView.selectItemAt(index: 0)
            weakSelf?.closeP2P()
        }
        alert.show()
    }
    
    private func closeP2P() {
        // 状态值改变
        self.isSDMode = false
        // 关闭链接
        LibraryCore.getInstance().rtcconnectionClose(serialNumber: selectSDDeviceSN) { code, msg in

        } onFail: { code, msg in

        }
        // 清空选中设备
        selectSDDeviceSN = ""
        selectSDDeviceName = ""
    }
    
    private lazy var calenday: FSCalendar = {
        let temp = FSCalendar()
        return temp
    }()
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calenday, action: #selector(self.calenday.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    private lazy var tableView: UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: .plain)
        temp.accessibilityIdentifier = "tableView"
        temp.delegate = self
        temp.dataSource = self
        temp.backgroundColor = .clear
        temp.separatorStyle = .none
        temp.rowHeight = UITableView.automaticDimension
        temp.separatorInset = UIEdgeInsets.zero
        if #available(iOS 15.0, *) {
            temp.sectionHeaderTopPadding = 0;
        }

        temp.clipsToBounds = true
        temp.register(A4xHomeLibraryEventCell.self, forCellReuseIdentifier: "A4xHomeLibraryEventCell")
        temp.register(A4xHomeLibrarySDNewCell.self, forCellReuseIdentifier: "A4xHomeLibrarySDNewCell")
        return temp
    }()
    
    private lazy var bottomView: A4xResourceBottomBarView = {
        let temp = A4xResourceBottomBarView(items: A4xResourceBottomStyle.defaultStyle())
        temp.backgroundColor = ADTheme.Theme
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.view.snp.bottom)
            make.width.equalTo(self.view.snp.width)
            make.leading.equalTo(0)
            make.height.equalTo(UIScreen.bottomBarHeight)
        })
        weak var weakSelf = self
        temp.bottomSelectBlock = {style in
            weakSelf?.bottomUpdateSelect(type: style)
        }
        return temp
    }()
}

//  Here is the logic of the data request .
extension A4xHomeLibraryBaseViewController {
    
    func loadHasDataTimes(date: Date, isFoct: Bool) {
        let (start, end, loadMonth) = date.previousMonthAndCurrentMonth
        guard loadMonth != self.visableMonth || isFoct else {
            return
        }
        self.visableMonth = loadMonth
        let monthStr = date.monthString()
        
        weak var weakSelf = self
        let serialNumbers = isSDMode ? [selectSDDeviceSN] : self.filterTagModel?.filterTagAllDeviceId() ?? []
        self.libraryVM.getLibraryStatus(isFromSDCard: isSDMode, start: start, end: end, serialNumbers: serialNumbers, filter: self.filterTagModel, result: { (strs) in
            guard strs.count > 0 else {
                return
            }
            let currentStr = weakSelf?.hasDataTimes?.filter({ (current) -> Bool in
                return !current.hasPrefix(monthStr)
            })
            weakSelf?.hasDataTimes = currentStr?.union(strs)
        })
    }
    
    
    private func getLibraryList(isHeadRefresh: Bool, isChangeSegment: Bool) {
        
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            let errorStr = A4xBaseManager.shared.getLocalString(key: "phone_no_net")
            self.view.makeToast(errorStr)
            return
        }
        let getData: Date = self.selectDate ?? Date()
        let serialNumbers = isSDMode ? [selectSDDeviceSN] : self.filterTagModel?.filterTagAllDeviceId()
        self.libraryVM.getEventRecordByFilter(deviceName: selectSDDeviceName, isFromSDCard: isSDMode, isMore: !isHeadRefresh, date: getData, serialNumbers: serialNumbers, filter: self.filterTagModel, result: {[weak self] (resouces, result, eventCount, libraryCount, errorCode, error) in
            if self?.selectDate != getData {
                return
            }
            if isHeadRefresh {
                self?.tableView.mj_header?.state = .idle
                if error == nil {
                    self?.dataEventSource = resouces
                }
                if isChangeSegment {
                    self?.sdDataEventSource = []
                    self?.cloudDataEventSource = []
                }
            } else {
                self?.tableView.mj_footer?.endRefreshing(completionBlock: {})
                if error == nil {
                    self?.dataEventSource? += resouces ?? []
                }
            }
            self?.eventCount = eventCount ?? 0
            self?.libraryCount = libraryCount ?? 0
            self?.tableView.mj_footer?.isHidden = !result
            
            self?.reloadData(error: error)
            
            if eventCount ?? 0 > 0 {
                self?.calenday.appearance.eventSelectionColor = ADTheme.Theme
            } else {
                self?.calenday.appearance.eventSelectionColor = .clear
            }
            self?.calenday.reloadData()
        })
    }
    
}


extension A4xHomeLibraryBaseViewController: FSCalendarDelegate, FSCalendarDataSource {
    func configCalendar() {
        self.calenday.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        self.calenday.calendarWeekdayView.backgroundColor = UIColor.clear
        self.calenday.collectionViewLayout.sectionInsets = UIEdgeInsets.zero
        self.calenday.delegate = self
        self.calenday.dataSource = self
        self.calenday.headerHeight = 0
        self.calenday.weekdayHeight = 28
        self.calenday.appearance.eventDefaultColor = ADTheme.Theme 
        self.calenday.appearance.eventSelectionColor = ADTheme.Theme 
        self.calenday.allowsMultipleSelection = false
        self.calenday.appearance.caseOptions = .weekdayUsesSingleUpperCase
        self.calenday.appearance.weekdayTextColor = ADTheme.C4
        self.calenday.appearance.selectionColor = ADTheme.Theme
        self.calenday.appearance.todayColor = UIColor.hex(0x000000, alpha: 0.1)
        self.calenday.appearance.titleTodayColor = ADTheme.C1
        self.calenday.appearance.titleFont = ADTheme.B2
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calenday.scope = .week
        self.calenday.register(A4xHomeCalendarCell.self, forCellReuseIdentifier: "A4xHomeCalendarCell")
        
        self.calenday.locale = CurrentLocale()
        updateNavTitle()
        self.calenday.calendarWeekdayView.configureAppearance()
    }
    
    private func addCalendayObserver() {
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: LanguageChangeNotificationKey, object: nil, queue: OperationQueue.main) { (noti) in
            
            weakSelf?.calenday.locale = CurrentLocale()
            weakSelf?.calenday.calendarWeekdayView.configureAppearance()
            weakSelf?.calenday.reloadData()
            
            weakSelf?.tableView.reloadData()
            weakSelf?.topView.title = weakSelf?.currentMonth.monthstr()
            
            let state = weakSelf?.tableView.mj_footer?.state ?? .idle
            weakSelf?.tableView.mj_footer?.state = .idle
            weakSelf?.tableView.mj_footer?.state = state
            
            if let fooder: MJRefreshAutoNormalFooter = weakSelf?.tableView.mj_footer as? MJRefreshAutoNormalFooter {
                fooder.setTitle(A4xBaseManager.shared.getLocalString(key: "more_data"), for: MJRefreshState.idle)
            }
            weakSelf?.bottomView.updateTitle()
            weakSelf?.tableView.updateAlertViewInfo()
            weakSelf?.updateNavTitle()
        }
    }
    
    private func setDefaultCalenday() {
        let date = Date()
        self.calenday.select(date, scrollToDate: true)
        self.selectDate = date
        self.topView.title = date.monthstr()
        
        self.calenday.addObserver(self, forKeyPath: "scope", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    
    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        A4xLog("calendar didSelect data: \(date)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        selectDate(date)
    }
    
    public func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        A4xLog("calendar boundingRectWillChange bounds.height: \(bounds.height)")
        self.calenday.snp.updateConstraints { (make) in
            make.height.equalTo(bounds.height)
        }
        //self.view.layoutIfNeeded()
    }
    
    
    public func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    public func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        return nil
    }
    
    public func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if let hasd = self.hasDataTimes {
            if hasd.contains(date.dateString()) {
                return 1
            }
        }
        return 0
    }
    
    public func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "A4xHomeCalendarCell", for: date, at: position)
        return cell
    }
    
    public func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        var date: Date? = calendar.currentPage
        switch calendar.scope {
        
        case .week:
            let day = calendar.currentPage.day
            if day > 28 {
                date = calendar.currentPage.nextMonth
            } else {
                date = calendar.currentPage
            }
        default:
            break
        }
        
        self.currentMonth = date ?? Date()
        self.topView.title = date?.monthstr()
        loadHasDataTimes(date: date ?? Date(), isFoct: false)
    }
}


extension A4xHomeLibraryBaseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configTableView() {
        
        weak var weakSelf = self
        self.tableView.mj_header = A4xMJRefreshHeader {
            A4xLog("-----------> A4xMJRefreshHeader")
            A4xVideoLibraryFilterModel.get(block: { (model) in
                
                weakSelf?.filterTagModel = model
                
                weakSelf?.loadHasDataTimes(date: weakSelf?.selectDate ?? Date(), isFoct: true)
                
                weakSelf?.getLibraryList(isHeadRefresh: true, isChangeSegment: false)
            })
        }

        let fooder = MJRefreshAutoNormalFooter(refreshingBlock: {
            
            weakSelf?.getLibraryList(isHeadRefresh: false, isChangeSegment: false)
        })
        fooder.isAutomaticallyRefresh = false
        fooder.setTitle("", for: MJRefreshState.idle)
        fooder.setTitle("", for: MJRefreshState.pulling)
        fooder.setTitle("", for: MJRefreshState.noMoreData)
        fooder.setTitle("", for: MJRefreshState.refreshing)
        fooder.setTitle(A4xBaseManager.shared.getLocalString(key: "more_data"), for: MJRefreshState.idle)
        fooder.isRefreshingTitleHidden = true
        self.tableView.mj_footer = fooder
        self.tableView.mj_footer?.isHidden = true
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if filterTagModel == nil || filterTagModel?.isEmpty() ?? true {
            return sectionHeight
        }
        return sectionHeight + sectionCollectionHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let isFilter = (filterTagModel == nil || filterTagModel?.isEmpty() ?? true)
        if (self.sectionHeaderView == nil) {
            self.sectionHeaderView = A4xHomeLibrarySectionHeaderView(editMode: self.editMode, isFilter: !isFilter)
        }
        
        weak var weakSelf = self
        sectionHeaderView?.leftClickBlock = { (isEdit, isSelectedAll) in
            if isEdit ?? false {
                (isSelectedAll ?? false) ? weakSelf?.selectEventAll() :  weakSelf?.reEventSelectAll()
            } else {
                if (weakSelf?.calenday.scope == .month){ 
                    weakSelf?.calenday.setScope(.week, animated: true)
                }
                weakSelf?.presendFilterResource { // 跳转筛选页面
                }
            }
        }
        sectionHeaderView?.rightClickBlock = { isEdit in
            if (weakSelf?.calenday.scope == .month){
                weakSelf?.calenday.setScope(.week, animated: true)
            }
            weakSelf?.editManager(flag: isEdit ?? false)
            
            weakSelf?.topView.canClickCalenday = (isEdit ?? false) ? false : true
            weakSelf?.calenday.alpha = (isEdit ?? false) ? 0.7 : 1
            weakSelf?.calenday.isUserInteractionEnabled = (isEdit ?? false) ? false : true
        }
        
        sectionHeaderView?.dataSource = filterTagModel
        let main1 = A4xBaseManager.shared.getLocalString(key: "total_event2", param: ["\(eventCount)" + " "])
        let main2 = A4xBaseManager.shared.getLocalString(key: "total_video2", param: ["\(libraryCount)"])
        sectionHeaderView?.eventTitleLabel.text = main1 + main2
        return sectionHeaderView
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataEventSource?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < dataEventSource?.count ?? 0 {
            let data = self.dataEventSource?[indexPath.row]
            if data?.imageUrl?.isBlank == true && isSDMode {
                return 79.auto()
            } else {
                return 110.auto()
            }
        } else {
            return 110.auto()
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row >= dataEventSource?.count ?? 0 {
            let tableCell = tableView.dequeueReusableCell(withIdentifier: "A4xHomeLibraryEventCell", for: indexPath) as? A4xHomeLibraryEventCell
            tableCell?.isEditModel = false
            return tableCell!
        }
        let data = self.dataEventSource?[indexPath.row]
        if data?.imageUrl?.isBlank == true && isSDMode {
            let tableCell = tableView.dequeueReusableCell(withIdentifier: "A4xHomeLibrarySDNewCell", for: indexPath) as? A4xHomeLibrarySDNewCell
            tableCell?.dataEventModel = self.dataEventSource?[indexPath.row]
            return tableCell!
        } else {
            let tableCell = tableView.dequeueReusableCell(withIdentifier: "A4xHomeLibraryEventCell", for: indexPath) as? A4xHomeLibraryEventCell
            tableCell?.dataEventModel = self.dataEventSource?[indexPath.row]
            tableCell?.updateEventSources()
            tableCell?.isEditModel = self.editMode
            tableCell?.isBeSelected = self.selectEventResouce.contains(tableCell?.dataEventModel?.libraryIds ?? "")
            tableCell?.dataSourceChangeBlock = { [weak self] updateSource in
                if (self?.dataEventSource?.count ?? 0) > indexPath.row {
                    let index = self?.dataEventSource?.firstIndex(where: { $0.libraryIds == updateSource?.libraryIds}) ?? -1
                    if index != -1 {
                        self?.dataEventSource?[index] = updateSource ?? RecordEventBean()

                    }
                }
            }
            return tableCell!
        }

    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.dataEventSource?.count ?? 0) > indexPath.row {
            let dataEventSource: RecordEventBean = self.dataEventSource![indexPath.row]
            
            if self.editMode {
                
                guard (dataEventSource.libraryIds ?? "" ).cLength > 0 else {
                    return
                }
                if (self.selectEventResouce.contains(dataEventSource.libraryIds ?? "")) {
                    self.selectEventResouce.remove(dataEventSource.libraryIds ?? "")
                } else {
                    self.selectEventResouce.insert(dataEventSource.libraryIds ?? "")
                }
                self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            } else {
                self.videoEventKey = dataEventSource.videoEventKey
                let date = Date(timeIntervalSince1970: dataEventSource.startTime ?? 0)
                let day = round(Date().daysInBetween(date))
                self.presentMediaPlay(index: indexPath.row, dataEventSource: self.dataEventSource ?? [])
            }
        }
    }
    
}


extension A4xHomeLibraryBaseViewController {
    
    func presendFilterResource(result: @escaping ()->Void ) {
        let vc = A4xFilterTagsViewController()
        vc.isFromSDCard = self.isSDMode
        vc.sdDeviceSN = self.selectSDDeviceSN
        vc.fileterUpdateBlock = { isChange in // 跳相册搜索页
            if isChange {
                result()
            }
        }
        vc.netDeviceImagesData = netDeviceImagesData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func editManager(flag : Bool) {
        self.videoEventArray.removeAll()
        self.selectEventResouce.removeAll()
        
        self.editMode = flag
        self.libraryEditBtnClickCallback?(flag)
        self.sectionHeaderView?.editMode = flag
        
        if flag {
            self.bottomView.isHidden = false
            self.sectionHeaderView?.editLeftBtn.isEnabled = self.dataEventSource?.count ?? 0 > 0
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        } else {
            self.bottomView.isHidden = true
            self.tableView.contentInset = .zero
        }
        
        self.tableView.reloadData()
        self.topView.canClickCalenday = !self.editMode
        self.calenday.alpha = self.editMode ? 0.7 : 1
        self.calenday.isUserInteractionEnabled = !self.editMode
        updateNavTitle()
    }
    
    
    func presentMediaPlay(index: Int, dataEventSource: [RecordEventBean]) {
        A4xLog("-----------> presentMediaPlay index: \(index)")
        
        let vc = A4xLibraryDetailBaseViewController(index: index, dataEventSource: dataEventSource, isFromSDCard: isSDMode)
        vc.filterTagModel = self.filterTagModel
        vc.selectSDDeviceSN = self.selectSDDeviceSN
        self.navigationController?.pushViewController(vc, animated: true)
        
        weak var weakSelf = self
        
        vc.popViewControllerBlock = { (eventSource, index) in
            weakSelf?.dataEventSource = eventSource
        }
        
        vc.souceChangeEventStarsBlock = { (source, sourceEvent, marked)  in 
            let index = weakSelf?.souceAtEventStarsIndex(source: source, sourceEvent: sourceEvent) ?? 0
            let data = sourceEvent
            if marked == 1 {
                data.marked = 1 
            } else {
                data.marked = 0 
            }
            data.missing = 0 
            DispatchQueue.main.a4xAfter(2) {
                weakSelf?.dataEventSource?[index] = data
            }
        }
        
        vc.onDissmisEventBlock = { model in
            A4xLog("---------------> onDissmisEventBlock: \(model)")
        }
        
        vc.souceChangeEventBlock = { source in  
            A4xLog("---------------> souceChangeEventBlock: \(source)")
            switch source {
            case let .updateEvent(modle):
                let index = weakSelf?.souceAtEventIndex(source: modle!) ?? 0

                
                weakSelf?.dataEventSource?[index] = modle!
                
            
            case let .deleteEvent(modle):
                let index = weakSelf?.souceAtEventIndex(source: modle) ?? 0
                if index < 0 {
                    return
                }
                weakSelf?.dataEventSource?.remove(at: index)
            
            }
            
            
        }
        
    }
    
    
    private func souceAtEventIndex(source: RecordEventBean) -> Int { 
        let libraryArray = source.libraryIds?.components(separatedBy: ",")
        guard let sourceId = libraryArray?[0] else {
            return -1
        }
        
        var index = -1
        for i in 0..<(self.dataEventSource?.count ?? 0) {
            let temp = self.dataEventSource![i]
            let tempArray = temp.libraryIds?.components(separatedBy: ",")
            if let tempId = tempArray?[0] {
                if tempId == sourceId {
                    index = i
                }
            }
        }
        return index
    }
    
    private func souceAtEventStarsIndex( source: RecordBean ,sourceEvent: RecordEventBean) -> Int { 
        var index = -1
        for i in 0..<(self.dataEventSource?.count ?? 0) {
            let temp = self.dataEventSource![i]
            if let tempId = temp.videoEventKey {
                if tempId == sourceEvent.videoEventKey {
                    index = i
                }
            }
        }
        return index
    }
}



//MARK: - Download manager
extension A4xHomeLibraryBaseViewController {
    
    private func bottomUpdateSelect(type : A4xResourceBottomStyle) {
        switch type {
        case .delete:
            A4xLog("delte")
            deleteEventResource()
        case .share:
            A4xLog("share")
        case .download:
            A4xLog("download")
            downloadEvent()
        }
    }
    
    
    private func reEventSelectAll() { 
        self.videoEventArray.removeAll()
        self.selectEventResouce.removeAll()
        self.tableView.reloadData()
        self.sectionHeaderView?.editLeftBtn.isSelected = false
    }
    
    private func selectEventAll() { 
        weak var weakSelf = self
        self.dataEventSource?.forEach({ (model) in
            if let id = model.libraryIds {
                weakSelf?.selectEventResouce.insert(id)
            }
        })
        self.tableView.reloadData()
        self.sectionHeaderView?.editLeftBtn.isSelected = true
    }
    
    
    private func downloadEvent() {
        
        guard self.dataEventSource != nil else {
            return
        }
        guard self.selectEventResouce.count > 0 else {
            return self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "no_item_selected"))
        }
        var downloadSource: [RecordBean] = []
        var videoId: String = ""
        var video_duration_sum: Float = 0
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        
        for source in self.dataEventSource! {
            if self.selectEventResouce.contains(source.libraryIds!) {
                if source.libraryIds != nil && source.libraryIds?.count ?? 0 > 0 {
                    queue.async(group: group, execute: {
                        
                        group.enter()
                        
                        let tempID = source.libraryIds ?? ""
                        videoId += (tempID + ",")
                        video_duration_sum += source.period ?? 0.0
                        
                        let serialNumbers = self.isSDMode ? [self.selectSDDeviceSN] : []
                        let startTimestamp = self.isSDMode ? self.calenday.currentPage.dayBetween.0 : 0
                        let endTimestamp = self.isSDMode ? self.calenday.currentPage.dayBetween.1 : 0
                        self.libraryVM.getEventDetail(isFromSDCard: self.isSDMode, serialNumbers: serialNumbers, startTimestamp: startTimestamp, endTimestamp: endTimestamp, filter: self.filterTagModel, videoEventKey: source.videoEventKey ?? "0", result: { list, total, error in
                            if list != nil {
                                A4xLog("-----------> sub list count: \(list?.count ?? 0)")
                                downloadSource += list!
                            }
                            group.leave()
                        })
                    })
                }
            }
        }
        
        group.notify(queue: queue) {
            guard downloadSource.count > 0 else {
                return
            }
            DispatchQueue.main.async {
                self.selectEventResouce.removeAll()
                self.editManager(flag: false)
                UIWindow.downloadSource(models: downloadSource, nav: self.navigationController, haveTabBar: true) 
            }
        }
    }
    private func deleteEventResource() {
        
        guard self.selectEventResouce.count > 0 else {
            return self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "no_item_selected"))
        }
        
        var deleteAllSource: [RecordEventBean] = Array()
        for source in self.dataEventSource! {
            if self.selectEventResouce.contains(source.libraryIds!) {
                if source.videoUrls != nil && source.libraryIds != nil {
                    deleteAllSource.append(source)
                }
            }
        }
        
        guard deleteAllSource.count > 0 else {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "toast_del_one_is_guest")) 
            return
        }
        let subSource = deleteAllSource.filter({ (model) -> Bool in
            return model.manager
        })
        if subSource.count == 0 {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "toast_del_one_is_guest")) 
            return
        }
        
        var title: String = ""
        var message: String = ""
        
        if deleteAllSource.count == subSource.count {
            if (subSource.count == 1) {
                title = A4xBaseManager.shared.getLocalString(key: "dialog_title_del_one")
                message = A4xBaseManager.shared.getLocalString(key: "dialog_message_del_multi_without_guest")
            } else {
                title = A4xBaseManager.shared.getLocalString(key: "dialog_title_del_multi", param: ["\(deleteAllSource.count)"])
                message = A4xBaseManager.shared.getLocalString(key: "dialog_message_del_multi_without_guest")
            }
        } else {
            title = A4xBaseManager.shared.getLocalString(key: "dialog_title_del_multi", param: ["\(deleteAllSource.count)"])
            //A4xBaseManager.shared.getLocalString(key: "dialog_title_del_multi(deleteAllSource.count)//")
            message = A4xBaseManager.shared.getLocalString(key: "dialog_message_del_multi_with_guest", param: ["\(deleteAllSource.count - subSource.count)"])
        }
        
        weak var weakSelf = self
        self.showAlert(title: title, message: message, cancelTitle: A4xBaseManager.shared.getLocalString(key: "cancel"), doneTitle: A4xBaseManager.shared.getLocalString(key: "delete"), doneAction: {
            weakSelf?.deleteEventSource(sources: deleteAllSource)
            weakSelf?.editManager(flag: false)
        })
    }
    
    private func deleteEventSource(sources: [RecordEventBean]) {
        var traceIdList: [String] = []
        var eventNum: Int = 0
        var videoNum: Int = 0
        sources.forEach { (adr) in
            let libraryArray = adr.libraryIds ?? ""
            if libraryArray.contains(",") {
                let tempLibraryIds = libraryArray.components(separatedBy: ",") 
                tempLibraryIds.forEach { libraryId in
                    traceIdList.append(libraryId)
                }

                eventNum += tempLibraryIds.count
            } else {
                traceIdList.append(libraryArray)
                videoNum += 1
            }
        }
        
        weak var weakSelf = self
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        self.libraryVM.deleteRecord(traceIdList: traceIdList, result: { (error) in
            weakSelf?.view.hideToastActivity()
            guard error == nil else {
                weakSelf?.view.makeToast(error)
                return
            }

            sources.forEach { (model) in
                weakSelf?.dataEventSource?.removeAll(where: { data in
                    model.videoEventKey == data.videoEventKey
                })
            }
            weakSelf?.videoEventArray.removeAll()
            weakSelf?.selectEventResouce.removeAll()
            
            weakSelf?.eventCount = (weakSelf?.eventCount ?? 0) - sources.count
            weakSelf?.libraryCount = (weakSelf?.libraryCount ?? 0) - (eventNum + videoNum)
            weakSelf?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "delete_success"))
            weakSelf?.tableView.reloadData()
        })
    }
    
    @objc private func closeActivity() {
        self.view.hideToastActivity()
    }
}
