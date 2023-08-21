//


//


//

import UIKit
import AssetsLibrary
import Photos
import SmartDeviceCoreSDK
import SnapKit
import Lottie
import BaseUI


enum A4xMediaSourceEventChange {
    case updateEvent(_ source: RecordEventBean?)
    case deleteEvent(_ source: RecordEventBean)
}

public class A4xLibraryDetailBaseViewController: A4xBaseViewController {
    
    private var isFromSDCard: Bool = true
    public var selectSDDeviceSN: String = ""
    
    private var dataEventSource: [RecordEventBean]? = []
    
    private var dataEventSubSource: [RecordBean]?
    
    private var needFirstLoading: Bool?
    private var showIndex: Int
    private var currentIndex: Int = 0
    private var titleStr = ""
    private var subTitleStr = ""
    
    private var videoCell: A4xMediaPlayScrollCell? 
    private var editMode: Bool = false
    
    let pageSize: Int = 200//1000
    
    var filterTagModel: A4xVideoLibraryFilterModel?
    
    var resoucesTotal: Int = 0
    
    var listTotal: Int = 0
    
    private var resoucesPage: Int = 0
    private var selectDate: Date?
    private var resourceHasMore: Bool = false
    private var resoucesModels: [RecordBean] = Array()
    
    
    
    var popViewControllerBlock: ((_ sourceEvent: [RecordEventBean], _ currentIndex: Int) ->Void )? 
    
    var souceChangeEventBlock: ((A4xMediaSourceEventChange)->Void)?
    
    var onDissmisEventBlock: ((RecordEventBean)->Void)?
    
    var souceChangeEventStarsBlock: ((_ source: RecordBean, _ sourceEvent: RecordEventBean, _ marked: Int?) ->Void )? 
    
    public init(index: Int, dataEventSource: [RecordEventBean], isFromSDCard: Bool = false, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        
        
        showIndex = index
        
        
        currentIndex = index
        //
        
        self.dataEventSource = dataEventSource
        self.isFromSDCard = isFromSDCard
        if index < dataEventSource.count {
            self.showIndex = index
        }
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var shouldAutorotate : Bool {
        return false
    }
    
    public override func loadView() {
        super.loadView()
        
        
        self.mediaScrollView?.isHidden = false
        
        self.defaultNav()
        
        self.view.clipsToBounds = true
        self.view.backgroundColor = .white
        
        self.mediaScrollView?.contentInsetAdjustmentBehavior = .automatic
    }
    
    public override func defaultNav() {
        self.navView?.lineView?.isHidden = true
        self.navView?.backgroundColor = .white
        
        
        weak var weakSelf = self
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg = "icon_back_gray"
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = { 
            weakSelf?.navView?.leftItem?.normalImg = "icon_back_gray"
            if weakSelf?.editMode ?? false {
                weakSelf?.videoCell?.tableView.reloadData()
                weakSelf?.leftCancel()
                weakSelf?.updateDownloadProgress(toBottom: true)
                
                guard let strongSelf = weakSelf else {
                    return
                }
                weakSelf?.mediaScrollView?.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(strongSelf.view.snp.bottom)
                })
            } else {
                let isL = A4xAppSettingManager.shared.orientationIsLandscape()
                if isL {
                    A4xAppSettingManager.shared.interfaceOrientations = .portrait
                } else {
                    if weakSelf?.mediaScrollView?.isLandscape ?? false  {
                        //A4xPushMsgManager.shared.setPushVideoEnable(true)
                        //A4xAppSettingManager.shared.interfaceOrientations = .portrait
                    } else {
                        weakSelf?.popViewControllerBlock?(weakSelf?.dataEventSource ?? [], weakSelf?.currentIndex ?? -1)
                        weakSelf?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        
        
        var rightItem = A4xBaseNavItem()
        rightItem.title = A4xBaseManager.shared.getLocalString(key: "choose")
        rightItem.titleColor = ADTheme.C1
        rightItem.font = UIFont.regular(16)
        self.navView?.rightBtn?.isHidden = false
        self.navView?.rightItem = rightItem
        self.navView?.rightClickBlock = {
            weakSelf?.navView?.leftItem?.normalImg = ""
            weakSelf?.mediaScrollView?.isScrollEnabled = false
            if weakSelf?.editMode ?? false {
                if (weakSelf?.navView?.rightBtn?.isSelected ?? false) {
                    weakSelf?.videoCell?.unSelectAll() 
                    weakSelf?.navView?.rightBtn?.isSelected = false
                } else {
                    weakSelf?.videoCell?.selectAll() 
                    weakSelf?.navView?.rightBtn?.isSelected = true
                }
            } else {
                weakSelf?.updateDownloadProgress(toBottom: false)
                weakSelf?.editMode = true;
                weakSelf?.editManager(flag: true)
                weakSelf?.navView?.leftItem?.title = A4xBaseManager.shared.getLocalString(key: "cancel")//"返回"
                weakSelf?.navView?.leftItem?.titleColor = ADTheme.C1
                weakSelf?.navView?.leftItem?.font = UIFont.regular(16)
                weakSelf?.navView?.lineView?.isHidden = true
                weakSelf?.navView?.backgroundColor = .white
                weakSelf?.navView?.rightItem?.title = A4xBaseManager.shared.getLocalString(key: "select_all") 
                weakSelf?.navView?.rightItem?.selectedTitle = A4xBaseManager.shared.getLocalString(key: "deselect_all")
                weakSelf?.navView?.rightItem?.titleColor = ADTheme.C1
                weakSelf?.navView?.rightItem?.font = UIFont.regular(16)
                
                UserDefaults.standard.set("1", forKey: "selectlibrary_scrollViewDidScroll_key")
                guard let strongSelf = weakSelf else {
                    return
                }
                
                weakSelf?.mediaScrollView?.snp.updateConstraints({ (make) in
                    make.bottom.equalTo(strongSelf.view.snp.bottom).offset(-UIScreen.bottomBarHeight)
                })
                
                weakSelf?.bottomView.isHidden = false
                weakSelf?.videoCell?.tableView.reloadData()
                
                weakSelf?.videoCell?.updateTableFrame(hasBottomView: true)
            }
        }
        
        updateTitle()
    }
    
    func deinitAllPlayView() {
        
        
        self.mediaScrollView?.resetAllPlayView()
        if let data = self.dataEventSource?.getIndex(self.currentIndex) {
            self.onDissmisEventBlock?(data)
        }
    }
    
    private func reloadScrollViewData() {
        
        self.mediaScrollView?.selectIndex = showIndex
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //该页面显示时可以横竖屏切换
        A4xAppSettingManager.shared.interfaceOrientations = .portrait
        
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.needFirstLoading = false
        A4xAppSettingManager.shared.delegate = nil
        self.deinitAllPlayView()
        updateDownloadProgress(toBottom: false)
    }
    
    
    func updateDownloadProgress(toBottom: Bool) {
        let bottomHeight = toBottom ? -UIScreen.safeAreaHeight : -UIScreen.bottomBarHeight;
        
        let keyWindow = UIApplication.shared.keyWindow
        if (keyWindow?.viewWithTag(100021) as? A4xDownloadProgressView) != nil {
            UIWindow.getDownloadView()?.snp.updateConstraints({ (make) in
                make.bottom.equalTo(keyWindow!.snp.bottom).offset(bottomHeight + 1.auto())
            })
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        A4xAppSettingManager.shared.delegate = self
        self.needFirstLoading = true
        
        reloadScrollViewData()
    }
    
    public override func viewDidLayoutSubviews() {
        
    }
    
    
    lazy var mediaScrollView: A4xMediaDetailScrollView? = {
        let rect = CGRect(x: 0, y: UIScreen.navBarHeight, width: self.view.width, height: self.view.height - UIScreen.navBarHeight)
        
        let temp = A4xMediaDetailScrollView(frame: rect, prot: self)
        temp.isPagingEnabled = true
        temp.showsHorizontalScrollIndicator = false
        temp.showsVerticalScrollIndicator = false
        self.view.addSubview(temp)
        self.videoCell = temp.showCell
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(UIScreen.navBarHeight)
            make.bottom.equalTo(self.view.snp.bottom)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width)
        })
        return temp
    }()
    
    
    lazy var bottomView: A4xMediaPlayerBottomView = {
        let temp = A4xMediaPlayerBottomView(items: A4xMediaPlayerItemType.default())
        if isFromSDCard {
            temp.styleItem = A4xMediaPlayerItemType.sdStyle()
            temp.updateItems()
        }
        weak var weakSelf = self
        temp.bottomSelectBlock = { type in
            weakSelf?.bottomSelectAction(type: type)
        }
        self.view.addSubview(temp)
        temp.isHidden = true
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.view.snp.bottom)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width)
            make.height.equalTo(UIScreen.bottomBarHeight)
        })
        return temp
    }()
    
    
    private func bottomSelectAction(type: A4xMediaPlayerItemType) {
        switch type {
        case .delete:
            self.deleteEventAction()
        case .share:
            self.shareResources()
        case .mark:
            self.markAction()
        case .download:
            self.downloadEvent()
        }
    }
    
}

extension A4xLibraryDetailBaseViewController {
    private func updateNavVisable(visable: Bool) {
        self.navView?.isHidden = !visable
    }
    
    private func updateBottomMarkSelect(select: Bool) {
        self.bottomView.markView.isSelected = select
    }
    
    
    private func deleteEventAction() { //事件删除
        guard self.videoCell?.dataSourceArray != nil else {
            return
        }
        guard (self.videoCell?.selectEventResouce.count ?? 0) > 0 else {
            return self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "no_item_selected"))
        }
        var deleteAllSource: [RecordBean] = []
        let dataSource = self.videoCell?.dataSourceArray ?? []
        for source in dataSource {
            if self.videoCell?.selectEventResouce.contains(source.traceId!) ?? false {
                if source.source != nil && source.source != nil {
                    deleteAllSource.append(source)
                }
            }
        }
        
        guard deleteAllSource.count > 0 else {
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "toast_del_one_is_guest")) //只有管理员能够删除此内容
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
                title = A4xBaseManager.shared.getLocalString(key: "dialog_title_del_multi", param: ["\(deleteAllSource.count)"])//(deleteAllSource.count)
                message = A4xBaseManager.shared.getLocalString(key: "dialog_message_del_multi_without_guest")
            }
        } else {
            title = A4xBaseManager.shared.getLocalString(key: "dialog_title_del_multi", param: ["\(deleteAllSource.count)"])
            message = A4xBaseManager.shared.getLocalString(key: "dialog_message_del_multi_with_guest", param: ["\(deleteAllSource.count - subSource.count)"])
        }
        
        weak var weakSelf = self
        self.showAlert(title: title, message: message, cancelTitle: A4xBaseManager.shared.getLocalString(key: "cancel"), doneTitle: A4xBaseManager.shared.getLocalString(key: "delete"), doneAction: {
            weakSelf?.deleteEventSource(sources: deleteAllSource)
        })
    }
    
    private func deleteEventSource(sources: [RecordBean]) { 
        var traceIdList: [String] = []
        sources.forEach { (adr) in
            traceIdList.append(adr.traceId ?? "-1")
        }

        weak var weakSelf = self
        //self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        LibraryCore.getInstance().deleteRecord(traceIdList: traceIdList, onSuccess: { (code, error, res) in
            weakSelf?.view.hideToastActivity()
            weakSelf?.videoCell?.isMark = true
            weakSelf?.videoCell?.dataSourceArray = weakSelf?.videoCell?.dataSourceArray?.filter({ (model) -> Bool in
                if weakSelf?.videoCell?.selectEventResouce.contains(model.traceId ?? "-1") ?? false {
                    return false
                }
                return true
            })

            weakSelf?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "delete_success"))
            if weakSelf?.videoCell?.dataSourceArray?.count == weakSelf?.videoCell?.selectEventResouce.count {
                weakSelf?.videoCell?.tableView.mj_header?.beginRefreshing()
                weakSelf?.videoCell?.isMark = false
                weakSelf?.dataEventSource?.remove(at: self.currentIndex)
            }
            
            weakSelf?.videoCell?.selectEventResouce.removeAll()
            weakSelf?.leftCancel()
            
            
            weakSelf?.mediaScrollView?.reladData(dataChange: true)
            weakSelf?.videoCell?.tableView.reloadData()
            if weakSelf?.dataEventSource?.count == 0 {
                weakSelf?.popViewControllerBlock?(weakSelf?.dataEventSource ?? [], weakSelf?.currentIndex ?? -1)
                weakSelf?.navigationController?.popViewController(animated: true)
            }
        }, onFail: { code, msg in
            weakSelf?.view.hideToastActivity()
            weakSelf?.view.makeToast(msg)
            
        })
    }
    
    
    private func downloadEvent() {
        guard self.videoCell?.dataSourceArray != nil else {
            return
        }
        guard (self.videoCell?.selectEventResouce.count ?? 0) > 0 else {
            return self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "no_item_selected"))
        }
        var downloadSrouce: [RecordBean] = []
        let dataSource = self.videoCell?.dataSourceArray ?? []
        for source in dataSource {
            if self.videoCell?.selectEventResouce.contains(source.traceId!) ?? false {
                if source.source != nil && source.traceId != nil {
                    downloadSrouce.append(source)
                }
            }
        }
        
        A4xBasePhotoManager.default().checkAuthor { (error) in
            if error == .no {
                self.leftCancel()
                let arrUrlStr = downloadSrouce.map { model in
                    return model.traceId ?? ""
                }
                
                
                UIWindow.downloadSource(models: downloadSrouce , nav: self.navigationController, haveTabBar: false)
            } else {
                A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.photo) { (f) in }
                
            }
        }
    }
    
    
    private func shareResources() {
        
        weak var weakSelf = self
        var shareSource: [RecordBean] = []
        
        guard self.videoCell?.dataSourceArray != nil else {
            return
        }
        guard (self.videoCell?.selectEventResouce.count ?? 0) > 0 else {
            return self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "no_item_selected"))
        }
        let dataSource = self.videoCell?.dataSourceArray ?? []
        for source in dataSource {
            if self.videoCell?.selectEventResouce.contains(source.traceId!) ?? false {
                if source.source != nil && source.traceId != nil {
                    shareSource.append(source)
                }
            }
        }
        
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "sharing")) { (cancel) in
        }
        
        PHPhotoLibrary.requestAuthorization({ (status) in
            switch status {
            case .notDetermined:
                break
            case .restricted://此应用程序没有被授权访问的照片数据
                break
            case .denied://用户已经明确否认了这一照片数据的应用程序访问
                break
            case .authorized://已经有权限
                //weakSelf?.downLoadView.isHidden = true
                let libraryCore = LibraryCore()
                libraryCore.downloadSource(tasks: shareSource, isShare: true) { d, t, p, describe in
                    
                } onFinish: { res, sharePathArr, shareComple in
                    DispatchQueue.main.async {
                        weakSelf?.view.hideToastActivity()
                        if res && (sharePathArr?.count ?? 0) > 0 {
                            var urlArr: [URL]? = []
                            for item in sharePathArr ?? [] {
                                urlArr?.append(URL(fileURLWithPath: "\(item)"))
                            }
                            
                            let actityController = UIActivityViewController(activityItems: urlArr ?? [], applicationActivities: nil)
                            
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                actityController.popoverPresentationController?.sourceView = self.view
                                actityController.popoverPresentationController?.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.height - 300, width: UIScreen.main.bounds.width, height: 300)
                                //actityController.presentationController.permittedArrowDirections = .any
                            }
                            weakSelf?.navigationController?.present(actityController, animated: true, completion: { })
                            
                            actityController.completionWithItemsHandler =  {(activityType, completed, returnedItems, activityError) in
                                print("completionWithItemsHandler activityType \(String(describing: activityType) )")
                                print("completionWithItemsHandler completed \(completed)")
                                print("completionWithItemsHandler activityError \(String(describing: activityError))")
                                
                                shareComple()
                            }
                        }
                    }
                }
                break
            case .limited:
                break
            }
        })
    }
    
    @objc private func closeActivity() {
        self.view.hideToastActivity()
    }


    //MARK: - 下载完成，去相册查看
    
    private func hiddenDownload(flag: Bool) {
        weak var weakSelf = self
        DispatchQueue.main.a4xAfter(5) {
            weakSelf?.leftCancel()
        }
    }
    
    //MARK: - 事件 - 标记
    private func markAction() {
        weak var weakSelf = self
        
        guard self.videoCell?.dataSourceArray != nil else {
            return
        }
        guard (self.videoCell?.selectEventResouce.count ?? 0) > 0 else {
            return self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "no_item_selected")) 
        }
        self.videoCell?.dataSourceArray?.enumerated().forEach({ (index ,element) in
            let data = element
            var isSelected: Bool = false
            if self.videoCell?.selectEventResouce.contains(data.traceId!) ?? false {
                if data.source != nil && data.traceId != nil {
                    isSelected = data.mark == 1 ? false : true
                    self.marked(dataSource: data , enable: isSelected ) { (result) in
                        if result {
                            data.mark = (isSelected) ? 1 : 0
                            if data.mark == 1 {
                                weakSelf?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "marked_success"))
                            } else {
                                weakSelf?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "marked_cancle"))
                            }
                            
                            weakSelf?.mediaScrollView?.selectIndex = weakSelf?.currentIndex ?? 0
                            
                            weakSelf?.leftCancel()
                            
                            weakSelf?.souceChangeEventStarsBlock?(data, weakSelf?.dataEventSource?[weakSelf?.currentIndex ?? 0] ?? RecordEventBean(), data.mark)
                        } else {
                            weakSelf?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "marked_fail"))
                        }
                    }
                } else {
                    isSelected = false
                }
            }
        })
    }
    
}

extension A4xLibraryDetailBaseViewController {
    
    private func onReadEven(dataSource: RecordEventBean?, comple: @escaping (Bool)->Void) {
        DispatchQueue.global().async {
            
            self.souceChangeEventBlock?(.updateEvent(dataSource))
            guard dataSource?.missing == 1 else {
                
                return
            }
            guard let userid = A4xUserDataHandle.Handle?.loginModel?.id else {
                
                comple(false)
                return
            }
            guard let sourceId = dataSource?.libraryIds else {
                
                comple(false)
                return
            }
            let libraryArray = sourceId.components(separatedBy: ",")
            weak var weakSelf = self
            LibraryCore.getInstance().setReadStatus(missing: 0, traceId: libraryArray[0]) { code, msg, res in
                if code == 0 {
                    
                    let data = dataSource
                    data?.missing = 0
                    weakSelf?.souceChangeEventBlock?(.updateEvent(data))
                    comple(true)
                } else {
                    
                    comple(false)
                }
            } onFail: { code,msg in
                comple(false)
            }
        }
    }
    
    
    private func marked(dataSource: RecordBean, enable: Bool, comple: @escaping (Bool)->Void) {
        DispatchQueue.global().async {
            guard let userid = A4xUserDataHandle.Handle?.loginModel?.id else {
                
                onMainThread {
                    comple(false)
                }
                return
            }
            guard let sourceId = dataSource.traceId else {
                
                onMainThread {
                    comple(false)
                }
                return
            }
            let marked = enable ? 1 : 0
            LibraryCore.getInstance().setMarkStatus(marked: marked, traceId: sourceId) { (code, msg, res) in
                onMainThread {
                    if code == 0 {
                        comple(true)
                    } else {
                        comple(false)
                    }
                }
            } onFail: { code,msg in 
                comple(false)
            }
        }
    }
    
}

//MARK: - Scroll 代理 - 回调（处理视频左右滑动） 凹
extension A4xLibraryDetailBaseViewController: A4xMediaBaseScrollProtocol {
    func numberOfCount() -> Int {
        return dataEventSource?.count ?? 0
    }
    
    func selectIndex(index: Int, cell: A4xMediaPlayScrollCell) {
        
        
        currentIndex = index
        self.updateNavVisable(visable: true)
        
        let data = dataEventSource?[currentIndex]

        
        self.videoCell = cell
        self.videoCell?.isFromSDCard = isFromSDCard
        self.videoCell?.hasImage = !(data?.imageUrl?.isBlank ?? true)
        self.videoCell?.retryBlock = { [weak self] in
            self?.loadEventVideoData(data)
        }
        
        
        loadEventVideoData(data)
        
    }
    
    
    func cellForIndex(index: Int) -> A4xMediaPlayScrollCell {
        let data = self.dataEventSource?[index]
        weak var weakSelf = self
        let videoCell = A4xMediaPlayScrollCell()
        videoCell.isFromSDCard = isFromSDCard
        videoCell.hasImage = !(data?.imageUrl?.isBlank ?? true)

        weak var weakCell = videoCell
        videoCell.controlBarHidden = { hi in
            if weakCell?.isLandscape ?? false {
                
                weakSelf?.updateNavVisable(visable: !hi)
            }
        }

        return videoCell
    }
    
    
    public override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
    }
}

extension A4xLibraryDetailBaseViewController: A4xAppSettingManagerProtocol {
    public func changeOrientation(orientation: UIInterfaceOrientationMask) {
        
        DispatchQueue.main.a4xAfter(0.3) {
 
            var isLandscape: Bool = false
            if orientation == .portrait {
                isLandscape = false
            } else {
                isLandscape = true
            }
            
            let navtop = isLandscape ? 0 : UIScreen.navBarHeight
            let bottonOffset = isLandscape ? 0 : -UIScreen.bottomBarHeight
            
            self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height)
            
            self.navView?.backgroundColor = isLandscape ? UIColor.clear : UIColor.white
            
            self.navView?.landscape = isLandscape
            
            var leftItem = A4xBaseNavItem()
            leftItem.normalImg = isLandscape ? "icon_back_write" : "icon_back_gray"
            leftItem.titleColor = isLandscape ? UIColor.white : ADTheme.C1
            self.navView?.leftItem = leftItem
            self.navView?.rightBtn?.isHidden = isLandscape
            if isLandscape {
                self.navView?.subtitle = self.titleStr
                self.navView?.title = ""
                                
            } else {
                self.updateTitle()
            }
            
            self.bottomView.isHidden = true
            
            if isLandscape {
                self.navView?.bgImage = bundleImageFromImageName("video_play_top_share")?.rtlImage().resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 1, bottom: 0, right: 1))
            }
            
            self.mediaScrollView?.frame = CGRect(x: 0, y: navtop, width: UIScreen.width, height: UIScreen.height - bottonOffset)
            self.mediaScrollView?.snp.remakeConstraints({ (make) in
                make.top.equalTo(navtop)
                make.bottom.equalTo(self.view.snp.bottom).offset(bottonOffset)
                make.width.equalTo(self.view.snp.width)
                make.centerX.equalTo(self.view.snp.centerX)
            })
        }
    }
    
}


extension A4xLibraryDetailBaseViewController {
    
    private func updateTitle() {
        
        if (self.dataEventSource?.count ?? 0) > currentIndex {
            titleStr = dataEventSource?[currentIndex].deviceName ?? ""
            self.navView?.title = titleStr
            let data = dataEventSource?[currentIndex]
            let is24HrFormatStr = "".timeFormatIs24Hr() ? kA4xDateFormat_24 : kA4xDateFormat_12
            
            if A4xBaseAppLanguageType.language() == .chinese || A4xBaseAppLanguageType.language() == .Japanese { 
                let languageFormat = "\(A4xUserDataHandle.Handle?.getBaseDateFormatStr() ?? A4xBaseManager.shared.getLocalString(key: "terminated_format")) \(is24HrFormatStr)"
                let dataString = DateFormatter.format(languageFormat).string(from: Date(timeIntervalSince1970: data?.startTime ?? 0))
                subTitleStr = dataString
                if self.listTotal > 1 {
                    let endLanguageFormat = "\(is24HrFormatStr)"
                    let endDataString = DateFormatter.format(endLanguageFormat).string(from: Date(timeIntervalSince1970: data?.endTime ?? 0))
                    subTitleStr = dataString + "—" + endDataString
                    self.navView?.subtitle = subTitleStr
                } else {
                    self.navView?.subtitle = subTitleStr
                }
            } else {
                let languageFormat = "\(is24HrFormatStr), \(A4xUserDataHandle.Handle?.getBaseDateFormatStr() ?? A4xBaseManager.shared.getLocalString(key: "terminated_format"))"
                let endLanguageFormat = self.listTotal > 1 ? "\(is24HrFormatStr)" : languageFormat
                
                let startDataString = DateFormatter.format(languageFormat).string(from: Date(timeIntervalSince1970: data?.startTime ?? 0))
                let endDataString = DateFormatter.format(endLanguageFormat).string(from: Date(timeIntervalSince1970: data?.endTime ?? 0))
                subTitleStr = startDataString
                if self.listTotal > 1  {
                    subTitleStr = startDataString  + "—" +  endDataString
                    self.navView?.subtitle = subTitleStr
                } else {
                    self.navView?.subtitle = subTitleStr
                }
            }
            
            self.navView?.subtitleLab?.snp.updateConstraints({ (make) in
                make.leading.equalTo(50.auto())
                make.trailing.equalTo(-50.auto())
            })
        } else {
            self.navView?.title = ""
        }
        
        
        if self.mediaScrollView?.isLandscape ?? false { 
            self.navView?.title = "" //
            self.navView?.subtitle = titleStr
        } else { 
            self.navView?.title = titleStr
            self.navView?.subtitle = subTitleStr
        }
    }

    private func leftCancel() { 
        
        
        self.mediaScrollView?.isScrollEnabled = true
        
        self.editMode = false
        self.editManager(flag: false)
        self.videoCell?.unSelectAll() 
        
        
        self.videoCell?.updateTableFrame(hasBottomView: false)
        //self.defaultNav()
        self.navView?.leftItem?.normalImg = "icon_back_gray"
        self.navView?.leftItem?.title = ""
        self.navView?.lineView?.isHidden = true
        self.navView?.backgroundColor = .white
        self.navView?.rightBtn?.isHidden = false
        self.navView?.rightItem?.title = A4xBaseManager.shared.getLocalString(key: "choose")
        self.navView?.rightItem?.selectedTitle = A4xBaseManager.shared.getLocalString(key: "choose")
        self.navView?.rightItem?.titleColor = ADTheme.C1
        self.navView?.rightItem?.font = UIFont.regular(16)
        
        updateTitle()
        
        
        UserDefaults.standard.removeObject(forKey: "selectlibrary_scrollViewDidScroll_key")
        UserDefaults.standard.synchronize()
        
        
        self.mediaScrollView?.snp.updateConstraints({ (make) in
            make.bottom.equalTo(self.view.snp.bottom)
        })

        
        self.videoCell?.snp.updateConstraints({ (make) in
            make.bottom.equalTo(self.view.snp.bottom)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalTo(self.view.snp.width)
            make.top.equalTo(self.mediaScrollView!.snp.top)
        })
     
        
        self.bottomView.isHidden = true
        
    }
    
    private func editManager(flag : Bool) {
        self.videoCell?.editMode = flag
    }
    
    private func loadEventVideoData(_ data: RecordEventBean?) { 
        
        
        self.resoucesPage = 0
        self.resoucesModels.removeAll()
        
        if self.videoCell?.tableView.mj_header?.isRefreshing ?? false {
            self.videoCell?.tableView.mj_header?.endRefreshing()
        }
        
        self.videoCell?.tableView.mj_header?.beginRefreshing()
        if !(self.mediaScrollView?.isLandscape ?? false) {
            
            self.bottomView.isHidden = true
            if self.needFirstLoading ?? false {
                self.needFirstLoading = !(self.needFirstLoading ?? false)
                self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading"), bgColor : UIColor.black.withAlphaComponent(0.5)) { (r) in }
            }
        }
        
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading"), completion: { (f) in })
        
        weak var weakSelf = self
        
        let libraryVM = A4xLibraryViewModel()
        
        let serialNumbers = isFromSDCard ? [selectSDDeviceSN] : []
        let startTimestamp = isFromSDCard ? data?.startTime : 0
        let endTimestamp = isFromSDCard ? data?.endTime: 0
        libraryVM.getEventDetail(isFromSDCard: self.isFromSDCard, serialNumbers: serialNumbers, startTimestamp: startTimestamp, endTimestamp: endTimestamp, filter: filterTagModel, videoEventKey: data?.videoEventKey ?? "") { list, total, error in
            if list != nil {
                
                weakSelf?.view.hideToastActivity()
                let list = list
                let total = total
                if let strongSelf = weakSelf {
                    strongSelf.resoucesTotal = total ?? 0
                    strongSelf.listTotal = list?.count ?? 0
                    
                    let showMax = (strongSelf.resoucesPage + 1) * strongSelf.pageSize
                    strongSelf.resourceHasMore = showMax < strongSelf.resoucesTotal
                    strongSelf.resoucesPage += 1
           
                    if list?.count ?? 0 > 0 {
                        let tmpList: [RecordBean]? = list
                        for i in 0..<(tmpList?.count ?? 0) {
                            tmpList?[i].magicPixState = data?.magicPixState
                        }
                        
                        weakSelf?.dataEventSubSource = tmpList ?? []
                        weakSelf?.videoCell?.dataSourceArray = tmpList ?? []
                        
                        weakSelf?.videoCell?.tableView.reloadData()
                        weakSelf?.videoCell?.tableView.mj_footer?.endRefreshing {}
                        
                        weakSelf?.videoCell?.isActivty = true
                        
                    }
                    weakSelf?.updateTitle()
                    
                }
            } else {
                weakSelf?.videoCell?.showNoDataView()
                weakSelf?.view.hideToastActivity()
            }
        }
    }

}

