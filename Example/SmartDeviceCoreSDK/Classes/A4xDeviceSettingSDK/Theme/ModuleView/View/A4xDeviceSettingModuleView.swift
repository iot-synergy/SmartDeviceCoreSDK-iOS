

import UIKit
import SmartDeviceCoreSDK
import BaseUI

@objc public protocol A4xDeviceSettingModuleViewDelegate : AnyObject {
    
    func A4xDeviceSettingModuleViewSwitchDidClick(isOn: Bool)
    
    
    func A4xDeviceSettingModuleViewSelectionBoxDidClick(index: Int)
    
    
    func A4xDeviceSettingModuleSubViewDidClick()
    
    
    func A4xDeviceSettingModuleViewButtonDidClick()
    
    
    func A4xDeviceSettingModuleViewSliderDidDrag(value: Float)
}

@objc public class A4xDeviceSettingModuleView: UIView, A4xDeviceSettingModuleSliderViewDelegate {
    
    public weak var delegate: A4xDeviceSettingModuleViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, moduleModel: A4xDeviceSettingModuleModel){
        self.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: ----- 更新UI -----
    public func updateUI(moduleModel: A4xDeviceSettingModuleModel, radiusType: A4xDeviceSettingModuleCornerRadiusType) {
        
        
        for subView in self.subviews as [UIView] {
            subView.removeFromSuperview()
        }
        
        let backViewHeight = moduleModel.moduleHeight
        let backView = UIView()
        
        switch radiusType {
        case .All:
            backView.layer.masksToBounds = true
            backView.layer.cornerRadius = 12
            backView.layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue | CACornerMask.layerMinXMaxYCorner.rawValue | CACornerMask.layerMaxXMaxYCorner.rawValue)
        case .Top:
            backView.layer.masksToBounds = true
            backView.layer.cornerRadius = 12
            backView.layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue)
        case .Bottom:
            backView.layer.masksToBounds = true
            backView.layer.cornerRadius = 12
            backView.layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMaxYCorner.rawValue | CACornerMask.layerMaxXMaxYCorner.rawValue)
        case .None:
            break;
        }
        backView.backgroundColor = UIColor.white
        self.addSubview(backView)
        backView.snp.makeConstraints({ (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(backViewHeight)
        })
        
        let tool = A4xDeviceSettingModuleTool()
        
        let moduleType = moduleModel.moduleType
        
        switch moduleType {
        case .Switch:
            let switchView = self.createSwitchView()
            switchView.loadingSwitchView.loadingSwitch.addTarget(self, action: #selector(loadingSwitchValueDidChanged(sender:)), for: .valueChanged)
            backView.addSubview(switchView)
            switchView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(A4xDeviceSettingModuleCellHeight)
            })
            switchView.updateUI(moduleModel: moduleModel)
            break
        case .SelectionBox:
            let selectionBoxView = self.createSelectionBoxView()
            backView.addSubview(selectionBoxView)
            selectionBoxView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(A4xDeviceSettingModuleCellHeight_SelectionBox)
            })
            selectionBoxView.updateUI(moduleModel: moduleModel)
            break
        case .ArrowPoint:
            let arrowPointView = self.createArrowPointView()
            let arrowPointViewTapGR = UITapGestureRecognizer.init(target: self, action: #selector(arrowPointViewDidClick(sender: )))
            arrowPointView.addGestureRecognizer(arrowPointViewTapGR)
            backView.addSubview(arrowPointView)
            arrowPointView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(tool.getSubUintHeight(moduleModel: moduleModel))
            })
            arrowPointView.updateUI(moduleModel: moduleModel)
            break
        case .CheckBoxTitle:
            let checkboxTitleView = self.createCheckBoxTitleView()
            backView.addSubview(checkboxTitleView)
            checkboxTitleView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(tool.getSubUintHeight(moduleModel: moduleModel))
            })
            checkboxTitleView.updateUI(moduleModel: moduleModel)
            break
        case .Enumeration:
            let enumView = self.createEnumView()
            let enumViewTapGR = UITapGestureRecognizer.init(target: self, action: #selector(enumViewDidClick(sender: )))
            enumView.addGestureRecognizer(enumViewTapGR)
            backView.addSubview(enumView)
            enumView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(tool.getSubUintHeight(moduleModel: moduleModel))
            })
            enumView.updateUI(moduleModel: moduleModel)
            break
        case .TextInputBox:
            break
        case .MoreInfo:
            let moreInfoView = self.createMoreInfoView()
            moreInfoView.learnMoreButton.addTarget(self, action: #selector(buttonDidClicked(sender: )), for: .touchUpInside)
            backView.addSubview(moreInfoView)
            moreInfoView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(tool.getSubUintHeight(moduleModel: moduleModel))
            })
            moreInfoView.updateUI(moduleModel: moduleModel)
            break
        case .Slider:
            let sliderView = self.createSliderView()
            sliderView.delegate = self
            backView.addSubview(sliderView)
            sliderView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(tool.getSubUintHeight(moduleModel: moduleModel))
            })
            sliderView.updateUI(moduleModel: moduleModel)
            break
        case .ContentSwitch:
            let contentSwitchView = self.createContentSwitchView()
            contentSwitchView.loadingSwitchView.loadingSwitch.addTarget(self, action: #selector(loadingSwitchValueDidChanged(sender:)), for: .valueChanged)
            backView.addSubview(contentSwitchView)
            contentSwitchView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(tool.getSubUintHeight(moduleModel: moduleModel))
            })
            contentSwitchView.updateUI(moduleModel: moduleModel)
            break
        case .Pantilt:
            let pantiltCalibrationView = createPantiltCalibrationView()
            pantiltCalibrationView.calibrationButton.addTarget(self, action: #selector(buttonDidClicked(sender: )), for: .touchUpInside)
            backView.addSubview(pantiltCalibrationView)
            pantiltCalibrationView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(tool.getSubUintHeight(moduleModel: moduleModel))
            })
            pantiltCalibrationView.updateUI(moduleModel: moduleModel)
            break
        case .InformationBar:
            let informationView = self.createInformationBarView()
            let informationViewTapGR = UITapGestureRecognizer.init(target: self, action: #selector(enumViewDidClick(sender: )))
            informationView.addGestureRecognizer(informationViewTapGR)
            backView.addSubview(informationView)
            informationView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(tool.getSubUintHeight(moduleModel: moduleModel))
            })
            informationView.updateUI(moduleModel: moduleModel)
            break
        case .MultiTextSelectionBox:
            let selectionBoxView = self.createMultiTextSelectionBoxView()
            let selectionBoxViewTapGR = UITapGestureRecognizer.init(target: self, action: #selector(selectionBoxDidClick(sender: )))
            selectionBoxView.addGestureRecognizer(selectionBoxViewTapGR)
            backView.addSubview(selectionBoxView)
            selectionBoxView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(tool.getSubUintHeight(moduleModel: moduleModel))
            })
            selectionBoxView.updateUI(moduleModel: moduleModel)
            break
        case .Advertisement:
            let advertisementView = self.createAdvertisementView()
            
            advertisementView.leftView.goBuyButton.addTarget(self, action: #selector(buttonDidClicked(sender: )), for: .touchUpInside)
            let advertisementViewTapGR = UITapGestureRecognizer.init(target: self, action: #selector(arrowPointViewDidClick(sender: )))
            advertisementView.addGestureRecognizer(advertisementViewTapGR)
            backView.addSubview(advertisementView)
            advertisementView.snp.makeConstraints({ (make) in
                make.top.left.right.equalTo(self)
                make.height.equalTo(tool.getSubUintHeight(moduleModel: moduleModel))
            })
            advertisementView.updateUI(moduleModel: moduleModel)
            break
        case .Normal:
            break
        default:
            break
        }
        
        
        let subModuleModels = moduleModel.subModuleModels
        if subModuleModels.count > 0 {
            
            self.updateUI_level2(moduleModel: moduleModel, sourceView: backView)
        }
        
        
        let isShowContent = moduleModel.isShowContent
        if isShowContent == true {
            let content = moduleModel.content
            let contentHeight = moduleModel.contentHeight
            let contentLabel = UILabel()
            contentLabel.font = UIFont.systemFont(ofSize: 13)
            contentLabel.numberOfLines = 0
            contentLabel.textAlignment = .left
            contentLabel.textColor = ADTheme.C3
            self.addSubview(contentLabel)
            contentLabel.snp.makeConstraints { make in
                make.bottom.equalTo(self)
                make.leading.equalTo(self).offset(8.auto())
                make.centerX.equalTo(self)
                make.height.equalTo(contentHeight)
            }
            contentLabel.text = content
        }
    }
    
    //MARK: ----- 创建多个子模块 -----
    
    private func createSwitchView() -> A4xDeviceSettingModuleSwitchView
    {
        let temp = A4xDeviceSettingModuleSwitchView()
        return temp
    }
    
    
    private func createSliderView() -> A4xDeviceSettingModuleSliderView
    {
        let temp = A4xDeviceSettingModuleSliderView()
        return temp
    }
    
    
    private func createPantiltCalibrationView() -> A4xDeviceSettingModulePantiltCalibrationView
    {
        let temp = A4xDeviceSettingModulePantiltCalibrationView()
        return temp
    }
    
    
    private func createSelectionBoxView() -> A4xDeviceSettingModuleSelectionBoxView
    {
        let temp = A4xDeviceSettingModuleSelectionBoxView()
        return temp
    }
    
    
    private func createAdvertisementView() -> A4xDeviceSettingModuleAdvertisementView
    {
        let temp = A4xDeviceSettingModuleAdvertisementView()
        return temp
    }
    
    
    private func createInformationBarView() -> A4xDeviceSettingModuleInformationBarView
    {
        let temp = A4xDeviceSettingModuleInformationBarView()
        return temp
    }
    
    
    private func createMultiTextSelectionBoxView() -> A4xDeviceSettingModuleMultiTextSelectionBoxView
    {
        let temp = A4xDeviceSettingModuleMultiTextSelectionBoxView()
        return temp
    }
        
    
    private func createArrowPointView() -> A4xDeviceSettingModuleArrowPointView
    {
        let temp = A4xDeviceSettingModuleArrowPointView()
        return temp
    }
    
    
    private func createCheckBoxTitleView() -> A4xDeviceSettingModuleCheckBoxTitleView
    {
        let temp = A4xDeviceSettingModuleCheckBoxTitleView()
        return temp
    }
    
    
    private func createContentSwitchView() -> A4xDeviceSettingModuleContentSwitchView
    {
        let temp = A4xDeviceSettingModuleContentSwitchView()
        return temp
    }
    
    
    private func createMoreInfoView() -> A4xDeviceSettingModuleMoreInfoView
    {
        let temp = A4xDeviceSettingModuleMoreInfoView()
        return temp
    }
    
    
    private func createVipInfoView() -> UIView
    {
        let temp = UIView()
        return temp
    }
    
    
    private func createEnumView() -> A4xDeviceSettingModuleEnumView
    {
        let temp = A4xDeviceSettingModuleEnumView()
        return temp
    }
    
    //MARK: ----- 布局多个二级子组件 -----
    
    
    private func updateUI_level2(moduleModel: A4xDeviceSettingModuleModel, sourceView: UIView) {
        
        let tool = A4xDeviceSettingModuleTool()
        let topPadding = tool.getSubUintHeight(moduleModel: moduleModel)
        
        let backView = UIView()
        
        backView.backgroundColor = ADTheme.C6
        backView.layer.cornerRadius = 12.auto()
        backView.layer.masksToBounds = true
        sourceView.addSubview(backView)
        
        let backViewHeight = tool.getSubModelsHeight(moduleModel: moduleModel)
        backView.snp.makeConstraints({ (make) in
            make.top.equalTo(topPadding)
            make.centerX.equalTo(sourceView)
            make.leading.equalTo(self).offset(8.auto())
            make.height.equalTo(backViewHeight)
        })
        
        
        var tempTopPadding = topPadding
        
        let subModuleModels = moduleModel.subModuleModels
        for i in 0..<(subModuleModels.count) {
            let subModel = subModuleModels.getIndex(i)
            
            
            let moduleType = subModel?.moduleType
            switch moduleType {
            case .Switch:
                let switchView = self.createSwitchView()
                sourceView.addSubview(switchView)
                switchView.snp.makeConstraints({ (make) in
                    make.top.equalTo(tempTopPadding)
                    make.trailing.equalTo(backView)
                    make.leading.equalTo(backView).offset(40.auto())
                    make.height.equalTo(A4xDeviceSettingModuleCellHeight)
                })
                switchView.updateUI(moduleModel: subModel ?? A4xDeviceSettingModuleModel())
                tempTopPadding = tempTopPadding + A4xDeviceSettingModuleCellHeight
                break
            case .SelectionBox:
                let selectionBoxView = self.createSelectionBoxView()
                selectionBoxView.tag = 2200 + i
                let selectionBoxViewTapGR = UITapGestureRecognizer.init(target: self, action: #selector(selectionBoxDidClick(sender: )))
                selectionBoxView.addGestureRecognizer(selectionBoxViewTapGR)
                sourceView.addSubview(selectionBoxView)
                selectionBoxView.snp.makeConstraints({ (make) in
                    make.top.equalTo(tempTopPadding)
                    make.trailing.equalTo(backView)
                    make.leading.equalTo(backView).offset(40.auto())
                    make.height.equalTo(A4xDeviceSettingModuleCellHeight_SelectionBox)
                })
                selectionBoxView.updateUI(moduleModel: subModel ?? A4xDeviceSettingModuleModel())
                tempTopPadding = tempTopPadding + A4xDeviceSettingModuleCellHeight_SelectionBox
                break
            case .MultiTextSelectionBox:
                break
            case .InformationBar:
                break
            case .ArrowPoint:
                break
            case .Enumeration:
                break
            case .TextInputBox:
                break
            case .Slider:
                break
            case .VipInfo:
                break
            case .Normal:
                break
            default:
                break
            }
        }
    }
    
    //MARK: ----- 交互事件 -----
    @objc func loadingSwitchValueDidChanged(sender : UISwitch) {
        let isOn = sender.isOn
        if (self.delegate != nil) {
            self.delegate?.A4xDeviceSettingModuleViewSwitchDidClick(isOn: isOn)
        }
    }
    
    
    @objc func selectionBoxDidClick(sender: UITapGestureRecognizer)
    {
        let index = (sender.view?.tag ?? 2200) - 2200
        if (self.delegate != nil) {
            self.delegate?.A4xDeviceSettingModuleViewSelectionBoxDidClick(index: index)
        }
    }
    
    
    @objc func enumViewDidClick(sender: UITapGestureRecognizer)
    {
        if (self.delegate != nil) {
            self.delegate?.A4xDeviceSettingModuleSubViewDidClick()
        }
    }
    
    
    @objc func arrowPointViewDidClick(sender: UITapGestureRecognizer)
    {
        if (self.delegate != nil) {
            self.delegate?.A4xDeviceSettingModuleSubViewDidClick()
        }
    }
    
    //MARK: ---- 各个点击事件 -----
    
    @objc func buttonDidClicked(sender: UITapGestureRecognizer)
    {
        if self.delegate != nil {
            self.delegate?.A4xDeviceSettingModuleViewButtonDidClick()
        }
    }
    
    //MARK: ----- A4xDeviceSettingModuleSliderViewDelegate -----
    @objc public func A4xDeviceSettingModuleSliderViewDidDrag(value: Float)
    {
        if self.delegate != nil {
            
            self.delegate?.A4xDeviceSettingModuleViewSliderDidDrag(value: value)
        }
    }
}
