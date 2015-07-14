//
//  TFAppDelegate.h
//  StealthAssist
//
//  Created by Tyler Fox on 12/11/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFAppDelegate : UIResponder <UIApplicationDelegate>

+ (instancetype)sharedInstance;

@property (strong, nonatomic) UIWindow *window;

@end
