//


//


//

import Foundation
import SmartDeviceCoreSDK

struct A4xDeviceShareViewModel {
    func loadShareUser(deviceID : String , comple : @escaping ([A4xUserDataModel] , String?)->Void) {
        DeviceShareCore.getInstance().loadShareUsers(serialNumber: deviceID) { code, message, models in
            var result : [A4xUserDataModel] = Array()
            models.forEach({ (m) in
                result.append(m.transitionUser())
            })
            comple(result , nil)
        } onError: { code, message in
            comple([], A4xAppErrorConfig(code: code).message() ?? message)
        }
    }
    
    func loadShareQrcode(deviceID : String , comple : @escaping (Bool, String?, Int?, Int?, String?)->Void) {
        DeviceShareCore.getInstance().startPreShareDeviceByAdmin(serialNumber: deviceID) { code, message, shareId, expiredTime in
            comple(true , shareId, expiredTime, 0, nil)
        } onError: { code, message in
            comple(false , nil, 0, code, message)
        }
    }
    
    func shareUserDelete(deviceID : String , deleteUser : A4xUserDataModel , comple : @escaping (Bool , String?)->Void){
        DeviceShareCore.getInstance().deleteShareUser(serialNumber: deviceID, deleteUserId: Int(deleteUser.id ?? 0)) { code, message in
            comple(true, "delete share user success!")
        } onError: { code, message in
            comple(false, A4xAppErrorConfig(code: code).message() ?? "delete share user failed!")
        }
    }
}
