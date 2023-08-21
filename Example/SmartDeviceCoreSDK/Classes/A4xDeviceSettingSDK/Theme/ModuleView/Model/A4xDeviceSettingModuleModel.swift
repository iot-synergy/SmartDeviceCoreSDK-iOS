//


//






import UIKit

///MARK: ----- Cell圆角类型枚举 -----
@objc public enum A4xDeviceSettingModuleCornerRadiusType: Int {
    
    case None   = 0
    
    case Top    = 1
    
    case Bottom = 2
    
    case All    = 3
}

///MARK: ----- 模块类型枚举 -----
@objc public enum A4xDeviceSettingModuleType: Int {
    
    case Switch                = 0
    
    case SelectionBox          = 1
    
    case ArrowPoint            = 2
    
    case Enumeration           = 3
    
    case TextInputBox          = 4
    
    case Slider                = 5
    
    case MoreInfo              = 6
    
    case VipInfo               = 7
    
    case ContentSwitch         = 8
    
    case Pantilt               = 9
    
    case InformationBar        = 10
    
    case MultiTextSelectionBox = 11
    
    case CheckBoxTitle         = 12
    case CheckBox              = 13
    
    case Advertisement         = 14
    
    case Normal                = 100
}

///MARK: ----- 子模块级别枚举 -----

@objc public enum A4xDeviceSettingModuleLevelType: Int {
    
    case Main = 0
    
    case Notification = 1
    
    case Other = 2
}

///MARK: ----- 模块类型枚举 -----
@objc public enum A4xDeviceSettingCurrentType: Int {
    
    case Normal               = 0
    
   ///MARK: ----- 推送通知界面使用 -----
    
    case RingNoti             = 100
    case MotionOpen           = 101
    
    case NotiMode             = 102
    
    
    case BirdsFans            = 200
    
    case PushMerge            = 300
    
    
    case AiMotionNotiTag      = 400
    
    case ActivityZone         = 401
    
    case ContentAnalysis      = 402
    
    case PersonNoti           = 403
    
    case PetNoti              = 404
   ///MARK: ----- 车辆相关 -----
    
    case VehicleNoti          = 405
    
    case VehicleNotiMark      = 406
    
    case VehicleNotiComing    = 407
    
    case VehicleNotiLeaving   = 408
    
    case VehicleNotiParking   = 409
    
   ///MARK: ----- 包裹相关 -----
    
    case PackageNoti          = 410
    
    case PackageNotiDetection = 411
    
    case PackageNotiDown      = 412
    
    case PackageNotiPickUp    = 413
    
    case PackageNotiRetention = 414
    
    case OtherNoti            = 415
    
    
    case Advertising          = 420
    
    
    case MotionDetecctionNoti = 500
    
    
    case AiMotionNotiButton   = 600
    
    case NoVipCloudStrorage   = 601
    
    case NoVipAiNoti          = 602
    
    case NoVipActivityZone    = 603
    
   ///MARK: ----- 设备信息界面使用 -----
    
    case DeviceName           = 700
    
    case UseLocation          = 701
    
    case DeviceType           = 702
    
    case BatteryLevel         = 703
    
    case DeviceSerialNumber   = 704
   ///MARK: ----- 系统信息界面使用 -----
    
    case SystemVersion        = 800
    
    case SystemMCU            = 801
    
    case WifiChannel          = 805
   ///MARK: ----- 网络信息界面使用 -----
    
    case WifiName             = 900
    
    case IPAddress            = 901
    
    case WirelessMacAddress   = 902
    
    case WiredMacAddress      = 903
    
    case ChangeNetWork        = 904
    
   ///MARK: ----- 运动检测界面使用,运动检测部分 -----
    
    case PirSwitch            = 1100
    
    case PirDetectPreference  = 1101
    
    case PirDetectPersonAI    = 1102
    case PirDetectPetAI       = 1103
    
    case PirSensitivity       = 1104
    
    case PirRecordTime        = 1105
    case ShootingSettings     = 1106
    
   ///MARK: ----- 运动检测界面使用,休眠部分 -----
    
    case DormancySwitch       = 1200
    
    case TimedDormancySwitch  = 1201
    
    case TimedDormancySetting = 1202
    
   //MARK: ----- 运动检测界面使用,运动追踪部分 -----
    
    case MotionTrackingSwitch = 1300
    
   //MARK: ----- 视频设置界面,视频录制部分 -----
    
    case VideoResolution      = 1400
    
    case videoSaveLocation    = 1401
    
    case videoFlipEntrance    = 1402
    
    case videoFlipSwitch      = 1403
    
   //MARK: ----- 视频设置界面,抗频闪部分 -----
    
    case antiFlickerSwitch    = 1500
    
    case AntiFlickerFrequency = 1501
    
   //MARK: ----- 视频设置界面,星光夜视部分 -----
    
    case StarlightSensor      = 1502
    
    case AutoNightVisionSwitch = 1503
    
    case StarlightWhiteBlack  = 1504
    
    case StarlightColor       = 1505
    
   //MARK: ----- 视频设置界面,音视频流联动部分 -----
    
    case audioVideoLinkage    = 1600
    
   //MARK: ----- 自动开机 -----
    
    case PowerSource          = 1700
    
    case ChargeAutoPowerOn    = 1701
    
   //MARK: ----- 云台校准 -----
    
    case PanTiltCalibration   = 1800
    
   //MARK: ----- 声音设置 -----
    
    case AlarmRingVolume      = 1900
    
    
    case DeviceLanguage       = 1901
    
    case DoorbellRing         = 1902
    
    case VoiceVolume          = 1903
    
    
    case LiveAudio            = 1904
    
    case RecordingAudio       = 1905
    
    
    case LiveSpeakerVolume    = 1906

   //MARK: ----- 警报设置 -----
    
    case MotionAlertSwitch    = 2000
    
    case AlarmDuration        = 2001
    
    
    case AntiDisassemblyAlarm = 2002
    
    
    case AlarmFlashSwitch     = 2003
    
   //MARK: ----- 灯光设置 -----
    
    case RecLampSwitch        = 2100
    
    
    case NightVisionSwitch    = 2101
    
    case NightVisionMode      = 2102
    
    case NightVisionSensitivity = 2103
    
   //MARK: ----- 拍摄设置 -----
    
    case PirCooldownSwitch    = 2200
    
    case PirCooldownTime      = 2201
    
    
    case SDCardVideoModes     = 2202
    
    case SDCardCooldownSwitch = 2203
   
    case SDCardCooldownSeconds = 2204
    
}

///MARK: ----- 组件化模型 -----
@objc public class A4xDeviceSettingModuleModel: NSObject {
    
    public init(moduleType: A4xDeviceSettingModuleType = .Switch, currentType: A4xDeviceSettingCurrentType = .Normal, title: String = "", titleContent: String = "", titleDescription: String = "", isShowTitleDescription: Bool = false, subModuleModels: Array<A4xDeviceSettingModuleModel> = [], moduleLevelType: A4xDeviceSettingModuleLevelType = .Notification, isShowContent: Bool = false, content: String = "", isShowRedPoint: Bool = false, isShowSeparator: Bool = false, isShowIntroduce: Bool = false, introduce: String = "", isInteractiveHidden: Bool = false, cellHeight: CGFloat = 0.0, moduleHeight: CGFloat = 0.0, contentHeight: CGFloat = 0.0, isSwitchShowIcon: Bool = false, isSwitchOpen: Bool = false, isSwitchLoading: Bool = false, isSelected: Bool = false, isSelectionBoxLoading: Bool = false, isNetWorking: Bool = false, enumContent: String = "", enumDataSource: Array<A4xDeviceSettingEnumAlertModel> = [], iconPath: String = "", buttonTitle: String = "", leftImage: String = "", rightImage: String = "", sliderValue: Float = 0.0, minValue: Float = 0.0, maxValue: Float = 100.0, scale: Float = 1.0, isNormalSlider: Bool = true) {
        self.moduleType = moduleType
        self.currentType = currentType
        self.title = title
        self.titleContent = titleContent
        self.titleDescription = titleDescription
        self.isShowTitleDescription = isShowTitleDescription
        self.subModuleModels = subModuleModels
        self.moduleLevelType = moduleLevelType
        self.isShowContent = isShowContent
        self.content = content
        self.isShowRedPoint = isShowRedPoint
        self.isShowSeparator = isShowSeparator
        self.isShowIntroduce = isShowIntroduce
        self.introduce = introduce
        self.isInteractiveHidden = isInteractiveHidden
        self.cellHeight = cellHeight
        self.moduleHeight = moduleHeight
        self.contentHeight = contentHeight
        self.isSwitchShowIcon = isSwitchShowIcon
        self.isSwitchOpen = isSwitchOpen
        self.isSwitchLoading = isSwitchLoading
        self.isSelected = isSelected
        self.isSelectionBoxLoading = isSelectionBoxLoading
        self.isNetWorking = isNetWorking
        self.enumContent = enumContent
        self.enumDataSource = enumDataSource
        self.iconPath = iconPath
        self.buttonTitle = buttonTitle
        self.leftImage = leftImage
        self.rightImage = rightImage
        self.sliderValue = sliderValue
        self.minValue = minValue
        self.maxValue = maxValue
        self.scale = scale
        self.isNormalSlider = isNormalSlider
    }
    
   
    public var moduleType : A4xDeviceSettingModuleType = .Switch
   
    public var currentType : A4xDeviceSettingCurrentType = .Normal
    
   
    public var title : String = ""
    public var titleContent : String = ""
   
    public var titleDescription : String = ""
   
    public var isShowTitleDescription : Bool = false
    
   
   
   
    public var subModuleModels : Array<A4xDeviceSettingModuleModel> = []
    
   
    public var moduleLevelType : A4xDeviceSettingModuleLevelType = .Notification
    
   
    public var isShowContent : Bool = false
    public var content : String = ""
    
    
    public var isShowRedPoint : Bool = false
    
   
    public var isShowSeparator : Bool = false
    
   
    public var isShowIntroduce : Bool = false
    public var introduce : String = ""
    
   
    public var isInteractiveHidden : Bool = false
    
   //MARK: ----- 高度相关 -----
   
   
    public var cellHeight : CGFloat = 0.0
   
    public var moduleHeight : CGFloat = 0.0
   
    public var contentHeight : CGFloat = 0.0
    
   //MARK: ----- 针对开关类型(Switch) -----
   
    public var isSwitchShowIcon : Bool = false
   
    public var isSwitchOpen : Bool = false
   
    public var isSwitchLoading : Bool = false
    
   //MARK: ----- 针对选择框类型(SelectionBox) -----
   
    public var isSelected : Bool = false
   
    public var isSelectionBoxLoading : Bool = false
   
    public var isNetWorking : Bool = false
   
    public var at_leat : Int = 0
    public var at_most : Int = 1
    
    public var requestValue : String = ""
    
   //MARK: ----- 右侧枚举类型(Enumeration) -----
   
    public var enumContent : String = ""
   
    public var enumDataSource : Array<A4xDeviceSettingEnumAlertModel> = []
    
   //MARK: ----- 右侧内容开关类型(ContentSwitch) -----
   
    public var iconPath : String = ""
    
   //MARK: ----- 更多信息类型(MoreInfo) -----
   
    public var buttonTitle : String = ""
    
   //MARK: ----- Vip信息类型(MoreInfo) || Slider类型 -----
   
    public var leftImage : String = ""
   
    public var rightImage : String = ""
    
   //MARK: ----- Slider类型 -----
   
    public var sliderValue : Float = 0.0
   
    public var minValue : Float = 0.0
   
    public var maxValue : Float = 100.0
   
    public var scale : Float = 1.0
   
   
   
    public var isNormalSlider : Bool = true
    
    
    public override var description: String {
        var description = ""
        
        let basicDes = "当前组件化类型 moduleType:\(moduleType.rawValue) 通知类型: \(currentType.rawValue) 模块的标题:\(title) 子模块数量:\(subModuleModels.count) 是否展示底部内容:\(isShowContent) 底部内容:\(isShowContent)"
        
        let switchDes = "针对开关类型(Switch) 是否开启开关:\(isSwitchOpen) 是否处于Loading状态:\(isSwitchLoading)"
        
        let selectionBoxDes = "针对选择框类型(SelectionBox) 是否选中:\(isSelected) SelectionBox是否处于Loading状态:\(isSelectionBoxLoading)"
        
        let enumDes = "右侧枚举类型(Enumeration) 展示内容:\(enumContent) 枚举对象数据源: \(enumDataSource)"
        
        description = basicDes + "\n" + switchDes + "\n" + selectionBoxDes + "\n" + enumDes
        return description
    }
}
