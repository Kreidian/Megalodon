//
//  MKInAppPurchaseManager.m
//  HolyHeading
//
//  Created by Eitan Levy on 4/27/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import "MKInAppPurchaseManager.h"

#define kProductsLoadedNotification         @"ProductsLoaded"
#define kProductPurchasedNotification       @"ProductPurchased"
#define kProductPurchaseFailedNotification  @"ProductPurchaseFailed"

@interface MKInAppPurchaseManager ()

@property(strong, nonatomic) UIAlertView *loading;

@end

@implementation MKInAppPurchaseManager

@synthesize myProducts;
@synthesize loading;
@synthesize lastPurchase;
@synthesize delegate;

-(void) setupPurchaseManager: (NSArray*) products
{
    purchaseEnabled = [SKPaymentQueue canMakePayments];
    
    if (!purchaseEnabled)
    {
        NSLog(@"Parental controls are enabled.");
        return;
    }
    
    NSMutableSet *prodIdentifiers = [[NSMutableSet alloc] initWithCapacity:products.count];
    NSString * bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *bundleName;
    for (NSString* prod in products) {
        bundleName = [bundleID stringByAppendingFormat:@".%@", prod];
        [prodIdentifiers addObject:bundleName];
    }
    
    SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:prodIdentifiers];
    productRequest.delegate = self;
    [productRequest start];
}

-(void) makePurchase: (NSString*) name
{
    if (!purchaseEnabled)
    {
        return;
    }
    
    NSString * bundleID = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString* bundleName = [bundleID stringByAppendingFormat:@".%@", name];
    SKPayment* payment = nil;
    lastPurchase = name;
    
    NSLog(@"**>  %@", bundleName);
    for (SKProduct* product in myProducts) {
        NSLog(@"%@", product.productIdentifier);
        if ([product.productIdentifier isEqualToString:bundleName])
        {
            NSLog(@"%@", product.productIdentifier);
            payment = [SKPayment paymentWithProduct:product];
            break;
        }
    }
    
    if (payment == nil)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error Invalid Purchase" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    
    //SKPayment* payment = [SKPayment paymentWithProduct:[myProducts objectAtIndex:0]];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    loading = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PURCHASING", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [loading show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    indicator.center = CGPointMake(loading.bounds.size.width / 2, loading.bounds.size.height - 50);
    [indicator startAnimating];
    [loading addSubview:indicator];
}
                                                        
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"invalids - %@", response.invalidProductIdentifiers);
    
    myProducts = [NSArray arrayWithArray:response.products];
    
    NSLog(@"products - %@", myProducts);
}

-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for( SKPaymentTransaction* trans in transactions )
    {
        switch (trans.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing - %@", trans);
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Purchased! - %@", trans);
                
                [[SKPaymentQueue defaultQueue] finishTransaction:trans];
                
                [loading dismissWithClickedButtonIndex:0 animated:YES];
                
                [self.delegate productDidPurchase:self.lastPurchase];
                
                NSLog(@"%@", trans.payment.productIdentifier);
                
                break;
                
            case SKPaymentTransactionStateRestored:
                
                NSLog(@"Restored! - %@", trans);
                [[SKPaymentQueue defaultQueue] finishTransaction:trans];
                NSLog(@"%@", trans.payment.productIdentifier);
                
                [self.delegate productDidPurchase:self.lastPurchase];
                
                [loading dismissWithClickedButtonIndex:0 animated:YES];
                break;
                
            case SKPaymentTransactionStateFailed:
                [loading dismissWithClickedButtonIndex:0 animated:YES];
                if (trans.error.code != SKErrorPaymentCancelled)
                {
                    NSLog(@"Error! - %@", trans.error);
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:trans.error.localizedFailureReason message:trans.error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                }
                break;    
            default:
                break;
        }
    }
}
                                                        

@end





