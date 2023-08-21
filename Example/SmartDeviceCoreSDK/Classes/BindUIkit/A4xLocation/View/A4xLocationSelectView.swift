//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xLocationSelectView : UIView  , A4xBaseAlertViewProtocol {
    var config: A4xBaseAlertConfig
    var selectAddressDone : ((A4xDeviceLocationModel) -> Void)?
    
    var onHiddenBlock: ((@escaping () -> Void) -> Void)?
    
    var identifier: String
    var awidth : CGFloat = 0
    let paddingvertical : CGFloat = 15.auto()
    var addressModle : A4xDeviceLocationModel
    
    var dataSources : (results : [(String , [A4xLocationSQLModel])] , hot : [A4xLocationSQLModel]) {
        set {
            addressModle.country = self.selectInfos.country?.dbName()
            addressModle.state = self.selectInfos.country?.code
            addressModle.city = self.selectInfos.city?.dbName()
            addressModle.state = self.selectInfos.region?.dbName()
            addressModle.district = self.selectInfos.district?.dbName()
            if newValue.results.count == 0 {
                self.selectAddressDone?(addressModle)
                onHiddenBlock?{}
                return
            }

            self.dataLists = newValue.results
            self.hotlist = newValue.hot
            self.headerView.type = self.selectInfos.currentIndex
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint(x: 0, y: 1), animated: false)
            if let selectData = self.selectInfos.currentDB {
                var indexPath : IndexPath?
                for session in (0..<(self.dataLists.count)) {
                    if indexPath != nil {
                        break
                    }
                    let (_ , dbs) = self.dataLists[session]
                    for row in (0..<(dbs.count)) {
                        let db = dbs[row]
                        if db.id == selectData.id {
                            indexPath = IndexPath(row: row, section: session)
                        }
                    }
                    
                }
                if let index = indexPath {
                    self.tableView.scrollToRow(at: index, at: .top, animated: false)
                }
            }
            self.collectView.reloadData()
            self.collectView.selectItem(at: IndexPath(row: self.selectInfos.currentIndex.rawValue, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition())
            
        }
        get {
            return ([],[])
        }
    }
    var hotlist : [A4xLocationSQLModel] = [] {
        didSet {
            self.headerView.hotData = self.hotlist
        }
    }
    var dataLists : [(String , [A4xLocationSQLModel])] = []
    
    var selectInfos : A4xAddressInfoModel = A4xAddressInfoModel()
    
    public init(frame: CGRect = CGRect.zero , Address address : A4xDeviceLocationModel? ) {
        self.config = A4xBaseAlertConfig()
        self.config.outBoundsHidden = true
        self.config.type = .sheet
        self.identifier = "A4xLocationSelectView"
        self.addressModle = address ?? A4xDeviceLocationModel()
        awidth = (UIApplication.shared.keyWindow?.width ?? 375)
        super.init(frame: frame)
        
        self.setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    private func setUpView() {
        self.bgView.isHidden                = false
        
        let height : CGFloat = 480.0.auto()
        
        
        self.titleView.isHidden = false
        self.closeButton.isHidden = false
        self.collectView.isHidden = false
        self.headerView.isHidden = false
        self.tableView.isHidden = false
        
        self.dataSources = self.selectInfos.parseAddressModle(addModle: &self.addressModle)

        self.bgView.frame = CGRect(x: 0, y: 0, width: awidth, height: height + UIScreen.safeAreaHeight )
        self.frame = CGRect(x: 0, y: 0, width: awidth, height: height + UIScreen.safeAreaHeight )
    }

    lazy var headerView : A4xLocationSelectHeader = {
        let temp = A4xLocationSelectHeader()
        self.addSubview(temp)
        weak var weakSelf = self
        temp.selectDBBlock = {db in
            if let strongSelf = weakSelf {
                strongSelf.dataSources = strongSelf.selectInfos.selectDBModle(db: db)
            }
        }
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.collectView.snp.bottom).offset(2)
            make.leading.equalTo(0)
            make.width.equalTo(self.snp.width)
        })
        return temp
    }()
    
    lazy var tableView : UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        temp.delegate = self
        temp.dataSource = self
        temp.separatorStyle = .none
        temp.backgroundColor = UIColor.clear
        temp.sectionIndexColor = ADTheme.Theme
        temp.estimatedRowHeight = 0;
        temp.estimatedSectionHeaderHeight = 0;
        temp.estimatedSectionFooterHeight = 0;
        self.insertSubview(temp, belowSubview: self.headerView)
       
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.headerView.snp.bottom).offset(5.auto())
            make.bottom.equalTo(self.snp.bottom)
            make.leading.equalTo(0)
            make.width.equalTo(self.snp.width)
        })
        return temp
    }()
    
    private
    lazy var titleView : UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.H2
        temp.textColor = ADTheme.C1
        temp.text = A4xBaseManager.shared.getLocalString(key: "location_selection")
        self.bgView.addSubview(temp)

        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(15.auto())
            make.centerX.equalTo(self.bgView.snp.centerX)
        })
        
        return temp
    }()
    
    private
    lazy var closeButton : UIButton = {
        let temp = UIButton()
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "save"), for: .normal)
        temp.setTitleColor(ADTheme.Theme, for: .normal)
        temp.titleLabel?.font = ADTheme.B2

        temp.addTarget(self, action: #selector(closeAlertAction), for: .touchUpInside)
        self.bgView.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.titleView.snp.centerY)
            make.trailing.equalTo(self.bgView.snp.trailing)
            make.size.equalTo(CGSize(width: 56.auto(), height: 56.auto()))
            
        })
        
        return temp
    }()
    
    private
    lazy var bgView : UIView = {
        let temp = UIView()
        temp.layer.cornerRadius = 5
        temp.layer.backgroundColor = UIColor.white.cgColor
        self.insertSubview(temp, at: 0)
        return temp;
    }()
    
    
    lazy var collectView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 150, height: 50.auto())
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1

        let temp = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        temp.dataSource = self
        temp.clipsToBounds = true
        temp.delegate = self
        temp.showsHorizontalScrollIndicator = false
        temp.backgroundColor = UIColor.clear
        temp.register(A4xLocationSelectCell.self, forCellWithReuseIdentifier: "A4xLocationSelectCell")
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.titleView.snp.bottom).offset(20)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(50.auto())
        })
        
        
        let line = UIView()
        line.backgroundColor = ADTheme.C5
        self.addSubview(line)
        
        line.snp.makeConstraints({ (make) in
            make.top.equalTo(temp.snp.bottom)
            make.width.equalTo(temp.snp.width).offset(-32.auto())
            make.height.equalTo(1)
            make.centerX.equalTo(temp.snp.centerX)
        })
        
        return temp
    }()
    
    @objc private
    func closeAlertAction(){
        self.selectAddressDone?(addressModle)
        self.onHiddenBlock? {}
    }
}


extension A4xLocationSelectView : UICollectionViewDataSource , UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return A4xLocationSelectType.allCase(of: self.selectInfos).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "A4xLocationSelectCell", for: indexPath)
        if let c : A4xLocationSelectCell = cell as? A4xLocationSelectCell {
            let info = A4xLocationSelectType.allCase(of: self.selectInfos)[indexPath.row].titleInfo
            c.title = (info.title , info.isPlaceHoder)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dataSources = self.selectInfos.selectIndex(index: A4xLocationDetailType(rawValue: indexPath.row) ?? .country)
    }
    
}


extension A4xLocationSelectView : UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataLists.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_ , list) = dataLists[section]
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "identifier"
        var cell : A4xLocationPlaceCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xLocationPlaceCell
        
        if cell == nil {
            cell = A4xLocationPlaceCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
            cell?.selectionStyle = .none
           
        }
        let (_ , lists) = dataLists[indexPath.section]
        let dbModle = lists[indexPath.row]
        cell?.title = dbModle.dbName()
       
        if let imageName = dbModle.imageName() {
            cell?.cimage = bundleImageFromImageName(imageName)?.rtlImage()
        }else {
            cell?.cimage = nil
        }
        
        cell?.checked = (dbModle.id == self.selectInfos.currentDB?.id ?? -1)
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (_ , lists) = dataLists[indexPath.section]
        let dbModle = lists[indexPath.row]
        self.dataSources = self.selectInfos.selectDBModle(db: dbModle)
    }
}
