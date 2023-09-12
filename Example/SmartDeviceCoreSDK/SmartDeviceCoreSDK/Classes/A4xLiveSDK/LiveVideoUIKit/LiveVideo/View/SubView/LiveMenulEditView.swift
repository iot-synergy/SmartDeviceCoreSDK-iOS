//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

enum A4xMenuDetailEditType {
    case location 
}

protocol LiveMenulEditViewProtocol: class {
    func deviceLocationClose(ofView: LiveMenulEditView)
    func deviceLocationEdit(ofView: LiveMenulEditView, type: LivePresetEditType)
    func deviceLocationClick(ofView: LiveMenulEditView, location: A4xPresetModel?, type: A4xDevicePresetCellType)
}

class LiveMenulEditView: UIView {
    var videoRatio : CGFloat = 1.8
    weak var `protocol` : LiveMenulEditViewProtocol?
    var isAdmin: Bool = false
    
    var dataDic: [String: Any]? {
        didSet {
            
        }
    }
    
    var presetListData: [A4xPresetModel]? {
        didSet {
            _presetListData = presetListData
            if editEnable {
                let temp : [A4xPresetModel] = _presetListData ?? []
                if temp.count < 5 {
                    var modle = A4xPresetModel()
                    modle.presetId = -1
                    if temp.count > 0 {
                        _presetListData?.append(modle)
                    } else {
                        _presetListData?.insert(modle, at: 0)
                    }
                }
            }
            
            self.collectView.reloadData()
            if (_presetListData?.count ?? 0) > 0 || self.isAdmin {
                self.collectView.hiddNoDataView()
            } else {
                var value = A4xBaseNoDataValueModel()
                value.error = A4xBaseManager.shared.getLocalString(key: "no_position")
                value.image = A4xLiveUIResource.UIImage(named: "no_move_location")?.rtlImage()
                value.retry = false
               let nodatav = self.collectView.showNoDataView(value: value)
                nodatav?.imageMaxSize = 70
            }
     
        }
    }
    
    var _presetListData: [A4xPresetModel]?
    
    var tableViewDataSource: [A4xPresetModel] {
        return _presetListData ?? []
    }
    
    var editEnable: Bool = false {
        didSet {
            
            self.editBtn.normailTitle = A4xBaseManager.shared.getLocalString(key: "delete")
            self.editBtn.selectTitle = A4xBaseManager.shared.getLocalString(key: "done")
            self.closeBtn.normailTitle = A4xBaseManager.shared.getLocalString(key: "close")
            self.editBtn.isHidden = !editEnable
        }
    }
    
    var editModle: Bool = false {
        didSet {
            
            self.collectView.reloadData()
            editBtn.isSelected = editModle
        }
    }
    
    
    var editMenuViewType: A4xMenuDetailEditType = .location {
        didSet {
            self.editBtn.isHidden = false
            reloadCollectView()
        }
    }
    
    
    
    public init(frame: CGRect = .zero, editMenuViewType: A4xMenuDetailEditType = .location) {
        super.init(frame: frame)
        self.editBtn.isHidden = false
        self.closeBtn.isHidden = false
        self.collectView.isHidden = false
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var editBtn: A4xBaseImageTextButton = {
        let temp = A4xBaseImageTextButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_editBtn"
        temp.normailImage = A4xLiveUIResource.UIImage(named: "edit_location_delete")?.rtlImage()
        temp.selectimage = A4xLiveUIResource.UIImage(named: "edit_location_done")
        temp.normailTitle = A4xBaseManager.shared.getLocalString(key: "delete")
        temp.selectTitle = A4xBaseManager.shared.getLocalString(key: "done")
        temp.addTarget(self, action: #selector(editButtonAction(sender:)), for: .touchUpInside)
        self.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 44.auto(), height: 64.auto())).priority(.high)
            make.leading.equalTo(15.auto()).priority(.high)
            make.top.equalTo(2.auto())
        }
        
        return temp
    }()
    
    private lazy var closeBtn: A4xBaseImageTextButton = {
        let temp = A4xBaseImageTextButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_closeBtn"
        temp.normailTitle = A4xBaseManager.shared.getLocalString(key: "close")
        temp.normailImage = bundleImageFromImageName("home_device_preset_close")?.rtlImage()
        temp.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        self.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 44.auto(), height: 64.auto()))
            make.trailing.equalTo(self.snp.trailing).offset(-22.auto())
            make.top.equalTo(2.auto())
        }
        
        return temp
    }()
    
    lazy var collectView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 6.auto()
        layout.itemSize = CGSize(width: 97.auto(), height: 77.auto())
        
        let temp = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        temp.dataSource = self
        temp.delegate = self
        temp.showsHorizontalScrollIndicator = false
        temp.backgroundColor = UIColor.clear
        
        temp.register(A4xDevicePresetCell.self, forCellWithReuseIdentifier: "A4xDevicePresetCell")
        
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.editBtn.snp.bottom).offset(15.auto()).priority(.high)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-30).priority(.high)
            make.bottom.equalTo(self.snp.bottom).offset(-10)
        })
        
        return temp
    }()
    
    @objc private func reloadCollectView() {
        collectView.removeFromSuperview()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 6.auto()
        layout.itemSize = CGSize(width: 97.auto(), height: 77.auto())
        
        collectView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectView.dataSource = self
        collectView.delegate = self
        collectView.showsHorizontalScrollIndicator = false
        collectView.backgroundColor = UIColor.clear
        
        collectView.register(A4xDevicePresetCell.self, forCellWithReuseIdentifier: "A4xDevicePresetCell")
        
        self.addSubview(collectView)
        collectView.snp.remakeConstraints({ (make) in
            make.top.equalTo(self.editBtn.snp.bottom).offset(15.auto()).priority(.high)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-30).priority(.high)
            make.bottom.equalTo(self.snp.bottom).offset(-10)
        })
        
        collectView.reloadData()
    }
    
    @objc private func editButtonAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        editModle = sender.isSelected
        self.protocol?.deviceLocationEdit(ofView: self, type: editModle ? .delete : .edit)
    }
    
    @objc private func closeButtonAction() {
        editBtn.isSelected = false
        editModle = false
        self.protocol?.deviceLocationClose(ofView: self)
    }
}


extension LiveMenulEditView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "A4xDevicePresetCell", for: indexPath)
        
        let modleData = tableViewDataSource[indexPath.row]
        if let c: A4xDevicePresetCell = cell as? A4xDevicePresetCell {
            if modleData.presetId == -1 {
                c.type = .add
                c.imageUrl = nil
                c.title = A4xBaseManager.shared.getLocalString(key: "pre_position_add")
            } else {
                if editModle {
                    c.type = .delete
                } else {
                    c.type = .none
                }
                c.imageUrl = modleData.thumbnailUrl
                c.title = modleData.rotationPointName
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let modleData = tableViewDataSource[indexPath.row]
        if editModle {
            if modleData.presetId == -1  {
                self.protocol?.deviceLocationClick(ofView: self, location: nil, type: .add)
                return
            }
            _presetListData?.remove(at: indexPath.row)
            self.collectView.deleteItems(at: [indexPath])
            self.protocol?.deviceLocationClick(ofView: self, location: modleData, type: .delete)
        } else {
            if modleData.presetId == -1 {
                self.protocol?.deviceLocationClick(ofView: self, location: nil, type: .add)
            } else {
                self.protocol?.deviceLocationClick(ofView: self, location: modleData, type: .none)
            }
        }
        
    }
    
}
