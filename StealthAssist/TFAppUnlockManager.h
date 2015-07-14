//
//  TFAppUnlockManager.h
//  StealthAssist
//
//  Created by Tyler Fox on 2/16/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kAppUnlockSucceededNotification; // posted when the app unlocks (due to successful purchase or restore)
extern NSString *kAppUnlockFailedNotification; // posted when an attempt to unlock the app fails (note - this is NOT posted when a restore completes successfully but the user never purchased the app unlock)
extern NSString *kRestorePurchasesFinishedNotification; // posted when the IAP restore completes (regardless of success/failure)

@interface TFAppUnlockManager : NSObject

+ (instancetype)sharedInstance;

// These two properties will always return opposite values
@property (nonatomic, readonly) BOOL isTrial;
@property (nonatomic, readonly) BOOL isUnlocked;

// Start the App Store purchase process
- (void)purchaseAppUnlock;

// Start the App Store purchase restore process
- (void)restoreAppUnlock;

@end
