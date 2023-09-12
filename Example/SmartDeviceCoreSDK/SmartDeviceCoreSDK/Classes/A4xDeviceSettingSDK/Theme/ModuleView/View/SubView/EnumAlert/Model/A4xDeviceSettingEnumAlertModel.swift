//


//


//

import UIKit

@objc public class A4xDeviceSettingEnumAlertModel: NSObject {
    
    
    var content : String? = ""
    
    var descriptionContent : String? = ""
    
    var requestContent : String? = ""
    
    var isEnable : Bool? = true
    
    public override var description: String {
        return "枚举对象 展示内容:\(content) 底部描述: \(descriptionContent) 需要给后端上传的内容:\(requestContent) 是否可用:\(isEnable)"
    }

}
