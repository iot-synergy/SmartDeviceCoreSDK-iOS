//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xFilterTagZoneCell: UITableViewCell {
    
    private var buttonLabel = UILabel() 
    
    private var buttonImage = UIImageView() 
    
    private var selectedArray = [ZoneBean?]() 
    
    private var zonePointArray = [ZoneBean?]() 
    
    var pushRemindAreaBlock: (() -> Void)? 
    
    var isSelectAllImage: Bool = false 
    
    var filterData: A4xVideoLibraryFilterModel? {
        didSet {
            self.allChecked = filterData?.isSelectAllZoneId(deviceId: deviceModel?.serialNumber ?? "") ?? false
            //self.isSelectAllImage = !(filterData?.isSelectAllZoneId(deviceId: deviceModel?.serialNumber ?? "") ?? false)
        }
    }
    
    var filterZoneIdAddBlock: ((_ zoneName: String, _ id: Int?, _ serialNumber: String?) -> Void)? 
    
    var filterZoneIdDelBlock: ((_ zoneName: String, _ id: Int?, _ serialNumber: String?) -> Void)? //删除 - all
    
    
    var selectAllIndexPathBlock: (() -> Void)? 
    
    var selectAllIndexPathDelBlock: (() -> Void)? 
    
    var filterZoneIdsDelSubAllBlock: ((_ zoneName: String, _ id: Int? ) -> Void)? 
    
    var deviceModel: FilterTagDeviceModel? {
        didSet {
            if let data: FilterTagDeviceModel = deviceModel {
                if data.modelCategory == 1 { 
                    self.iconImageV.image = bundleImageFromImageName("filter_tag_camera_icon")?.rtlImage()
                } else { 
                    self.iconImageV.image = bundleImageFromImageName("filter_tag_doorbell_icon")?.rtlImage()
                }
                self.aNameLable.text = deviceModel?.deviceName
                guard let sernum = data.serialNumber else {
                    self.subAllButton.setBackgroundImage(nil, for: .normal)
                    return
                }
                self.subAllButton.setBackgroundImage(thumbImage(deviceID: sernum), for: .normal)
                //self.isSelectAllImage =
                if data.isBind {
                    remindButton.isHidden = false
                } else {
                    remindButton.isHidden = true
                }
            } else {
                self.iconImageV.image = bundleImageFromImageName("filter_tag_camera_icon")?.rtlImage()
                self.aNameLable.text = nil
            }
            updateMainControl()
        }
    }
    
    var allChecked: Bool = false { 
        didSet {
            self.selecteImage.isHidden = allChecked
            self.isSelectAllImage = allChecked
            if allChecked {
                self.subAllButton.layer.borderWidth = 4
                self.subAllButton.layer.borderColor = ADTheme.Theme.cgColor
                self.selecteImage.isHidden = false
            } else {
                self.subAllButton.layer.borderWidth = 0
                self.subAllButton.layer.borderColor = ADTheme.C6.cgColor
                self.selecteImage.isHidden = true
            }
        }
    }
    
    var netDeviceImagesData: [ZoneBean]? { 
        didSet {
            if netDeviceImagesData?.count ?? 0 > 0 {
                self.remindButton.isHidden = true
            } else {
                if let data: FilterTagDeviceModel = deviceModel {
                    
                    if data.isBind {
                        remindButton.isHidden = false
                    } else {
                        remindButton.isHidden = true
                    }
                }
            }
            self.collectView.reloadData()
        }
    }
    
    private lazy var iconImageV: UIImageView = {
        var temp : UIImageView = UIImageView()
        temp.image = bundleImageFromImageName("filter_tag_camera_icon")?.rtlImage()
        self.contentView.addSubview(temp)
        temp.contentMode = .center
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(16)
            make.top.equalTo(self.contentView.snp.top).offset(13.auto())
            make.size.equalTo(CGSize(width: 24, height: 24))
        })
        return temp
    }()
    
    private lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.B1
        temp.textAlignment = .left
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.iconImageV.snp.trailing).offset(15)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-15)
            make.centerY.equalTo(self.iconImageV.snp.centerY).offset(0)
        })
        return temp
    }()
    
    lazy var subAllButton: UIButton = { 
        let temp = UIButton()
        temp.layer.cornerRadius = 5.5.auto()
        temp.layer.masksToBounds = true
        temp.adjustsImageWhenHighlighted = false
        temp.addTarget(self, action: #selector(clickAllimageAction(sendr:)), for: .touchUpInside)
        temp.backgroundColor = ADTheme.C4
        
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({(make) in
            make.top.equalTo(aNameLable.snp.bottom).offset(12.5.auto())
            make.leading.equalTo(16)
            make.height.equalTo(46.auto())
            make.width.equalTo(82.auto())
        })
        return temp
    }()
    
    lazy var subAllTitleLbl: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "all_screen") //"全部区域"
        temp.textColor = ADTheme.C1
        temp.font = UIFont.regular(14)
        temp.textAlignment = .center
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(subAllButton.snp.bottom).offset(7.auto())
            make.width.equalTo(subAllButton.snp.width)
            make.height.equalTo(20)
            make.leading.equalTo(16.auto())
        })
        return temp
    }()
    
    lazy var selecteImage: UIImageView = {     
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("filter_selected_camera_icon")?.rtlImage()
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.subAllButton.snp.centerY)
            make.centerX.equalTo(self.subAllButton.snp.centerX)
        }
        return temp
    }()
    
    lazy var collectView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0.auto() //竖直方向
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0.auto(), bottom: 0, right: 10.auto())
        layout.minimumLineSpacing = 5.auto() 
        layout.itemSize = CGSize(width: 82.auto(), height: 73.auto())
        let temp = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        temp.backgroundColor = .clear
        temp.showsHorizontalScrollIndicator = false
        temp.dataSource = self
        temp.delegate = self
        temp.register(A4xFilterTagZoneSubCell.self, forCellWithReuseIdentifier: "A4xFilterTagZoneSubCell")
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(subAllButton.snp.top)
            make.leading.equalTo(self.subAllButton.snp.trailing).offset(5.auto())

            make.width.equalTo(self.contentView.snp.width).offset(-103.auto())
            make.height.equalTo(73.auto())
        })
        return temp
    }()
    
    lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.colorFromHex("#F4F4F4")
        self.contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.leading.equalTo(8.auto())
            make.trailing.equalTo(-8.auto())
            make.bottom.equalTo(-1.auto())
            make.height.equalTo(1.auto());
        }
        return view
    }()
    
    private lazy var remindButton: UIButton = {     
        let button = UIButton()
        button.titleLabel?.font = .regular(16)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(ADTheme.Theme, for: .normal)
        button.setTitleColor(ADTheme.Theme, for: .disabled)
        button.setBackgroundImage(UIImage.init(color: .white) , for: .normal)
        button.setBackgroundImage(UIImage.init(color: .white) , for: .highlighted)
        button.setBackgroundImage(UIImage.init(color: .white) , for: .disabled)
        button.layer.cornerRadius = 6.auto()
        button.layer.borderWidth = 1.5
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(remindAction), for: .touchUpInside)
        self.contentView.addSubview(button)
        button.backgroundColor = UIColor.colorFromHex("#5AC4A7")
        button.snp.makeConstraints { (make) in

            make.width.equalTo(self.contentView.snp.width).offset(-125.auto())
            make.height.equalTo(subAllButton.snp.height)
            make.top.equalTo(subAllButton.snp.top)
            make.leading.equalTo(self.subAllButton.snp.trailing).offset(16.auto())
        }
        
        let label = UILabel()
        label.textColor = ADTheme.Theme
        label.numberOfLines = 1
        label.textAlignment = .center
        button.addSubview(label)
        let btnWidth = UIScreen.width - 32.auto() - 82.auto() - 32.auto() - 10.auto()
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(button.snp.centerX).offset(-12.auto())
            make.centerY.equalTo(button.snp.centerY)
            make.width.equalTo(btnWidth)
        }
        
        
        if (deviceModel?.roleId == 1) {
            button.isEnabled = true
            button.layer.borderColor = ADTheme.Theme.cgColor
            label.textColor = ADTheme.Theme
            label.text = A4xBaseManager.shared.getLocalString(key: "set_az") //设置提醒区域
            
            var labelWidth = (label.text?.width(font: UIFont.regular(13) , wordSpace: 0) ?? 0 ) + 36.auto()
            if labelWidth >= (btnWidth - 28.auto()) {
                labelWidth = btnWidth - 28.auto()
            }
            label.snp.updateConstraints { (make) in
                make.centerX.equalTo(button.snp.centerX).offset(-12.auto())
                make.centerY.equalTo(button.snp.centerY)
                make.width.equalTo(labelWidth)
            }
        } else {
            button.isEnabled = false
            button.layer.borderColor = ADTheme.C4.cgColor
            label.textColor = ADTheme.C4
            label.text = A4xBaseManager.shared.getLocalString(key: "contact_admin_set_az") 
            label.snp.updateConstraints { (make) in
                make.centerX.equalTo(button.snp.centerX)
                make.centerY.equalTo(button.snp.centerY)
                make.width.equalTo(btnWidth)
            }
        }
        buttonLabel = label
        
        
        let view = UIImageView()
        if (deviceModel?.roleId == 1) {
            view.image = bundleImageFromImageName("add_dialog_arrow")?.rtlImage()
        } else {
            view.image = nil
        }
        button.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.leading.equalTo(label.snp.trailing).offset(7.auto())
            make.centerY.equalTo(button.snp.centerY)
            make.width.equalTo(14.auto())
            make.height.equalTo(14.auto())
        }
        buttonImage = view
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
        
        self.collectView.isHidden = false
        self.iconImageV.isHidden = false
        self.aNameLable.isHidden = false
        self.subAllButton.isHidden = false
        self.subAllTitleLbl.isHidden = false
        self.bottomLineView.isHidden = false
        
        self.contentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.leading.equalTo(16.auto())
            make.trailing.equalTo(-16.auto())
        }
        self.contentView.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func updateMainControl() {
        let btnWidth = UIScreen.width - 32.auto() - 82.auto() - 32.auto() - 10.auto()
        
        if (deviceModel?.roleId == 1) {
            self.remindButton.isEnabled = true
            self.remindButton.layer.borderColor = ADTheme.Theme.cgColor
            buttonLabel.textColor = ADTheme.Theme
            buttonLabel.text = A4xBaseManager.shared.getLocalString(key: "set_az") //设置提醒区域
            
            var labelWidth = (buttonLabel.text?.width(font: UIFont.regular(13) , wordSpace: 0) ?? 0 ) + 36.auto()
            if labelWidth >= (btnWidth - 28.auto()) {
                labelWidth = btnWidth - 28.auto()
            }
            buttonLabel.snp.updateConstraints { (make) in
                make.centerX.equalTo(remindButton.snp.centerX).offset(-12.auto())
                make.centerY.equalTo(remindButton.snp.centerY)
                make.width.equalTo(labelWidth)
            }
        } else {
            self.remindButton.isEnabled = false
            self.remindButton.layer.borderColor = ADTheme.C4.cgColor
            buttonLabel.textColor = ADTheme.C4
            buttonLabel.text = A4xBaseManager.shared.getLocalString(key: "contact_admin_set_az") 
            buttonLabel.snp.updateConstraints { (make) in
                make.centerX.equalTo(remindButton.snp.centerX)
                make.centerY.equalTo(remindButton.snp.centerY)
                make.width.equalTo(btnWidth)
            }
        }
        
        
        if (deviceModel?.roleId == 1) {
            buttonImage.image = bundleImageFromImageName("add_dialog_arrow")?.rtlImage()
        } else {
            buttonImage.image = nil
        }
        buttonImage.snp.makeConstraints { (make) in
            make.leading.equalTo(buttonLabel.snp.trailing).offset(7.auto())
            make.centerY.equalTo(remindButton.snp.centerY)
            make.width.equalTo(14.auto())
            make.height.equalTo(14.auto())
        }
        
    }
    
    
}



extension A4xFilterTagZoneCell {
    
    @objc func clickAllimageAction(sendr: UIButton) {
        sendr.isSelected = !sendr.isSelected
        if sendr.isSelected {
            subAllButton.layer.borderWidth = 4
            subAllButton.layer.borderColor = ADTheme.Theme.cgColor
            self.selecteImage.isHidden = false
            
            self.selectedArray.removeAll()
            isSelectAllImage = true
            self.collectView.reloadData()
            
            self.selectAllIndexPathBlock?() 
        } else {
            isSelectAllImage = false //取消
            subAllButton.layer.borderWidth = 0
            subAllButton.layer.borderColor = ADTheme.C6.cgColor
            self.selecteImage.isHidden = true
            
            self.selectAllIndexPathDelBlock?() 

        }
    }
    
    @objc func remindAction() { 
        self.pushRemindAreaBlock?()
    }
    
}



extension A4xFilterTagZoneCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.netDeviceImagesData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "A4xFilterTagZoneSubCell", for: indexPath)
        
        if let c: A4xFilterTagZoneSubCell = cell as? A4xFilterTagZoneSubCell {
            
            let deviceModelImage = netDeviceImagesData?[indexPath.row]
            
            c.deviceModel = deviceModelImage
            c.deviceModel = getList()?[indexPath.row]

                
                
                
                c.checked = filterData?.isSelectDisplayZoneId(deviceId: "\(indexPath.section)_\(indexPath.row)_\(deviceModel?.serialNumber ?? "")_\(deviceModelImage?.zoneId.string ?? "")") ?? false
                
                
                if isSelectAllImage == true {
                    
                    c.subAllImageView.layer.borderWidth = 0
                    c.subAllImageView.layer.borderColor = ADTheme.C6.cgColor
                    c.selecteImage.isHidden = true
                    
                    //self.filterZoneIdsDelSubAllBlock?(name, deviceModelImage?.id) 
                }

            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)as! A4xFilterTagZoneSubCell
        let model = netDeviceImagesData?[indexPath.row]
        
        var isReal: Bool = false
        var ii: Int = 0
        
        for i in 0..<self.selectedArray.count {
            if model?.zoneName == self.selectedArray[i]?.zoneName { 
                isReal = true
                ii = i
                self.selectedArray.remove(at: i)
                self.selectedArray.append(model)
            }
        }
        
        if isReal == true { 
            
            cell.subAllImageView.layer.borderWidth = 0
            cell.subAllImageView.layer.borderColor = ADTheme.C6.cgColor
            cell.selecteImage.isHidden = true
            self.selectedArray.remove(at: ii)
            
            self.filterZoneIdDelBlock?(model?.zoneName ?? "", model?.zoneId, model?.serialNumber)
            
        } else {  
            
            self.selectedArray.append(model)
            
            
            isSelectAllImage = false
            subAllButton.isSelected = false
            subAllButton.layer.borderWidth = 0
            subAllButton.layer.borderColor = ADTheme.C6.cgColor
            
            
            self.selecteImage.isHidden = true
            cell.subAllImageView.layer.borderWidth = 4
            cell.subAllImageView.layer.borderColor = ADTheme.Theme.cgColor
            cell.selecteImage.isHidden = false
            
            
            self.filterZoneIdAddBlock?(model?.zoneName ?? "" , model?.zoneId , model?.serialNumber )
            
        }
        
    }
   
}



extension A4xFilterTagZoneCell {

    func getList() -> [ZoneBean]? {
        return self.loadColorData(value: self.netDeviceImagesData)
    }
    
    private func loadColorData(value : [ZoneBean]? ) -> [ZoneBean]?  {
        guard let data = value else {
            return nil
        }
        var result : [ZoneBean] = []
        let count = min(value?.count ?? 0, 3)
        for index in 0..<count {
            var point = data[index]
            point.errPoint = point.checkFloatPointsArr(vertices: point.vertices) //index > 0 ? 1 : 0 //
            point.rectColor = A4xBaseActivityZonePointColorsValue[index]
            result.append(point)
        }
        
        
        let resPoints = result.sorted { (point1, point2) -> Bool in
            return (point1.errPoint ?? 0) < (point2.errPoint ?? 0) ? true : false
        }
        return resPoints
    }
    
}
