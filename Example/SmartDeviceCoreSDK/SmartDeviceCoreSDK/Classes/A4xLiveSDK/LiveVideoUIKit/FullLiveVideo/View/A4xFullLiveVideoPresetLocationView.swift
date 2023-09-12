//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xFullLiveVideoPresetLocationView : UIButton {
    var videoRatio : CGFloat = 1.8
    var isAdmin : Bool = false
    
    var presetListData : [A4xPresetModel]?{
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
                self.collectView.showNoDataView(value: value)
            }
        }
    }
    var _presetListData : [A4xPresetModel]?
    
    var tableViewDataSource : [A4xPresetModel] {







        return _presetListData ?? []
    }
    
    
    var itemActionBlock : ((A4xPresetModel? , A4xFullLiveVideoPresetCellType)->Void)?
    
    var colseVideoBlock : (()->Void)?
    var editModleBlock : ((LivePresetEditType)->Void)?
    
    var editEnable : Bool = true {
        didSet {
            self.editBtn.isHidden = !editEnable
        }
    }
    
    var editModle : Bool = false {
        didSet {
            self.collectView.reloadData()
        }
    }
    
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.editBtn.isHidden = false
        self.backBtn.isHidden = false
        self.collectView.isHidden = false
        self.backgroundColor = UIColor.hex(0x1D1C1C, alpha: 0.8)
        self.addTarget(self, action: #selector(emtry), for: UIControl.Event.touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func emtry(){
        
    }
    
    private lazy
    var backBtn : UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_backBtn"
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "close"), for: UIControl.State.normal)
        temp.setTitleColor(UIColor.white, for: .normal)
        temp.titleLabel?.font = ADTheme.B2
        temp.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        self.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 44.auto(), height: 44.auto()))
            make.leading.equalTo(10.auto())
            make.top.equalTo(12.auto())
        }
        
        return temp
    }()
    
    private lazy
    var editBtn : UIButton = {
        let temp = UIButton()
        temp.accessibilityIdentifier = "A4xLiveUIKit_editBtn"
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "delete"), for: UIControl.State.normal)
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "done"), for: UIControl.State.selected)
        temp.setTitleColor(UIColor.white, for: .normal)
        temp.titleLabel?.font = ADTheme.B2
        temp.addTarget(self, action: #selector(editButtonAction(sender:)), for: .touchUpInside)
        self.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 44.auto(), height: 44.auto()))
            make.trailing.equalTo(self.snp.trailing).offset(-10.auto())
            make.top.equalTo(12.auto())
        }
        
        return temp
    }()
    
    lazy var collectView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 10.auto()
        layout.itemSize = CGSize(width: 122.auto(), height: 68.auto())
        
        let temp = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        temp.dataSource = self
        temp.delegate = self
        temp.showsHorizontalScrollIndicator = false
        temp.backgroundColor = UIColor.clear
        
        
        temp.register(A4xFullLiveVideoPresetCell.self, forCellWithReuseIdentifier: "A4xFullLiveVideoPresetCell")
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.editBtn.snp.bottom)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-30)
            make.bottom.equalTo(self.snp.bottom).offset(-5)
        })
        
        return temp
    }()
    
    @objc private
    func editButtonAction(sender : UIButton){
        sender.isSelected = !sender.isSelected
        DispatchQueue.main.a4xAfter(0) {
            self.editModle = sender.isSelected
            self.editModleBlock?(self.editModle ? .delete : .edit)
        }
        
    }
    
    @objc private
    func closeButtonAction(){
        editBtn.isSelected = false
        editModle = false
        self.colseVideoBlock?()
    }
}


extension A4xFullLiveVideoPresetLocationView : UICollectionViewDataSource , UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableViewDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "A4xFullLiveVideoPresetCell", for: indexPath)
        let modleData = tableViewDataSource[indexPath.row]
        
        if let c : A4xFullLiveVideoPresetCell = cell as? A4xFullLiveVideoPresetCell {
            if modleData.presetId == -1 {
                c.type = .add
                c.imageUrl = nil
                c.title = A4xBaseManager.shared.getLocalString(key: "pre_position_add")
            }else {
                if editModle {
                    c.type = .delete
                }else {
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
        
        if modleData.presetId == -1 {
            self.itemActionBlock?(nil , .add)
        }else {
            if editModle {
                //_presetListData?.remove(at: indexPath.row - 1)
                _presetListData?.remove(at: indexPath.row)
                self.collectView.deleteItems(at: [indexPath])
                self.itemActionBlock?(modleData ,.delete )
            }else {
                self.itemActionBlock?(modleData ,  .none)
            }
        }
    }
}
