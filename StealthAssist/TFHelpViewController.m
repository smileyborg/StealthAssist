//
//  TFHelpViewController.m
//  StealthAssist
//
//  Created by Tyler Fox on 1/1/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import "TFHelpViewController.h"
#import "TFPreferences.h"
#import "TFDeviceHardware.h"
#import "TFFAQViewController.h"
#import "TFAlertOverlay.h"

#define ITUNES_APP_STORE_ID 792567084

#define kHorizontalCellPadding      15.0f

typedef NS_ENUM(NSInteger, TFHelpRow) {
    TFHelpRowUnlockApp = 0,
    TFHelpRowRestorePurchases,
    TFHelpRowTutorial,
    TFHelpRowFAQ,
    TFHelpRowSupport,
    TFHelpRowFeedback,
    TFHelpRowRateApp,
    TFHelpNumberOfRows
};

@interface TFHelpViewController ()

@property (nonatomic, strong) TFAlertOverlay *purchasingUnlockOverlay;
@property (nonatomic, strong) TFAlertOverlay *restoringUnlockOverlay;

@end

@implementation TFHelpViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"About";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [doneButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kStealthAssistFont size:18.0f]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    self.tableView.allowsSelection = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([TFAppUnlockManager sharedInstance].isTrial) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appUnlockSucceeded:) name:kAppUnlockSucceededNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appUnlockFailed:) name:kAppUnlockFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restorePurchasesFinished:) name:kRestorePurchasesFinishedNotification object:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return TFHelpNumberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 60.0f;
    TFHelpRow row = indexPath.row;
    if ([TFAppUnlockManager sharedInstance].isUnlocked) {
        if (row == TFHelpRowUnlockApp || row == TFHelpRowRestorePurchases) {
            height = 0.0f;
        }
    } else if ([TFAppUnlockManager sharedInstance].isTrial) {
        if (row == TFHelpRowRateApp) {
            height = 0.0f;
        }
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    TFHelpRow row = indexPath.row;
    switch (row) {
        case TFHelpRowUnlockApp:
            cell = [self unlockAppCell];
            break;
        case TFHelpRowRestorePurchases:
            cell = [self restorePurchasesCell];
            break;
        case TFHelpRowTutorial:
            cell = [self tutorialCell];
            break;
        case TFHelpRowFAQ:
            cell = [self faqCell];
            break;
        case TFHelpRowSupport:
            cell = [self emailCell:YES];
            break;
        case TFHelpRowFeedback:
            cell = [self emailCell:NO];
            break;
        case TFHelpRowRateApp:
            cell = [self rateCell];
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell *)unlockAppCell
{
    if ([TFAppUnlockManager sharedInstance].isUnlocked) {
        return [[UITableViewCell alloc] init];
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Purchase Full Version Unlock";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)restorePurchasesCell
{
    if ([TFAppUnlockManager sharedInstance].isUnlocked) {
        return [[UITableViewCell alloc] init];
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Restore Previous Unlock Purchase";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)tutorialCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Play Tour";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)faqCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Help & FAQ";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)emailCell:(BOOL)isSupport // YES if support, NO if feedback
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = isSupport ? @"Email Support" : @"Send Feedback";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (UITableViewCell *)rateCell
{
    if ([TFAppUnlockManager sharedInstance].isTrial) {
        return [[UITableViewCell alloc] init];
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *label = [UILabel newAutoLayoutView];
    label.font = [UIFont fontWithName:kStealthAssistFont size:16.0f];
    label.text = @"Rate & Review in the App Store";
    label.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:label];
    
    [label autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:kHorizontalCellPadding];
    [label autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TFHelpRow row = indexPath.row;
    switch (row) {
        case TFHelpRowUnlockApp:
            if ([TFAppUnlockManager sharedInstance].isTrial) {
                [TFAnalytics track:@"Help: Unlock App"];
                [self unlockApp];
            }
            break;
        case TFHelpRowRestorePurchases:
            if ([TFAppUnlockManager sharedInstance].isTrial) {
                [TFAnalytics track:@"Help: Restore Purchases"];
                [self restorePurchases];
            }
            break;
        case TFHelpRowTutorial:
            [TFAnalytics track:@"Help: Play Tutorial"];
            [self showTutorial];
            break;
        case TFHelpRowFAQ:
            [TFAnalytics track:@"Help: Open FAQ"];
            [self showFAQ];
            break;
        case TFHelpRowSupport:
            [TFAnalytics track:@"Help: Email Support"];
            [self handleEmail:YES];
            break;
        case TFHelpRowFeedback:
            [TFAnalytics track:@"Help: Send Feedback"];
            [self handleEmail:NO];
            break;
        case TFHelpRowRateApp:
            if ([TFAppUnlockManager sharedInstance].isUnlocked) {
                [TFAnalytics track:@"Help: Rate App"];
                [self rateAppInAppStore];
            }
            break;
        default:
            break;
    }
}

- (void)unlockApp
{
    self.purchasingUnlockOverlay = [TFAlertOverlay alertOverlayWithSize:CGSizeMake(250.0f, 150.0f) title:@"Unlocking App"];
    self.purchasingUnlockOverlay.displayActivityIndicator = YES;
    [self.purchasingUnlockOverlay display];
    [[TFAppUnlockManager sharedInstance] purchaseAppUnlock];
    
    if ([self.tableView numberOfSections] > 0 && [self.tableView numberOfRowsInSection:0] > TFHelpRowUnlockApp) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:TFHelpRowUnlockApp inSection:0] animated:YES];
    } else {
        NSAssert(nil, @"Can't deselect Unlock App row!");
    }
}

- (void)restorePurchases
{
    self.restoringUnlockOverlay = [TFAlertOverlay alertOverlayWithSize:CGSizeMake(250.0f, 150.0f) title:@"Unlocking App"];
    self.restoringUnlockOverlay.displayActivityIndicator = YES;
    [self.restoringUnlockOverlay display];
    [[TFAppUnlockManager sharedInstance] restoreAppUnlock];
    
    if ([self.tableView numberOfSections] > 0 && [self.tableView numberOfRowsInSection:0] > TFHelpRowRestorePurchases) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:TFHelpRowRestorePurchases inSection:0] animated:YES];
    } else {
        NSAssert(nil, @"Can't deselect Restore Purchases row!");
    }
}

- (void)showTutorial
{
    [TFPreferences sharedInstance].shouldShowTutorial = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showFAQ
{
    TFFAQViewController *faqController = [[TFFAQViewController alloc] init];
    [self.navigationController pushViewController:faqController animated:YES];
}

- (void)handleEmail:(BOOL)isSupport // YES if support, NO if feedback
{
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *trialMode = [TFAppUnlockManager sharedInstance].isTrial ? @"TM" : @"UL";
    NSString *diagnosticInfo = [NSString stringWithFormat:@"StealthAssist v%@ %@, %@ iOS %@", appVersion, trialMode, [TFDeviceHardware platform], [[UIDevice currentDevice] systemVersion]];
    
    NSString *emailAddress = @"StealthAssist@smileyborg.com";
    NSString *supportSubject = @"Support for StealthAssist iOS App v%@";
    NSString *feedbackSubject = @"Feedback for StealthAssist iOS App v%@";
    NSString *supportBody = [NSString stringWithFormat:@"<p><b>What are you having trouble with?</b><br><i>Please include as much detail as possible:</i></p><p><br><br><br><br><br></p><p><i>The information below has been automatically added to help solve the issue:</i><br>[Diagnostic information: %@]</p>", diagnosticInfo];
    NSString *feedbackBody = [NSString stringWithFormat:@"<p><b>Enter your feedback:</b></p><p><br><br><br><br><br></p><p><i>The information below has been added to better understand how you are using the app; you may delete this if you do not wish to send it.</i><br>[Diagnostic information: %@]</p>", diagnosticInfo];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setToRecipients:@[emailAddress]];
        NSString *subject = [NSString stringWithFormat:(isSupport ? supportSubject : feedbackSubject), appVersion];
        [mailController setSubject:subject];
        [mailController setMessageBody:(isSupport ? supportBody : feedbackBody) isHTML:YES];
        [self presentViewController:mailController animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", emailAddress]]];
    }
}

- (void)rateAppInAppStore
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d", ITUNES_APP_STORE_ID]]];
    
    if ([self.tableView numberOfSections] > 0 && [self.tableView numberOfRowsInSection:0] > TFHelpRowRateApp) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:TFHelpRowRateApp inSection:0] animated:YES];
    } else {
        NSAssert(nil, @"Can't deselect Rate App row!");
    }
}

- (void)restorePurchasesFinished:(NSNotification *)notification
{
    [self.restoringUnlockOverlay dismiss];
}

#pragma mark App Unlock

- (void)appUnlockSucceeded:(NSNotification *)notification
{
    NSAssert([TFAppUnlockManager sharedInstance].isUnlocked, @"App unlock successful notification received, but app is not unlocked!");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppUnlockSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppUnlockFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRestorePurchasesFinishedNotification object:nil];
    
    [self.purchasingUnlockOverlay dismiss];
    [self.restoringUnlockOverlay dismiss];
    
    // Reload the table view to remove the app unlock rows
    [self.tableView reloadData];
}

- (void)appUnlockFailed:(NSNotification *)notification
{
    [self.purchasingUnlockOverlay dismiss];
    [self.restoringUnlockOverlay dismiss];
}

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
