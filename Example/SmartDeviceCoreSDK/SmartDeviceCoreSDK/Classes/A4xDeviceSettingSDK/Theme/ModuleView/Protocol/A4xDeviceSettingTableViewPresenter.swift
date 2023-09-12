

import UIKit

class A4xDeviceSettingTableViewPresenter: NSObject, UITableViewDelegate, UITableViewDataSource, A4xDeviceSettingModuleTableViewCellDelegate {
    
    
    var allCases : Array<Array<A4xDeviceSettingModuleModel>>? = []
    
    
    weak var delegate : A4xDeviceSettingModuleTableViewCellDelegate?
    
    //MARK: ----- UITableViewDelegate & UITableViewDataSource -----
    
    @objc public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allCases?.getIndex(section)?.count ?? 0
    }
    
    @objc public func numberOfSections(in tableView: UITableView) -> Int {
        return self.allCases?.count ?? 0
    }
    
    
    @objc public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let moduleModel = self.allCases?[indexPath.section][indexPath.row] ?? A4xDeviceSettingModuleModel()
        let identifier = "A4xDeviceSettingModuleTableViewCell"
        
        var tableCell: A4xDeviceSettingModuleTableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xDeviceSettingModuleTableViewCell
        if (tableCell == nil) {
            tableCell = A4xDeviceSettingModuleTableViewCell.init(style: .default, reuseIdentifier: identifier, moduleModel: moduleModel)
        }
        
        tableCell?.selectionStyle = .none
        tableCell?.delegate = self.delegate
        tableCell?.indexPath = indexPath
        var radiusType : A4xDeviceSettingModuleCornerRadiusType = .All
        let elementCount = self.allCases?[indexPath.section].count
        if elementCount == 1 {
            radiusType = .All
        } else {
            if indexPath.row == 0 {
                
                radiusType = .Top
            } else if indexPath.row == ((elementCount ?? 0) - 1) {
                
                radiusType = .Bottom
            } else {
                
                radiusType = .None
            }
        }
        
        tableCell?.setCell(moduleModel: moduleModel, radiusType: radiusType)
        return tableCell!
    }
    
    @objc public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let moduleModel = self.allCases?[indexPath.section][indexPath.row] ?? A4xDeviceSettingModuleModel()
        return moduleModel.cellHeight
    }
    
    @objc public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return A4xDeviceSettingModuleCellTopPadding
    }
    
    @objc public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    @objc public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == ((self.allCases?.count ?? 0) - 1) {
            return 16.auto()
        } else {
            return 0
        }
    }
    
    @objc public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    //MARK: ----- A4xDeviceSettingModuleTableViewCellDelegate -----
    
    
    
    func A4xDeviceSettingModuleTableViewCellSwitchDidClick(indexPath: IndexPath, isOn: Bool)
    {
        
    }
    
    
    func A4xDeviceSettingModuleTableViewCellSelectionBoxDidClick(indexPath: IndexPath, index: Int)
    {
        
    }
    
    
    func A4xDeviceSettingModuleTableViewCellDidClick(indexPath: IndexPath)
    {
        
    }
    
    
    func A4xDeviceSettingModuleTableViewCellButtonDidClick(indexPath: IndexPath)
    {
        
    }
    
    
    func A4xDeviceSettingModuleTableViewCellSliderDidDrag(value: Float, indexPath: IndexPath)
    {
        
    }

}
