//
//  TFChooseColorController.h
//  StealthAssist
//
//  Created by Tyler Fox on 3/30/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFTableViewController.h"

typedef void(^TFChooseColorBlock)(UIColor *chosenColor);


@interface TFChooseColorController : TFTableViewController

// Used to inject into the "___ Color" string for the title
@property (nonatomic, strong) NSString *titlePrefix;

// A swatch for each color is displayed in the table view
@property (nonatomic, strong) NSArray *colors;

// The index of the color in the |colors| array that has been selected. Defaults to NSNotFound.
@property (nonatomic, assign) NSInteger selectedColorIndex;

// This is executed when a swatch is picked. The associated color is passed in to the block.
@property (nonatomic, copy) TFChooseColorBlock block;

@end
