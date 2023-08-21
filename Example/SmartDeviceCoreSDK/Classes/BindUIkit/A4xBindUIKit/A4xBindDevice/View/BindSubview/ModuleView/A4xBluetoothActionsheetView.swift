//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public class A4xBluetoothActionsheetView: A4xBaseBluetoothActionsheetView {

    public var bluetoothTable: UITableView?
    
    public var dataSource: [[BindDeviceModel]]? = []
    
    var cellHeight: CGFloat = 94.5.auto()
    
    public var devicesCellSelectBlock: ((BindDeviceModel?)->Void)?
    
    public override func addNewSubview(_ view: UIView) {
        
        
        let titleLbl = UILabel()
        titleLbl.textAlignment = .left
        titleLbl.numberOfLines = 0
        titleLbl.text = A4xBaseManager.shared.getLocalString(key: "bt_new_device_pop")
        titleLbl.textColor = ADTheme.C1
        titleLbl.font = UIFont.heavy(21.auto())
        view.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { (make) in
            make.top.equalTo(UIScreen.barNewHeight)
            make.leading.equalTo(24.auto())
            make.width.equalTo(view.snp.width).offset(-64.auto())
        }
        
        
        bluetoothTable = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        if #available(iOS 11.0, *) {
            bluetoothTable?.contentInsetAdjustmentBehavior = .never
        }
        bluetoothTable?.dataSource = self
        bluetoothTable?.delegate = self
        bluetoothTable?.isScrollEnabled = true
        bluetoothTable?.tableFooterView = UIView()
        bluetoothTable?.backgroundColor = .white
        bluetoothTable?.accessibilityIdentifier = "tableView"
        bluetoothTable?.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        bluetoothTable?.showsVerticalScrollIndicator = false
        bluetoothTable?.separatorColor = UIColor.clear
        bluetoothTable?.estimatedRowHeight = 60
        bluetoothTable?.sectionHeaderHeight = UITableView.automaticDimension
        bluetoothTable?.rowHeight = UITableView.automaticDimension
        view.addSubview(bluetoothTable ?? UITableView())
        let isMore = (dataSource?.count ?? 0) > 1 ? true : false
        let height = isMore ? 175.5.auto() : cellHeight + 20.auto()
        bluetoothTable?.snp.makeConstraints { (make) in
            make.top.equalTo(titleLbl.snp.bottom).offset(16.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(view.snp.width).offset(-32.auto())
            make.height.equalTo(height)
        }
    }
    
    
    public override func updateUI() {
        
        self.contenView? = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.width, height: self.contenHeight ?? 254.auto()))
        
        let isMore = (dataSource?.count ?? 0) > 1 ? true : false
        let height = isMore ? 175.5.auto() : (cellHeight + 20.auto())
        bluetoothTable?.snp.updateConstraints() { (make) in
            make.height.equalTo(height)
        }
        
        self.contenView?.backgroundColor = .white
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: CGFloat(0.8), initialSpringVelocity: CGFloat(0.5), options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.alpha = 1.0
            self.contenView?.y = 0
        }, completion: {  _ in
            self.updateSubUI(self.contenView!)
            let indexPath = IndexPath(row: 0, section: (self.dataSource?.count ?? 1) - 1)
            self.bluetoothTable?.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        })
    }

}

extension A4xBluetoothActionsheetView: UITableViewDelegate, UITableViewDataSource, A4xBindFindDeviceViewCellProtocol {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?[section].count ?? 0
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "A4xBindFindDeviceViewCell"
        var tableCell: A4xBindFindDeviceViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xBindFindDeviceViewCell
        if (tableCell == nil) {
            tableCell = A4xBindFindDeviceViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        tableCell?.model = (self.dataSource?[indexPath.section][indexPath.row], 24.auto())
        cellHeight = tableCell?.getCellHeight() ?? 94.5.auto()
        tableCell?.protocol = self
        return tableCell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataSource?[indexPath.section][indexPath.row]
        self.devicesCellSelectBlock?(model)
        self.hiddenView()
    }
    
    public func cellClickAction(model: BindDeviceModel) {
        self.devicesCellSelectBlock?(model)
        self.hiddenView()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
        cell.clipsToBounds = true
        
        let count = self.bluetoothTable?.numberOfRows(inSection: indexPath.section) ?? 0
        if indexPath.row == count {
            cell.contentView.layer.mask = nil
            return
        }
        
        let bounds = cell.contentView.bounds
        
        var rectCorner: UIRectCorner = UIRectCorner.allCorners
        if count > 1 {
            if indexPath.row == 0 {
                rectCorner = [.topLeft, .topRight]
            } else if indexPath.row == count - 1 {
                rectCorner = [.bottomLeft, .bottomRight]
            } else {
                rectCorner = []
            }
        } else {
            rectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        }
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 10.auto(), height: 10.auto()))
        
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = cell.contentView.bounds
        maskLayer.path = path.cgPath
        cell.contentView.layer.mask = maskLayer
        
        cell.contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.contentView.layer.shadowOpacity = 1
        cell.contentView.layer.shadowRadius = 7.5
    }
}
