//
//  ValentineCommunicationService.h
//  Valentine
//
//  Created by Amadeus Consulting on 2/25/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to encapsulate the communication between the V1Connection and the iOS hardware.
 
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ESPPacketCollection.h"
#import "PacketAction.h"


/****************************************************************************/
/*						Service Characteristics								*/
/****************************************************************************/
extern NSString *kV1ConnectionLEServiceUUIDString;
extern NSString *kV1outClientInShortCharacteristicUUIDString;
extern NSString *kV1outClientInLongCharacteristicUUIDString;
extern NSString *kClientOutV1inShortCharacteristicUUIDString;
extern NSString *kClientOutV1inLongCharacteristicUUIDString;


@protocol V1ComProtocol <NSObject>
@optional
/** This method will return a recieved ESPPackt to any class that is assigned as the delegate.
 
 */
- (void) didRecieveShortChar:(ESPPacket *)packet;
/** This method will be called on any class that is assigned as the delegate when the device is connected.
 
 */
- (void) didConnectToDevice;
//- (void) didRecieveLongChar:(ValentineCommunicationService *)service;

@end

@interface ValentineCommunicationService : NSObject

/** This method will initialize the class with a periperal and a delegate.
 
 */
- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<V1ComProtocol>)controller;
/** This method will reset the service's peripheral to nil.
 
 */
- (void) reset;
/** This method will start the service and recognize the apropriate characteristics from the peripheral.
 
 */
- (void) start;

/** This method will write the a packet to the ESP bus.
 @param espPacket The packet to be transmitted.
 */
- (void) writeMessage:(ESPPacket *)espPacket;

// Not implemented in code
//- (void)enteredBackground;
//- (void)enteredForeground;

@property (readonly) CBPeripheral *peripheral;
@property (nonatomic) ESPPacketCollection *packets;
@property (nonatomic) char destination;
@property (nonatomic) char origin;
@property (nonatomic) NSMutableDictionary *lastPacketOfType;
@property (atomic) bool isLegacy;

@property (nonatomic) bool kClientOutV1inLongCharacteristicUUIDStringFound;
@property (nonatomic) bool kClientOutV1inShortCharacteristicUUIDStringFound;
@property (nonatomic) bool kV1outClientInLongCharacteristicUUIDStringFound;
@property (nonatomic) bool kV1outClientInShortCharacteristicUUIDStringFound;


@end
