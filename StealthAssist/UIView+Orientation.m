//
//  UIView+Orientation.m
//  StealthAssist
//
//  Created by Tyler Fox on 7/25/15.
//  Copyright (c) 2015 Tyler Fox. All rights reserved.
//

#import "UIView+Orientation.h"

@implementation UIView (Orientation)

+ (ViewOrientation)viewOrientationForSize:(CGSize)size {
    return (size.width > size.height) ? ViewOrientationLandscape : ViewOrientationPortrait;
}

- (ViewOrientation)viewOrientation {
    return [[self class] viewOrientationForSize:self.bounds.size];
}

- (BOOL)isViewOrientationPortrait {
    return [self viewOrientation] == ViewOrientationPortrait;
}

- (BOOL)isViewOrientationLandscape {
    return [self viewOrientation] == ViewOrientationLandscape;
}

@end
