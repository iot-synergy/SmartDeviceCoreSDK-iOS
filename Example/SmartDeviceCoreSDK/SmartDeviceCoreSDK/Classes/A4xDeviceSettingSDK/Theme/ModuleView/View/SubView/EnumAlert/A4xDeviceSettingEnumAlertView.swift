//


//


//

import UIKit
import SmartDeviceCoreSDK

@objc public protocol A4xDeviceSettingEnumAlertViewDelegate : AnyObject {
    
    func A4xDeviceSettingEnumAlertViewCellDidClick(currentType: A4xDeviceSettingCurrentType, enumModel: A4xDeviceSettingEnumAlertModel)
    
}

public class A4xDeviceSettingEnumAlertView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate : A4xDeviceSettingEnumAlertViewDelegate?
    
    
    public var allCases: [A4xDeviceSettingEnumAlertModel]?
    public var currentType: A4xDeviceSettingCurrentType?
    
    let maxTableHeight : Int = 300.auto()
    
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    //
    
    @objc override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, currentType: A4xDeviceSettingCurrentType, allCases: [A4xDeviceSettingEnumAlertModel]){
        self.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.allCases = allCases
        self.currentType = currentType
        self.tableView.reloadData()
        self.tapView.isHidden = false
        
        var height = ((self.allCases?.count ?? 0) * 60.auto()) + 68.auto()
        let screenHeight = Int(UIScreen.main.bounds.height)
        


        if height >= screenHeight {
            height = Int(screenHeight)
            self.tableView.isScrollEnabled = true
        } else {
            self.tableView.isScrollEnabled = false
        }
        self.tableView.snp.remakeConstraints({ (make) in
            make.height.equalTo(height)
            make.left.width.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: ----- 点击事件 -----
    
    @objc func closePage(sender: UITapGestureRecognizer)
    {
        self.hideAlert()
    }
    
    
    //MARK: ----- 弹出 -----
    func showAlert() {
        if (self.allCases?.count ?? 0) > 0 {
            UIApplication.shared.keyWindow?.addSubview(self)
            self.tableView.reloadData()
        }
    }
    
    @objc public func hideAlert() {
        self.removeFromSuperview()
    }

    //MARK: ----- UI组件 -----
    lazy private var tapView: UIView = {
        let temp = UIView();
        temp.backgroundColor = UIColor.clear
        //temp.sectionHeaderHeight = A4xDeviceSettingModuleCellTopPadding
        //temp.separatorInset = UIEdgeInsets.zero
        let viewTapGR = UITapGestureRecognizer.init(target: self, action: #selector(closePage(sender:)))
        temp.addGestureRecognizer(viewTapGR)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.tableView.snp.top)
            make.left.width.equalTo(self)
            make.top.equalTo(self.snp.top)
        })
        
        return temp
    }()
    
    lazy private var tableView: UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped);
        temp.backgroundColor = UIColor.clear
        //temp.sectionHeaderHeight = A4xDeviceSettingModuleCellTopPadding
        //temp.separatorInset = UIEdgeInsets.zero
        temp.separatorColor = UIColor.clear
        temp.separatorStyle = .none
        temp.accessibilityIdentifier = "A4xDeviceSettingEnumAlertView_tableView"
        temp.delegate = self
        temp.register(A4xDeviceSettingEnumAlertTableViewCell.self, forCellReuseIdentifier: "A4xDeviceSettingEnumAlertTableViewCell")
        temp.dataSource = self
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.height.equalTo(maxTableHeight)
            make.left.width.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
        })
        
        return temp
    }()

    //MARK: ----- UITableViewDelegate & UITableViewDataSource -----
    @objc public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.allCases?.count ?? 0
        } else {
            return 1
        }
    }
    
    @objc public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    @objc public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "A4xDeviceSettingEnumAlertTableViewCell"
        var tableCell: A4xDeviceSettingEnumAlertTableViewCell? = tableView.cellForRow(at: indexPath) as? A4xDeviceSettingEnumAlertTableViewCell
        //dequeueReusableCell(withIdentifier: identifier) as? A4xDeviceSettingEnumAlertTableViewCell
        if (tableCell == nil) {
            tableCell = A4xDeviceSettingEnumAlertTableViewCell.init(style: .default, reuseIdentifier: identifier)
        }
        if indexPath.section == 1 {
            
            let finalModel = A4xDeviceSettingEnumAlertModel()
            finalModel.content = A4xBaseManager.shared.getLocalString(key: "cancel")
            finalModel.descriptionContent = ""
            finalModel.isEnable = true
            tableCell?.setCell(enumModel: finalModel, radiusType: .None)
        } else {
            let enumModel = self.allCases?[indexPath.row] ?? A4xDeviceSettingEnumAlertModel()
            var radiusType : A4xDeviceSettingModuleCornerRadiusType = .All
            if indexPath.row == 0 {
                
                radiusType = .Top
            } else {
                
                radiusType = .None
            }
            tableCell?.setCell(enumModel: enumModel, radiusType: radiusType)
        }
        
        return tableCell!
    }
    
    @objc public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.auto()
    }
    
    @objc public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    @objc public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil;
    }
    
    
    @objc public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 8.auto()
        } else {
            return 0
        }
    }
    
    @objc public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil;
    }
    
    @objc public  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {

        } else {
            if self.delegate != nil {
                let enumModel = (self.allCases?.getIndex(indexPath.row) ?? A4xDeviceSettingEnumAlertModel())
                self.delegate?.A4xDeviceSettingEnumAlertViewCellDidClick(currentType: self.currentType ?? .NotiMode, enumModel: enumModel)
            }
        }
        self.removeFromSuperview()
    }
    
}
