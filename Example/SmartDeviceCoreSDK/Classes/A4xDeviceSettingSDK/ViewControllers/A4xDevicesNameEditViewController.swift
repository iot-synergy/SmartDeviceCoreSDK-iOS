//


//


//

import UIKit

import SmartDeviceCoreSDK
import BaseUI

@objc public protocol A4xDevicesNameEditViewControllerDelegate : AnyObject {
    
    func A4xDevicesNameEditViewControllerDidEditDeviceName(isComple: Bool, deviceId: String, deviceName: String)
}

class A4xDevicesNameEditViewController: A4xBaseViewController {

    var dataSource : DeviceBean?
    
    weak var delegate : A4xDevicesNameEditViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.loadNavtion()
        self.textView.isHidden = false
        self.textView.text = self.dataSource?.deviceName
        textChange()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.becomeFirstResponder()

    }
    
    private func loadNavtion() {
        weak var weakSelf = self
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
        self.navView?.title = A4xBaseManager.shared.getLocalString(key: "device_name", param: [tempString]).capitalized
        var leftItem = A4xBaseNavItem()
        leftItem.title = A4xBaseManager.shared.getLocalString(key: "cancel")
        leftItem.titleColor = ADTheme.Theme
        self.navView?.leftItem = leftItem
        self.navView?.leftClickBlock = {
            weakSelf?.checkAction()
        }
        
        var rightItem = A4xBaseNavItem()
        rightItem.title = A4xBaseManager.shared.getLocalString(key: "save")
        rightItem.titleColor = ADTheme.Theme
        rightItem.disableColor = ADTheme.Theme.withAlphaComponent(0.3)
        self.navView?.rightItem = rightItem
        self.navView?.rightClickBlock = {
            weakSelf?.updateName()
        }
    }

    private lazy
    var textView : UITextField = {
        let temp = A4xBaseTextField()
        temp.addTarget(self, action: #selector(textChange), for: .editingChanged)
        temp.inset = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 19)
        temp.backgroundColor = ADTheme.C6
        temp.clearButtonMode = .always
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.B1
        temp.textAlignment = .left
        temp.accessibilityIdentifier = "device_name"
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(self.navView!.snp.bottom)
            make.leading.equalTo(0)
            make.width.equalTo(self.view.snp.width)
            make.height.equalTo(45)
        })
        
        return temp
    }()

    @objc
    func textChange(){
        guard let text = self.textView.text else {
            self.navView?.rightBtn?.isEnabled = false
            return
        }
        
        guard text.trim().count > 0 else {
            self.navView?.rightBtn?.isEnabled = false
            return
        }
        guard text != self.dataSource?.deviceName else {
            self.navView?.rightBtn?.isEnabled = false
            return
        }
        self.navView?.rightBtn?.isEnabled = true
    }
    
    private func checkAction(){
        self.textView.resignFirstResponder()
        
        guard let text = self.textView.text else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        guard text.trim().count > 0 else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        guard text != self.dataSource?.deviceName  else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        var config = A4xBaseAlertAnimailConfig()
        config.leftbtnBgColor = ADTheme.C5
        config.leftTitleColor = ADTheme.C1
        config.rightbtnBgColor = ADTheme.Theme
        config.rightTextColor = UIColor.white
        weak var weakSelf = self
        
        let alert = A4xBaseAlertView(param: config, identifier: "delete device")
        alert.message  = A4xBaseManager.shared.getLocalString(key: "change_not_save")
        alert.leftButtonTitle = A4xBaseManager.shared.getLocalString(key: "no")
        alert.rightButtonTitle = A4xBaseManager.shared.getLocalString(key: "yes")
        alert.rightButtonBlock = {
            weakSelf?.updateName()
        }
        alert.leftButtonBlock = {
            weakSelf?.navigationController?.popViewController(animated: true)
        }
        alert.show()
    }
    
    private func updateName(){
        self.textView.resignFirstResponder()
        guard self.dataSource != nil else {
            return
        }
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: self.dataSource?.modelCategory ?? 1)
        
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading")) { (r) in }
        weak var weakSelf = self
        DeviceSettingCore.getInstance().updateAttribute(serialNumber: self.dataSource?.serialNumber ?? "", name: "deviceName", value: self.textView.text ?? "") { code, message in
            if weakSelf?.delegate != nil {
                weakSelf?.delegate?.A4xDevicesNameEditViewControllerDidEditDeviceName(isComple: true, deviceId: self.dataSource?.serialNumber ?? "", deviceName: self.textView.text ?? "")
            }
                
            if let strongSelf = weakSelf {
                strongSelf.dataSource?.deviceName = strongSelf.textView.text
                A4xUserDataHandle.Handle?.updateDevice(device: strongSelf.dataSource!)
                UIApplication.shared.keyWindow?.makeToast(A4xBaseManager.shared.getLocalString(key: "update_device_name_scuess", param: [tempString]))
                strongSelf.navigationController?.popViewController(animated: true)
            }
        } onError: { code, message in
            if weakSelf?.delegate != nil {
                weakSelf?.delegate?.A4xDevicesNameEditViewControllerDidEditDeviceName(isComple: false, deviceId: self.dataSource?.serialNumber ?? "", deviceName: "")
            }
            weakSelf?.view.makeToast(message)
        }
    }
}
