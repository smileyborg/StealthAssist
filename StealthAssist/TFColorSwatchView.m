//
//  TFColorSwatchView.m
//  StealthAssist
//
//  Created by Tyler Fox on 3/30/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "TFColorSwatchView.h"

#define kColorSwatchCornerRadius            8.0
#define kColorSwatchBorderWidth             1.0
#define kColorSwatchBorderWidthSelected     4.0


@implementation TFColorSwatchView

+ (instancetype)colorSwatchWithColor:(UIColor *)color
{
    TFColorSwatchView *colorSwatch = [TFColorSwatchView newAutoLayoutView];
    [colorSwatch setup];
    colorSwatch.swatchColor = color;
    return colorSwatch;
}

- (void)setup
{
    self.layer.cornerRadius = kColorSwatchCornerRadius;
    self.layer.borderWidth = self.isSelected ? kColorSwatchBorderWidthSelected : kColorSwatchBorderWidth;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)setSwatchColor:(UIColor *)swatchColor
{
    _swatchColor = swatchColor;
    
    self.backgroundColor = swatchColor;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    self.layer.borderWidth = isSelected ? kColorSwatchBorderWidthSelected : kColorSwatchBorderWidth;
}

@end
