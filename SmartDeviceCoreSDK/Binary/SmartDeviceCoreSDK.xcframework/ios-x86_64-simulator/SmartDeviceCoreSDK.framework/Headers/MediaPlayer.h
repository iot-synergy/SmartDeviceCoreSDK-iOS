//
//  MediaPlayer.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/20.
//

#ifndef MediaPlayer_h
#define MediaPlayer_h

#import "SignalConnection.h"
#import "P2PConnection.h"
#import "A4xObjcWebRtcPlayer.h"
#import "A4xDataChannel.h"

@interface MediaPlayer<P2pConnectionDelegate, A4xSignalDelegate, A4xDataChannelDelegate> : A4xObjcWebRtcPlayer

-(instancetype)initWithSN:(NSString*)sn;

@end

#endif /* MediaPlayer_h */
