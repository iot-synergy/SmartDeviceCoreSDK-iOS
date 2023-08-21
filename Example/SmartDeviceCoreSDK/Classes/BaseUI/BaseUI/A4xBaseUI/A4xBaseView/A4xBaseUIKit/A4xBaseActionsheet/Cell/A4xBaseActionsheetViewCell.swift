//


//


//

import UIKit
import SmartDeviceCoreSDK

class A4xBaseActionsheetViewCell: UITableViewCell {

    var title: String? {
        didSet {
            self.titleLbl.text = title
        }
    }
    
    var des: String? {
        didSet {
            self.desLbl.text = des
            if !(des?.isBlank ?? true) {
                self.desLbl.isHidden = false
                titleLbl.snp.remakeConstraints({ (make) in
                    make.top.equalTo(self.contentView.snp.top).offset(7.5.auto())
                    make.centerX.equalToSuperview()
                })
            }
        }
    }
    
    private func centerTitleUI() {
        if !(des?.isBlank ?? true) {
            self.desLbl.isHidden = false
            titleLbl.snp.remakeConstraints({ (make) in
                make.top.equalTo(self.contentView.snp.top).offset(7.5.auto())
                make.centerX.equalToSuperview()
            })
        } else {
            titleLbl.snp.remakeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            })
        }
    }
    
    var cellType: A4xBaseTitleAlignment? = .center {
        didSet {
            switch cellType {
            case .center:
                centerTitleUI()
                break
            case .left:
                titleLbl.snp.remakeConstraints({ (make) in
                    make.leading.equalTo(self.contentView.snp.leading).offset(28.auto())
                    make.centerY.equalToSuperview()
                })
                break
            default:
                break
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
        self.titleLbl.isHidden = false
        self.desLbl.isHidden = true
        self.selIconImg.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if cellType == .left {
            if selected {
                selIconImg.isHidden = false
                self.titleLbl.textColor = ADTheme.Theme
            } else {
                selIconImg.isHidden = true
                self.titleLbl.textColor = UIColor.colorFromHex("#2F3742")
            }
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        //self.contentView.backgroundColor = highlighted ? UIColor.colorFromHex("#D4D3D9") : UIColor.colorFromHex("#F5F6FA")
    }

    override func select(_ sender: Any?) {
        super.select(sender)
    }
    
    public lazy var titleLbl: UILabel = {
        let temp = UILabel()
        temp.font = UIFont.regular(16)
        temp.textColor = UIColor.colorFromHex("#2F3742")
        temp.textAlignment = .center
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        })
        return temp
    }()
    
    public lazy var desLbl: UILabel = {
        let temp = UILabel()
        temp.textAlignment = .center
        temp.numberOfLines = 0
        temp.lineBreakMode = .byWordWrapping
        temp.textColor = ADTheme.C3
        temp.font = UIFont.regular(12)
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(titleLbl.snp.bottom).offset(1.5.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(self.snp.width).offset(-32.auto())
        })
        return temp
    }()
    
    public lazy var selIconImg: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleToFill
        temp.image = bundleImageFromImageName("checkbox_select")
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self.titleLbl.snp.centerY)
            make.height.width.equalTo(13.auto())
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-28.auto())
        })
        return temp
    }()
   
}

