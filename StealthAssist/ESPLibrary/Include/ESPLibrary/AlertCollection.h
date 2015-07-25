//
//  AlertCollection.h
//  ESPLibrary
//
//  Created by Amadeus Consulting on 3/13/13.
//  Copyright (c) 2013 Valentine. All rights reserved.
//

/** This class is designed to encapsulate an alert table returned by the Valentine One.
 
 */

#import <Foundation/Foundation.h>
#import "AlertData.h"

@interface AlertCollection : NSObject

@property (nonatomic) int totalAlerts;
@property (nonatomic) NSMutableArray *alerts;

/** Call this method to initalize the alert collection with an alert.
 */
- (id) initWithAlert:(AlertData*)alert;
/** Call this method to create a copy of an alert collection.
 */
//- (id) createCopy:(AlertCollection*)ac;
/** Call this method to add an alert to the collection.
 @param alert The alert being added to the collection.
 */
- (void) addAlert:(AlertData*)alert;
/** Call this method to determine whether or not the collection contains all of the alerts in the table.
 */
- (bool) isComplete;
/** Call this method to retrieve an alert by index.
 @return The alert at the index provided.
 */
- (AlertData*) getAlertAtIndex:(int)index;
/** Call this method to retrieve the alert marked as the priority.
 @return The priority alert
 */
- (AlertData*) getPriorityAlert;
/** Call this method to determine whether an alert with the provided index is already in the table or not.
 @i The index to be checked.
 */
- (bool)containsAlertWithIndex:(int)i;

@end
