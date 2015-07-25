//
//  UserSetupOptions.h
//  Valentine
//
//  Created by Amadeus Consulting on 3/4/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to allow you to interact with the Valentine One hardware. It centers around the user setup options.
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ESPPacket.h"
#import "UserBytes.h"

@protocol UserSetupOptionsProtocol <NSObject>
@optional
/** This method will be called and the userBytes will be returned to any class assigned as the delegate.
 
 */
- (void) didRecieveUserBytes:(UserBytes*)userBytes;
@end

@interface UserSetupOptions : NSObject

@property (nonatomic) UserBytes *mostRecentBytes;

-(id)initWithDelegate:(id<UserSetupOptionsProtocol>)delegate;
-(void)respUserBytes:(ESPPacket*)recievedPacket;
-(ESPPacket*)reqUserBytes:(char)dest Origin:(char)origin;
-(ESPPacket*)reqWriteUserBytes:(UserBytes*)bytes Dest:(char)dest Origin:(char)origin;
-(ESPPacket*)reqFactoryDefaults:(char)dest Origin:(char)origin;
-(void)setDelegate:(id<UserSetupOptionsProtocol>)delegate;

@end
