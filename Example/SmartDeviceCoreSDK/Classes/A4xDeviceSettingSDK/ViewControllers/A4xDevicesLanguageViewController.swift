//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xDevicesLanguageViewController: A4xBaseViewController {







    
    var deviceModel: DeviceBean?
    
    private var cellInfos : [A4xDeviceLanguageEnum]?
    private var dataSource : DeviceBean?
    
    init(deviceModel: DeviceBean, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.deviceModel = deviceModel
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        //
        self.dataSource = A4xUserDataHandle.Handle?.getDevice(deviceId: deviceModel.serialNumber ?? "", modeType: deviceModel.apModeType ?? .WiFi)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNavtion()
        self.configTableView()
        self.tableView.isHidden = false
        reloadData()
        self.loadDeviceConfig()
        
    }
    
    private func reloadData() {
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        A4xUserDataHandle.Handle?.videoHelper.stopAlive(deviceId: self.deviceModel?.serialNumber ?? "" )
    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.deviceModel?.modelCategory ?? 1)
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "device_language", param: [tempString]).capitalized
        var leftItem = A4xBaseNavItem()
        leftItem.normalImg =  "icon_back_gray"
        self.navView?.leftItem = leftItem
        
        self.navView?.leftClickBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
    }
    
    private
    lazy var tableView : UITableView = {
        let temp = UITableView()
        temp.delegate = self
        temp.dataSource = self
        temp.backgroundColor = UIColor.clear
        temp.tableFooterView = UIView()
        temp.accessibilityIdentifier = "tableView"
        temp.separatorInset = .zero
        temp.separatorColor = ADTheme.C6
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
    

    /*
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    */

}

extension A4xDevicesLanguageViewController : UITableViewDelegate , UITableViewDataSource {
    func configTableView() {
        self.tableView.isHidden = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.estimatedRowHeight = 48.auto();
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.separatorColor = ADTheme.C5
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.separatorInset = UIEdgeInsets.zero
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellInfos?.count ?? 0
    }
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "identifier"
        
        var tableCell : A4xLanguageViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xLanguageViewCell
        if (tableCell == nil){
            tableCell = A4xLanguageViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier);
        }
        if let type = self.cellInfos?[indexPath.row] {
            tableCell?.title = type.tipValue()
            tableCell?.check = type == dataSource?.deviceLanguageEnum()
        }
        
        return tableCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let type = self.cellInfos?[indexPath.row] {
            
            self.updatelanguageInfo(info: type)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)  {
        cell.preservesSuperviewLayoutMargins = false
        
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
    }
}


extension A4xDevicesLanguageViewController {
    private func loadDeviceConfig() {
        weak var weakSelf = self
        var isFirst : Bool = true

        A4xUserDataHandle.Handle?.videoHelper.keepAlive(deviceId: self.deviceModel?.serialNumber ?? "" ) { (state, flag) in
            switch state {
            case .start:
                weakSelf?.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading"), completion: { (r) in  })
            case  .done(_):
                if isFirst {
                    weakSelf?.loadDefaultData()
                }
                isFirst = false
            case let .error(error):
                weakSelf?.view.hideToastActivity {
                    weakSelf?.view.makeToast(error)
                }
            }
        }
    }
    
    private func loadDefaultData(){
        weak var weakSelf = self
        if !(self.deviceModel?.isAdmin() ?? true) {
            return
        }
        
        DeviceManageCore.getInstance().getDeviceSettingConfig(serialNumber: self.deviceModel?.serialNumber ?? "", onSuccess: { code, message, model in
            weakSelf?.view.hideToastActivity()
            weakSelf?.dataSource?.deviceLanguage = model?.deviceLanguage
            A4xUserDataHandle.Handle?.updateDevice(device: weakSelf?.dataSource)
            weakSelf?.cellInfos = A4xDeviceLanguageEnum.allCases(languages: model?.deviceSupportLanguage)
            weakSelf?.tableView.reloadData()
        }, onError: { code, message in
            weakSelf?.view.hideToastActivity()
            weakSelf?.tableView.reloadData()
        })

    }
    
    private func updatelanguageInfo(info : A4xDeviceLanguageEnum) {
        weak var weakSelf = self
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (f) in }
        
        DeviceSettingCore.getInstance().updateDeviceLanguage(serialNumber: self.deviceModel?.serialNumber ?? "", language: info.rawValue) { code, message in
            weakSelf?.view.hideToastActivity()
            weakSelf?.dataSource?.deviceLanguage = info.rawValue
            A4xUserDataHandle.Handle?.updateDevice(device: weakSelf?.dataSource)
            UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "toast_change_language"))
            DispatchQueue.main.a4xAfter(0.1) {
                weakSelf?.navigationController?.popViewController(animated: true)
            }
        } onError: { code, message in
            weakSelf?.view.hideToastActivity()
            weakSelf?.view.makeToast(message)
            weakSelf?.reloadData()
        }
    }
}
