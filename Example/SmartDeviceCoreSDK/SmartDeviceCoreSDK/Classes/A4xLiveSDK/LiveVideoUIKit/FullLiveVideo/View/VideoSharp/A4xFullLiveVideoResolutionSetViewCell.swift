//


//


//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

class A4xFullLiveVideoResolutionSetViewCell: UITableViewCell {
    
    var resolutionIntroBlock: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var title : String? {
        didSet {
            self.titleLabel.text = self.title
            showHelpInfo = self.title == A4xBaseManager.shared.getLocalString(key: "auto") ? true : false
        }
    }
    
    var showHelpInfo: Bool? = false {
        didSet {
            self.infoBtn.isHidden = !(showHelpInfo ?? false)
        }
    }

    private lazy var titleLabel: UILabel = {
        let temp = UILabel()
        temp.font = UIFont.regular(16)
        temp.textAlignment = .center
        temp.backgroundColor = UIColor.clear
        temp.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.center.equalTo(self.contentView.snp.center)
        })
        return temp
    }()
    
    private lazy var infoBtn: UIButton = {
        let temp = UIButton()
        temp.isHidden = true
        temp.setImage(A4xLiveUIResource.UIImage(named: "live_video_full_help_info"), for: .normal)
        temp.backgroundColor = .clear
        temp.addTarget(self, action: #selector(helpInfoClick), for: .touchUpInside)
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.titleLabel.snp.trailing).offset(8.auto())
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.size.equalTo(CGSize(width: 36.auto(), height: 36.auto()))
        })
        return temp
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.titleLabel.textColor = ADTheme.Theme
        } else {
            self.titleLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    @objc func helpInfoClick() {
        
        self.resolutionIntroBlock?()
    }
}
