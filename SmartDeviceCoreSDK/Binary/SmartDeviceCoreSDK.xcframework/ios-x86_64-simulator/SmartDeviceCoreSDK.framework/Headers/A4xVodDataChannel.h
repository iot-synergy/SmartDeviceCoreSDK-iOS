//
//  A4xVodDataChannel.h
//  A4xVodDataChannel
//
//  Created by mac on 2023/5/22.
//

#import <Foundation/Foundation.h>

typedef void (^CreateRtcConnectionBlock)(NSString* _Nonnull sn);
typedef int (^CreateDataChannelBlock)(NSString* _Nonnull sn, NSString* _Nonnull label);
typedef void (^CloseDataChannelByLabelBlock)(NSString* _Nonnull sn, NSString* _Nonnull label);
typedef void (^CloseDataChannelByIdBlock)(NSString* _Nonnull sn, int channelId);
typedef int (^SendDcMessageBlock)(NSString* _Nonnull sn, NSString* _Nonnull msg);
typedef NSString* (^GetDataChannelStateBlock)(NSString* _Nonnull sn, NSString* _Nonnull label);
typedef int (^GetPeerConnStateBlock)(NSString* _Nonnull sn);
typedef void (^CloseRtcConnectionBlock)(NSString* _Nonnull sn);

@interface DataChannelBlockCollection : NSObject
@property(nonatomic, nullable, copy)CreateRtcConnectionBlock createRtcConnectionBlock;
@property(nonatomic, nullable, copy)CreateDataChannelBlock createDataChannelBlock;
@property(nonatomic, nullable, copy)CloseDataChannelByLabelBlock closeDataChannelByLabelBlock;
@property(nonatomic, nullable, copy)CloseDataChannelByIdBlock closeDataChannelByIdBlock;
@property(nonatomic, nullable, copy)SendDcMessageBlock sendDcMessageBlock;
@property(nonatomic, nullable, copy)GetDataChannelStateBlock getDataChannelStateBlock;
@property(nonatomic, nullable, copy)GetPeerConnStateBlock getPeerConnStateBlock;
@property(nonatomic, nullable, copy)CloseRtcConnectionBlock closeRtcConnectionBlock;
@end

@interface A4xVodDataChannel : NSObject

@property(nonatomic, nullable, weak)DataChannelBlockCollection* dataChannelBlocks;

-(void)initDcTransfer;
-(void)setLogLevel:(int)level log:(NSString*)logFile;

-(void)setPcStateChange:(NSString*)sn state:(int)pcState;
-(void)setDcStateChange:(NSString*)sn label:(NSString*)label channelId:(int)chId state:(int)chState;
-(void)receiveTextMsg:(NSString*)sn msg:(NSString*)recvMsg;
-(void)receiveBinaryMsg:(NSString*)sn channelId:(int)chId binary:(NSData*)data;

@end
