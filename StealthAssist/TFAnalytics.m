//
//  TFAnalytics.m
//  StealthAssist
//
//  Created by Tyler Fox on 2/15/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "TFAnalytics.h"
#import "Flurry.h"
#import <Mixpanel/Mixpanel.h>

@implementation TFAnalytics

+ (void)initializeLibraries
{
    Mixpanel *mixpanel = nil;
    
#if DEBUG
    /* Initialize third party analytics libs with DEBUG tokens */
    
//    [Flurry startSession:@""];
    
//    mixpanel = [Mixpanel sharedInstanceWithToken:@""];
#else
    /* Initialize third party analytics libs with RELEASE tokens */
        
//    [Flurry startSession:@""];
    
//    mixpanel = [Mixpanel sharedInstanceWithToken:@""];
#endif /* DEBUG */
    
    mixpanel.showNetworkActivityIndicator = NO;
}

+ (void)track:(NSString *)eventName
{
    [Flurry logEvent:eventName];
    [[Mixpanel sharedInstance] track:eventName];
}

+ (void)track:(NSString *)eventName withData:(NSDictionary *)data
{
    [Flurry logEvent:eventName withParameters:data];
    [[Mixpanel sharedInstance] track:eventName properties:data];
}

+ (void)trackStart:(NSString *)eventName withData:(NSDictionary *)data
{
    [Flurry logEvent:eventName withParameters:data timed:YES];
    [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"START %@", eventName] properties:data];
}

+ (void)trackEnd:(NSString *)eventName withData:(NSDictionary *)data
{
    [Flurry endTimedEvent:eventName withParameters:data];
    [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"END %@", eventName] properties:data];
}

@end
