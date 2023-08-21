//
//  MediaFileRecord.h
//  A4xIOSPlayer
//
//  Created by mac on 2022/1/14.
//

#ifndef MediaFileRecord_h
#define MediaFileRecord_h

#import "AVFrameCallback.h"
#import "P2PConnection.h"

@interface MediaFileRecord<AVFrameDelegate> : NSObject

@property (nullable, nonatomic, weak)P2PConnection* p2pConn;

-(int)startRecord:(P2PConnection*)p2pConn file:(nonnull NSString*)filePath;
-(void)stopRecord;
-(void)recordLocalAudioSamples:(int8_t*)audio len:(NSInteger)len;
-(void)recordRemoteAudioSamples:(int8_t*)audio len:(NSInteger)len;
@end


#endif /* MediaFileRecord_h */
