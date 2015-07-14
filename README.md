# StealthAssist
This repository contains the complete source code for **StealthAssist**, [available on the iOS App Store](https://itunes.apple.com/us/app/stealthassist-for-v1/id792567084?mt=8). StealthAssist wirelessly connects your iPhone to the [Valentine One](http://www.valentine1.com) radar detector using Bluetooth LE. For full functionality, you need a Valentine One with [ESP](http://www.valentine1.com/V1Info/ESP/) as well as the [V1connection LE](http://www.valentine1.com/v1info/v1connection/ios/) accessory.

## Background
StealthAssist was designed and built by entirely by me (Tyler Fox) as a side project. The current version of the app (v1.3) is extremely stable, has never crashed in production, and has no known bugs. With that said, some parts of the code are in need of significant cleanup and refactoring -- `TFMainDisplayViewController` is a fantastic example of MVC *(Massive View Controller)*. I generally chose to prioritize new features and functionality over working on tech debt in my limited spare time, as revisiting existing proven code would incur even more testing overhead. (I test StealthAssist releases extensively using K and Ka band radar guns at home, as well as out in the field with real radar sources.) I started a significant rewrite of the app in Swift, but haven't had enough time to focus on that recently and there are many hours of development and testing left before that work is production-ready. I've decided to open source the current project in the meantime, and I've also made the Full App Unlock In-App Purchase available for free.

## Getting Started
StealthAssist uses CocoaPods to manage most third-party dependencies. Therefore, you must open the `StealthAssist.xcworkspace` file in Xcode to view the complete project, and build & run the app.

The CocoaPods used by this app have been checked in to the repository (in the `Pods/` directory), so you can simply open the above workspace in Xcode and immediately build and run. You do not need to run `pod install` after cloning the repository.

### Crash Reporting & Analytics
StealthAssist uses [Crittercism](http://www.crittercism.com) to collect crash reports in the field. You need to provide your own API keys in the `TFAppDelegate.m` file for this to work.

StealthAssist uses [Flurry](http://www.flurry.com) and [Mixpanel](http://mixpanel.com) to collect anonymous analytics. You need to provide your own API keys in the `TFAnalytics.m` file for these to work.

## App Store Description
### Features
- Auto Mute the V1 when driving below a set speed (requires GPS)
- Tap anywhere on the display to mute the V1, double tap to unmute
- View the frequency (in GHz) of the priority alert
- Highly readable display presents critical information at a glance
- Customize the display with a wide variety of colors, including a color per band
- Fully operational in the background while using other apps
- Receive notifications for new threats while in the background (optional)
- Play an alert sound & vibration for first detected bogey (optional)
- Optimized for performance, including fast connection on app launch
- Automatic standby mode conserves power when iOS device is unplugged or V1 is disconnected
- Advanced settings: black out the V1 display, always unmute for Ka priority alerts
- Supports portrait, landscape, and upside-down display orientations

StealthAssist for V1 is the ultimate driver's companion app. If you're serious about maintaining peak situational awareness on the road, you need StealthAssist connected to your Valentine One.

With Auto Mute, StealthAssist reduces driver distraction by silencing low risk alerts below the speed threshold you set. It works just like the SAVVY module, but wirelessly. When driving above the speed threshold, a single tap on the display will mute the V1. StealthAssist offers a clear and sharp picture of your surroundings, with the option to restore alerts to full volume by double tapping on the display. The app can additionally display the precise frequency of the radar signal posing the greatest threat, to aid in quick identification of new bogeys. StealthAssist allows you to keep your focus where it matters -- on the road, instead of on annoying beeps that pose no threat.

StealthAssist runs in the background, continuing to communicate with your V1 in realtime. That means you can switch to any other app on your iOS device, and the Auto Mute feature will continue to intelligently mute and unmute the V1 based on your current speed. Optional background notifications will display new radar alerts at the top of your screen while using other apps, and tapping one of these notifications takes you straight back to StealthAssist. The app includes other advanced features such as highly customizable display colors, the ability to assign each band a unique color, an option to black out the V1 display and operate in concealed mode, and more. Use the alert sound on first bogey setting to monitor your V1 over headphones -- an especially useful feature for motorcycles, where the V1's audio alerts aren't easily heard. Since StealthAssist works in any orientation and communicates wirelessly with your V1, your iOS device can be mounted nearly anywhere in your vehicle.

Once you drive with StealthAssist, you realize you can't afford to drive without it.

StealthAssist for V1 uses Bluetooth LE to connect to the V1connection LE accessory (sold separately) for your V1. It is highly recommended that your iOS device is plugged in to a power source while StealthAssist is running to prevent battery drain, due to the usage of the device's GPS for the Auto Mute feature.

### Hardware Requirements
- REQUIRES iOS device with Bluetooth LE: iPhone 4S or newer, iPad (3rd gen) or newer, iPad mini or newer, iPod touch (5th gen) or newer.
- REQUIRES Valentine One radar detector with ESP.
- REQUIRES V1connection LE Bluetooth accessory.
- iOS device must be GPS-enabled (all iPhone models, iPad models with cellular) for full functionality.

## License & Legal
The StealthAssist source code, assets, and other project resources are provided under the [MIT license](LICENSE). Third-party libraries in this repository, including CocoaPods, have their own license information (and are not necessarily provided under the MIT license).

You are welcome to modify this project and distribute it however you like within the terms of the project's license and the licenses of all third-party components. (Yes, you may submit it to the App Store and even put the app up for sale if you wish.)

StealthAssist works in connection with the Valentine One ESP Serial Protocol. StealthAssist is not associated with Valentine Research. The Valentine One, V1connection LE, SAVVY, and related are trademarks or registered trademarks of Valentine Research.
