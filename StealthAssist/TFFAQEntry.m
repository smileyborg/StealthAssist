//
//  TFFAQEntry.m
//  StealthAssist
//
//  Created by Tyler Fox on 1/5/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "TFFAQEntry.h"

@implementation TFFAQEntry

+ (instancetype)faqEntryWithQuestion:(NSString *)question answer:(NSString *)answer
{
    TFFAQEntry *faqEntry = [[TFFAQEntry alloc] init];
    faqEntry.question = question;
    faqEntry.answer = answer;
    return faqEntry;
}

+ (NSArray *)allFAQEntries
{
    NSMutableArray *faqEntries = [NSMutableArray new];
    
    if ([TFAppUnlockManager sharedInstance].isTrial) {
        [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"What hardware is required to use StealthAssist?"
                                                        answer:@"StealthAssist requires the following hardware:\n1.  Valentine One radar detector with ESP (Extended Serial Protocol) - Check for the ESP logo on the front panel of the V1 below the Control Knob.\n2.  V1connection LE Bluetooth communicator accessory - Enables iOS device to connect to the V1 using Bluetooth LE.\n3.  iOS device with Bluetooth LE (Low Energy) - iPhone 4S or newer, iPad (3rd gen) or newer, iPad mini or newer, iPod touch (5th gen) or newer. Note that the iOS device must be GPS-enabled (all iPhone models, iPad models with cellular) to use the Auto Mute feature."]];
        NSString *speedString = [TFPreferences sharedInstance].isUsingMPH ? @"55 MPH" : @"88 KM/H";
        [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"What are the trial mode limitations, before unlocking the full version of the app?"
                                                        answer:[NSString stringWithFormat:@"The free trial mode is designed to provide you with an opportunity to test the app, successfully connect to your V1, and explore all the features available before you unlock the full version. All of the features in the app are available in trial mode, however the app will automatically disconnect from the V1 after 3 minutes of usage, or when traveling at speeds above %@. To remove the trial mode limitations, please unlock the full version of the app on the previous screen.", speedString]]];
        [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"I'm having trouble purchasing the full version unlock."
                                                        answer:@"Please go back to the previous screen, tap 'Email Support', and provide as much detail as possible about the problem you are having (including any error codes)."]];
        [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"I already purchased the full version, but the app is not unlocked."
                                                        answer:@"Please got back to the previous screen and tap 'Restore Previous Unlock Purchase'. If you encounter issues restoring your previously purchased app unlock, please go back to the previous screen, tap 'Email Support', and provide as much detail as possible about the problem you are having (including any error codes)."]];
    }
    
    [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"I'm having trouble connecting to my V1 radar detector."
                                                    answer:@"1.  Make sure the Valentine One is plugged in and powered on.\n2.  Make sure the V1connection LE Bluetooth module is connected to the V1's power adapter, and that the blue LED is flashing.\n3.  Make sure that Bluetooth is enabled on your iOS device (you should see the Bluetooth icon near the battery indicator at the top of the screen).\n4.  Sometimes the Bluetooth LE on your iOS device gets into a bad state. When this happens, StealthAssist may display 'Connecting to V1' on the main display for a while and will fail to connect, even as the Bluetooth icon in the iOS status bar illuminates to suggest that a device is connected. If this occurs, you must completely restart your iOS device (press and hold the Sleep/Wake button on the top of the device, drag the red slider, wait until it shuts off, and then power it back on and reopen StealthAssist)."]];
    [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"When I am driving below the auto mute speed and a bogey is first detected, why does my V1 beep once at full volume before muting?"
                                                    answer:@"This occurs because it takes a split second for StealthAssist to receive the notification of a new bogey from the V1 and send back the mute command. During this very short period of time, the V1 has already triggered the first audible alert. You can use this initial alert to your advantage so that even when auto muted, you'll know that the V1 has detected a bogey."]];
    [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"Will StealthAssist use my device's battery if I do not kill the app?"
                                                    answer:@"No, by default when the setting to allow StealthAssist to run in the background is enabled, StealthAssist will automatically enter Standby Mode after a few seconds if:\n   - your iOS device is unplugged from a power source and you background the app.\n   - the app is already running in the background and your iOS device becomes unplugged from a power source.\n   - StealthAssist loses connection with the V1 while running in the background.\nYou can change how long StealthAssist will run in the background while your iOS device is unplugged on the Settings screen. Even if you choose the 'No limit' setting, StealthAssist will always enter Standby Mode automatically if the connection to the V1 is lost while in the background. Don't forget, you can always enter Standby Mode manually from the control drawer at any time."]];
    [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"Why does StealthAssist disconnect from the V1 when the app enters the background?"
                                                    answer:@"First, make sure that you have not disabled the setting for StealthAssist to run in the background on the Settings screen. Next, make sure your iOS device is plugged in to a power source when you background StealthAssist. If you want to be able to run the app in the background unplugged, choose the 'Up to 30 min' or 'No limit' settings on the Settings screen. Finally, sometimes iOS will forget to allow StealthAssist to remain connected to the V1 over Bluetooth when it enters the background. To fix this, you should kill the app completely (double tap the Home button on your device, then slide the StealthAssist app upwards to kill it), then tap the StealthAssist icon on your home screen to relaunch the app."]];
    [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"How do background notifications work?"
                                                    answer:@"With background notifications enabled, when StealthAssist is running in the background (while using another app, or if the device's screen is off), a notification will be displayed when the first bogey is detected. (A background notification will not be displayed if the V1 is already alerting for at least one bogey and an additional new bogey is detected.) If the 'Show Priority Alert Frequency' setting is also enabled, the notification will include the frequency of the priority alert. Note that these notifications only apply to radar alerts; laser alerts will not generate a notification. Notifications will also be shown when StealthAssist connects to or disconnects from the V1. You can enable or disable background notifications from StealthAssist's Settings screen."]];
    [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"How does the alert sound on first bogey work?"
                                                    answer:@"With the 'Play Alert Sound on First Bogey' setting enabled, your iOS device will vibrate and play a short sound when the first bogey is detected, regardless of whether StealthAssist is backgrounded or not. The alert sound includes the bogey lock tone ('deet-deet') and one beep corresponding with the radar band of the first bogey. Laser alerts do not trigger the alert sound. The alert sound will only play if your device's Silent/Mute switch is off. The alert sound will play through the built-in speaker on your iOS device (or to headphones, if attached) using the current system volume setting. If you are not hearing this alert sound, make sure your iOS device is not silenced (ringer must be on) and raise the system volume using the volume buttons on the side of the device."]];
    [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"Why does my current speed always read 0 (zero)?"
                                                    answer:@"Your iOS device must have a GPS receiver in order to get speed data, and some iOS devices (e.g. Wi-Fi only devices like the iPod touch) do not have a GPS chip. If your device is GPS-enabled, you must grant StealthAssist permission to use your current location for it to be able to access your speed. To make sure that StealthAssist can access your location, tap the Home button on your device, go to the iOS Settings app, tap Privacy, tap Location Services, and then make sure that StealthAssist is turned on."]];
    [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"What is the priority alert?"
                                                    answer:@"The priority alert is the radar signal that has been identified by the Valentine One as posing the greatest threat. When there are multiple bogeys detected, the V1 indicates the priority alert by flashing the arrow & band indicators associated with its direction & frequency. With StealthAssist, you can display additional data about the priority alert, such as its exact frequency. Configure this and other related preferences on the Settings screen."]];
    [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"I have a feature request, comment, or other feedback."
                                                    answer:@"Please go back to the previous screen and tap 'Send Feedback' to get in touch."]];
    [faqEntries addObject:[TFFAQEntry faqEntryWithQuestion:@"I have a question not addressed here."
                                                    answer:@"Please go back to the previous screen and tap 'Email Support' to get your question answered."]];
    return faqEntries;
}

@end
