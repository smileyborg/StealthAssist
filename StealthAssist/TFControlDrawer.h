//
//  TFControlDrawer.h
//  StealthAssist
//
//  Created by Tyler Fox on 12/28/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTFControlDrawerTopOverlap      30.0f
#define kTFControlDrawerHeight          110.0f

#define kSlideAnimationDuration              0.15
#define kOverSlideAnimationDuration          0.2

#define kDrawerSlideAmount          (kTFControlDrawerHeight - kTFControlDrawerTopOverlap)
#define kDrawerOverSlide            (kDrawerSlideAmount * 0.05f)

@protocol TFControlDrawerDelegate <NSObject>

- (void)toggleControlDrawerWithCompletionHandler:(void (^)())completion;
- (void)controlDrawerShowSettings;
- (void)controlDrawerShowHelp;
- (void)controlDrawerEnterStandby;
- (void)controlDrawerUnlockApp;

@end

@interface TFControlDrawer : UIView

// Exposed for tutorial
@property (nonatomic, readonly) CGRect toggleButtonRect;

@property (nonatomic, weak) NSObject<TFControlDrawerDelegate> *delegate;

@property (nonatomic, assign) BOOL isDrawerOpen;
@property (nonatomic, assign) BOOL isDrawerToggling; // will be YES during toggle animation to prevent another toggle before finished

@property (nonatomic, assign) BOOL isUnlockButtonEnabled;

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, readonly) UIButton *toggleButton;

- (id)initWithDelegate:(NSObject<TFControlDrawerDelegate> *)delegate;

// Applies transforms and adjusts the toggle button position so that the view appears correct in horizontal orientations
- (void)rotateToHorizontal:(BOOL)isHorizontal;

@end
