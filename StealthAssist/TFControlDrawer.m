//
//  TFControlDrawer.m
//  StealthAssist
//
//  Created by Tyler Fox on 12/28/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import "TFControlDrawer.h"
#import "UIView+Orientation.h"

@interface TFControlDrawer ()

@property (nonatomic, strong, readwrite) UIButton *toggleButton;
@property (nonatomic, strong) UIView *toggleButtonBackground;
@property (nonatomic, strong) UIView *drawerBackground; // the visible gray background of the drawer (overdraws for overslide effect)
@property (nonatomic, strong) UIStackView *buttonContainer; // contains the buttons, roughly same as drawerBackground but no overdraw (so buttons can center correctly)
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *standbyButton;
@property (nonatomic, strong) UIButton *helpButton;
@property (nonatomic, strong) UIButton *unlockButton;

/** YES if in the tall layout, NO if in the wide layout. */
@property (nonatomic, assign) BOOL isTallLayout;

// Only one of these two will ever be non-nil at a time. Stores the constraints used for that particular layout.
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *tallConstraints;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *wideConstraints;

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

static const CGFloat kToggleButtonBackgroundCornerRadius = 12.0;

- (void)setupView
{
    self.toggleButtonBackground = [UIView newAutoLayoutView];
    self.toggleButtonBackground.backgroundColor = [UIColor darkGrayColor];
    self.toggleButtonBackground.layer.cornerRadius = kToggleButtonBackgroundCornerRadius;
    [self addSubview:self.toggleButtonBackground];
    
    UIImage *triangleImage = [UIImage imageNamed:@"icon-triangle"];
    self.toggleButton = [UIButton newAutoLayoutView];
    [self.toggleButton setImage:triangleImage forState:UIControlStateNormal];
    [self.toggleButton addTarget:self action:@selector(toggleDrawer) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toggleButton];
    
    self.drawerBackground = [UIView newAutoLayoutView];
    self.drawerBackground.backgroundColor = self.toggleButtonBackground.backgroundColor;
    [self addSubview:self.drawerBackground];
    
    NSMutableArray<UIView *> *buttons = [NSMutableArray array];
    
    self.settingsButton = [UIButton new];
    [self.settingsButton setImage:[UIImage imageNamed:@"icon-settings"] forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(settingsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttons addObject:self.settingsButton];
    
    self.standbyButton = [UIButton new];
    [self.standbyButton setImage:[UIImage imageNamed:@"icon-power"] forState:UIControlStateNormal];
    [self.standbyButton addTarget:self action:@selector(standbyButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttons addObject:self.standbyButton];
    
    self.helpButton = [UIButton new];
    [self.helpButton setImage:[UIImage imageNamed:@"icon-help"] forState:UIControlStateNormal];
    [self.helpButton addTarget:self action:@selector(helpButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttons addObject:self.helpButton];
    
    if ([self shouldDisplayUnlockButton]) {
        self.unlockButton = [UIButton new];
        [self.unlockButton setImage:[UIImage imageNamed:@"icon-unlock"] forState:UIControlStateNormal];
        [self.unlockButton addTarget:self action:@selector(unlockButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:self.unlockButton];
    }
    
    self.buttonContainer = [[UIStackView alloc] initWithArrangedSubviews:buttons];
    self.buttonContainer.axis = UILayoutConstraintAxisHorizontal;
    self.buttonContainer.distribution = UIStackViewDistributionEqualSpacing;
    self.buttonContainer.alignment = UIStackViewAlignmentCenter;
    [self.drawerBackground addSubview:self.buttonContainer];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (!self.tallConstraints && self.isTallLayout) {
        [self.wideConstraints autoRemoveConstraints];
        self.wideConstraints = nil;
        self.tallConstraints = [self setupTallConstraints];
    }
    
    if (!self.wideConstraints && !self.isTallLayout) {
        [self.tallConstraints autoRemoveConstraints];
        self.tallConstraints = nil;
        self.wideConstraints = [self setupWideConstraints];
    }
}

static const CGFloat k3ButtonsEdgePadding = 30.0;
static const CGFloat k4ButtonsEdgePadding = 15.0;
static const CGFloat kToggleButtonSideEdgePadding = 12.0;
static const CGFloat kToggleButtonEndEdgePadding = 8.0;

- (NSArray<NSLayoutConstraint *> *)setupWideConstraints
{
    CGFloat kButtonsEdgePadding = self.buttonContainer.arrangedSubviews.count >= 4 ? k4ButtonsEdgePadding : k3ButtonsEdgePadding;
    NSArray<NSLayoutConstraint *> *constraints = [UIView autoCreateConstraintsWithoutInstalling:^{
        [self.drawerBackground autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kTFControlDrawerTopOverlap, 0.0, -kDrawerOverSlide, 0.0)];
        [self.buttonContainer autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0, kButtonsEdgePadding, kDrawerOverSlide, kButtonsEdgePadding)];
        
        [self.toggleButton autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self];
        [self.toggleButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        [self.toggleButtonBackground autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.toggleButton withOffset:-kToggleButtonEndEdgePadding];
        [self.toggleButtonBackground autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.toggleButton withOffset:-kToggleButtonSideEdgePadding];
        [self.toggleButtonBackground autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.toggleButton withOffset:kToggleButtonSideEdgePadding];
        [self.toggleButtonBackground autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.drawerBackground withOffset:kToggleButtonBackgroundCornerRadius];
    }];
    [constraints autoInstallConstraints];
    return constraints;
}

- (NSArray<NSLayoutConstraint *> *)setupTallConstraints
{
    CGFloat kButtonsEdgePadding = self.buttonContainer.arrangedSubviews.count >= 4 ? k4ButtonsEdgePadding : k3ButtonsEdgePadding;
    NSArray<NSLayoutConstraint *> *constraints = [UIView autoCreateConstraintsWithoutInstalling:^{
        [self.drawerBackground autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0.0, kTFControlDrawerTopOverlap, 0.0, -kDrawerOverSlide)];
        [self.buttonContainer autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kButtonsEdgePadding, kDrawerOverSlide, kButtonsEdgePadding, 0.0)];
        
        [self.toggleButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self];
        [self.toggleButton autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self withMultiplier:0.5];
        
        [self.toggleButtonBackground autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.toggleButton withOffset:-kToggleButtonSideEdgePadding];
        [self.toggleButtonBackground autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.toggleButton withOffset:-kToggleButtonEndEdgePadding];
        [self.toggleButtonBackground autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.toggleButton withOffset:kToggleButtonSideEdgePadding];
        [self.toggleButtonBackground autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.drawerBackground withOffset:kToggleButtonBackgroundCornerRadius];
    }];
    [constraints autoInstallConstraints];
    return constraints;
}

- (BOOL)shouldDisplayUnlockButton
{
    return [TFAppUnlockManager sharedInstance].isTrial;
}

- (void)setIsUnlockButtonEnabled:(BOOL)isUnlockButtonEnabled
{
    _isUnlockButtonEnabled = isUnlockButtonEnabled;
    self.unlockButton.enabled = isUnlockButtonEnabled;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.isTallLayout = self.viewOrientation == ViewOrientationPortrait;
    CGAffineTransform rotate = self.isTallLayout ? CGAffineTransformMakeRotation(-M_PI_2) : CGAffineTransformIdentity;
    self.toggleButton.transform = rotate;
    self.buttonContainer.axis = self.isTallLayout ? UILayoutConstraintAxisVertical : UILayoutConstraintAxisHorizontal;
    [self setNeedsUpdateConstraints];
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
    [self.delegate toggleControlDrawerWithCompletionHandler:nil];
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
