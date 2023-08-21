//
//  PlayController.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/22.
//

#ifndef PlayController_h
#define PlayController_h

#import "DataChannelCommand.h"
#import "A4xObjcWebRtcPlayer.h"

@interface ResponseBlockCollector : NSObject
@property (nullable, nonatomic, copy) PlayControlResponseBlock controlBlock;
@property (nullable, nonatomic, copy) PtzResponseBlock ptzBlock;
@property (nullable, nonatomic, copy) RecordFileResponseBlock recordFileBlock;
@property (nullable, nonatomic, copy) HaveRecordDayResponseBlock haveRecordDayBlock;
@end

@interface RequestEntity : NSObject

@property (nonnull, nonatomic, copy)NSString* requestId;
@property (nullable, nonatomic, strong)ResponseBlockCollector* responseProxy;
@end

@interface PlayController : NSObject
@property (nonnull, nonatomic, strong) DataChannelCommand* command;

-(void)onCommandResponse:(nonnull DataChannelReceive*)command;

-(void)startLive:(nonnull NSString*)resolution;

-(void)stopLive;

-(void)startPlayback:(long long)startTime;

-(void)stopPlayback;

-(void)getHasRecordDays:(long long)startTime stop:(long long)stopTime
            resultBlock:(nullable HaveRecordDayResponseBlock)block;

-(NSInteger)getRecordFileList:(long long)startTime stop:(long long)stopTime
                  resultBlock:(nullable RecordFileResponseBlock)block;

//1:关 2:开
-(void)setWhiteLight:(BOOL)open response:(nullable PlayControlResponseBlock)block;

//
-(void)closeP2P;

-(void)setLiveResolution:(nonnull NSString*)resolution response:(nullable PlayControlResponseBlock)block;

//alarm
-(void)triggerAlarm:(nullable PlayControlResponseBlock)block;

//设置云台控制参数
-(void)PTZControl:(float)pitch yaw:(float)yaw response:(nullable PtzResponseBlock)block;

-(void)addPresetCoordinate:(nullable PlayControlResponseBlock)block;

//保存云台位置点
-(void)setPreset:(nonnull NSString*)coordinate response:(nullable PlayControlResponseBlock)block;

//临时人形追踪状态 1 open  0 close
-(void)setMotionTrackStatus:(NSInteger)status;

-(void)getMotionTrackStatus:(nonnull PlayControlResponseBlock)block;

-(void)changeTransceiverOffer:(nonnull NSString*)offer response:(nonnull PlayControlResponseBlock)block;

//回复datachannel消息
-(void)datachannelAnswer:(nonnull NSString*)requestId cmd:(nonnull NSString*)cmd answer:(nullable NSString*)answer;

-(void)start;
-(void)stop;
@end


#endif /* PlayController_h */
