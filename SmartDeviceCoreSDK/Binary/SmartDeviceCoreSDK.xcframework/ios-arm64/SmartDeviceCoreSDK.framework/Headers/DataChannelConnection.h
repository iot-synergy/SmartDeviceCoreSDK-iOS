//
//  DataChannelConnection.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/16.
//

#ifndef DataChannelConnection_h
#define DataChannelConnection_h
#import <WebRTC/RTCDataChannel.h>
#import <WebRTC/RTCPeerConnection.h>
#import "A4xDataChannel.h"

typedef NS_ENUM(NSInteger, DataChannelState) {
    //connecting
    kDataChannelStateConnecting,
    //closing
    kDataChannelStateClosing,
    // State when disconnected.
    kDataChannelStateClosed,
    // State when connection is established but not ready for use.
    kDataChannelStateOpen,
    // State when connection is established and registered.
    kDataChannelStateRegistered,
    // State when connection encounters a fatal error.
    kDataChannelStateError
};

@class DataChannelReceive;
@class DataChannelConnection;


@interface DataChannelConnection<RTCDataChannelDelegate> : A4xDataChannel

@property(nonatomic, strong)RTCDataChannel* dataChannel;
@property(nonatomic, assign)RTCDataChannelState state;

-(void)createDataChannel:(RTCPeerConnection*)peerConnection label:(NSString*)label;

@end

#endif /* DataChannelConnection_h */
