//
//  Miscellaneous.h
//  ESPLibrary
//
//  Created by Amadeus Consulting on 3/17/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to allow you to interact with the Valentine One hardware.
 
 */

#import <Foundation/Foundation.h>
#import "ESPPacket.h"

@protocol MiscellaneousPacketProtocol <NSObject>
@optional
/** This method will be called and return the ESPPacket containing the data recieved acknowledgement to any class assigned as the delegate.
 
 */
- (void) DidRecieveDataAcknowledgement:(ESPPacket *)ack;
/** This method will be called and return the ESPPacket containing the unsupported packet id to any class assigned as the delegate.
 
 */
- (void) UnsupportedPacketReturned:(ESPPacket *)packet;
/** This method will be called and return the ESPPacket containing the id of the packet that was not processed to any class assigned as the delegate.
 
 */
- (void) RequestNotProcessed:(ESPPacket *)packet;
/** This method will be called and return a NSData object containing the ids of the packets pending processing to any class assigned as the delegate.
 
 */
- (void) V1Busy:(NSData *)packetsToBeProcessed;
/** This method will be called and return the ESPPacket containing the id of the packet which produced a data error to any class assigned as the delegate.
 
 */
- (void) DataErrorPacketReturned:(ESPPacket *)packet;
/** This method will be called and return the Battery Voltage to any class assigned as the delegate.
 
 */
- (void) BatteryVoltageReturned:(double)voltage;
@end

@interface Miscellaneous : NSObject

-(id)initWithDelegate:(id<MiscellaneousPacketProtocol>)delegate;
-(void)respDataRecieved:(ESPPacket*)recievedPacket;
-(ESPPacket*)reqBatteryVoltage:(char)dest Origin:(char)origin;
-(void)respBatteryVoltage:(ESPPacket*)recievedPacket;
-(void)respUnsupportedPacket:(ESPPacket*)recievedPacket;
-(void)respRequestNotProcessed:(ESPPacket*)recievedPacket;
-(void)infV1Busy:(ESPPacket*)recievedPacket;
-(void)respDataError:(ESPPacket*)recievedPacket;
-(ESPPacket*)SENDBADPACKET:(char)dest Origin:(char)origin;
-(void)setDelegate:(id<MiscellaneousPacketProtocol>)delegate;

@property (nonatomic) NSMutableArray *pendingPacketIDs;

@end
