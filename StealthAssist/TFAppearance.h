//
//  TFAppearance.h
//  StealthAssist
//
//  Created by Tyler Fox on 12/27/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import "TFPreferences.h"
#import "UIColor+LighterAndDarker.h"

#ifndef TF_APPEARANCE_H
#define TF_APPEARANCE_H

#pragma mark Fonts

#define DEVICE_HAS_TALL_SCREEN ([[UIScreen mainScreen] bounds].size.height > 480.0f)

#define kStealthAssistFont      @"DIN Alternate"

#pragma mark Colors

#define kAppTintColor           [TFPreferences sharedInstance].appTintColor
#define kAppTintColorLighter    [kAppTintColor lighterColor]
#define kAppTintColorDarker     [kAppTintColor darkerColor]

#define kVeryDarkGray           [UIColor colorWithWhite:0.1f alpha:1.0f]
#define kOverlayColor           [UIColor colorWithWhite:0.0f alpha:0.8f]
#define kWhiteOverlayColor      [UIColor colorWithWhite:1.0f alpha:0.9f]

#endif /* TF_APPEARANCE_H */
