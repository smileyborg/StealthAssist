//
//  TFColorSwatchView.h
//  StealthAssist
//
//  Created by Tyler Fox on 3/30/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFColorSwatchView : UIView

+ (instancetype)colorSwatchWithColor:(UIColor *)color;

@property (nonatomic, strong) UIColor *swatchColor;

@property (nonatomic, assign) BOOL isSelected;

@end
