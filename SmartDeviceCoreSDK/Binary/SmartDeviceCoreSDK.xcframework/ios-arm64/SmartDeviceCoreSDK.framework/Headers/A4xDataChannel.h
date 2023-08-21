//
//  A4xDataChannel.h
//  Pods
//
//  Created by mac on 2023/5/15.
//

#ifndef A4xDataChannel_h
#define A4xDataChannel_h
#import <WebRTC/RTCDataChannel.h>

@protocol A4xDataChannelDelegate;

@interface A4xDataChannel : NSObject
-(void)addDataChannelDelegate:(id<A4xDataChannelDelegate>)delegate;
-(void)close;
-(RTCDataChannelState)getChannelState;
-(NSString*)getChannelLabel;
-(int)getChannelId;
-(NSInteger)sendData:(NSData*)data binary:(BOOL)isBinary;
@end

@protocol A4xDataChannelDelegate <NSObject>

-(void)datachannel:(nonnull A4xDataChannel*)channel didChannelStateChange:(int)channelId label:(NSString*)label state:(RTCDataChannelState)state;
-(void)datachannel:(nonnull A4xDataChannel*)channel didRecvMessage:(NSData*)msg;
-(void)datachannel:(nonnull A4xDataChannel*)channel didRecvBinaryMessage:(NSData*)msg channId:(int)channelId;
@end

#endif /* A4xDataChannel_h */
