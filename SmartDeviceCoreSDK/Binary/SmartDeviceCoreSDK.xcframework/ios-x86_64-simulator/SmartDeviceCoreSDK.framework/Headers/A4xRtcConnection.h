//
//  A4xRtcConnection.h
//  Pods
//
//  Created by mac on 2023/5/15.
//

#ifndef A4xRtcConnection_h
#define A4xRtcConnection_h

#import "A4xDataChannel.h"
#import <WebRTC/RTCPeerConnection.h>

typedef void (^RtcConnectionStateChangeBlock)(RTCPeerConnectionState state);

@interface A4xRtcConnection : NSObject

-(RTCPeerConnectionState)getState;
-(A4xDataChannel*)createDataChannel:(NSString*)label delegate:(id<A4xDataChannelDelegate>)channelDelegate;
-(A4xDataChannel*)getDataChannel;
-(void)setStateChangeBlock:(RtcConnectionStateChangeBlock)stateChangeBlock;

@end

#endif /* A4xRtcConnection_h */
