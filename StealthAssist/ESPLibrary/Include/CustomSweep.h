//
//  CustomSweep.h
//  ESPLibrary
//
//  Created by Amadeus Consulting on 3/20/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to allow you to interact with the Valentine One hardware. It centers around managing custom sweeps.
 
 */

#import <Foundation/Foundation.h>
#import "ESPPacket.h"
#import "CustomSweepObject.h"

@protocol CustomSweepProtocol <NSObject>
@optional
/** This method will be called and return the sweep sections to any class assigned as the delegate.
 
 */
-(void)didRecieveSweepSections:(NSArray*)returnedSections;
/** This method will be called and return the max sweep index to any class assigned as the delegate.
 
 */
-(void)didRecieveMaxSweepIndex:(int)index;
/** This method will be called and return the sweep definition to any class assigned as the delegate.
 
 */
-(void)didRecieveSweepDefinition:(CustomSweepObject*)csd;

/** This method will be called and return the success of a sweep definition writing to any class assigned as the delegate.
 
 */
-(void)didRecieveSweepWriteResult:(int)errIndex;
@end

@interface CustomSweep : NSObject

@property (nonatomic) NSMutableArray *sweepSections;


-(id)initWithDelegate:(id<CustomSweepProtocol>)delegate;
-(ESPPacket*)reqWriteSweepDefinition:(char)dest Origin:(char)origin Index:(int)index UpperEdge:(uint16_t)ue LowerEdge:(uint16_t)le Commit:(bool)commit;
-(ESPPacket*)reqAllSweepDefinitions:(char)dest Origin:(char)origin;
-(void)respSweepDefinition:(ESPPacket*)recievedPacket;
-(ESPPacket*)reqSetSweepsToDefault:(char)dest Origin:(char)origin;
-(ESPPacket*)reqMaxSweepIndex:(char)dest Origin:(char)origin;
-(void)respMaxSweepIndex:(ESPPacket*)recievedPacket;
-(void)respSweepWriteResult:(ESPPacket*)recievedPacket;
-(ESPPacket*)reqSweepSections:(char)dest Origin:(char)origin;
-(void)respSweepSections:(ESPPacket*)recievedPacket;
-(void)setDelegate:(id<CustomSweepProtocol>)delegate;

@end
