//
//  DisplayAndAudio.h
//  ESPLibrary
//
//  Created by Amadeus Consulting on 3/14/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to allow you to interact with the Valentine One hardware. It centers around the Display and Audio functionality.
 
 */

#import <Foundation/Foundation.h>
#import "ESPPacket.h"
#import "DisplayData.h"

@protocol InfoDisplayProtocol <NSObject>
/** This method will be called and the displayData will be returned to any class assigned as the delegate.
 
 */
- (void) didRecieveDisplayData:(DisplayData *)displayData;
@end

@interface DisplayAndAudio : NSObject

-(id)initWithDelegate:(id<InfoDisplayProtocol>)delegate;

-(void)infDisplayData:(ESPPacket*)recievedPacket;

-(ESPPacket*)reqTurnOffMainDisplay:(char)dest Origin:(char)origin;
-(ESPPacket*)reqTurnOnMainDisplay:(char)dest Origin:(char)origin;
-(ESPPacket*)reqMuteOn:(char)dest Origin:(char)origin;
-(ESPPacket*)reqMuteOff:(char)dest Origin:(char)origin;
-(ESPPacket*)reqChangeMode:(int)mode Destination:(char)dest Origin:(char)origin;
-(void)setDelegate:(id<InfoDisplayProtocol>)delegate;

@property bool hasLaser;
@property bool muted;
@property bool holdoff;
@property long lastMute;
@property int displayDataWithoutBusy;

@end
