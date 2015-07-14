//
//  TFSignalStrengthView.m
//  StealthAssist
//
//  Created by Tyler Fox on 7/26/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "TFSignalStrengthView.h"

#define kMaxNumberOfBars        8

@implementation TFSignalStrengthView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setNumberOfBars:(NSInteger)numberOfBars
{
    _numberOfBars = MIN(MAX(numberOfBars, 0), kMaxNumberOfBars);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextClearRect(c, rect);
    
    CGFloat spacingRatio = 0.5; // how tall the spacing between bars is compared to the height of each bar
    
    CGFloat left = CGRectGetMinX(rect);
    CGFloat width = CGRectGetWidth(rect);
    CGFloat startY = CGRectGetMaxY(rect);
    CGFloat height = CGRectGetHeight(rect) / (kMaxNumberOfBars + (kMaxNumberOfBars - 1) * spacingRatio);
    
    CGFloat minimumAlpha = 0.5;
    UIColor *fillColor = [kAppTintColor colorWithAlphaComponent:minimumAlpha + ((1.0 - minimumAlpha) * ((self.numberOfBars * 1.0) / kMaxNumberOfBars))];
    CGContextSetFillColorWithColor(c, fillColor.CGColor);
    
    for (NSUInteger i = 0; i < self.numberOfBars; i++) {
        startY -= height;
        CGContextFillRect(c, CGRectMake(left, startY, width, height));
        startY -= height * spacingRatio;
    }
}

@end
