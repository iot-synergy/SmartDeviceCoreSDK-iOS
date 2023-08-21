
#import <WebRTC/RTCMacros.h>
#import <Foundation/Foundation.h>

// for iOS assembly
#ifndef A4X_RTC
#define A4X_RTC
#endif
#ifdef A4X_RTC

RTC_OBJC_EXPORT
@interface A4xGlobalAdapter : NSObject

- (void)setAudioTest: (NSString*)fileDir testOpen: (bool)bTest appVersion:(NSString*)version;

@end

#endif
