//
//  TFMainDisplayViewController.h
//  StealthAssist
//
//  Created by Tyler Fox on 12/11/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BTDiscovery.h"
#import "TFControlDrawer.h"
#import "WSCoachMarksView.h"

@interface TFMainDisplayViewController : UIViewController <CLLocationManagerDelegate, CBCentralManagerDelegate, V1ComProtocol, BTDiscoveryDelegate, BTDeviceNotFoundProtocol, InfoDisplayProtocol, AlertOutProtocol, DeviceInformationProtocol, TFControlDrawerDelegate>

@end
