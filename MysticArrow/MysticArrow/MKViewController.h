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
#import "MKTargetsViewController.h"

@class MKSpecialLocation;

@interface MKViewController : UIViewController <CLLocationManagerDelegate, ADBannerViewDelegate, MKInAppPurchaseDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    int cLonFactor;
    int cLatFactor;
    
    BOOL spookyScanned;
    BOOL PicAllowed;
    
    CLLocationCoordinate2D lastPosition;
    CLLocationDirection lastHeading;
    
    CLLocationDistance spookyDist;
    
    CLLocationManager *locationManager;
    MKSpecialLocation* currentSpooky;
    
    MKTargetsViewController* select;
    MKOptionsViewController* options;
    MKInAppPurchaseManager* iaManager;
    
    BOOL inMiles;
    CLAuthorizationStatus myStatus;
    
    IBOutlet UIImageView* arrow;
    IBOutlet UIImageView* bgImage;
    
    IBOutlet UILabel* spookyName;
    IBOutlet UILabel* distance;
    
    IBOutlet ADBannerView *adBannerView;
    
    IBOutlet UIButton* picButton;
    IBOutlet UIButton* optButton;
    IBOutlet UIButton* selButton;
    
    UINavigationController* navControl;
    NSDate *baseTimeData;
}

@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) UINavigationController* navControl;
@property(strong, nonatomic) IBOutlet UIImageView* arrow;
@property(strong, nonatomic) IBOutlet UIImageView* bgImage;
@property(strong, nonatomic) IBOutlet ADBannerView *adBannerView;
@property(strong, nonatomic) IBOutlet UILabel* spookyName;
@property(strong, nonatomic) IBOutlet UILabel* distance;
@property(strong, nonatomic) IBOutlet UIButton* picButton;
@property(strong, nonatomic) IBOutlet UIButton* optButton;
@property(strong, nonatomic) IBOutlet UIButton* selButton;

@property(strong, nonatomic) MKOptionsViewController* options;
@property(strong, nonatomic) MKTargetsViewController* select;
@property(strong, nonatomic) MKInAppPurchaseManager* iaManager;

@property(strong, nonatomic) NSArray* CityLocations;
@property(strong, nonatomic) NSDate *baseTimeData;
@property(strong, nonatomic) MKSpecialLocation* currentSpooky;

-(IBAction)onOptions:(id)sender;

-(void) setCurrentTheme: (NSInteger) index;
-(void) setInMiles: (BOOL) mi;
-(bool) distUnits;

-(void) doneButton;
-(void) removeAdButton;

-(void) resetScan;

-(IBAction)onSpookyScan:(id)sender;
-(IBAction)onSelectSpooky:(id)sender;
-(IBAction)onPhotoBtn:(id)sender;
@end
