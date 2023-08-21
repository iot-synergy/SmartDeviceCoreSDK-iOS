//
//  A4xVideoRenderView.h
//  A4xIOSPlayer
//
//  Created by mac on 2022/1/5.
//

#ifndef A4xVideoRenderView_h
#define A4xVideoRenderView_h

#import <WebRTC/RTCEAGLVideoView.h>
#import <WebRTC/RTCMTLVideoView.h>
#import <WebRTC/RTCVideoRenderer.h>
#import "A4xCommon.h"

typedef void (^FrameResolutionChangeBlock)(CGFloat width, CGFloat height);
typedef void (^FirstFrameRenderedBlock)(void);
typedef void (^VideoStreamAlgorithmCallback)(uint8_t* _Nullable frameBuff, int len, int width, int height, int status);
typedef void (^ImageAlgorithmCallBack)(uint8_t* _Nullable imgBuff, int len, int width, int height, int status);

@protocol A4xVisionAlgorithmDelegate <NSObject>
-(void)processVideoStream_yuv:(uint8_t*_Nullable)y u:(uint8_t*_Nullable)u v:(uint8_t*_Nullable)v w:(int)frameWidth h:(int)frameHeight cb:(VideoStreamAlgorithmCallback _Nullable )callback;
//-(void)processImage:(uint8_t*)inputImageData w:(int)imageWidth h:(int)imageHeight cb:(ImageAlgorithmCallBack)callback;
@end

@interface A4xVideoResolutionChangeListener <RTCVideoViewDelegate> : NSObject
@property (nonatomic, strong, nullable)FrameResolutionChangeBlock resolutionChangeBlock;

@end

/*
@interface A4xVideoGLESRenderView : RTCEAGLVideoView
@property(nonatomic, strong) A4xVideoResolutionChangeListener* _Nullable resolutionChangeListener;
@property(nonatomic, weak) id<A4xVisionAlgorithmDelegate> _Nullable visionAlgorithmDelegate;
@property(nonatomic, copy, nullable)FirstFrameRenderedBlock firstFrameRenderedBlock;
-(instancetype)initWithFrame:(CGRect)frame;

@end
 */

@interface A4xVideoMetalRenderView <SuperResolutionDelegate, RTCVideoViewDelegate> : RTCMTLVideoView
@property(nonatomic, strong, nullable) A4xVideoResolutionChangeListener* resolutionChangeListener;
@property(nonatomic, weak) id<A4xVisionAlgorithmDelegate> _Nullable visionAlgorithmDelegate;
@property(nonatomic, copy, nullable) FirstFrameRenderedBlock firstFrameRenderedBlock;
@property(nonatomic, assign)BOOL waitFirstFrame;
@property(nonatomic, strong, nullable) RTCVideoFrame* cacheVideoFrame;
// magicpix process state callbck
@property(nonatomic, copy, nullable) MagicPixProcStateBlock magicPixProcStateBlock;
// enable/disable magicpix
@property(atomic, assign) BOOL enableMagicPix;
// status:[-1:失败]<[0:无需]<[1:微亮]<[2:较亮]<[3:最亮] magicpix
@property(nonatomic, assign) int magicPixProcState;

-(instancetype)initWithFrame:(CGRect)frame;

/** The frame to be displayed. */
- (void)renderFrame:(nullable RTCVideoFrame *)frame;
-(void)screenshot:(double)quality complete:(nonnull ScreenshotBlock)completeBlock;

@end


@interface FrameInfo : NSObject
@property(nonatomic, assign)long long frameTime;
@property(nonatomic, assign)int rotation;
@property(nonatomic, assign)long long recvTime;

-(instancetype)initWithTime:(long long)frameTime rota:(int)rotation recvtm:(long long)recvTime;
@end

#endif /* A4xVideoRenderView_h */
