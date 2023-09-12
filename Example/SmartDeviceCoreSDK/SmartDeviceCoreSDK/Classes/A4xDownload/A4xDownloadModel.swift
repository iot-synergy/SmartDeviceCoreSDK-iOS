//
//  A4xDownloadModel.swift
//  AddxAi
//
//  Created by wei jin on 2023/5/16.
//  Copyright © 2023 addx.ai. All rights reserved.
//

import Foundation

/// A model class for saving data parsed from a media file.
@objcMembers
public class A4xDownloadModel: NSObject, Codable {
    public init(serialNumber: String? = nil, deviceName: String? = nil, m3uUrl: URL? = nil, name: String? = nil, tsArr: [URL]? = nil, totalSize: Int = 0, m3uUri: URL? = nil, mediaType: Int = 1, videoUrl: String? = nil, downloadTaskPath: String? = nil, downloadOutputPath: String? = nil, isShare: Bool = false) {
        self.serialNumber = serialNumber
        self.deviceName = deviceName
        self.m3uUrl = m3uUrl
        self.name = name
        self.tsArr = tsArr
        self.totalSize = totalSize
        self.m3uUri = m3uUri
        self.mediaType = mediaType
        self.videoUrl = videoUrl
        self.downloadTaskPath = downloadTaskPath
        self.downloadOutputPath = downloadOutputPath
        self.isShare = isShare
    }
    
    /// device serial number
    public var serialNumber: String?
    /// device name
    public var deviceName: String?
    /// The media file's source URL.
    public var m3uUrl: URL?
    /// Name of media file.
    public var name: String?
    /// An array of names of sliced ​​videos parsed from the contents of the file.
    public var tsArr: [URL]?
    /// The total size of all sliced ​​videos.
    public var totalSize: Int = 0
    /// The media file's source path.
    public var m3uUri: URL?
    /// media type  1,m3u; 0,mp4
    public var mediaType: Int = 1
    /// media  videoUrl
    public var videoUrl: String?
    /// download success path
    public var downloadTaskPath: String?
    /// download output path
    public var downloadOutputPath: String?
    /// download is share
    public var isShare: Bool = false
}

/// Used to represent whether a task was successful or encountered an error.
///
/// - success: The task and all operations were successful resulting of the provided associated value.
///
/// - failure: The task encountered an error resulting in a failure. The associated values are the original data
///            provided by the task as well as the error that caused the failure.
public enum Result<Value> {
    case success(Value)
    case failure(WLError)
}

/// `WLError` is the error type returned by A4xM3U8Utils.
///
/// - parametersInvalid:     Returned when specified parameters are invalid.
/// - urlDuplicate:          Returned when attach a task that is already in progress.
/// - handleCacheFailed:     Returned when local cache has someting wrong.
/// - downloadFailed:        Returned when download requests encounter an error.
/// - logicError:            Returned when internal logic encounters an error.
/// - m3uFileContentInvalid: Returned when `m3u` file's content is invalid.
public enum WLError: Error {
    case parametersInvalid
    case urlDuplicate
    case handleCacheFailed(Error)
    case downloadFailed(Error?)
    case logicError
    case m3uFileContentInvalid
}

extension WLError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .parametersInvalid:
            return "参数错误，请检查传入的参数。"
        case .urlDuplicate:
            return "URL 已存在，当前正在处理中。"
        case .handleCacheFailed(_):
            return "操作缓存失败，请检查本地缓存是否正确。"
        case .logicError:
            return "逻辑错误"
        case .m3uFileContentInvalid:
            return "m3u 文件内容错误，请检查文件内容格式和数据是否正确。"
        default:
            return "未知错误"
        }
    }
}

/// A closure that will be called when determine the URL of the slice file from a given String and URL.
/// This will be called multiple times.
/// String: A ts file path from the m3u file content.
/// URL: The relative URL.
/// URL?: URL of the slice file. Retuen `nil` if it is not a ts file.
public typealias TsURLHandler = (String, URL) -> URL?

/// A closure executed once a combine task has completed.
/// Result<URL>: A Result instance of the download task. The `URL` value is the path where the final video file is
/// located.
public typealias CombineCompletion = (Result<URL>) -> ()

