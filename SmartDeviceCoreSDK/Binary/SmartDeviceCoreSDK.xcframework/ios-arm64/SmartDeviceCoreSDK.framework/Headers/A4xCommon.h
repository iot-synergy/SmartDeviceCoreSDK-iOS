//
//  A4xCommon.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/22.
//

#ifndef A4xCommon_h
#define A4xCommon_h
#import <UIKit/UIKit.h>

//video resolution
typedef NS_ENUM(NSInteger, A4xVideoResolution) {
    //640x360
    kVideoSize_640x360,
    //640x480
    kVideoSize_640x480,
    //1280x720
    kVideoSize_1280x720,
    //1280x960
    kVideoSize_1280x960,
    //1920x1080
    kVideoSize_1920x1080,
    //2560x1440
    kVideoSize_2560x1440,
    //2048x1536
    kVideoSize_2048x1536,
    //2304x1296
    kVideoSize_2304x1296,
    //7680*4320
    kVideoSize_7680x4320
};

typedef NS_ENUM(NSInteger, A4xObjcWebRtcPlayerState) {
    //player idle 0
    kMediaPlayerStateIDLE,
    //opening 1
    kMediaPlayerStateOpening,
    //playing 2
    kMediaPlayerStatePlaying,
    //stop and have not closep2p 3
    kMediaPlayerStatePause,
    // failed 4
    kMediaPlayerStateFailed,
    // closing 5
    kMediaPlayerStateClosing,
    // closed 6
    kMediaPlayerStateClosed,
    // poor network playing 7
    kMediaPlayerStatePoorNetworkPlaying
};

typedef NS_ENUM(NSInteger, A4xErrorCode) {
    kPlayOk = 0,
    kPlayTimeout = -1,
    kPlayFailed = -2,
    kPlayDenyAccess = -3,
    kPlayInvalidArgument = -4,
    kPlayInProgress = -5,
    kPlayUnkownError = -6,
    kPlayMaxConnectionLimit = 3002,
    //websocket have exist for one user and save sn
    kPlaySignalHaveExist = 3004,
    //not login
    kPlayNotLogin = -1022,
    //webrtcticket expired
    kPlayLoginExpired = -1023,
    //login on other device
    kPlayAccountGetKicked = -1024,
    //same with -1024
    kPlayTokenMissing = -1025,
    //device dormant in plan
    kPlayDeviceInDormancyPlan = -2133,
    //peerconnection connected but not recv first frame
    kPlayNotRecvFirstFrame = -10,
    
};

typedef NS_ENUM(NSInteger, A4xDeviceState) {
    //设备无sdcard或者被拔除
    kDeviceSDCardInvalid = 1,
    //设备无录像文件
    kDeviceNoRecordFile = 2,
    //sdcard格式不支持，需要格式化
    kDeviceSDCardNeedToReformat = 3,
    //当前有人正在观看录像
    kDeviceRecordIsPlaying = 4,
    //SD卡正在格式化
    kDeviceSDCardFormating = 5,
    //设备内部错误
    kDeviceInternalError = 6,
};

typedef NS_ENUM(NSInteger, A4xSignalConnState) {
    /// 空闲
    kSignalConnStateIdle = 0,
    /// 连接中
    kSignalConnStateConnecting = 1,
    /// 验证证书 鉴权
    kSignalConnStateVerifyCerts = 2,
    /// 已连接
    kSignalConnStateConnected = 3,
    /// 断开连接
    kSignalConnStateDisconnect = 4,
    
    kSignalConnStateReconnecting = 5,
    kSignalConnStateReleasing = 6,
    kSignalConnStateClosed = 7,
};

//voice change
typedef NS_ENUM(NSInteger, A4xVoiceEffects) {
    //no change
    kVoiceNoChange = 0,
    //低沉大叔音
    kVoiceLowPitch,
    //怪兽音
    kVoiceMonstrous,
    //可爱少女音
    kVoiceCuteGirl,
};

//MagicPix process state
typedef NS_ENUM(NSInteger, A4xMagicPixProcState) {
    // 失败
    kMagicPixSateError = -1,
    // 未生效
    kMagicPixSateNoEffect = 0,
    // 微亮
    kMagicPixSateLevelOne = 1,
    // 较亮
    kMagicPixSateLevelTwo = 2,
    // 最亮
    kMagicPixSateLevelThree = 3
};

//record file
@interface RecordFile : NSObject
@property (nonatomic, assign)long long startTime;
@property (nonatomic, assign)long long stopTime;

-(instancetype)initWithStartTime:(long long)start stop:(long long)stop;
@end

@interface RecordFileSlice : NSObject
@property (nonatomic, strong)RecordFile* earliestRecordSlice;
@property (nonatomic, copy)NSMutableArray* dayRecordSlice;

-(instancetype)initWithJsonData:(NSDictionary*)jsonData;
@end


@interface RecordDay : NSObject
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, assign) long long startTime;

-(instancetype)initWithHasVideo:(BOOL)hasVideo start:(long long)startTime;
@end

@interface HaveRecordDay : NSObject
@property (nonatomic, copy) NSMutableArray *haveRecordDayList;

-(instancetype)initWithJsonData:(NSDictionary*)jsonData;
@end

@interface RecordPlaySeekPos : NSObject
@property (nonatomic, copy) NSString* action;
@property (nonatomic, assign) long long seekTime;
@end

@interface DeviceEventReport : NSObject
@property (nonatomic, copy) NSString* action;
@property (nonatomic, assign) int eventType;
@end

@interface PtzControlResponse : NSObject
@property (nonatomic, copy) NSString* action;
@property (nonatomic, assign) int result;
@end


//block define
typedef void (^PlayControlResponseBlock)(NSInteger error, NSString* errMsg);
typedef void (^PtzResponseBlock)(NSInteger error, PtzControlResponse* response);
typedef void (^RecordFileResponseBlock)(NSInteger error, RecordFileSlice* response);
typedef void (^HaveRecordDayResponseBlock)(NSInteger error, HaveRecordDay* response);
typedef void (^ScreenshotBlock)(NSInteger error, UIImage* image);
typedef void (^AsyncCallBlock)(NSInteger error, NSString* reason);
typedef void (^MagicPixProcStateBlock)(A4xMagicPixProcState state);

#endif /* A4xCommon_h */
