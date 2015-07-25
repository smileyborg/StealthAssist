//
//  DisplayData.h
//  ESPLibrary
//
//  Created by Amadeus Consulting on 3/14/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to encapsulate the display information returned by the Valentine One.
 
 */

#import <Foundation/Foundation.h>

typedef enum dispState_en{
    blinking =0,
    off =1,
    on =2,
    fade = 3
} dispState;

@interface DisplayData : NSObject

@property (nonatomic) NSData *DisplayData;

/** Call this method to initialize the DisplayData object with payload data.
 */
-(id)initWithBytes:(NSData*)bytes;

/** Call this method to initialize the DisplayData with all zeroes.
 */
-(id) initBlank;

//Get Bytes

-(Byte)getDisplayByte1;

-(Byte)getDisplayByte2;

-(Byte)getDisplayByte3;

-(Byte)getDisplayByte4;

-(Byte)getDisplayByte5;

-(Byte)getDisplayByte6;

-(Byte)getDisplayByte7;

-(Byte)getDisplayByte8;

-(Byte)getDisplayByte9;

// MutiSegment Display. This will determine whether the segment is ON (2), OFF (1) or BLINKING (0)
/** Call this method to retrieve the state of SegmentA of the seven segmented display.
 @return The enumerated displayState
 */
-(dispState)SegmentA;
/** Call this method to retrieve the state of SegmentB of the seven segmented display.
 @return The enumerated displayState
 */
-(dispState)SegmentB;
/** Call this method to retrieve the state of SegmentC of the seven segmented display.
 @return The enumerated displayState
 */
-(dispState)SegmentC;
/** Call this method to retrieve the state of SegmentD of the seven segmented display.
 @return The enumerated displayState
 */
-(dispState)SegmentD;
/** Call this method to retrieve the state of SegmentE of the seven segmented display.
 @return The enumerated displayState
 */
-(dispState)SegmentE;
/** Call this method to retrieve the state of SegmentF of the seven segmented display.
 @return The enumerated displayState
 */
-(dispState)SegmentF;
/** Call this method to retrieve the state of SegmentG of the seven segmented display.
 @return The enumerated displayState
 */
-(dispState)SegmentG;
/** Call this method to retrieve the state of the decimal point of the seven segmented display.
 @return The enumerated displayState
 */
-(dispState)DP;

// StrengthBar Display. This will determine whether the light is ON (true), or OFF (false). 0 is left, 7 is right.
/** Call this method to retrieve the state of a light on the strength display.
 @return The on/off state of the strength.
 */
-(bool)b0;
/** Call this method to retrieve the state of a light on the strength display.
 @return The on/off state of the strength.
 */
-(bool)b1;
/** Call this method to retrieve the state of a light on the strength display.
 @return The on/off state of the strength.
 */
-(bool)b2;
/** Call this method to retrieve the state of a light on the strength display.
 @return The on/off state of the strength.
 */
-(bool)b3;
/** Call this method to retrieve the state of a light on the strength display.
 @return The on/off state of the strength.
 */
-(bool)b4;
/** Call this method to retrieve the state of a light on the strength display.
 @return The on/off state of the strength.
 */
-(bool)b5;
/** Call this method to retrieve the state of a light on the strength display.
 @return The on/off state of the strength.
 */
-(bool)b6;
/** Call this method to retrieve the state of a light on the strength display.
 @return The on/off state of the strength.
 */
-(bool)b7;


// Band and Direction. This will determine whether it is ON (2), OFF (1) or BLINKING (0)
/** Call this method to retrieve the state of the Lazer display.
 @return The enumerated displayState
 */
-(dispState)Laser;
/** Call this method to retrieve the state of the Ka display.
 @return The enumerated displayState
 */
-(dispState)Ka;
/** Call this method to retrieve the state of the K display.
 @return The enumerated displayState
 */
-(dispState)K;
/** Call this method to retrieve the state of the X display.
 @return The enumerated displayState
 */
-(dispState)X;
/** Call this method to retrieve the state of the Front arrow.
 @return The enumerated displayState
 */
-(dispState)Front;
/** Call this method to retrieve the state of the Side arrow.
 @return The enumerated displayState
 */
-(dispState)Side;
/** Call this method to retrieve the state of the Rear arrow.
 @return The enumerated displayState
 */
-(dispState)Rear;

//Aux0 Byte Information
/** Call this method to retrieve the Soft status.
 */
-(bool)Soft;
/** Call this method to retrieve the TSHoldOff status.
 */
-(bool)TSHoldOff;
/** Call this method to retrieve the SystemStatus status.
 */
-(bool)SystemStatus;
/** Call this method to retrieve the DisplayOn status.
 */
-(bool)DisplayOn;
/** Call this method to retrieve the EuroMode status.
 */
-(bool)EuroMode;
/** Call this method to retrieve the CustomSweep status.
 */
-(bool)CustomSweep;
/** Call this method to retrieve the Legacy status.
 */
-(bool)Legacy;


@end
