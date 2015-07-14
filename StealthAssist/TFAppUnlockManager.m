//
//  TFAppUnlockManager.m
//  StealthAssist
//
//  Created by Tyler Fox on 2/16/14.
//  Copyright (c) 2014 Tyler Fox. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <Lockbox/Lockbox.h>
#import "TFAppUnlockManager.h"
#import "TFAppDelegate.h"

#define kAPP_UNLOCK_KEY         @"com.smileyborg.stealthassist.key"
#define kAPP_UNLOCK_VALUE       @"792567084"

#define kPRODUCT_ID_APP_UNLOCK              @"com.smileyborg.stealthassist.unlock"
#define kPRODUCT_ID_EXISTING_PAID_USER      @"com.smileyborg.stealthassist.existingpaiduser"

NSString *kAppUnlockSucceededNotification = @"TFAppUnlockSucceededNotification";
NSString *kAppUnlockFailedNotification = @"TFAppUnlockFailedNotification";
NSString *kRestorePurchasesFinishedNotification = @"TFRestorePurchasesFinishedNotification";

NSString *kUnlockButtonTitle = @"Unlock";
NSString *kCancelButtonTitle = @"Cancel";

@interface TFAppUnlockManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) SKProductsRequest *productsRequest;

@property (strong, nonatomic) SKProduct *product; // will be set once the products request completes

// Will start as NO. If we read from the Lockbox that the app is unlocked, we'll set this to YES,
// so that for the lifetime of this object we can just read and return the value from this property.
@property (nonatomic, assign) BOOL isAppUnlockedCachedValue;

@end

@implementation TFAppUnlockManager

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.isAppUnlockedCachedValue = NO;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)displayAlert:(UIAlertController *)alert
{
    [[TFAppDelegate sharedInstance].window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (BOOL)isTrial
{
    return !self.isUnlocked;
}

- (BOOL)isUnlocked
{
#if DEBUG
    // Uncomment the below line and run the app once to 're-lock' the app
//    [Lockbox setString:@"" forKey:kAPP_UNLOCK_KEY];
#endif
    
    if (self.isAppUnlockedCachedValue) {
        return YES;
    }
    
    NSString *isAppUnlocked = [Lockbox stringForKey:kAPP_UNLOCK_KEY];
    if (isAppUnlocked && [isAppUnlocked isEqualToString:kAPP_UNLOCK_VALUE]) {
        self.isAppUnlockedCachedValue = YES;
        return YES;
    } else {
        return NO;
    }
}

- (void)unlockApp
{
    if (self.isTrial) {
        [Lockbox setString:kAPP_UNLOCK_VALUE forKey:kAPP_UNLOCK_KEY accessibility:kSecAttrAccessibleAfterFirstUnlock];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppUnlockSucceededNotification object:self];
    }
}

- (void)purchaseAppUnlock
{
    if ([SKPaymentQueue canMakePayments] == NO) {
        [TFAnalytics track:@"IAP Error: In App Purchases Disabled"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppUnlockFailedNotification object:self];
        [self displayAlert:[TFAlertView alertWithTitle:@"App Unlock Failed"
                                               message:@"In App Purchases are disabled on your device."
                                     cancelButtonTitle:@"OK"]];
        return;
    }
    
    NSString *productID = kPRODUCT_ID_APP_UNLOCK;
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productID]];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
    NSLog(@"Sending products request...");
}

- (void)restoreAppUnlock
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    NSLog(@"Starting IAP restore...");
}

#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if ([response.invalidProductIdentifiers count] > 0) {
        // The products request contained invalid product identifiers
        NSAssert([response.invalidProductIdentifiers count] == 0, @"An invalid product identifier was sent.");
        NSString *invalidProductIdentifiers = [response.invalidProductIdentifiers componentsJoinedByString:@", "];
        [TFAnalytics track:@"IAP: Invalid Product Identifiers Sent" withData:@{@"Invalid Product Identifiers": invalidProductIdentifiers}];
    }
    
    if ([response.products count] != 1) {
        [TFAnalytics track:@"IAP: Product Request Response Invalid"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppUnlockFailedNotification object:self];
        NSString *errorMessage = [NSString stringWithFormat:@"An error occurred while communicating with the App Store to process the transaction. (Error Code 1001, Product Count %lu)", (unsigned long)[response.products count]];
        [self displayAlert:[TFAlertView alertWithTitle:@"App Unlock Failed"
                                               message:errorMessage
                                     cancelButtonTitle:@"OK"]];
        return;
    }
    
    self.product = [response.products lastObject];
    NSLog(@"Products Request Did Receive Response: Product ID = %@", [self.product productIdentifier]);
    
    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
    priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    priceFormatter.locale = self.product.priceLocale;
    NSString *priceString = [self.product.price isEqualToNumber:[NSDecimalNumber zero]] ? @"free" : [priceFormatter stringFromNumber:self.product.price];
    NSString *unlockMessage = [NSString stringWithFormat:@"Would you like to unlock the full version of StealthAssist for %@?", priceString];
    UIAlertController *confirmPurchaseAlert = [UIAlertController alertControllerWithTitle:@"Unlock App"
                                                                                  message:unlockMessage
                                                                           preferredStyle:UIAlertControllerStyleAlert];
    [confirmPurchaseAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppUnlockFailedNotification object:self];
        [TFAnalytics track:@"IAP Confirm Dialog: Cancel"];
    }]];
    [confirmPurchaseAlert addAction:[UIAlertAction actionWithTitle:@"Unlock" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSAssert(self.product, @"Product must not be nil!");
        SKPayment *payment = [SKPayment paymentWithProduct:self.product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [TFAnalytics track:@"IAP Confirm Dialog: Unlock"];
    }]];
    [self displayAlert:confirmPurchaseAlert];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    self.productsRequest = nil;
    
    [TFAnalytics track:@"IAP: Product Request Failed"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppUnlockFailedNotification object:self];
    
    [self displayAlert:[TFAlertView alertWithTitle:@"App Unlock Failed"
                                           message:@"An error occurred while communicating with the App Store to process the transaction. (Error Code 1002)"
                                 cancelButtonTitle:@"OK"]];
}

- (void)requestDidFinish:(SKRequest *)request
{
    self.productsRequest = nil;
}

#pragma mark SKPaymentTransactionObserver methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing product ID = %@ from store.", transaction.payment.productIdentifier);
                break;
            case SKPaymentTransactionStatePurchased:
            {
                if ([transaction.payment.productIdentifier isEqualToString:kPRODUCT_ID_APP_UNLOCK] ||
                    [transaction.payment.productIdentifier isEqualToString:kPRODUCT_ID_EXISTING_PAID_USER]) {
                    NSLog(@"App unlock purchased successfully.");
                    if ([transaction.payment.productIdentifier isEqualToString:kPRODUCT_ID_APP_UNLOCK]) {
                        [TFAnalytics track:@"IAP: App Unlock Purchased"];
                    } else if ([transaction.payment.productIdentifier isEqualToString:kPRODUCT_ID_EXISTING_PAID_USER]) {
                        [TFAnalytics track:@"IAP: Existing Paid User Unlock Purchased"];
                    }
                    if (self.isTrial) {
                        [self unlockApp];
                        [self displayAlert:[TFAlertView alertWithTitle:@"App Unlock Successful"
                                                               message:@"You now have unrestricted access to all features and functionality in the app."
                                                     cancelButtonTitle:@"OK"]];
                    }
                } else {
                    NSString *unknownProductID = transaction.payment.productIdentifier ? transaction.payment.productIdentifier : @"<nil product ID>";
                    [TFAnalytics track:@"IAP: Purchase Issue - Unknown Product ID" withData:@{@"Unknown Product ID": unknownProductID}];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAppUnlockFailedNotification object:self];
                    [self displayAlert:[TFAlertView alertWithTitle:@"App Unlock Failed"
                                                           message:@"An error occurred while communicating with the App Store to process the transaction. (Error Code 1005)"
                                                 cancelButtonTitle:@"OK"]];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateRestored:
            {
                if ([transaction.payment.productIdentifier isEqualToString:kPRODUCT_ID_APP_UNLOCK] ||
                    [transaction.payment.productIdentifier isEqualToString:kPRODUCT_ID_EXISTING_PAID_USER]) {
                    NSLog(@"App unlock restored successfully.");
                    [TFAnalytics track:@"IAP: App Unlock Restored" withData:@{@"Product ID": transaction.payment.productIdentifier}];
                    // This case will execute twice in the extremely unlikely event that the user has purchased both product IDs;
                    // the below check for isTrial ensures we only do one unlock and show one alert view.
                    if (self.isTrial) {
                        [self unlockApp];
                        [self displayAlert:[TFAlertView alertWithTitle:@"App Unlock Successful"
                                                               message:@"You have previously purchased the app unlock, so it was restored for you."
                                                     cancelButtonTitle:@"OK"]];
                    }
                } else {
                    NSString *unknownProductID = transaction.payment.productIdentifier ? transaction.payment.productIdentifier : @"<nil product ID>";
                    [TFAnalytics track:@"IAP: Restore Issue - Unknown Product ID" withData:@{@"Unknown Product ID": unknownProductID}];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAppUnlockFailedNotification object:self];
                    [self displayAlert:[TFAlertView alertWithTitle:@"App Unlock Failed"
                                                           message:@"An error occurred while communicating with the App Store to process the transaction. (Error Code 1006)"
                                                 cancelButtonTitle:@"OK"]];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateFailed:
            {
                NSLog(@"Product purchase failed with error: %@", transaction.error);
                [TFAnalytics track:@"IAP: App Unlock Failed" withData:@{@"Error Code": [NSString stringWithFormat:@"%ld", (long)transaction.error.code]}];
                [self displayAlertForTransactionError:transaction.error];
                [[NSNotificationCenter defaultCenter] postNotificationName:kAppUnlockFailedNotification object:self];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"IAP restore failed with error: %@", error);
    [TFAnalytics track:@"IAP: Restore Failed" withData:@{@"Error Code": [NSString stringWithFormat:@"%ld", (long)error.code]}];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppUnlockFailedNotification object:self];
    [self displayAlert:[TFAlertView alertWithTitle:@"Restore Failed"
                                           message:@"No previous purchases were able to be restored. (Error Code 1020)"
                                 cancelButtonTitle:@"OK"]];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"IAP restore finished.");
    [[NSNotificationCenter defaultCenter] postNotificationName:kRestorePurchasesFinishedNotification object:self];
}

- (void)displayAlertForTransactionError:(NSError *)error
{
    UIAlertController *alert = nil;
    switch (error.code) {
        case SKErrorPaymentCancelled:
            NSLog(@"Product purchase failed - payment cancelled.");
            [TFAnalytics track:@"IAP Error: Payment Cancelled"];
            alert = [TFAlertView alertWithTitle:@"App Unlock Failed"
                                        message:@"The transaction was cancelled. (Error Code 1011)"
                              cancelButtonTitle:@"OK"];
            break;
        case SKErrorClientInvalid:
            NSLog(@"Product purchase failed - client invalid.");
            [TFAnalytics track:@"IAP Error: Client Invalid"];
            alert = [TFAlertView alertWithTitle:@"App Unlock Failed"
                                        message:@"An error occurred while processing the transaction. (Error Code 1012)"
                              cancelButtonTitle:@"OK"];
            break;
        case SKErrorPaymentInvalid:
            NSLog(@"Product purchase failed - payment invalid.");
            [TFAnalytics track:@"IAP Error: Payment Invalid"];
            alert = [TFAlertView alertWithTitle:@"App Unlock Failed"
                                        message:@"An error occurred while processing the transaction. (Error Code 1013)"
                              cancelButtonTitle:@"OK"];
            break;
        case SKErrorPaymentNotAllowed:
            NSLog(@"Product purchase failed - payment not allowed.");
            [TFAnalytics track:@"IAP Error: Not Allowed"];
            alert = [TFAlertView alertWithTitle:@"App Unlock Failed"
                                        message:@"An error occurred while processing the transaction. (Error Code 1014)"
                              cancelButtonTitle:@"OK"];
            break;
        case SKErrorUnknown:
        default:
            NSLog(@"Product purchase failed - unknown error.");
            [TFAnalytics track:@"IAP Error: Unknown"];
            alert = [TFAlertView alertWithTitle:@"App Unlock Failed"
                                        message:@"An error occurred while processing the transaction. (Error Code 1010)"
                              cancelButtonTitle:@"OK"];
            break;
    }
    [self displayAlert:alert];
}

@end
