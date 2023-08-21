//
//  CommonEntity.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/16.
//

#ifndef CommonEntity_h
#define CommonEntity_h


typedef NS_ENUM(NSInteger, PlayType) {
  kPlayLive,
  kPlayback,
  //单独建立rtc连接
  kRtcConnection,
};

typedef NS_ENUM(NSInteger, NetworkMode) {
    kNetworkModeWIFI,
    kNetworkModeAP,
};

typedef NS_ENUM(NSInteger, DeviceOnline) {
    kDevOffline,
    kDevOnline
};

@interface IceServerEntity : NSObject
    
@property(nonatomic, copy) NSString* url;
@property(nonatomic, copy) NSString * userName;
@property(nonatomic, copy) NSString *credential;

-(instancetype)initWithUrl:(NSString*)urls userName:(NSString*)name credential:(NSString*)credent;
-(NSData*)jsonData;
@end


@interface AudioTestEntity : NSObject
@property (nonatomic, copy)NSString* action;
@property (nonatomic, assign)long long timestamp;
@property (nonatomic, assign)BOOL openTest;
@property (nonatomic, assign)float amplitude;
@property (nonatomic, assign)float threshold;
@end

@interface APModeParameter : NSObject
@property (nonatomic, copy)NSString* token;
@property (nonatomic, copy)NSString* userId;
@property (nonatomic, copy)NSString* apAddr;
@end

//live stream custom parameters
@interface ObjcCustomParam : NSObject
//是否忽略休眠计划
@property (nonatomic, assign)BOOL verifyDormancyPlan;

-(instancetype)initWithDictionary:(NSDictionary*)dic;
@end


@interface Bitrate : NSObject
@property (nonatomic, assign)int minBitrate;
@property (nonatomic, assign)int maxBitrate;
@property (nonatomic, assign)int targetBitrate;

-(instancetype)initWithBitrate:(int)min max:(int)max target:(int)target;

@end

@interface DevAutoBitrateControl : NSObject
@property (atomic, copy)NSMutableArray<Bitrate*>* mainBitrate;
@property (atomic, copy)NSMutableArray<Bitrate*>* subBitrate;

-(instancetype)initWithSpecificBitrate:(NSDictionary*)bitrate;
-(Bitrate*)bitrateBound:(NSString*)resolution;
-(int)findDevEncodeBitrate:(NSString*)resolution suggest:(int)bitrate;
@end
#endif /* CommonEntry_h */
