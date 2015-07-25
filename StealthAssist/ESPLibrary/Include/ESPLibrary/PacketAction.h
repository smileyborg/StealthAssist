//
//  PacketAction.h
//  Valentine
//
//  Created by Amadeus Consulting on 2/27/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to allow you to interact with the Valentine One hardware. It handles the routing of recieved packets to their appropriate classes for processing.
 
 */

#import <Foundation/Foundation.h>
#import "ESPPacket.h"
#import "AlertOutput.h"
#import "DisplayAndAudio.h"
#import "Miscellaneous.h"
#import "SavvySpecific.h"
#import "UserSetupOptions.h"
#import "CustomSweep.h"
#import "DeviceInformation.h"

@interface PacketAction : NSObject

@property (nonatomic) AlertOutput* AO;
@property (nonatomic) DisplayAndAudio* DA;
@property (nonatomic) Miscellaneous* MS;
@property (nonatomic) SavvySpecific* SS;
@property (nonatomic) UserSetupOptions* USO;
@property (nonatomic) CustomSweep* CS;
@property (nonatomic) DeviceInformation* DI;
@property (nonatomic, assign) id<AlertOutProtocol> AlertOutDelegate;
@property (nonatomic, assign) id<InfoDisplayProtocol> InfoDisplayDelegate;
@property (nonatomic, assign) id<SavvyProtocol> SavvyDelegate;
@property (nonatomic, assign) id<UserSetupOptionsProtocol> UserSetupOptionsDelegate;
@property (nonatomic, assign) id<CustomSweepProtocol> CustomSweepDelegate;
@property (nonatomic, assign) id<MiscellaneousPacketProtocol> MiscellaneousPacketDelegate;
@property (nonatomic, assign) id<DeviceInformationProtocol> DeviceInformationDelegate;


/** This returns the signleton instance that should be used to set the delegates for the Packet Action classes.
 
 */
+ (PacketAction*)sharedInstance;

-(void)actOnReceivedPacket:(ESPPacket*)currentPacket;
@end
