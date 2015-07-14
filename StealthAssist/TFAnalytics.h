//
//  TFAnalytics.h
//  StealthAssist
//
//  Created by Tyler Fox on 2/15/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 An adapter that consolidates multiple analytics SDK APIs into a single API.
 */
@interface TFAnalytics : NSObject

// Call from the app delegate's application:didFinishLaunchingWithOptions:
// Initializes the third party analytics libraries with the appropriate token, depending
// on the scheme (Debug or Release) and the target (iPhone Simulator or device)
+ (void)initializeLibraries;

// Track an event
+ (void)track:(NSString *)eventName;

// Track an event, with a dictionary of arbitrary string key-value pairs
+ (void)track:(NSString *)eventName withData:(NSDictionary *)data;

// Track the start of a timed event, with a dictionary of arbitrary string key-value pairs
+ (void)trackStart:(NSString *)eventName withData:(NSDictionary *)data;

// Track the end of a timed event, with a dictionary of arbitrary string key-value pairs
+ (void)trackEnd:(NSString *)eventName withData:(NSDictionary *)data;

@end
