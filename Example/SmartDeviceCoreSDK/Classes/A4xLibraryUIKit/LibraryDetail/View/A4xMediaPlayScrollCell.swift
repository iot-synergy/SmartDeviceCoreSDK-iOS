//


//


//

import UIKit
import MJRefresh
import SmartDeviceCoreSDK
import A4xIJKMediaPlayerUIKit
import BaseUI

protocol A4xMediaPlayScrollCellProtocol: class {
    func A4xMediaPlayRefreshStateHeader()
    func A4xMediaPlayRefreshStateFooter()
}

public enum A4xMediaPlayScrollType : Int {
    case playeStart     = 1000     
    case playComple     = 1001     
    case playPause      = 1002     
    case playStop       = 10023    
}

class A4xMediaPlayScrollCell: A4xMediaBaseScrollCell {
    
    private var selectStatusPlay : A4xMediaPlayScrollType = .playeStart
    private var isPlaying: Bool = true

    private var cellHeight: CGFloat = 0.auto() 
    private var _dataSourceArray: [RecordBean]? 
    private var eventDescCount: Int = 0 
    private var selectIndex: Int = 0 
    private var mediaPlayer: A4xMediaPlayerController?

    
    weak var `protocol`: A4xMediaPlayScrollCellProtocol? 
    var editMode : Bool = false
    var isFromSDCard: Bool = false 
    var hasImage: Bool = false 
    var isMark: Bool = false 
    
    var retryBlock: (() -> Void)? 
    
    var selectEventResouce : Set<String> = Set() {
        didSet {}
    }
    
    var dataSourceArray: [RecordBean]? {
        set {
            if isMark {
                
            } else {
                _dataSourceArray = newValue
                self.updateMediaData()     
                self.fetchVideoEventDetail()   
            }
        }
        get {
            return _dataSourceArray
        }
    }
    
    override var controlBarHidden: ((Bool) -> Void)? {
        didSet {
            self.mediaPlayerView.controlBarHidden = controlBarHidden
        }
    }
    
    public override var isLandscape: Bool {
        get {
            return A4xAppSettingManager.shared.orientationIsLandscape()
        }
    }
    
    init(frame: CGRect = .zero, data: RecordBean? = nil) {
        super.init(frame: frame)
        self.updateFrame()
    }
    
    override var frame: CGRect {
        didSet {
            self.updateFrame()
        }
    }
    private lazy var _authorityLaybel: UILabel? = {
        let temp = UILabel()
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        temp.font = ADTheme.H3
        temp.textColor = ADTheme.C1
        self.addSubview(temp)
        return temp
    }()
    
    private lazy var _dateLaybel: UILabel? = {
        let temp = UILabel()
        temp.font = ADTheme.B2
        temp.textColor = ADTheme.C4
        self.addSubview(temp)
        return temp
    }()
    
    private lazy var _mediaTypeImg: A4xMediaVideoTagsView? = { 
        let temp = A4xMediaVideoTagsView()
        self.addSubview(temp)
        return temp
    }()
    
    //MARK: - 播放器
    lazy var mediaPlayerView: A4xMediaPlayerView = { 
        let temp = A4xMediaPlayerView()
        self.mediaPlayer = A4xMediaPlayerController()
        self.mediaPlayer?.playerType = .ijkType
        self.mediaPlayer?.mediaPlayerView = temp
        self.mediaPlayer?.delegate = self
        self.addSubview(temp)
        return temp
    }()
    
    private lazy var playErrorView: A4xMediaVideoPlayErrorView = {
        let temp = A4xMediaVideoPlayErrorView()
        self.mediaPlayerView.addSubview(temp)
        temp.isHidden = true
        temp.reloadBtn.addTarget(self, action: #selector(replayVideo), for: .touchUpInside)
        return temp
    }()
    
    @objc func replayVideo() {
        self.playErrorView.isHidden = true
        self.mediaPlayer?.playVideo()
    }
    
    private lazy var pushInfoView: UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.B1
        temp.textAlignment = .left
        temp.numberOfLines = 0
        temp.textColor = ADTheme.C4
        self.addSubview(temp)
        return temp
    }()
    
    //MARK: - 事件
    lazy var tableView: UITableView = {
        let temp = UITableView()
        temp.delegate = self
        temp.dataSource = self
        temp.backgroundColor = .clear
        temp.tableFooterView = UIView()
        temp.accessibilityIdentifier = "tableView"
        temp.separatorInset = .zero
        temp.separatorColor = ADTheme.C6
        temp.estimatedRowHeight = 70
        temp.rowHeight = UITableView.automaticDimension
        temp.register(A4xMediaPlayScrollLibraryCell.self, forCellReuseIdentifier: "A4xMediaPlayScrollLibraryCell")
        temp.register(A4xMediaPlayScrollLibrarySDCell.self, forCellReuseIdentifier: "A4xMediaPlayScrollLibrarySDCell")
        
        let fooder = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            
            self?.protocol?.A4xMediaPlayRefreshStateFooter()
        })
        
        fooder.isAutomaticallyRefresh = false
        fooder.setTitle("", for: MJRefreshState.idle)
        fooder.setTitle("", for: MJRefreshState.pulling)
        fooder.setTitle("", for: MJRefreshState.noMoreData)
        fooder.setTitle("", for: MJRefreshState.refreshing)
        fooder.setTitle(A4xBaseManager.shared.getLocalString(key: "more_data"), for: MJRefreshState.idle)
        fooder.isRefreshingTitleHidden = true
        temp.mj_footer = fooder
        temp.mj_footer?.isHidden = true
        
        self.addSubview(temp)
        return temp
    }()
    
    override var isActivty: Bool {
        didSet {
            if isActivty {
                if isActivty == oldValue {
                    return
                }
                self.mediaPlayer?.isAutoPlay = isActivty
                self.mediaPlayer?.playVideo()
            } else {
                self.mediaPlayer?.stopVideo()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    
    private func playComple() {
        
        self.isActivty = false
    }
    
    public func showNoDataView() {
        self.noDataView?.isHidden = false
        self.mediaPlayerView.isHidden = true
        self.tableView.isHidden = true
    }
    
    private func hideNoDataView() {
        self.noDataView?.isHidden = true
        self.mediaPlayerView.isHidden = false
        self.tableView.isHidden = false
    }
    
    private lazy var noDataView: UIView? = {
        let img = bundleImageFromImageName("libary_detail_no_data")?.rtlImage()
        let errorValue = A4xBaseNoDataValueModel.noData(error: A4xBaseManager.shared.getLocalString(key: "videolist_error"), image: img, retry: false, noDataType: .normal, specialState: A4xBaseNoDataSpecialType.none) { [weak self] in
            self?.retryBlock?()
        }
        let temp = self.showNoDataView(value: errorValue)
        self.addSubview(temp!)
        temp?.isHidden = true
        return temp!
    }()
}

extension A4xMediaPlayScrollCell: A4xMediaPlayerProtocol {
    var authorityLaybel: UILabel? {
        return self._authorityLaybel
    }
    
    var dateLaybel: UILabel?{
        return self._dateLaybel
    }
    
    var mediaTypeImg: A4xMediaVideoTagsView? {
        return self._mediaTypeImg
    }
    
    private func updateVisable(progress: CGFloat) {
        let alpha: CGFloat = max(min(1, progress), 0)
        self.authorityLaybel?.alpha = alpha
        self.dateLaybel?.alpha = alpha
        self.mediaTypeImg?.alpha = alpha
    }
    
    private func updateMediaData() {
        if self.dataSourceArray?.count ?? 0 > 0 {
            self.hideNoDataView()
            var videoURL: URL? = self.dataSourceArray?[0].videoURL
            if videoURL == nil && self.dataSourceArray?[0].source != nil {
                videoURL = URL(string: (self.dataSourceArray?[0].source ?? ""))
            }
            
            self.mediaPlayer?.videoUrl = videoURL
            

        } else {
            self.showNoDataView()
        }
    }
    
    
    private func fetchVideoEventDetail() {
        guard self.dataSourceArray?.count ?? 0 > 0 else {
            return
        }
        guard self.dataSourceArray?.count ?? 0 <= selectIndex else {
            return
        }
        guard let messageId = self.dataSourceArray?[selectIndex].traceId else {
            return
        }
        
        weak var weakSelf = self
        LibraryCore.getInstance().loadSingleLibraryInfo(msgId: messageId) { code, msg, model in
            if code == 0 {
                var eventVideoModel: RecordBean = model ?? RecordBean()
                
                if eventVideoModel.tags == nil || eventVideoModel.tags == "" { 
                    eventVideoModel.tags = weakSelf?.dataSourceArray?[weakSelf?.selectIndex ?? 0].tags 
                }
                if eventVideoModel.eventInfoList == nil || eventVideoModel.eventInfoList != [] {
                    eventVideoModel.eventInfoList = weakSelf?.dataSourceArray?[weakSelf?.selectIndex ?? 0].eventInfoList
                }
                if eventVideoModel.eventInfo == nil || eventVideoModel.eventInfo == "" {
                    eventVideoModel.eventInfo = weakSelf?.dataSourceArray?[weakSelf?.selectIndex ?? 0].eventInfo
                }
                if eventVideoModel.pushInfo == nil || eventVideoModel.pushInfo == "" {
                    eventVideoModel.pushInfo = weakSelf?.dataSourceArray?[weakSelf?.selectIndex ?? 0].pushInfo
                }
                if eventVideoModel.missing != nil { //资源读取
                    eventVideoModel.missing = weakSelf?.dataSourceArray?[weakSelf?.selectIndex ?? 0].missing //资源读取
                }
                if eventVideoModel.mark == nil {
                    eventVideoModel.mark = weakSelf?.dataSourceArray?[weakSelf?.selectIndex ?? 0].mark
                }
                if eventVideoModel.locationId == nil {
                    eventVideoModel.locationId = weakSelf?.dataSourceArray?[weakSelf?.selectIndex ?? 0].locationId
                }
                if eventVideoModel.adminIsVip == nil {
                    eventVideoModel.adminIsVip = weakSelf?.dataSourceArray?[weakSelf?.selectIndex ?? 0].adminIsVip
                }
                if eventVideoModel.activityZoneName == nil || eventVideoModel.activityZoneName == "" { 
                    eventVideoModel.activityZoneName = weakSelf?.dataSourceArray?[weakSelf?.selectIndex ?? 0].activityZoneName 
                }
                weakSelf?._dataSourceArray?[weakSelf?.selectIndex ?? 0] = eventVideoModel
                weakSelf?.eventDescCount = weakSelf?._dataSourceArray?[weakSelf?.selectIndex ?? 0].eventInfoList?.count ?? 0
            } else {
                //weakSelf?.mediaPlayerView.playStateChanged(state: .error(errInfo: A4xAppErrorConfig.init(code: code).message() ?? ""))
            }
        }
    }
    
    private func updateFrame() {
        self.dateLaybel?.isHidden = self.isLandscape
        self.authorityLaybel?.isHidden = self.isLandscape
        self.mediaTypeImg?.isHidden = self.isLandscape
        self.pushInfoView.isHidden = self.isLandscape
        
        self.mediaPlayer?.changeOrientation(isLandscape: self.isLandscape)
        
        self.playErrorView.frame = self.mediaPlayerView.bounds
        
        if self.isLandscape { 
            self.tableView.frame = CGRect(x: 0, y: self.mediaPlayerView.maxY, width: self.width, height: self.height)
            self.tableView.isScrollEnabled = false
            self.bringSubviewToFront(self.mediaPlayerView)
        } else { 
            let contentHeight = CGFloat(0.56) * min(UIScreen.width, UIScreen.height)
            self.tableView.frame = CGRect(x: 0, y: contentHeight, width: UIScreen.width, height: UIScreen.height - UIScreen.navBarHeight - contentHeight)
            
            self.tableView.isScrollEnabled = true
           
            
            reloadTableView()
            
            self.bringSubviewToFront(self.mediaPlayerView)
        }
    }
}




extension A4xMediaPlayScrollCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isLandscape {
            return 0
        } else {
            return dataSourceArray?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var contentHeight: CGFloat = 0
        if self.isLandscape {
            contentHeight = min(UIScreen.width, UIScreen.height)
        } else {
            return 16.auto()
        }
        return contentHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if hasImage {
            let tableCell = tableView.dequeueReusableCell(withIdentifier: "A4xMediaPlayScrollLibraryCell", for: indexPath) as? A4xMediaPlayScrollLibraryCell
            if let dataModel = dataSourceArray?[indexPath.row] { 
                tableCell?.editMode = self.editMode
                tableCell?.dataSourceModel = dataModel
                tableCell?.checked = self.selectEventResouce.contains(tableCell?.dataSourceModel?.traceId ?? "-1")
                tableCell?.resourceVideoDesTags = dataModel.videoDesTags()

                
                if self.editMode {
                    
                    tableCell?.statusPlay = .playComple
                } else {
                    if self.selectIndex == indexPath.row {
                        tableCell?.rowNum = self.eventDescCount
                        
                        if isPlaying {
                            tableCell?.statusPlay = .playeStart
                        } else {
                            tableCell?.statusPlay = .playComple
                        }
                    } else { 
                        tableCell?.statusPlay = .playComple
                    }
                }
            }
            cellHeight = tableCell?.getCellHeight() ?? 0
            return tableCell!
        } else {
            let tableCell = tableView.dequeueReusableCell(withIdentifier: "A4xMediaPlayScrollLibrarySDCell", for: indexPath) as? A4xMediaPlayScrollLibrarySDCell
            if let dataModel = dataSourceArray?[indexPath.row] { 
                tableCell?.dataSourceModel = dataModel
                tableCell?.editMode = self.editMode
                tableCell?.checked = self.selectEventResouce.contains(tableCell?.dataSourceModel?.traceId ?? "-1")

                
                if self.editMode {
                    
                    tableCell?.statusPlay = .playComple
                } else {
                    if self.selectIndex == indexPath.row {
                        
                        if isPlaying {
                            tableCell?.statusPlay = .playeStart
                        } else {
                            tableCell?.statusPlay = .playComple
                        }
                    } else { 
                        tableCell?.statusPlay = .playComple
                    }
                }
            }
            
            cellHeight = 54.auto()
            return tableCell!
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)




















            if let data = dataSourceArray?[indexPath.row] { 
                if self.editMode {
                    guard data.cID?.count ?? 0 > 0 else {
                        return
                    }
                    if (self.selectEventResouce.contains(data.traceId!)) {
                        self.selectEventResouce.remove(data.traceId!)
                    } else {
                        self.selectEventResouce.insert(data.traceId!)
                    }
                    UIView.performWithoutAnimation {
                        //关闭CALayer的隐式动画
                        CATransaction.setDisableActions(true)
                        self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                        CATransaction.commit()
                    }
                } else {
                    self.selectIndex = indexPath.row
                    isPlaying = true
                    self.reloadTableView()
                    
                    self.fetchVideoEventDetail()
                    
                    var videoURL: URL? = self.dataSourceArray?[indexPath.row].videoURL
                    if videoURL == nil && self.dataSourceArray?[indexPath.row].source != nil {
                        videoURL = URL(string: (self.dataSourceArray?[indexPath.row].source!)!)
                    }
                    self.mediaPlayer?.changeVideoUrl(url: videoURL)
                }
            }
        }

    
    
    func reloadTableView() {
        UIView.performWithoutAnimation {
            //关闭CALayer的隐式动画
            CATransaction.setDisableActions(true)
            self.tableView.reloadData()
            CATransaction.commit()
        }
    }
}



extension A4xMediaPlayScrollCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let eventStr = UserDefaults.standard.string(forKey: "selectlibrary_scrollViewDidScroll_key") ?? "0"
        if eventStr == "1" {
            let contentHeight = CGFloat(0.56) * self.width
            if scrollView == self.tableView {
                let sectionHeaderHeight = CGFloat(contentHeight)
                if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) { 
                    scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
                } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {  
                    scrollView.contentInset = UIEdgeInsets(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0)
                }
            }
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            if scrollView.contentOffset.y <= 0 {  
                var offset = scrollView.contentOffset
                offset.y = 0
                scrollView.contentOffset = offset
            }
        }
    }
    
}



extension A4xMediaPlayScrollCell: A4xMediaPlayerControllerDelegate {
    func mediaPlayerUpdateState(_ state: A4xMediaPlayerState, _ playTime: Float?, _ isCacheDone: Bool?, _ errorInfo: String?) {
        switch state {
        case .none:
            break
        case .cache:
            break
        case .playing:
            self.isPlaying = true
            self.selectStatusPlay = .playeStart 
            if playTime == 0.0  {
                self.reloadTableView()
            }
            break
        case .comple:
            self.isPlaying = false
            self.selectStatusPlay = .playComple 
            
            guard self.dataSourceArray?.count ?? 0 > (selectIndex + 1) else {
                return
            }
            if editMode { 
                return
            }
            
            let nextIndexPath = IndexPath(row: selectIndex + 1, section: 0)
            self.tableView(self.tableView, didSelectRowAt: nextIndexPath)
            self.tableView.scrollToRow(at: nextIndexPath, at: .top, animated: true)
            break
        case .pause:
            self.isPlaying = true
            self.selectStatusPlay = .playPause 
            break
        case .stop:
            self.isPlaying = false
            self.selectStatusPlay = .playStop 
            break
        case .error:
            if isFromSDCard {
                self.playErrorView.isHidden = false
            } else {
                self.reloadTableView()
            }
            break
        }
    }
}



extension A4xMediaPlayScrollCell {
    


    func selectAll() { 
        for item in self.dataSourceArray ?? []  {
            if let id = item.traceId {
                self.selectEventResouce.insert(id)
            }
        }
        self.reloadTableView()
    }
    
    func unSelectAll () { 

        self.selectEventResouce.removeAll()
        self.reloadTableView()
    }
    
    func updateTableFrame(hasBottomView: Bool) {
        let contentHeight = CGFloat(0.56) * UIScreen.width
        let bottomHeight = hasBottomView ? UIScreen.bottomBarHeight : 0
        self.tableView.frame = CGRect(x: 0, y: contentHeight, width: self.width, height: UIScreen.height - contentHeight - UIScreen.navBarHeight - bottomHeight)
    }
    
}
