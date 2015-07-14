//
//  ESPPacketCollection.h
//  Valentine
//
//  Created by Amadeus Consulting on 2/25/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to encapsulate a collection of ESP Packets returned by the Valentine One.
 
 */

#import <Foundation/Foundation.h>
#import "ESPPacket.h"

@interface ESPPacketCollection : NSObject

@property (nonatomic) NSMutableArray *packets;
@property (nonatomic) int totalPackets;

/** Call this method to initialize the collection with a packet.
 */
- (id) initWithPacket:(ESPPacket*)packet;
/** Call this method to add a packet to the collection.
 */
- (void) addPacket:(ESPPacket*)packet;
/** Call this method to determine if the collection is complete.
 */
- (bool) isComplete;
/** Call this method to return a complete packet to send to the Valentine One.
 */
- (ESPPacket*) getCompletedPacket;
/** Call this method to construct a packet collection from a data object.
 */
- (void)constructPacketsFromData:(NSData*)data dest:(char)dest type:(PacketType)pt;

@end
