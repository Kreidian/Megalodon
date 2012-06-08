//
//  MKViewController.m
//  HolyHeading
//
//  Created by Eitan Levy on 4/23/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import "MKViewController.h"
#import "MKSpecialLocation.h"
#import "MKCapturedImageViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/CAAnimation.h>

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define isIPhone() [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone

#define kMinPicAllowedDist 10

@interface MKViewController ()
{
    MKCapturedImageViewController* capture;
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
-(void) checkHeading;
- (NSString *) md5:(NSString *) input;
-(void) scanForSpooky;
-(void) takePhoto;
-(void) loadPic;
@end

@implementation MKViewController

@synthesize locationManager;
@synthesize arrow;
@synthesize bgImage;
@synthesize adBannerView;
@synthesize options;
@synthesize select;
@synthesize CityLocations;
@synthesize currentSpooky;
@synthesize spookyName;
@synthesize distance;
@synthesize baseTimeData;
@synthesize iaManager;
@synthesize navControl;
@synthesize picButton;
@synthesize optButton;
@synthesize selButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    options = [[MKOptionsViewController alloc] initWithNibName:@"MKOptionsView_iPhone" bundle:nil];
    options.parent = self;
    
    select = [[MKTargetsViewController alloc] initWithNibName:@"MKTargetsView_iPhone" bundle:nil];
    select.parent = self;
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* products = [dictionary objectForKey:@"Products"];
    
    iaManager = [[MKInAppPurchaseManager alloc] init];
    [iaManager setupPurchaseManager:products];
    iaManager.delegate = self;
    
    
    inMiles = NO;
    spookyScanned = NO;
    PicAllowed = NO;
    
    [self setCurrentTheme:0];
    
    myStatus = kCLAuthorizationStatusAuthorized;
    
    CGRect frame = adBannerView.frame;
    frame.origin.y = -50;
    adBannerView.frame = frame;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // Once configured, the location manager must be "started".
    
    [options loadOptionSettings];
        
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    
    NSArray* spookies = [dictionary objectForKey:@"Spookies"];
    NSString* sName = [spookies objectAtIndex:[self.options getLastSpookySelected]];
    
    self.spookyName.text = NSLocalizedString(sName, nil);
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
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


-(void) checkHeading
{
    if (!spookyScanned)
        return;
    
    CLLocationCoordinate2D targetCoords = [currentSpooky getCoordinates];
    NSDate* date = [NSDate date];
    double delta = [date timeIntervalSinceDate:baseTimeData];
    
    delta /= 86400000000.0;
    
    targetCoords.longitude += delta * cLonFactor;
    targetCoords.latitude += delta * cLatFactor;
    
    double dLong = DEGREES_TO_RADIANS(targetCoords.longitude - lastPosition.longitude);
    double lat1 = DEGREES_TO_RADIANS(lastPosition.latitude);
    double lat2 = DEGREES_TO_RADIANS(targetCoords.latitude);
//    double dLat = DEGREES_TO_RADIANS(targetCoords.latitude - lastPosition.latitude);
    
//    double R = 6371.0;
    
    double dPhi = log(tan(lat2/2+M_PI/4) / tan(lat1/2+M_PI/4));
//    double q = dPhi != 0 ? dLat/dPhi : cos(lat1);
    // if dLon over 180° take shorter rhumb across 180° meridian:
    if (fabs(dLong) > M_PI) {
        dLong = dLong>0 ? -(2*M_PI-dLong) : (2*M_PI+dLong);
    }
/*    
    double d = sqrt(dLat*dLat + q*q*dLong*dLong);
    
    d *= R; 
*/
    double brng =   atan2(dLong, dPhi);
    CLLocationDirection heading = RADIANS_TO_DEGREES(brng);
    
//    NSLog(@"Heading 1 - %F\n distance %F", heading, d);
//    NSLog(@" my Heading - %F", lastHeading);
    
    int dist = spookyDist;
    
    //kilometers x 0.6214 = miles
    // 1 meter = 3.2808399 feet 
    if (inMiles) {
        dist *= 3.2808399;
        
        distance.text = [NSString stringWithFormat:@"%d - ft.", dist];
    }
    else {
        if (dist == 0) {
            distance.text = [NSString stringWithFormat:@"%f - m.", spookyDist];
        }
        else {
            distance.text = [NSString stringWithFormat:@"%d - m", dist];
        }
    }
    
    brng = heading - lastHeading;
    
    arrow.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(brng));

    if ( dist <= kMinPicAllowedDist )
    {
        if (PicAllowed == NO)
        {
            NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
            NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
            NSArray* Themes = [dictionary objectForKey:@"Themes"];
            NSString* name = [Themes objectAtIndex:[self.options getLastSelectedTheme]];
            NSString* btnName = [NSString stringWithFormat:@"ButMain-%@.png", name];
            [self.picButton setImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
        }
        
        PicAllowed = YES;
    }
    else 
    {
        if (PicAllowed == YES)
        {
            NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
            NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
            NSArray* Themes = [dictionary objectForKey:@"Themes"];
            NSString* name = [Themes objectAtIndex:[self.options getLastSelectedTheme]];
            NSString* btnName = [NSString stringWithFormat:@"ButOff-%@.png", name];
            [self.picButton setImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
        }
        
        PicAllowed = NO;
    }
}

#pragma mark - Location Manager methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"%d", status);
   
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
    
    CLLocationCoordinate2D refLoc = [currentSpooky getCoordinates];
    CLLocation* spookyLoc = [[CLLocation alloc] initWithLatitude:refLoc.latitude longitude:refLoc.longitude];
    
    if (spookyScanned)
    {
        spookyDist = [newLocation distanceFromLocation:spookyLoc];
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
                         frame.origin.y = 0;
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
    NSLog(@"BACK");
    
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
    [self.iaManager makePurchase:@"AdRemoval"];
}

-(void) setCurrentTheme: (NSInteger) index
{
    if (index != [self.options getLastSelectedTheme]) 
        return;
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* Themes = [dictionary objectForKey:@"Themes"];
    NSString* name = [Themes objectAtIndex:index];
    NSString* picName = nil; 
    NSString* optName = [NSString stringWithFormat:@"ButOpt-%@.png", name];
    NSString* SelName = [NSString stringWithFormat:@"ButSel-%@.png", name];
    NSString* bgName = [NSString stringWithFormat:@"Back-%@.png", name];
    NSString* AName = [NSString stringWithFormat:@"Arrow-%@.png", name];
    
    if (PicAllowed) {
        picName = [NSString stringWithFormat:@"ButMain-%@.png", name];
    } else {
        picName = [NSString stringWithFormat:@"ButOff-%@.png", name];
    }
    
    [self.picButton setImage:[UIImage imageNamed:picName] forState:UIControlStateNormal];
    [self.optButton setImage:[UIImage imageNamed:optName] forState:UIControlStateNormal];
    [self.selButton setImage:[UIImage imageNamed:SelName] forState:UIControlStateNormal];
    bgImage.image = [UIImage imageNamed:bgName];
    arrow.image = [UIImage imageNamed:AName];
    
    UIColor* fText = nil;
    UIColor* bText = nil;
    
    switch (index) {
        case 0:
            fText = [UIColor blackColor];
            break;
        case 1:
            fText = [UIColor yellowColor];
            bText = [UIColor blackColor];
            break;
        case 2:
            fText = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
            break;
        case 3:
            fText = [UIColor blackColor];
            bText = [UIColor lightGrayColor];
            break;
        case 4:
            fText = [UIColor greenColor];
            break;
        case 5:
            fText = [UIColor whiteColor];
            bText = [UIColor blackColor];
            break;    
        default:
            break;
    }

    self.spookyName.textColor = fText;
    self.distance.textColor = fText;
    
    if (bText != nil)
    {
        CGSize size = CGSizeMake(1, 1);
        
        self.spookyName.shadowColor = bText;
        self.spookyName.shadowOffset = size;
        self.distance.shadowColor = bText;
        self.distance.shadowOffset = size;
    }
    else 
    {
        CGSize size = CGSizeMake(0, 0);
        
        self.spookyName.shadowColor = bText;
        self.spookyName.shadowOffset = size;
        self.distance.shadowColor = bText;
        self.distance.shadowOffset = size;
    }
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
    }
    else 
    {
        [options.mySettingsView reloadData];
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
    NSLog(@"receiveing ad");
    
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

#pragma mark - select

-(IBAction)onSelectSpooky:(id)sender
{
    navControl = [[UINavigationController alloc] initWithRootViewController:select];
    
    [self.view addSubview:navControl.view];
    
    CGRect frame = navControl.view.frame;
    frame.origin.y = 480;
    navControl.view.frame = frame;
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGRect frame = navControl.view.frame;
                         frame.origin.y = 0;
                         navControl.view.frame = frame;
                     }
                     completion:nil];
}

#pragma mark - photo

-(IBAction)onPhotoBtn:(id)sender
{
//    [locationManager stopUpdatingLocation];
//    [locationManager stopUpdatingHeading];
    if (PicAllowed)
        [self takePhoto];
}

-(void) takePhoto
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (isIPhone())
            [self loadPic];
        return;
    }
    
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    
    // Delegate is self
    imagePicker.delegate = self;
    
    // Allow editing of image ?
    imagePicker.allowsEditing = NO;
    
    // Show image picker
    [self presentModalViewController:imagePicker animated:YES];
    
    [self resetScan];
}

-(void) loadPic
{
    // Create image picker controller
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // Set source to the camera
    imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Delegate is self
    imagePicker.delegate = self;
    
    // Allow editing of image ?
    imagePicker.allowsEditing = NO;
    
    // Show image picker
    [self presentModalViewController:imagePicker animated:YES];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    capture = [[MKCapturedImageViewController alloc] initWithImage:image];
    capture.parent = self;
    
    [self.view addSubview:capture.view];
    
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - spoky scan

-(IBAction)onSpookyScan:(id)sender
{
    self.distance.text = NSLocalizedString(@"SCANNING", nil);
//    [locationManager startUpdatingLocation];
//    [locationManager startUpdatingHeading];
    [self runSpinAnimationOnView:self.arrow duration:1 rotations:1 repeat:2];
    [self performSelector:@selector(scanForSpooky) withObject:nil afterDelay:2];
    
//    [self scanForSpooky];
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void) resetScan
{
    spookyScanned = NO;
    self.distance.text = @"";
    self.arrow.transform = CGAffineTransformMakeRotation(0.0);
    PicAllowed = NO;
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* Themes = [dictionary objectForKey:@"Themes"];
    NSString* name = [Themes objectAtIndex:[self.options getLastSelectedTheme]];
    NSString* btnName = [NSString stringWithFormat:@"ButOff-%@.png", name];
    [self.picButton setImage:[UIImage imageNamed:btnName] forState:UIControlStateNormal];
}

-(void) scanForSpooky
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* spookies = [dictionary objectForKey:@"Spookies"];
    NSString* spookName = [spookies objectAtIndex:[self.options getLastSpookySelected]];
    
    NSDate* date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *baseDay = [dateFormatter dateFromString:[formattedDateString stringByAppendingFormat:@"000000"]];
        
    NSString* data = [NSString stringWithFormat:@"%@-8kEyPhRaSe8-%@", formattedDateString, spookyName ];
    
    NSString* hash = [self md5:data];
    
    NSString* one = [NSString stringWithFormat:@"0x%@",[hash substringToIndex:16]];
    NSString* two = [NSString stringWithFormat:@"0x%@",[hash substringFromIndex:16]];
    
    NSScanner* value1 = [NSScanner scannerWithString:[one substringToIndex:5]];
    NSScanner* value2 = [NSScanner scannerWithString:[two substringToIndex:5]];
    
    one = [NSString stringWithFormat:@"0x%@",[hash substringWithRange:NSMakeRange(6, 2)]];
    two = [NSString stringWithFormat:@"0x%@",[hash substringWithRange:NSMakeRange(22, 2)]];
    
    NSScanner* value3 = [NSScanner scannerWithString:one];
    NSScanner* value4 = [NSScanner scannerWithString:two];
    
    one = [NSString stringWithFormat:@"0x%@",[hash substringWithRange:NSMakeRange(8, 2)]];
    two = [NSString stringWithFormat:@"0x%@",[hash substringWithRange:NSMakeRange(24, 2)]];
    
    NSScanner* value5 = [NSScanner scannerWithString:one];
    NSScanner* value6 = [NSScanner scannerWithString:two];
    
    unsigned int val1test = 0;
    unsigned int val2test = 0;
    unsigned int val3test = 0;
    unsigned int val4test = 0;
    unsigned int val5test = 0;
    unsigned int val6test = 0;
    
    [value1 scanHexInt:&val1test];
    [value2 scanHexInt:&val2test];
    [value3 scanHexInt:&val3test];
    [value4 scanHexInt:&val4test];
    [value5 scanHexInt:&val5test];
    [value6 scanHexInt:&val6test];
    
    val5test = val5test % 3;
    val6test = val6test % 3;
    
    val1test = val1test % 1000;
    val2test = val2test % 1000;
    double latMod = val1test / 10000000.0;
    double lonMod = val2test / 10000000.0;
    
    CLLocationCoordinate2D testCoords;
    testCoords = lastPosition;

//    testCoords.latitude = 34.207366;
//    testCoords.longitude = -118.396182;
    NSLog(@"%.10f, %.10f, %.10f, %.10f", latMod, lonMod, testCoords.latitude, testCoords.longitude);

    int stripper = testCoords.latitude * 10000;
    testCoords.latitude = stripper / 10000.0;
    stripper = testCoords.longitude * 10000;
    testCoords.longitude = stripper / 10000.0;
    testCoords.latitude += latMod;
    testCoords.longitude += lonMod;
    
    NSLog(@"%d, %d, %d, %d", val1test, val2test, val3test, val4test);
    
    BOOL latDir = val3test % 2;
    BOOL lonDir = val4test % 2;
    
    cLatFactor = latDir ? -val5test : val5test;
    cLonFactor = lonDir ? -val6test : val6test;
    
    NSLog(@"Direction: %d ,%d\n Latitude: %.20f \n Longitude %.20f", latDir, lonDir, testCoords.latitude, testCoords.longitude);
    
    currentSpooky = [MKSpecialLocation specialLocationWithCoordsAndName:testCoords Name:spookName];
    baseTimeData = baseDay;
    
    spookyScanned = YES;
}

- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

@end
