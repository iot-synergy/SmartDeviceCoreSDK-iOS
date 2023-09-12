//


//


//

import UIKit
import SmartDeviceCoreSDK

//MARK: ----- 左边距 -----
let A4xDeviceSettingModuleLeftPadding_LevelMain = 16.auto()
let A4xDeviceSettingModuleLeftPadding_LevelNotification = 0.auto()
let A4xDeviceSettingModuleLeftPadding_LevelOther = 48.auto()

//MARK: ----- 各模块高度 -----

let A4xDeviceSettingModuleCellHeight = 60.auto()

let A4xDeviceSettingModuleCellHeight_SelectionBox = 44.auto()

let A4xDeviceSettingModuleCellHeight_InformationBar = 56.auto()

let A4xDeviceSettingModuleCellHeight_Slider = 100.auto()

let A4xDeviceSettingModuleCellTopPadding = 8.auto()

@objc public class A4xDeviceSettingModuleTool: NSObject {
    
    //MARK: ----- 以下是动态计算高度的方法 -----
    
    public static let screenWidth = UIScreen.main.bounds.width
    public static let textWidth : CGFloat = screenWidth - 32.auto()
    public static let introduceWidth : CGFloat = screenWidth - 48.auto()
    
    //MARK: -----  获取整个cell需要展示的高度 -----
    public func getCellHeight(moduleModel: A4xDeviceSettingModuleModel, fontSize: CGFloat = 13, textWidth: CGFloat = textWidth, isBold: Bool = false) -> CGFloat
    {
        var height = 0.0
        let moduleHeight = self.getModuleHeight(moduleModel: moduleModel)
        height = height + moduleHeight
        
        if moduleModel.isShowContent == true {
            let contentHeight = self.getContentHeight(moduleModel: moduleModel, fontSize: fontSize, textWidth: textWidth, isBold: isBold)
            height = height + contentHeight.auto()
        }
        

        return height
    }
    
    //MARK: -----  获取子模型数组需要展示的高度 -----
    public func getSubModelsHeight(moduleModel: A4xDeviceSettingModuleModel) -> CGFloat
    {
        var height = 0.0
        
        let subModuleModels = moduleModel.subModuleModels
        if subModuleModels.count > 0
        {
            for i in 0..<subModuleModels.count {
                let subModel = subModuleModels.getIndex(i)
                height = height + self.getSubUintHeight(moduleModel: subModel ?? A4xDeviceSettingModuleModel())
            }
        } else {
            
        }
        return height
    }
    
    
    public func getModuleHeight(moduleModel: A4xDeviceSettingModuleModel) -> CGFloat
    {
        var height = 0.0
        height = height + self.getSubUintHeight(moduleModel: moduleModel)
        
        let subModuleModels = moduleModel.subModuleModels
        if subModuleModels.count > 0
        {
            for i in 0..<subModuleModels.count {
                let subModel = subModuleModels.getIndex(i)
                height = height + self.getSubUintHeight(moduleModel: subModel ?? A4xDeviceSettingModuleModel())
            }
            
            height = height + A4xDeviceSettingModuleCellTopPadding
        } else {
            
        }
        return height
    }
    
    //MARK: ----- 获取底部Content的高度 -----
    public func getContentHeight(moduleModel: A4xDeviceSettingModuleModel, fontSize: CGFloat = 13, textWidth: CGFloat = textWidth, isBold: Bool = false) -> CGFloat
    {
        let isShowContent = moduleModel.isShowContent
        let content = moduleModel.content
        var contentHeight = 0.0
        
        contentHeight = content.textHeightFromTextString(text: content, textWidth: textWidth, fontSize: fontSize, isBold: isBold) + 3.auto() + 8.auto()
        
        return contentHeight
    }
    
    //MARK: ----- 获取介绍的高度 -----
    public func getIntroduceHeight(moduleModel: A4xDeviceSettingModuleModel, fontSize: CGFloat = 13, textWidth: CGFloat = introduceWidth, isBold: Bool = false) -> CGFloat 
    {
        let isShowIntroduce = moduleModel.isShowIntroduce
        let introduce = moduleModel.introduce
        var introduceHeight = 0.0
        if isShowIntroduce == true {
            introduceHeight = introduce.textHeightFromTextString(text: introduce, textWidth: textWidth, fontSize: fontSize, isBold: isBold) + 3.auto() + A4xDeviceSettingModuleCellTopPadding
        }
        //
        return introduceHeight
    }
    
    //MARK: ----- 获取标题介绍的高度 -----
    public func getTitleDesHeight(moduleModel: A4xDeviceSettingModuleModel, fontSize: CGFloat = 13, textWidth: CGFloat = introduceWidth, isBold: Bool = false) -> CGFloat
    {
        let isShowTitleDescription = moduleModel.isShowTitleDescription
        let titleDescription = moduleModel.titleDescription
        var titleDesHeight = 0.0
        if isShowTitleDescription == true {
            titleDesHeight = titleDescription.textHeightFromTextString(text: titleDescription, textWidth: textWidth, fontSize: fontSize, isBold: isBold) + 3.auto() + A4xDeviceSettingModuleCellTopPadding
        }
        




             
        
        return titleDesHeight
    }
    
    //MARK: ----- 获取某个组件高度 -----
    
    public func getSubUintHeight(moduleModel: A4xDeviceSettingModuleModel) -> CGFloat {
        let moduleType = moduleModel.moduleType
        let isShowIntroduce = moduleModel.isShowIntroduce
        let isShowContent = moduleModel.isShowContent
        let isShowTitleDescription = moduleModel.isShowTitleDescription
        var height = 0.0
        switch moduleType {
        case .Switch:
            if isShowTitleDescription == false {
                
                if isShowIntroduce == true {
                    
                    height = A4xDeviceSettingModuleCellHeight + self.getIntroduceHeight(moduleModel: moduleModel)
                } else {
                    height = A4xDeviceSettingModuleCellHeight
                }
            } else {
                
                if isShowIntroduce == true {
                    
                    height = 44.auto() + self.getTitleDesHeight(moduleModel: moduleModel) + self.getIntroduceHeight(moduleModel: moduleModel) + 5.auto()
                } else {
                    height = 44.auto() + self.getTitleDesHeight(moduleModel: moduleModel) + 5.auto()
                }
            }
            break
        case .Enumeration:
            fallthrough
        case .TextInputBox:
            fallthrough
        case .Normal:
            if isShowIntroduce == true && moduleModel.moduleLevelType == .Main {
                
                height = A4xDeviceSettingModuleCellHeight + self.getIntroduceHeight(moduleModel: moduleModel)
            } else {
                height = A4xDeviceSettingModuleCellHeight
            }
            break
        case .SelectionBox:
            height = A4xDeviceSettingModuleCellHeight_SelectionBox
            break
        case .InformationBar:
            height = A4xDeviceSettingModuleCellHeight_InformationBar
            break
        case .MultiTextSelectionBox:
            
            height = 16.auto() + 22.4.auto() + 4.auto() + self.getTitleDesHeight(moduleModel: moduleModel)
            //
            break
        case .Slider:
            height = A4xDeviceSettingModuleCellHeight_Slider
            break
        case .MoreInfo:
            
            if isShowTitleDescription == false {
                height = A4xDeviceSettingModuleCellHeight
            } else {
                
                height = CGFloat(59.5).auto() + self.getTitleDesHeight(moduleModel: moduleModel)
            }
            break
        case .VipInfo:
            
            height = CGFloat(252).auto() + self.getTitleDesHeight(moduleModel: moduleModel)
            break
        case .ContentSwitch:
            
            if isShowTitleDescription == false {
                height = A4xDeviceSettingModuleCellHeight
            } else {
                
                height = CGFloat(36.5).auto() + self.getTitleDesHeight(moduleModel: moduleModel) + 5.auto()
            }
            break
        case .ArrowPoint:
            
            if isShowTitleDescription == false {
                height = A4xDeviceSettingModuleCellHeight
            } else {
                
                height = CGFloat(49).auto() + self.getTitleDesHeight(moduleModel: moduleModel)
            }
            break
        case .CheckBoxTitle:
            
            if isShowTitleDescription == false {
                height = A4xDeviceSettingModuleCellHeight
            } else {
                
                height = CGFloat(49).auto() + self.getTitleDesHeight(moduleModel: moduleModel) + 8.auto()
            }
            break
        case .Advertisement:
            
            let titleHeight = moduleModel.title.textHeightFromTextString(text: moduleModel.title, textWidth: 124.auto(), fontSize: 18, isBold: true) + 1
            let leftViewHeight = titleHeight + 8.auto() + 26.auto()
            let rightImageHeight = 82.auto()
            if leftViewHeight >= rightImageHeight {
                height = leftViewHeight + 16.auto()
            } else {
                height = rightImageHeight + 16.auto()
            }
            break
        default:
            height = A4xDeviceSettingModuleCellHeight
            break
        }
        
        return height
    }
    
    
    //MARK: ----- 创建对象的方法 -----
    
    /*
     
     let personSubModuleModel = tool.createMuduleModel(moduleType: .SelectionBox, currentType: .PersonNoti, title: A4xBaseManager.shared.getLocalString(key: "notifications"), titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: choice, isSelectionBoxLoading: false, isNetWorking: self.isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
     
     
     
     */
    
    
    @objc public func createBaseCheckBoxModel(moduleType: A4xDeviceSettingModuleType, currentType: A4xDeviceSettingCurrentType, title: String, isSelected: Bool, isNetWorking: Bool, at_leat: Int = 0, at_most: Int = 1) -> A4xDeviceSettingModuleModel
    {
        
        let boxModel = self.createMuduleModel(moduleType: moduleType, currentType: .Normal, title: title, titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Notification, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: isSelected, isSelectionBoxLoading: false, isNetWorking: isNetWorking, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
        boxModel.at_leat = at_leat
        boxModel.at_most = at_most
        return boxModel
    }
    
    
    @objc public func createBaseEnumModel(moduleType: A4xDeviceSettingModuleType, currentType: A4xDeviceSettingCurrentType, title: String, titleContent: String,  enumDataSource: Array<A4xDeviceSettingEnumAlertModel>) -> A4xDeviceSettingModuleModel
    {
        let enumModel = self.createMuduleModel(moduleType: moduleType, currentType: currentType, title: title, titleContent: titleContent, isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: enumDataSource, iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
        return enumModel
    }
    
    
    @objc public func createBaseSwitchModel(moduleType: A4xDeviceSettingModuleType, currentType: A4xDeviceSettingCurrentType, title: String, isSwitchOpen: Bool, isSwitchLoading: Bool) -> A4xDeviceSettingModuleModel
    {
        let baseSwitchModel = self.createMuduleModel(moduleType: moduleType, currentType: currentType, title: title, titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: isSwitchOpen, isSwitchLoading: isSwitchLoading, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
        return baseSwitchModel
    }
    
    
    @objc public func createBaseArrowPointModel(moduleType: A4xDeviceSettingModuleType, currentType: A4xDeviceSettingCurrentType, title: String, isInteractiveHidden: Bool) -> A4xDeviceSettingModuleModel
    {
        let baseArrowModel = self.createMuduleModel(moduleType: moduleType, currentType: currentType, title: title, titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: isInteractiveHidden, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
        return baseArrowModel
    }
    
    
    @objc public func createBaseSliderModel(moduleType: A4xDeviceSettingModuleType, currentType: A4xDeviceSettingCurrentType, title: String, titleContent: String, leftImage: String, rightImage: String, sliderValue: Float, scale: Float, minValue: Float, maxValue: Float, isNormalSlider: Bool) -> A4xDeviceSettingModuleModel
    {
        let baseArrowModel = self.createMuduleModel(moduleType: moduleType, currentType: currentType, title: title, titleContent: titleContent, isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: leftImage, rightImage: rightImage, sliderValue: sliderValue, scale: scale, minValue: minValue, maxValue: maxValue, isNormalSlider: isNormalSlider)
        return baseArrowModel
    }
    
    
    @objc public func createBaseInformationModel(moduleType: A4xDeviceSettingModuleType, currentType: A4xDeviceSettingCurrentType, title: String, leftImage: String, rightImage: String) -> A4xDeviceSettingModuleModel
    {
        let informationModel = self.createMuduleModel(moduleType: moduleType, currentType: currentType, title: title, titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: leftImage, rightImage: rightImage)
        return informationModel
    }
    
    
    @objc public func createBaseMultiTextSelectionBoxModel(moduleType: A4xDeviceSettingModuleType, currentType: A4xDeviceSettingCurrentType, title: String, titleDescription: String, isShowTitleDescription: Bool) -> A4xDeviceSettingModuleModel
    {
        let baseMultiTextModel = self.createMuduleModel(moduleType: moduleType, currentType: currentType, title: title, titleContent: "", isShowTitleDescription: isShowTitleDescription, titleDescription: titleDescription, subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: "", leftImage: "", rightImage: "")
        return baseMultiTextModel
    }
    
    
    @objc public func createBaseAdvertisementModel(moduleType: A4xDeviceSettingModuleType, currentType: A4xDeviceSettingCurrentType, title: String, buttonTitle: String, rightImage: String) -> A4xDeviceSettingModuleModel
    {
        let advertisementModel = self.createMuduleModel(moduleType: moduleType, currentType: currentType, title: title, titleContent: "", isShowTitleDescription: false, titleDescription: "", subModuleModels: [], moduleLevelType: .Main, isShowContent: false, content: "", isShowSeparator: false, isShowIntroduce: false, introduce: "", isInteractiveHidden: false, isSwitchOpen: false, isSwitchLoading: false, isSelected: false, isSelectionBoxLoading: false, isNetWorking: false, enumDataSource: [], iconPath: "", buttonTitle: buttonTitle, leftImage: "", rightImage: rightImage)
        return advertisementModel
    }
    
    /**
     * 参数
     * @param `moduleType`            : 模块类型,`Switch``SelectionBox`等
     * @param `currentType`              : 通知类型,`BirdsFans``NotiMode`等
     * @param `title`                 : 模块左侧标题内容
     * @param `titleContent`          : 模块左侧标题后面 显示
     * @param `isShowTitleDescription`: 是否展示标题描述信息
     * @param `titleDescription`      : 标题描述信息内容
     * @param `subModuleModels`       : 子模块数据源,没有的话传[]
     * @param `moduleLevelType`       : 模块级别类型,一级模块传`.Main`,通知子模块传`.Notification`
     * @param `isShowContent`         : 是否展示底部的描述内容,对应`content`
     * @param `content`               : 底部的描述内容
     * @param `isShowSeparator`       : 是否展示底部的分割线
     * @param `isShowIntroduce`       : 是否展示`title`下面的简介,对应`introduce`
     * @param `introduce`             : `title`下面的简介内容
     * @param `isInteractiveHidden`   : 是否只展示title,隐藏后面的交互按钮,目前只有`Switch`类型可用
     * ----- 以下是对应模块类型`moduleType`的数据源 -----
     * `Switch`
     * @param `isSwitchOpen`          : 是否开启开关
     * @param `isSwitchLoading`       : 开关是否Loading
     * `SelectionBox`
     * @param `isSelected`            : 是否选中
     * @param `isSelectionBoxLoading` : 选择框是否Loading
     * @param `isNetWorking`          : 数据是否处于更新中
     * `Enumeration`
     * @param `enumDataSource`        : 枚举数据源
     * `ContentSwitch`
     * @param `iconPath`              : 本地icon路径
     * `MoreInfo`
     * @param `buttonTitle`           : 按钮标题
     * `VipInfo`
     * @param `leftImage`             : 左侧图片
     * @param `rightImage`            : 右侧图片
     * `Slider`
     * @param `sliderValue`           : 当前值
     * @param `scale`                 : 刻度
     * @param `minValue`              : 最小值
     * @param `maxValue`              : 最大值
     */
    public func createMuduleModel(moduleType: A4xDeviceSettingModuleType, currentType: A4xDeviceSettingCurrentType, title: String, titleContent: String, isShowTitleDescription: Bool , titleDescription: String, subModuleModels: Array<A4xDeviceSettingModuleModel>, moduleLevelType: A4xDeviceSettingModuleLevelType, isShowContent: Bool, content: String, isShowSeparator: Bool, isShowIntroduce: Bool, introduce: String, isInteractiveHidden: Bool, isSwitchOpen: Bool, isSwitchLoading: Bool, isSelected: Bool, isSelectionBoxLoading: Bool, isNetWorking: Bool, enumDataSource: Array<A4xDeviceSettingEnumAlertModel>, iconPath: String, buttonTitle: String, leftImage: String, rightImage: String, sliderValue: Float = 1.0, scale: Float = 1.0, minValue: Float = 0.0, maxValue: Float = 100.0, isNormalSlider: Bool = true) -> A4xDeviceSettingModuleModel {
        let moduleModel = A4xDeviceSettingModuleModel()
        moduleModel.moduleType = moduleType
        moduleModel.currentType = currentType
        moduleModel.title = title
        moduleModel.titleContent = titleContent
        moduleModel.isShowTitleDescription = isShowTitleDescription
        moduleModel.titleDescription = titleDescription
        moduleModel.subModuleModels = subModuleModels
        moduleModel.moduleLevelType = moduleLevelType
        moduleModel.isShowContent = isShowContent
        moduleModel.content = content
        moduleModel.isShowSeparator = isShowSeparator
        moduleModel.isShowIntroduce = isShowIntroduce
        moduleModel.introduce = introduce
        moduleModel.isInteractiveHidden = isInteractiveHidden
        
        moduleModel.isSwitchOpen = isSwitchOpen
        moduleModel.isSwitchLoading = isSwitchLoading
        
        moduleModel.isSelected = isSelected
        moduleModel.isSelectionBoxLoading = isSelectionBoxLoading
        moduleModel.isNetWorking = isNetWorking
        
        moduleModel.enumDataSource = enumDataSource
        
        moduleModel.iconPath = iconPath
        
        moduleModel.buttonTitle = buttonTitle
        
        moduleModel.leftImage = leftImage
        moduleModel.rightImage = rightImage
        
        moduleModel.sliderValue = sliderValue
        moduleModel.scale = scale
        moduleModel.minValue = minValue
        moduleModel.maxValue = maxValue
        moduleModel.isNormalSlider = isNormalSlider
        
        
        let tool = A4xDeviceSettingModuleTool()
        moduleModel.cellHeight = tool.getCellHeight(moduleModel: moduleModel)
        moduleModel.contentHeight = tool.getContentHeight(moduleModel: moduleModel)
        moduleModel.moduleHeight = tool.getModuleHeight(moduleModel: moduleModel)
        
        return moduleModel
    }
    
    //MARK: ----- 根据后端给的类型,获取对应的模块类型 -----
    @objc public func getModuleType(type: String) -> A4xDeviceSettingModuleType
    {
        var moduleType : A4xDeviceSettingModuleType = .Normal
        if type == "TEXT" {
            moduleType = .ArrowPoint
        } else if type == "SWITCH" {
            moduleType = .Switch
        } else if type == "ENUM" {
            moduleType = .Enumeration
        } else if type == "CHECKBOX" {
            
            moduleType = .CheckBox
        } else if type == "INT_RANGE" {
            
            moduleType = .Slider
        }
        return moduleType
    }
    
    
    public func getValueOrOption(anyCodable: ModifiableAnyAttribute) -> AnyObject {
        return anyCodable.value as AnyObject
    }
    
    
    @objc public func sortModuleArray(moduleArray: Array<A4xDeviceSettingModuleModel>) -> Array<A4xDeviceSettingModuleModel>
    {
        var tempModuleArray = moduleArray
        
        if moduleArray.count < 1 {
            return []
        } else {
            if moduleArray.count == 1
            {
                tempModuleArray = moduleArray
            }
            else{
                
                for i in 0...(tempModuleArray.count - 2) { //n个数进行排序，只要进行（n - 1）轮操作
                    for j in 0...(tempModuleArray.count - i - 2){ //开始一轮操作
                        let tempModule_j = tempModuleArray[j]
                        let tempModule_j1 = tempModuleArray[j+1]
                        
                        if tempModule_j.currentType.rawValue > tempModule_j1.currentType.rawValue {
                            //交换位置
                            let temp = tempModuleArray[j]
                            tempModuleArray[j] = tempModuleArray[j + 1]
                            tempModuleArray[j + 1] = temp;
                        }
                    }
                }
            }
        }
        return tempModuleArray
    }
    
    //MARK: ----- 获取枚举Cases数据 -----
    public func getEnumCases(currentType: A4xDeviceSettingCurrentType, modifiableAttributeModel : A4xDeviceSettingModifiableAttributesModel, modelCategory: Int? = 0) -> [A4xDeviceSettingEnumAlertModel] {
        
        var allCase : [A4xDeviceSettingEnumAlertModel] = []
        let options = modifiableAttributeModel.options
        
        let disabledOptions = modifiableAttributeModel.disabledOptions
        switch currentType {
        case .UseLocation:
            let deviceOptions = self.getValueOrOption(anyCodable: options ?? ModifiableAnyAttribute()) as? [A4xDeviceSettingUnitModel]
        case .NotiMode:
            fallthrough
        case .PirSensitivity:
            fallthrough
        case .PirRecordTime:
            fallthrough
        case .AntiFlickerFrequency:
            fallthrough
        case .VideoResolution:
            fallthrough
        case .AlarmDuration:
            fallthrough
        case .PowerSource:
            fallthrough
        case .NightVisionMode:
            fallthrough
        case .NightVisionSensitivity:
            fallthrough
        case .SDCardVideoModes:
            fallthrough
        case .SDCardCooldownSeconds:
            fallthrough
        case .PirCooldownTime:
            let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: modelCategory ?? 0)
            let deviceOptions = self.getValueOrOption(anyCodable: options ?? ModifiableAnyAttribute()) as? [String]
            let deviceDisabledOptions = self.getValueOrOption(anyCodable: disabledOptions ?? ModifiableAnyAttribute()) as? [String]
            
            






            
            if let deviceOptions = self.getValueOrOption(anyCodable: options ?? ModifiableAnyAttribute()) as? [String],
                let deviceDisabledOptions = self.getValueOrOption(anyCodable: disabledOptions ?? ModifiableAnyAttribute()) as? [String] {
                let tempArray = deviceOptions.filter { !deviceDisabledOptions.contains($0) }
                
                
                for i in 0..<(tempArray.count) {
                    let enumModel = A4xDeviceSettingEnumAlertModel()
                    let key = self.getModifiableAttributeTypeName(currentType: currentType) + "_options_" + (tempArray.getIndex(i) ?? "")
                    
                    let content = A4xBaseManager.shared.getLocalString(key: key)
                    enumModel.content = content
                    enumModel.requestContent = tempArray.getIndex(i)
                    enumModel.isEnable = true
                    enumModel.descriptionContent = ""
                    if currentType == .NightVisionMode {
                        if tempArray.getIndex(i) == "infrared" {
                            enumModel.descriptionContent = A4xBaseManager.shared.getLocalString(key: "infrared_des")
                        } else if tempArray.getIndex(i) == "white" {
                            enumModel.descriptionContent = A4xBaseManager.shared.getLocalString(key: "whitelight_des")
                        }
                    } else if currentType == .PirRecordTime {
                        if tempArray.getIndex(i) == "auto" {
                            enumModel.descriptionContent = A4xBaseManager.shared.getLocalString(key: "auto_video_record_desc", param: [tempString])
                        }
                    }
                        
                    if content.isBlank != true {
                        
                        allCase.append(enumModel)
                    }
                }
            }
        default:
            break
        }
        
        return allCase
    }
    
    //MARK: ----- 根据类型获取对应后端的name -----
    @objc public func getModifiableAttributeTypeName(currentType: A4xDeviceSettingCurrentType) -> String {
        
        var name : String
        switch currentType {
        case .NotiMode:
            name = "doorbellPressNotifyType"
        case .PirSensitivity:
            name = "pirSensitivity"
        case .PirRecordTime:
            name = "pirRecordTime"
        case .PirCooldownTime:
            name = "pirCooldownTime"
        case .AntiFlickerFrequency:
            name = "videoAntiFlickerFrequency"
        case .VideoResolution:
            name = "videoResolution"
        case .PowerSource:
            name = "powerSource"
        case .DeviceLanguage:
            name = "voiceLanguage"
        case .DoorbellRing:
            name = "doorBellRing"
        case .NightVisionMode:
            name = "nightVisionMode"
        case .NightVisionSensitivity:
            name = "nightVisionSensitivity"
        case .AlarmDuration:
            name = "alarmDuration"
        case .SDCardVideoModes:
            name = "sdCardVideoModes"
        case .SDCardCooldownSeconds:
            name = "sdCardCooldownSeconds"
        default:
            name = ""
        }
        return name
    }
    
    //MARK: ----- CHECKBOX类型获取子Model -----
    
    public func getCheckBoxSubModels(modelCategory: Int, attrModel: A4xDeviceSettingModifiableAttributesModel, isNetWorking: Bool) -> A4xDeviceSettingModuleModel {
        
        let tempString = A4xBaseManager.shared.getDeviceTypeString(deviceModelCategory: modelCategory)
        
        let type = attrModel.type
        let name = attrModel.name ?? ""
        var module : A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
        var subModels : [A4xDeviceSettingModuleModel] = []
        
        switch type {
        case "CHECKBOX":
            
            let options = attrModel.options
            let optionsArray = self.getValueOrOption(anyCodable: options ?? ModifiableAnyAttribute()) as? [A4xDeviceSettingUnitModel]
            let pirAIModel = optionsArray?[0] ?? A4xDeviceSettingUnitModel()
            
            let checkables = pirAIModel.checkables ?? []
            
            let values = attrModel.value
            let valuesArray = self.getValueOrOption(anyCodable: values ?? ModifiableAnyAttribute()) as? [String] ?? []
            
            subModels = self.getCheckBoxModels(name: name,unitModel: pirAIModel ,isNetWorking: isNetWorking, values: valuesArray)
            
            switch name {
            case "pirAi":
                
                let detectPreferenceModule = self.createBaseArrowPointModel(moduleType: .CheckBoxTitle, currentType: .PirDetectPreference, title: A4xBaseManager.shared.getLocalString(key: "detection_preference"), isInteractiveHidden: true)
                detectPreferenceModule.at_leat = pirAIModel.at_leat
                detectPreferenceModule.at_most = pirAIModel.at_most
                detectPreferenceModule.isShowTitleDescription = true
                detectPreferenceModule.titleDescription = A4xBaseManager.shared.getLocalString(key: "detection_preference_subtext", param: [tempString, tempString])
                detectPreferenceModule.subModuleModels = subModels
                
                detectPreferenceModule.cellHeight = self.getCellHeight(moduleModel: detectPreferenceModule)
                detectPreferenceModule.moduleHeight = self.getModuleHeight(moduleModel: detectPreferenceModule)
                detectPreferenceModule.contentHeight = self.getContentHeight(moduleModel: detectPreferenceModule)
                module = detectPreferenceModule
            default:
                break
            }
            
            break
        default:
            break
        }
        return module
    }

    //MARK: ----- 分割线颜色 -----
    @objc public func getSeparatorColor() -> UIColor {
        return UIColor.init(red: 232/255, green: 232/255, blue: 232/255, alpha: 1)
    }
    
    //MARK: ----- 给两个数组,返回对象 -----
    public func getCheckBoxModels(name: String, unitModel: A4xDeviceSettingUnitModel, isNetWorking: Bool, values: [String]) -> [A4xDeviceSettingModuleModel] {
        
        let checkables = unitModel.checkables
        var checkBoxModel : A4xDeviceSettingModuleModel = A4xDeviceSettingModuleModel()
        
        var subModels : [A4xDeviceSettingModuleModel] = []
        
        var isSelected = false
        
        var dic : [String: String] = ["":""]
        
        if values.count > 0 {
            for i in 0..<values.count {
                let value = values.getIndex(i) ?? ""
                dic[value] = "temp_\(value)"
            }
            for i in 0..<(checkables?.count ?? 0) {
                
                let checkable = checkables?.getIndex(i) ?? ""
                
                let currentType = self.getCheckBoxCurrentType(checkable: checkable)
                
                let titleKey = name + "_options_" + checkable
                let title = A4xBaseManager.shared.getLocalString(key: titleKey)
                
                if "temp_\(checkable)" == dic[checkable] {
                    
                    isSelected = true
                } else {
                    isSelected = false
                }
                
                checkBoxModel = self.createBaseCheckBoxModel(moduleType: .SelectionBox, currentType: currentType, title: title, isSelected: isSelected, isNetWorking: isNetWorking, at_leat: unitModel.at_leat ?? 0, at_most: unitModel.at_most ?? 1)
                checkBoxModel.requestValue = checkable
                subModels.append(checkBoxModel)
            }
        } else {
            
            for i in 0..<(checkables?.count ?? 0) {
                
                let checkable = checkables?.getIndex(i) ?? ""
                
                let currentType = self.getCheckBoxCurrentType(checkable: checkable)
                
                let titleKey = name + "_options_" + checkable
                let title = A4xBaseManager.shared.getLocalString(key: titleKey)

                
                
                checkBoxModel = self.createBaseCheckBoxModel(moduleType: .SelectionBox, currentType: currentType, title: title, isSelected: false, isNetWorking: isNetWorking, at_leat: unitModel.at_leat ?? 0, at_most: unitModel.at_most ?? 1)
                checkBoxModel.requestValue = checkable
                subModels.append(checkBoxModel)
            }
        }
        
        return subModels
        
    }
    
    @objc public func getCheckBoxCurrentType(checkable: String) -> A4xDeviceSettingCurrentType {
        switch checkable {
        case "detectPersonAI":
            return .PirDetectPersonAI
        case "detectPetAI":
            return .PirDetectPetAI
        default:
            return .Normal
        }
    }
}
