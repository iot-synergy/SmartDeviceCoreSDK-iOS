
//
//  A4xNotificationManager.h
//  A4xIOSPlayer
//
//  Created by mac on 2023/10/16.
//

#import <Foundation/Foundation.h>

@interface A4xNotificationManager : NSObject

- (nullable instancetype)init;

- (void)addObserver:(nonnull id)observer
           selector:(nonnull SEL)aSelector
               name:(nullable NSString *)aName
             object:(nullable id)anObject;

- (void)removeAllObservers:(nonnull id)observer;

@end
