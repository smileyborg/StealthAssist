//
//  AlertData.h
//  ESPLibrary
//
//  Created by Amadeus Consulting on 3/13/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to encapsulate an alert returned by the Valentine One.
 
 */

#import <Foundation/Foundation.h>
#import <QuartzCore/CAAnimation.h>


typedef enum direction_en{
    badDir = -1,
    front = 0,
    side = 1,
    rear = 2
} direction;

typedef enum band_en{
    badBand = -1,
    laser = 0,
    ka = 1,
    k = 2,
    x = 3,
    ku = 4
} band;

@interface AlertData : NSObject
@property (nonatomic)NSMutableData *alertBytes;
@property (nonatomic,assign) bool active;
@property (nonatomic,assign) bool isNew;
@property (nonatomic,assign) band boxBand;
@property (nonatomic) double lastDetectTimestamp;

//Init

-(id)init;

/** Call this method to intialize the Custom Sweep with recieved custom sweep data from the Valentine One.
 
 */
-(id)initWithBytes:(NSData*)bytes;

//Get Bytes

-(Byte)getAlertByte1;

-(Byte)getAlertByte2;

-(Byte)getAlertByte3;

-(Byte)getAlertByte4;

-(Byte)getAlertByte5;

-(Byte)getAlertByte6;

-(Byte)getAlertByte7;

//Get Alert Information

/** Call this method to return the number of alerts in the table.
 @return number of alerts
 */
-(int)getCount;

/** Call this method to return the index of the alert.
 @return index of the alert
 */
-(int)getIndex;

/** Call this method to return the frequency of the alert.
 @return frequency of the alert
 */
-(int)getFrequency;

/** Call this method to return the front signal strength of the alert.
 @return front signal strength of the alert
 */
-(int)getFrontSignalStrength;

/** Call this method to return the rear signal strength of the alert.
 @return frequency of the alert
 */
-(int)getRearSignalStrength;

//Set Alert Information

-(void)SetPriorityOn:(bool)val;

// 2 = Rear, 1 = Side, 0 = Front, -1 = Bad

/** Call this method to return the direction of the alert.
 @return direction of the alert: 2 = Rear, 1 = Side, 0 = Front, -1 = Bad
 */
-(direction)getDirection;

// 4 = Ku, 3 = X, 2 = K, 1 = Ka, 0 = Lazer, -1= Bad

/** Call this method to return the band of the alert.
 @return band of the alert: 4 = Ku, 3 = X, 2 = K, 1 = Ka, 0 = Lazer, -1= Bad
 */
-(band)getBand;

/** Call this method to return the normalized signal strength of the alert.
 @return normalized of the alert on a 1-8 scale
 */
-(Byte)getNormalizedSignalStregth;

/** Call this method to return the devience of the  alert.
 @return devience of the acceptance window for the alert
 */
-(int)getDevience;

/** Call this method to return if the alert is a priority alert.
 @return priority status of the alert
 */
-(bool)isPriority;

/** Call this method to return the upper window edge for the alert.
 @return upper acceptance window edge to see if the alert can be considered a matching alert when compared.
 */
-(int)getWindowUpper;

/** Call this method to return the upper window edge for the alert.
 @return upper acceptance window edge to see if the alert can be considered a matching alert when compared.
 */
-(int)getWindowLower;

//Sorting
- (NSComparisonResult)compare:(AlertData*)otherObject;

- (BOOL) isEqual:(id)object;

@end
