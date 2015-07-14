//
//  TFAlertOverlay.h
//  StealthAssist
//
//  Created by Tyler Fox on 12/31/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFAlertOverlay : UIView

@property (nonatomic) NSString *title;
@property (nonatomic, assign) BOOL displayActivityIndicator;

+ (instancetype)alertOverlayWithSize:(CGSize)size title:(NSString *)title;

- (void)display;
- (void)displayForDuration:(NSTimeInterval)duration;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;
- (void)dismissAfterDelay:(NSTimeInterval)delay;

@end
