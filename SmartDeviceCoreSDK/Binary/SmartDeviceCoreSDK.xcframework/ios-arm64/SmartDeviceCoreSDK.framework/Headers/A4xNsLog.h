//
//  A4xNsLog.h
//  HelloIOS
//
//  Created by mac on 2022/4/3.
//

#ifndef A4xNsLog_h
#define A4xNsLog_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface A4xNsLog : NSObject

//日志级别
typedef NS_ENUM(NSUInteger,LogLevel) {
    Level_ERROR    = 0b00001111,  //全部打印
    Level_DEBUG    = 0b00000111,  //打印WARN、INFO、DEBUG
    Level_WARN     = 0b00000011,  //打印INFO和WARN
    Level_INFO     = 0b00000001,  //只打印INFO的日志
    Level_NONE     = 0b00000000   //不打印
};

//获取当前的日志文件路径
FOUNDATION_EXPORT NSString* getLogDir(void);
//设置日志级别
FOUNDATION_EXPORT void setLogLevel(LogLevel level);

FOUNDATION_EXPORT void LOGE(NSString *message,...) NS_FORMAT_FUNCTION(1,2);
FOUNDATION_EXPORT void LOGD(NSString *message,...) NS_FORMAT_FUNCTION(1,2);
FOUNDATION_EXPORT void LOGW(NSString *message,...) NS_FORMAT_FUNCTION(1,2);
FOUNDATION_EXPORT void LOGI(NSString *message,...) NS_FORMAT_FUNCTION(1,2);

@end



@interface Logger : NSObject

-(void)setLogLevel:(int)level path:(NSString*)filePath;
-(void)clear;

-(void)LOGI:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);
-(void)LOGD:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);
-(void)LOGW:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);
-(void)LOGE:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);

-(BOOL)debugWebRtc;
-(BOOL)debugSignal;

@end



#endif /* MyNsLog_h */
