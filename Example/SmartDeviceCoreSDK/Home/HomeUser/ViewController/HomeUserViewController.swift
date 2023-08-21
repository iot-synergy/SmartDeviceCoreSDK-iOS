//


//


//

import UIKit
import SmartDeviceCoreSDK
import A4xLocation
import A4xDeviceSettingSDK
import Resolver
import BindUIkit
import BaseUI

class HomeUserViewController: A4xHomeBaseViewController {
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var allCases: [[A4xUserSettingEnum]]?
    
    
    var newFeedBackRecordTimer : TimeInterval? {
        didSet {
            onMainThread { [weak self] in

                if self?.isViewLoaded ?? false {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.accessibilityIdentifier = "A4xIdentifier_UserPage"
        
        self.view.backgroundColor = ADTheme.C6
        self.tableView.isHidden = false
        
        self.allCases = A4xUserSettingEnum.allCases()
        
        configTableView()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: UIScreen.width - 15.auto(), bottom: 0, right: 0) 
        self.tableView.reloadData()
                
    
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    private lazy var tableView: UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: .grouped)
        self.view.addSubview(temp)
        temp.tableFooterView = UIView()
        temp.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        temp.accessibilityIdentifier = "tableView"
        temp.separatorInset = .zero
        temp.separatorStyle = .none
        temp.showsVerticalScrollIndicator = false
        temp.register(A4xHomeUserCell.self, forCellReuseIdentifier: "A4xHomeUserCell")
        weak var weakSelf = self
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(100)
            make.trailing.equalTo(self.view.snp.trailing).offset(-15.auto())
            make.leading.equalTo(15.auto())
            make.bottom.equalTo(self.view.snp.bottom)
        })
        return temp
    }()
    
    private func userEditAction() {
        
    }
    

}


extension HomeUserViewController : UITableViewDelegate , UITableViewDataSource {

    func configTableView() {
        self.tableView.isHidden = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorStyle = .none
        self.tableView.estimatedSectionHeaderHeight = 0


        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 0.001))
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 0.001))
        
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.auto()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return allCases?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCases?[section].count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.auto()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = allCases?[indexPath.section][indexPath.row] else {
            return UITableViewCell()
        }
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "A4xHomeUserCell", for: indexPath) as? A4xHomeUserCell
        let attributes = attributesForCell(withType: type)
        
        cell?.title = attributes.title
        cell?.showPoint = attributes.showPoint
        cell?.tipAttrString = attributes.tipAttrString
        cell?.iconImage = bundleImageFromImageName(attributes.iconImageName)?.rtlImage()
        return cell ?? UITableViewCell()
    }

    
    struct CellAttributes {
        let title: String
        let showPoint: Bool
        let tipAttrString: NSAttributedString?
        let iconImageName: String
    }

    
    func attributesForCell(withType type: A4xUserSettingEnum) -> CellAttributes {
        switch type {
        case .language:
            return CellAttributes(title: type.rawValue,
                                  showPoint: false,
                                  tipAttrString: nil,
                                  iconImageName: "home_user_info_language_setting")
        case .location:
            return CellAttributes(title: type.rawValue,
                                  showPoint: false,
                                  tipAttrString: nil,
                                  iconImageName: "home_user_info_location_setting")
        case .joinDevice:
            return CellAttributes(title: type.rawValue,
                                  showPoint: false,
                                  tipAttrString: nil,
                                  iconImageName: "home_user_info_add_device")
        case .logout:
            return CellAttributes(title: type.rawValue,
                                  showPoint: false,
                                  tipAttrString: nil,
                                  iconImageName: "home_user_info_add_device")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type : A4xUserSettingEnum? = allCases?[indexPath.section][indexPath.row]
        guard let t = type else {
            return
        }
        switch t {
        case .language:
            
            let vc = LanguageViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case .location:
            let vc = A4xDeviceUpdateLocationViewController(type: .manager)
            self.navigationController?.pushViewController(vc, animated: true)
       
        case .joinDevice:
            
            
            Resolver.bindImpl.pushScanQrCodeViewController(navigationController: self.navigationController) { code, msg, result in
                
            }
        case .logout:
            SmartDeviceCore.getInstance().loginOut();
            let rootVC : AccountFirstController = AccountFirstController()
            let nav: A4xBaseAccountNavgationContoller =  A4xBaseAccountNavgationContoller(rootViewController: rootVC)
            nav.setDirectionConfig()
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.window?.rootViewController = nav
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = allCases?[indexPath.section].count ?? 0
        cell.contentView.layer.mask = nil
        let bounds =  cell.contentView.bounds
        
        var rectCorner : UIRectCorner = UIRectCorner.allCorners
        if count > 1 {
            if indexPath.row == 0 {
                rectCorner = [.topLeft,.topRight]
            }else if indexPath.row == count - 1 {
                rectCorner = [.bottomLeft,.bottomRight]
            }else {
                rectCorner = []
            }
        }
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 10.auto() , height: 10.auto() ))
        let maskLayer : CAShapeLayer = CAShapeLayer()
        maskLayer.frame = cell.contentView.bounds
        maskLayer.path = path.cgPath
        cell.contentView.layer.mask = maskLayer
        
        cell.contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.contentView.layer.shadowOpacity = 1
        cell.contentView.layer.shadowRadius = 7.5
    }
    
    
}
