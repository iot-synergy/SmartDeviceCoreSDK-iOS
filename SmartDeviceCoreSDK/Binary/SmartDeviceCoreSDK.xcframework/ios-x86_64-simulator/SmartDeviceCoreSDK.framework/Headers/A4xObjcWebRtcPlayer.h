//
//  A4xObjcWebRtcPlayer.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/28.
//

#ifndef A4xObjcWebRtcPlayer_h
#define A4xObjcWebRtcPlayer_h
#import "A4xLogReportDelegate.h"
#import "A4xCommon.h"
#import <WebRTC/RTCVideoFrame.h>
#import <WebRTC/RTCEncodedImage.h>
#import "A4xVideoRenderView.h"
#import "A4xRtcConnection.h"


@class A4xObjcWebRtcPlayer;

@protocol A4xEncodeAVDelegate <NSObject>
//远端视频编码数据帧回调
-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer*)player onEncodeVideo:(nullable RTCEncodedImage *)image;
-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer*)player onEncodeAudio:(nullable NSData*)samples
              rate:(NSInteger)sampeRate channel:(NSInteger)ch;
/*本地语音数据回调*/
-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer *)player onLocalAudio:(nonnull int16_t*)buffer size:(NSInteger)bufferSize;
@end

@protocol A4xDecodeVideoDelegate <NSObject>

-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer*)player onDecodedFrame:(nullable RTCVideoFrame *)frame;
@end

@protocol A4xOnPlayerStateDelegate <NSObject>

-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer*)player onStreamStats:(double)recvBitrate;
-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer*)player onState:(nonnull NSString*)sn state:(A4xObjcWebRtcPlayerState)state error:(A4xErrorCode)errCode;
-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer*)player onDebug:(nonnull NSDictionary*)debugInfo;
@end


@protocol A4xStatsReportDelegate <NSObject>

-(void)onStats:(double)recvBytes;
@end


@protocol A4xDeviceDataPushDelegate <NSObject>

-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer*)player onRecordPlaySeek:(nullable RecordPlaySeekPos*)seekPos;
-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer*)player onDeviceEventStateReport:(nullable DeviceEventReport*)eventReport;
@end

@protocol A4xSignalConnDelegate <NSObject>

-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer*)player onSignalMsg:(nonnull NSData*)msg;
-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer*)player onState:(A4xSignalConnState)state;
-(void)mediaPlayer:(nonnull A4xObjcWebRtcPlayer*)player onError:(int)errCode errMsg:(NSString*)errMsg;
@end


@interface A4xObjcWebRtcPlayer : NSObject

@property (nonatomic, weak, nullable) id<A4xOnPlayerStateDelegate> playerStateDelegate;
@property (nonatomic, weak, nullable) id<A4xEncodeAVDelegate> encodeAVDelegate;
@property (nonatomic, weak, nullable) id<A4xDecodeVideoDelegate> decodeVideoDelegate;
@property (nonatomic, weak, nullable) id<A4xLogReportDelegate> logReportDelegate;
@property (nonatomic, weak, nullable) id<A4xStatsReportDelegate> statsDelegate;
@property (nonatomic, weak, nullable) id<A4xDeviceDataPushDelegate> devDataPushDelegate;
@property (nonatomic) A4xObjcWebRtcPlayerState playerState;
@property (nonatomic, weak, nullable) id<A4xSignalConnDelegate> signalDelegate;
//@property (nonatomic, strong, nullable, retain) UIView* rendView;

/**
声音开关/对讲开关
 */
@property (nonatomic, assign) BOOL audioEnable;
@property (nonatomic, assign) BOOL speakEnable;
// 变声
@property (nonatomic, assign) A4xVoiceEffects voiceEffect;
// magicpix算法是否开启
@property (nonatomic, assign) BOOL magicPixelEnable;
// 是否支持直播视频分辨率auto档位
@property (nonatomic, assign) BOOL autoResolutionEnable;
/**
 resolution:*x*:1920x1080
 customParam:直播相关自定义参数
 ["verifyDormancyPlan" : true ]: 是否核查休眠计划
 */
-(void)startLive:(nonnull NSString*)resolution custom:(nullable NSDictionary*)customParam;
/**
 * default:20(seconds)
 * 关闭直播,且延迟delay断开链接
 * */
-(void)stopLive:(int)delay;

-(void)setKeepalive;

-(void)setRenderView:(A4xVideoMetalRenderView*)renderView;

/**
   volume:0-10.0f
 */
-(void)setVolume:(double)volume;

-(void)setResolution:(nonnull NSString*)resolution response:(nullable PlayControlResponseBlock)block;

-(void)setWhiteLight:(BOOL)open response:(nullable PlayControlResponseBlock)block;

-(void)triggerAlarm:(nullable PlayControlResponseBlock)block;

-(void)PTZControl:(float)pitch yaw:(float)yaw response:(nullable PtzResponseBlock)block;

-(void)addPreset:(nullable PlayControlResponseBlock)block;

-(void)setPreset:(nonnull NSString*)coordinate response:(nullable PlayControlResponseBlock)block;

-(void)getSdHasVideoDays:(long long)starttm
                    stop:(long long)stoptm
                response:(nonnull HaveRecordDayResponseBlock)completeBlock;

-(void)getSdVideoList:(long long)starttm
                   stop:(long long)stoptm
               response:(nonnull RecordFileResponseBlock)completeBlock;

-(void)startPlayback:(long long)starttm;

-(void)stopPlayback:(int)delay;
/**
 * 开始/停止录像到本地相册
 * @param path 本地录像临时存储路径
 * @param completeBlock 停止录像结果回调(阻塞耗时故可异步)
 * */
-(void)startRecord:(nonnull NSString*)path response:(nonnull PlayControlResponseBlock)completeBlock;
-(void)stopRecord:(nonnull PlayControlResponseBlock)completeBlock;

/**
 * 截图
 * @param quality 图像质量 0.0-1.0
 * @param completeBlock 成功回调,阻塞耗时故可异步
 * */
-(int)screenshot:(double)quality complete:(nonnull ScreenshotBlock)completeBlock;

/**
 * 销毁播放器
 * */
-(void)close;

/**
   AP直连模式
 */
-(void)initAPMode:(nonnull NSString*)apAddr uid:(nonnull NSString*)userId;
-(void)setAPToken:(nonnull NSString*)token;
-(int)sendSignalMessage:(NSData*)msg isBinary:(BOOL)isBinary;

/**
 听筒和喇叭切换:0:Speaker 1:handset
 */
-(void)switchHandsetAndSpeaker:(NSInteger)flag;

/**
   设置日志level和文件名
   TODO:level暂时未用
 */
-(void)setLogLevel:(int)level path:(nonnull NSString*)filePath;

/**
 创建rtc链接
 */
-(A4xRtcConnection*)createRtcConnection:(nullable NSDictionary*)customParam complete:(nullable RtcConnectionStateChangeBlock)stateChangeBlock;
/**
 销毁rtc连接
 */
-(void)destroyRtcConnection;

// magicpix算法执行状态回调
-(void)setMagicPixProcessState:(nullable MagicPixProcStateBlock)stateBlock;
@end


#endif /* A4xObjcWebRtcPlayer_h */
