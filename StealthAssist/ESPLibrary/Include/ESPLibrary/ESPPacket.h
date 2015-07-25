//
//  ESPPacket.h
//  Valentine
//
//  Created by Amadeus Consulting on 2/25/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to encapsulate an ESP Packet returned by the Valentine One.
 
 */

#import <Foundation/Foundation.h>
#import "PacketTypes.h"

@interface ESPPacket : NSObject

@property (nonatomic)NSMutableData *_data;
@property (nonatomic)BOOL isWholeData;

/** Call this method to intialize the ESPPacket with recieved data from the Valentine One.
 @param isWhole Whether the packet is complete or not.
 */
- (id) initWithData:(NSData*)data isWhole:(BOOL)whole;
/** Call this method to create a new ESPPacket.
 @param data The packet payload.
 @param index The index of the packet.
 @param count The total count of packets that make up the entire data.
 @param originator The origin identifier of the packet.
 @param dest The destination identifier of the packet.
 @param pi The packet type identifier.
 */
- (id) initWithData:(NSData*)data index:(int)index count:(int)count originator:(char)originator destination:(char)dest packetIdentifier:(PacketType)pi;

- (int) getPacketCount;
- (int) getPacketIndex;
-(PacketType)getPacketType;
-(Byte)getDestination;
-(Byte)getOrigin;
/** Call this method to retrieve the packet's payload.
 */
-(NSData*)getDataFromPacket;
/** Call this method to retrieve the packet's payload if the connected Valentine One does not use a checksum.
 */
-(NSData*)getDataFromPacketNoCheckSum;
/** Call this method to add data to the packet's payload.
 @param data The data to be appeneded to the payload.
 */
-(void)appendDataToEmptyPacket:(NSData*)data;
/** Call this method to return the packet as a data object.
 */
-(NSData*)getPacketAsData;
/** Call this method to retrieve the packet as a binary data string.
 */
-(NSString*)toBinaryString;

@end
