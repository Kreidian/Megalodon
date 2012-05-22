//
//  MKViewController.h
//  HolyHeading
//
//  Created by Eitan Levy on 4/23/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <iAd/ADBannerView.h>

#import "MKOptionsViewController.h"
#import "MKInAppPurchaseManager.h"

@class MKSpecialLocation;

@interface MKViewController : UIViewController <CLLocationManagerDelegate, ADBannerViewDelegate, MKInAppPurchaseDelegate>
{
    CLLocationCoordinate2D lastPosition;
    CLLocationDirection lastHeading;
    
    CLLocationDistance cityDist;
    
    CLLocationManager *locationManager;
    CLLocation* cityLocData;
    
    MKOptionsViewController* options;
    MKInAppPurchaseManager* iaManager;
    
    NSArray* CityLocations;
    
    BOOL inMiles;
    CLAuthorizationStatus myStatus;
    
    IBOutlet UIImageView* arrow;
    IBOutlet UIImageView* bgImage;
    
    IBOutlet UILabel* cityName;
    IBOutlet UILabel* distance;
    
    IBOutlet ADBannerView *adBannerView;
    
    UINavigationController* navControl;
}

@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) UINavigationController* navControl;
@property(strong, nonatomic) IBOutlet UIImageView* arrow;
@property(strong, nonatomic) IBOutlet UIImageView* bgImage;
@property(strong, nonatomic) IBOutlet ADBannerView *adBannerView;
@property(strong, nonatomic) IBOutlet UILabel* cityName;
@property(strong, nonatomic) IBOutlet UILabel* distance;

@property(strong, nonatomic) MKOptionsViewController* options;
@property(strong, nonatomic) MKInAppPurchaseManager* iaManager;

@property(strong, nonatomic) NSArray* CityLocations;
@property(strong, nonatomic) CLLocation* cityLocData;
@property(weak, nonatomic) MKSpecialLocation* holycity;

-(IBAction)onOptions:(id)sender;

-(void) setCityData: (NSInteger) index;
-(void) setInMiles: (BOOL) mi;
-(bool) distUnits;


-(void) doneButton;
-(void) removeAdButton;
@end
