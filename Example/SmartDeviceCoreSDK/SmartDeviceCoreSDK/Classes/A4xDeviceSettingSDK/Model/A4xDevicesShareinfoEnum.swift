//


//


//

import Foundation
import SmartDeviceCoreSDK

public enum A4xDevicesShareSessionInfoEnum {
    case admin  
    case shared 
    case rold   
    
    var rawValue : String {
        switch self {
        case .admin:
            return A4xBaseManager.shared.getLocalString(key: "admin_info")
        case .shared:
            return A4xBaseManager.shared.getLocalString(key: "share_to")
        case .rold:
            return A4xBaseManager.shared.getLocalString(key: "permission")
        }
    }
}

public enum A4xDevicesShareinfoEnum : Equatable , Hashable  {
    public var hashValue : Int {
        switch self {
        case .admin   : return -3
        case .invite   : return -2
        case .share(let user) : return user.userId.hashValue
        case let .rold(role,_):
            return role.rawValue.hashValue
        }
    }
    public func hash(into hasher: inout Hasher) {
        
    }
    
    public static func == (lhs: A4xDevicesShareinfoEnum, rhs: A4xDevicesShareinfoEnum) -> Bool {
        switch (lhs, rhs) {
        case (.admin, .admin): return true
        case (.invite, .invite): return true
        case (.share(let s1), .share(let s2)) where s1.userId == s2.userId : return true
        case _: return false
        }
    }
    
    case admin(_ user : A4xUserDataModel)
    case share(_ user : A4xUserDataModel)
    case invite
    case rold(A4xDeviceRole , Bool)
    
    public static func shareCase (admin : A4xUserDataModel , shareUsers : [A4xUserDataModel] ) -> ([A4xDevicesShareSessionInfoEnum : [A4xDevicesShareinfoEnum]] , [A4xDevicesShareSessionInfoEnum]) {
        var allCase : [A4xDevicesShareSessionInfoEnum : [A4xDevicesShareinfoEnum]] = [:]
        allCase[A4xDevicesShareSessionInfoEnum.admin] = [A4xDevicesShareinfoEnum.admin(admin)]
        
        var tempCase : [A4xDevicesShareinfoEnum] = []
        shareUsers.forEach { (user) in
            tempCase += [.share(user)]
        }
        tempCase += [.invite]

        allCase[A4xDevicesShareSessionInfoEnum.shared] = tempCase
        return (allCase , [A4xDevicesShareSessionInfoEnum.admin , A4xDevicesShareSessionInfoEnum.shared])
    }
    
    public static func shareByCase (admin : A4xUserDataModel , shareByRoles : [[A4xDeviceRole : Bool]] ) -> ([A4xDevicesShareSessionInfoEnum : [A4xDevicesShareinfoEnum]] , [A4xDevicesShareSessionInfoEnum]) {
        var allCase : [A4xDevicesShareSessionInfoEnum : [A4xDevicesShareinfoEnum]] = [:]
        allCase[A4xDevicesShareSessionInfoEnum.admin] = [A4xDevicesShareinfoEnum.admin(admin)]
        
        var tempCase : [A4xDevicesShareinfoEnum] = []
        shareByRoles.forEach { (dict) in
            dict.forEach({ (key , value) in
                tempCase += [.rold(key , value)]
            })
        }
        allCase[A4xDevicesShareSessionInfoEnum.rold] = tempCase
        return (allCase ,[A4xDevicesShareSessionInfoEnum.admin , A4xDevicesShareSessionInfoEnum.rold] )
    }
}
