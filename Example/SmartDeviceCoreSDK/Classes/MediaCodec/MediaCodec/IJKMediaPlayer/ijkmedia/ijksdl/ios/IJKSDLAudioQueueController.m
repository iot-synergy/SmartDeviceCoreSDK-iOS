/*
 * IJKSDLAudioQueueController.m
 *
 * Copyright (c) 2013-2014 Bilibili
 * Copyright (c) 2013-2014 Zhang Rui <bbcallen@gmail.com>
 *
 * based on https://github.com/kolyvan/kxmovie
 *
 * This file is part of ijkPlayer.
 *
 * ijkPlayer is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * ijkPlayer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with ijkPlayer; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#import "IJKSDLAudioQueueController.h"
#import "IJKSDLAudioKit.h"
#import "ijksdl_log.h"
#import <sys/utsname.h>
#import <AVFoundation/AVFoundation.h>

#define kIJKAudioQueueNumberBuffers (3)

@implementation IJKSDLAudioQueueController {
    AudioQueueRef _audioQueueRef;
    AudioQueueBufferRef _audioQueueBufferRefArray[kIJKAudioQueueNumberBuffers];
    BOOL _isPaused;
    BOOL _isStopped;

    volatile BOOL _isAborted;
    NSLock *_lock;
}

BOOL _isECModel = NO;
BOOL _isECModel2 = NO;

- (id)initWithAudioSpec:(const SDL_AudioSpec *)aSpec
{
    self = [super init];
    if (self) {
        if (aSpec == NULL) {
            self = nil;
            return nil;
        }
        _spec = *aSpec;

        if (aSpec->format != AUDIO_S16SYS) {
            NSLog(@"aout_open_audio: unsupported format %d\n", (int)aSpec->format);
            return nil;
        }

        if (aSpec->channels > 2) {
            NSLog(@"aout_open_audio: unsupported channels %d\n", (int)aSpec->channels);
            return nil;
        }

        /* Get the current format */
        AudioStreamBasicDescription streamDescription;
        IJKSDLGetAudioStreamBasicDescriptionFromSpec(&_spec, &streamDescription);

        SDL_CalculateAudioSpec(&_spec);

        if (_spec.size == 0) {
            NSLog(@"aout_open_audio: unexcepted audio spec size %u", _spec.size);
            return nil;
        }

        /* Set the desired format */
        AudioQueueRef audioQueueRef;
        OSStatus status = AudioQueueNewOutput(&streamDescription,
                                              IJKSDLAudioQueueOuptutCallback,
                                              (__bridge void *) self,
                                              NULL,
                                              kCFRunLoopCommonModes,
                                              0,
                                              &audioQueueRef);
        if (status != noErr) {
            NSLog(@"AudioQueue: AudioQueueNewOutput failed (%d)\n", (int)status);
            self = nil;
            return nil;
        }

        UInt32 propValue = 1;
        AudioQueueSetProperty(audioQueueRef, kAudioQueueProperty_EnableTimePitch, &propValue, sizeof(propValue));
        propValue = 1;
        AudioQueueSetProperty(audioQueueRef, kAudioQueueProperty_TimePitchBypass, &propValue, sizeof(propValue));
        propValue = kAudioQueueTimePitchAlgorithm_Spectral;
        AudioQueueSetProperty(audioQueueRef, kAudioQueueProperty_TimePitchAlgorithm, &propValue, sizeof(propValue));

        status = AudioQueueStart(audioQueueRef, NULL);
        if (status != noErr) {
            NSLog(@"AudioQueue: AudioQueueStart failed (%d)\n", (int)status);
            self = nil;
            return nil;
        }

        _audioQueueRef = audioQueueRef;

        for (int i = 0;i < kIJKAudioQueueNumberBuffers; i++)
        {
            AudioQueueAllocateBuffer(audioQueueRef, _spec.size, &_audioQueueBufferRefArray[i]);
            _audioQueueBufferRefArray[i]->mAudioDataByteSize = _spec.size;
            memset(_audioQueueBufferRefArray[i]->mAudioData, 0, _spec.size);
            AudioQueueEnqueueBuffer(audioQueueRef, _audioQueueBufferRefArray[i], 0, NULL);
        }
        /*-
        status = AudioQueueStart(audioQueueRef, NULL);
        if (status != noErr) {
            NSLog(@"AudioQueue: AudioQueueStart failed (%d)\n", (int)status);
            self = nil;
            return nil;
        }
         */

        _isStopped = NO;

        _lock = [[NSLock alloc] init];

        struct utsname systemInfo;
        uname(&systemInfo);
        NSString* deviceModel = [NSString stringWithCString:systemInfo.machine
                                                          encoding:NSUTF8StringEncoding];

        char tmpBuf[30];
        const char* tmp = (const char*)tmpBuf;
        tmp = [deviceModel UTF8String];
        
        NSLog(@"iphone model %s ", tmp);
        if (
            [deviceModel isEqualToString:@"iPhone9,1"] ||     // "iPhone 7"
            [deviceModel isEqualToString:@"iPhone9,3"] ||     // "iPhone 7"
            [deviceModel isEqualToString:@"iPhone9,2"] ||     // "iPhone 7 Plus"
            [deviceModel isEqualToString:@"iPhone9,4"]        // "iPhone 7 Plus"
            ) {
            _isECModel = YES;
            NSLog(@"This is an echo cancellation adaptation model");
        } else if([deviceModel isEqualToString:@"iPhone11,6"] ) {    // "iPhone Xs Max";
            _isECModel2 = YES;
            NSLog(@"This is an echo cancellation adaptation model 2");
        }
    }
    return self;
}

- (void)dealloc
{
    [self close];
}

- (void)play
{
    if (!_audioQueueRef)
        return;

    self.spec.callback(self.spec.userdata, NULL, 0);

    @synchronized(_lock) {
        _isPaused = NO;
        NSError *error = nil;
        if (NO == [[AVAudioSession sharedInstance] setActive:YES error:&error]) {
            NSLog(@"AudioQueue: AVAudioSession.setActive(YES) failed: %@\n", error ? [error localizedDescription] : @"nil");
        }

        OSStatus status = AudioQueueStart(_audioQueueRef, NULL);
        if (status != noErr)
            NSLog(@"AudioQueue: AudioQueueStart failed (%d)\n", (int)status);
    }
}

- (void)pause
{
    if (!_audioQueueRef)
        return;

    @synchronized(_lock) {
        if (_isStopped)
            return;

        _isPaused = YES;
        OSStatus status = AudioQueuePause(_audioQueueRef);
        if (status != noErr)
            NSLog(@"AudioQueue: AudioQueuePause failed (%d)\n", (int)status);
    }
}

- (void)flush
{
    if (!_audioQueueRef)
        return;

    @synchronized(_lock) {
        if (_isStopped)
            return;

        if (_isPaused == YES) {
            for (int i = 0; i < kIJKAudioQueueNumberBuffers; i++)
            {
                if (_audioQueueBufferRefArray[i] && _audioQueueBufferRefArray[i]->mAudioData) {
                    _audioQueueBufferRefArray[i]->mAudioDataByteSize = _spec.size;
                    memset(_audioQueueBufferRefArray[i]->mAudioData, 0, _spec.size);
                }
            }
        } else {
            AudioQueueFlush(_audioQueueRef);
        }
    }
}

- (void)stop
{
    if (!_audioQueueRef)
        return;

    @synchronized(_lock) {
        if (_isStopped)
            return;

        _isStopped = YES;
    }

    // do not lock AudioQueueStop, or may be run into deadlock
    AudioQueueStop(_audioQueueRef, true);
    AudioQueueDispose(_audioQueueRef, true);
}

- (void)close
{
    [self stop];
    _audioQueueRef = nil;
}

- (void)setPlaybackRate:(float)playbackRate
{
    if (fabsf(playbackRate - 1.0f) <= 0.000001) {
        UInt32 propValue = 1;
        AudioQueueSetProperty(_audioQueueRef, kAudioQueueProperty_TimePitchBypass, &propValue, sizeof(propValue));
        AudioQueueSetParameter(_audioQueueRef, kAudioQueueParam_PlayRate, 1.0f);
    } else {
        UInt32 propValue = 0;
        AudioQueueSetProperty(_audioQueueRef, kAudioQueueProperty_TimePitchBypass, &propValue, sizeof(propValue));
        AudioQueueSetParameter(_audioQueueRef, kAudioQueueParam_PlayRate, playbackRate);
    }
}

- (void)setPlaybackVolume:(float)playbackVolume
{
    float aq_volume = playbackVolume;
    if (fabsf(aq_volume - 1.0f) <= 0.000001) {
        AudioQueueSetParameter(_audioQueueRef, kAudioQueueParam_Volume, 1.f);
    } else {
        AudioQueueSetParameter(_audioQueueRef, kAudioQueueParam_Volume, aq_volume);
    }
}

- (double)get_latency_seconds
{
    return ((double)(kIJKAudioQueueNumberBuffers)) * _spec.samples / _spec.freq;
}

static void IJKSDLAudioQueueOuptutCallback(void * inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    @autoreleasepool {
        IJKSDLAudioQueueController* aqController = (__bridge IJKSDLAudioQueueController *) inUserData;

        if (!aqController) {
            // do nothing;
        } else if (aqController->_isPaused || aqController->_isStopped) {
            memset(inBuffer->mAudioData, aqController.spec.silence, inBuffer->mAudioDataByteSize);
        } else {
            (*aqController.spec.callback)(aqController.spec.userdata, inBuffer->mAudioData, inBuffer->mAudioDataByteSize);

            if (_isECModel) {
                int16_t *data = (int16_t*)inBuffer->mAudioData;
                for(int i = 0; i < inBuffer->mAudioDataByteSize/2; i++){
                    data[i] = (int16_t)((float)data[i] * 0.1);
                }
            } else if(_isECModel2) {
                int16_t *data = (int16_t*)inBuffer->mAudioData;
                for(int i = 0; i < inBuffer->mAudioDataByteSize/2; i++){
                    data[i] = (int16_t)((float)data[i] * 0.85);
                }
            }
        }

        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}


@end
