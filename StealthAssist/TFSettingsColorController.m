//
//  TFSettingsColorController.m
//  StealthAssist
//
//  Created by Tyler Fox on 3/30/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "TFSettingsColorController.h"
#import "TFPreferences.h"
#import "TFColorSwatchView.h"

#define kHorizontalCellPadding      15.0
#define kColorSwatchSize            40.0

typedef NS_ENUM(NSInteger, TFSettingsColorSection) {
    TFSettingsColorSectionMain = 0,
    TFSettingsColorSectionBand
};

typedef NS_ENUM(NSInteger, TFSettingsColorMainSectionRow) {
    TFSettingsColorMainSectionRowTintColor = 0,
    TFSettingsColorMainSectionRowColorPerBand,
    TFSettingsColorMainSectionNumberOfRows
};

typedef NS_ENUM(NSInteger, TFSettingsColorBandSectionRow) {
    TFSettingsColorBandSectionRowLaser = 0,
    TFSettingsColorBandSectionRowKa,
    TFSettingsColorBandSectionRowK,
    TFSettingsColorBandSectionRowX,
    TFSettingsColorBandSectionNumberOfRows
};

@interface TFSettingsColorController ()

@property (nonatomic, assign) BOOL isShowingBandSection;

@end

@implementation TFSettingsColorController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"Display Colors";
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
    NSInteger numberOfSections = 1;
    if ([self shouldDisplayBandSection]) {
        numberOfSections++;
        self.isShowingBandSection = YES;
    } else {
        self.isShowingBandSection = NO;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    TFSettingsColorSection sectionType = section;
    switch (sectionType) {
        case TFSettingsColorSectionMain:
            numberOfRows = TFSettingsColorMainSectionNumberOfRows;
            break;
        case TFSettingsColorSectionBand:
            numberOfRows = TFSettingsColorBandSectionNumberOfRows;
            break;
        default:
            break;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    TFSettingsColorSection sectionType = indexPath.section;
    switch (sectionType) {
        case TFSettingsColorSectionMain:
            cell = [self tableView:tableView cellForRowInMainSection:indexPath.row];
            break;
        case TFSettingsColorSectionBand:
            cell = [self tableView:tableView cellForRowInBandSection:indexPath.row];
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowInMainSection:(NSInteger)row
{
    TFSettingsColorMainSectionRow rowType = row;
    UITableViewCell *cell = nil;
    switch (rowType) {
        case TFSettingsColorMainSectionRowTintColor:
            cell = [self tintColorCell];
            break;
        case TFSettingsColorMainSectionRowColorPerBand:
            cell = [self colorPerBandCell];
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowInBandSection:(NSInteger)row
{
    TFSettingsColorBandSectionRow rowType = row;
    UITableViewCell *cell = nil;
    switch (rowType) {
        case TFSettingsColorBandSectionRowLaser:
            cell = [self bandCellWithTitle:@"Laser" selectedColor:[TFPreferences sharedInstance].bandLaserColor];
            break;
        case TFSettingsColorBandSectionRowKa:
            cell = [self bandCellWithTitle:@"Ka Band" selectedColor:[TFPreferences sharedInstance].bandKaColor];
            break;
        case TFSettingsColorBandSectionRowK:
            cell = [self bandCellWithTitle:@"K Band" selectedColor:[TFPreferences sharedInstance].bandKColor];
            break;
        case TFSettingsColorBandSectionRowX:
            cell = [self bandCellWithTitle:@"X Band" selectedColor:[TFPreferences sharedInstance].bandXColor];
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell *)tintColorCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Primary Theme Color";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    // We'll display the chosen color if one is waiting to be applied.
    UIColor *colorToDisplay = self.chosenTintColor ? self.chosenTintColor : [TFPreferences sharedInstance].appTintColor;
    TFColorSwatchView *colorSwatch = [TFColorSwatchView colorSwatchWithColor:colorToDisplay];
    [cell.contentView addSubview:colorSwatch];
    
    [colorSwatch autoSetDimensionsToSize:CGSizeMake(kColorSwatchSize, kColorSwatchSize)];
    [colorSwatch autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:label withOffset:kHorizontalCellPadding relation:NSLayoutRelationGreaterThanOrEqual];
    [colorSwatch autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalCellPadding];
    [colorSwatch autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)colorPerBandCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Color Per Band";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UISwitch *control = [UISwitch newAutoLayoutView];
    control.onTintColor = kAppTintColorDarker;
    control.on = [TFPreferences sharedInstance].colorPerBand;
    [control addTarget:self action:@selector(colorPerBandChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:control];
    
    [control autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:label withOffset:kHorizontalCellPadding relation:NSLayoutRelationGreaterThanOrEqual];
    [control autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalCellPadding];
    [control autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)bandCellWithTitle:(NSString *)title selectedColor:(UIColor *)selectedColor
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    CGFloat cellInset = kHorizontalCellPadding * 2.0;
    cell.separatorInset = UIEdgeInsetsMake(0, cellInset, 0, 0);
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:cellInset];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    TFColorSwatchView *colorSwatch = [TFColorSwatchView colorSwatchWithColor:selectedColor];
    [cell.contentView addSubview:colorSwatch];
    
    [colorSwatch autoSetDimensionsToSize:CGSizeMake(kColorSwatchSize, kColorSwatchSize)];
    [colorSwatch autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:label withOffset:kHorizontalCellPadding relation:NSLayoutRelationGreaterThanOrEqual];
    [colorSwatch autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalCellPadding];
    [colorSwatch autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == TFSettingsColorSectionMain) {
        TFSettingsColorMainSectionRow row = indexPath.row;
        switch (row) {
            case TFSettingsColorMainSectionRowTintColor:
                [self chooseAppTintColor];
                break;
            case TFSettingsColorMainSectionRowColorPerBand:
            default:
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                break;
        }
    }
    
    if (indexPath.section == TFSettingsColorSectionBand) {
        TFSettingsColorBandSectionRow row = indexPath.row;
        switch (row) {
            case TFSettingsColorBandSectionRowLaser:
                [self chooseColorForBandRow:row];
                break;
            case TFSettingsColorBandSectionRowKa:
                [self chooseColorForBandRow:row];
                break;
            case TFSettingsColorBandSectionRowK:
                [self chooseColorForBandRow:row];
                break;
            case TFSettingsColorBandSectionRowX:
                [self chooseColorForBandRow:row];
                break;
            default:
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                break;
        }
    }
}

- (void)chooseAppTintColor
{
    TFChooseColorController *chooseColorController = [[TFChooseColorController alloc] init];
    NSArray *tintColors = [TFPreferences sharedInstance].appTintColors;
    chooseColorController.titlePrefix = @"Primary Theme";
    chooseColorController.colors = tintColors;
    UIColor *colorToSelect = self.chosenTintColor ? self.chosenTintColor : [TFPreferences sharedInstance].appTintColor;
    chooseColorController.selectedColorIndex = [tintColors indexOfObject:colorToSelect];
    chooseColorController.block = ^(UIColor *chosenColor, NSUInteger chosenColorIndex) {
        self.chosenTintColor = chosenColor;
        if (self.tintColorSelectionBlock) {
            self.tintColorSelectionBlock(chosenColor, chosenColorIndex);
        }
        [self.tableView reloadData];
        [TFAnalytics track:@"Color Preference Changed: Tint Color" withData:@{@"Tint Color Index": [NSString stringWithFormat:@"%ld", (long)[tintColors indexOfObject:chosenColor]], @"Tint Color": [chosenColor description]}];
    };
    [self.navigationController pushViewController:chooseColorController animated:YES];
    
    if ([self.tableView numberOfSections] > TFSettingsColorSectionMain && [self.tableView numberOfRowsInSection:TFSettingsColorSectionMain] > TFSettingsColorMainSectionRowTintColor) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:TFSettingsColorMainSectionRowTintColor inSection:TFSettingsColorSectionMain] animated:YES];
    } else {
        NSAssert(nil, @"Can't deselect tint color row!");
    }
}

- (void)colorPerBandChanged:(UISwitch *)sender
{
    [TFPreferences sharedInstance].colorPerBand = sender.on;
    if (self.isShowingBandSection == NO && [self shouldDisplayBandSection]) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:TFSettingsColorSectionBand] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (self.isShowingBandSection && [self shouldDisplayBandSection] == NO) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:TFSettingsColorSectionBand] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [TFAnalytics track:@"Color Preference Changed: Color Per Band" withData:@{@"Color Per Band": ([TFPreferences sharedInstance].colorPerBand ? @"YES" : @"NO")}];
}

- (void)chooseColorForBandRow:(TFSettingsColorBandSectionRow)bandRow
{
    TFChooseColorController *chooseColorController = [[TFChooseColorController alloc] init];
    NSArray *bandColors = [TFPreferences sharedInstance].bandColors;
    NSString *bandString = @"";
    switch (bandRow) {
        case TFSettingsColorBandSectionRowLaser:
            bandString = @"Laser";
            chooseColorController.selectedColorIndex = [bandColors indexOfObject:[TFPreferences sharedInstance].bandLaserColor];
            break;
        case TFSettingsColorBandSectionRowKa:
            bandString = @"Ka Band";
            chooseColorController.selectedColorIndex = [bandColors indexOfObject:[TFPreferences sharedInstance].bandKaColor];
            break;
        case TFSettingsColorBandSectionRowK:
            bandString = @"K Band";
            chooseColorController.selectedColorIndex = [bandColors indexOfObject:[TFPreferences sharedInstance].bandKColor];
            break;
        case TFSettingsColorBandSectionRowX:
            bandString = @"X Band";
            chooseColorController.selectedColorIndex = [bandColors indexOfObject:[TFPreferences sharedInstance].bandXColor];
            break;
        default:
            break;
    }
    chooseColorController.titlePrefix = bandString;
    chooseColorController.colors = bandColors;
    chooseColorController.block = ^(UIColor *chosenColor, NSUInteger chosenColorIndex) {
        switch (bandRow) {
            case TFSettingsColorBandSectionRowLaser:
                [TFPreferences sharedInstance].bandLaserColorIndex = chosenColorIndex;
                break;
            case TFSettingsColorBandSectionRowKa:
                [TFPreferences sharedInstance].bandKaColorIndex = chosenColorIndex;
                break;
            case TFSettingsColorBandSectionRowK:
                [TFPreferences sharedInstance].bandKColorIndex = chosenColorIndex;
                break;
            case TFSettingsColorBandSectionRowX:
                [TFPreferences sharedInstance].bandXColorIndex = chosenColorIndex;
                break;
            default:
                break;
        }
        [self.tableView reloadData];
        [TFAnalytics track:@"Color Preference Changed: Band Color" withData:@{@"Band": bandString, @"Band Color Index": [NSString stringWithFormat:@"%ld", (long)chosenColorIndex], @"Band Color": [chosenColor description]}];
    };
    [self.navigationController pushViewController:chooseColorController animated:YES];
    
    if ([self.tableView numberOfSections] > TFSettingsColorSectionBand && [self.tableView numberOfRowsInSection:TFSettingsColorSectionBand] > bandRow) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:bandRow inSection:TFSettingsColorSectionBand] animated:YES];
    } else {
        NSAssert(nil, @"Can't deselect band color row!");
    }
}

@end
