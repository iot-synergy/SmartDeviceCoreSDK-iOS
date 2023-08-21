//
//  ImageCapture.h
//  A4xIOSPlayer
//
//  Created by mac on 2022/2/8.
//

#ifndef ImageCapture_h
#define ImageCapture_h

#import <WebRTC/RTCVideoTrack.h>
#import "AVFrameCallback.h"
#import "A4xObjcWebRtcPlayer.h"

@interface ImageCapture : NSObject<AVFrameDelegate>

@property (nullable, nonatomic, copy)ScreenshotBlock completeBlock;

-(void)capture:(P2PConnection*)p2pConn;

@end


#endif /* ImageCapture_h */
