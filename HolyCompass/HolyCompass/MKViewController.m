//
//  MKViewController.m
//  HolyHeading
//
//  Created by Eitan Levy on 4/23/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import "MKViewController.h"
#import "MKSpecialLocation.h"
#import "MKImageListViewController.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define isIPhone() [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone

@interface MKViewController ()
-(void) checkHeading;
@end

@implementation MKViewController

@synthesize locationManager;
@synthesize arrow;
@synthesize bgImage;
@synthesize adBannerView;
@synthesize options;
@synthesize CityLocations;
@synthesize holycity;
@synthesize cityName;
@synthesize distance;
@synthesize cityLocData;
@synthesize iaManager;
@synthesize navControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    options = [[MKOptionsViewController alloc] initWithNibName:@"MKOptionsView_iPhone" bundle:nil];
    options.parent = self;
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"HHParameters" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* products = [dictionary objectForKey:@"Products"];
    
    iaManager = [[MKInAppPurchaseManager alloc] init];
    [iaManager setupPurchaseManager:products];
    iaManager.delegate = self;
    
    //CLLocationCoordinate2D jerusalem = CLLocationCoordinate2DMake(31.777992, 35.235364);
    //CLLocationCoordinate2D mecca = CLLocationCoordinate2DMake(21.421831, 39.826298);
    //CLLocationCoordinate2D vatican = CLLocationCoordinate2DMake(41.902133, 12.453411);
    
    MKSpecialLocation* jerusalem = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(31.777992, 35.235364) Name:NSLocalizedString(@"JERUSALEM", nil)];
    MKSpecialLocation* mecca = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(21.421831, 39.826298) Name:NSLocalizedString(@"MECCA", nil)];
    MKSpecialLocation* vatican = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(41.902133, 12.453411) Name:NSLocalizedString(@"VATICAN", nil)];
    MKSpecialLocation* bethlehem = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(31.704274, 35.20733) Name:NSLocalizedString(@"BETHLEHEM", nil)];
    MKSpecialLocation* varanasi = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(25.283196, 82.960167) Name:NSLocalizedString(@"VARANASI", nil)];
    MKSpecialLocation* axum = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(14.129704, 38.719543) Name:NSLocalizedString(@"AXUM", nil)];
    MKSpecialLocation* saltlake = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(40.770451, -111.892008) Name:NSLocalizedString(@"SALTLAKE", nil)];
    MKSpecialLocation* angkorwat = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(13.412539, 103.866763) Name:NSLocalizedString(@"ANGKORWAT", nil)];
    MKSpecialLocation* mexico = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(19.690817, -98.846708) Name:NSLocalizedString(@"TEOTIHUACAN", nil)];
    MKSpecialLocation* bodhgaya = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(24.696006, 84.99135) Name:NSLocalizedString(@"BODHGAYA", nil)];
    MKSpecialLocation* giza = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(29.977836, 31.131649) Name:NSLocalizedString(@"PYRAMIDS", nil)];
    MKSpecialLocation* stonehenge = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(51.178765, -1.825919) Name:NSLocalizedString(@"STONEHENGE", nil)];
    MKSpecialLocation* neworleans = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(29.961416, -90.067321) Name:NSLocalizedString(@"NEWORLEANS", nil)];
    
//    MKSpecialLocation* test = [MKSpecialLocation specialLocationWithCoordsAndName:CLLocationCoordinate2DMake(34.633208,-120.344238) Name:@"test"];
    
    CityLocations = [NSArray arrayWithObjects:jerusalem, mecca, vatican, bethlehem, varanasi, axum, saltlake, angkorwat, mexico, bodhgaya, giza, stonehenge, neworleans, nil];
    
    cityDist = 0.0;
    cityLocData = nil;
    
    inMiles = NO;
    
    [self setCityData:0];
    
    myStatus = kCLAuthorizationStatusAuthorized;
    
    CGRect frame = adBannerView.frame;
    frame.origin.y = -50;
    adBannerView.frame = frame;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    // Once configured, the location manager must be "started".
    
    [options loadOptionSettings];
    
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [options saveOptionSettings];

    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIDeviceOrientationPortrait;
}


-(void) checkHeading
{
    //  da house  CLLocationCoordinate2D jerusalem = CLLocationCoordinate2DMake(34.207614, -118.396139);    
    // testing w/ jerusalem first
    CLLocationCoordinate2D targetCoords = [holycity getCoordinates];
    
    double dLong = DEGREES_TO_RADIANS(targetCoords.longitude - lastPosition.longitude);
    double lat1 = DEGREES_TO_RADIANS(lastPosition.latitude);
    double lat2 = DEGREES_TO_RADIANS(targetCoords.latitude);
    double dLat = DEGREES_TO_RADIANS(targetCoords.latitude - lastPosition.latitude);
    
    double R = 6371.0;
    
    double dPhi = log(tan(lat2/2+M_PI/4) / tan(lat1/2+M_PI/4));
    double q = dPhi != 0 ? dLat/dPhi : cos(lat1);
    // if dLon over 180° take shorter rhumb across 180° meridian:
    if (fabs(dLong) > M_PI) {
        dLong = dLong>0 ? -(2*M_PI-dLong) : (2*M_PI+dLong);
    }
    
    double d = sqrt(dLat*dLat + q*q*dLong*dLong);
    
    d *= R;
    
    if ( d > 300 || cityDist > 300 )
    {
        cityDist = d;
    }
    
    double brng =   atan2(dLong, dPhi);
    CLLocationDirection heading = RADIANS_TO_DEGREES(brng);
    
//    NSLog(@"Heading 1 - %F\n distance %F", heading, d);
    
//    NSLog(@" my Heading - %F", lastHeading);
    
    int dist = cityDist;
    
    //kilometers x 0.6214 = miles
    
    if (inMiles) {
        dist = cityDist * 0.6214;
        
        if (dist == 0) {
            distance.text = [NSString stringWithFormat:@"%f - mi.", cityDist];
        }
        else {
            distance.text = [NSString stringWithFormat:@"%d - mi.", dist];
        }
    }
    else {
        
        if (dist == 0) {
            distance.text = [NSString stringWithFormat:@"%f - km.", cityDist];
        }
        else {
            distance.text = [NSString stringWithFormat:@"%d - km", dist];
        }
    }
    
    brng = heading - lastHeading;
    
    arrow.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(brng));

}

#pragma mark - Location Manager methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
//    NSLog(@"%d", status);
   
    if (status == kCLAuthorizationStatusAuthorized && myStatus != kCLAuthorizationStatusAuthorized)
    {
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
    }

    myStatus = status;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //    NSLog(@"From %@ To %@", oldLocation, newLocation);
    
    lastPosition = newLocation.coordinate;
    
    if (cityDist <= 300)
    {    
        cityDist = [cityLocData distanceFromLocation:newLocation] / 1000;
    }
    
    [self checkHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    lastHeading = newHeading.trueHeading;
    
    [self checkHeading];
}

-(IBAction)onOptions:(id)sender
{
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    
    navControl = [[UINavigationController alloc] initWithRootViewController:options];
    
    [self.view addSubview:navControl.view];
   
    CGRect frame = navControl.view.frame;
    frame.origin.y = 480;
    navControl.view.frame = frame;
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGRect frame = navControl.view.frame;
                         frame.origin.y = -20;
                         navControl.view.frame = frame;
                     }
                     completion:^(BOOL finished){
                         if (myStatus == kCLAuthorizationStatusDenied || ![CLLocationManager locationServicesEnabled])
                         {
                             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LOCERROR", nil) message:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LOCERRMSG1", nil), NSLocalizedString(@"LOCERRMSG2", nil)] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                             [alert show];
                         }
                             }];
}

-(void) doneButton
{
//    NSLog(@"BACK");
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
    [options saveOptionSettings];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGRect frame = navControl.view.frame;
                         frame.origin.y = 480;
                         navControl.view.frame = frame;
                     }
                     completion:^(BOOL finished){
                         [navControl.view removeFromSuperview];
                     }];
}

-(void) removeAdButton
{
    bool hide = [[NSUserDefaults standardUserDefaults] boolForKey:@"AdRemoval"];
    if (!hide)
    {
        [self.iaManager makePurchase:@"AdRemoval"];
    }
}

-(void) setCityData: (NSInteger) index
{
    MKSpecialLocation* city = [self.CityLocations objectAtIndex:index];
    self.holycity = city;
    
    cityName.text = city.name;
    
    CLLocationCoordinate2D coord = [city getCoordinates];
    
    cityLocData = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
}

-(void) setInMiles: (BOOL) mi
{
    inMiles = mi;
}

-(bool) distUnits
{
    return inMiles;
}

-(void) productDidPurchase: (NSString*) name
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:name];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([name isEqualToString:@"AdRemoval"])
    {
        adBannerView.hidden = YES;
        [options clearAdsButton];
    }
    else 
    {
        [options.subimages.mySettingsView reloadData];
    }
}

#pragma mark - iAd Banner methods

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [locationManager stopUpdatingLocation];
    [locationManager stopUpdatingHeading];
    
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}

- (void)bannerViewWillLoadAd:(ADBannerView *)banner
{
//    NSLog(@"receiveing ad");
    
    bool hide = [[NSUserDefaults standardUserDefaults] boolForKey:@"AdRemoval"];
    
    if (hide)
    {
        adBannerView.hidden = YES;
        return;
    }

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGRect frame = adBannerView.frame;
                         frame.origin.y = 0;  
                         adBannerView.frame = frame;
                         
                     }
                     completion:nil];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

/*
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        
    }
}
*/


@end
