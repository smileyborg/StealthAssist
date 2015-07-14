//
//  CustomSweepObject.h
//  ESPLibrary
//
//  Created by Amadeus Consulting on 3/20/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to encapsulate a custom sweep object. This could either be a sweep section or a sweep definition.
 
 */

#import <Foundation/Foundation.h>

@interface CustomSweepObject : NSObject
@property (nonatomic) NSMutableData *sweepData;

/** Call this method to intialize the Custom Sweep with recieved custom sweep data from the Valentine One.
 
 */
-(id)initWithData:(NSData*)data;

/** Call this method to intialize the Custom Sweep.
 @param index The index of the Sweep Definition.
 @param ue The upper edge of the sweep.
 @param le The upper edge of the sweep.
 @param commit Whether or not this is the last sweep definition in the set.
 */
-(id)initWithIndex:(int)index UpperEdge:(uint16_t)ue LowerEdge:(uint16_t)le Commit:(bool)commit;
-(uint16_t)getUpperSweepEdge;
-(uint16_t)getLowerSweepEdge;
-(void)setUpperSweepEdge:(uint16_t)ue;
-(void)setLowerSweepEdge:(uint16_t)le;
-(int)getSweepSectionIndex;
-(int)getSweepSectionCount;
-(int)getIndex;
-(void)updateDefinition:(int)index withCount:(int)sectionCount;
-(BOOL)isEqualTo:(CustomSweepObject *)otherObject;
@end
