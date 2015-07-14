//
//  TFAppDelegate.m
//  StealthAssist
//
//  Created by Tyler Fox on 12/11/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import "TFAppDelegate.h"
#import "TFMainDisplayViewController.h"
#import "Crittercism.h"

static TFAppDelegate *_static_sharedInstance = nil;

@implementation TFAppDelegate

+ (instancetype)sharedInstance
{
    return _static_sharedInstance;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _static_sharedInstance = self;
    
#if DEBUG
    /* Initialize third party libs with DEBUG tokens */
#if !TARGET_IPHONE_SIMULATOR
    // Don't start up Crittercism in the sim while in Debug because it gobbles stack traces
//    [Crittercism enableWithAppID:@""];
#endif /* !TARGET_IPHONE_SIMULATOR */
#else
    /* Initialize third party libs with RELEASE tokens */
//    [Crittercism enableWithAppID:@""];
#endif /* DEBUG */
    
    // Initialize the analytics libraries
    [TFAnalytics initializeLibraries];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[TFMainDisplayViewController alloc] init];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kStealthAssistFont size:20.0f]}];
    [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setTintColor:[UIColor infoBlueColor]];
    self.window.tintColor = kAppTintColorDarker;
    
    [application setIdleTimerDisabled:YES];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // This will clear any accumulated background notifications in Notification Center
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

// Simple category on UINavigationController to allow presented navigation controllers to rotate correctly
// based on the topViewController's supportedInterfaceOrientations. (Otherwise upside down doesn't work.)
@implementation UINavigationController (Autorotation)

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

@end
