#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "A4xObjAudioMixer.h"
#import "A4xAudioPitch.h"
#import "A4xMediaKit.h"
#import "A4xSignal.h"
#import "A4xVodDataChannel.h"
#import "SmartDeviceCoreSDK.h"
#import "FKConfigure.h"
#import "FKDefine.h"
#import "FKDownloader.h"
#import "FKDownloadExecutor.h"
#import "FKDownloadManager.h"
#import "FKHashHelper.h"
#import "FKMapHub.h"
#import "FKReachability.h"
#import "FKResumeHelper.h"
#import "FKSystemHelper.h"
#import "FKTask.h"
#import "FKTaskStorage.h"
#import "NSArray+FKDownload.h"
#import "NSData+FKDownload.h"
#import "NSMutableSet+FKDownload.h"
#import "NSString+FKDownload.h"
#import "A4xCommon.h"
#import "A4xDataChannel.h"
#import "A4xLogReportDelegate.h"
#import "A4xObjcWebRtcPlayer.h"
#import "A4xObjcWebRtcPlayerManager.h"
#import "A4xPlayerSDK.h"
#import "A4xRtcConnection.h"
#import "A4xServiceContext.h"
#import "A4xVideoRenderView.h"
#import "DataChannelTransferProxy.h"
#import "A4xNsLog.h"
#import "AVFrameCallback.h"
#import "CommonEntity.h"
#import "DataChannelCommand.h"
#import "DataChannelConnection.h"
#import "GCDTimerManager.h"
#import "ImageCapture.h"
#import "LogReport.h"
#import "MediaFileRecord.h"
#import "MediaPlayer.h"
#import "NetRequestService.h"
#import "P2PConnection.h"
#import "PeerConnectionFactoryProxy.h"
#import "PlayController.h"
#import "RestApiClient.h"
#import "RTCIceCandidate+JSON.h"
#import "RTCSessionDescription+JSON.h"
#import "SignalConnection.h"
#import "StatsBuilder.h"
#import "Utility.h"
#import "WebRTCTicketInfo.h"
#import "A4xObjAudioMixer.h"
#import "A4xAudioPitch.h"
#import "A4xMediaKit.h"
#import "A4xSignal.h"
#import "A4xVodDataChannel.h"

FOUNDATION_EXPORT double SmartDeviceCoreSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char SmartDeviceCoreSDKVersionString[];

