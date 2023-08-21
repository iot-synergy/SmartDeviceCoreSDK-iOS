//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xBindEditDeviceNameHeaderView: UICollectionReusableView {
    
    var cellHeight: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLable.isHidden = false
        self.deviceNameTitle.isHidden = false
        self.deviceNameTxtF.isHidden = false
        self.locationName.isHidden = false
        self.editButton.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var editMode: Bool = false {
        didSet {
            self.editButton.isSelected = editMode
        }
    }
    
    var editEnable: Bool = true {
        didSet {
            self.editButton.isEnabled = editEnable
            self.editButton.isSelected = false
        }
    }
    
    var editModeAction: ((Bool)->Void)?
    
    var deviceNameUpdate: ((String?)->Void)?
    
    var currentDeviceName: String? {
        return deviceNameTxtF.text
    }
    
    var deviceNameEdit: String? {
        didSet {
            if deviceNameEdit?.isBlank ?? true {
                return
            }
            deviceNameTxtF.text = deviceNameEdit
        }
    }
    
    lazy var titleLable: UILabel = {
        var temp: UILabel = UILabel()
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        temp.text = A4xBaseManager.shared.getLocalString(key: "new_bind_device_name", param: [tempString])
        temp.textColor = ADTheme.C1
        temp.numberOfLines = 0
        temp.textAlignment = .center
        temp.lineBreakMode = .byWordWrapping
        self.addSubview(temp)
        temp.font = ADTheme.H1
        
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(10.auto())
            make.centerX.equalTo(self.snp.centerX)
            make.width.equalTo(self.snp.width).offset(-60)
        })
        temp.layoutIfNeeded()
        
        cellHeight += temp.height + 10.auto()
        return temp
    }()
    
    lazy var deviceNameTxtF: A4xBaseTextField = {
        var temp: A4xBaseTextField = A4xBaseTextField()
        temp.accessibilityIdentifier = "device_account_name"
        temp.addTarget(self, action: #selector(textChange), for: .editingChanged)
        temp.backgroundColor = UIColor.clear
        temp.font = ADTheme.B1
        temp.textColor = ADTheme.C1
        temp.clearButtonMode = .whileEditing
        temp.textAlignment = .left
        temp.placeholderTextColor = ADTheme.C4
        temp.inset = UIEdgeInsets(top: 0, left: 0.auto(), bottom: 0, right: 15.auto())
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: 0)
        temp.placeholder = A4xBaseManager.shared.getLocalString(key: "enter_device_name", param: [tempString])
        var appName = ADTheme.APPName
        temp.text = A4xBaseManager.shared.getLocalString(key: "default_device_name") //A4xBaseManager.shared.getLocalString(key: "device_default_name", param: [appName])
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.deviceNameTitle.snp.bottom).offset(5.auto())
            make.height.equalTo(38.auto())
            make.width.equalTo(self.snp.width)
        })
        temp.addLineStyle()
        temp.layoutIfNeeded()
        
        cellHeight += 38.auto() + 5.auto()
        
        return temp
    }()
    
    lazy var deviceNameTitle: UILabel = {
        let temp = UILabel()
        temp.font = UIFont.systemFont(ofSize: 14.auto(), weight: UIFont.Weight.medium)
        temp.textColor = ADTheme.Theme
        temp.text = A4xBaseManager.shared.getLocalString(key: "device_name", param: [A4xBaseManager.shared.getLocalString(key: "device_type_unknown")]).capitalized
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(0)
            make.top.equalTo(self.titleLable.snp.bottom).offset(60.auto())
            make.height.equalTo(38.auto())
            make.width.equalTo(self.snp.width).offset(-32.auto())
        })
        
        temp.layoutIfNeeded()
        
        cellHeight += 38.auto() + 60.auto()
        
        return temp
    }()
    
    lazy var locationName: UILabel = {
        let temp = UILabel()
        temp.font = UIFont.systemFont(ofSize: 14.auto(), weight: UIFont.Weight.medium)
        temp.textColor = ADTheme.Theme
        temp.text = A4xBaseManager.shared.getLocalString(key: "location")
        temp.textAlignment = .left
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(0)
            make.top.equalTo(self.deviceNameTxtF.snp.bottom).offset(30.auto())
            make.height.equalTo(38.auto())
            make.width.greaterThanOrEqualTo(self.width / 2)
        })
        
        temp.layoutIfNeeded()
        
        cellHeight += 38.auto() + 30.auto()
        return temp
        
    }()
    
    private lazy var editButton: UIButton = {
        let temp = UIButton()
        temp.contentHorizontalAlignment = .right
        temp.setTitleColor(UIColor(hex: "#333333"), for: UIControl.State.normal)
        temp.setTitleColor(UIColor(hex: "#999999"), for: UIControl.State.disabled)
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "edit"), for: UIControl.State.normal)
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "done"), for: UIControl.State.selected)
        temp.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        temp.titleLabel?.font = UIFont.systemFont(ofSize: 14.auto())
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(0)
            make.centerY.equalTo(self.locationName.snp.centerY)
            make.height.equalTo(38.auto())
            make.width.greaterThanOrEqualTo(self.width / 2)
        })
        return temp
    }()
    
    public func getHeadViewHeight() -> CGFloat {
        return cellHeight 
    }
    
    @objc private func editButtonAction() {
        self.editButton.isSelected = !self.editButton.isSelected
        self.editModeAction?(self.editButton.isSelected)
    }
    
    @objc private func textChange() {
        self.deviceNameUpdate?(self.deviceNameTxtF.text)
    }
}
