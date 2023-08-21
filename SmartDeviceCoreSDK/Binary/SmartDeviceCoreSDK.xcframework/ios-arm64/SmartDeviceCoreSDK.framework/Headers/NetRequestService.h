//
//  NetworkTools.h
//  A4xIOSPlayer
//
//  Created by mac on 2021/12/14.
//

#ifndef NetRequestService_h
#define NetRequestService_h

#import <Foundation/Foundation.h>

/** 请求类型的枚举 */
typedef NS_ENUM(NSUInteger, NetHttpRequestType){
    /** get请求 */
    NetHttpRequestTypeGet = 0,
    /** post请求 */
    NetHttpRequestTypePost
};

/**
 http通讯成功的block
 @param responseObject 返回的数据
 */
typedef void (^NetHTTPRequestSuccessBlock)(id responseObject);

/**
 http通讯失败后的block
 @param error 返回的错误信息
 */
typedef void (^NetHTTPRequestFailedBlock)(NSError *error);


//超时时间
extern NSInteger const kAFNetworkingTimeoutInterval;


@interface NetRequestService : NSObject<NSURLSessionTaskDelegate>


NS_ASSUME_NONNULL_BEGIN


+ (NetRequestService *)shared;

- (void)postRequestWithApi:(NSString *)api
                    header:(NSDictionary *)headers
                     param:(NSDictionary *)param
                   success:(void(^)(NSDictionary *rootDict))success
                   failure:(void(^)(id error))failure;


NS_ASSUME_NONNULL_END

- (long)getHttpConnectElapse;
- (void)resetHttpConnectElapse;

@end


#endif /* NetworkTools_h */
