//
//  A4xObjAudioMixer.h
//  A4xObjAudioMixer
//
//  Created by mac on 2023/01/10.
//

#import <Foundation/Foundation.h>

typedef void (^LogCallbackBlocker)(NSString* log);

@interface A4xObjAudioMixer : NSObject

-(instancetype) initWithAudioFormat:(int)mixCount chann:(int)channels sampleRate:(int)sampleRate bit:(int)bits;
-(int) feedAudioSamples:(int)index audio:(NSData*)audio;
-(NSData*) getMixedAudioSamples;
-(void)destroy;
-(void)setLogLevel:(int)level log:(LogCallbackBlocker)logBlocker;

@end
