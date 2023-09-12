//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

protocol A4xFilterTagNormalCellProtocol: class {
    func checkCellClick(sender: UIButton, indexPath: IndexPath)
}

class A4xFilterTagNormalCell: UITableViewCell {
    weak var `protocol`: A4xFilterTagNormalCellProtocol?
    var subVehicleCellHeight: CGFloat = 144.auto()
    var subPackageCellHeight: CGFloat = 144.auto()
    var indexPath: IndexPath?
    
    var iconImage : UIImage? {
        didSet {
            self.iconImageV.image = iconImage
        }
    }
    
    var filterName : String? {
        didSet {
            self.aNameLable.text = filterName
            if filterName == A4xBaseManager.shared.getLocalString(key: "ai_car") {
                self.packageSubView.isHidden = true
                self.vehicelSubView.isHidden = false
                self.checkButton.isHidden = true
            } else if filterName == A4xBaseManager.shared.getLocalString(key: "package_tag") {
                self.vehicelSubView.isHidden = true
                self.packageSubView.isHidden = false
                self.checkButton.isHidden = true
            } else {
                self.packageSubView.isHidden = true
                self.vehicelSubView.isHidden = true
                
                self.checkButton.isHidden = false
            }
        }
    }
    
    
    var subTags: [FilterAiSubTag]?
    
    var subVehicelFilterNameArr: [String] = [A4xBaseManager.shared.getLocalString(key: "vehicle_approaching"), A4xBaseManager.shared.getLocalString(key: "vehicle_leaving"), A4xBaseManager.shared.getLocalString(key: "vehicle_parked")]
    
    var subPackageFilterNameArr: [String] = [A4xBaseManager.shared.getLocalString(key: "package_down"), A4xBaseManager.shared.getLocalString(key: "package_up"), A4xBaseManager.shared.getLocalString(key: "package_detained")]
    
    var checked : Bool = false {
        didSet {
            self.checkButton.isSelected = checked
        }
    }
    
    
    var subVehicelChecked: [Bool] = [] {
        didSet {
            if subVehicelChecked.count > 2 {
                self.subVehicelApproachingCheckBtn.isSelected = subVehicelChecked[0]
                self.subVehicleLeavingCheckBtn.isSelected = subVehicelChecked[1]
                self.subVehicleParkedCheckBtn.isSelected = subVehicelChecked[2]
            }
        }
    }
    
    
    var subPackageChecked: [Bool] = [] {
        didSet {
            if subPackageChecked.count > 2 {
                self.subPackageDownCheckBtn.isSelected = subPackageChecked[0]
                self.subPackageUpCheckBtn.isSelected = subPackageChecked[1]
                self.subPackageDetainedCheckBtn.isSelected = subPackageChecked[2]
            }
        }
    }
    
    
    func configVehicelSubTags(subTags: [FilterAiSubTag]) -> CGFloat {
        subVehicleCellHeight = CGFloat(subTags.count * 48.auto())
        
        self.vehicelSubView.snp.remakeConstraints({ (make) in
            make.top.equalTo(self.iconImageV.snp.bottom).offset(11.5.auto())
            make.leading.equalTo(8.auto())
            make.trailing.equalTo(-8.auto())
            make.height.equalTo(subVehicleCellHeight)
        })
        
        var lastHeight = 0
        for subTag in subTags {
            if subTag.name == "vehicle_enter" {
                
                self.subVehicelApproachingImgView.snp.remakeConstraints({(make) in
                    make.top.equalTo(lastHeight + 12.auto())
                    make.leading.equalTo(self.vehicelSubView.snp.leading).offset(48.auto())
                    make.width.height.equalTo(24.auto())
                })
                self.subVehicelApproachingTitleLbl.isHidden = false
                self.subVehicelApproachingTitleLbl.snp.remakeConstraints({ (make) in
                    make.centerY.equalTo(self.subVehicelApproachingImgView.snp.centerY)
                    make.leading.equalTo(self.iconImageV.snp.trailing).offset(15)
                    //make.leading.equalTo(self.subVehicelApproachingImgView.snp.trailing).offset(16.auto())
                })
                self.subVehicelApproachingCheckBtn.isHidden = false
                self.subVehicelApproachingCheckBtn.snp.remakeConstraints({ (make) in
                    make.trailing.equalTo(self.vehicelSubView.snp.trailing).offset(-8.auto())
                    make.centerY.equalTo(self.subVehicelApproachingTitleLbl.snp.centerY)
                    make.size.equalTo(CGSize(width: 25, height: 25))
                })
            } else if subTag.name == "vehicle_out" {
                
                self.subVehicleLeavingImgView.snp.makeConstraints({(make) in
                    make.top.equalTo(lastHeight + 12.auto())
                    make.centerX.equalTo(self.subVehicelApproachingImgView.snp.centerX)
                    make.width.height.equalTo(24.auto())
                })
                self.subVehicleLeavingTitleLbl.isHidden = false
                self.subVehicleLeavingTitleLbl.snp.makeConstraints({ (make) in
                    make.centerY.equalTo(self.subVehicleLeavingImgView.snp.centerY)
                    make.leading.equalTo(self.iconImageV.snp.trailing).offset(15)
                    //make.leading.equalTo(self.subVehicleLeavingImgView.snp.trailing).offset(12.5.auto())
                })
                self.subVehicleLeavingCheckBtn.isHidden = false
                self.subVehicleLeavingCheckBtn.snp.makeConstraints({ (make) in
                    make.trailing.equalTo(self.vehicelSubView.snp.trailing).offset(-8.auto())
                    make.centerY.equalTo(self.subVehicleLeavingTitleLbl.snp.centerY)
                    make.size.equalTo(CGSize(width: 25, height: 25))
                })
            } else if subTag.name == "vehicle_held_up" {
                
                self.subVehicleParkedImgView.snp.makeConstraints({(make) in
                    make.top.equalTo(lastHeight + 12.auto())
                    make.centerX.equalTo(self.subVehicelApproachingImgView.snp.centerX)
                    make.width.height.equalTo(24.auto())
                })
                self.subVehicleParkedTitleLbl.isHidden = false
                self.subVehicleParkedTitleLbl.snp.makeConstraints({ (make) in
                    make.centerY.equalTo(self.subVehicleParkedImgView.snp.centerY)
                    make.leading.equalTo(self.iconImageV.snp.trailing).offset(15)
                    //make.leading.equalTo(self.subPackageDetainedImgView.snp.trailing).offset(12.5.auto())
                })
                self.subVehicleParkedCheckBtn.isHidden = false
                self.subVehicleParkedCheckBtn.snp.makeConstraints({ (make) in
                    make.trailing.equalTo(self.vehicelSubView.snp.trailing).offset(-8.auto())
                    make.centerY.equalTo(self.subVehicleParkedTitleLbl.snp.centerY)
                    make.size.equalTo(CGSize(width: 25, height: 25))
                })
            }
            lastHeight += 48.auto()
        }
        
        
        let rect = CGRect(x: 0, y: 0, width: Int(UIScreen.width) - 48.auto(), height: lastHeight)
        let rectCorner: UIRectCorner = UIRectCorner.allCorners
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 11.auto() , height: 11.auto() ))
        let maskLayer : CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.vehicelSubView.bounds
        maskLayer.path = path.cgPath
        self.vehicelSubView.layer.mask = maskLayer
        
        return subVehicleCellHeight
    }
    
    
    func configPackageSubTags(subTags: [FilterAiSubTag]) -> CGFloat {
        subPackageCellHeight = CGFloat(subTags.count * 48.auto())
        
        self.packageSubView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.iconImageV.snp.bottom).offset(11.5.auto())
            make.leading.equalTo(8.auto())
            make.trailing.equalTo(-8.auto())
            make.height.equalTo(subPackageCellHeight.auto())
        })
        
        var lastHeight = 0
        for subTag in subTags {
            if subTag.name == "package_drop_off" {
                
                self.subPackageDownImgView.snp.makeConstraints({(make) in
                    make.top.equalTo(lastHeight + 12.auto())
                    make.leading.equalTo(self.packageSubView.snp.leading).offset(48.auto())
                    make.width.height.equalTo(24.auto())
                })
                self.subPackageDownTitleLbl.isHidden = false
                self.subPackageDownTitleLbl.snp.makeConstraints({ (make) in
                    make.centerY.equalTo(self.subPackageDownImgView.snp.centerY)
                    make.leading.equalTo(self.iconImageV.snp.trailing).offset(15)
                    //make.leading.equalTo(self.subPackageDownImgView.snp.trailing).offset(16.auto())
                })
                self.subPackageDownCheckBtn.isHidden = false
                self.subPackageDownCheckBtn.snp.makeConstraints({ (make) in
                    make.trailing.equalTo(self.packageSubView.snp.trailing).offset(-8.auto())
                    make.centerY.equalTo(self.subPackageDownTitleLbl.snp.centerY)
                    make.size.equalTo(CGSize(width: 25, height: 25))
                })
            } else if subTag.name == "package_pick_up" {
                
                self.subPackageUpImgView.snp.makeConstraints({(make) in
                    make.top.equalTo(lastHeight + 12.auto())
                    make.centerX.equalTo(self.subPackageDownImgView.snp.centerX)
                    make.width.height.equalTo(24.auto())
                })
                self.subPackageUpTitleLbl.isHidden = false
                self.subPackageUpTitleLbl.snp.makeConstraints({ (make) in
                    make.centerY.equalTo(self.subPackageUpImgView.snp.centerY)
                    make.leading.equalTo(self.iconImageV.snp.trailing).offset(15)
                    //make.leading.equalTo(self.subPackageUpImgView.snp.trailing).offset(12.5.auto())
                })
                self.subPackageUpCheckBtn.isHidden = false
                self.subPackageUpCheckBtn.snp.makeConstraints({ (make) in
                    make.trailing.equalTo(self.packageSubView.snp.trailing).offset(-8.auto())
                    make.centerY.equalTo(self.subPackageUpTitleLbl.snp.centerY)
                    make.size.equalTo(CGSize(width: 25, height: 25))
                })
            } else if subTag.name == "package_exist" {
                
                self.subPackageDetainedImgView.snp.makeConstraints({(make) in
                    make.top.equalTo(lastHeight + 12.auto())
                    make.centerX.equalTo(self.subPackageDownImgView.snp.centerX)
                    make.width.height.equalTo(24.auto())
                })
                self.subPackageDetainedTitleLbl.isHidden = false
                self.subPackageDetainedTitleLbl.snp.makeConstraints({ (make) in
                    make.centerY.equalTo(self.subPackageDetainedImgView.snp.centerY)
                    make.leading.equalTo(self.iconImageV.snp.trailing).offset(15)
                    //make.leading.equalTo(self.subPackageDetainedImgView.snp.trailing).offset(12.5.auto())
                })
                self.subPackageDetainedCheckBtn.isHidden = false
                self.subPackageDetainedCheckBtn.snp.makeConstraints({ (make) in
                    make.trailing.equalTo(self.packageSubView.snp.trailing).offset(-8.auto())
                    make.centerY.equalTo(self.subPackageDetainedTitleLbl.snp.centerY)
                    make.size.equalTo(CGSize(width: 25, height: 25))
                })
            }
            lastHeight += 48.auto()
        }
        
        
        let rect = CGRect(x: 0, y: 0, width: Int(UIScreen.width) - 48.auto(), height: lastHeight)
        let rectCorner: UIRectCorner = UIRectCorner.allCorners
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 11.auto() , height: 11.auto() ))
        let maskLayer1 : CAShapeLayer = CAShapeLayer()
        maskLayer1.frame = self.packageSubView.bounds
        maskLayer1.path = path.cgPath
        self.packageSubView.layer.mask = maskLayer1
        
        return subPackageCellHeight
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.white
        
        
        self.subVehicelApproachingImgView.isHidden = true;
        self.subVehicleLeavingImgView.isHidden = true;
        self.subVehicleParkedImgView.isHidden = true;
        self.subPackageDownImgView.isHidden = true;
        self.subPackageUpImgView.isHidden = true;
        self.subPackageDetainedImgView.isHidden = true;
        
        
        self.contentView.addSubview(self.iconImageV)
        self.contentView.addSubview(self.aNameLable)
        self.contentView.addSubview(self.checkButton)
        
        self.contentView.addSubview(self.vehicelSubView)
        
        self.vehicelSubView.addSubview(self.subVehicelApproachingImgView)
        self.vehicelSubView.addSubview(self.subVehicelApproachingTitleLbl)
        self.subVehicelApproachingTitleLbl.isHidden = true
        self.vehicelSubView.addSubview(self.subVehicelApproachingCheckBtn)
        self.subVehicelApproachingCheckBtn.isHidden = true
        
        self.vehicelSubView.addSubview(self.subVehicleLeavingImgView)
        self.vehicelSubView.addSubview(self.subVehicleLeavingTitleLbl)
        self.subVehicleLeavingTitleLbl.isHidden = true
        self.vehicelSubView.addSubview(self.subVehicleLeavingCheckBtn)
        self.subVehicleLeavingCheckBtn.isHidden = true
        
        self.vehicelSubView.addSubview(self.subVehicleParkedImgView)
        self.vehicelSubView.addSubview(self.subVehicleParkedTitleLbl)
        self.subVehicleParkedTitleLbl.isHidden = true
        self.vehicelSubView.addSubview(self.subVehicleParkedCheckBtn)
        self.subVehicleParkedCheckBtn.isHidden = true
        
        
        self.contentView.addSubview(self.packageSubView)
        
        self.packageSubView.addSubview(self.subPackageDownImgView)
        self.packageSubView.addSubview(self.subPackageDownTitleLbl)
        self.subPackageDownTitleLbl.isHidden = true
        self.packageSubView.addSubview(self.subPackageDownCheckBtn)
        self.subPackageDownCheckBtn.isHidden = true
        
        self.packageSubView.addSubview(self.subPackageUpImgView)
        self.packageSubView.addSubview(self.subPackageUpTitleLbl)
        self.subPackageUpTitleLbl.isHidden = true
        self.packageSubView.addSubview(self.subPackageUpCheckBtn)
        self.subPackageUpCheckBtn.isHidden = true
        
        self.packageSubView.addSubview(self.subPackageDetainedImgView)
        self.packageSubView.addSubview(self.subPackageDetainedTitleLbl)
        self.subPackageDetainedTitleLbl.isHidden = true
        self.packageSubView.addSubview(self.subPackageDetainedCheckBtn)
        self.subPackageDetainedCheckBtn.isHidden = true
        
        
        self.iconImageV.snp.makeConstraints({ (make) in
            make.leading.equalTo(16.auto())
            make.top.equalTo(self.contentView.snp.top).offset(18.auto())
            make.size.equalTo(CGSize(width: 24.auto(), height: 24.auto()))
        })
        self.aNameLable.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.iconImageV.snp.trailing).offset(15)
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-80)
            make.centerY.equalTo(self.iconImageV.snp.centerY).offset(0)
        })
        self.checkButton.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-16.auto())
            make.centerY.equalTo(self.iconImageV.snp.centerY).offset(0)
            make.size.equalTo(CGSize(width: 25, height: 25))
        })
        
        
        self.contentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.leading.equalTo(16.auto())
            make.trailing.equalTo(-16.auto())
        }
        self.contentView.layoutIfNeeded()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var iconImageV : UIImageView = {
        var temp : UIImageView = UIImageView()
        temp.contentMode = .center

        return temp
    }()
    
    private lazy var aNameLable: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "test"
        temp.textColor = ADTheme.C1
        temp.font = ADTheme.B1
        return temp
    }()
    
    private lazy var checkButton : UIButton = {
        var temp = UIButton()
        temp.isUserInteractionEnabled = false
        temp.imageView?.contentMode = .center
        temp.setImage(bundleImageFromImageName("checkbox_unselect")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("filter_tag_select_icon"), for: UIControl.State.selected)
        return temp
    }()
    
    
    private lazy var vehicelSubView: UIView = {
        var temp = UIView()
        temp.backgroundColor = ADTheme.C6
        return temp
    }()
    
    
    private lazy var subVehicelApproachingImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("main_libary_package_down")?.rtlImage()
        return iv
    }()
    
    private lazy var subVehicelApproachingTitleLbl: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "vehicle_approaching")
        temp.textColor = ADTheme.C2
        temp.font = UIFont.regular(14)
        return temp
    }()
    
    private lazy var subVehicelApproachingCheckBtn : UIButton = {
        var temp = UIButton()
        temp.tag = 1
        temp.isUserInteractionEnabled = true
        temp.imageView?.contentMode = .center
        temp.setImage(bundleImageFromImageName("checkbox_unselect")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("filter_tag_select_icon"), for: UIControl.State.selected)
        temp.addTarget(self, action: #selector(checkCellClick(sender:)), for: .touchUpInside)
        return temp
    }()
    
    
    private lazy var subVehicleLeavingImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("main_libary_package_up")?.rtlImage()
        return iv
    }()
    
    private lazy var subVehicleLeavingTitleLbl: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "vehicle_leaving")
        temp.textColor = ADTheme.C2
        temp.font = UIFont.regular(14)
        return temp
    }()
    
    private lazy var subVehicleLeavingCheckBtn: UIButton = {
        var temp = UIButton()
        temp.tag = 2
        temp.isUserInteractionEnabled = true
        temp.imageView?.contentMode = .center
        temp.setImage(bundleImageFromImageName("checkbox_unselect")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("filter_tag_select_icon"), for: UIControl.State.selected)
        temp.addTarget(self, action: #selector(checkCellClick(sender:)), for: .touchUpInside)
        return temp
    }()
    
    
    private lazy var subVehicleParkedImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("main_libary_package_detained")?.rtlImage()
        return iv
    }()
    
    private lazy var subVehicleParkedTitleLbl: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "vehicle_parked")
        temp.textColor = ADTheme.C2
        temp.font = UIFont.regular(14)
        return temp
    }()
    
    private lazy var subVehicleParkedCheckBtn : UIButton = {
        var temp = UIButton()
        temp.tag = 3
        temp.isUserInteractionEnabled = true
        temp.imageView?.contentMode = .center
        temp.setImage(bundleImageFromImageName("checkbox_unselect")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("filter_tag_select_icon"), for: UIControl.State.selected)
        temp.addTarget(self, action: #selector(checkCellClick(sender:)), for: .touchUpInside)
        return temp
    }()
    
 
    
    private lazy var packageSubView: UIView = {
        var temp = UIView()
        temp.backgroundColor = ADTheme.C6
        return temp
    }()
    
    
    private lazy var subPackageDownImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("main_libary_package_down")?.rtlImage()
        return iv
    }()
    
    private lazy var subPackageDownTitleLbl: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "package_down")
        temp.textColor = ADTheme.C2
        temp.font = UIFont.regular(14)
        return temp
    }()
    
    private lazy var subPackageDownCheckBtn : UIButton = {
        var temp = UIButton()
        temp.tag = 1
        temp.isUserInteractionEnabled = true
        temp.imageView?.contentMode = .center
        temp.setImage(bundleImageFromImageName("checkbox_unselect")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("filter_tag_select_icon"), for: UIControl.State.selected)
        temp.addTarget(self, action: #selector(checkCellClick(sender:)), for: .touchUpInside)
        return temp
    }()
    
    
    private lazy var subPackageUpImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("main_libary_package_up")?.rtlImage()
        return iv
    }()
    
    private lazy var subPackageUpTitleLbl: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "package_up")
        temp.textColor = ADTheme.C2
        temp.font = UIFont.regular(14)
        return temp
    }()
    
    private lazy var subPackageUpCheckBtn: UIButton = {
        var temp = UIButton()
        temp.tag = 2
        temp.isUserInteractionEnabled = true
        temp.imageView?.contentMode = .center
        temp.setImage(bundleImageFromImageName("checkbox_unselect")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("filter_tag_select_icon"), for: UIControl.State.selected)
        temp.addTarget(self, action: #selector(checkCellClick(sender:)), for: .touchUpInside)
        return temp
    }()
    
    
    private lazy var subPackageDetainedImgView: UIImageView = {
        var iv: UIImageView = UIImageView()
        iv.image = bundleImageFromImageName("main_libary_package_detained")?.rtlImage()
        return iv
    }()
    
    private lazy var subPackageDetainedTitleLbl: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "package_detained")
        temp.textColor = ADTheme.C2
        temp.font = UIFont.regular(14)
        return temp
    }()
    
    private lazy var subPackageDetainedCheckBtn : UIButton = {
        var temp = UIButton()
        temp.tag = 3
        temp.isUserInteractionEnabled = true
        temp.imageView?.contentMode = .center
        temp.setImage(bundleImageFromImageName("checkbox_unselect")?.rtlImage(), for: UIControl.State.normal)
        temp.setImage(bundleImageFromImageName("filter_tag_select_icon"), for: UIControl.State.selected)
        temp.addTarget(self, action: #selector(checkCellClick(sender:)), for: .touchUpInside)
        return temp
    }()
    
    @objc func checkCellClick(sender: UIButton) {
        self.protocol?.checkCellClick(sender: sender, indexPath: self.indexPath ?? IndexPath(row: 0, section: 0))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //Get the width of tableview
        let width = subviews[0].frame.width

        for view in subviews where view != contentView {
            //for top and bottom separator will be same width with the tableview width
            //so we check at here and remove accordingly
            if view.frame.width == width && view.minY == 0 {
                view.removeFromSuperview()
            }
        }
    }
}
