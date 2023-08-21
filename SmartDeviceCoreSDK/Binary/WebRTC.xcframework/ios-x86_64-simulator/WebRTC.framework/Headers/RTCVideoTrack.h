/*
 *  Copyright 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <WebRTC/RTCMediaStreamTrack.h>

#import <WebRTC/RTCMacros.h>

NS_ASSUME_NONNULL_BEGIN
// for iOS assembly
#ifndef A4X_RTC
#define A4X_RTC
#endif

@protocol RTC_OBJC_TYPE
(RTCVideoRenderer);
@class RTC_OBJC_TYPE(RTCPeerConnectionFactory);
@class RTC_OBJC_TYPE(RTCVideoSource);

#ifdef A4X_RTC
@protocol RTC_OBJC_TYPE(RTCEncodeVideoSink);
#endif

RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE (RTCVideoTrack) : RTC_OBJC_TYPE(RTCMediaStreamTrack)

/** The video source for this video track. */
@property(nonatomic, readonly) RTC_OBJC_TYPE(RTCVideoSource) *source;

- (instancetype)init NS_UNAVAILABLE;

/** Register a renderer that will render all frames received on this track. */
- (void)addRenderer:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)renderer;

/** Deregister a renderer. */
- (void)removeRenderer:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)renderer;

#ifdef A4X_RTC
- (void)addEncodeVideoSink:(id<RTC_OBJC_TYPE(RTCEncodeVideoSink)>)sink;
- (void)removeEncodeVideoSink:(id<RTC_OBJC_TYPE(RTCEncodeVideoSink)>)sink;
#endif

@end

NS_ASSUME_NONNULL_END
