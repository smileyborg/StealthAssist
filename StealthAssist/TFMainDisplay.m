//
//  TFMainDisplay.m
//  StealthAssist
//
//  Created by Tyler Fox on 12/31/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import "TFMainDisplay.h"
#import "TFSignalStrengthView.h"

#define kSignalStrengthBarInset     20.0f
#define kBottomHUDCornerRadius      4.0f

@interface TFMainDisplay ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@property (nonatomic, strong, readwrite) UIView *mainHUDBorder;

// Center HUD
@property (nonatomic, strong) UIView *centerHUDContainer;
@property (nonatomic, strong) UIImageView *aheadArrow;
@property (nonatomic, strong) UIImageView *sideArrow;
@property (nonatomic, strong) UIImageView *behindArrow;

// Left HUD
@property (nonatomic, strong) UIView *leftHUDContainer;
@property (nonatomic, strong) TFSignalStrengthView *signalStrengthView;
@property (nonatomic, strong) UILabel *bogeyCountLabel;
@property (nonatomic, strong) UIView *leftHUDDivider;

// Right HUD
@property (nonatomic, strong) UIView *rightHUDContainer;
@property (nonatomic, strong) UILabel *laserLabel;
@property (nonatomic, strong) UIView *laserLabelBackground;
@property (nonatomic, strong) UILabel *kaLabel;
@property (nonatomic, strong) UIView *kaLabelBackground;
@property (nonatomic, strong) UILabel *kLabel;
@property (nonatomic, strong) UIView *kLabelBackground;
@property (nonatomic, strong) UILabel *xLabel;
@property (nonatomic, strong) UIView *xLabelBackground;

// Bottom HUD
@property (nonatomic, strong) UIView *bottomHUDContainer;
@property (nonatomic, strong) UILabel *modeLabel;
@property (nonatomic, strong) UILabel *frequencyLabel;

@end

@implementation TFMainDisplay

+ (instancetype)mainDisplay
{
    return [[self alloc] initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self loadBottomHUD];
        
        self.mainHUDBorder = [UIView newAutoLayoutView];
        self.mainHUDBorder.clipsToBounds = YES;
        self.mainHUDBorder.backgroundColor = [UIColor blackColor];
        self.mainHUDBorder.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.mainHUDBorder.layer.borderWidth = 3.0f;
        self.mainHUDBorder.layer.cornerRadius = 8.0f;
        [self addSubview:self.mainHUDBorder];
        
        [self loadCenterHUD];
        [self loadLeftHUD];
        [self loadRightHUD];
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(refreshDisplayState) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)loadCenterHUD
{
    self.centerHUDContainer = [UIView newAutoLayoutView];
    self.centerHUDContainer.layer.borderWidth = 2.0f;
    self.centerHUDContainer.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.mainHUDBorder addSubview:self.centerHUDContainer];
    
    self.aheadArrow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"arrow-ahead-grey"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    self.aheadArrow.translatesAutoresizingMaskIntoConstraints = NO;
    self.aheadArrow.tintColor = [UIColor darkGrayColor];
    [self.centerHUDContainer addSubview:self.aheadArrow];
    
    self.sideArrow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"arrow-side-grey"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    self.sideArrow.translatesAutoresizingMaskIntoConstraints = NO;
    self.sideArrow.tintColor = [UIColor darkGrayColor];
    [self.centerHUDContainer addSubview:self.sideArrow];
    
    self.behindArrow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"arrow-behind-grey"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    self.behindArrow.translatesAutoresizingMaskIntoConstraints = NO;
    self.behindArrow.tintColor = [UIColor darkGrayColor];
    [self.centerHUDContainer addSubview:self.behindArrow];
}

- (void)loadLeftHUD
{
    self.leftHUDContainer = [UIView newAutoLayoutView];
    [self.mainHUDBorder addSubview:self.leftHUDContainer];
    
    self.signalStrengthView = [TFSignalStrengthView newAutoLayoutView];
    self.signalStrengthView.layer.cornerRadius = 4.0f;
    [self.leftHUDContainer addSubview:self.signalStrengthView];
    
    self.bogeyCountLabel = [UILabel newAutoLayoutView];
    self.bogeyCountLabel.layer.cornerRadius = 4.0f;
    self.bogeyCountLabel.font = [UIFont fontWithName:kStealthAssistFont size:86.0f];
    self.bogeyCountLabel.textAlignment = NSTextAlignmentCenter;
    self.bogeyCountLabel.adjustsFontSizeToFitWidth = YES;
    [self.leftHUDContainer addSubview:self.bogeyCountLabel];
    
    self.leftHUDDivider = [UIView newAutoLayoutView];
    self.leftHUDDivider.layer.borderWidth = 2.0f;
    self.leftHUDDivider.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.leftHUDContainer addSubview:self.leftHUDDivider];
}

- (void)loadRightHUD
{
    self.rightHUDContainer = [UIView newAutoLayoutView];
    [self.mainHUDBorder addSubview:self.rightHUDContainer];
    
    static const CGFloat bandLabelFontSize = 44.0f;
    
    self.laserLabelBackground = [UIView newAutoLayoutView];
    [self.rightHUDContainer addSubview:self.laserLabelBackground];
    
    self.laserLabel = [UILabel newAutoLayoutView];
    self.laserLabel.font = [UIFont fontWithName:kStealthAssistFont size:bandLabelFontSize];
    self.laserLabel.text = @"L";
    [self.rightHUDContainer addSubview:self.laserLabel];
    
    self.kaLabelBackground = [UIView newAutoLayoutView];
    [self.rightHUDContainer addSubview:self.kaLabelBackground];
    
    self.kaLabel = [UILabel newAutoLayoutView];
    self.kaLabel.font = [UIFont fontWithName:kStealthAssistFont size:bandLabelFontSize];
    self.kaLabel.text = @"Ka";
    [self.rightHUDContainer addSubview:self.kaLabel];
    
    self.kLabelBackground = [UIView newAutoLayoutView];
    [self.rightHUDContainer addSubview:self.kLabelBackground];
    
    self.kLabel = [UILabel newAutoLayoutView];
    self.kLabel.font = [UIFont fontWithName:kStealthAssistFont size:bandLabelFontSize];
    self.kLabel.text = @"K";
    [self.rightHUDContainer addSubview:self.kLabel];
    
    self.xLabelBackground = [UIView newAutoLayoutView];
    [self.rightHUDContainer addSubview:self.xLabelBackground];
    
    self.xLabel = [UILabel newAutoLayoutView];
    self.xLabel.font = [UIFont fontWithName:kStealthAssistFont size:bandLabelFontSize];
    self.xLabel.text = @"X";
    [self.rightHUDContainer addSubview:self.xLabel];
}

- (void)loadBottomHUD
{
    self.bottomHUDContainer = [UIView newAutoLayoutView];
    self.bottomHUDContainer.layer.borderWidth = 2.0f;
    self.bottomHUDContainer.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.bottomHUDContainer.layer.cornerRadius = kBottomHUDCornerRadius;
    [self addSubview:self.bottomHUDContainer];
    
    self.modeLabel = [UILabel newAutoLayoutView];
    self.modeLabel.font = [UIFont fontWithName:kStealthAssistFont size:18.0f];
    self.modeLabel.textAlignment = NSTextAlignmentCenter;
    self.modeLabel.adjustsFontSizeToFitWidth = YES;
    self.modeLabel.minimumScaleFactor = 0.8;
    [self.bottomHUDContainer addSubview:self.modeLabel];
    
    self.frequencyLabel = [UILabel newAutoLayoutView];
    CGFloat frequencyFontSize = DEVICE_HAS_TALL_SCREEN ? 30.0f : 24.0f;
    self.frequencyLabel.font = [UIFont fontWithName:kStealthAssistFont size:frequencyFontSize];
    self.frequencyLabel.textAlignment = NSTextAlignmentCenter;
    self.frequencyLabel.text = @" "; // this will force the label to the correct height, which may impact auto layout calculations
    self.frequencyLabel.hidden = YES; // will be made visible when a frequency is set
    [self.bottomHUDContainer addSubview:self.frequencyLabel];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (!self.didSetupConstraints) {
        [self.centerHUDContainer autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.centerHUDContainer autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.leftHUDContainer autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.rightHUDContainer autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.bottomHUDContainer autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f relation:NSLayoutRelationGreaterThanOrEqual];
        
        [self.mainHUDBorder autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [self.mainHUDBorder autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.centerHUDContainer];
        
        // Assumes sideArrow is the widest image
        [self.sideArrow autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f];
        [self.sideArrow autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0f];
        
        [self.aheadArrow autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12.0f];
        [self.aheadArrow autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        [self.sideArrow autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.aheadArrow withOffset:0.0f];
        [self.sideArrow autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        [self.behindArrow autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.sideArrow withOffset:0.0f];
        [self.behindArrow autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:12.0f];
        [self.behindArrow autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        [self.leftHUDContainer autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.centerHUDContainer withOffset:0.0f];
        [self.leftHUDContainer autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeRight];
        
        [self.signalStrengthView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 2.0, 0) excludingEdge:ALEdgeTop];
        [self.signalStrengthView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.bogeyCountLabel];
        
        [self.bogeyCountLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.bogeyCountLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [self.bogeyCountLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow - 1 forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.leftHUDDivider autoSetDimension:ALDimensionHeight toSize:2.0];
        [self.leftHUDDivider autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.leftHUDDivider autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [self.leftHUDDivider autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.bogeyCountLabel];
        
        [self.rightHUDContainer autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.centerHUDContainer withOffset:0.0f];
        [self.rightHUDContainer autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.centerHUDContainer];
        
        [@[self.laserLabel, self.kaLabel, self.kLabel, self.xLabel] autoDistributeViewsAlongAxis:ALAxisVertical alignedTo:ALAttributeVertical withFixedSpacing:15.0f];
        [self.laserLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.laserLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.kaLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.kaLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.kLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.kLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.xLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.xLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10.0f relation:NSLayoutRelationGreaterThanOrEqual];
        
        [self.laserLabelBackground autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.laserLabel];
        [self.laserLabelBackground autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.rightHUDContainer];
        [self.laserLabelBackground autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.rightHUDContainer];
        [self.laserLabelBackground autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.laserLabel];
        
        [self.kaLabelBackground autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.kaLabel];
        [self.kaLabelBackground autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.laserLabelBackground];
        [self.kaLabelBackground autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.laserLabelBackground];
        [self.kaLabelBackground autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.kaLabel];
        
        [self.kLabelBackground autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.kLabel];
        [self.kLabelBackground autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.laserLabelBackground];
        [self.kLabelBackground autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.laserLabelBackground];
        [self.kLabelBackground autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.kLabel];
        
        [self.xLabelBackground autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.xLabel];
        [self.xLabelBackground autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.laserLabelBackground];
        [self.xLabelBackground autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.laserLabelBackground];
        [self.xLabelBackground autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.xLabel];
        
        [self.bottomHUDContainer autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.centerHUDContainer];
        [self.bottomHUDContainer autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.centerHUDContainer];
        [self.bottomHUDContainer autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.centerHUDContainer withOffset:-kBottomHUDCornerRadius];
        
        [self.modeLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:4.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.modeLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:6.0f];
        [self.modeLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:6.0f];
        [self.modeLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:2.0f relation:NSLayoutRelationGreaterThanOrEqual];
        [self.modeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow - 1 forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.frequencyLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.modeLabel];
        [self.frequencyLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.modeLabel];
        [self.frequencyLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.modeLabel];
        [self.frequencyLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.modeLabel];
        
        self.didSetupConstraints = YES;
    }
}

- (void)setSignalStrength:(CGFloat)signalStrength
{
    signalStrength = MAX(MIN(signalStrength, 1.0f), 0.0f);
    _signalStrength = signalStrength;
}

- (void)setMode:(TFV1Mode)mode
{
    _mode = mode;
    
    self.modeLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0]; // only Unknown Mode is not this color
    switch (mode) {
        case TFV1ModeAllBogeys:
            self.modeLabel.text = @"All Bogeys";
            break;
        case TFV1ModeLogic:
            self.modeLabel.text = @"Logic";
            break;
        case TFV1ModeAdvancedLogic:
            self.modeLabel.text = @"Advanced Logic";
            break;
        case TFV1ModeKKaCustomSweeps:
            self.modeLabel.text = @"K & Ka Custom Sweeps";
            break;
        case TFV1ModeKaCustomSweeps:
            self.modeLabel.text = @"Ka Custom Sweeps";
            break;
        case TFV1ModeKKaPhoto:
            self.modeLabel.text = @"Euro K & Ka (Photo)";
            break;
        case TFV1ModeKaPhoto:
            self.modeLabel.text = @"Euro Ka (Photo)";
            break;
        default:
            self.modeLabel.text = @"Unknown Mode";
            self.modeLabel.textColor = [UIColor darkGrayColor];
            break;
    }
}

- (void)setPriorityAlertFrequency:(NSInteger)priorityAlertFrequency
{
    _priorityAlertFrequency = priorityAlertFrequency;
    
    if (priorityAlertFrequency > 0 && [[TFPreferences sharedInstance] showPriorityAlertFrequency]) {
        self.modeLabel.hidden = YES;
        self.frequencyLabel.hidden = NO;
        self.frequencyLabel.text = [NSString stringWithFormat:@"%.3f GHz", priorityAlertFrequency / 1000.0f];
        UIColor *textColor = kAppTintColor;
        if ([TFPreferences sharedInstance].colorPerBand) {
            if (priorityAlertFrequency >= kBandKaFrequencyLowerEnd) {
                textColor = [TFPreferences sharedInstance].bandKaColor;
            } else if (priorityAlertFrequency >= kBandKFrequencyLowerEnd) {
                textColor = [TFPreferences sharedInstance].bandKColor;
            } else if (priorityAlertFrequency >= kBandKuFrequencyLowerEnd) {
                textColor = [TFPreferences sharedInstance].bandKColor; // Treat Ku as K
            } else if (priorityAlertFrequency >= kBandXFrequencyLowerEnd) {
                textColor = [TFPreferences sharedInstance].bandXColor;
            }
        }
        self.frequencyLabel.textColor = textColor;
    } else {
        self.modeLabel.hidden = NO;
        self.frequencyLabel.hidden = YES;
        self.frequencyLabel.text = @" "; // this will force the label to the correct height, which may impact auto layout calculations
    }
}

- (void)refreshDisplayState
{
    static BOOL aheadBlinkRed = NO;
    if (self.aheadArrowState == TFDisplayStateOff || (self.aheadArrowState == TFDisplayStateBlinking && aheadBlinkRed)) {
        self.aheadArrow.tintColor = [UIColor darkGrayColor];
    } else if (self.aheadArrowState == TFDisplayStateOn || (self.aheadArrowState == TFDisplayStateBlinking && !aheadBlinkRed)) {
        self.aheadArrow.tintColor = kAppTintColor;
    }
    aheadBlinkRed = !aheadBlinkRed;
    
    static BOOL sideBlinkRed = NO;
    if (self.sideArrowState == TFDisplayStateOff || (self.sideArrowState == TFDisplayStateBlinking && sideBlinkRed)) {
        self.sideArrow.tintColor = [UIColor darkGrayColor];
    } else if (self.sideArrowState == TFDisplayStateOn || (self.sideArrowState == TFDisplayStateBlinking && !sideBlinkRed)) {
        self.sideArrow.tintColor = kAppTintColor;
    }
    sideBlinkRed = !sideBlinkRed;
    
    static BOOL behindBlinkRed = NO;
    if (self.behindArrowState == TFDisplayStateOff || (self.behindArrowState == TFDisplayStateBlinking && behindBlinkRed)) {
        self.behindArrow.tintColor = [UIColor darkGrayColor];
    } else if (self.behindArrowState == TFDisplayStateOn || (self.behindArrowState == TFDisplayStateBlinking && !behindBlinkRed)) {
        self.behindArrow.tintColor = kAppTintColor;
    }
    behindBlinkRed = !behindBlinkRed;
    
    static BOOL laserBlinkRed = NO;
    if (self.laserState == TFDisplayStateOff || (self.laserState == TFDisplayStateBlinking && laserBlinkRed)) {
        [self updateBand:TFBandLaser label:self.laserLabel background:self.laserLabelBackground toOn:NO];
    } else if (self.laserState == TFDisplayStateOn || (self.laserState == TFDisplayStateBlinking && !laserBlinkRed)) {
        [self updateBand:TFBandLaser label:self.laserLabel background:self.laserLabelBackground toOn:YES];
    }
    laserBlinkRed = !laserBlinkRed;
    
    static BOOL kaBlinkRed = NO;
    if (self.kaState == TFDisplayStateOff || (self.kaState == TFDisplayStateBlinking && kaBlinkRed)) {
        [self updateBand:TFBandKa label:self.kaLabel background:self.kaLabelBackground toOn:NO];
    } else if (self.kaState == TFDisplayStateOn || (self.kaState == TFDisplayStateBlinking && !kaBlinkRed)) {
        [self updateBand:TFBandKa label:self.kaLabel background:self.kaLabelBackground toOn:YES];
    }
    kaBlinkRed = !kaBlinkRed;
    
    static BOOL kBlinkRed = NO;
    if (self.kState == TFDisplayStateOff || (self.kState == TFDisplayStateBlinking && kBlinkRed)) {
        [self updateBand:TFBandK label:self.kLabel background:self.kLabelBackground toOn:NO];
    } else if (self.kState == TFDisplayStateOn || (self.kState == TFDisplayStateBlinking && !kBlinkRed)) {
        [self updateBand:TFBandK label:self.kLabel background:self.kLabelBackground toOn:YES];
    }
    kBlinkRed = !kBlinkRed;
    
    static BOOL xBlinkRed = NO;
    if (self.xState == TFDisplayStateOff || (self.xState == TFDisplayStateBlinking && xBlinkRed)) {
        [self updateBand:TFBandX label:self.xLabel background:self.xLabelBackground toOn:NO];
    } else if (self.xState == TFDisplayStateOn || (self.xState == TFDisplayStateBlinking && !xBlinkRed)) {
        [self updateBand:TFBandX label:self.xLabel background:self.xLabelBackground toOn:YES];
    }
    xBlinkRed = !xBlinkRed;
    
    
    CGFloat signalStrength = self.signalStrength;
    if (self.laserState != TFDisplayStateOff) {
        // We have a laser alert - this pegs the signal strength to 100%, and fills the bogeyCount label solid red
        signalStrength = 1.0f;
        self.bogeyCountLabel.text = @"!";
        self.bogeyCountLabel.textColor = [UIColor blackColor];
        self.bogeyCountLabel.backgroundColor = kAppTintColor;
    } else {
        // Normal case, no laser alert
        NSInteger singleDigitBogeyCount = MIN(self.bogeyCount, 9); // don't display more than 9, even though this is possible
        self.bogeyCountLabel.text = [NSString stringWithFormat:@"%ld", (long)singleDigitBogeyCount];
        self.bogeyCountLabel.textColor = self.bogeyCount > 0 ? kAppTintColor : [UIColor darkGrayColor];
        self.bogeyCountLabel.backgroundColor = [UIColor blackColor];
    }
    
    self.signalStrengthView.numberOfBars = signalStrength * 8.0;
    
    self.priorityAlertFrequency = self.priorityAlertFrequency; // causes priority alert frequency to update
}

- (void)updateBand:(TFBand)band label:(UILabel *)label background:(UIView *)background toOn:(BOOL)isOn
{
    label.textColor = isOn ? [UIColor blackColor] : [UIColor darkGrayColor];
    
    UIColor *bandColor = kAppTintColor;
    if ([TFPreferences sharedInstance].colorPerBand) {
        switch (band) {
            case TFBandLaser:
                bandColor = [TFPreferences sharedInstance].bandLaserColor;
                break;
            case TFBandKa:
                bandColor = [TFPreferences sharedInstance].bandKaColor;
                break;
            case TFBandK:
                bandColor = [TFPreferences sharedInstance].bandKColor;
                break;
            case TFBandX:
                bandColor = [TFPreferences sharedInstance].bandXColor;
                break;
            default:
                break;
        }
    }
    background.backgroundColor = isOn ? bandColor : [UIColor blackColor];
}

- (CGRect)leftHUDRect
{
    return [self.superview convertRect:self.leftHUDContainer.frame fromView:self.leftHUDContainer.superview];
}

- (CGRect)centerHUDRect
{
    return [self.superview convertRect:self.centerHUDContainer.frame fromView:self.centerHUDContainer.superview];
}

- (CGRect)rightHUDRect
{
    return [self.superview convertRect:self.rightHUDContainer.frame fromView:self.rightHUDContainer.superview];
}

@end
