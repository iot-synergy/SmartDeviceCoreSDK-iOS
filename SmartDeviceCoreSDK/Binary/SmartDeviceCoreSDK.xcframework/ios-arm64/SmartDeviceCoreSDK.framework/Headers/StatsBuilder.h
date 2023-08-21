//
//  StatsBuilder.h
//  A4xIOSPlayer
//
//  Created by mac on 2022/1/26.
//

#ifndef StatsBuilder_h
#define StatsBuilder_h

#import <Foundation/Foundation.h>
#import <WebRTC/RTCStatisticsReport.h>

@class RTCLegacyStatsReport;

static NSString* const kProtocolTypeUnknown = @"unknown";
static NSString* const kProtocolTypeP2p = @"p2p";
static NSString* const kProtocolTypeRelay = @"relay";

@interface StatsBuilder : NSObject

@property(nonatomic, readonly) NSString *statsString;
@property(nonatomic, copy) NSString* videoRecvBitrate;
@property(nonatomic, assign) double videoRecvBitrateDouble;
@property(nonatomic, assign) double suggestBitrateDouble;
//满足切换auto resolution的项
@property(nonatomic, assign) int reachToNetworkPoorItem;

- (void)parseStatsReport:(NSDictionary<NSString*, RTC_OBJC_TYPE(RTCStatistics)*>*) stats;
- (NSString*)peerConnectionType;
- (NSMutableDictionary*)debugStatsInfo;
//check if network poor should switch auto resolution
-(BOOL)checkNetworkPoor;
-(void)reset;

@end

@interface BitrateTracker : NSObject
/** The bitrate in bits per second. */
@property(nonatomic, readonly) double bitrate;
/** The bitrate as a formatted string in bps, Kbps or Mbps. */
@property(nonatomic, readonly) NSString *bitrateString;

// frame decoded rate
@property(nonatomic, readonly) double frameDecodedRate;
// frame received rate
@property(nonatomic, readonly) double frameRecvRate;


/** Converts the bitrate to a readable format in bps, Kbps or Mbps. */
+ (NSString *)bitrateStringForBitrate:(double)bitrate;
/** Updates the tracked bitrate with the new byte count. */
- (void)updateBitrateWithCurrentByteCount:(NSInteger)byteCount;


@end


#endif /* StatsBuilder_h */
