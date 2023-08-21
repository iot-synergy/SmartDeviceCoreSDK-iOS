//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class LanguageViewController: A4xBaseViewController {

    var dataSources : [A4xBaseAppLanguageType] = []
    var selectLanguage : A4xBaseAppLanguageType = .english
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNavtion()
        self.selectLanguage = A4xBaseAppLanguageType.language()
        self.dataSources = A4xBaseAppLanguageType.allCases()
        self.tableView.isHidden = false
        self.view.backgroundColor = ADTheme.C6
    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "language")
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg =  "icon_back_gray"
        self.navView?.leftItem = leftItem
        
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
    }
    
    private lazy var tableView: UITableView = {
        let temp = UITableView()
        temp.delegate = self
        temp.backgroundColor = UIColor.clear
        temp.dataSource = self
        temp.tableFooterView = UIView()
        temp.accessibilityIdentifier = "tableView"
        temp.separatorInset = .zero
        temp.separatorColor = ADTheme.C5
        temp.estimatedRowHeight = 80;
        temp.rowHeight=UITableView.automaticDimension;
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom).offset(10.auto())
            make.width.equalTo(self.view.snp.width)
            make.leading.equalTo(0)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        
        return temp
    }()
}


extension LanguageViewController : UITableViewDelegate , UITableViewDataSource {
    func configTableView() {
        self.tableView.isHidden = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.estimatedRowHeight = 48.auto();
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.separatorColor = ADTheme.C5
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.isScrollEnabled = false
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSources.count + 1
    }
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "identifier"
        
        var tableCell : A4xLanguageViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xLanguageViewCell
        if (tableCell == nil){
            tableCell = A4xLanguageViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier);
        }
        if indexPath.row == 0 {
            tableCell?.title = A4xBaseManager.shared.getLocalString(key: "app_lang_follow_system").capitalized
            tableCell?.check = !A4xBaseAppLanguageType.isSelectedLanguage()
        } else {
            let type = self.dataSources[indexPath.row - 1]
            tableCell?.title = type.languageValue()
            if A4xBaseAppLanguageType.isSelectedLanguage() {
                tableCell?.check = type == self.selectLanguage
            } else {
                tableCell?.check = false
            }
        }
        return tableCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell: A4xLanguageViewCell = tableView.cellForRow(at: indexPath) as? A4xLanguageViewCell else {
            return
        }
        
        
        if cell.check { return }
        
        var type: A4xBaseAppLanguageType? 
        if indexPath.row == 0 {
            type = A4xBaseAppLanguageType.getSysLanguageType()
        } else {
            type = self.dataSources[indexPath.row - 1] 
        }
        self.showSwitchLanguageAlert(type: type ?? .english, indexPath: indexPath)
        
    }
    
    
    private func showSwitchLanguageAlert(type: A4xBaseAppLanguageType, indexPath: IndexPath) {
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.leftbtnBgColor = ADTheme.C7
        config.rightbtnBgColor = ADTheme.C7
        config.rightTextColor = ADTheme.Theme
        
        let alert = A4xBaseAlertView(param: config, identifier: "switch language")
        alert.title = A4xBaseManager.shared.getLocalString(key: "switch_language")
        alert.message = A4xBaseManager.shared.getLocalString(key: "switch_language_descr", param: [(indexPath.row == 0 ? A4xBaseManager.shared.getLocalString(key: "app_lang_follow_system").capitalized : type.languageValue())])
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "cancel")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "confirm")
        alert.rightButtonBlock = { [weak self] in
            self?.switchLanguage(type: type, indexPath: indexPath)
        }
        
        alert.leftButtonBlock = {
            
        }
      
        alert.show()
    }
    
    private func switchLanguage(type: A4xBaseAppLanguageType, indexPath: IndexPath) {
        
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        weak var weakSelf = self
        
        A4xBaseAccountCenterInterface.shared.updateAppLanguage(name: type) { (code, msg, res) in
            weakSelf?.view.hideToastActivity(block: {})
            if code == 0 {
                
                if indexPath.row == 0 {
                    
                    A4xBaseAppLanguageType.cleanSelectedLanguage()
                    
                } else {
                    
                    weakSelf?.selectLanguage = type
                    A4xBaseAppLanguageType.setLanguage(language: type)
                }
                
                weakSelf?.tableView.reloadData()
                UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "toast_change_language"))
                DispatchQueue.main.a4xAfter(0.1) {
                    weakSelf?.navigationController?.popViewController(animated: true)
                }
            } else {
                weakSelf?.view.makeToast(A4xAppErrorConfig(code: code).message())
                weakSelf?.tableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)  {
        cell.preservesSuperviewLayoutMargins = false
        
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
    }
}
