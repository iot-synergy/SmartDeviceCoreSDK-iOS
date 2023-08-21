//
//  DataChannelTransferProxy.h
//  Pods
//
//  Created by mac on 2023/5/16.
//

#ifndef DataChannelTransferProxy_h
#define DataChannelTransferProxy_h

#import "A4xObjcWebRtcPlayer.h"
#import "A4xRtcConnection.h"
#import "A4xDataChannel.h"

@interface DataChannelTransferProxy : NSObject
+(DataChannelTransferProxy*)instance;

+(void)initVodDataChannel;

+(void)createRtcConnection:(NSString*)serialNum;
+(void)closeRtcConnection:(NSString*)serialNum;
+(int)createDataChannel:(NSString*)serialNum label:(NSString*)label;
+(void)closeDataChannelById:(NSString*)serialNum channId:(int)channelId;
+(void)closeDataChannelByLabel:(NSString*)serialNum label:(NSString*)label;
+(int)getRtcConnectionState:(NSString*)serialNum;
+(NSString*)getDataChannelState:(NSString*)serialNum label:(NSString*)label;
+(int)sendDCMessage:(NSString*)serialNum msg:(NSString*)message;
@end


@interface RtcConnection<A4xDataChannelDelegate> : NSObject
@property(nonatomic, copy)NSString* serialNumber;
@property(nonatomic, strong)A4xObjcWebRtcPlayer* player;
@property(nonatomic, strong)A4xRtcConnection* p2pConnection;
@property(nonatomic, strong)A4xDataChannel* cmdTransportChannel;
@property(nonatomic, assign)RTCPeerConnectionState connectionState;
@property(nonatomic, strong)NSMutableArray* datachannelList;

-(void)createRtcConnection:(NSString*)serialNum;
-(void)closeP2pConnection;
-(A4xDataChannel*)createDataChannel:(NSString*)label;
-(void)removeDataChannel:(int)channelId;
-(A4xDataChannel*)getDataChannelByLabel:(NSString*)label;
-(A4xDataChannel*)getDataChannelById:(int)channelId;
-(int)getConnectionState;
@end

#endif /* DataChannelTransferProxy_h */
