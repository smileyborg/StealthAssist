//
//  TFPreferences.h
//  StealthAssist
//
//  Created by Tyler Fox on 12/25/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTimeToRunInBackgroundUnplugged10Seconds    10      // 10 seconds
#define kTimeToRunInBackgroundUnplugged30Minutes    1800    // 30 minutes
#define kTimeToRunInBackgroundUnpluggedNoLimit      86400   // 24 hours

@interface TFPreferences : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic) BOOL shouldShowTutorial;
@property (nonatomic) BOOL isUsingMPH;
@property (nonatomic) CGFloat autoMuteSetting;
@property (nonatomic) BOOL runsInBackground;
@property (nonatomic) NSTimeInterval timeToRunInBackgroundUnplugged;
@property (nonatomic) BOOL displayBackgroundNotifications;
@property (nonatomic) BOOL playNotificationSounds;
@property (nonatomic) BOOL turnsOffV1Display;
@property (nonatomic) BOOL showPriorityAlertFrequency;
@property (nonatomic) BOOL unmuteForBandKa;

@property (nonatomic, readonly) NSArray *appTintColors;
@property (nonatomic) UIColor *appTintColor;
@property (nonatomic) BOOL colorPerBand;
@property (nonatomic, readonly) NSArray *bandColors;
@property (nonatomic) UIColor *bandLaserColor;
@property (nonatomic) UIColor *bandKaColor;
@property (nonatomic) UIColor *bandKColor;
@property (nonatomic) UIColor *bandXColor;

- (void)restoreDefaults;

@end
