//
//  MediaCodecAdapter.swift
//  MediaCodec
//
//  Created by huafeng on 2023/7/31.
//

import Foundation
import SmartDeviceCoreSDK

public class MediaCodecAdapter: MediaCodecProtocol {
    
    public init(){}
    
    public func turnMp4Video(inputPath: String, outputPath: String) -> Bool {
        return A4xFFmpegManager.turnMp4Video(inputPath, outputPath: outputPath)
    }
    
    public func ts2Mp4(inputPath: String, outputPath: String, complete: @escaping (TSMediaAssetExportSessionStatus, String) -> Void) -> Bool {
        return A4xFFmpegManager.sharedInstance().ts2Mp4(inputPath, outputPath: outputPath) { status, outPath in
            complete(TSMediaAssetExportSessionStatus(rawValue: status.rawValue) ?? .unknown, outputPath)
        }
    }
    
}
