//
//  A4xServiceContext.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/24.
//

#ifndef A4xServiceContext_h
#define A4xServiceContext_h

@interface AppInfo : NSObject

@property (nonatomic, copy) NSString* appName;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, copy) NSString* versionName;
@property (nonatomic, copy) NSString* bundle;
@property (nonatomic, copy) NSString* appType;
@property (nonatomic, assign) NSInteger channelId;
@property (nonatomic, copy) NSString* tenantId;
@property (nonatomic, copy) NSString* apiVersion;
@property (nonatomic, copy) NSString* countryNo;
@property (nonatomic, copy) NSString* countlyId;
@property (nonatomic, copy) NSString* language;
-(NSData*)jsonData;

@end

@interface A4xServiceContext : NSObject

@property (nonatomic, copy) NSString* token;
@property (nonatomic, copy) NSString* nodeUrl;
@property (nonatomic, strong) AppInfo* appInfo;

+(A4xServiceContext*)instance;

-(void)initServiceContext:(NSString*)token
                   server:(NSString*)serverUrl
                   appInfo:(AppInfo*)appInfo;
-(BOOL)isDebug;

@end

#endif /* A4xServiceContext */
