//
//  DataChannelCommand.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/22.
//

#ifndef DataChannelCommand_h
#define DataChannelCommand_h

#import "A4xDataChannel.h"
#import <WebRTC/RTCPeerConnection.h>

//request command
extern NSString* const kCmdStartLive;
extern NSString* const kCmdStopLive;
extern NSString* const kCmdStartPlayback;
extern NSString* const kCmdStopPlayback;
extern NSString* const kCmdGetHaveRecordDays;
extern NSString* const kCmdGetRecordFileList;
extern NSString* const kCmdSetWhiteLight;
extern NSString* const kCmdCloseP2P;
extern NSString* const kCmdTriggerAlarm;
extern NSString* const kCmdPTZControl;
extern NSString* const kCmdSetResolution;
extern NSString* const kCmdGetCurCoordinate;
extern NSString* const kCmdSetCurCoordinate;
extern NSString* const kCmdSetMotionTrackStatus;
extern NSString* const kCmdGetMotionTrackStatus;

extern NSString* const kCmdRequestChangeTransceiverOffer;
extern NSString* const kCmdChangeTransceiverOffer;
extern NSString* const kCmdAudioTest;
extern NSString* const kCmdReplaySeek;
extern NSString* const kCmdReplayDevReport;
extern NSString* const kCmdDataChannelConnected;
extern NSString* const kCmdDevAutoBitrate;

//发送datachannel消息回调
typedef void (^DataChannelSendBlock)(NSString* cmd);

@interface DataChannelCommand : NSObject

@property(nonatomic, weak) A4xDataChannel* weakDataChannel;
@property(nonatomic, readwrite) RTCPeerConnectionState p2pConnState;
@property(nonatomic, copy, nullable)DataChannelSendBlock dataChannelSendBlock;

-(NSInteger)sendCommand:(nonnull NSString*)request param:(nullable NSDictionary*)param
              requestId:(nonnull NSString*)requestId async:(BOOL)async;
-(void)start;
-(void)stop;
//通道是否可用
-(BOOL)ready;
-(void)readyToSend;
@end


@interface CommandParam : NSObject
@property (nonatomic, copy, nonnull)NSString* requestId;
@property (nonatomic, copy, nonnull)NSString* connectionId;
@property (nonatomic, assign)long long timestamp;
@property (nonatomic, copy, nonnull)NSString* action;
@property (nonatomic, copy, nonnull)NSDictionary* parameters;

-(instancetype)initWithRequestId:(NSString*)requestId
                    connectionId:(NSString*)connId
                            time:(long long)time
                          action:(NSString*)action
                           param:(NSString*)param;
-(NSData*)JsonData;

@end


@interface DataChannelReceive : NSObject
@property (nonatomic, copy)NSString* requestId;
@property (nonatomic, copy)NSString* connectionId;
@property (nonatomic, assign)long long timestamp;
@property (nonatomic, copy)NSString* action;
@property (nonatomic, assign)int error;
@property (nonatomic, copy)NSDictionary* receiveData;
@property (nonatomic, assign)int channelId;
@end

#endif /* DataChannelCommand_h */
