//
//  TFPreferences.m
//  StealthAssist
//
//  Created by Tyler Fox on 12/25/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import "TFPreferences.h"

#define kDefaultShouldShowTutorial              YES
#define kDefaultIsUsingMPH                      YES
#define kDefaultAutoMuteSetting                 65.0 // in MPH
#define kDefaultRunsInBackground                YES
#define kDefaultTimeToRunInBackgroundUnplugged  kTimeToRunInBackgroundUnplugged10Seconds // in seconds
#define kDefaultDisplayBackgroundNotifications  NO
#define kDefaultPlayNotificationSounds          NO
#define kDefaultTurnsOffV1Display               NO
#define kDefaultShowPriorityAlertFrequency      NO
#define kDefaultUnmuteForBandKa                 NO

#define kDefaultAppTintColorIndex               0
#define kDefaultColorPerBand                    NO
#define kDefaultBandLaserColorIndex             0
#define kDefaultBandKaColorIndex                2
#define kDefaultBandKColorIndex                 4
#define kDefaultBandXColorIndex                 6

#define kShouldShowTutorialPreferencesKey               @"ShouldShowTutorialPreferencesKey"
#define kMPHPreferencesKey                              @"MPHPreferencesKey"
#define kAutoMutePreferencesKey                         @"AutoMutePreferencesKey"
#define kBackgroundPreferencesKey                       @"BackgroundPreferencesKey"
#define kTimeToRunInBackgroundUnpluggedPreferencesKey   @"TimeToRunInBackgroundUnpluggedPreferencesKey"
#define kDisplayBackgroundNotificationsPreferencesKey   @"DisplayBackgroundNotificationsPreferencesKey"
#define kPlayNotificationSoundsPreferencesKey           @"PlayNotificationSoundsPreferencesKey"
#define kTurnsOffV1DisplayPreferencesKey                @"TurnsOffV1DisplayPreferencesKey"
#define kShowPriorityAlertFrequencyPreferencesKey       @"ShowPriorityAlertFrequencyPreferencesKey"
#define kUnmuteForBandKaPreferencesKey                  @"UnmuteForBandKaPreferencesKey"

#define kAppTintColorIndexPreferencesKey                @"AppTintColorIndexPreferencesKey"
#define kColorPerBandPreferencesKey                     @"ColorPerBandPreferencesKey"
#define kBandLaserColorIndexPreferencesKey              @"BandLaserColorIndexPreferencesKey"
#define kBandKaColorIndexPreferencesKey                 @"BandKaColorIndexPreferencesKey"
#define kBandKColorIndexPreferencesKey                  @"BandKColorIndexPreferencesKey"
#define kBandXColorIndexPreferencesKey                  @"BandXColorIndexPreferencesKey"

@implementation TFPreferences

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)restoreDefaults
{
    self.isUsingMPH = kDefaultIsUsingMPH;
    self.runsInBackground = kDefaultRunsInBackground;
    self.timeToRunInBackgroundUnplugged = kDefaultTimeToRunInBackgroundUnplugged;
    self.displayBackgroundNotifications = kDefaultDisplayBackgroundNotifications;
    self.playNotificationSounds = kDefaultPlayNotificationSounds;
    self.turnsOffV1Display = kDefaultTurnsOffV1Display;
    self.showPriorityAlertFrequency = kDefaultShowPriorityAlertFrequency;
    self.unmuteForBandKa = kDefaultUnmuteForBandKa;
    
    // Colors
    self.appTintColorIndex = kDefaultAppTintColorIndex;
    self.colorPerBand = kDefaultColorPerBand;
    self.bandLaserColorIndex = kDefaultBandLaserColorIndex;
    self.bandKaColorIndex = kDefaultBandKaColorIndex;
    self.bandKColorIndex = kDefaultBandKColorIndex;
    self.bandXColorIndex = kDefaultBandXColorIndex;
}

#pragma mark Preferences

- (BOOL)shouldShowTutorial
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kShouldShowTutorialPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setShouldShowTutorial:kDefaultShouldShowTutorial];
    }
    return hasStoredPreference ? [storedPreference boolValue] : kDefaultShouldShowTutorial;
}

- (void)setShouldShowTutorial:(BOOL)shouldShowTutorial
{
    [[NSUserDefaults standardUserDefaults] setObject:@(shouldShowTutorial) forKey:kShouldShowTutorialPreferencesKey];
}

- (BOOL)isUsingMPH
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kMPHPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setIsUsingMPH:kDefaultIsUsingMPH];
    }
    return hasStoredPreference ? [storedPreference boolValue] : kDefaultIsUsingMPH;
}

- (void)setIsUsingMPH:(BOOL)isUsingMPH
{
    [[NSUserDefaults standardUserDefaults] setObject:@(isUsingMPH) forKey:kMPHPreferencesKey];
}

- (CGFloat)autoMuteSetting
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kAutoMutePreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setAutoMuteSetting:kDefaultAutoMuteSetting];
    }
    return hasStoredPreference ? [storedPreference floatValue] : kDefaultAutoMuteSetting;
}

- (void)setAutoMuteSetting:(CGFloat)autoMuteSetting
{
    [[NSUserDefaults standardUserDefaults] setObject:@(autoMuteSetting) forKey:kAutoMutePreferencesKey];
}

- (BOOL)runsInBackground
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kBackgroundPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setRunsInBackground:kDefaultRunsInBackground];
    }
    return hasStoredPreference ? [storedPreference boolValue] : kDefaultRunsInBackground;
}

- (void)setRunsInBackground:(BOOL)runsInBackground
{
    [[NSUserDefaults standardUserDefaults] setObject:@(runsInBackground) forKey:kBackgroundPreferencesKey];
}

- (NSTimeInterval)timeToRunInBackgroundUnplugged
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kTimeToRunInBackgroundUnpluggedPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setTimeToRunInBackgroundUnplugged:kDefaultTimeToRunInBackgroundUnplugged];
    }
    return hasStoredPreference ? [storedPreference doubleValue] : kDefaultTimeToRunInBackgroundUnplugged;
}

- (void)setTimeToRunInBackgroundUnplugged:(NSTimeInterval)timeToRunInBackgroundUnplugged
{
    [[NSUserDefaults standardUserDefaults] setObject:@(timeToRunInBackgroundUnplugged) forKey:kTimeToRunInBackgroundUnpluggedPreferencesKey];
}

- (void)registerForBackgroundNotifications
{
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:types categories:nil]];
}

- (BOOL)displayBackgroundNotifications
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kDisplayBackgroundNotificationsPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setDisplayBackgroundNotifications:kDefaultDisplayBackgroundNotifications];
    }
    BOOL displayBackgroundNotifications = hasStoredPreference ? [storedPreference boolValue] : kDefaultDisplayBackgroundNotifications;
    if (displayBackgroundNotifications) {
        // Register for background notifications if enabled here (even when just reading the property) to handle the case where the property is set to YES
        // but we still don't have permissions for some reason. (e.g. setting was enabled before updating to iOS 9 and using v1.4 of the app)
        [self registerForBackgroundNotifications];
    }
    return displayBackgroundNotifications;
}

- (void)setDisplayBackgroundNotifications:(BOOL)displayBackgroundNotifications
{
    if (displayBackgroundNotifications) {
        [self registerForBackgroundNotifications];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(displayBackgroundNotifications) forKey:kDisplayBackgroundNotificationsPreferencesKey];
}

- (BOOL)playNotificationSounds
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kPlayNotificationSoundsPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setPlayNotificationSounds:kDefaultPlayNotificationSounds];
    }
    return hasStoredPreference ? [storedPreference boolValue] : kDefaultPlayNotificationSounds;
}

- (void)setPlayNotificationSounds:(BOOL)playNotificationSounds
{
    [[NSUserDefaults standardUserDefaults] setObject:@(playNotificationSounds) forKey:kPlayNotificationSoundsPreferencesKey];
}

- (BOOL)turnsOffV1Display
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kTurnsOffV1DisplayPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setTurnsOffV1Display:kDefaultTurnsOffV1Display];
    }
    return hasStoredPreference ? [storedPreference boolValue] : kDefaultTurnsOffV1Display;
}

- (void)setTurnsOffV1Display:(BOOL)turnsOffV1Display
{
    [[NSUserDefaults standardUserDefaults] setObject:@(turnsOffV1Display) forKey:kTurnsOffV1DisplayPreferencesKey];
}

- (BOOL)showPriorityAlertFrequency
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kShowPriorityAlertFrequencyPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setShowPriorityAlertFrequency:kDefaultShowPriorityAlertFrequency];
    }
    return hasStoredPreference ? [storedPreference boolValue] : kDefaultShowPriorityAlertFrequency;
}

- (void)setShowPriorityAlertFrequency:(BOOL)showPriorityAlertFrequency
{
    [[NSUserDefaults standardUserDefaults] setObject:@(showPriorityAlertFrequency) forKey:kShowPriorityAlertFrequencyPreferencesKey];
}

- (BOOL)unmuteForBandKa
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kUnmuteForBandKaPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setUnmuteForBandKa:kDefaultUnmuteForBandKa];
    }
    return hasStoredPreference ? [storedPreference boolValue] : kDefaultUnmuteForBandKa;
}

- (void)setUnmuteForBandKa:(BOOL)unmuteForBandKa
{
    [[NSUserDefaults standardUserDefaults] setObject:@(unmuteForBandKa) forKey:kUnmuteForBandKaPreferencesKey];
}

#pragma mark Colors

NSArray<UIColor *> *GetMasterColors(void)
{
    static NSArray<UIColor *> *_masterColors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _masterColors = @[
                          [UIColor redColor],
                          [UIColor grapefruitColor],
                          [UIColor orangeColor],
                          [UIColor yellowColor],
                          [UIColor yellowGreenColor],
                          [UIColor colorWithRed:0.0f green:0.9f blue:0.0f alpha:1.0f], // Green
                          [UIColor skyBlueColor],
                          [UIColor colorWithRed:0.2f green:0.2f blue:1.0f alpha:1.0f], // Blue
                          [UIColor violetColor],
                          [UIColor fuschiaColor]
                          ];
    });
    return _masterColors;
}

- (NSArray<UIColor *> *)appTintColors
{
    return GetMasterColors();
}

- (NSUInteger)appTintColorIndex
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kAppTintColorIndexPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setAppTintColorIndex:kDefaultAppTintColorIndex];
    }
    return hasStoredPreference ? [storedPreference unsignedIntegerValue] : kDefaultAppTintColorIndex;
}

- (void)setAppTintColorIndex:(NSUInteger)appTintColorIndex
{
    NSAssert(appTintColorIndex < self.appTintColors.count, @"App tint color index out of bounds!");
    [[NSUserDefaults standardUserDefaults] setObject:@(appTintColorIndex) forKey:kAppTintColorIndexPreferencesKey];
}

- (UIColor *)appTintColor
{
    return self.appTintColors[self.appTintColorIndex];
}

- (BOOL)colorPerBand
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kColorPerBandPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setColorPerBand:kDefaultColorPerBand];
    }
    return hasStoredPreference ? [storedPreference boolValue] : kDefaultColorPerBand;
}

- (void)setColorPerBand:(BOOL)colorPerBand
{
    [[NSUserDefaults standardUserDefaults] setObject:@(colorPerBand) forKey:kColorPerBandPreferencesKey];
}

// This must have at least 4 colors, since there are 4 bands.
- (NSArray<UIColor *> *)bandColors
{
    return GetMasterColors();
}

- (NSUInteger)bandLaserColorIndex
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kBandLaserColorIndexPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setBandLaserColorIndex:kDefaultBandLaserColorIndex];
    }
    return hasStoredPreference ? [storedPreference unsignedIntegerValue] : kDefaultBandLaserColorIndex;
}

- (void)setBandLaserColorIndex:(NSUInteger)bandLaserColorIndex
{
    [[NSUserDefaults standardUserDefaults] setObject:@(bandLaserColorIndex) forKey:kBandLaserColorIndexPreferencesKey];
}

- (UIColor *)bandLaserColor
{
    return self.bandColors[self.bandLaserColorIndex];
}

- (NSUInteger)bandKaColorIndex
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kBandKaColorIndexPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setBandKaColorIndex:kDefaultBandKaColorIndex];
    }
    return hasStoredPreference ? [storedPreference unsignedIntegerValue] : kDefaultBandKaColorIndex;
}

- (void)setBandKaColorIndex:(NSUInteger)bandKaColorIndex
{
    [[NSUserDefaults standardUserDefaults] setObject:@(bandKaColorIndex) forKey:kBandKaColorIndexPreferencesKey];
}

- (UIColor *)bandKaColor
{
    return self.bandColors[self.bandKaColorIndex];
}

- (NSUInteger)bandKColorIndex
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kBandKColorIndexPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setBandKColorIndex:kDefaultBandKColorIndex];
    }
    return hasStoredPreference ? [storedPreference unsignedIntegerValue] : kDefaultBandKColorIndex;
}

- (void)setBandKColorIndex:(NSUInteger)bandKColorIndex
{
    [[NSUserDefaults standardUserDefaults] setObject:@(bandKColorIndex) forKey:kBandKColorIndexPreferencesKey];
}

- (UIColor *)bandKColor
{
    return self.bandColors[self.bandKColorIndex];
}

- (NSUInteger)bandXColorIndex
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kBandXColorIndexPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setBandXColorIndex:kDefaultBandXColorIndex];
    }
    return hasStoredPreference ? [storedPreference unsignedIntegerValue] : kDefaultBandXColorIndex;
}

- (void)setBandXColorIndex:(NSUInteger)bandXColorIndex
{
    [[NSUserDefaults standardUserDefaults] setObject:@(bandXColorIndex) forKey:kBandXColorIndexPreferencesKey];
}

- (UIColor *)bandXColor
{
    return self.bandColors[self.bandXColorIndex];
}

@end
