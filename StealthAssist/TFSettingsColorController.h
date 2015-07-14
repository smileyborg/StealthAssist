//
//  TFSettingsColorController.h
//  StealthAssist
//
//  Created by Tyler Fox on 3/30/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFTableViewController.h"

@interface TFSettingsColorController : TFTableViewController

// Stores the chosen tint color before changes are applied. (If this preference is set upon selection,
// parts of the UI will take on the new color, and parts won't!)
@property (nonatomic, strong) UIColor *chosenTintColor;

// This will be executed with the chosen tint color once it has been selected.
// This allows the presenting controller to store the selected color, to apply at a later time.
@property (nonatomic, copy) void(^tintColorSelectionBlock)(UIColor *tintColor);

@end
