//


//





import UIKit
import MJRefresh
import SmartDeviceCoreSDK
import Resolver
import A4xDeviceSettingInterface
import BindInterface
import A4xLiveVideoUIInterface
import BaseUI

public enum LivePresetEditType: Int {
    case none
    case show
    case edit
    case delete
}

public class A4xHomeLiveVideoViewController: A4xHomeLiveBaseViewController {
    
    private func collectViewReloadData(code: Int, error: String?) {
        
        guard isNavigationTopVC else {
            
            return
        }

       
            collectView.hiddNoDataView()
    
        
        self.collectView.collectionViewLayout.invalidateLayout()
        self.collectView.reloadData()
        
    }
    
    lazy var headerView: A4xHomeLiveVideoHeaderView = {
        let temp: A4xHomeLiveVideoHeaderView = A4xHomeLiveVideoHeaderView()
        temp.addCameraImage = A4xLiveUIResource.UIImage(named: "nav_add_device_right")?.rtlImage()
        temp.backgroundColor = ADTheme.C6
        
        weak var weakSelf = self

        temp.headAddCameraClickBlock = { [weak temp] in
            guard let temp = temp else {
                return
            }
            weakSelf?.showMenu()
            weakSelf?.rotateArrow(temp.addCameraView, open: true)
        }
        
        self.view.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.height.equalTo(UIScreen.newNavHeight.auto())
        }
        return temp
    }()
    
    
    lazy var collectionLayout: A4xHomeLiveVideoCollectLayout = {
        let temp = A4xHomeLiveVideoCollectLayout(delegate: self)
        return temp
    }()
    
    lazy var collectView: UICollectionView = {
        let temp = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionLayout)
        temp.dataSource = self
        temp.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10.auto(), right: 0)
        temp.delegate = self
        temp.clipsToBounds = false
        temp.backgroundColor = .clear
        temp.register(A4xHomeAPLiveCollectCell.self, forCellWithReuseIdentifier: "A4xHomeAPLiveCollectCell")
        temp.register(A4xHomeLiveVideoCollectCell.self, forCellWithReuseIdentifier: "A4xHomeLiveVideoCollectCell-0")
        temp.register(A4xHomeLiveVideoCollectCell.self, forCellWithReuseIdentifier: "A4xHomeLiveVideoCollectCell-1")
        temp.register(A4xHomeLiveVideoCollectCell.self, forCellWithReuseIdentifier: "A4xHomeLiveVideoCollectCell-2")
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints({ make in
            make.top.equalTo(self.headerView.snp.bottom)
            make.leading.equalTo(self.view.snp.leading)
            make.width.equalTo(self.view.snp.width)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        return temp
    }()
    
    
    public override func tabbarWillHidden() {
        super.tabbarWillHidden()
        
        
        self.stopLiveAll(skipDeviceId: nil, reason: A4xPlayerStopReason.changePage)
    }
    
    public override func tabbarWillShow() {
        super.tabbarWillShow()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.checkAPModeDataSourceUpload()
        
        if !(collectView.mj_header?.isRefreshing ?? true) {
            
            reloadCellTypes()
            
            collectViewReloadData(code: 0, error: nil)
        }
        
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        logDebug("-----------> viewDidLoad func")
        
        view.backgroundColor = ADTheme.C6
        collectView.isHidden = false
        headerView.isHidden = false

        initLanguageChangeNotification()

    }
    
    private func refreshList() {
        var shouldUpdateDistan = true
        
//        self.queue.async(group: self.group, execute: {
//            self.group.enter()
//            A4xBaseDeviceSettingInterface.shared.getApDeviceList { (code, error, models) in
//                self.group.leave()
//            }
//        })
        
        self.queue.async(group: self.group, execute: {
            self.group.enter()
            // 首页下拉列表刷新处理
            DeviceManageUtil.getDeviceList { (code, err, models) in
                self.group.leave()
                if code == 0 {
                    
                    models?.forEach({ (model) in
                        UserDefaults.standard.set("0", forKey: "show_error_report_\(model.serialNumber ?? "")")
                        
                        
                        self.liveVideoViewModel.loadMotionTrackStatus(deviceModel: model) { (res, updateModel) in
                        }
                        
                    })
                    
                } else {
                    DispatchQueue.main.async {
                        self.view.makeToast(err)
                    }
                }
            }
        })

        self.group.notify(queue: self.queue) {
            
            DispatchQueue.main.async {
                
                self.collectView.mj_header?.endRefreshing()
                self.stopLiveAll(skipDeviceId: nil, reason: A4xPlayerStopReason.pull)
             

                self.collectViewReloadData(code: 0, error: nil)
                
                
                self.liveVideoViewModel.updateAllScreenShot(customParam: [:]) { [weak self] deviceID in
                    if !deviceID.isBlank {
                        
                        
                        self?.reloadCellWithDeviceId(deviceID: deviceID, onlyIndex: true)
                    } else {
                        //weakSelf?.collectViewReloadData(code: code, error: err)
                    }
                }
                
                
                                
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaultVideoStyle: A4xVideoCellStyle = .default
        A4xUserDataHandle.Handle?.videoStyle = defaultVideoStyle
        DeviceLocationUtil.getAndSaveUserLocations { (code, msg, res) in }
        weak var weakSelf = self
        collectView.mj_header = A4xMJRefreshHeader {
            weakSelf?.refreshList()
        }
        if !(collectView.mj_header?.isRefreshing ?? true) {
            //reloadDataCount = 0
            collectView.mj_header?.beginRefreshing()
        }
    }
    
    private func initLanguageChangeNotification() {
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: LanguageChangeNotificationKey, object: nil, queue: OperationQueue.main) { _ in
            
            DeviceManageUtil.getDeviceList { (code, err, models) in
                // 刷新数据
                weakSelf?.collectViewReloadData(code: code, error: err)
                if code == 0 {
                    
                } else {
                    weakSelf?.view.makeToast(err)
                }
            }
        }
    }
    private func reloadCellWithDeviceId(deviceID: String, onlyIndex: Bool = false) {
        
        guard !deviceID.isEmpty else {
            return
        }
        
        var reloadindex: Int? = nil
        for index in 0..<(self.dataSource?.count ?? 0) {
            if let deviceModle = self.dataSource?[index] {
                if deviceModle.serialNumber == deviceID {
                    reloadindex = index
                }
            }
        }
        
        guard let index = reloadindex else {
            return
        }
        
        self.collectViewReloadData(code: 0, error: nil)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deviceListChange(noti: NSNotification) {
        DispatchQueue.main.async {
            self.collectView.mj_header?.beginRefreshing()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
    }
}

extension A4xHomeLiveVideoViewController {
    
    @objc func showMenu() {
        //数据源（icon可不填）
        let popData = [(icon:"nav_menu_add_device",title:A4xBaseManager.shared.getLocalString(key: "add_new_camera")),(icon:"nav_menu_add_device",title: "Add AP Carema"),
                       (icon:"nav_menu_add_friend_device",title:A4xBaseManager.shared.getLocalString(key: "join_friend_device"))]
        //设置参数
        let parameters:[A4xBasePopMenuViewConfigure] = [
            .PopMenuTextColor(UIColor.black),
            .popMenuItemHeight(53.auto()),
            .PopMenuTextFont(UIFont.regular(15))
        ]
        
        let title1Size = NSString(string: A4xBaseManager.shared.getLocalString(key: "add_new_camera")).size(withAttributes: [NSAttributedString.Key.font : UIFont.regular(15)])
        let title2Size = NSString(string: "Add AP Carema").size(withAttributes: [NSAttributedString.Key.font : UIFont.regular(15)])
        let title3Size = NSString(string: A4xBaseManager.shared.getLocalString(key: "join_friend_device")).size(withAttributes: [NSAttributedString.Key.font : UIFont.regular(15)])
        
        let menuWidth = max(title1Size.width, title2Size.width, title3Size.width) + 45 > 182 ? 195 : 182
        
        popMenu = A4xBasePopMenuView(menuWidth: CGFloat(menuWidth.auto()), arrow: CGPoint(x: headerView.addCameraView.center.x, y: headerView.addCameraView.center.y + 30), datas: popData, configures: parameters)
        
        //click
        popMenu.didSelectMenuBlock = { [weak self](index: Int) -> Void in
            print("block select \(index)")
            self?.popMenu = nil
            self?.rotateArrow((self?.headerView.addCameraView)!, open: false)
            switch index {
            case 0:
                self?.stopLiveAll(skipDeviceId: nil, reason: A4xPlayerStopReason.changePage)
                Resolver.bindImpl.pushBindViewController(isAPMode: false, bindFromType: .top_menu_add, navigationController: self?.navigationController)
                break
            case 1:
                self?.stopLiveAll(skipDeviceId: nil, reason: A4xPlayerStopReason.changePage)
                Resolver.bindImpl.pushBindViewController(isAPMode: true, bindFromType: .top_menu_add, navigationController: self?.navigationController)
                break
            case 2:
                self?.stopLiveAll(skipDeviceId: nil, reason: A4xPlayerStopReason.changePage)
                Resolver.bindImpl.pushScanQrCodeViewController(navigationController: self?.navigationController, comple: {code,msg,result in
                    
                })
                break
            default:
                break
            }
        }
        
        popMenu.clicktMenuBlock = { [weak self](dismiss: Int) -> Void in
            print("block select \(dismiss)")
            if dismiss == 1 {
                self?.rotateArrow((self?.headerView.addCameraView)!, open: false)
            }
        }
        //show
        popMenu.show()
    }
    
    
    private func rotateArrow(_ btn: UIButton, open: Bool) {
        var rotate = Double.pi * 3 / 4
        if !open {
            rotate = -Double.pi * 3 / 4
        }
        UIView.animate(withDuration: 0.3, animations: { () -> () in
            btn.transform = btn.transform.rotated(by: CGFloat(rotate))
        })
    }
}



extension A4xHomeLiveVideoViewController: A4xHomeVideoCellContentProtocol, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func getCellHeight(forRow row: Int, itemWidth: CGFloat) -> CGFloat {
        let currentCellType: A4xVideoCellType = .default
        let viewType: A4xVideoCellType = self.cellTypes.getIndex(row) ?? currentCellType
        let cellHeight = A4xHomeLiveVideoCollectCell.heightForDevice(type: viewType, itemWidth: itemWidth, deviceModel: self.dataSource?.getIndex(row))
        return cellHeight
    }
    
    func getDefaultCellType(rowIndex: Int) -> A4xVideoCellType {
        let currentCellType: A4xVideoCellType = .default
        var viewType: A4xVideoCellType = self.cellTypes.getIndex(rowIndex) ?? currentCellType
        if let deviceModle = dataSource?.getIndex(rowIndex) {
            // 首次加载 initAllLivePlayer
            if let state = self.liveVideoViewModel.getLiveState(deviceId: deviceModle.serialNumber ?? "", customParam: ["isAPMode" : deviceModle.apModeType == .AP]) {
                if state == A4xPlayerStateType.playing.rawValue {
                    if viewType == .default {
                        viewType = .playControl(isShowMore: false)
                    }
                } else {
                    viewType = .default
                }
                updateCellType(type: viewType, rowIndex: rowIndex)
            }
        }
        return viewType
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cellInfos?.count ?? 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let curSection = section
        var type: A4xHomeLiveVideoCollectCellEnum = .normalMode
        if curSection <= (cellInfos?.count ?? 0) - 1 {
            type = cellInfos?[curSection] ?? .normalMode
        }
        if type == .apMode {
            return 1
        } else {
            return (dataSource?.count ?? 0)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let curSection = indexPath.section
        var type: A4xHomeLiveVideoCollectCellEnum = .normalMode
        if curSection <= (cellInfos?.count ?? 0) - 1 {
            type = cellInfos?[curSection] ?? .normalMode
        }
        if type == .apMode {
            let cell: A4xHomeAPLiveCollectCell = collectionView.dequeueReusableCell(withReuseIdentifier: "A4xHomeAPLiveCollectCell", for: indexPath) as! A4xHomeAPLiveCollectCell
            cell.apTitleLabel?.text = A4xBaseManager.shared.getLocalString(key: "home_device_hotspot")
            return cell
        } else {
            let tag = indexPath.row % 3
            let model = dataSource?.getIndex(indexPath.row)
            let cell: A4xHomeLiveVideoCollectCell = collectionView.dequeueReusableCell(withReuseIdentifier: "A4xHomeLiveVideoCollectCell-\(tag)", for: indexPath) as! A4xHomeLiveVideoCollectCell
            if self.showImageAnimailRow == indexPath.row {
                cell.showChangeAnilmail(true)
                self.showImageAnimailRow = -1
            } else {
                cell.showChangeAnilmail(false)
            }
            
            logDebug("-----------> collectionView cell create sn: \(model?.serialNumber ?? "") row: \(indexPath.row)")
            
            cell.indexPath = indexPath
            let currentCellType: A4xVideoCellType = .default
            cell.videoStyle = cellTypes.getIndex(indexPath.row) ?? currentCellType
            cell.protocol = self
            
            
            // 竖屏运动追踪状态图标
            let isTrackingOpen = liveVideoViewModel.isTrackingOpen(deviceId: model?.serialNumber ?? "")
            
            // 是否为用户自己设备
            let isFollowAdmin = model?.isAdmin() ?? false
            
            // 预设位置信息
            let presetListData = liveVideoViewModel.presetModelBy(deviceId: model?.serialNumber ?? "")
            
            var dataDic: [String : Any] = [:]
            dataDic["isTrackingOpen"] = isTrackingOpen
            dataDic["isFollowAdmin"] = isFollowAdmin
            dataDic["presetListData"] = presetListData
            
            cell.dataDic = dataDic
            cell.dataSource = model
            
            // cell 点击事件处理
            weak var weakSelf = self
            cell.autoFollowBlock = { deviceModel, follow, comple in
                weakSelf?.deviceFllowAction(devceModel: deviceModel, enable: follow, comple: comple)
                logDebug("A4xHomeLiveVideoCollectCell autoFollowBlock device:\(deviceModel?.serialNumber ?? "") value \(follow)")
            }
            
            cell.itemliveStartBlock = { [weak self] model in
                self?.currentLiveDeviceModel = model
            }
            
            cell.presetItemActionBlock = { deviceModel, data, type, img in
                weakSelf?.presetItemAction(deviceModel: deviceModel, preset: data, type: type, image: img)
            }
            
            cell.liveStateChangeBlock = { [weak self] deviceModel, stateCode in
                if let state = A4xPlayerStateType(rawValue: stateCode) {
                    self?.liveStateChange(state: state, deviceId: deviceModel?.serialNumber ?? "")
                }
            }
            
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let curSection = indexPath.section
        var type: A4xHomeLiveVideoCollectCellEnum = .normalMode
        if curSection <= (cellInfos?.count ?? 0) - 1 {
            type = cellInfos?[curSection] ?? .normalMode
        }
        if type == .apMode {
            self.stopLiveAll(skipDeviceId: nil, reason: A4xPlayerStopReason.changePage)
            let vc = A4xHotlinkLiveVideoViewController(nav: self.navigationController)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //logDebug("-----------> A4xHomeLiveVideoCollectLayout type1: \(type)")
        //全屏切半屏后定位到切之前的位置
        if fullVideoSelIndexPath != nil {
            let tmpIndexPath = fullVideoSelIndexPath
            self.fullVideoSelIndexPath = nil
            guard self.collectView.cellForItem(at: tmpIndexPath!) != nil else {
                return
            }
            DispatchQueue.main.a4xAfter(0.3) {
                self.collectView.scrollToItem(at: tmpIndexPath ?? IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    // 更新对应index的cell的显示类型
    private func updateCellType(type: A4xVideoCellType, rowIndex: Int) {
        
        // 数量不等
        if self.cellTypes.count != self.dataSource?.count {
            reloadCellTypes()
        }
        
        guard rowIndex < cellTypes.count  else {
            return
        }
        
        if rowIndex < 0 {
            return
        }
        
        cellTypes[rowIndex] = type
    }
    
    // 根据直播状态，设置cell展示样式 - 枚举类型
    private func reloadCellTypes() {
        // 移除所有样式
        cellTypes.removeAll()
        
        let count  = self.dataSource?.count ?? 0
        guard count > 0 else {
            return
        }
        
        // 初始化cell
        self.cellInfos = A4xHomeLiveVideoCollectCellEnum.allCase()
        
        // 非四分屏
        var types = Array(repeating: A4xVideoCellType.default, count: count)
        
        for index in 0..<count {
            if let device = self.dataSource?.getIndex(index) {
                // 初始化 竖屏包含对所有直播实例的实例化
                if let state = liveVideoViewModel.getLiveState(deviceId: device.serialNumber ?? "", customParam: ["isAPMode" : device.apModeType == .AP]) {
                    if state == A4xPlayerStateType.playing.rawValue {
                        types[index] = .playControl(isShowMore: false)
                    }
                }
            }
        }
        cellTypes = types
    }

    
    private func deviceFllowAction(devceModel: DeviceBean?, enable: Bool, comple: @escaping (Bool) -> Void) {
        weak var weakSelf = self
        
        liveVideoViewModel.updateMotionTrackStatus(deviceId: devceModel?.serialNumber ?? "", enable: enable) { error in
            
            if error != nil {
                weakSelf?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "request_timeout_and_try"))
            }
            

            comple(error == nil)
        }
    }
    
    
    private func addPresetAlertLocation(deviceModel: DeviceBean?, image: UIImage?) {
        
        let (add, error) = liveVideoViewModel.canAdd(deviceId: deviceModel?.serialNumber ?? "")
        if !add {
            view.makeToast(error)
            return
        }
        
        let alert = A4xAddPresetLocationAlert(frame: CGRect.zero)
        alert.image = image
        let currKeyWindow = UIApplication.shared.keyWindow
        weak var weakSelf = self
        alert.onEditDone = { str in
            
            currKeyWindow?.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading"), completion: { _ in })
            weakSelf?.liveVideoViewModel.addPreLocationPoint(deviceModel: deviceModel, image: image, name: str, comple: { status, tips in
                currKeyWindow?.hideToastActivity()
                onMainThread {
                    if tips != "" {
                        weakSelf?.view.makeToast(tips, position: ToastPosition.bottom(offset: 50))
                    }
                }
                
                weakSelf?.collectViewReloadData(code: 0, error: nil)
            })
        }
        alert.show()
    }
    
    private func deletePresetLocaion(deviceId: String?, preset: A4xPresetModel?) {
        
        
        weak var weakSelf = self
        liveVideoViewModel.delPresetPosition(deviceId: deviceId, pointId: preset?.presetId ?? 0) {status, tips in
            if status {
                weakSelf?.collectViewReloadData(code: 0, error: nil)
            }
            weakSelf?.view.makeToast(tips)
        }
    }
    
    private func presetClickAction(deviceModel: DeviceBean?, preset: A4xPresetModel?) {
        
        weak var weakSelf = self
        liveVideoViewModel.setPreLocationPoint(deviceModel: deviceModel, preset: preset) { error in
            if let e = error {
                weakSelf?.view.makeToast(e, position: ToastPosition.bottom(offset: 50))
            }
        }
    }
    
    private func presetItemAction(deviceModel: DeviceBean?, preset: A4xPresetModel?, type: A4xDevicePresetCellType, image: UIImage?) {
        weak var weakSelf = self
        switch type {
        case .none:
            weakSelf?.presetClickAction(deviceModel: deviceModel, preset: preset)
        case .add:
            weakSelf?.addPresetAlertLocation(deviceModel: deviceModel, image: image)
        case .delete:
            weakSelf?.deletePresetLocaion(deviceId: deviceModel?.serialNumber ?? "", preset: preset)
        }
    }
    
    private func deviceAtIndex(deviceId: String?) -> (Int, DeviceBean?) {
        if let allSource = dataSource, let devid = deviceId {
            for index in 0 ..< allSource.count {
                let modle = allSource[index]
                if modle.serialNumber == devid {
                    return (index, modle)
                }
            }
        }
        
        return (-1, nil)
    }
}



extension A4xHomeLiveVideoViewController: A4xHomeLiveVideoCollectCellProtocol {
    
    
    func liveStateChange(state: A4xPlayerStateType, deviceId: String) {
        
        guard isNavigationTopVC else {
            
            return
        }

        let (index, deviceModel) = deviceAtIndex(deviceId: deviceId)
        defer {
            collectViewReloadData(code: 0, error: nil)
            if state == .playing {
                if fullVideoSelIndexPath == nil {
//                    collectView.layoutIfNeeded()
                    // 因为布局未渲染完，导致调用scrollToItem不准确。
                    // 如果在ap模式下，先延迟0.3s用于重新渲染布局
                    // 如果在nomal模式下，则不会产生此问题，所以不需要延迟渲染
                    let section = (self.cellInfos?.count ?? 1) > 1 ? 1 : 0
                    if self.cellInfos?.count ?? 0 > 1 {
                        DispatchQueue.main.a4xAfter(0.3) {
                            self.collectView.scrollToItem(at: IndexPath(row: index, section: section), at: .top, animated: true)
                        }
                    } else {
                        // 触发 A4xHomeLiveVideoCollectLayout prepare，系统还会再触发一次
                        self.collectView.scrollToItem(at: IndexPath(row: index, section: section), at: .top, animated: true)
                    }
                }
            }
        }



        var currentType = cellTypes.getIndex(index) ?? A4xVideoCellType.default
        weak var weakSelf = self
        if state == .playing {
            if currentType != .playControl(isShowMore: false) {
                currentType = .playControl(isShowMore: false)
            }
            
            
            
            liveVideoViewModel.searchAllPresetPosition(deviceModel: deviceModel) { error in
                if let e = error {
                    weakSelf?.view.makeToast(e)
                }
                
                weakSelf?.collectViewReloadData(code: 0, error: nil)
            }
            
        } else {
            if currentType != A4xVideoCellType.default {
                currentType = A4xVideoCellType.default
            }
        }

        self.updateCellType(type: currentType, rowIndex: index)
    }
    
    
    func deviceSleepToWakeUp(device: DeviceBean?) {
        
        weak var weakSelf = self
        
        UIApplication.shared.keyWindow?.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in}
        
        DeviceSleepPlanCore.getInstance().setSleep(serialNumber: device?.serialNumber ?? "", enable: false) { code, message in
            UIApplication.shared.keyWindow?.hideToastActivity()
            weakSelf?.collectView.mj_header?.beginRefreshing()
        } onError: { code, message in
            UIApplication.shared.keyWindow?.hideToastActivity()
            let msg = A4xAppErrorConfig(code: code).message()
            weakSelf?.view.makeToast(msg)
        }
    }

    
    
    func deviceSetting(device: DeviceBean?, subPage: String?) {
        
        self.stopLiveAll(skipDeviceId: nil, reason: A4xPlayerStopReason.changePage)
        Resolver.deviceSettingImpl.pushDevicesSettingViewController(deviceModel: device, fromType: .default, navigationController: navigationController)
        
        
    }
    
    
    func deviceOTAAction(device: DeviceBean?, state: String?, clickState: LiveOtaActionType?) {
        
        if clickState == .uptate {
            self.stopLiveAll(skipDeviceId: nil, reason: A4xPlayerStopReason.changePage)
            
            
        } else if clickState == .igonre {
            weak var weakSelf = self
            self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in}
            A4xBaseOTAInterface.shared.ignoreFirmwareUpdate(deviceID: device?.serialNumber ?? "") { (code, msg, res) in
                weakSelf?.view.hideToastActivity()
                if code == 0 {
                    
                    let deviceModel = device
                    deviceModel?.upgradeStatus = 19
                    weakSelf?.videoRefreshUI(device: deviceModel, isRefreshAll: false)
                } else {
                    weakSelf?.view.makeToast(msg)
                }
            }
            
        }
    }
    
    
    func videoRefreshUI(device: DeviceBean?, isRefreshAll: Bool) {
        if isRefreshAll {
            self.collectView.mj_header?.beginRefreshing()
            return
        }
        
        guard let devId = device?.serialNumber else {
            return
        }
        
        A4xUserDataHandle.Handle?.updateDevice(device: device)
        collectViewReloadData(code: 0, error: nil)
    }
    
    
    func videoControlFull(device: DeviceBean?, indexPath: IndexPath?) {
        if device == nil {
            return
        }
        self.stopLiveAll(skipDeviceId: device?.serialNumber ?? "", reason: .changePage)
        let vc = A4xFullLiveVideoViewController()
        vc.delegate = self
        vc.dataSource = device
        vc.liveVideoViewModel = liveVideoViewModel
        vc.currentIndexPath = indexPath
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //
    func deviceCellModelUpdate(device: DeviceBean?, type: A4xVideoCellType, indexPath: IndexPath?) {

        self.updateCellType(type: type, rowIndex: indexPath?.row ?? 0)
        self.collectViewReloadData(code: 0, error: nil)
    }
    
    
    func muteVoiceGoSoundSetting(deviceModel: DeviceBean?) {
        
        self.stopLiveAll(skipDeviceId: nil, reason: A4xPlayerStopReason.changePage)
        Resolver.deviceSettingImpl.pushDevicesSoundViewController(deviceModel: deviceModel ?? DeviceBean(serialNumber: deviceModel?.serialNumber ?? ""), navigationController: self.navigationController)
        
    }
    
}


extension A4xHomeLiveVideoViewController: A4xFullLiveVideoViewControllerDelegate {
    
    func didFinishViewController(controller: UIViewController, currentIndexPath: IndexPath) {
        controller.navigationController?.popViewController(animated: true)
        self.fullVideoSelIndexPath = currentIndexPath
    }
}
