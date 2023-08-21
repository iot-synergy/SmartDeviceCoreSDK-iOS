//
//  AVFrameCallback.h
//  A4xIOSPlayer
//
//  Created by mac on 2022/1/14.
//

#ifndef AVFrameCallback_h
#define AVFrameCallback_h

#import <WebRTC/RTCEAGLVideoView.h>
#import <WebRTC/RTCMTLVideoView.h>
#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCAudioSource.h>
#import <WebRTC/RTCVideoRenderer.h>
#import "P2PConnection.h"

@class AVFrameCallback;
@protocol AVFrameDelegate <NSObject>

-(void)avFrame:(nonnull AVFrameCallback*)cl encodeImage:(nullable RTCEncodedImage *)image;
-(void)avFrame:(nonnull AVFrameCallback*)cl decodeFrame:(nullable RTCVideoFrame *)frame;
-(void)avFrame:(nonnull AVFrameCallback*)cl audioSamples:(nullable NSData*)samples rate:(NSInteger)sampleRate channel:(NSInteger)ch;
@end


typedef void (^onFirstFrameRecvBlock)(void);

#if defined(__arm64__)
@interface AVFrameCallback : RTCMTLVideoView<RTCEncodeVideoSink>

@property (nullable, nonatomic, weak)P2PConnection* p2pConn;
@property (nullable, nonatomic, weak)id<AVFrameDelegate> avFrameDelegate;
@property (atomic, assign)BOOL enable;
@property (nullable, nonatomic, copy) onFirstFrameRecvBlock firstFrameBlock;

/** The frame to be displayed. */
- (void)renderFrame:(nullable RTCVideoFrame *)frame;

- (void)onEncodeFrame:(nullable RTCEncodedImage*)frame;

@end

#else

//@interface AVFrameCallback : RTCEAGLVideoView<RTCEncodeVideoSink>
@interface AVFrameCallback : RTCMTLVideoView<RTCEncodeVideoSink>

@property (nullable, nonatomic, weak)P2PConnection* p2pConn;
@property (nullable, nonatomic, weak)id<AVFrameDelegate> avFrameDelegate;
@property (atomic, assign)BOOL enable;
@property (nullable, nonatomic, copy) onFirstFrameRecvBlock firstFrameBlock;

/** The frame to be displayed. */
- (void)renderFrame:(nullable RTCVideoFrame *)frame;

- (void)onEncodeFrame:(nullable RTCEncodedImage*)frame;
@end
#endif


typedef void (^FirstFrameRecvBlocker)(RTCEncodedImage* _Nullable encFrame);

@interface FirstFrameRecvObserver : RTCMTLVideoView<RTCEncodeVideoSink>
@property (nullable, nonatomic, weak)P2PConnection* p2pConn;

- (void)setFirstFrameRecvBlocker:(nullable FirstFrameRecvBlocker)blocker;
- (void)setListen:(nonnull RTCVideoTrack*)track enable:(BOOL)enable;

- (void)onEncodeFrame:(nullable RTCEncodedImage*)frame;

@end


#endif /* AVFrameCallback_h */
