//
//  RestApiClient.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/24.
//

#ifndef RestApiClient_h
#define RestApiClient_h
#import "NetRequestService.h"
#import "A4xLogReportDelegate.h"
#import "CommonEntity.h"

typedef void (^RestResponseBlock)(int errCode, id response);

@interface RestApiClient : NSObject
+(void)getWebRTCTicket:(NSString*)sn
                 custom:(nullable ObjcCustomParam*)param
               response:(RestResponseBlock)block;

+(void)getDeviceInfo:(NSString*)sn
            response:(RestResponseBlock)block;

+(void)logEventReport:(ReportInfo*)logReport;

+(void)constructConsistentConnection;
+(void)keepAlive;
+(void)destroyConnection;
@end



#endif /* RestApiClient_h */
