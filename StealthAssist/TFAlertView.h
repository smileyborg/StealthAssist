//
//  TFAlertView.h
//  StealthAssist
//
//  Created by Tyler Fox on 10/19/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFAlertView : NSObject

+ (UIAlertController *)alertWithTitle:(NSString *)title
                              message:(NSString *)message
                    cancelButtonTitle:(NSString *)cancelButtonTitle;

@end
