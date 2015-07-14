//
//  TFSettingsViewController.m
//  StealthAssist
//
//  Created by Tyler Fox on 12/27/13.
//  Copyright (c) 2013 Tyler Fox. All rights reserved.
//

#import "TFSettingsViewController.h"
#import "TFPreferences.h"
#import "TFSettingsColorController.h"
#import "TFAppDelegate.h"

#define kHorizontalCellPadding      15.0

#define kNumberOfBackgroundRows     2 // number of rows that show/hide when the RunsInBackground toggle is flipped

typedef NS_ENUM(NSInteger, TFSettingsRow) {
    TFSettingsRowDisplayColors = 0,
    TFSettingsRowUnits,
    TFSettingsRowRunsInBackground,
    TFSettingsRowTimeToRunInBackground,
    TFSettingsRowDisplayBackgroundNotifications,
    TFSettingsRowFirstBogeyAlertSound,
    TFSettingsRowShowPriorityAlertFrequency,
    TFSettingsRowUnmuteForBandKa,
    TFSettingsRowTurnsOffV1Display,
    TFSettingsNumberOfRows
};

@interface TFSettingsViewController ()

// Stores the chosen tint color before changes are applied. (If this preference is set upon selection,
// parts of the UI will take on the new color, and parts won't!)
@property (nonatomic, strong) UIColor *chosenTintColor;

@property (nonatomic, assign) BOOL isShowingBackgroundRows;

@end

@implementation TFSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"Settings";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [doneButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kStealthAssistFont size:18.0f]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    UIBarButtonItem *restoreDefaultsButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(restoreDefaults)];
    [restoreDefaultsButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kStealthAssistFont size:18.0f]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = restoreDefaultsButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done
{
    // Apply any change to the app tint color
    if (self.chosenTintColor) {
        [TFPreferences sharedInstance].appTintColor = self.chosenTintColor;
        [TFAppDelegate sharedInstance].window.tintColor = kAppTintColorDarker;
        [self.tableView reloadData]; // updates table view with new tint colors
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)restoreDefaults
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset All Settings"
                                                                   message:@"Are you sure you want to restore the default settings? Any changes you have made will be lost."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[TFPreferences sharedInstance] restoreDefaults];
        // Apply any change to the app tint color to the main window
        [TFAppDelegate sharedInstance].window.tintColor = kAppTintColorDarker;
        [self.tableView reloadData];
        [TFAnalytics track:@"Preferences: Restored Defaults"];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)shouldShowBackgroundRows
{
    return [TFPreferences sharedInstance].runsInBackground;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = TFSettingsNumberOfRows;
    if ([self shouldShowBackgroundRows]) {
        self.isShowingBackgroundRows = YES;
    } else {
        numberOfRows -= kNumberOfBackgroundRows;
        self.isShowingBackgroundRows = NO;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectZero];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    header.backgroundColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
    header.textColor = [UIColor lightGrayColor];
    header.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    header.textAlignment = NSTextAlignmentCenter;
    header.text = @"Changes take effect when you tap Done.";
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFSettingsRow row = indexPath.row;
    if (self.isShowingBackgroundRows == NO && indexPath.row >= TFSettingsRowDisplayBackgroundNotifications) {
        row = indexPath.row + kNumberOfBackgroundRows;
    }
    UITableViewCell *cell = nil;
    switch (row) {
        case TFSettingsRowDisplayColors:
            cell = [self displayColorsCell];
            break;
        case TFSettingsRowUnits:
            cell = [self unitsCell];
            break;
        case TFSettingsRowRunsInBackground:
            cell = [self runsInBackgroundCell];
            break;
        case TFSettingsRowTimeToRunInBackground:
            cell = [self timeToRunInBackgroundCell];
            break;
        case TFSettingsRowDisplayBackgroundNotifications:
            cell = [self displayBackgroundNotificationsCell];
            break;
        case TFSettingsRowFirstBogeyAlertSound:
            cell = [self firstBogeyAlertSoundCell];
            break;
        case TFSettingsRowTurnsOffV1Display:
            cell = [self turnsOffV1DisplayCell];
            break;
        case TFSettingsRowShowPriorityAlertFrequency:
            cell = [self showPriorityAlertFrequencyCell];
            break;
        case TFSettingsRowUnmuteForBandKa:
            cell = [self unmuteForBandKaCell];
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell *)displayColorsCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Display Colors";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)unitsCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Units";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"MPH", @"KM/H"]];
    segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    segmentedControl.tintColor = kAppTintColor;
    segmentedControl.selectedSegmentIndex = [TFPreferences sharedInstance].isUsingMPH ? 0 : 1;
    [segmentedControl addTarget:self action:@selector(unitsChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:segmentedControl];
    
    [segmentedControl autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:label withOffset:kHorizontalCellPadding relation:NSLayoutRelationGreaterThanOrEqual];
    [segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalCellPadding];
    [segmentedControl autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)runsInBackgroundCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Keep Running in Background";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UISwitch *control = [UISwitch newAutoLayoutView];
    control.onTintColor = kAppTintColorDarker;
    control.on = [TFPreferences sharedInstance].runsInBackground;
    [control addTarget:self action:@selector(backgroundModeChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:control];
    
    [control autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:label withOffset:kHorizontalCellPadding relation:NSLayoutRelationGreaterThanOrEqual];
    [control autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalCellPadding];
    [control autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)timeToRunInBackgroundCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Plugged in", @"Up to 30 min", @"No limit"]];
    segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    segmentedControl.tintColor = kAppTintColor;
    NSTimeInterval timeToRun = [TFPreferences sharedInstance].timeToRunInBackgroundUnplugged;
    if (timeToRun == kTimeToRunInBackgroundUnplugged10Seconds) {
        segmentedControl.selectedSegmentIndex = 0;
    } else if (timeToRun == kTimeToRunInBackgroundUnplugged30Minutes) {
        segmentedControl.selectedSegmentIndex = 1;
    } else if (timeToRun == kTimeToRunInBackgroundUnpluggedNoLimit) {
        segmentedControl.selectedSegmentIndex = 2;
    }
    [segmentedControl addTarget:self action:@selector(timeToRunInBackgroundChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:segmentedControl];
    
    CGFloat cellInset = kHorizontalCellPadding * 2.0;
    cell.separatorInset = UIEdgeInsetsMake(0, cellInset, 0, 0);
    
    [segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:cellInset];
    [segmentedControl autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)displayBackgroundNotificationsCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Background Notifications";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    CGFloat cellInset = kHorizontalCellPadding * 2.0;
    cell.separatorInset = UIEdgeInsetsMake(0, cellInset, 0, 0);
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:cellInset];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UISwitch *control = [UISwitch newAutoLayoutView];
    control.onTintColor = kAppTintColorDarker;
    control.on = [TFPreferences sharedInstance].displayBackgroundNotifications;
    [control addTarget:self action:@selector(displayBackgroundNotificationsChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:control];
    
    [control autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:label withOffset:kHorizontalCellPadding relation:NSLayoutRelationGreaterThanOrEqual];
    [control autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalCellPadding];
    [control autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)firstBogeyAlertSoundCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Play Alert Sound on First Bogey";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    CGFloat cellInset = kHorizontalCellPadding;
    cell.separatorInset = UIEdgeInsetsMake(0, cellInset, 0, 0);
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:cellInset];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UISwitch *control = [UISwitch newAutoLayoutView];
    control.onTintColor = kAppTintColorDarker;
    control.on = [TFPreferences sharedInstance].playNotificationSounds;
    [control addTarget:self action:@selector(firstBogeyAlertSoundChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:control];
    
    [control autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:label withOffset:kHorizontalCellPadding relation:NSLayoutRelationGreaterThanOrEqual];
    [control autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalCellPadding];
    [control autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)turnsOffV1DisplayCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Black Out V1 Display";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UISwitch *control = [UISwitch newAutoLayoutView];
    control.onTintColor = kAppTintColorDarker;
    control.on = [TFPreferences sharedInstance].turnsOffV1Display;
    [control addTarget:self action:@selector(turnsOffV1DisplayChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:control];
    
    [control autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:label withOffset:kHorizontalCellPadding relation:NSLayoutRelationGreaterThanOrEqual];
    [control autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalCellPadding];
    [control autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)showPriorityAlertFrequencyCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Show Priority Alert Frequency";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UISwitch *control = [UISwitch newAutoLayoutView];
    control.onTintColor = kAppTintColorDarker;
    control.on = [TFPreferences sharedInstance].showPriorityAlertFrequency;
    [control addTarget:self action:@selector(showPriorityAlertFrequencyChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:control];
    
    [control autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:label withOffset:kHorizontalCellPadding relation:NSLayoutRelationGreaterThanOrEqual];
    [control autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalCellPadding];
    [control autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)unmuteForBandKaCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Always Unmute Ka Priority Alerts";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UISwitch *control = [UISwitch newAutoLayoutView];
    control.onTintColor = kAppTintColorDarker;
    control.on = [TFPreferences sharedInstance].unmuteForBandKa;
    [control addTarget:self action:@selector(unmuteForBandKaChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:control];
    
    [control autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:label withOffset:kHorizontalCellPadding relation:NSLayoutRelationGreaterThanOrEqual];
    [control autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:kHorizontalCellPadding];
    [control autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFSettingsRow row = indexPath.row;
    switch (row) {
        case TFSettingsRowDisplayColors:
            [self displaySettingsColorController];
            break;
        case TFSettingsRowUnits:
        case TFSettingsRowRunsInBackground:
        case TFSettingsRowTurnsOffV1Display:
        case TFSettingsRowShowPriorityAlertFrequency:
        case TFSettingsRowUnmuteForBandKa:
        default:
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
    }
}

- (void)displaySettingsColorController
{
    TFSettingsColorController *colorController = [[TFSettingsColorController alloc] init];
    colorController.chosenTintColor = self.chosenTintColor;
    colorController.tintColorSelectionBlock = ^(UIColor *tintColor) {
        self.chosenTintColor = tintColor;
    };
    [self.navigationController pushViewController:colorController animated:YES];
    
    if ([self.tableView numberOfSections] > 0 && [self.tableView numberOfRowsInSection:0] > TFSettingsRowDisplayColors) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:TFSettingsRowDisplayColors inSection:0] animated:YES];
    } else {
        NSAssert(nil, @"Can't deselect Display Colors row!");
    }
}

- (void)unitsChanged:(UISegmentedControl *)sender
{
    [TFPreferences sharedInstance].isUsingMPH = (sender.selectedSegmentIndex == 0);
    [TFAnalytics track:@"Preference Changed: Units" withData:@{@"Units": ([TFPreferences sharedInstance].isUsingMPH ? @"MPH" : @"KM/H")}];
}

- (void)timeToRunInBackgroundChanged:(UISegmentedControl *)sender
{
    NSString *timeToRunString = @"";
    if (sender.selectedSegmentIndex == 0) {
        [TFPreferences sharedInstance].timeToRunInBackgroundUnplugged = kTimeToRunInBackgroundUnplugged10Seconds;
        timeToRunString = @"10 Seconds";
    } else if (sender.selectedSegmentIndex == 1) {
        [TFPreferences sharedInstance].timeToRunInBackgroundUnplugged = kTimeToRunInBackgroundUnplugged30Minutes;
        timeToRunString = @"30 Minutes";
    } else if (sender.selectedSegmentIndex == 2) {
        [TFPreferences sharedInstance].timeToRunInBackgroundUnplugged = kTimeToRunInBackgroundUnpluggedNoLimit;
        timeToRunString = @"Always";
        UIAlertController *warningAlert = [TFAlertView alertWithTitle:@"Warning"
                                                              message:@"Choosing \"No limit\" will allow StealthAssist to run in the background indefinitely as long as it is connected to your V1, even when your device is unplugged from a power source. This will cause your battery to drain if you do not enter Standby Mode manually."
                                                    cancelButtonTitle:@"I Understand"];
        [self presentViewController:warningAlert animated:YES completion:nil];
    } else {
        NSAssert(nil, @"Unexpected selected segment index!");
    }
    [TFAnalytics track:@"Preference Changed: Time To Run In Background Unplugged" withData:@{@"Time To Run In Background Unplugged": timeToRunString}];
}

- (void)backgroundModeChanged:(UISwitch *)sender
{
    [TFPreferences sharedInstance].runsInBackground = sender.on;
    if (self.isShowingBackgroundRows == NO && [self shouldShowBackgroundRows]) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:TFSettingsRowTimeToRunInBackground inSection:0], [NSIndexPath indexPathForRow:TFSettingsRowDisplayBackgroundNotifications inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    } else if (self.isShowingBackgroundRows && [self shouldShowBackgroundRows] == NO) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:TFSettingsRowTimeToRunInBackground inSection:0], [NSIndexPath indexPathForRow:TFSettingsRowDisplayBackgroundNotifications inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
    [TFAnalytics track:@"Preference Changed: Background Mode" withData:@{@"Runs in Background": ([TFPreferences sharedInstance].runsInBackground ? @"YES" : @"NO")}];
}

- (void)displayBackgroundNotificationsChanged:(UISwitch *)sender
{
    [TFPreferences sharedInstance].displayBackgroundNotifications = sender.on;
    [TFAnalytics track:@"Preference Changed: Background Notifications" withData:@{@"Background Notifications": ([TFPreferences sharedInstance].displayBackgroundNotifications ? @"ON" : @"OFF")}];
}

- (void)firstBogeyAlertSoundChanged:(UISwitch *)sender
{
    [TFPreferences sharedInstance].playNotificationSounds = sender.on;
    [TFAnalytics track:@"Preference Changed: Play Notification Sounds" withData:@{@"Play Notification Sounds": ([TFPreferences sharedInstance].playNotificationSounds ? @"ON" : @"OFF")}];
}

- (void)turnsOffV1DisplayChanged:(UISwitch *)sender
{
    [TFPreferences sharedInstance].turnsOffV1Display = sender.on;
    [TFAnalytics track:@"Preference Changed: Turns Off V1 Display" withData:@{@"Turns Off V1 Display": ([TFPreferences sharedInstance].turnsOffV1Display ? @"YES" : @"NO")}];
}

- (void)showPriorityAlertFrequencyChanged:(UISwitch *)sender
{
    [TFPreferences sharedInstance].showPriorityAlertFrequency = sender.on;
    [TFAnalytics track:@"Preference Changed: Show Priority Alert Frequency" withData:@{@"Show Priority Alert Frequency": ([TFPreferences sharedInstance].showPriorityAlertFrequency ? @"YES" : @"NO")}];
}

- (void)unmuteForBandKaChanged:(UISwitch *)sender
{
    [TFPreferences sharedInstance].unmuteForBandKa = sender.on;
    [TFAnalytics track:@"Preference Changed: Unmute For Band Ka" withData:@{@"Unmute For Band Ka": ([TFPreferences sharedInstance].unmuteForBandKa ? @"YES" : @"NO")}];
}

@end
