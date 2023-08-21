//
//  Utility.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/16.
//

#ifndef Utility_h
#define Utility_h
#import "A4xCommon.h"
#import <WebRTC/RTCPeerConnection.h>


@interface Utility : NSObject

+(UInt64)nowMillisecondSince1970;

+(NSString*)getAppDocumentDir;

+(NSString*)mapCorrectResolution:(nonnull NSString*)resolution;
+(NSString*)getVideoResolutionString:(A4xVideoResolution)resolution;

+(NSString*)datetimeFormat:(NSDate*)date;
//redirect NSLog to file
+(void)redirectNSLogToDocumentFolder;

+(NSString *)stringForPlayerState:(A4xObjcWebRtcPlayerState)type;
+(NSString*)stringForP2pState:(RTCPeerConnectionState)type;

@end


@interface NSDictionary (Utilities)

// Creates a dictionary with the keys and values in the JSON object.
+ (NSDictionary *)dictionaryWithJSONString:(NSString *)jsonString;
+ (NSDictionary *)dictionaryWithJSONData:(NSData *)jsonData;

@end


@interface NSMutableArray (QueueAdditions)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end


NSInteger getCpuUsagePercentage(void);

#endif /* Utility_h */
