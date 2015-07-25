//
//  AlertOutput.h
//  ESPLibrary
//
//  Created by Amadeus Consulting on 3/13/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to allow you to interact with the Valentine One hardware. It centers around processing alerts received from the Valentine One.
 
 */

#import <Foundation/Foundation.h>
#import "ESPPacket.h"
#import "AlertCollection.h"

@protocol AlertOutProtocol <NSObject>
/** This method will be called and return the Alert Table to any class assigned as the delegate.
 
 */
- (void) didRecieveAlertTable:(AlertCollection *)collection;
@end

@interface AlertOutput : NSObject


-(id)initWithDelegate:(id<AlertOutProtocol>)delegate;
-(void)respAlertData:(ESPPacket*)recievedPacket;
-(ESPPacket*)reqStartAlertData:(char)dest Origin:(char)origin;
-(ESPPacket*)reqStopAlertData:(char)dest Origin:(char)origin;
-(AlertCollection*)getLastAlert;
-(void)setDelegate:(id<AlertOutProtocol>)delegate;

@end
