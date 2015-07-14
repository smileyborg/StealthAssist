//
//  TFFAQEntry.h
//  StealthAssist
//
//  Created by Tyler Fox on 1/5/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFFAQEntry : NSObject

@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSString *answer;

+ (instancetype)faqEntryWithQuestion:(NSString *)question answer:(NSString *)answer;

+ (NSArray *)allFAQEntries;

@end
