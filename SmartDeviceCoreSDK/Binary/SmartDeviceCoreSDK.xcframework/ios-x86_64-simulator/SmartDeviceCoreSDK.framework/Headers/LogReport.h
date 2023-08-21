//
//  LogReport.h
//  A4xIOSPlayer
//
//  Created by mac on 2022/1/6.
//

#ifndef LogReport_h
#define LogReport_h
#import "A4xLogReportDelegate.h"

extern NSString* const kLogLivePlayStart;
extern NSString* const kLogWebrtcTicketStart;
extern NSString* const kLogUsingCachedWebrtcTicket;
extern NSString* const kLogWebrtcTicketGetSucc;
extern NSString* const kLogWebrtcTicketGetFail;
extern NSString* const kLogWebsocketConnectStart;
extern NSString* const kLogWebsocketConnectFail;
extern NSString* const kLogWebsocketConnectSucc;
extern NSString* const kLogWebsocketConnectionClose;
extern NSString* const kLogLivePlayStop;
extern NSString* const kLogLivePlayFailed;
extern NSString* const kLogRecvPeerIn;
extern NSString* const kLogRecvPeerInTimeout;
extern NSString* const kLogSendSdpOffer;
extern NSString* const kLogRetrySendSdpOffer;
extern NSString* const kLogIceConnected;
extern NSString* const kLogIceComplete;
extern NSString* const kLogIceDisconnect;
extern NSString* const kLogP2pConnecting;
extern NSString* const kLogP2pConnected;
extern NSString* const kLogP2pDisconnect;
extern NSString* const kLogP2pFailed;
extern NSString* const kLogP2pClosed;
extern NSString* const kLogRecvSdpAnswer;
extern NSString* const kLogDataChannelSucc;
extern NSString* const kLogSendStartLive;   //具体send cmd
extern NSString* const kLogRecvFirstFrame;
extern NSString* const kLogRecvFirstFrameTimeout;
extern NSString* const kLogRecvPeerOut;
extern NSString* const kLogSDPlayStart;
extern NSString* const kLogSDPlayFailed;
extern NSString* const kLogFirstFrameRendered;
extern NSString* const kLogCreateDataChannelSuccess;
extern NSString* const kLogLiveMaxLimit;
extern NSString* const kLogSDPlayStop;


@class MediaPlayer;
@interface LogReport : NSObject

/**
 回调埋点日志给上层业务
   开始直播打开日志
   停止直播关闭日志
 */
@property (nonatomic, weak) id<A4xLogReportDelegate> logReportDelegate;
@property (nonatomic, weak) MediaPlayer* player;
//TODO:
@property (nonatomic, copy) NSString* liveResolution;
@property (nonatomic, copy) NSString* liveRealResolution;
@property (nonatomic, copy) NSString* liveVideoCodec;

-(void)report:(nullable NSString*)topic errMsg:(nonnull NSString*)log rep:(nonnull ReportInfo*)report;

-(void)start;
-(void)stop;

@end

@interface DeviceInfo : NSObject
@property (nonatomic, assign) NSInteger awake;
@property (nonatomic, assign) NSInteger online;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString* model;
@property (nonatomic, copy) NSString* version;

-(NSString*)toString;

@end




#endif /* LogReport_h */
