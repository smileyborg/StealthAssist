//
//  TFAlertView.m
//  StealthAssist
//
//  Created by Tyler Fox on 10/19/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "TFAlertView.h"

@implementation TFAlertView

+ (UIAlertController *)alertWithTitle:(NSString *)title
                              message:(NSString *)message
                    cancelButtonTitle:(NSString *)cancelButtonTitle
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:nil]];
    return alert;
}

@end
