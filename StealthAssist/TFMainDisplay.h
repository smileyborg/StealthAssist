//
//  TFMainDisplay.h
//  StealthAssist
//
//  Created by Tyler Fox on 12/31/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFMainDisplay : UIView

@property (nonatomic, assign) TFV1Mode mode;
@property (nonatomic, assign) NSInteger bogeyCount;
@property (nonatomic, assign) CGFloat signalStrength; // 0.0f to 1.0f
@property (nonatomic, assign) NSInteger priorityAlertFrequency; // in MHz
@property (nonatomic, assign) TFDisplayState aheadArrowState;
@property (nonatomic, assign) TFDisplayState sideArrowState;
@property (nonatomic, assign) TFDisplayState behindArrowState;
@property (nonatomic, assign) TFDisplayState laserState;
@property (nonatomic, assign) TFDisplayState kaState;
@property (nonatomic, assign) TFDisplayState kState;
@property (nonatomic, assign) TFDisplayState xState;

// View frames exposed for tutorial
@property (nonatomic, readonly) CGRect leftHUDRect;
@property (nonatomic, readonly) CGRect centerHUDRect;
@property (nonatomic, readonly) CGRect rightHUDRect;

// View exposed for constraints
@property (nonatomic, readonly) UIView *mainHUDBorder;

+ (instancetype)mainDisplay;


@end
