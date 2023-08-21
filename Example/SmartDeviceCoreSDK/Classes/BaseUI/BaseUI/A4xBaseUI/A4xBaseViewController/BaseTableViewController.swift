//

import Foundation


open class BaseTableViewController: BaseNavViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isHidden = false
    }
    public lazy var tableView: UITableView = {
        let temp = UITableView()
        temp.backgroundColor = UIColor.clear
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
