//
//  PeerConnectionFactoryProxy.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/15.
//

#ifndef PeerConnectionFactoryProxy_h
#define PeerConnectionFactoryProxy_h

#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCDefaultVideoDecoderFactory.h>
#import <WebRTC/RTCDefaultVideoEncoderFactory.h>
#import <WebRTC/RTCIceServer.h>
#import <WebRTC/RTCMediaConstraints.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCRtpSender.h>
#import <WebRTC/RTCRtpTransceiver.h>
#import <WebRTC/RTCTracing.h>
#import <WebRTC/RTCVideoSource.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCCallbackLogger.h>
#import <WebRTC/RTCLogging.h>

typedef void(^RTCCallbackLoggerHandler)(NSString* message, RTCLoggingSeverity severity);

@interface PeerConnectionFactoryProxy : NSObject

@property (atomic, assign)NSInteger headset;

+(PeerConnectionFactoryProxy*)instance;

-(void)audioConfig:(NSInteger)flag;

-(void)bluetoothAndHandsetListen;

-(RTCPeerConnectionFactory*)createFactory;
//webrtc log callback
-(void)openRTCLog:(nullable RTCCallbackLoggerHandler)loggerHandler;
-(void)closeRTCLog;

@end


#endif /* PeerConnectionFactoryProxy_h */
