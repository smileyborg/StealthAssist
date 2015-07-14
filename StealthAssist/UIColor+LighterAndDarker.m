//
//  UIColor+LighterAndDarker.m
//  StealthAssist
//
//  Created by Tyler Fox on 1/12/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "UIColor+LighterAndDarker.h"

#define kAdjustmentPercentage       0.2f

@implementation UIColor (LighterAndDarker)

- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:MIN(b * (1.0f + kAdjustmentPercentage), 1.0)
                               alpha:a];
    }
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * (1.0f - kAdjustmentPercentage)
                               alpha:a];
    }
    return nil;
}

@end
