//
//  P2PConnection.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/15.
//

#ifndef P2PConnection_h
#define P2PConnection_h

#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCVideoSource.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCAudioSource.h>

#import "A4xCommon.h"
#import "A4xNsLog.h"
#import "A4xRtcConnection.h"

@class P2PConnection;

typedef void(^RecordAudioBlock)(int16_t* audioSample, NSInteger sampleSize);

@protocol P2pConnectionDelegate <NSObject>

- (void)p2pConnection:(P2PConnection *)conn didChangeConnectionState:(RTCPeerConnectionState)state;

- (void)p2pConnection:(P2PConnection *)conn didChangeIceConnectionState:(RTCIceConnectionState)state;
- (void)p2pConnection:(P2PConnection*)conn didGenerateIceCandidate:(RTCIceCandidate*)candidate;
-(void)p2pConnection:(P2PConnection *)conn didRemoveIceCandidates:(RTCIceCandidate*)candidate;

-(void)p2pConnection:(P2PConnection *)conn didAddStream:(RTCMediaStream *)stream;
-(void)p2pConnection:(P2PConnection *)conn didOpenDataChannel:(RTCDataChannel *)dataChannel;

- (void)p2pConnection:(P2PConnection *)conn didError:(NSError *)error;
- (void)p2pConnection:(P2PConnection *)conn didGetStats:(NSArray *)stats;
@end


@interface P2PConnection<RTCPeerConnectionDelegate> : A4xRtcConnection
@property(nonatomic, strong)   RTCAudioTrack* remoteAudioTrack;
@property(nonatomic, strong)   RTCAudioTrack* localAudioTrack;
@property(nonatomic, strong)   RTCVideoTrack* remoteVideoTrack;
@property(nonatomic, strong)   RTCPeerConnection* peerConnection;
@property(nonatomic, strong)  RTCPeerConnectionFactory* factory;
@property(nonatomic, strong)  NSMutableArray<RTCIceServer*>* iceServers;
@property(nonatomic, strong)  RTCMediaConstraints* defaultPeerConnectionConstraints;
@property(nonatomic, readwrite) RTCPeerConnectionState state;
@property(nonatomic, weak) id<P2pConnectionDelegate> delegate;
@property(nullable, nonatomic, copy) RecordAudioBlock localAudioBlock;
@property(nullable, nonatomic, copy) RecordAudioBlock remoteAudioBlock;
@property(nonatomic, assign)     BOOL haveLocalDescription;
//trace log
@property(nullable, nonatomic, weak) Logger* traceLog;
//
@property(nullable, nonatomic, strong)A4xDataChannel* baseDataChannel;


-(void)createPeerConnection:(NSArray<NSDictionary*>*)iceServer;
-(void)createOffer:(void (^_Nonnull)(NSString *_Nullable sdp,
                             NSError *_Nullable error))onCreateSuccess;
-(RTCAudioTrack*_Nullable)createAudioTrack;
-(void)createMediaSenders;

-(RTCMediaConstraints *_Nullable)defaultOfferConstraints;

-(void)setRemoteDescription:(NSString*_Nonnull)message;
-(void)addIceCandidate:(NSString*_Nonnull)message;

-(void)addVideoSink:(nonnull id<RTCVideoRenderer>)render;
-(void)removeVideoSink:(nonnull id<RTCVideoRenderer>)render;

-(void)startAudioRecord;
-(void)stopAudioRecord;

-(void)setLocalAudioBlock:(RecordAudioBlock _Nullable)localAudioBlock;
-(void)setRemoteAudioBlock:(RecordAudioBlock _Nullable)localAudioBlock;
-(void)localSpeakEnable:(BOOL)enable;
-(void)remoteAudioEnable:(BOOL)enable;
-(void)setVoiceEffect:(A4xVoiceEffects)voiceEffect;
-(A4xVoiceEffects)getVoiceEffect;


-(void)stop;
-(void)close;
@end


#endif /* P2PConnection_h */
