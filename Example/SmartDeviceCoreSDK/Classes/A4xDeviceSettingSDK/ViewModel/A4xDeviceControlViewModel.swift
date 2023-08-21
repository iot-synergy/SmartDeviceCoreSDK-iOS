//


//


//

import Foundation
import SmartDeviceCoreSDK
import Resolver

struct A4xSleepPlanList : Codable {
    var sleeplist : [A4xDeviceSleepPlanBean]?
}

class A4xDeviceControlViewModel : Codable {
    private static let DeviceDataPath : String = "deviceControl"

    //var deviceId : String
    var deviceModel : DeviceBean
    var personDetect : Bool?
    var recordEnable: Bool?
    var recordValue: Int?
    var motionTrack : Bool?
    var alarmEnable : Bool?
    var alarmValue : Int?
    var whiteLightflash : Bool?
    var motionEnable : Bool?
    var motionValue : Int?
    var resolution  : String?
    
    var nightEnable : Bool?
    var nightMode : Int?
    var nightValue : Int?
    var nightThresholdLevel: Int?
    
    var moveMode  : Int?
    
    var antiflickerSwitch : Bool?
    var antiflicker : Int?

    var deviceLanguage: String?
    var deviceSupportLanguage: [String]?
    var recLamp: Int? 
    var voiceVolumeSwitch: Bool? 
    var voiceVolume: Int? 
    var alarmVolume: Int? 
    var mirrorFlipEnable : Bool?
    
    var cryDetect: Bool? 
    var cryDetectLevel: Int? 
    
    var sleepPlanStatus : Bool? 
    var deviceStatus: Int? 
    var sleepPlanModels : [A4xDeviceSleepPlanBean]?
    
    
    
    public var description: String {
        return "运动检测开关: \(self.motionEnable)"
    }
    
    init(deviceModel: DeviceBean) {
        self.deviceModel = deviceModel
    }
    
    static func loadLocalData(deviceModel: DeviceBean, comple : @escaping (_ error : String?)->Void) -> A4xDeviceControlViewModel {
        var deviceControl : A4xDeviceControlViewModel?
        let decoder : JSONDecoder = JSONDecoder()
        if let ydata = try? Disk.retrieve(DeviceDataPath + (deviceModel.serialNumber ?? "") + ".json", from: .documents, as: Data.self) {
            if let data = ydata.decryption() {
                deviceControl = try? decoder.decode(A4xDeviceControlViewModel.self, from: data)
            }
        }
        
        return deviceControl ?? A4xDeviceControlViewModel(deviceModel: deviceModel)
    }
    
    func save() {
        do {
            if let saveData : Data = try self.encodeCrypt() {
                try Disk.save(saveData, to: .documents, as: A4xDeviceControlViewModel.DeviceDataPath + (self.deviceModel.serialNumber ?? "")  + ".json")
            }
        } catch {
            
        }
    }

    
    
    func loadNetData(device: DeviceBean? = DeviceBean(), comple : @escaping (_ error : String?)->Void) {
        let weakSelf = self
        DeviceManageCore.getInstance().getDeviceSettingConfig(serialNumber: self.deviceModel.serialNumber ?? "") { code, message, model in
            weakSelf.motionTrack = (model?.motionTrack ?? 0) > 0 ? true : false
            weakSelf.moveMode = model?.motionTrackMode
            weakSelf.alarmEnable = (model?.needAlarm ?? 0) > 0 ? true : false
            
            if (model?.alarmSeconds ?? 0) > 0 {
                weakSelf.alarmValue = model?.alarmSeconds
            } else {
                weakSelf.alarmValue = 5
            }
            
            weakSelf.personDetect = (model?.devicePersonDetect ?? 0) > 0 ? true : false
            weakSelf.motionEnable = (model?.needMotion ?? 0) > 0 ? true : false
            if (model?.motionSensitivity ?? 0) > 0 {
                weakSelf.motionValue = model?.motionSensitivity
            } else {
                weakSelf.motionValue = A4xDevicesMotioninfoEnum.A4xMotionLevelEnum.high.rawValue
            }
            
            weakSelf.recordEnable = (model?.needVideo ?? 0) > 0 ? true : false
            
            if (model?.videoSeconds ?? 0) > 0 {
                weakSelf.recordValue = model?.videoSeconds
            } else {
                weakSelf.recordValue = A4xDevicesMotioninfoEnum.A4xRecordCountEnum.auto.value()
            }
            
            weakSelf.whiteLightflash = (model?.whiteLightScintillation ?? 0) > 0 ? true : false
            weakSelf.nightEnable = (model?.needNightVision ?? 0) > 0 ? true : false
            
            if (model?.nightVisionSensitivity ?? 0) > 0 {
                weakSelf.nightValue = model?.nightVisionSensitivity
            } else {
                weakSelf.nightValue = 1
            }
            weakSelf.nightMode = model?.nightVisionMode ?? 0
            
            weakSelf.antiflickerSwitch = (model?.antiflickerSwitch ?? 0) > 0 ? true : false
            weakSelf.antiflicker = model?.antiflicker
            
            weakSelf.deviceLanguage = model?.deviceLanguage
            weakSelf.deviceSupportLanguage = model?.deviceSupportLanguage
            weakSelf.recLamp = model?.recLamp
            weakSelf.voiceVolumeSwitch = (model?.voiceVolumeSwitch ?? 0) > 0 ? true : false
            weakSelf.voiceVolume = model?.voiceVolume
            weakSelf.alarmVolume = model?.alarmVolume
            weakSelf.mirrorFlipEnable = model?.mirrorFlip == 1
            
            weakSelf.cryDetect = (model?.cryDetect ?? 0) > 0 ? true : false
            weakSelf.cryDetectLevel = model?.cryDetectLevel
            
            
            A4xUserDataHandle.Handle?.updateDevice(device: model)
            weakSelf.save()
            comple(nil)
        } onError: { code, message in
            comple(message)
        }
    }
    
    func sleepToWakeUP(enable: Bool, comple: @escaping (_ error: String?) -> Void) {
        weak var weakSelf = self
        DeviceSleepPlanCore.getInstance().setSleep(serialNumber: self.deviceModel.serialNumber ?? "", enable: enable) { code, message in
            weakSelf?.deviceStatus = enable ? 3 : 0
            weakSelf?.save()
            comple(nil)
        } onError: { code, message in
            let msg = A4xAppErrorConfig(code: code).message()
            comple(msg)
        }
    }
    
    
    func getSleepPlanStatus(comple: @escaping (_ error: String?) -> Void) {
        weak var weakSelf = self
        
        DeviceSettingCoreUtil.getDeviceAttributes(deviceId: self.deviceModel.serialNumber ?? "") { code, model, message in
            if code == 0 {
                let modifiableAttributes = model.modifiableAttributes
                let tool = A4xDeviceSettingModuleTool()
                for i in 0..<(modifiableAttributes?.count ?? 0) {
                    let attrModel = modifiableAttributes?.getIndex(i)
                    let name = attrModel?.name
                    if name == "timedDormancySwitch" {
                        let value = attrModel?.value
                        let timedDormancySwitchValue = tool.getValueOrOption(anyCodable: value ?? ModifiableAnyAttribute()) as? Bool ?? false
                        weakSelf?.sleepPlanStatus = timedDormancySwitchValue
                        weakSelf?.save()
                        comple(nil)
                    }
                }
            } else {
                comple(message)
            }
        }
    }
    
    
    func setSleepPlanStatus(enable: Bool, comple: @escaping (_ error: String?) -> Void) {
        weak var weakSelf = self
        DeviceSettingCore.getInstance().updateAttribute(serialNumber: self.deviceModel.serialNumber ?? "", name: "timedDormancySwitch", value: enable) { code, message in
            weakSelf?.sleepPlanStatus = enable
            weakSelf?.save()
            comple(nil)
        } onError: { code, message in
            if code == 10000 || code == 10001 {
                comple(A4xBaseManager.shared.getLocalString(key: "open_fail_retry"))
            } else {
                comple(message)
            }
        }
    }
    
    
    func getSleepPlanList(comple: @escaping (_ error: String?) -> Void) {
        weak var weakSelf = self
        DeviceSleepPlanCore.getInstance().getSleepPlanList(serialNumber: self.deviceModel.serialNumber ?? "") { code, message, modebeans in
            var beans : [A4xDeviceSleepPlanBean] = []
            if modebeans.count > 0 {
                for i in 0..<modebeans.count {
                    let modebean = modebeans.getIndex(i)
                    let bean = DeviceSleepPlanUtil.toA4xDeviceSleepPlanBean(bean: modebean ?? DeviceSleepPlanBean())
                    beans.append(bean)
                }
            }
            weakSelf?.sleepPlanModels = beans
            weakSelf?.save()
            comple(nil)
        } onError: { code, message in
            comple(message)
        }
    }
    
    
    func createSleepPlan(planStartDay: [Int], startHour: Int, startMinute: Int, endHour: Int, endMinute: Int,comple: @escaping (_ error: String?) -> Void) {
        weak var weakSelf = self
        var planBean = DeviceSleepPlanBean()
        planBean.planStartDay = planStartDay
        planBean.startHour = startHour
        planBean.startMinute = startMinute
        planBean.endHour = endHour
        planBean.endMinute = endMinute
        
        DeviceSleepPlanCore.getInstance().creatSleepPlan(serialNumber: self.deviceModel.serialNumber ?? "", planBean: planBean) { code, message in
            weakSelf?.save()
            comple(nil)
        } onError: { code, message in
            comple(message)
        }
    }
    
    
    func editSleepPlan(period: Int, planStartDay: [Int], startHour: Int, startMinute: Int, endHour: Int, endMinute: Int,comple: @escaping (_ error: String?) -> Void) {
        weak var weakSelf = self
        var planBean = DeviceSleepPlanBean()
        planBean.period = period
        planBean.planStartDay = planStartDay
        planBean.startHour = startHour
        planBean.startMinute = startMinute
        planBean.endHour = endHour
        planBean.endMinute = endMinute
        
        DeviceSleepPlanCore.getInstance().editSleepPlan(serialNumber: self.deviceModel.serialNumber ?? "", planBean: planBean) { code, message in
            weakSelf?.save()
            comple(nil)
        } onError: { code, message in
            comple(message)
        }
    }
    
    
    func deleteSleepPlan(period: Int, comple: @escaping (_ error: String?) -> Void) {
        weak var weakSelf = self
        DeviceSleepPlanCore.getInstance().deleteSleepPlan(period: period, serialNumber: self.deviceModel.serialNumber ?? "") { code, message in
            weakSelf?.save()
            comple(nil)
        } onError: { code, message in
            comple(message)
        }
    }
}

