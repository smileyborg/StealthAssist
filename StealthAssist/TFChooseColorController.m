//
//  TFChooseColorController.m
//  StealthAssist
//
//  Created by Tyler Fox on 3/30/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "TFChooseColorController.h"
#import "TFPreferences.h"
#import "TFColorSwatchView.h"

#define kHorizontalCellPadding      15.0

@interface TFChooseColorController ()

@end

@implementation TFChooseColorController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if ([self.titlePrefix length] > 0) {
        self.title = [NSString stringWithFormat:@"%@ Color", self.titlePrefix];
    } else {
        self.title = @"Choose Color";
    }
    
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldDisplayBandSection
{
    return [TFPreferences sharedInstance].colorPerBand;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.colors count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TFColorSwatchView *colorSwatch = [TFColorSwatchView colorSwatchWithColor:self.colors[indexPath.row]];
    colorSwatch.isSelected = (self.selectedColorIndex == indexPath.row);
    [cell.contentView addSubview:colorSwatch];
    
    [colorSwatch autoSetDimensionsToSize:CGSizeMake(60.0, 60.0)];
    [colorSwatch autoCenterInSuperview];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.row < [self.colors count], @"There should not be more rows in the table view than there are colors.");
    self.selectedColorIndex = indexPath.row;
    [self.tableView reloadData];
    if (self.block) {
        self.block(self.colors[self.selectedColorIndex]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
    
@end
