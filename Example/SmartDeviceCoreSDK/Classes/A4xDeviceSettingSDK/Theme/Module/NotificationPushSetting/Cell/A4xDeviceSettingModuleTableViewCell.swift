//


//


//

import UIKit

@objc public protocol A4xDeviceSettingModuleTableViewCellDelegate : AnyObject {
    
    func A4xDeviceSettingModuleTableViewCellSwitchDidClick(indexPath: IndexPath, isOn: Bool)
    
    
    func A4xDeviceSettingModuleTableViewCellSelectionBoxDidClick(indexPath: IndexPath, index: Int)
    
    
    func A4xDeviceSettingModuleTableViewCellDidClick(indexPath: IndexPath)
    
    
    func A4xDeviceSettingModuleTableViewCellButtonDidClick(indexPath: IndexPath)
    
    
    func A4xDeviceSettingModuleTableViewCellSliderDidDrag(value: Float, indexPath: IndexPath)
}


@objc class A4xDeviceSettingModuleTableViewCell: UITableViewCell, A4xDeviceSettingModuleViewDelegate {
    
    
    public var indexPath : IndexPath?
    
    
    public weak var delegate: A4xDeviceSettingModuleTableViewCellDelegate?

    private var moduleModel: A4xDeviceSettingModuleModel?
    
    @objc override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear//UIColor.hex(0xF5F6FA)
    }
    
    convenience init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, moduleModel: A4xDeviceSettingModuleModel){
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.moduleModel = moduleModel
        //self.setCell(moduleModel: moduleModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var moduleView : A4xDeviceSettingModuleView = {
        let temp = A4xDeviceSettingModuleView.init(frame: CGRect.zero, moduleModel: self.moduleModel ?? A4xDeviceSettingModuleModel())
        temp.delegate = self
        self.contentView.addSubview(temp)
        let height = self.moduleModel?.moduleHeight.auto()
        temp.snp.makeConstraints({ (make) in
            make.top.height.equalTo(self.contentView)
            make.leading.equalTo(self.contentView.snp.leading).offset(8.auto())
            make.centerX.equalTo(self.contentView)
        })
        return temp
    }()
    
    
    @objc public func setCell(moduleModel: A4xDeviceSettingModuleModel, radiusType: A4xDeviceSettingModuleCornerRadiusType) {
        
        self.moduleView.updateUI(moduleModel: moduleModel, radiusType: radiusType)
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

    //MARK: ----- A4xDeviceSettingModuleViewDelegate -----
    
    func A4xDeviceSettingModuleViewSwitchDidClick(isOn: Bool)
    {
        if self.delegate != nil {
            self.delegate?.A4xDeviceSettingModuleTableViewCellSwitchDidClick(indexPath: self.indexPath ?? IndexPath(), isOn: isOn)
        }
    }
    
    
    func A4xDeviceSettingModuleViewSelectionBoxDidClick(index: Int)
    {
        if self.delegate != nil {
            self.delegate?.A4xDeviceSettingModuleTableViewCellSelectionBoxDidClick(indexPath: self.indexPath ?? IndexPath(), index: index)
        }
    }
    
    
    func A4xDeviceSettingModuleSubViewDidClick()
    {
        if self.delegate != nil {
            self.delegate?.A4xDeviceSettingModuleTableViewCellDidClick(indexPath: self.indexPath ?? IndexPath())
        }
    }
    
    func A4xDeviceSettingModuleViewButtonDidClick() {
        if self.delegate != nil {
            self.delegate?.A4xDeviceSettingModuleTableViewCellButtonDidClick(indexPath: self.indexPath ?? IndexPath())
        }
    }
    
    
    func A4xDeviceSettingModuleViewSliderDidDrag(value: Float)
    {
        if self.delegate != nil {
            self.delegate?.A4xDeviceSettingModuleTableViewCellSliderDidDrag(value: value, indexPath: self.indexPath ?? IndexPath())
        }
    }
    
}
