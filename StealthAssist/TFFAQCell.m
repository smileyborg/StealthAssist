//
//  TFFAQCell.m
//  StealthAssist
//
//  Created by Tyler Fox on 1/5/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "TFFAQCell.h"

#define kLabelHorizontalInsets      15.0f
#define kLabelVerticalInsets        10.0f

@interface TFFAQCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@property (nonatomic, strong) NSLayoutConstraint *answerHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *answerBottomConstraint;

@end

@implementation TFFAQCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.questionLabel = [UILabel newAutoLayoutView];
        self.questionLabel.numberOfLines = 0;
        self.questionLabel.textColor = kAppTintColorLighter;
        self.questionLabel.font = [UIFont fontWithName:kStealthAssistFont size:18.0f];
        [self.contentView addSubview:self.questionLabel];
        
        self.answerLabel = [UILabel newAutoLayoutView];
        self.answerLabel.numberOfLines = 0;
        self.answerLabel.textColor = [UIColor whiteColor];
        self.answerLabel.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
        [self.contentView addSubview:self.answerLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.didSetupConstraints == NO) {
        [self.questionLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.questionLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(kLabelVerticalInsets, kLabelHorizontalInsets, 0, kLabelHorizontalInsets) excludingEdge:ALEdgeBottom];
        
        [self.answerLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.questionLabel withOffset:kLabelVerticalInsets relation:NSLayoutRelationGreaterThanOrEqual];
        [self.answerLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kLabelHorizontalInsets];
        [self.answerLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kLabelHorizontalInsets];
        self.answerBottomConstraint = [self.answerLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kLabelVerticalInsets];
        
        self.didSetupConstraints = YES;
    }
    
    if (self.isExpanded) {
        [self.answerHeightConstraint autoRemove];
        self.answerHeightConstraint = nil;
        self.answerBottomConstraint.constant = -kLabelVerticalInsets;
    } else {
        if (!self.answerHeightConstraint) {
            self.answerHeightConstraint = [self.answerLabel autoSetDimension:ALDimensionHeight toSize:0.0f];
        }
        self.answerBottomConstraint.constant = 0.0f;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.questionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.questionLabel.frame);
    self.answerLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.answerLabel.frame);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    
}

@end
