//
//  MKInAppPurchaseManager.h
//  HolyHeading
//
//  Created by Eitan Levy on 4/27/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol MKInAppPurchaseDelegate <NSObject>

-(void) productDidPurchase: (NSString*) name;

@end

@interface MKInAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> 
{
    BOOL purchaseEnabled;
    NSString* lastPurchase;
    NSArray* myProducts;
}

@property(strong, nonatomic) NSArray* myProducts;
@property(strong, nonatomic) NSString* lastPurchase;

-(void) setupPurchaseManager: (NSArray*) products;
-(void) makePurchase:(NSString*) name;

@property(weak, nonatomic) id <MKInAppPurchaseDelegate> delegate;

@end
