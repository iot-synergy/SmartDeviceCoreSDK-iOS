//
//  LoggerImpl.swift
//  BaseUI
//
//  Created by huafeng on 2023/8/23.
//

import Foundation
import SmartDeviceCoreSDK

@objc public class LoggerImpl: NSObject, LoggerDelegate {
    
    public func warning(_ tag: String, message: String) {
        self.log(.warning, tag, message: message)
    }
    
    public func info(_ tag: String, message: String) {
        self.log(.info, tag, message: message)
    }
    
    public func error(_ tag: String, message: String) {
        self.log(.error, tag, message: message)
    }
    
    public func debug(_ tag: String, message: String) {
        self.log(.debug, tag, message: message)
    }
    
    public func verbose(_ tag: String, message: String) {
        self.log(.verbose, tag, message: message)
    }
    
    private func log(_ level: LogLevel, _ tag: String, message: String) {
        if A4xAppBuildConfig.buildInfo().isDebug() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss:SSSS"
            print("\(dateFormatter.string(from: Date())) \(tag) \(level.stringValue): \(message)")
        }
    }
    
    public func LogTime() -> String {
        //获取当前时间
        let now = Date()
        // 创建一个日期格式器
        let dformatter = DateFormatter()
        dformatter.dateFormat = "mm:ss.SSS"
        return dformatter.string(from: now)
    }

    
}
