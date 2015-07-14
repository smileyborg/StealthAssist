//
//  TFFAQViewController.m
//  StealthAssist
//
//  Created by Tyler Fox on 1/5/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "TFFAQViewController.h"
#import "TFFAQEntry.h"
#import "TFFAQCell.h"

#define kFAQCellIdentifier      @"FAQCellIdentifier"

@interface TFFAQViewController ()

@property (nonatomic, strong) NSArray *faqEntries;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) TFFAQCell *offscreenCell;

@end

@implementation TFFAQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"Help & FAQ";
    
    self.tableView.allowsSelection = YES;
    [self.tableView registerClass:[TFFAQCell class] forCellReuseIdentifier:kFAQCellIdentifier];
    
    self.faqEntries = [TFFAQEntry allFAQEntries];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
    if (self.selectedIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.faqEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFFAQCell *cell = [tableView dequeueReusableCellWithIdentifier:kFAQCellIdentifier];
    
    TFFAQEntry *faqEntry = self.faqEntries[indexPath.row];
    cell.questionLabel.text = faqEntry.question;
    cell.answerLabel.text = faqEntry.answer;
    cell.isExpanded = [indexPath isEqual:self.selectedIndexPath];
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.offscreenCell) {
        self.offscreenCell = [[TFFAQCell alloc] init];
    }
    TFFAQCell *cell = self.offscreenCell;
    
    TFFAQEntry *faqEntry = self.faqEntries[indexPath.row];
    cell.questionLabel.text = faqEntry.question;
    cell.answerLabel.text = faqEntry.answer;
    cell.isExpanded = [indexPath isEqual:self.selectedIndexPath];
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    // Set the width of the cell to match the width of the table view. This is important so that we'll get the
    // correct height for different table view widths, since our cell's height depends on its width due to
    // the multi-line UILabel word wrapping. Don't need to do this above in -[tableView:cellForRowAtIndexPath]
    // because it happens automatically when the cell is used in the table view.
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
    // in the UITableViewCell subclass
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // Add an extra point to account for the table view cell separator (added between the contentView bottom and cell bottom)
    height += 1.0f;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *indexPathsToReload = [NSMutableArray new];
    if (self.selectedIndexPath && [self.selectedIndexPath isEqual:indexPath] == NO) {
        // We had a previously selected index path and the new one is different, so add it to the array to be reloaded
        [indexPathsToReload addObject:self.selectedIndexPath];
    }
    [indexPathsToReload addObject:indexPath];
    
    self.selectedIndexPath = [self.selectedIndexPath isEqual:indexPath] ? nil : indexPath;
    
    [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
    if (self.selectedIndexPath) {
        [self.tableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    NSAssert(self.selectedIndexPath.row < self.faqEntries.count, @"Selected index path row of FAQ should not exceed the number of FAQ entries.");
    if (self.selectedIndexPath && self.selectedIndexPath.row < self.faqEntries.count) {
        TFFAQEntry *selectedEntry = self.faqEntries[self.selectedIndexPath.row];
        [TFAnalytics track:@"FAQ: Tapped Question" withData:@{@"Question": selectedEntry.question}];
    }
}

@end
