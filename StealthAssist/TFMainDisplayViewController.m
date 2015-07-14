//
//  TFMainDisplayViewController.m
//  StealthAssist
//
//  Created by Tyler Fox on 12/11/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import "TFMainDisplayViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SendRequest.h"
#import "TFPreferences.h"
#import "TFMainDisplay.h"
#import "TFAlertOverlay.h"
#import "TFSettingsViewController.h"
#import "TFHelpViewController.h"

#define MPS_TO_MPH(mps)     (mps * 2.23693629)
#define MPH_TO_KMH(mph)     (mph * 1.60934)
#define KMH_TO_MPH(kmh)     (kmh / 1.60934)

#define kAutoMuteSliderMinimumValue     0   // MPH
#define kAutoMuteSliderMaximumValue     85  // MPH
#define kAutoMuteSliderSnapIntervalMPH  5
#define kAutoMuteSliderSnapIntervalKMH  5

#define kStandbyModeFadeAnimationDuration     0.3

typedef NS_ENUM(NSInteger, TFV1State) {
    TFV1StateDisconnected = 0,
    TFV1StateShouldConnect, // will trigger auto-retry of connection if the device's bluetooth state changes
    TFV1StateConnecting,
    TFV1StateConnected
};

@interface TFMainDisplayViewController () <WSCoachMarksViewDelegate>

@property (nonatomic, assign) BOOL didSetupConstraints;

// Constraints
@property (nonatomic, strong) NSLayoutConstraint *mainDisplayConstraint1;
@property (nonatomic, strong) NSLayoutConstraint *mainDisplayConstraint2;
@property (nonatomic, strong) NSLayoutConstraint *autoMuteSliderConstraint1;
@property (nonatomic, strong) NSLayoutConstraint *autoMuteSliderConstraint2;
@property (nonatomic, strong) NSLayoutConstraint *autoMuteSliderBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *autoMuteLabelConstraint;

// Main Display
@property (nonatomic, strong) TFMainDisplay *mainDisplay;
@property (nonatomic, strong) UIView *connectionDisplay;
@property (nonatomic, strong) UILabel *connectionStatusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *connectingActivityIndicator;
@property (nonatomic, strong) UIButton *retryConnectionButton;

// User Controls
@property (nonatomic, strong) TFControlDrawer *controlDrawer;
@property (nonatomic, strong) UIView *muteButton;
@property (nonatomic, strong) UISlider *autoMuteSlider;
@property (nonatomic, strong) UILabel *autoMuteLabel;
@property (nonatomic, strong) UIView *currentSpeedBackground;
@property (nonatomic, strong) UILabel *currentSpeedLabel;
@property (nonatomic, strong) UIView *standbyOverlay;
@property (nonatomic, strong) TFAlertOverlay *purchasingUnlockOverlay; // displayed while communicating with App Store for unlock

// Device State
@property (nonatomic, assign) BOOL isBackgrounded;
@property (nonatomic, assign) UIDeviceBatteryState batteryState;
@property (nonatomic, assign) BOOL viewJustLoaded;
@property (nonatomic, assign) BOOL isShowingTutorial;
@property (nonatomic, assign) TFV1State v1State;

// V1 & App State
@property (nonatomic, assign) CGFloat autoMuteSetting; // in MPH
@property (nonatomic, assign) CGFloat currentSpeed; // in MPH
@property (nonatomic, readonly) BOOL isAutoMuted; // dynamic, whether currentSpeed < autoMuteSetting
@property (nonatomic, strong) NSTimer *startAlertDataTimer;

// Tour
@property (nonatomic, strong) UIAlertController *rotationAlert;

// Trial & Unlocking
@property (nonatomic, strong) UIAlertController *trialAlert;
@property (nonatomic, strong) NSTimer *trialDisconnectTimer; // in trial mode, this disconnects the user after they have been connected for a while

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CBCentralManager *bluetoothManager;

@end

@implementation TFMainDisplayViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.isShowingTutorial) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self disconnectV1];
    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.mainDisplay = [TFMainDisplay mainDisplay];
    [self.view addSubview:self.mainDisplay];
    
    [self loadConnectionDisplay];
    
    [self loadUIControls];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)loadConnectionDisplay
{
    self.connectionDisplay = [UIView newAutoLayoutView];
    self.connectionDisplay.backgroundColor = [UIColor blackColor];
    self.connectionDisplay.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.connectionDisplay.layer.borderWidth = 3.0f;
    self.connectionDisplay.layer.cornerRadius = 8.0f;
    [self.view addSubview:self.connectionDisplay];
    
    self.connectionStatusLabel = [UILabel newAutoLayoutView];
    self.connectionStatusLabel.textColor = [UIColor whiteColor];
    self.connectionStatusLabel.font = [UIFont fontWithName:kStealthAssistFont size:26.0f];
    self.connectionStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.connectionStatusLabel.numberOfLines = 3;
    [self.connectionDisplay addSubview:self.connectionStatusLabel];
    
    self.connectingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.connectingActivityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.connectingActivityIndicator.color = [UIColor whiteColor];
    self.connectingActivityIndicator.hidesWhenStopped = YES;
    [self.connectionDisplay addSubview:self.connectingActivityIndicator];
    
    self.retryConnectionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.retryConnectionButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.retryConnectionButton.titleLabel.font = self.connectionStatusLabel.font;
    [self.retryConnectionButton setTitle:@"Reconnect" forState:UIControlStateNormal];
    [self.retryConnectionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.retryConnectionButton addTarget:self action:@selector(wakeFromStandbyMode) forControlEvents:UIControlEventTouchUpInside];
    [self.connectionDisplay addSubview:self.retryConnectionButton];
}

- (void)loadUIControls
{
    self.muteButton = [UIView newAutoLayoutView];
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mute)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.muteButton addGestureRecognizer:singleTapGestureRecognizer];
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unmute)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.muteButton addGestureRecognizer:doubleTapGestureRecognizer];
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    [self.view addSubview:self.muteButton];
    
    self.autoMuteSlider = [UISlider newAutoLayoutView];
    self.autoMuteSlider.minimumValue = kAutoMuteSliderMinimumValue;
    self.autoMuteSlider.maximumValue = kAutoMuteSliderMaximumValue;
    [self.autoMuteSlider addTarget:self action:@selector(speedSliderChangedValue:) forControlEvents:UIControlEventAllEvents];
    [self.view addSubview:self.autoMuteSlider];
    
    self.autoMuteLabel = [UILabel newAutoLayoutView];
    self.autoMuteLabel.textColor = [UIColor whiteColor];
    CGFloat autoMuteLabelFontSize = DEVICE_HAS_TALL_SCREEN ? 28.0f : 20.0f;
    self.autoMuteLabel.font = [UIFont fontWithName:kStealthAssistFont size:autoMuteLabelFontSize];
    self.autoMuteLabel.numberOfLines = 2;
    self.autoMuteLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.autoMuteLabel];
    
    self.currentSpeedBackground = [UIView newAutoLayoutView];
    self.currentSpeedBackground.layer.cornerRadius = 8.0f;
    UITapGestureRecognizer *speedTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setAutoMuteSettingFromCurrentSpeed)];
    speedTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.currentSpeedBackground addGestureRecognizer:speedTapGestureRecognizer];
    [self.view addSubview:self.currentSpeedBackground];
    
    self.currentSpeedLabel = [UILabel newAutoLayoutView];
    self.currentSpeedLabel.font = [UIFont fontWithName:kStealthAssistFont size:42.0f];
    self.currentSpeedLabel.textColor = [UIColor whiteColor];
    self.currentSpeedLabel.numberOfLines = 2;
    self.currentSpeedLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.currentSpeedLabel];
    
    self.controlDrawer = [[TFControlDrawer alloc] initWithDelegate:self];
    [self.view addSubview:self.controlDrawer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isBackgrounded = NO;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.autoMuteSetting = [[TFPreferences sharedInstance] autoMuteSetting];
    
    self.v1State = TFV1StateDisconnected;
    self.connectionStatusLabel.text = @"Disconnected from V1";
    [self resetState];
    
#if !TARGET_IPHONE_SIMULATOR
    [self setupV1Interface];
#endif /* !TARGET_IPHONE_SIMULATOR */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateDidChange) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
    if ([TFAppUnlockManager sharedInstance].isTrial) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appUnlockSucceeded:) name:kAppUnlockSucceededNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appUnlockFailed:) name:kAppUnlockFailedNotification object:nil];
    }
    
    self.viewJustLoaded = YES;
}

- (void)setupV1Interface
{
    [[BTDiscovery sharedInstance] setV1ComDelegate:self];
    [[BTDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[BTDiscovery sharedInstance] setNotFoundDelegate:self];
    [[PacketAction sharedInstance] setDeviceInformationDelegate:self];
    [[PacketAction sharedInstance] setInfoDisplayDelegate:self];
    [[PacketAction sharedInstance] setAlertOutDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateControlDrawerFrameForOrientation:self.interfaceOrientation withOverslide:NO];
    
    [self refreshDisplay];
    
    if (self.v1State == TFV1StateConnected) {
        if ([TFPreferences sharedInstance].turnsOffV1Display) {
            [[SendRequest new] reqTurnOffMainDispay];
        } else {
            [[SendRequest new] reqTurnOnMainDispay];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[TFPreferences sharedInstance] shouldShowTutorial]) {
        [self showTutorial];
    } else if (self.viewJustLoaded) {
        [self.locationManager startUpdatingLocation];
        
#if !TARGET_IPHONE_SIMULATOR
        [self connectV1];
#endif /* !TARGET_IPHONE_SIMULATOR */
        
        self.viewJustLoaded = NO;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) != UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        // Only update the control drawer if going from portrait to landscape or vice versa;
        // no changes are required when the device changes directly from portrait to portrait upside down,
        // or landscape left to landscape right (or vice versa).
        [self updateControlDrawerFrameForOrientation:toInterfaceOrientation withOverslide:NO];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([[TFPreferences sharedInstance] shouldShowTutorial]) {
        [self showTutorial];
    }
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (!self.didSetupConstraints) {
        [self.connectionDisplay autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.mainDisplay.mainHUDBorder];
        [self.connectionDisplay autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.mainDisplay.mainHUDBorder];
        [self.connectionDisplay autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.mainDisplay.mainHUDBorder];
        [self.connectionDisplay autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.mainDisplay.mainHUDBorder];
        
        [self.connectionStatusLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow - 1 forAxis:UILayoutConstraintAxisHorizontal];
        [self.connectionStatusLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10.0f, 10.0f, 0, 10.0f) excludingEdge:ALEdgeBottom];
        
        [self.connectingActivityIndicator autoCenterInSuperview];
        [self.connectingActivityIndicator autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.connectionStatusLabel withOffset:10.0f];
        
        [self.retryConnectionButton setContentCompressionResistancePriority:UILayoutPriorityDefaultLow - 1 forAxis:UILayoutConstraintAxisHorizontal];
        [self.retryConnectionButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.connectingActivityIndicator withOffset:10.0f];
        [self.retryConnectionButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 10.0f, 10.0f, 10.0f) excludingEdge:ALEdgeTop];
        
        [self.muteButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.mainDisplay];
        [self.muteButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.mainDisplay];
        [self.muteButton autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.mainDisplay];
        [self.muteButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.mainDisplay];
        
        [self.currentSpeedBackground autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.currentSpeedLabel];
        [self.currentSpeedBackground autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.currentSpeedLabel withOffset:2.0f];
        [self.currentSpeedBackground autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.currentSpeedLabel withOffset:-10.0f];
        [self.currentSpeedBackground autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.currentSpeedLabel withOffset:10.0f];
        
        [self.currentSpeedLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.autoMuteLabel];
        [self.currentSpeedLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.autoMuteLabel];
        [self.currentSpeedLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self.autoMuteLabel];
        
        [self.autoMuteSlider autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.autoMuteLabel withOffset:10.0f];
        self.autoMuteSliderBottomConstraint = [self.autoMuteSlider autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
        
        self.didSetupConstraints = YES;
    }
    
    // Handle autorotation
    [self.mainDisplayConstraint1 autoRemove];
    [self.mainDisplayConstraint2 autoRemove];
    [self.autoMuteSliderConstraint1 autoRemove];
    [self.autoMuteSliderConstraint2 autoRemove];
    [self.autoMuteLabelConstraint autoRemove];
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.mainDisplayConstraint1 = [self.mainDisplay autoAlignAxisToSuperviewAxis:ALAxisVertical];
        self.mainDisplayConstraint2 = [self.mainDisplay autoPinToTopLayoutGuideOfViewController:self withInset:0.0f];
        
        self.autoMuteSliderConstraint1 = [self.autoMuteSlider autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15.0f];
        self.autoMuteSliderConstraint2 = [self.autoMuteSlider autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15.0f];
        
        self.autoMuteLabelConstraint = [self.autoMuteLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self.view];
        
        self.autoMuteSliderBottomConstraint.constant = -50.0f;
    } else {
        self.mainDisplayConstraint1 = [self.mainDisplay autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
        self.mainDisplayConstraint2 = [self.mainDisplay autoPinToTopLayoutGuideOfViewController:self withInset:0.0f];
        
        self.autoMuteSliderConstraint1 = [self.autoMuteSlider autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.mainDisplay withOffset:15.0f];
        self.autoMuteSliderConstraint2 = [self.autoMuteSlider autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15.0f];
        
        self.autoMuteLabelConstraint = [self.autoMuteLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self.autoMuteSlider];
        
        self.autoMuteSliderBottomConstraint.constant = -25.0f;
    }
}

- (void)showTutorial
{
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait) {
        if (!self.rotationAlert) {
            self.rotationAlert = [UIAlertController alertControllerWithTitle:@"Rotate Device" message:@"Please rotate your device upright to portrait orientation to begin the tour." preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:self.rotationAlert animated:YES completion:nil];
        }
        return;
    } else {
        [self.rotationAlert dismissViewControllerAnimated:YES completion:nil];
        self.rotationAlert = nil;
    }
    
    [self closeDrawer];
    [self disconnectV1];
    [self.locationManager stopUpdatingLocation];
    [self resetState];
    
    self.isShowingTutorial = YES;
    self.v1State = self.v1State; // triggers UI update after setting isShowingTutorial to YES
    NSArray *coachMarks = [TFAppUnlockManager sharedInstance].isTrial ? [self trialCoachMarks] : [self unlockedCoachMarks];
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
    coachMarksView.delegate = self;
    coachMarksView.maskColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
    coachMarksView.lblCaption.textColor = [UIColor blackColor];
    coachMarksView.lblCaption.font = [UIFont fontWithName:kStealthAssistFont size:20.0f];
    [self.view addSubview:coachMarksView];
    [coachMarksView start];
    [TFAnalytics trackStart:@"Tutorial: Start" withData:nil];
}

- (NSArray *)trialCoachMarks
{
    NSString *speedString = [TFPreferences sharedInstance].isUsingMPH ? @"55 MPH" : @"88 KM/H";
    return @[// 0
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.mainDisplay.frame, 0.0f, -3.0f)],
               @"caption": @"This is the main display, much like on the front of your V1."},
             // 1
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.mainDisplay.frame, 0.0f, -3.0f)],
               @"caption": @"Tap once anywhere on the main display to mute the V1. Double tap to unmute the V1."},
             // 2
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.autoMuteSlider.frame, -5.0f, -5.0f)],
               @"caption": @"This slider controls the auto mute speed setting.\nWhen driving below this speed, alerts are automatically muted."},
             // 3
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.currentSpeedBackground.frame, -25.0f, -5.0f)],
               @"caption": @"This is your current speed.\nWhen the V1 is being auto muted, the background will be colored, otherwise it will be white."},
             // 4
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.currentSpeedBackground.frame, -25.0f, -5.0f)],
               @"caption": @"Tap your current speed to quickly set it as the auto mute speed setting."},
             // 5
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.controlDrawer.toggleButtonRect, -5.0f, -10.0f)],
               @"caption": @"Tap here to open the control drawer."},
             // 6
             @{@"rect": [NSValue valueWithCGRect:CGRectMake(0.0f, CGRectGetHeight(self.view.bounds) - kTFControlDrawerHeight + kTFControlDrawerTopOverlap, self.view.bounds.size.width * 1.0f/4.0f, kTFControlDrawerHeight - kTFControlDrawerTopOverlap)],
               @"caption": @"By default, StealthAssist will run in the background and remain connected to your V1 while you use other apps, as long as your iOS device is plugged in to a power source.\nTap this icon to change settings and customize the app."},
             // 7
             @{@"rect": [NSValue valueWithCGRect:CGRectMake(self.view.bounds.size.width * 1.0f/4.0f, CGRectGetHeight(self.view.bounds) - kTFControlDrawerHeight + kTFControlDrawerTopOverlap, self.view.bounds.size.width * 1.0f/4.0f, kTFControlDrawerHeight - kTFControlDrawerTopOverlap)],
               @"caption": @"Tap this icon to enter Standby Mode.\nIn Standby Mode, StealthAssist will disconnect from the V1 and stop using your device's GPS."},
             // 8
             @{@"rect": [NSValue valueWithCGRect:CGRectMake(self.view.bounds.size.width * 1.0f/4.0f, CGRectGetHeight(self.view.bounds) - kTFControlDrawerHeight + kTFControlDrawerTopOverlap, self.view.bounds.size.width * 1.0f/4.0f, kTFControlDrawerHeight - kTFControlDrawerTopOverlap)],
               @"caption": @"If your iOS device is unplugged while StealthAssist is in the background, it will automatically enter Standby Mode after a few seconds."},
             // 9
             @{@"rect": [NSValue valueWithCGRect:CGRectMake(self.view.bounds.size.width * 3.0f/4.0f, CGRectGetHeight(self.view.bounds) - kTFControlDrawerHeight + kTFControlDrawerTopOverlap, self.view.bounds.size.width * 1.0f/4.0f, kTFControlDrawerHeight - kTFControlDrawerTopOverlap)],
               @"caption": @"You are currently using the free trial of StealthAssist. The trial mode allows you to connect to your V1 and explore all the features before unlocking the full version."},
             // 10
             @{@"rect": [NSValue valueWithCGRect:CGRectMake(self.view.bounds.size.width * 3.0f/4.0f, CGRectGetHeight(self.view.bounds) - kTFControlDrawerHeight + kTFControlDrawerTopOverlap, self.view.bounds.size.width * 1.0f/4.0f, kTFControlDrawerHeight - kTFControlDrawerTopOverlap)],
               @"caption": [NSString stringWithFormat:@"Note that in trial mode, the app will only remain connected to your V1 for up to 3 minutes, and at speeds below %@.", speedString]},
             // 11
             @{@"rect": [NSValue valueWithCGRect:CGRectMake(self.view.bounds.size.width * 3.0f/4.0f, CGRectGetHeight(self.view.bounds) - kTFControlDrawerHeight + kTFControlDrawerTopOverlap, self.view.bounds.size.width * 1.0f/4.0f, kTFControlDrawerHeight - kTFControlDrawerTopOverlap)],
               @"caption": @"Tap this icon to unlock the full version of StealthAssist and remove the trial mode limits. The full version provides unlimited access to all features."},
             // 12
             @{@"rect": [NSValue valueWithCGRect:CGRectMake(self.view.bounds.size.width * 2.0f/4.0f, CGRectGetHeight(self.view.bounds) - kTFControlDrawerHeight + kTFControlDrawerTopOverlap, self.view.bounds.size.width * 1.0f/4.0f, kTFControlDrawerHeight - kTFControlDrawerTopOverlap)],
               @"caption": @"Tap this icon to get more information about the app. You can replay this tour again at any time from here.\n\nPlease drive safely and use StealthAssist responsibly."}];
}

- (NSArray *)unlockedCoachMarks
{
    return @[// 0
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.mainDisplay.frame, 0.0f, -3.0f)],
               @"caption": @"This is the main display, much like on the front of your V1."},
             // 1
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.mainDisplay.frame, 0.0f, -3.0f)],
               @"caption": @"Tap once anywhere on the main display to mute the V1. Double tap to unmute the V1."},
             // 2
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.autoMuteSlider.frame, -5.0f, -5.0f)],
               @"caption": @"This slider controls the auto mute speed setting.\nWhen driving below this speed, alerts are automatically muted."},
             // 3
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.currentSpeedBackground.frame, -25.0f, -5.0f)],
               @"caption": @"This is your current speed.\nWhen the V1 is being auto muted, the background will be colored, otherwise it will be white."},
             // 4
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.currentSpeedBackground.frame, -25.0f, -5.0f)],
               @"caption": @"Tap your current speed to quickly set it as the auto mute speed setting."},
             // 5
             @{@"rect": [NSValue valueWithCGRect:CGRectInset(self.controlDrawer.toggleButtonRect, -5.0f, -10.0f)],
               @"caption": @"Tap here to open the control drawer."},
             // 6
             @{@"rect": [NSValue valueWithCGRect:CGRectMake(0.0f, CGRectGetHeight(self.view.bounds) - kTFControlDrawerHeight + kTFControlDrawerTopOverlap, self.view.bounds.size.width * 1.0f/3.0f, kTFControlDrawerHeight - kTFControlDrawerTopOverlap)],
               @"caption": @"By default, StealthAssist will run in the background and remain connected to your V1 while you use other apps, as long as your iOS device is plugged in to a power source.\nTap this icon to change settings and customize the app."},
             // 7
             @{@"rect": [NSValue valueWithCGRect:CGRectMake(self.view.bounds.size.width * 1.0f/3.0f, CGRectGetHeight(self.view.bounds) - kTFControlDrawerHeight + kTFControlDrawerTopOverlap, self.view.bounds.size.width * 1.0f/3.0f, kTFControlDrawerHeight - kTFControlDrawerTopOverlap)],
               @"caption": @"Tap this icon to enter Standby Mode.\nIn Standby Mode, StealthAssist will disconnect from the V1 and stop using your device's GPS."},
             // 8
             @{@"rect": [NSValue valueWithCGRect:CGRectMake(self.view.bounds.size.width * 1.0f/3.0f, CGRectGetHeight(self.view.bounds) - kTFControlDrawerHeight + kTFControlDrawerTopOverlap, self.view.bounds.size.width * 1.0f/3.0f, kTFControlDrawerHeight - kTFControlDrawerTopOverlap)],
               @"caption": @"If your iOS device is unplugged while StealthAssist is in the background, it will automatically enter Standby Mode after a few seconds."},
             // 9
             @{@"rect": [NSValue valueWithCGRect:CGRectMake(self.view.bounds.size.width * 2.0f/3.0f, CGRectGetHeight(self.view.bounds) - kTFControlDrawerHeight + kTFControlDrawerTopOverlap, self.view.bounds.size.width * 1.0f/3.0f, kTFControlDrawerHeight - kTFControlDrawerTopOverlap)],
               @"caption": @"Tap this icon to get more information about the app. You can replay this tour again at any time from here.\n\nPlease drive safely and use StealthAssist responsibly."}];
}

- (void)coachMarksView:(WSCoachMarksView *)coachMarksView willNavigateToIndex:(NSUInteger)index
{
    static NSArray *timers = nil;
    
    if (index > 1 && index != 4) {
        for (NSTimer *timer in timers) {
            [timer invalidate];
        }
        [self resetState];
    }
    
    if (index == 0) {
        self.mainDisplay.aheadArrowState = TFDisplayStateBlinking;
        self.mainDisplay.mode = TFV1ModeAllBogeys;
        timers = @[[NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(turnSideBackOnOff) userInfo:nil repeats:YES],
                   [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(changeSignalStrength) userInfo:nil repeats:YES],
                   [NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(changeBogeyCount) userInfo:nil repeats:YES],
                   [NSTimer scheduledTimerWithTimeInterval:0.55 target:self selector:@selector(blinkBandIndicators) userInfo:nil repeats:YES]];
    }
    else if (index == 2) {
        self.autoMuteSetting = 55.0;
    }
    else if (index == 3) {
        timers = @[[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(changeSpeed) userInfo:nil repeats:YES]];
    }
    else if (index == 6) {
        [self openDrawer];
    }
}

- (void)coachMarksViewWillCleanup:(WSCoachMarksView *)coachMarksView
{
    [self closeDrawer];
}

- (void)coachMarksViewDidCleanup:(WSCoachMarksView *)coachMarksView
{
    [TFAnalytics trackEnd:@"Tutorial: Start" withData:nil];
    [TFAnalytics track:@"Tutorial: End"];
    [TFPreferences sharedInstance].shouldShowTutorial = NO;
    self.isShowingTutorial = NO;
    [self wakeFromStandbyMode];
}

- (void)openDrawer
{
    if (self.controlDrawer.isDrawerOpen == NO) {
        [self toggleControlDrawer];
    }
}

- (void)closeDrawer
{
    if (self.controlDrawer.isDrawerOpen) {
        [self toggleControlDrawer];
    }
}

- (void)toggleControlDrawer
{
    if (self.controlDrawer.isDrawerToggling) {
        return;
    }
    
    self.controlDrawer.isDrawerToggling = YES;
    if (self.controlDrawer.isDrawerOpen == NO) {
        self.controlDrawer.overlayView.alpha = 0.0f;
        [self.controlDrawer.superview insertSubview:self.controlDrawer.overlayView belowSubview:self.controlDrawer];
    }
    
    [UIView animateWithDuration:kSlideAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.controlDrawer.overlayView.alpha = self.controlDrawer.isDrawerOpen ? 0.0f : 1.0f;
                         self.controlDrawer.toggleButton.imageView.layer.transform = self.controlDrawer.isDrawerOpen ? CATransform3DIdentity : CATransform3DMakeRotation(M_PI, -1.0f, 0.0f, 0.0f);
                         [self updateControlDrawerFrameForOrientation:self.interfaceOrientation withOverslide:YES];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:kOverSlideAnimationDuration
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              [self updateControlDrawerFrameForOrientation:self.interfaceOrientation withOverslide:NO];
                                          }
                                          completion:^(BOOL finished) {
                                              if (self.controlDrawer.isDrawerOpen) {
                                                  [self.controlDrawer.overlayView removeFromSuperview];
                                                  self.controlDrawer.overlayView = nil;
                                              }
                                              self.controlDrawer.isDrawerOpen = !self.controlDrawer.isDrawerOpen;
                                              self.controlDrawer.isDrawerToggling = NO;
                                          }];
                     }];
}

// This method does not provide animation; call from within an animation block to animate the transition.
- (void)updateControlDrawerFrameForOrientation:(UIInterfaceOrientation)orientation withOverslide:(BOOL)hasOverslide
{
    CGFloat overslideAmount = hasOverslide ? kDrawerOverSlide : 0.0f;
    // If an autorotation is currently in progress, we need to flip the width and height so that the frame sets correctly
    CGFloat screenWidth = (orientation == self.interfaceOrientation) ? CGRectGetWidth(self.view.bounds) : CGRectGetHeight(self.view.bounds);
    CGFloat screenHeight = (orientation == self.interfaceOrientation) ? CGRectGetHeight(self.view.bounds) : CGRectGetWidth(self.view.bounds);
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        // Portrait
        [self.controlDrawer rotateToHorizontal:NO];
        if ((self.controlDrawer.isDrawerToggling && self.controlDrawer.isDrawerOpen == NO) ||
            (self.controlDrawer.isDrawerToggling == NO && self.controlDrawer.isDrawerOpen)) {
            // Drawer open position
            self.controlDrawer.frame = CGRectMake(0.0f,
                                                  screenHeight - kTFControlDrawerHeight - overslideAmount,
                                                  screenWidth,
                                                  kTFControlDrawerHeight);
        } else {
            // Drawer closed position
            self.controlDrawer.frame = CGRectMake(0.0f,
                                                  screenHeight - kTFControlDrawerTopOverlap + overslideAmount,
                                                  screenWidth,
                                                  kTFControlDrawerHeight);
        }
    } else {
        // Landscape
        [self.controlDrawer rotateToHorizontal:YES];
        if ((self.controlDrawer.isDrawerToggling && self.controlDrawer.isDrawerOpen == NO) ||
            (self.controlDrawer.isDrawerToggling == NO && self.controlDrawer.isDrawerOpen)) {
            // Drawer open position
            self.controlDrawer.frame = CGRectMake(screenWidth - kTFControlDrawerHeight - overslideAmount,
                                                  0.0f,
                                                  kTFControlDrawerHeight,
                                                  screenHeight);
        } else {
            // Drawer closed position
            self.controlDrawer.frame = CGRectMake(screenWidth - kTFControlDrawerTopOverlap + overslideAmount,
                                                  0.0f,
                                                  kTFControlDrawerHeight,
                                                  screenHeight);
        }
    }
}

- (void)controlDrawerShowSettings
{
    [TFAnalytics track:@"Drawer: Show Settings"];
    TFSettingsViewController *settingsController = [[TFSettingsViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)controlDrawerShowHelp
{
    [TFAnalytics track:@"Drawer: Show Help"];
    TFHelpViewController *helpController = [[TFHelpViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:helpController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)controlDrawerEnterStandby
{
    [TFAnalytics track:@"Drawer: Enter Standby Mode"];
    [self enterStandbyMode];
    [self closeDrawer];
}

- (void)appDidEnterBackground
{
    NSLog(@"Application entered background.");
    self.isBackgrounded = YES;
    self.batteryState = [[UIDevice currentDevice] batteryState];
#if DEBUG && !TARGET_IPHONE_SIMULATOR
    NSAssert(self.batteryState != UIDeviceBatteryStateUnknown, @"Battery state should never be unknown.");
#endif
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enterStandbyMode) object:nil];
    if ([TFPreferences sharedInstance].runsInBackground == NO) {
        // We don't run in the background at all, enter standby mode immediately.
        [self enterStandbyMode];
    } else if (self.v1State == TFV1StateDisconnected || self.v1State == TFV1StateShouldConnect) {
        // Don't run in the background if not connected (or connecting) to the V1
        [self enterStandbyMode];
    } else if (self.batteryState == UIDeviceBatteryStateUnplugged) {
        // App was backgrounded while device is unplugged. Enter standby mode after a short delay.
        [self performSelector:@selector(enterStandbyMode) withObject:nil afterDelay:[TFPreferences sharedInstance].timeToRunInBackgroundUnplugged];
    }
}

- (void)appWillEnterForeground
{
    NSLog(@"Application entered foreground.");
    self.isBackgrounded = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enterStandbyMode) object:nil];
    [self wakeFromStandbyMode];
}

- (void)batteryStateDidChange
{
    self.batteryState = [[UIDevice currentDevice] batteryState];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enterStandbyMode) object:nil];
    if (self.batteryState == UIDeviceBatteryStateUnplugged && self.isBackgrounded) {
        // Device was unplugged while we are running in the background. Enter standby mode after a short delay.
        [self performSelector:@selector(enterStandbyMode) withObject:nil afterDelay:[TFPreferences sharedInstance].timeToRunInBackgroundUnplugged];
    }
}

- (void)wakeFromStandbyMode
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    CBPeripheral *v1 = [[BTDiscovery sharedInstance] getConnectedV1Device];
    if (!v1) {
#if !TARGET_IPHONE_SIMULATOR
        [self connectV1];
#endif /* !TARGET_IPHONE_SIMULATOR */
    }
    
    [self.locationManager startUpdatingLocation];
    
    if (self.standbyOverlay.superview) {
        [UIView animateWithDuration:kStandbyModeFadeAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.standbyOverlay.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [self.standbyOverlay removeFromSuperview];
                             self.standbyOverlay = nil;
                         }];
    }
}

- (void)enterStandbyMode
{
    [self disconnectV1];
    [self.locationManager stopUpdatingLocation];
    [self resetState];
    
    self.standbyOverlay.alpha = 0.0f;
    [self.view addSubview:self.standbyOverlay];
    [UIView animateWithDuration:kStandbyModeFadeAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.standbyOverlay.alpha = 1.0f;
                     }
                     completion:nil];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (UIView *)standbyOverlay
{
    if (!_standbyOverlay) {
        _standbyOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
        _standbyOverlay.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _standbyOverlay.backgroundColor = kOverlayColor;
        [_standbyOverlay addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wakeFromStandbyMode)]];
        
        UILabel *standbyTitleLabel = [UILabel newAutoLayoutView];
        standbyTitleLabel.textColor = [UIColor whiteColor];
        standbyTitleLabel.font = [UIFont fontWithName:kStealthAssistFont size:32.0f];
        standbyTitleLabel.text = @"Standby Mode";
        [_standbyOverlay addSubview:standbyTitleLabel];
        
        UILabel *standbyMessageLabel = [UILabel newAutoLayoutView];
        standbyMessageLabel.textColor = [UIColor whiteColor];
        standbyMessageLabel.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
        standbyMessageLabel.numberOfLines = 0;
        standbyMessageLabel.textAlignment = NSTextAlignmentCenter;
        standbyMessageLabel.text = @"StealthAssist has disconnected from your V1 and has stopped using your device's GPS.\n\nStealthAssist will not draw power in Standby Mode when you leave the app, and will resume automatically when reopened.";
        [_standbyOverlay addSubview:standbyMessageLabel];
        
        [standbyTitleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [standbyMessageLabel autoCenterInSuperview];
        [standbyMessageLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:standbyTitleLabel withOffset:15.0f];
        [standbyMessageLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:15.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [standbyMessageLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:15.0f relation:NSLayoutRelationGreaterThanOrEqual];
    }
    return _standbyOverlay;
}

- (void)setV1State:(TFV1State)v1State
{
    _v1State = v1State;
    
    if (v1State == TFV1StateConnected || self.isShowingTutorial) {
        self.connectionDisplay.hidden = YES;
        self.mainDisplay.hidden = NO;
        self.muteButton.hidden = NO;
    } else {
        self.connectionDisplay.hidden = NO;
        self.mainDisplay.hidden = YES;
        self.muteButton.hidden = YES;
    }
    
    if (v1State == TFV1StateConnecting) {
        [self.connectingActivityIndicator startAnimating];
    } else {
        [self.connectingActivityIndicator stopAnimating];
    }
    
    if (v1State == TFV1StateDisconnected) {
        self.retryConnectionButton.hidden = NO;
    } else {
        self.retryConnectionButton.hidden = YES;
    }
}

- (void)connectV1
{
    switch (self.bluetoothManager.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Connecting to V1.");
            self.v1State = TFV1StateConnecting;
            self.connectionStatusLabel.text = @"Connecting to V1";
            [[BTDiscovery sharedInstance] startScanningForUUIDString:kV1ConnectionLEServiceUUIDString];
            break;
        case CBCentralManagerStatePoweredOff:
            self.connectionStatusLabel.text = @"Bluetooth Powered Off";
            self.v1State = TFV1StateShouldConnect;
            break;
        case CBCentralManagerStateUnauthorized:
            [TFAnalytics track:@"Error: Bluetooth Unauthorized"];
            self.connectionStatusLabel.text = @"Bluetooth Unauthorized";
            self.v1State = TFV1StateShouldConnect;
            break;
        case CBCentralManagerStateResetting:
            [TFAnalytics track:@"Error: Bluetooth Resetting"];
            self.connectionStatusLabel.text = @"Bluetooth Resetting";
            self.v1State = TFV1StateShouldConnect;
            break;
        case CBCentralManagerStateUnsupported:
            [TFAnalytics track:@"Error: Bluetooth Unsupported"];
            self.connectionStatusLabel.text = @"Bluetooth LE Unsupported";
            self.v1State = TFV1StateShouldConnect;
            break;
        case CBCentralManagerStateUnknown:
            if (self.v1State == TFV1StateShouldConnect) {
                // We've already been through this method at least once, and we're still in the unknown state, so now display the alert
                [TFAnalytics track:@"Error: Bluetooth State Unknown"];
                self.connectionStatusLabel.text = @"Bluetooth State Unknown";
            }
            self.v1State = TFV1StateShouldConnect;
            break;
        default:
            break;
    }
}

- (void)disconnectV1
{
    [self.startAlertDataTimer invalidate];
    self.startAlertDataTimer = nil;
    
    if (self.v1State != TFV1StateConnected) {
        // Since we aren't connected, make sure to explicitly set the state to disconnected since we aren't going to get any callbacks
        // upon disconnection (discoveryDisconnected:)
        self.v1State = TFV1StateDisconnected;
        self.connectionStatusLabel.text = @"Disconnected from V1";
    }
#if !TARGET_IPHONE_SIMULATOR
    [[BTDiscovery sharedInstance] stopScanning];
    CBPeripheral *v1 = [[BTDiscovery sharedInstance] getConnectedV1Device];
    if (v1) {
        NSLog(@"Disconnecting from V1.");
        [[BTDiscovery sharedInstance] disconnectPeripheral:v1];
    }
#endif /* !TARGET_IPHONE_SIMULATOR */
}

// Called from either of the below trial disconnection methods to handle the disconnection
- (void)trialDisconnect
{
    [self.trialDisconnectTimer invalidate];
    self.trialDisconnectTimer = nil;
    
    [self disconnectV1];
}

// Called when the trial disconnect timer fires (to enforce the time limit on app usage in trial mode)
- (void)trialDisconnectV1TimeLimit
{
    if (self.v1State != TFV1StateConnected) {
        [self trialDisconnect];
        return;
    }
    
    [self trialDisconnect];
    
    [TFAnalytics track:@"Trial: Time Limit Reached"];
    [self displayTrialAlertWithMessage:@"The trial mode 3 minute connection limit has been reached. Please unlock the full version of the app to remove this limit."];
}

// Called when the user exceeds the trial mode speed limit
- (void)trialDisconnectV1SpeedLimit
{
    if (self.v1State != TFV1StateConnected) {
        [self trialDisconnect];
        return;
    }
    
    [self trialDisconnect];
    
    [TFAnalytics track:@"Trial: Speed Limit Reached"];
    NSString *speedString = [TFPreferences sharedInstance].isUsingMPH ? @"55 MPH" : @"88 KM/H";
    [self displayTrialAlertWithMessage:[NSString stringWithFormat:@"The trial mode %@ speed limit has been reached. Please unlock the full version of the app to remove this limit.", speedString]];
}

- (void)startAlertData
{
    if (self.v1State == TFV1StateConnected) {
        NSLog(@"Starting alert data.");
        [[SendRequest new] reqStartAlertData];
    } else {
        [self.startAlertDataTimer invalidate];
        self.startAlertDataTimer = nil;
    }
}

- (void)resetState
{
    self.currentSpeed = 0.0f;
    self.mainDisplay.mode = TFV1ModeUnknown;
    self.mainDisplay.bogeyCount = 0;
    self.mainDisplay.signalStrength = 0.0f;
    self.mainDisplay.aheadArrowState = TFDisplayStateOff;
    self.mainDisplay.sideArrowState = TFDisplayStateOff;
    self.mainDisplay.behindArrowState = TFDisplayStateOff;
    self.mainDisplay.laserState = TFDisplayStateOff;
    self.mainDisplay.kaState = TFDisplayStateOff;
    self.mainDisplay.kState = TFDisplayStateOff;
    self.mainDisplay.xState = TFDisplayStateOff;
}

// Update any visible parts of the UI that may have changed due to preferences changes, etc.
- (void)refreshDisplay
{
    self.currentSpeed = self.currentSpeed; // will trigger the label to update with correct units
    [self updateAutoMuteSliderThumbImage];
}

- (void)setCurrentSpeed:(CGFloat)currentSpeed
{
    BOOL wasAutoMuted = self.isAutoMuted;
    
    currentSpeed = MAX(currentSpeed, 0);
    _currentSpeed = currentSpeed;
    
    if (wasAutoMuted && self.isAutoMuted == NO) {
        [self unmuteV1];
    } else if (wasAutoMuted == NO && self.isAutoMuted) {
        [self muteV1];
    }
    
    [self updateCurrentSpeedLabelAppearance];
    
    // Update the text of the current speed label
    NSString *mphString = @"MPH";
    NSString *kmhString = @"KM/H";
    NSString *currentSpeedString;
    if ([[TFPreferences sharedInstance] isUsingMPH]) {
        currentSpeedString = [NSString stringWithFormat:@"%ld\n%@", (long)round(self.currentSpeed), mphString];
    } else {
        currentSpeedString = [NSString stringWithFormat:@"%ld\n%@", (long)round(MPH_TO_KMH(self.currentSpeed)), kmhString];
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:currentSpeedString];
    NSRange range = [currentSpeedString rangeOfString:([[TFPreferences sharedInstance] isUsingMPH] ? mphString : kmhString)];
    [attributedString setAttributes:@{NSFontAttributeName: [UIFont fontWithName:kStealthAssistFont size:self.currentSpeedLabel.font.pointSize * 0.4f]} range:range];
    self.currentSpeedLabel.attributedText = attributedString;
    
    if ([TFAppUnlockManager sharedInstance].isTrial && self.v1State == TFV1StateConnected && currentSpeed > 55.0f) {
        // Exceeded the trial mode speed limit
        [self trialDisconnectV1SpeedLimit];
    }
}

- (void)updateCurrentSpeedLabelAppearance
{
    BOOL isAutoMutedDueToSpeed = (self.currentSpeed < self.autoMuteSetting); // separate this out from other factors impacting auto mute, e.g. Ka alert detected
    self.currentSpeedLabel.textColor = isAutoMutedDueToSpeed ? [kAppTintColorDarker blackOrWhiteContrastingColor] : [UIColor blackColor];
    self.currentSpeedBackground.backgroundColor = isAutoMutedDueToSpeed ? kAppTintColorDarker : [UIColor whiteColor];
}

- (void)setAutoMuteSetting:(CGFloat)autoMuteSetting
{
    BOOL wasAutoMuted = self.isAutoMuted;
    
    _autoMuteSetting = autoMuteSetting;
    
    if (wasAutoMuted && self.isAutoMuted == NO) {
        [self unmuteV1];
    } else if (wasAutoMuted == NO && self.isAutoMuted) {
        [self muteV1];
    }
    
    [[TFPreferences sharedInstance] setAutoMuteSetting:autoMuteSetting];
    
    self.autoMuteSlider.value = autoMuteSetting;
    
    [self updateAutoMuteSliderThumbImage];
    
    if (autoMuteSetting == 0.0) {
        self.autoMuteLabel.text = @"Auto Mute\nDisabled";
    } else {
        if ([[TFPreferences sharedInstance] isUsingMPH]) {
            self.autoMuteLabel.text = [NSString stringWithFormat:@"Auto Mute Under\n%ld MPH", (long)round(autoMuteSetting)];
        } else {
            self.autoMuteLabel.text = [NSString stringWithFormat:@"Auto Mute Under\n%ld KM/H", (long)round(MPH_TO_KMH(autoMuteSetting))];
        }
    }
    
    [self updateCurrentSpeedLabelAppearance];
    
    self.currentSpeedLabel.alpha = 0.0f;
    self.currentSpeedBackground.alpha = 0.0f;
    self.autoMuteLabel.alpha = 1.0f;
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.autoMuteLabel.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [UIView animateWithDuration:0.5
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  self.currentSpeedLabel.alpha = 1.0f;
                                                  self.currentSpeedBackground.alpha = 1.0f;
                                              }
                                              completion:nil];
                         }
                     }];
}

- (void)updateAutoMuteSliderThumbImage
{
    NSString *text;
    if (self.autoMuteSetting > 0) {
        NSInteger autoMuteSetting;
        if ([[TFPreferences sharedInstance] isUsingMPH]) {
            autoMuteSetting = round(self.autoMuteSetting);
        } else {
            autoMuteSetting = round(MPH_TO_KMH(self.autoMuteSetting));
        }
        text = [NSString stringWithFormat:@"%ld", (long)autoMuteSetting];
    } else {
        text = @"Off";
    }
    
    static const CGFloat thumbDiameter = 38.0f;
    CGSize thumbSize = CGSizeMake(thumbDiameter, thumbDiameter);
    UIGraphicsBeginImageContextWithOptions(thumbSize, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0.0f, 0.0f, thumbSize.width, thumbSize.height);
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, CGColorGetComponents([UIColor whiteColor].CGColor));
    CGContextFillPath(ctx);
    NSDictionary *textAttributes = @{NSFontAttributeName: [UIFont fontWithName:kStealthAssistFont size:20.0f], NSForegroundColorAttributeName : [UIColor blackColor]};
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    CGPoint startPoint = CGPointMake(thumbSize.width / 2.0f - textSize.width / 2.0f, thumbSize.height / 2.0f - textSize.height / 2.0f);
    [text drawAtPoint:startPoint withAttributes:textAttributes];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.autoMuteSlider setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (BOOL)isAutoMuted
{
    if (self.mainDisplay.priorityAlertFrequency >= kBandKaFrequencyLowerEnd &&
        self.mainDisplay.priorityAlertFrequency <= kBandKaFrequencyUpperEnd &&
        [TFPreferences sharedInstance].unmuteForBandKa) {
        return NO;
    }
    
    if (self.currentSpeed >= self.autoMuteSetting) {
        return NO;
    }
    
    return YES;
}

- (void)speedSliderChangedValue:(UISlider *)slider
{
    BOOL isUsingMPH = [TFPreferences sharedInstance].isUsingMPH;
    
    CGFloat sliderValueMPH = slider.value;
    
    NSInteger snapInterval = isUsingMPH ? kAutoMuteSliderSnapIntervalMPH : kAutoMuteSliderSnapIntervalKMH;
    
    // Snap the slider to the interval above
    CGFloat snapValueMPH;
    if (isUsingMPH) {
        snapValueMPH = round(sliderValueMPH / snapInterval) * snapInterval;
    } else {
        snapValueMPH = KMH_TO_MPH(round(MPH_TO_KMH(sliderValueMPH) / snapInterval) * snapInterval);
    }
    
    // Discard the first MPH interval so there is a bigger gap between 0 (off) and the first valid speed setting.
    self.autoMuteSetting = (snapValueMPH < kAutoMuteSliderSnapIntervalMPH * 2) ? 0 : snapValueMPH;
}

- (void)setAutoMuteSettingFromCurrentSpeed
{
    self.autoMuteSetting = round(self.currentSpeed);
    self.autoMuteSlider.value = self.autoMuteSetting;
    [TFAnalytics track:@"Main Display: Auto Mute Set From Current Speed"];
}

- (void)mute
{
    [self muteV1];
    TFAlertOverlay *alertOverlay = [TFAlertOverlay alertOverlayWithSize:CGSizeMake(180.0f, 120.0f) title:@"V1 Muted"];
    [alertOverlay displayForDuration:0.2];
    [TFAnalytics track:@"Main Display: Tapped to Mute"];
}

- (void)unmute
{
    [self unmuteV1];
    TFAlertOverlay *alertOverlay = [TFAlertOverlay alertOverlayWithSize:CGSizeMake(180.0f, 120.0f) title:@"V1 Unmuted"];
    [alertOverlay displayForDuration:0.2];
    [TFAnalytics track:@"Main Display: Tapped to Unmute"];
}

- (void)muteV1
{
    if (self.v1State == TFV1StateConnected) {
        [[SendRequest new] reqMuteOn];
    }
}

- (void)unmuteV1
{
    if (self.v1State == TFV1StateConnected) {
        [[SendRequest new] reqMuteOff];
    }
}

- (void)displayLocalNotificationForBogeyBand:(TFBand)band direction:(TFDirection)direction frequency:(NSInteger)frequency
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSString *bandIcon = @"";
    NSString *bandString = @"";
    NSString *soundName = nil;
    switch (band) {
        case TFBandKa:
            bandIcon = @"‼️";
            bandString = @"Ka";
            soundName = @"bogeylock-ka.aif";
            break;
        case TFBandK:
            bandIcon = @"❗️";
            bandString = @"K";
            soundName = @"bogeylock-k.aif";
            break;
        case TFBandX:
            bandIcon = @"❕";
            bandString = @"X";
            soundName = @"bogeylock-x.aif";
            break;
        default:
            NSAssert(nil, @"Unsupported band!");
            break;
    }
    NSString *directionIcon = @"";
    NSString *directionString = @"";
    switch (direction) {
        case TFDirectionAhead:
            directionIcon = @"▲";
            directionString = @"Ahead";
            break;
        case TFDirectionSide:
            directionIcon = @"↔️";
            directionString = @"Side";
            break;
        case TFDirectionBehind:
            directionIcon = @"▼";
            directionString = @"Behind";
            break;
        default:
            NSAssert(nil, @"Unsupported direction!");
            break;
    }
    if ([TFPreferences sharedInstance].showPriorityAlertFrequency) {
        NSString *frequencyString = [NSString stringWithFormat:@"%.3f GHz", frequency / 1000.0f];
        notification.alertBody = [NSString stringWithFormat:@"%@%@%@ %@, %@", directionIcon, bandIcon, bandString, directionString, frequencyString];
    } else {
        notification.alertBody = [NSString stringWithFormat:@"%@%@%@ %@", directionIcon, bandIcon, bandString, directionString];
    }
    if ([TFPreferences sharedInstance].playNotificationSounds) {
        notification.soundName = soundName;
    }
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)playSoundForBogeyBand:(TFBand)band
{
    static SystemSoundID soundIDKa;
    static SystemSoundID soundIDK;
    static SystemSoundID soundIDX;
    
    switch (band) {
        case TFBandKa:
            if (!soundIDKa) {
                NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"bogeylock-ka" withExtension:@"aif"];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundIDKa);
            }
            AudioServicesPlayAlertSound(soundIDKa);
            break;
        case TFBandK:
            if (!soundIDK) {
                NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"bogeylock-k" withExtension:@"aif"];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundIDK);
            }
            AudioServicesPlayAlertSound(soundIDK);
            break;
        case TFBandX:
            if (!soundIDX) {
                NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"bogeylock-x" withExtension:@"aif"];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundIDX);
            }
            AudioServicesPlayAlertSound(soundIDX);
            break;
        default:
            NSAssert(nil, @"Unsupported band!");
            break;
    }
    
    // Since we keep the sound IDs around once loaded for the lifetime of the app, there's no need to dispose of them.
    // Note that if you call the below line before the sound finishes playing, the sound will not play!
    // AudioServicesDisposeSystemSoundID(soundID);
}

#pragma mark App Unlock

- (void)controlDrawerUnlockApp
{
    [TFAnalytics track:@"Drawer: Unlock App"];
    [self purchaseAppUnlock];
}

- (void)purchaseAppUnlock
{
    self.purchasingUnlockOverlay = [TFAlertOverlay alertOverlayWithSize:CGSizeMake(250.0f, 150.0f) title:@"Unlocking App"];
    self.purchasingUnlockOverlay.displayActivityIndicator = YES;
    [self.purchasingUnlockOverlay display];
    [[TFAppUnlockManager sharedInstance] purchaseAppUnlock];
}

- (void)appUnlockSucceeded:(NSNotification *)notification
{
    NSAssert([TFAppUnlockManager sharedInstance].isUnlocked, @"App unlock successful notification received, but app is not unlocked!");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppUnlockSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppUnlockFailedNotification object:nil];
    
    [self.purchasingUnlockOverlay dismiss];
    self.purchasingUnlockOverlay = nil;
    
    // Close the control drawer, then once the animation completes, reload it so that the unlock button is removed
    [self closeDrawer];
    double delayInSeconds = kSlideAnimationDuration + kOverSlideAnimationDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.controlDrawer removeFromSuperview];
        self.controlDrawer = [[TFControlDrawer alloc] initWithDelegate:self];
        [self.view addSubview:self.controlDrawer];
        [self updateControlDrawerFrameForOrientation:self.interfaceOrientation withOverslide:NO];
    });
}

- (void)appUnlockFailed:(NSNotification *)notification
{
    [self.purchasingUnlockOverlay dismiss];
    self.purchasingUnlockOverlay = nil;
}

- (void)displayTrialAlertWithMessage:(NSString *)message
{
    if (!self.trialAlert && !self.purchasingUnlockOverlay) {
        self.trialAlert = [UIAlertController alertControllerWithTitle:@"Trial Mode Limit Reached" message:message preferredStyle:UIAlertControllerStyleAlert];
        typeof(self) __weak weakSelf = self;
        [self.trialAlert addAction:[UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [TFAnalytics track:@"Trial: Alert Unlock Later"];
            weakSelf.trialAlert = nil;
        }]];
        [self.trialAlert addAction:[UIAlertAction actionWithTitle:@"Unlock App" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [TFAnalytics track:@"Trial: Alert Unlock App"];
            [weakSelf purchaseAppUnlock];
            weakSelf.trialAlert = nil;
        }]];
        [self presentViewController:self.trialAlert animated:YES completion:nil];
    }
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    if (location.speed >= 0.0) {
        self.currentSpeed = MPS_TO_MPH(location.speed);
    } else {
        self.currentSpeed = 0.0f;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        // TODO: handle this error
//        TFAlertOverlay *errorAlert = [TFAlertOverlay alertOverlayWithSize:CGSizeMake(240.0f, 240.0f) title:@"Location Services Disabled"];
//        [errorAlert displayForDuration:3.0];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // TODO: handle denied, restricted (also see above delegate method)
}

#pragma mark CBCentralManagerDelegate methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (self.v1State == TFV1StateShouldConnect) {
        [self connectV1];
    }
}

#pragma mark BTDiscoveryDelegate methods

- (void)discoveryConnected:(CBPeripheral *)per
{
    NSLog(@"Bluetooth device connected.");
}

- (void)discoveryDisconnected
{
    NSLog(@"Bluetooth device disconnected.");
    
    if (self.isBackgrounded && [TFPreferences sharedInstance].displayBackgroundNotifications && self.v1State == TFV1StateConnected) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"Disconnected from V1.";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
    
    self.v1State = TFV1StateDisconnected;
    if (self.isBackgrounded) {
        [self enterStandbyMode];
    }
    self.connectionStatusLabel.text = @"Disconnected from V1";
}

- (void)discoveryStatePoweredOff
{
    NSLog(@"Bluetooth powered off.");
    
    self.v1State = TFV1StateShouldConnect;
    if (self.isBackgrounded) {
        [self enterStandbyMode];
    }
    self.connectionStatusLabel.text = @"Bluetooth Powered Off";
}

- (void)multipleUnknownDevicesFound:(NSString *)suggestedErrorMessage
{
    UIAlertController *alert = [TFAlertView alertWithTitle:@"Error"
                                                   message:suggestedErrorMessage
                                         cancelButtonTitle:@"OK"];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)btleUnsupported:(NSString *)suggestedErrorMessage
{
    UIAlertController *alert = [TFAlertView alertWithTitle:@"Error"
                                                   message:suggestedErrorMessage
                                         cancelButtonTitle:@"OK"];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark BTDeviceNotFoundProtocol methods

- (void)deviceNotFound
{
    NSLog(@"No bluetooth device found.");
    
    // If we encountered another error already (such as bluetooth being turned off), the v1State will be something other
    // than TFV1StateConnecting, and we don't want to update the status label since it will have already been updated elsewhere.
    if (self.v1State == TFV1StateConnecting) {
        self.v1State = TFV1StateDisconnected;
        self.connectionStatusLabel.text = @"V1connection LE Bluetooth Module Not Found";
        if (self.isBackgrounded && [TFPreferences sharedInstance].displayBackgroundNotifications) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = @"V1connection LE Bluetooth module not found.";
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
    }
}

#pragma mark V1ComProtocol methods

- (void)didConnectToDevice
{
    NSLog(@"Connected to V1.");
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enterStandbyMode) object:nil];
    
    [[BTDiscovery sharedInstance] stopScanning];
    
    // Delay a short amount of time before considering status as "connected" and sending the first packet
    // to request alert data from the V1, as even when this delegate method gets called the V1 is still
    // not quite ready to receive packets and will complain about being sent a packet before it's ready.
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.v1State != TFV1StateConnecting) {
            // This can happen if the user taps into Standby Mode while connecting but before connection finishes
            [self disconnectV1];
            return;
        }
        
        self.v1State = TFV1StateConnected;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enterStandbyMode) object:nil];
        
        if (self.isBackgrounded && [TFPreferences sharedInstance].displayBackgroundNotifications) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.alertBody = @"Connected to V1.";
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
        
        // To make sure the below startAlertData packet goes through, we setup the below timer which gets invalidated as soon as we get the first callback
        // to the didRecieveAlertTable: delegate method (meaning we're receiving alert data).
        [self.startAlertDataTimer invalidate];
        self.startAlertDataTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(startAlertData) userInfo:nil repeats:YES];
        [self startAlertData];
        
        // Now that we're connected, send some commands to the V1 so it reflects the current state of the app
        if ([TFPreferences sharedInstance].turnsOffV1Display) {
            [[SendRequest new] reqTurnOffMainDispay];
        } else {
            [[SendRequest new] reqTurnOnMainDispay];
        }
        
        if (self.isAutoMuted) {
            [self muteV1];
        } else {
            [self unmuteV1];
        }
        
        if ([TFAppUnlockManager sharedInstance].isTrial) {
            // Disconnect from the V1 after 3 minutes (180 sec) to enforce trial mode. (DEV NOTE: be sure to update tutorial text if changing this duration!)
            self.trialDisconnectTimer = [NSTimer scheduledTimerWithTimeInterval:180.0 target:self selector:@selector(trialDisconnectV1TimeLimit) userInfo:nil repeats:NO];
        }
    });
}

#pragma mark InfoDisplayProtocol methods

- (TFDisplayState)displayStateFromV1DispState:(dispState)dispState
{
    switch (dispState) {
        case off:
            return TFDisplayStateOff;
            break;
        case on:
            return TFDisplayStateOn;
            break;
        case blinking:
            return TFDisplayStateBlinking;
            break;
        default:
            return TFDisplayStateOff;
            break;
    }
}

- (void)didRecieveDisplayData:(DisplayData *)displayData
{
    if (displayData) {
        [self parseModeFromDisplayData:displayData];
        self.mainDisplay.aheadArrowState = [self displayStateFromV1DispState:[displayData Front]];
        self.mainDisplay.sideArrowState = [self displayStateFromV1DispState:[displayData Side]];
        self.mainDisplay.behindArrowState = [self displayStateFromV1DispState:[displayData Rear]];
        self.mainDisplay.laserState = [self displayStateFromV1DispState:[displayData Laser]];
        self.mainDisplay.kaState = [self displayStateFromV1DispState:[displayData Ka]];
        self.mainDisplay.kState = [self displayStateFromV1DispState:[displayData K]];
        self.mainDisplay.xState = [self displayStateFromV1DispState:[displayData X]];
    }
}

- (void)parseModeFromDisplayData:(DisplayData *)displayData
{
    if ([displayData SegmentA] == on &&
        [displayData SegmentB] == on &&
        [displayData SegmentC] == on &&
        [displayData SegmentD] == off &&
        [displayData SegmentE] == on &&
        [displayData SegmentF] == on &&
        [displayData SegmentG] == on) {
        // Big "A"
        self.mainDisplay.mode = TFV1ModeAllBogeys;
    }
    else if ([displayData SegmentA] == off &&
             [displayData SegmentB] == off &&
             [displayData SegmentC] == off &&
             [displayData SegmentD] == on &&
             [displayData SegmentE] == on &&
             [displayData SegmentF] == off &&
             [displayData SegmentG] == off) {
        // Small "L"
        self.mainDisplay.mode = TFV1ModeLogic;
    }
    else if ([displayData SegmentA] == off &&
             [displayData SegmentB] == off &&
             [displayData SegmentC] == off &&
             [displayData SegmentD] == on &&
             [displayData SegmentE] == on &&
             [displayData SegmentF] == on &&
             [displayData SegmentG] == off) {
        // Big "L"
        self.mainDisplay.mode = TFV1ModeAdvancedLogic;
    }
    else if ([displayData SegmentA] == on &&
             [displayData SegmentB] == off &&
             [displayData SegmentC] == off &&
             [displayData SegmentD] == on &&
             [displayData SegmentE] == on &&
             [displayData SegmentF] == on &&
             [displayData SegmentG] == off) {
        // Big "C"
        self.mainDisplay.mode = TFV1ModeKKaCustomSweeps;
	}
	else if ([displayData SegmentA] == off &&
             [displayData SegmentB] == off &&
             [displayData SegmentC] == off &&
             [displayData SegmentD] == on &&
             [displayData SegmentE] == on &&
             [displayData SegmentF] == off &&
             [displayData SegmentG] == on) {
        // Little "C"
        self.mainDisplay.mode = TFV1ModeKaCustomSweeps;
	}
	else if ([displayData SegmentA] == off &&
             [displayData SegmentB] == on &&
             [displayData SegmentC] == on &&
             [displayData SegmentD] == on &&
             [displayData SegmentE] == on &&
             [displayData SegmentF] == on &&
             [displayData SegmentG] == off) {
        // Big "U"
        self.mainDisplay.mode = TFV1ModeKKaPhoto;
	}
	else if ([displayData SegmentA] == off &&
             [displayData SegmentB] == off &&
             [displayData SegmentC] == on &&
             [displayData SegmentD] == on &&
             [displayData SegmentE] == on &&
             [displayData SegmentF] == off &&
             [displayData SegmentG] == off) {
        // Little "U"
        self.mainDisplay.mode = TFV1ModeKaPhoto;
	}
}

#pragma mark AlertOutProtocol methods

- (void)didRecieveAlertTable:(AlertCollection *)collection
{
    // Sometimes the V1 stops sending alert data, even though it remains connected - such as when the V1 power cycles as the car
    // ignition turns on. If this happens, the below timer will restart alert data automatically.
    [self.startAlertDataTimer invalidate];
    self.startAlertDataTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(startAlertData) userInfo:nil repeats:YES];
    
    NSInteger oldBogeyCount = self.mainDisplay.bogeyCount;
    BOOL wasAutoMuted = self.isAutoMuted; // used to determine if a change in priority frequency affects auto mute state
    
    TFBand priorityAlertBand = TFBandNone;
    TFDirection priorityAlertDirection = TFDirectionUnknown;
    if (collection) {
        self.mainDisplay.bogeyCount = [collection totalAlerts];
        AlertData *priorityAlert = [collection getPriorityAlert];
        self.mainDisplay.signalStrength = [priorityAlert getNormalizedSignalStregth] / 8.0f;
        self.mainDisplay.priorityAlertFrequency = [priorityAlert getFrequency];
        // [priorityAlert isNew] does not appear to work; it always returns NO
        switch ([priorityAlert getBand]) {
            case ka:
                priorityAlertBand = TFBandKa;
                break;
            case k:
                priorityAlertBand = TFBandK;
                break;
            case x:
                priorityAlertBand = TFBandX;
                break;
            default:
                break;
        }
        switch ([priorityAlert getDirection]) {
            case front:
                priorityAlertDirection = TFDirectionAhead;
                break;
            case side:
                priorityAlertDirection = TFDirectionSide;
                break;
            case rear:
                priorityAlertDirection = TFDirectionBehind;
                break;
            default:
                break;
        }
    }
    
    BOOL didDetectFirstBogey = (oldBogeyCount == 0 && self.mainDisplay.bogeyCount > 0);
    
    if (didDetectFirstBogey && priorityAlertBand != TFBandNone && priorityAlertDirection != TFDirectionUnknown) {
        if (self.isBackgrounded) {
            // Display a local notification for this alert when the app is backgrounded, and this is the first bogey, and the priority alert has a valid band & direction
            if ([TFPreferences sharedInstance].displayBackgroundNotifications) {
                [self displayLocalNotificationForBogeyBand:priorityAlertBand direction:priorityAlertDirection frequency:self.mainDisplay.priorityAlertFrequency];
            }
        } else {
            // Play a sound for this alert when the app is foregrounded, and this is the first bogey, and the priority alert has a valid band & direction
            if ([TFPreferences sharedInstance].playNotificationSounds) {
                [self playSoundForBogeyBand:priorityAlertBand];
            }
        }
    }
    
    if (didDetectFirstBogey) {
        // When there are 0 bogeys the V1 reverts to full volume after ~10 seconds, even if previously muted.
        // This ensures that we'll send the appropriate mute/unmute command to the V1 every time the first
        // bogey is identified, so that the V1 is in the correct state.
        if (self.isAutoMuted) {
            [self muteV1];
        } else {
            [self unmuteV1];
        }
    } else if (wasAutoMuted && self.isAutoMuted == NO) {
        // We also need to see if a change in priority alert frequency means we need to mute or unmute the V1.
        // This check or the below one will only be true if there was a change in the priority alert frequency AND the user
        // has the "Always Unmute Ka Priority Alerts" setting ON. Otherwise, these conditions will both always be false.
        [self unmuteV1]; // we just started detecting Ka, so unmute the V1
    } else if (wasAutoMuted == NO && self.isAutoMuted) {
        // The comment in the above branch applies here as well.
        [self muteV1]; // we were previously detecting Ka, but now we are not, so mute the V1
    }
}

#pragma mark DEMO methods

// DEMO method - displays frequencies in the bottom HUD
- (void)displayFrequency
{
    static NSUInteger counter = 1;
    
    if (counter % 7 == 0) {
        self.mainDisplay.priorityAlertFrequency = 34774;
    }
    
    if (counter % 5 == 0) {
        self.mainDisplay.priorityAlertFrequency = 25318;
    }
    
    if (counter % 3 == 0) {
        self.mainDisplay.priorityAlertFrequency = 11000;
    }
    
    if (counter % 2 == 0) {
        self.mainDisplay.priorityAlertFrequency = 0;
    }
    
    counter++;
}

// DEMO method - blinks the side/back arrows
- (void)turnSideBackOnOff
{
    static NSUInteger counter = 1;
    
    if (counter % 3 == 0) {
        if (self.mainDisplay.sideArrowState == TFDisplayStateOn) {
            self.mainDisplay.sideArrowState = TFDisplayStateOff;
        } else {
            self.mainDisplay.sideArrowState = TFDisplayStateOn;
        }
    }
    
    if (counter % 2 == 0) {
        if (self.mainDisplay.behindArrowState == TFDisplayStateOn) {
            self.mainDisplay.behindArrowState = TFDisplayStateOff;
        } else {
            self.mainDisplay.behindArrowState = TFDisplayStateOn;
        }
    }
    
    counter++;
}

// DEMO method - randomly changes the current speed
- (void)changeSpeed
{
    [self.locationManager stopUpdatingLocation];
    
    static BOOL goingUp = YES;
    
    self.currentSpeed = self.currentSpeed + (goingUp ? 1 : -1) * (NSInteger)arc4random_uniform(5);
    if (self.currentSpeed > 105) {
        goingUp = NO;
        self.currentSpeed = 105;
    } else if (self.currentSpeed == 0) {
        goingUp = YES;
    }
}

// DEMO method - randomly changes the signal strength
- (void)changeSignalStrength
{
    static BOOL goingUp = YES;
    
    //    self.signalStrength = self.signalStrength + (goingUp ? 1.0f : -1.0f) * (NSInteger)arc4random_uniform(10) / 1000.0f;
    self.mainDisplay.signalStrength = self.mainDisplay.signalStrength + (goingUp ? 1/8.f : -1/8.f);
    if (self.mainDisplay.signalStrength == 1.0f) {
        goingUp = NO;
    } else if (self.mainDisplay.signalStrength == 0.0f) {
        goingUp = YES;
    }
}

// DEMO method - cycles through the bogey count
- (void)changeBogeyCount
{
    //    static BOOL goingUp = YES;
    //
    //    self.mainDisplay.bogeyCount = self.mainDisplay.bogeyCount + (goingUp ? 1 : -1);
    //    if (self.mainDisplay.bogeyCount >= 9) {
    //        goingUp = NO;
    //    } else if (self.mainDisplay.bogeyCount <= 0) {
    //        goingUp = YES;
    //    }
    static NSInteger count = 0;
    
    if (count == 0) {
        self.mainDisplay.bogeyCount = 1;
    } else if (count == 1) {
        self.mainDisplay.bogeyCount = 1;
    } else if (count == 2) {
        self.mainDisplay.bogeyCount = 2;
    } else if (count == 3) {
        self.mainDisplay.bogeyCount = 1;
    } else if (count == 4) {
        self.mainDisplay.bogeyCount = 1;
    } else if (count == 5) {
        self.mainDisplay.bogeyCount = 2;
    } else if (count == 6) {
        self.mainDisplay.bogeyCount = 3;
    } else if (count == 7) {
        self.mainDisplay.bogeyCount = 4;
    } else if (count == 8) {
        self.mainDisplay.bogeyCount = 4;
    } else if (count == 9) {
        self.mainDisplay.bogeyCount = 3;
    } else if (count == 10) {
        self.mainDisplay.bogeyCount = 4;
    } else if (count == 11) {
        self.mainDisplay.bogeyCount = 5;
    } else if (count == 12) {
        self.mainDisplay.bogeyCount = 6;
    } else if (count == 13) {
        self.mainDisplay.bogeyCount = 7;
    } else if (count == 14) {
        self.mainDisplay.bogeyCount = 8;
    } else if (count == 15) {
        self.mainDisplay.bogeyCount = 9;
    } else if (count == 16) {
        self.mainDisplay.bogeyCount = 9;
    } else {
        count = 0;
    }
    count++;
}

// DEMO method - blinks the band indicators
- (void)blinkBandIndicators
{
    static NSUInteger counter = 1;
    
    self.mainDisplay.kaState = TFDisplayStateBlinking;
    
    self.mainDisplay.laserState = TFDisplayStateOff;
    
    if (counter % 2 == 0) {
        if (self.mainDisplay.xState == TFDisplayStateOn) {
            self.mainDisplay.xState = TFDisplayStateOff;
        } else {
            self.mainDisplay.xState = TFDisplayStateOn;
        }
    }
    
    if (counter % 5 == 0) {
        if (self.mainDisplay.kState == TFDisplayStateOn) {
            self.mainDisplay.kState = TFDisplayStateOff;
        } else {
            self.mainDisplay.kState = TFDisplayStateOn;
        }
        //        self.mainDisplay.kaState = TFDisplayStateOff;
    }
    
    if (counter % 9 == 0) {
        //        self.mainDisplay.kaState = TFDisplayStateOn;
    }
    
    if (counter % 12 == 0) {
        self.mainDisplay.laserState = TFDisplayStateOn;
    }
    
    counter++;
}

@end
