//
//  A4xFFmpegManager.h
//  A4xLiveSDK
//
//  Created by Hao Shen on 6/9/20.
//  Copyright © 2020 Stas Seldin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMMedia.h"

NS_ASSUME_NONNULL_BEGIN

@protocol A4xFFmpegManagerDelegate <NSObject>

@optional
- (void)ts2Mp4Result:(KMMediaAssetExportSessionStatus) status outputPath: (NSString *) outputfilePath;

@end

typedef void (^Ts2Mp4CompleteBlocker)(KMMediaAssetExportSessionStatus status, NSString* outPath);


@interface A4xFFmpegManager : NSObject

+ (instancetype)sharedInstance;

+ (BOOL)muxerMP4File:(NSString *)mp4file withH264File:(NSString *)h264File codecName:(NSString *)codecName;
// 转换Mp4视频
+ (BOOL)turnMp4Video:(NSString *)inputPath outputPath:(NSString *)outputPath;

// TS转换Mp4视频
- (BOOL)ts2Mp4:(NSString *)inputPath outputPath:(NSString *)outputPath;
-(BOOL)ts2Mp4:(NSString*)inputPath outputPath:(NSString*)outputPath complete:(nonnull Ts2Mp4CompleteBlocker)completeBlock;

//解析ts的编码格式:KMMediaFormatH264/KMMediaFormatHEVC
//defined in KMMediaFormat.h
- (int)getVideoStreamCodec: (NSString*)inputPath;

// 代理
@property(nonatomic, weak) id<A4xFFmpegManagerDelegate> adFFmpegMuxerDelegate;

@end

NS_ASSUME_NONNULL_END
