//


//


//
import SmartDeviceCoreSDK
import BaseUI

public class A4xHomeLibrarySDCardChooseView : UIView, UIGestureRecognizerDelegate {
    
    var dataSourceArray = [DeviceBean]()
    
    var hideSDCardViewBlock: (() -> Void)?
    
    var confirmClick: ((String) -> Void)?
    
    var selectedIndex: IndexPath?
    
    var selectDeviceSN: String = ""
    
    public func updateLanguage() {
        self.titleLable.text = A4xBaseManager.shared.getLocalString(key: "library_sdcard_select_device")
        self.noDataLabel.text = A4xBaseManager.shared.getLocalString(key: "library_sdcard_no_device")
        self.confirButton.setTitle(A4xBaseManager.shared.getLocalString(key: "confirm"), for: .normal)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.colorFromHex("#000000", alpha: 0.5)
        
        preparData()
        
        self.addSubview(self.topBgView)
        self.topBgView.addSubview(self.titleLable)
        self.topBgView.addSubview(self.tableContentView)
        self.tableContentView.addSubview(self.tableView)
        self.topBgView.addSubview(self.confirButton)
        
        self.topBgView.addSubview(self.noDataImgView)
        self.topBgView.addSubview(self.noDataLabel)
        
        self.topBgView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(-1)
            make.height.equalTo(303)
        }
        self.titleLable.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.leading.equalTo(16.auto())
            make.trailing.equalTo(-16.auto())
            make.height.equalTo(20)
        }
        self.tableContentView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLable.snp.bottom).offset(8)
            make.leading.equalTo(16.auto())
            make.trailing.equalTo(-16.auto())
            make.height.equalTo(61*3)
        }
        self.tableView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(0)
        }
        self.confirButton.snp.makeConstraints { make in
            make.top.equalTo(self.tableContentView.snp.bottom).offset(16)
            make.leading.equalTo(16.auto())
            make.trailing.equalTo(-16.auto())
            make.height.equalTo(52)
        }
        
        self.noDataImgView.snp.makeConstraints { make in
            make.top.equalTo(32)
            make.centerX.equalTo(self)
            make.size.equalTo(CGSizeMake(150, 150))
        }
        self.noDataLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.height.equalTo(24)
            make.top.equalTo(self.noDataImgView.snp.bottom).offset(24)
        }
        
        
        DispatchQueue.main.a4xAfter(0.1) {
            let rectCorner: UIRectCorner = [.bottomLeft, .bottomRight]
            self.topBgView.layoutIfNeeded()
            self.topBgView.addCorner(conrners: rectCorner, radius: 12.auto())
            self.topBgView.layer.masksToBounds = true
            
            let startColor = UIColor.colorFromHex("#E6E6E6")
            self.confirButton.gradientColor(CGPoint(x:0, y:0), CGPoint(x:1, y:0), [startColor.cgColor, startColor.cgColor])
        }
        
        let backViewTapGR = UITapGestureRecognizer.init(target: self, action: #selector(closePage))
        backViewTapGR.delegate = self
        self.addGestureRecognizer(backViewTapGR)
    }
    
    public func show() {
        preparData()
        if dataSourceArray.count > 0 {
            self.titleLable.isHidden = false
            self.tableContentView.isHidden = false
            self.confirButton.isHidden = false
            self.tableView.reloadData()
            self.noDataLabel.isHidden = true
            self.noDataImgView.isHidden = true
        } else {
            self.titleLable.isHidden = true
            self.tableContentView.isHidden = true
            self.confirButton.isHidden = true
            
            self.noDataLabel.isHidden = false
            self.noDataImgView.isHidden = false
        }
    }
    
    
    public func preparData() {
        self.dataSourceArray.removeAll()
        let datas = A4xUserDataHandle.Handle?.deviceModels
        let count = datas?.count ?? 0
        for index in 0..<count {
            guard let deviceModel = datas?[index] else {
                return
            }
            

                self.dataSourceArray.append(deviceModel)

        }
    }
    
    @objc func closePage() {
        hideSDCardViewBlock?()
    }
    
    @objc func confirm(button: UIButton) {
        confirmClick?(selectDeviceSN)
    }
    
    @objc public func changeConfirmState(canClick: Bool) {
        if canClick {
            let startColor = ADTheme.Theme.withAlphaComponent(1)
            let endColor = ADTheme.Theme.withAlphaComponent(0.8)
            self.confirButton.gradientColor(CGPoint(x:0, y:0), CGPoint(x:1, y:0), [startColor.cgColor, endColor.cgColor])
            
            self.confirButton.isUserInteractionEnabled = true
            self.confirButton.setTitleColor(.white, for: .normal)
        } else {
            let startColor = UIColor.colorFromHex("#E6E6E6")
            self.confirButton.gradientColor(CGPoint(x:0, y:0), CGPoint(x:1, y:0), [startColor.cgColor, startColor.cgColor])
            
            self.confirButton.isUserInteractionEnabled = false
            self.confirButton.setTitleColor(UIColor.colorFromHex("#999999"), for: .normal)
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.topBgView) {
            return false
        }
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var topBgView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.colorFromHex("#F6F7F9")
        return temp
    }()
    
    private lazy var titleLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "library_sdcard_select_device")
        temp.font = ADTheme.B2
        temp.textAlignment = .left
        temp.lineBreakMode = .byTruncatingTail
        temp.textColor = ADTheme.C3
        return temp
    }()
    
    private lazy var tableContentView: UIView = {
        let temp = UIView()
        temp.backgroundColor = .white
        temp.layer.cornerRadius = 12
        temp.layer.masksToBounds = true
        return temp
    }()
    
    private lazy var tableView: UITableView = {
        let temp = UITableView(frame:CGRect.zero, style: .plain)
        temp.delegate = self
        temp.dataSource = self
        temp.backgroundColor = .white
        temp.separatorInset = .zero
        temp.allowsSelection = true
        temp.allowsMultipleSelection = false
        temp.register(A4xHomeLibrarySDCardChooseCell.self, forCellReuseIdentifier: "A4xHomeLibrarySDCardChooseCell")
        temp.separatorStyle = .none
        temp.estimatedRowHeight = 61;
        temp.rowHeight = UITableView.automaticDimension;
        return temp
    }()
    
    private lazy var confirButton: UIButton = {
        var temp = UIButton()
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "confirm"), for: .normal)
        temp.layer.cornerRadius = 26
        temp.addTarget(self, action: #selector(confirm(button: )), for: .touchUpInside)
        temp.isUserInteractionEnabled = false
        return temp
    }()
    
    private lazy var noDataImgView: UIImageView = {
        var temp = UIImageView()
        temp.image = bundleImageFromImageName("no_sd_device")
        return temp
    }()
    
    private lazy var noDataLabel: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "library_sdcard_no_device")
        temp.font = UIFont.regular(17)
        temp.textAlignment = .center

        temp.numberOfLines = 1
        temp.textColor = UIColor(hex: "#C9CDD4")
        return temp
    }()
}


extension A4xHomeLibrarySDCardChooseView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "A4xHomeLibrarySDCardChooseCell") as! A4xHomeLibrarySDCardChooseCell
        cell.deviceModel = dataSourceArray[indexPath.row]
        
        if indexPath == selectedIndex {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deviceModel = dataSourceArray[indexPath.row]
        if deviceModel.deviceState() == .sleep {
            self.makeToast(A4xBaseManager.shared.getLocalString(key: "camera_sleep", param: [deviceModel.deviceName ?? ""]))
        } else if deviceModel.deviceState() != .online {
            self.makeToast(A4xBaseManager.shared.getLocalString(key: "camera_poor_network_short", param: [deviceModel.deviceName ?? ""]))
        } else if deviceModel.sdCard?.formatStatus == 13 {
            self.makeToast(A4xBaseManager.shared.getLocalString(key: "sd_error", param: [deviceModel.deviceName ?? ""]))
        } else if !deviceModel.hasSdCardAndSupport() {
            self.makeToast(A4xBaseManager.shared.getLocalString(key: "sd_card_not_exist", param: [deviceModel.deviceName ?? ""]))
        } else {
            if let selectedIndex = selectedIndex {
                if selectedIndex == indexPath {
                    
                    self.selectedIndex = nil
                    selectDeviceSN = ""
                    changeConfirmState(canClick: false)
                } else {
                    
                    self.selectedIndex = indexPath
                    selectDeviceSN = deviceModel.serialNumber ?? ""
                    changeConfirmState(canClick: true)
                }
            } else {
                
                self.selectedIndex = indexPath
                selectDeviceSN = deviceModel.serialNumber ?? ""
                changeConfirmState(canClick: true)
            }
            tableView.reloadData()
        }
    }
    
    
}
