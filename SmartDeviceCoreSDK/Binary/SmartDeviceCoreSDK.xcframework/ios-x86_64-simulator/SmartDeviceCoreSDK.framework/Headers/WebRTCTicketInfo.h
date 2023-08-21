//
//  WebRTCTicketInfo.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/24.
//

#ifndef WebRTCTicketInfo_h
#define WebRTCTicketInfo_h
#import "CommonEntity.h"

@interface TicketDataBean : NSObject
@property (nonatomic, copy)NSString* traceId;
@property (nonatomic, copy)NSString* groupId;
@property (nonatomic, copy)NSString* role;
@property (nonatomic, copy)NSString* userId;
@property (nonatomic, assign)long long appStopLiveTimeout;
@property (nonatomic, assign)long long expirationTime;
@property (nonatomic, copy)NSString* signalServerUrl;
@property (nonatomic, copy)NSString* signalServerIpAddress;
@property (nonatomic, copy)NSString* sign;
@property (nonatomic, assign)long long time;
@property (nonatomic, assign)int signalPingInterval;
@property (nonatomic, strong)NSArray<NSDictionary*>* iceServer;

-(instancetype)initWithData:(NSDictionary*)data;
-(NSString*)getUrlPath;
-(NSData*)jsonData;
-(NSArray<NSDictionary*>*)getIceServer;
-(void)parse:(NSDictionary*)data;
@end

@interface ErrorResult : NSObject
@property (nonatomic, assign)NSInteger errNO;
@property (nonatomic, copy)NSString* errMsg;

-(instancetype)initWithResult:(NSDictionary*)result;
-(NSData*)jsonData;
-(void)parse:(NSDictionary*)result;
@end

@interface WebRTCTicketInfo : NSObject
@property (nonatomic, strong) ErrorResult* errResult;
@property (nonatomic, strong) TicketDataBean* ticketData;

-(void)fillTicketInfo:(NSDictionary*)ticket;
-(NSData*)jsonData;
-(BOOL)useLocalCacheWebrtcTicket:(NSString*)sn;
-(void)cacheToLocalStorage:(NSString*)sn ticket:(NSDictionary*)ticketInfo;
-(void)cleanCacheData:(NSString*)sn;
@end

#endif /* WebRTCTicketInfo_h */
