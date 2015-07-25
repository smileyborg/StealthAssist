//
//  SavvySpecific.h
//  ESPLibrary
//
//  Created by Amadeus Consulting on 3/19/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to allow you to interact with the Savvy hardware. You can request information from the Savvy, or write settings to it.
 
 */

#import <Foundation/Foundation.h>
#import "ESPPacket.h"
#import "SavvyStatus.h"

@protocol SavvyProtocol <NSObject>
@optional
/** This method will be called and the Savvy Status will be returned to any class assigned as the delegate.
 
 */
- (void) didRecieveSavvyStatus:(SavvyStatus *)savvyStatus;
/** This method will be called and the vehicleSpeed will be returned to any class assigned as the delegate.
 
 */
- (void) didRecieveVehicleSpeed:(uint8_t)vehicleSpeed;
@end

@interface SavvySpecific : NSObject

-(id)initWithDelegate:(id<SavvyProtocol>)delegate;
-(void)respSavvyStatus:(ESPPacket*)recievedPacket;
-(ESPPacket*)reqSavvyStatus:(char)dest Origin:(char)origin;
-(void)respVehicleSpeed:(ESPPacket*)recievedPacket;
-(ESPPacket*)reqVehicleSpeed:(char)dest Origin:(char)origin;
-(ESPPacket*)reqOverrideThumbwheel:(char)dest Origin:(char)origin SpeedInKPH:(uint8_t)speed;
-(ESPPacket*)reqSetSavvyUnmuteEnable:(char)dest Origin:(char)origin Mute:(bool)mute;
-(void)setDelegate:(id<SavvyProtocol>)delegate;

@property (nonatomic) SavvyStatus *mostRecentStatus;
@property (nonatomic) uint8_t mostRecentSpeed;

@end
