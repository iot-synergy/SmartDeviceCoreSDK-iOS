//
//  A4xAudioPitch.h
//  A4xAudioPitch
//
//  Created by mac on 2022/10/10.
//

#import <Foundation/Foundation.h>

@interface A4xAudioPitch : NSObject

-(void) setTempo:(float)tempo;
-(void) setPitchSemitones:(float)pitch;
-(void) setSpeed:(float)speed;
-(void) processFile:(NSString*)inputFile outputFile:(NSString*)outFile;
-(void) setAudioFormat:(int)sampleRate bits:(int)sampleBits chann:(int)channel;
-(int) processAudioData:(NSData*)audio;
-(NSData*) getProcessedAudio;

-(void)destroy;

@end
