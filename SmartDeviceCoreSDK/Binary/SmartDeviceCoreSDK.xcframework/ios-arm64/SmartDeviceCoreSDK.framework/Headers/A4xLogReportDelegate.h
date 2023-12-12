//
//  A4xLogReportDelegate.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/28.
//

#ifndef A4xLogReportDelegate_h
#define A4xLogReportDelegate_h

@class A4xObjcWebRtcPlayer;

@interface ReportInfo : NSObject
@property (nonatomic, copy) NSString* reportTopic;
@property (nonatomic, copy) NSString* serialNumber;  //设备ID
@property (nonatomic, copy) NSString* liveId;
@property (nonatomic, copy) NSString* sessionId;
@property (nonatomic, copy) NSString* clickId;
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* event; //startlive,stoplive sendoffer,changeResolution,setWightLight
@property (nonatomic, copy) NSString* connectLog;  //具体的播放日志信息
@property (nonatomic, copy) NSString* error_msg;  //PlayErrorStep 具体的错误步骤
@property (nonatomic, assign) long long wait_time;  //从发起直播到收到第一帧图像的耗时:milliseconds
@property (nonatomic, copy) NSString* p2p_connection_type; //p2p, relay
@property (nonatomic, copy) NSString* stream_protocol; //webrtc
@property (nonatomic, copy) NSString* download_speeds;  //getstats
@property (nonatomic, copy) NSString* devState; //直播设备状态
@property (atomic, assign) BOOL isClicked; //是否用户点击打开
@property (atomic, assign) BOOL liveInterrupt; //是否打断
//TODO:
@property (atomic, assign) long long elapse; //http connect elapse
@property (atomic, copy) NSString* videoCodec;

- (NSDictionary *)toMap;

@end


/**
 * 上报的事件类型
 * 根据事件类型调用对应的上报接口
 */
extern NSString* const kReportEventGetWebRTCTicket; //getwebrtcticket
extern NSString* const kReportEventLiveStart; //startlive前
extern NSString* const kReportEventLiveSuccess; //收到第一帧videoframe
//超时收不到数据(第一帧)或设备超过最大直播人数或直播过程中某一步链接失败，释放p2p或网络连接断开或者链接超时
extern NSString* const kReportEventLiveFail; //getwebrtcticket
extern NSString* const kReportEventLiveInterrupt; //liveToplimit或非正常stop
extern NSString* const kReportEventLiveSendOffer; //send offer
extern NSString* const kReportEventLiveP2pConnected; //onConnectionChange state=CONNECTED
extern NSString* const kReportEventLiveWebsocketStart; //websocket onSocketConnecting
extern NSString* const kReportEventLiveWebsocketConnected; //websocket onSocketConnected onOpen
extern NSString* const kReportEventLiveStop; //close live play
extern NSString* const kReportEventDataChannelSend; //send message on datachannel
extern NSString* const kReportEventDataChannelSuccess; ////recv datachannel response
extern NSString* const kReportEventSDLivePlayStart; //
extern NSString* const kReportEventSDLivePlaySuccess; //
extern NSString* const kReportEventSDLivePlayFail; //
extern NSString* const kReportEventSDLivePlayInterrupt; //
extern NSString* const kReportEventSDLivePlayStop; //

@protocol A4xLogReportDelegate <NSObject>

-(void)mediaplayer:(A4xObjcWebRtcPlayer*)player onReport:(NSString*)topic report:(ReportInfo*)report;

@end

#endif /* IA4xLogReportListener_h */
