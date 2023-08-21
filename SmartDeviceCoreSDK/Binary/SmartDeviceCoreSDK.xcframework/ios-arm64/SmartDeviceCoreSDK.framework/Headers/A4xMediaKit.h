//
//  A4xMediaKit.h
//  A4xMediaKit
//
//  Created by mac on 2022/1/14.
//

#import <Foundation/Foundation.h>

@interface A4xMediaKit : NSObject

/**
 * ts stream convert to mp4
 */
-(void)createTsConverter:(NSString*)tsFile mp4File:(NSString*)mp4File
            videoFps:(NSInteger)vfps audioSampleRate:(NSInteger)sampleRate;

-(void)tsToMp4;
-(void)done;


/**
 *audio only support bitwidth=16bit, channels=1
 *video support avc and hevc
 */
-(void)createMp4Writer:(NSString*)mp4File
              videoFps:(NSInteger)vfps audioSampleRate:(NSInteger)sampleRate;
-(void)writeVideo:(NSMutableData*)data len:(NSInteger)length;
-(void)writePCM:(NSMutableData*)data len:(NSInteger)length;
-(void)writeAAC:(NSMutableData*)data len:(NSInteger)length;
-(void)destoryMp4Writer;

@end
