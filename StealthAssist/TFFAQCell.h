//
//  TFFAQCell.h
//  StealthAssist
//
//  Created by Tyler Fox on 1/5/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFFAQCell : UITableViewCell

@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UILabel *answerLabel;

@property (nonatomic, assign) BOOL isExpanded;

@end
