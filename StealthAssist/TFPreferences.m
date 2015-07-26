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

#define kDefaultAppTintColor                    self.appTintColors[0]
#define kDefaultColorPerBand                    NO
#define kDefaultBandLaserColor                  self.bandColors[0]
#define kDefaultBandKaColor                     self.bandColors[2]
#define kDefaultBandKColor                      self.bandColors[4]
#define kDefaultBandXColor                      self.bandColors[6]

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

#define kAppTintColorPreferencesKey                     @"AppTintColorPreferencesKey"
#define kColorPerBandPreferencesKey                     @"ColorPerBandPreferencesKey"
#define kBandLaserColorPreferencesKey                   @"BandLaserColorPreferencesKey"
#define kBandKaColorPreferencesKey                      @"BandKaColorPreferencesKey"
#define kBandKColorPreferencesKey                       @"BandKColorPreferencesKey"
#define kBandXColorPreferencesKey                       @"BandXColorPreferencesKey"

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
    self.appTintColor = kDefaultAppTintColor;
    self.colorPerBand = kDefaultColorPerBand;
    self.bandLaserColor = kDefaultBandLaserColor;
    self.bandKaColor = kDefaultBandKaColor;
    self.bandKColor = kDefaultBandKColor;
    self.bandXColor = kDefaultBandXColor;
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

- (NSArray *)masterColors
{
    return @[
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
}

- (NSArray *)appTintColors
{
    return [self masterColors];
}

- (UIColor *)appTintColor
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kAppTintColorPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setAppTintColor:kDefaultAppTintColor];
    }
    UIColor *color = hasStoredPreference ? [NSKeyedUnarchiver unarchiveObjectWithData:storedPreference] : kDefaultAppTintColor;
    if ([self.appTintColors containsObject:color] == NO) {
        // This occurs when the stored color is not one of the options (due to the source code for the appTintColors options array changing)
        color = kDefaultAppTintColor;
    }
    return color;
}

- (void)setAppTintColor:(UIColor *)appTintColor
{
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:appTintColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:kAppTintColorPreferencesKey];
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
- (NSArray *)bandColors
{
    return [self masterColors];
}

- (UIColor *)bandLaserColor
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kBandLaserColorPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setBandLaserColor:kDefaultBandLaserColor];
    }
    UIColor *color = hasStoredPreference ? [NSKeyedUnarchiver unarchiveObjectWithData:storedPreference] : kDefaultBandLaserColor;
    if ([self.bandColors containsObject:color] == NO) {
        color = kDefaultBandLaserColor;
    }
    return color;
}

- (void)setBandLaserColor:(UIColor *)bandLaserColor
{
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:bandLaserColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:kBandLaserColorPreferencesKey];
}

- (UIColor *)bandKaColor
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kBandKaColorPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setBandKaColor:kDefaultBandKaColor];
    }
    UIColor *color = hasStoredPreference ? [NSKeyedUnarchiver unarchiveObjectWithData:storedPreference] : kDefaultBandKaColor;
    if ([self.bandColors containsObject:color] == NO) {
        color = kDefaultBandKaColor;
    }
    return color;
}

- (void)setBandKaColor:(UIColor *)bandKaColor
{
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:bandKaColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:kBandKaColorPreferencesKey];
}

- (UIColor *)bandKColor
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kBandKColorPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setBandKColor:kDefaultBandKColor];
    }
    UIColor *color = hasStoredPreference ? [NSKeyedUnarchiver unarchiveObjectWithData:storedPreference] : kDefaultBandKColor;
    if ([self.bandColors containsObject:color] == NO) {
        color = kDefaultBandKColor;
    }
    return color;
}

- (void)setBandKColor:(UIColor *)bandKColor
{
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:bandKColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:kBandKColorPreferencesKey];
}

- (UIColor *)bandXColor
{
    id storedPreference = [[NSUserDefaults standardUserDefaults] objectForKey:kBandXColorPreferencesKey];
    BOOL hasStoredPreference = storedPreference != nil;
    if (hasStoredPreference == NO) {
        [self setBandXColor:kDefaultBandXColor];
    }
    UIColor *color = hasStoredPreference ? [NSKeyedUnarchiver unarchiveObjectWithData:storedPreference] : kDefaultBandXColor;
    if ([self.bandColors containsObject:color] == NO) {
        color = kDefaultBandXColor;
    }
    return color;
}

- (void)setBandXColor:(UIColor *)bandXColor
{
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:bandXColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:kBandXColorPreferencesKey];
}

@end
