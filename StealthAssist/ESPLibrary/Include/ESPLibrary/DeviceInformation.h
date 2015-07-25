//
//  DeviceInformation.h
//  Valentine
//
//  Created by Amadeus Consulting on 2/27/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ESPPacket.h"

@protocol DeviceInformationProtocol <NSObject>
@optional
/** This method will be called and return the serial number and origin to any class assigned as the delegate.
 
 */
- (void) DidRecieveSerialNumber:(NSString*)serial withOrigin:(char)origin;
/** This method will be called and return the firmware number and origin to any class assigned as the delegate.
 
 */
- (void) DidRecieveFirmwareVersion:(NSString*)firmware withOrigin:(char)origin;
@end

@interface DeviceInformation : NSObject

-(id)initWithDelegate:(id<DeviceInformationProtocol>)delegate;
-(void)respVersion:(ESPPacket*)recievedPacket;
-(ESPPacket*)reqVersionwithDest:(char)dest Origin:(char)origin;
-(void)respSerialNumber:(ESPPacket*)recievedPacket;
-(ESPPacket*)reqSerialwithDest:(char)dest Origin:(char)origin;
-(void)setDelegate:(id<DeviceInformationProtocol>)delegate;


@end
