//
//  A4xObjcWebRtcPlayerManager.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/28.
//

#ifndef A4xObjcWebRtcPlayerManager_h
#define A4xObjcWebRtcPlayerManager_h
#import "A4xObjcWebRtcPlayer.h"
#import "A4xServiceContext.h"

@interface A4xObjcWebRtcPlayerManager : NSObject
+(A4xObjcWebRtcPlayerManager*)instance;

-(int)a4xSDKInit:(NSString*)token
          server:(NSString*)serverUrl
         appInfo:(AppInfo*)appInfo;

-(A4xObjcWebRtcPlayer*)createPlayer:(NSString*)sn;
-(void)destroyPlayer:(NSString*)sn;
-(void)stopAll;
-(void)stopOther:(NSString*)sn;
-(NSArray<A4xObjcWebRtcPlayer*>*)getAllPlayers;
@end

#endif /* A4xObjcWebRtcPlayerManager_h */
