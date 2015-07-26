//
//  UIView+Orientation.h
//  StealthAssist
//
//  Created by Tyler Fox on 7/25/15.
//  Copyright (c) 2015 Tyler Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

// These macros should only be used if you MUST know the interface orientation for the device itself, for example when displaying a new UIWindow.
// This should be very rare; generally you should only look at the immediate parent view's size (or "view orientation" using the category below).
#define StatusBarOrientationIsPortrait      UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])
#define StatusBarOrientationIsLandscape     UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])

typedef NS_ENUM(NSInteger, ViewOrientation) {
    ViewOrientationPortrait,
    ViewOrientationLandscape
};

@interface UIView (Orientation)

/** Returns the "orientation" of size. width > height is considered "landscape", otherwise "portrait" */
+ (ViewOrientation)viewOrientationForSize:(CGSize)size;

/** Returns the "orientation" of this view based on its size. width > height is considered "landscape", otherwise "portrait" */
- (ViewOrientation)viewOrientation;

/** Returns YES if this view's height >= width */
- (BOOL)isViewOrientationPortrait;

/** Returns YES if this view's width > height */
- (BOOL)isViewOrientationLandscape;

@end
