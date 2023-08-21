//
//  A4xSignal.h
//  A4xSignal
//
//  Created by mac on 2021/12/20.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, A4xSignalState) {
    kSignalStateIdle,
    kSignalStateConnecting,
    kSignalStateVerifyCerts,
    kSignalStateConnected,
    kSignalStateDisconnect,
    kSignalStateReconnecting,
    kSignalStateReleasing,
    kSignalStateClosed,
};

@class A4xSignal;
@protocol A4xSignalDelegate <NSObject>

-(void)a4xSignal:(A4xSignal*)signal didStateChanged:(A4xSignalState)state;
-(void)a4xSignal:(A4xSignal *)signal didRecvSignalMsg:(NSString*)signalEvent recvMsg:(NSString*)msg;
-(void)a4xSignal:(A4xSignal*)signal didClose:(int)closeCode;
@end

@interface A4xSignal : NSObject

@property(nonatomic, weak) id<A4xSignalDelegate> delegate;

/**
   netMode: 0:WIFI 1:AP
 */
-(void)newConnection:(NSString*)addr host:(NSString*)host
                port:(NSInteger)port urlPath:(NSString*)url
             netMode:(int)netMode;
-(NSInteger)connect;
-(int)send:(NSData*)msg isBinary:(BOOL)binary;
-(void)close;
-(void)setLogLevel:(int)level logPath:(NSString*)path;

@end
