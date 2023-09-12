//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xBindHistoryWifiCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

    override func select(_ sender: Any?) {
        super.select(sender)
    }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.contentView.backgroundColor = highlighted ? UIColor.colorFromHex("#D4D3D9") : .clear
    }
    
    
    var dataSource: BindHistoryWifiModel? {
        didSet {
            //selectWificheckBoxBtn.isSelected = datas?["isSelected"] == "1" ? true : false
            wifiNameLbl.text = dataSource?.wifiName
        }
    }
    
    
    lazy var historyWifiImg: UIImageView = {
        var iv = UIImageView()
        iv.image = bundleImageFromImageName("icon_history_wifi")?.rtlImage()
        return iv
    }()
    
    
    lazy var wifiNameLbl: UILabel = {
        var lbl: UILabel = UILabel()
        lbl.text = ""
        lbl.numberOfLines = 0
        lbl.textAlignment = .left
        lbl.textColor = ADTheme.C1
        lbl.font = UIFont.regular(16)
        return lbl
    }()
    
    
    lazy var editWifiImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.contentMode = .center
        iv.image = bundleImageFromImageName("del_history_wifi")?.rtlImage()
        return iv
    }()
    
    
    lazy var lineView : UIView = {
        let v: UIView = UIView()
        v.backgroundColor = UIColor.colorFromHex("#DADBE0")
        return v
    }()
    
    
    private func setupUI() {
        self.contentView.addSubview(historyWifiImg)
        self.contentView.addSubview(wifiNameLbl)
        self.contentView.addSubview(editWifiImgView)
        self.contentView.addSubview(lineView)
        
        
        historyWifiImg.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(31)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 15.76.auto(), height: 15.76.auto()))
        })
        
        
        wifiNameLbl.snp.makeConstraints({ (make) in
            make.leading.equalTo(historyWifiImg.snp.trailing).offset(11.5.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.width.equalTo(211.5.auto())
        })
        
        
        editWifiImgView.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-32.auto())
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: 20, height: 20))
        })
        
        
        lineView.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.contentView.snp.bottom).offset(0)
            make.height.equalTo(1)
            make.width.equalTo(self.contentView.snp.width).offset(-62)
            make.leading.equalTo(historyWifiImg.snp.leading).offset(0)
        })
    }
}
