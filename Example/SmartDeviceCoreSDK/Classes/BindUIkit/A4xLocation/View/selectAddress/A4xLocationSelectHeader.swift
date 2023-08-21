//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xLocationSelectHeader : UIView {
    
    var hotData : [A4xLocationSQLModel] = [] {
        didSet {
            if self.hotData.count > 0 {
                self.titleView.isHidden = false
                self.collectView.isHidden = false
                self.collectView.reloadData()
                bottomTitleView.snp.updateConstraints { (make) in
                    make.top.equalTo(80.auto())
                }
            }else {
                self.titleView.isHidden = true
                self.collectView.isHidden = true
                bottomTitleView.snp.updateConstraints { (make) in
                    make.top.equalTo(15.auto())
                }
            }
        }
    }
    
    var selectDBBlock : ((A4xLocationSQLModel)->Void)?
    
    var type : A4xLocationDetailType = .country {
        didSet {
            self.bottomTitleView.text = self.type.placeHoder
            self.titleView.text = A4xBaseManager.shared.getLocalString(key: "hot") + A4xBaseManager.shared.getLocalString(key: "country")
        }
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private
    lazy var titleView : UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.B2
        temp.textColor = ADTheme.C4
        temp.text = A4xBaseManager.shared.getLocalString(key: "district_country")
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(15.auto())
            make.top.equalTo(15.auto())
            make.trailing.equalTo(self.snp.trailing).offset(-15.auto())
        })
        
        return temp
    }()
    
    lazy var collectView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 50, height: 50.auto())
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let temp = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        temp.dataSource = self
        temp.clipsToBounds = true
        temp.delegate = self
        temp.showsHorizontalScrollIndicator = false
        temp.backgroundColor = UIColor.clear
        temp.register(A4xHotSelectHeaderCell.self, forCellWithReuseIdentifier: "A4xHotSelectHeaderCell")
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.titleView.snp.bottom)
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(50.auto())
        })
        return temp
    }()
    
    
    private
    lazy var bottomTitleView : UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.B2
        temp.textColor = ADTheme.C4
        temp.text = A4xBaseManager.shared.getLocalString(key: "district_country")
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(15.auto())
            make.top.equalTo(80.auto())
            make.trailing.equalTo(self.snp.trailing).offset(-15.auto())
            make.bottom.equalTo(self.snp.bottom)
        })
        
        return temp
    }()
}


extension A4xLocationSelectHeader : UICollectionViewDataSource , UICollectionViewDelegate /*, UICollectionViewDelegateFlowLayout*/ {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "A4xHotSelectHeaderCell", for: indexPath)
        if let c : A4xHotSelectHeaderCell = cell as? A4xHotSelectHeaderCell {
            c.title = hotData[indexPath.row].dbName()
        }
        return cell
    }
 
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectDBBlock?(hotData[indexPath.row])
    }
    
}


class A4xHotSelectHeaderCell : UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleView.isHidden = false
        self.bgView.isHidden = false
    }
    
    var title : String? {
        didSet {
            self.titleView.text = self.title
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private
    lazy var titleView : UILabel = {
        let temp = UILabel()
        temp.font = ADTheme.B2
        temp.textColor = ADTheme.C1
        temp.text = A4xBaseManager.shared.getLocalString(key: "district_country")
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(30.auto())
            make.trailing.equalTo(self.snp.trailing).offset(-30.auto())
            make.centerY.equalTo(self.snp.centerY)
            make.centerX.equalTo(self.snp.centerX)
        })
        
        return temp
    }()
    
    private
    lazy var bgView : UIView = {
        let temp = UIView()
        temp.layer.cornerRadius = 14.auto()
        temp.backgroundColor = UIColor.hex(0xf5f5f5)
        self.insertSubview(temp, belowSubview: self.titleView)

        temp.snp.makeConstraints({ (make) in
            make.width.equalTo(self.titleView.snp.width).offset(30.auto())
            make.centerY.equalTo(self.titleView.snp.centerY)
            make.centerX.equalTo(self.titleView.snp.centerX)
            make.height.equalTo(28.auto())
        })
        
        return temp
    }()
}
