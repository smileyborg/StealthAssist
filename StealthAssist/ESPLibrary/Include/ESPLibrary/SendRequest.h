//
//  SendRequest.h
//  Valentine
//
//  Created by Amadeus Consulting on 2/27/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to easily allow you to make a request to the Valentine One. Simply create an instance and call your desired function.
 
 */

#import <Foundation/Foundation.h>
#import "ESPPacket.h"
#import "UserBytes.h"

@interface SendRequest : NSObject


-(void)reqVersion:(char)destination;
-(void)reqSerial:(char)destination;
-(void)reqUserBytes;
-(void)reqWriteUserBytes:(UserBytes*)userBytes;
-(void)reqFactoryDefaultDestination:(char)dest;
-(void)reqStartAlertData;
-(void)reqStopAlertData;
-(void)reqMuteOn;
-(void)reqMuteOff;
-(void)reqChangeMode:(int)mode;
-(void)reqTurnOffMainDispay;
-(void)reqTurnOnMainDispay;
-(void)reqBatteryVoltage;
-(void)SENDBADPACKET;
-(void)reqSavvyStatus;
-(void)reqVehicleSpeed;
-(void)reqOverrideThumbwheelMPH:(int)mph;
-(void)reqOverrideThumbwheelKPH:(int)kph;
-(void)reqSetSavvyUnmuteEnable:(bool)mute;

/**
 @param index The index of the sweep definition to be written.
 @param ue The upper edge of the sweep
 @param le The lower edge of the sweep
 @param commit Set this to true if it is the last sweep definition to be sent.
 */
-(void)reqWriteSweepDefinitionIndex:(int)index UpperEdge:(uint16_t)ue LowerEdge:(uint16_t)le Commit:(bool)commit;
-(void)reqAllSweepDefinitions;
-(void)reqSetSweepsToDefault;
-(void)reqMaxSweepIndex;
-(void)reqSweepSections;

@end
