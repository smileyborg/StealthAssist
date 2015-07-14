//
//  TFControlDrawer.m
//  StealthAssist
//
//  Created by Tyler Fox on 12/28/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import "TFControlDrawer.h"

#define kToggleButtonHorizontalOffsetPercentage 0.75f
#define kPaddingBetweenControlIcons             25.0f
#define kToggleButtonBackgroundCornerRadius     12.0f

@interface TFControlDrawer ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@property (nonatomic, strong, readwrite) UIButton *toggleButton;
@property (nonatomic, strong) UIView *toggleButtonBackground;
@property (nonatomic, strong) UIView *drawerBackground; // the visible gray background of the drawer (overdraws for overslide effect)
@property (nonatomic, strong) UIView *buttonContainer; // contains the buttons, roughly same as drawerBackground but no overdraw (so buttons can center correctly)
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *standbyButton;
@property (nonatomic, strong) UIButton *helpButton;
@property (nonatomic, strong) UIButton *unlockButton;

@property (nonatomic, assign) CGAffineTransform unlockButtonTransform; // will store the current transform on the unlock button

@end

@implementation TFControlDrawer

// Designated initializer.
- (id)initWithDelegate:(NSObject<TFControlDrawerDelegate> *)delegate
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        _isDrawerOpen = NO;
        _isUnlockButtonEnabled = [self shouldDisplayUnlockButton];
    }
    return self;
}

- (void)setupView
{
    self.toggleButtonBackground = [UIView newAutoLayoutView];
    self.toggleButtonBackground.backgroundColor = [UIColor darkGrayColor];
    self.toggleButtonBackground.layer.cornerRadius = kToggleButtonBackgroundCornerRadius;
    [self addSubview:self.toggleButtonBackground];
    
    UIImage *triangleImage = [UIImage imageNamed:@"icon-triangle"];
    self.toggleButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   triangleImage.size.width,
                                                                   triangleImage.size.height)];
    [self.toggleButton setImage:triangleImage forState:UIControlStateNormal];
    self.toggleButton.center = CGPointMake(CGRectGetMidX(self.bounds), self.toggleButton.center.y);
    self.toggleButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.toggleButton addTarget:self action:@selector(toggleDrawer) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toggleButton];
    
    self.drawerBackground = [UIView newAutoLayoutView];
    self.drawerBackground.backgroundColor = self.toggleButtonBackground.backgroundColor;
    [self addSubview:self.drawerBackground];
    
    self.buttonContainer = [UIView newAutoLayoutView];
    [self.drawerBackground addSubview:self.buttonContainer];
    
    self.settingsButton = [UIButton newAutoLayoutView];
    [self.settingsButton setImage:[UIImage imageNamed:@"icon-settings"] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(settingsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainer addSubview:self.settingsButton];
    
    self.standbyButton = [UIButton newAutoLayoutView];
    [self.standbyButton setImage:[UIImage imageNamed:@"icon-power"] forState:UIControlStateNormal];
    [self.standbyButton addTarget:self action:@selector(standbyButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainer addSubview:self.standbyButton];
    
    self.helpButton = [UIButton newAutoLayoutView];
    [self.helpButton setImage:[UIImage imageNamed:@"icon-help"] forState:UIControlStateNormal];
    [self.helpButton addTarget:self action:@selector(helpButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainer addSubview:self.helpButton];
    
    if ([self shouldDisplayUnlockButton]) {
        self.unlockButton = [UIButton newAutoLayoutView];
        [self.unlockButton setImage:[UIImage imageNamed:@"icon-unlock"] forState:UIControlStateNormal];
        [self.unlockButton addTarget:self action:@selector(unlockButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonContainer addSubview:self.unlockButton];
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (!self.didSetupConstraints) {
        [self.drawerBackground autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kTFControlDrawerTopOverlap, 0.0f, -kDrawerOverSlide, 0.0f)];
        [self.buttonContainer autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0f, 0.0f, kDrawerOverSlide, 0.0f)];
        
        [self.toggleButtonBackground autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.toggleButton withOffset:-8.0f];
        [self.toggleButtonBackground autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.toggleButton withOffset:-12.0f];
        [self.toggleButtonBackground autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.toggleButton withOffset:12.0f];
        [self.toggleButtonBackground autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.drawerBackground withOffset:kToggleButtonBackgroundCornerRadius];
        
        if ([self shouldDisplayUnlockButton]) {
            [self.settingsButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
            [self.settingsButton autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.buttonContainer withMultiplier:0.25f];
            
            [self.standbyButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
            [self.standbyButton autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.buttonContainer withMultiplier:0.75f];
            
            [self.helpButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
            [self.helpButton autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.buttonContainer withMultiplier:1.25f];
            
            [self.unlockButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
            [self.unlockButton autoConstrainAttribute:ALAttributeVertical toAttribute:ALAttributeVertical ofView:self.buttonContainer withMultiplier:1.75f];
        } else {
            [self.settingsButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
            [self.settingsButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kPaddingBetweenControlIcons];
            
            [self.standbyButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
            [self.standbyButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
            
            [self.helpButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
            [self.helpButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kPaddingBetweenControlIcons];
        }
        
        self.didSetupConstraints = YES;
    }
}

- (BOOL)shouldDisplayUnlockButton
{
    return [TFAppUnlockManager sharedInstance].isTrial;
}

- (void)setIsUnlockButtonEnabled:(BOOL)isUnlockButtonEnabled
{
    _isUnlockButtonEnabled = isUnlockButtonEnabled;
    self.unlockButton.enabled = isUnlockButtonEnabled;
    [self.unlockButton.layer removeAllAnimations];
    [self startUnlockButtonAnimation];
}

- (void)startUnlockButtonAnimation
{
    if (self.isUnlockButtonEnabled == NO) {
        self.unlockButton.transform = self.unlockButtonTransform;
        return;
    }
    
    // Push the new animation to the next run loop so that any previous removeAllAnimations call will actually take effect
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1.0
                              delay:0.0
                            options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.unlockButton.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.15, 1.15), self.unlockButtonTransform);
                         }
                         completion:nil];
    });
}

// Override to make this view transparent to touches.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    // If the hitView is THIS view, return nil and allow hitTest:withEvent: to
    // continue traversing the hierarchy to find the underlying view.
    if (hitView == self) {
        return nil;
    }
    // Else return the hitView (as it could be one of this view's buttons).
    return hitView;
}

- (void)rotateToHorizontal:(BOOL)isHorizontal
{
    CGAffineTransform rotate = isHorizontal ? CGAffineTransformMakeRotation(-M_PI_2) : CGAffineTransformIdentity;
    CGAffineTransform inverseRotate = isHorizontal ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformIdentity;
    
    self.transform = rotate;
    self.settingsButton.transform = inverseRotate;
    self.standbyButton.transform = inverseRotate;
    self.helpButton.transform = inverseRotate;
    
    if ([self shouldDisplayUnlockButton]) {
        self.unlockButtonTransform = inverseRotate;
        self.unlockButton.transform = self.unlockButtonTransform;
        [self.unlockButton.layer removeAllAnimations];
        [self startUnlockButtonAnimation];
    }
    
    CGFloat toggleButtonX = isHorizontal ? CGRectGetWidth(self.bounds) * kToggleButtonHorizontalOffsetPercentage : CGRectGetMidX(self.bounds);
    self.toggleButton.center = CGPointMake(toggleButtonX, self.toggleButton.center.y);
    if (isHorizontal) {
        self.toggleButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    } else {
        self.toggleButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
}

- (UIView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:self.superview.bounds];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _overlayView.backgroundColor = kOverlayColor;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDrawer)];
        [_overlayView addGestureRecognizer:tapGestureRecognizer];
    }
    return _overlayView;
}

- (void)toggleDrawer
{
    [self.delegate toggleControlDrawer];
}

- (void)settingsButtonTapped
{
    [self.delegate controlDrawerShowSettings];
}

- (void)standbyButtonTapped
{
    [self.delegate controlDrawerEnterStandby];
}

- (void)helpButtonTapped
{
    [self.delegate controlDrawerShowHelp];
}

- (void)unlockButtonTapped
{
    [self.delegate controlDrawerUnlockApp];
}

- (CGRect)toggleButtonRect
{
    return [self.superview convertRect:self.toggleButtonBackground.frame fromView:self.toggleButtonBackground.superview];
}

@end
