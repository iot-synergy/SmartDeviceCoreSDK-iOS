//


import Foundation
import SmartDeviceCoreSDK

public class BaseCoreAdapter: BaseAdapterProtocol {
    
    public init(){}
    
    public func getLocalString(key: String, param: [String]) -> String {
        let tempContent = a4xLocalizedString(key, comment: "")
        var content : String = tempContent
        if tempContent.contains("%u") {
            content = tempContent.replacingOccurrences(of: "%u", with: "%@")
        }
        
        if content.contains("%d") {
            content = tempContent.replacingOccurrences(of: "%d", with: "%@")
        }
        
        var removeSpecialContent = ""
        if tempContent.contains("<![CDATA[<b>") {
            removeSpecialContent = tempContent.replacingOccurrences(of: "<![CDATA[<b>", with: "")
        }
        
        if removeSpecialContent.contains("</b>]]>") {
            content = removeSpecialContent.replacingOccurrences(of: "</b>]]>", with: "")
        }
        
        if param.count > 0 {
            var contentStr: NSString = content as NSString
            for i in 0..<param.count {
                
                let index = content.positionOf(sub: "%@")
                if index != -1 {
                    content = (contentStr.replacingCharacters(in: NSMakeRange(content.positionOf(sub: "%@"), 2), with: param[i])) as String
                    contentStr = content as NSString
                }
                
                
                let index2 = content.positionOf(sub: "％@")
                if index2 != -1 {
                    content = (contentStr.replacingCharacters(in: NSMakeRange(content.positionOf(sub: "％@"), 2), with: param[i])) as String
                    contentStr = content as NSString
                }
                
                
                let index3 = content.positionOf(sub: "%\(i + 1)")
                if index3 != -1 {
                    content = (contentStr.replacingCharacters(in: NSMakeRange(content.positionOf(sub: "%\(i + 1)"), 2), with: param[i])) as String
                    contentStr = content as NSString
                }
                
                
                let index4 = content.positionOf(sub: "％\(i + 1)")
                if index4 != -1 {
                    content = (contentStr.replacingCharacters(in: NSMakeRange(content.positionOf(sub: "％\(i + 1)"), 2), with: param[i])) as String
                    contentStr = content as NSString
                }
                
            }
        }

        if content == notFoundKeyInLocalizedString {
            
            if A4xBaseManager.shared.checkIsDebug() {
                DispatchQueue.main.a4xAfter(0.2) {
                    
                    showErrorAlert(resourceName: key, for: BaseCoreAdapter.self)
                }
            }
            
            return ""
        } else {
            
            return content
        }
    }
    
    
    public func vCommonLogError(_ closure: @autoclosure () -> Any?) {
        
    }
    
    public func vLiveLog(level: XCGLoggerLevel , _ closure: @autoclosure () -> Any?) {
        
    }
    
    public func clearResultFile(url: URL) {
        
    }
    
    public func makeToast(_ message: String?) {
        UIApplication.shared.keyWindow?.makeToast(message)
    }
    
    private func a4xLocalizedString(_ key: String , bundle: Bundle = Bundle.main , comment: String) -> String{
        if bundle == Bundle.main {
            return NSLocalizedString(key, tableName: nil, bundle: languageBundle , value: notFoundKeyInLocalizedString, comment: comment)
        }else {
            return NSLocalizedString(key, tableName: nil, bundle: bundle , value: notFoundKeyInLocalizedString, comment: comment)
        }
    }
}
