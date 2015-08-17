//
//  TFAlertOverlay.m
//  StealthAssist
//
//  Created by Tyler Fox on 12/31/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import "TFAlertOverlay.h"
#import "TFAppDelegate.h"

#define kInAnimationDuration        0.2
#define kOutAnimationDuration       0.25

@interface TFAlertOverlay ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) NSMutableArray *installedConstraints;

@property (nonatomic, assign) CGSize size;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UIView *overlayView; // the view that overlays the app, blocking user interaction with things underneath

@end

@implementation TFAlertOverlay

+ (instancetype)alertOverlayWithSize:(CGSize)size title:(NSString *)title
{
    TFAlertOverlay *alertOverlay = [[TFAlertOverlay alloc] initWithFrame:CGRectZero];
    alertOverlay.size = size;
    alertOverlay.titleLabel.text = title;
    return alertOverlay;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 12.0f;
        self.backgroundColor = kWhiteOverlayColor;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        self.titleLabel = [UILabel newAutoLayoutView];
        self.titleLabel.font = [UIFont fontWithName:kStealthAssistFont size:32.0f];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.5f;
        [self addSubview:self.titleLabel];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        self.activityIndicator.color = [UIColor blackColor];
        self.activityIndicator.hidesWhenStopped = YES;
        [self addSubview:self.activityIndicator];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (!self.didSetupConstraints) {
        [self.installedConstraints autoRemoveConstraints];
        self.installedConstraints = [NSMutableArray new];
        
        if (self.displayActivityIndicator) {
            [NSLayoutConstraint autoSetPriority:UILayoutPriorityRequired - 1 forConstraints:^{
                [self.installedConstraints addObjectsFromArray:[self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(25.0, 15.0, 0, 15.0) excludingEdge:ALEdgeBottom]];
                
                [self.installedConstraints addObject:[self.activityIndicator autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:15.0f]];
                [self.installedConstraints addObject:[self.activityIndicator autoAlignAxisToSuperviewAxis:ALAxisVertical]];
                [self.installedConstraints addObject:[self.activityIndicator autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:25.0f]];
            }];
        } else {
            [NSLayoutConstraint autoSetPriority:UILayoutPriorityRequired - 1 forConstraints:^{
                [self.installedConstraints addObjectsFromArray:[self.titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f)]];
            }];
        }
        
        self.didSetupConstraints = YES;
    }
}

- (void)reSetupConstraints
{
    self.didSetupConstraints = NO;
    [self setNeedsUpdateConstraints];
}

- (UIView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _overlayView;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setDisplayActivityIndicator:(BOOL)displayActivityIndicator
{
    _displayActivityIndicator = displayActivityIndicator;
    
    if (displayActivityIndicator) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    [self reSetupConstraints];
}

- (void)display
{
    [self displayForDuration:0.0];
}

- (void)displayForDuration:(NSTimeInterval)duration
{
    UIView *topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    self.overlayView.frame = topView.bounds;
    [topView addSubview:self.overlayView];
    
    self.alpha = 0.0f;
    [self.overlayView addSubview:self];
    self.frame = CGRectMake(CGRectGetMidX(self.overlayView.bounds) - self.size.width / 2.0f,
                            CGRectGetMidY(self.overlayView.bounds) - self.size.height / 2.0f,
                            self.size.width,
                            self.size.height);
    static const CGFloat inScale = 1.2f;
    self.transform = CGAffineTransformMakeScale(inScale, inScale);
    [UIView animateWithDuration:kInAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1.0f;
                         self.transform = CGAffineTransformIdentity;
                         if (duration == 0.0) {
                             [TFAppDelegate sharedInstance].window.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (duration > 0.0) {
                             [self dismissAfterDelay:duration];
                         }
                     }];
}

- (void)dismiss
{
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated
{
    static const CGFloat outScale = 0.7f;
    
    if (animated) {
        [UIView animateWithDuration:kInAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.alpha = 0.0f;
                             self.transform = CGAffineTransformMakeScale(outScale, outScale);
                             [TFAppDelegate sharedInstance].window.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             [self.overlayView removeFromSuperview];
                             self.overlayView = nil;
                         }];
    } else {
        [self removeFromSuperview];
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;
        [TFAppDelegate sharedInstance].window.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    }
}

- (void)dismissAfterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:delay];
}

@end
