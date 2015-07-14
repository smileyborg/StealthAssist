//
//  UserBytes.h
//  Valentine
//
//  Created by Amadeus Consulting on 3/4/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to encapsulate the user settings stored on the Valentine One.
 
 */

#import <Foundation/Foundation.h>

@interface UserBytes : NSObject
@property (nonatomic)NSMutableData *userBytes;


//Init

-(id)init;

/** Call this method to intialize the Custom Sweep with recieved custom sweep data from the Valentine One.
 
 */
-(id)initWithBytes:(NSData*)bytes;

-(void)resetTo0xFF;

//Get Bytes

-(Byte)getUserByte1;

-(Byte)getUserByte2;

-(Byte)getUserByte3;

//Get

-(bool)XbandOn;

-(bool)KbandOn;

-(bool)KAbandOn;

-(bool)LaserOn;

-(bool)BargraphNormalResponsive;

-(bool)KAFalseGuardOn;

-(bool)KMutingOn;

-(bool)MuteVolumeLeverZero;

-(bool)PostMuteBogeyLockVolumeLeverKnob;

-(int)KMuteTimer;

-(bool)KInitialUnmute4Lights;

-(bool)KPersistantUnmute6Lights;

-(bool)KRearMuteOn;

-(bool)KUBandOn;

-(bool)PopOn;

-(bool)EuroOn;

-(bool)EuroXBandOn;

-(bool)FilterOn;

-(bool)ForceLegacyCD;

//Set

-(void)SetXbandOn:(bool)val;

-(void)SetKbandOn:(bool)val;

-(void)SetKAbandOn:(bool)val;

-(void)SetLaserOn:(bool)val;

-(void)SetBargraphNormalResponsive:(bool)val;

-(void)SetKAFalseGuardOn:(bool)val;

-(void)SetKMutingOn:(bool)val;

-(void)SetMuteVolumeLeverZero:(bool)val;

-(void)SetPostMuteBogeyLockVolumeKnobLever:(bool)val;

-(void)SetKMuteTimer:(int)val;

-(void)SetKInitialUnmute4Lights:(bool)val;

-(void)SetKPersistantUnmute6Lights:(bool)val;

-(void)SetKRearMuteOn:(bool)val;

-(void)SetKUBandOn:(bool)val;

-(void)SetPopOn:(bool)val;

-(void)SetEuroOn:(bool)val;

-(void)SetEuroXBandOn:(bool)val;

-(void)SetFilterOn:(bool)val;

-(void)SetForceLegacyCD:(bool)val;

//Comparison
-(bool)isEqualTo:(UserBytes*)ub;

//Overloaded Description Method
-(NSString*)description;

@end
