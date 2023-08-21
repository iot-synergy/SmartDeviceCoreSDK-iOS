//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xHomeLibrarySectionHeaderView : UIView  {
    
    var rightClickBlock : ((Bool?) -> Void)?
    
    
    var leftClickBlock : ((Bool?, Bool?) -> Void)?
    
    private var sourcesKeys : [String]?
    
    private var sourceString : [[String]] = Array()
    
    var titleName : String? 
    
    var titleKey : String? 
    
    var isSDCardMode: Bool = false {
        didSet {
            if isSDCardMode {
                normalRightBtn.isHidden = true
                self.eventTitleLabel.textAlignment = .right
                self.normalRightBtn.snp.remakeConstraints({ (make) in
                    make.trailing.equalTo(-16.auto())
                    make.top.equalTo(2.auto())
                    make.size.equalTo(CGSizeMake(0, 0))
                })
                self.eventTitleLabel.snp.remakeConstraints { make in
                    make.leading.equalTo(self.normalLeftBtn.snp.trailing)
                    make.trailing.equalTo(-16.auto())
                    make.centerY.equalTo(self.normalLeftBtn)
                    make.height.equalTo(24.auto())
                }
            } else {
                normalRightBtn.isHidden = false
                self.eventTitleLabel.textAlignment = .center
                self.normalRightBtn.snp.remakeConstraints({ (make) in
                    make.trailing.equalTo(-16.auto())
                    make.top.equalTo(2.auto())
                    make.size.equalTo(CGSizeMake(44.auto(), 44.auto()))
                })
                self.eventTitleLabel.snp.remakeConstraints { make in
                    make.leading.equalTo(self.normalLeftBtn.snp.trailing)
                    make.trailing.equalTo(self.normalRightBtn.snp.leading)
                    make.centerY.equalTo(self.normalLeftBtn)
                    make.height.equalTo(24.auto())
                }
            }
        }
    }
    
    var editMode : Bool = false {
        didSet {
            self.collectView.isUserInteractionEnabled = !editMode
            self.collectView.alpha = self.editMode ? 0.5 : 1
            
            self.normalLeftBtn.isHidden = editMode
            self.eventTitleLabel.isHidden = editMode
            self.normalRightBtn.isHidden = editMode
            self.editLeftBtn.isHidden = !editMode
            self.editRightBtn.isHidden = !editMode
        }
    }
    
    var isSelectedAll : Bool = false
    
    private var isFilter: Bool = false
    
    var dataSource: A4xVideoLibraryFilterModel? {
        didSet {
            self.reloadData()
            self.bgView.snp.remakeConstraints { make in
                make.top.bottom.leading.trailing.equalTo(0)
            }
            DispatchQueue.main.a4xAfter(0.1) {
                self.bgView.filletedCorner(CGSize(width: 22.auto(), height: 22.auto()), UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue)))
            }
        }
    }
    
    init(frame: CGRect = .zero, editMode: Bool, isFilter: Bool) {
        self.editMode = editMode
        super.init(frame: frame)
        self.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        self.isFilter = isFilter
        self.collectView.isUserInteractionEnabled = !editMode
        self.collectView.alpha = self.editMode ? 0.5 : 1
        
        self.addSubview(self.bgView)
        self.bgView.addSubview(self.topShadowView)
        self.bgView.addSubview(self.normalLeftBtn)
        self.bgView.addSubview(self.normalRightBtn)
        self.bgView.addSubview(self.editLeftBtn)
        self.bgView.addSubview(self.editRightBtn)
        self.bgView.addSubview(self.eventTitleLabel)
        self.bgView.addSubview(self.lineView)
        self.bgView.addSubview(self.collectView)
        self.editLeftBtn.isHidden = true
        self.editRightBtn.isHidden = true
        
        self.bgView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(0)
        }
        self.topShadowView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(0)
            make.height.equalTo(20.auto())
        }
        self.normalLeftBtn.snp.makeConstraints({ (make) in
            make.leading.equalTo(16.auto())
            make.top.equalTo(2.auto())
            make.size.equalTo(CGSizeMake(44.auto(), 44.auto()))
        })
        self.normalRightBtn.snp.makeConstraints({ (make) in
            make.trailing.equalTo(-16.auto())
            make.top.equalTo(2.auto())
            make.size.equalTo(CGSizeMake(44.auto(), 44.auto()))
        })
        self.editLeftBtn.snp.makeConstraints { make in
            make.leading.equalTo(16.auto())
            make.top.equalTo(2.auto())
            make.size.equalTo(CGSize(width: (UIScreen.main.bounds.width-32)/2, height: 44.auto()))
        }
        self.editRightBtn.snp.makeConstraints { make in
            make.trailing.equalTo(self.snp.trailing).offset(0)
            make.top.equalTo(0)
            make.size.equalTo(CGSize(width: (UIScreen.main.bounds.width-32)/2, height: 44.auto()))
        }
        self.eventTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.normalLeftBtn.snp.trailing)
            make.trailing.equalTo(self.normalRightBtn.snp.leading)
            make.centerY.equalTo(self.normalLeftBtn)
            make.height.equalTo(24.auto())
        }
        self.lineView.snp.makeConstraints { (make) in
            make.top.equalTo(48.auto())
            make.leading.equalTo(16.auto())
            make.trailing.equalTo(-16.auto())
            make.height.equalTo(0.5)
        }
        self.collectView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.lineView.snp.bottom).offset(12.auto())
            make.leading.equalTo(16.auto())
            make.trailing.equalTo(-16.auto())
            make.height.equalTo(30)
        })
        
        

        DispatchQueue.main.a4xAfter(0.1) {
            self.bgView.filletedCorner(CGSize(width: 22.auto(), height: 22.auto()), UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue) | (UIRectCorner.topRight.rawValue)))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func reloadData() {
        let sources = dataSource?.onlyDisplayZonePointsources?.keys
        self.sourceString.removeAll()
        
        
        self.sourcesKeys = sources?.sorted()
        
        weak var weakSelf = self
        var device: [String] = Array()
        
        self.sourcesKeys?.forEach({ (key) in
            
            let title = weakSelf?.dataSource?.onlyDisplayZonePointsources?[key]
            if let targetTitle = title {
                
                
                let trail = "A4xFilterTagsViewController_allScreen"
                if targetTitle.contains(trail) {
                    let range = targetTitle.range(of: trail)
                    let targetString = targetTitle.replacingOccurrences(of: trail, with: ("・" + A4xBaseManager.shared.getLocalString(key: "all_screen")), range: range)
                    device.append(targetString)
                } else {
                    device.append(targetTitle)
                }
            }
        })
        
        
        self.sourceString.append(device)
        
        
        self.sourceString.append([
            A4xBaseManager.shared.getLocalString(key: "library_sign"),
            A4xBaseManager.shared.getLocalString(key: "setting_db_ring"),
            A4xBaseManager.shared.getLocalString(key: "setting_db_remove"),
            A4xBaseManager.shared.getLocalString(key: "bird"),
            A4xBaseManager.shared.getLocalString(key: "notification_detection_people"),
            A4xBaseManager.shared.getLocalString(key: "ai_pet"),
            A4xBaseManager.shared.getLocalString(key: "ai_car"),
            A4xBaseManager.shared.getLocalString(key: "vehicle_approaching"),
            A4xBaseManager.shared.getLocalString(key: "vehicle_leaving"),
            A4xBaseManager.shared.getLocalString(key: "vehicle_parked"),
            A4xBaseManager.shared.getLocalString(key: "package_down"),
            A4xBaseManager.shared.getLocalString(key: "package_up"),
            A4xBaseManager.shared.getLocalString(key: "package_detained")
        ])
        
        
        self.sourceString.append([A4xBaseManager.shared.getLocalString(key: "motion_detection"), A4xBaseManager.shared.getLocalString(key: "manual_f")])
        
        //section 3 未读、标记
        self.sourceString.append([A4xBaseManager.shared.getLocalString(key: "missed"), A4xBaseManager.shared.getLocalString(key: "mark")])
        
        self.collectView.reloadData()
    }
    
    @objc func normalLeftBtnAction() {
        if leftClickBlock != nil {
            self.leftClickBlock!(editMode, false)
        }
    }
    
    @objc func normalRightBtnAction() {
        editMode = true
        if rightClickBlock != nil {
            self.rightClickBlock!(editMode)
        }
    }
    
    @objc func editLeftBtnAction() {
        self.editLeftBtn.isSelected = !self.editLeftBtn.isSelected
        if leftClickBlock != nil {
            self.leftClickBlock!(editMode, self.editLeftBtn.isSelected)
        }
    }
    
    @objc func editRightBtnAction() {
        self.editLeftBtn.isSelected = false
        editMode = false
        if rightClickBlock != nil {
            self.rightClickBlock!(editMode)
        }
    }
    
    private lazy var collectionlayout : A4xHomeLibraryHeaderLayout = {
        let temp = A4xHomeLibraryHeaderLayout(delegate: self)
        temp.itemSize = CGSize(width: 100, height: 30)
        temp.minimumInteritemSpacing = 10
        return temp
    }()
    
    private lazy var bgView: UIView = {
        let tempView = UIView()
        tempView.backgroundColor = .white
        return tempView
    }()
    
    private lazy var topShadowView: UIView = {
        
        let layerView = UIView()
        
        let bgLayer1 = CALayer()
        bgLayer1.frame = layerView.bounds
        bgLayer1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        bgLayer1.cornerRadius = 22.auto()
        bgLayer1.masksToBounds = true
        layerView.layer.addSublayer(bgLayer1)
        
        layerView.layer.shadowColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.14).cgColor
        layerView.layer.shadowOffset = CGSize(width: 0, height: 4) 
        layerView.layer.shadowOpacity = 1
        layerView.layer.shadowRadius = 15.5 
        return layerView
    }()
    
    private lazy var normalLeftBtn: UIButton = {
        var temp : UIButton = UIButton()
        temp.setImage(bundleImageFromImageName("main_libary_filter"), for: UIControl.State.normal)
        temp.addTarget(self, action: #selector(normalLeftBtnAction), for: UIControl.Event.touchUpInside)
        temp.imageView?.contentMode = .scaleAspectFit
        return temp
    }()
    
    private lazy var normalRightBtn: UIButton = {
        var temp : UIButton = UIButton()
        temp.setImage(bundleImageFromImageName("main_libary_manager"), for: UIControl.State.normal)
        temp.imageView?.contentMode = .scaleAspectFit
        temp.addTarget(self, action: #selector(normalRightBtnAction), for: UIControl.Event.touchUpInside)
        return temp
    }()
    
    public lazy var editLeftBtn : A4xBaseNavBarButton = {
        let temp = A4xBaseNavBarButton()
        temp.contentHorizontalAlignment = .left
        temp.titleLabel?.font = ADTheme.B1
        temp.imageView?.contentMode = .scaleAspectFit
        temp.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        temp.addTarget(self, action: #selector(editLeftBtnAction), for: UIControl.Event.touchUpInside)
        
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "select_all"), for: .normal)
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "deselect_all"), for: .selected)
        temp.setTitleColor(ADTheme.Theme, for: .normal)
        temp.setTitleColor(ADTheme.Theme.withAlphaComponent(0.3), for: .disabled)
        return temp
    }()
    
    public lazy var editRightBtn : A4xBaseNavBarButton = {
        let temp = A4xBaseNavBarButton()
        temp.titleLabel?.font = ADTheme.B1
        temp.contentHorizontalAlignment = .right
        temp.imageView?.contentMode = .scaleAspectFit
        temp.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        temp.addTarget(self, action: #selector(editRightBtnAction), for: UIControl.Event.touchUpInside)
        
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "done"), for: .normal)
        temp.setTitleColor(ADTheme.Theme, for: .normal)
        return temp
    }()
    
    public lazy var eventTitleLabel: UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.B2
        temp.textColor = .hex(0x999999)
        temp.numberOfLines = 1
        temp.textAlignment = .center
        return temp
    }()
    
    private lazy var lineView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.colorFromHex("#DFDFDF")//UIColor.black.withAlphaComponent(0.4)
        return temp
    }()
    
    
    lazy var collectView: UICollectionView = {
        let temp = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionlayout)
        temp.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0.auto(), right: 0)
        temp.dataSource = self
        temp.clipsToBounds = true
        temp.delegate = self
        temp.showsHorizontalScrollIndicator = false
        temp.backgroundColor = .clear
        temp.register(A4xHomeLibraryTableHeaderCell.self, forCellWithReuseIdentifier: "A4xHomeLibraryTableHeaderCell")
        return temp
    }()
    
}


extension A4xHomeLibrarySectionHeaderView: UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout ,A4xHomeLibraryHeaderLayoutProduct{
    
    func sizeAtIndex(indexPath: IndexPath) -> CGSize {
        let title = self.sourceString[indexPath.section][indexPath.row]
        let width = title.width(font: ADTheme.B2 , wordSpace: 0) + 37.0
        if title.count < 16 {
            return CGSize(width: width, height: 30)
        } else {
            return CGSize(width: min(width, CGFLOAT_MAX), height: 30)
        }
    }
    
    func filterTagCheckShow(indexPatch: IndexPath) -> Bool {
        if indexPatch.section == 0 {
            return true
        } else if indexPatch.section == 1 {
            if indexPatch.row == 0 {
                return dataSource?.isSelect(tag: .device_call) ?? false
            } else if indexPatch.row == 1 {
                return dataSource?.isSelect(tag: .doorbell_press) ?? false
            } else if indexPatch.row == 2 {
                return dataSource?.isSelect(tag: .doorbell_remove) ?? false
            } else if indexPatch.row == 3 {
                return dataSource?.isSelect(tag: .bird) ?? false
            } else if indexPatch.row == 4 {
                return dataSource?.isSelect(tag: .person) ?? false
            } else if indexPatch.row == 5 {
                return dataSource?.isSelect(tag: .pet) ?? false
            } else if indexPatch.row == 6 {
                return dataSource?.isSelect(tag: .vehicle) ?? false
            } else if indexPatch.row == 7 {
                return dataSource?.isSelect(tag: .vehicle_enter) ?? false
            } else if indexPatch.row == 8 {
                return dataSource?.isSelect(tag: .vehicle_out) ?? false
            } else if indexPatch.row == 9 {
                return dataSource?.isSelect(tag: .vehicle_held_up) ?? false
            } else if indexPatch.row == 10 {
                return dataSource?.isSelect(tag: .package_drop_off) ?? false
            } else if indexPatch.row == 11 {
                return dataSource?.isSelect(tag: .package_pick_up) ?? false
            } else if indexPatch.row == 12 {
                return dataSource?.isSelect(tag: .package_exist) ?? false
            }
        } else if indexPatch.section == 2 {
            if indexPatch.row == 0 {
                return dataSource?.isSelect(from: .motion) ?? false
            } else if indexPatch.row == 1 {
                return dataSource?.isSelect(from: .camera) ?? false
            }
        } else if indexPatch.section == 3 {
            if indexPatch.row == 0 {
                return dataSource?.isSelect(other: .unread) ?? false
            } else if indexPatch.row == 1 {
                return dataSource?.isSelect(other: .mark) ?? false
            }
        }
        return false
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sourceString[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "A4xHomeLibraryTableHeaderCell", for: indexPath)
        
        
        if let resultCell = cell as? A4xHomeLibraryTableHeaderCell {
            
            resultCell.indexPath = indexPath
            weak var weakSelf = self
            resultCell.deleteActionBlock = { index in
                weakSelf?.deleteAction(index: indexPath)
            }
            resultCell.name = self.sourceString[indexPath.section][indexPath.row]
        }
        return cell
    }
    
    func deleteAction (index: IndexPath) {
        if index.section == 0 {
            
            
            if let titleName = self.dataSource!.onlyDisplayZonePointsources![self.sourcesKeys![index.row]] {
                self.titleName = titleName
            }
            
            weak var weakSelf = self
            
            var saveZoneIdKey = ""
            var saveZoneIdSubValue = "-1"
            
            
            self.sourcesKeys?.forEach({ (key) in
                let title = weakSelf?.dataSource?.onlyDisplayZonePointsources?[key]
                if let titleName = title {
                    if titleName == self.titleName ?? "" {
                        weakSelf?.titleKey = key
                        let idArr = weakSelf?.titleKey?.components(separatedBy: "_")
                        if (idArr?.count ?? 0) > 3 && !(idArr?[3].isBlank ?? true) {
                            saveZoneIdKey = idArr?[2] ?? ""
                            saveZoneIdSubValue = idArr?[3] ?? ""
                        } else if (idArr?.count ?? 0) > 3 && (idArr?[3].isBlank ?? true) {
                            
                            saveZoneIdKey = idArr?[2] ?? ""
                        }
                    }
                }
            })
            
            
            dataSource?.saveZonePointsources?.forEach({ (saveKey , values) in  
                if saveKey == saveZoneIdKey {
                    var array = values
                    if saveZoneIdSubValue == "-1" { 
                        self.dataSource?.saveZonePointsources?.removeValue(forKey: saveKey)
                        array.removeAll()
                    } else {
                        if array.count > 0 {
                            for (index, value) in array.enumerated() { 
                                if Int(saveZoneIdSubValue) == value {
                                    array.remove(at: index)
                                    //
                                    if array.count == 0 { 
                                        self.dataSource?.saveZonePointsources?.removeValue(forKey: saveKey)
                                        array.removeAll()
                                    } else {
                                        
                                        self.dataSource?.saveZonePointsources?[saveKey] = array
                                    }
                                }
                            }
                        } else {
                            
                            self.dataSource?.saveZonePointsources?.removeValue(forKey: saveKey)
                            array.removeAll()
                        }
                    }
                }
            })
            
            
            self.dataSource!.onlyDisplayZonePointsources![self.sourcesKeys![index.row]] = nil
            
        } else if index.section == 2 {
            if index.row == 0 {
                self.dataSource!.change_select(from: A4xSourceFrom.motion)
            } else if index.row == 1 {
                self.dataSource!.change_select(from: A4xSourceFrom.camera)
            }
        } else if index.section == 3 {
            if index.row == 0 {
                self.dataSource!.change_select(other: .unread)
            } else if index.row == 1{
                self.dataSource!.change_select(other: .mark)
            }
        } else if index.section == 1 {
            if index.row == 0 {
                self.dataSource!.change_select(tag: .device_call)
            } else if (index.row == 1) {
                self.dataSource!.change_select(tag: .doorbell_press)
            } else if (index.row == 2) {
                self.dataSource!.change_select(tag: .doorbell_remove)
            } else if index.row == 3 {
                self.dataSource!.change_select(tag: .bird)
            } else if index.row == 4 {
                self.dataSource!.change_select(tag: .person)
            } else if index.row == 5 {
                self.dataSource!.change_select(tag: .pet)
            } else if index.row == 6 {
                self.dataSource!.change_select(tag: .vehicle)
            } else if index.row == 7 {
                self.dataSource!.change_select(tag: .vehicle_enter)
            } else if index.row == 8 {
                self.dataSource!.change_select(tag: .vehicle_out)
            } else if index.row == 9 {
                self.dataSource!.change_select(tag: .vehicle_held_up)
            } else if index.row == 10 {
                self.dataSource!.change_select(tag: .package_drop_off)
            } else if index.row == 11 {
                self.dataSource!.change_select(tag: .package_pick_up)
            } else if index.row == 12 {
                self.dataSource!.change_select(tag: .package_exist)
            }
        }
        
        A4xVideoLibraryFilterModel.save(model: self.dataSource!)

    }
}

