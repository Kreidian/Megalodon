//
//  MKOptionsViewController.m
//  HolyHeading
//
//  Created by Eitan Levy on 4/24/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import "MKOptionsViewController.h"
#import "MKViewController.h"
#import "MKSpecialLocation.h"
#import "MKImageViewCell.h"
#import "MKImageListViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kCitySelectedStr @"CitySelected"
#define kBGSelectedStr @"BGSelected"
#define kPointerSelectedStr @"PointerSelected"
#define kLocAccuracyStr @"LocAccuracySetting"
#define kHideDistanceStr @"HideDistance"
#define kUnitsInMilesStr @"IsUnitsMiles"

@interface MKOptionsViewController ()

@end

@implementation MKOptionsViewController

@synthesize navBar;
@synthesize removeAdsButton;
@synthesize mySettingsView;
@synthesize parent;
@synthesize pImageCell;
@synthesize subimages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //navBar
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    subimages = [[MKImageListViewController alloc] init];
    subimages.parent = self;
    
    //view.layer.cornerRadius = 10;
    self.title = NSLocalizedString(@"OPTIONS", nil);
    
    UIBarButtonItem* donebtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backButton:)];
    //UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* removeAds = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"REMOVEADS", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(removeAdsSelected:)];
    
    //[self setToolbarItems:[NSArray arrayWithObjects:donebtn, space, removeAds, nil] animated:YES];
    self.navigationItem.leftBarButtonItem = donebtn;
    
    bool hide = [[NSUserDefaults standardUserDefaults] boolForKey:@"AdRemoval"];
    if (!hide)
    {
        self.navigationItem.rightBarButtonItem = removeAds;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)backButton:(id)sender
{
//    NSLog(@"BACK");
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"HHParameters" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* pointers = [dictionary objectForKey:@"Pointers"];
    NSArray* skins = [dictionary objectForKey:@"Skins"];
    
    self.parent.bgImage.image = [UIImage imageNamed:[skins objectAtIndex:lastSelectedBG]];
    self.parent.arrow.image = [UIImage imageNamed:[pointers objectAtIndex:lastPointerSel]];
    
    [parent doneButton];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return parent.CityLocations.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    MKSpecialLocation* city = [parent.CityLocations objectAtIndex:row];
    return city.name;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [parent setCityData:row];
}

-(IBAction)distanceSwitch:(UISwitch*)sender
{
    BOOL isON = sender.on;
    parent.distance.hidden = !isON;
}

- (IBAction)locationPresicionChanged:(id)sender
{
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) 
    {
        case 0:
            parent.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            break;
        case 1:
            parent.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            break;
        case 2:
            parent.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            break;
        default:
            break;
    }
}

- (IBAction)distanceUnitsChanged:(id)sender
{
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) 
    {
        case 0:
            [parent setInMiles:YES];
            break;
        case 1:
            [parent setInMiles:NO];
            break;
        default:
            break;
    }
}

-(IBAction)removeAdsSelected:(id)sender
{
    [parent removeAdButton];
}

-(void) clearAdsButton
{
    self.navigationItem.rightBarButtonItem = nil;
}

-(void) setLastSelectedBG: (NSInteger) index
{
    lastSelectedBG = index;
}

-(void) setLastPointerSel: (NSInteger) index
{
    lastPointerSel = index;
}

#pragma mark - TableView data source and delegate methods


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell"];
    MKImageViewCell *imgCell = nil;
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TestCell"]; 
    }
    
    cell.selected = NO;
    
    MKSpecialLocation* city = nil;
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"HHParameters" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* assets = nil;
    NSString* imgBanner= nil;
    
    switch (indexPath.section) {
        case 0: // city selections
            city = [parent.CityLocations objectAtIndex:indexPath.row];
            cell.textLabel.text = city.name;
            cell.accessoryType = lastCitySelected == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone; 
            break;
        case 1: // compass resolution
            cell.accessoryType = UITableViewCellAccessoryNone; 
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"BEST", nil);
                    if ( parent.locationManager.desiredAccuracy == kCLLocationAccuracyBestForNavigation ) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark; 
                    }
                    break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"BETTER", nil);
                    if ( parent.locationManager.desiredAccuracy == kCLLocationAccuracyBest ) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark; 
                    }
                    break;
                case 2:
                    cell.textLabel.text = NSLocalizedString(@"GOOD", nil);
                    if ( parent.locationManager.desiredAccuracy == kCLLocationAccuracyNearestTenMeters ) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark; 
                    }
                    break;
                case 3:
                    cell.textLabel.text = NSLocalizedString(@"ENOUGH", nil);
                    if ( parent.locationManager.desiredAccuracy == kCLLocationAccuracyHundredMeters ) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark; 
                    }
                    break;  
                default:
                    break;
            }
            break;
        case 2: // distance settings
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"DISTANCE", nil);
                    cell.accessoryType = parent.distance.hidden ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                    break;
                case 1:
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    if ( [self.parent distUnits] )
                    {
                        cell.textLabel.text =  NSLocalizedString(@"MILES", nil);
                    }
                    else 
                    {
                        cell.textLabel.text =  NSLocalizedString(@"KILOMETERS", nil);
                    }
                    break;
                    
                default:
                    break;
            }
            break; 
        case 3: // bg choice
            imgCell =  [tableView dequeueReusableCellWithIdentifier:@"MKImageViewCell"];
            if (imgCell == nil)
            {
                [[NSBundle mainBundle] loadNibNamed:@"PureImageCell" owner:self options:nil];
                imgCell = self.pImageCell;
                self.pImageCell = nil;
            }
            
            assets = [dictionary objectForKey:@"Skins"];
            imgBanner = [NSString stringWithFormat:@"Banner-%@", [assets objectAtIndex:lastSelectedBG]];
            
            imgCell.mainImage.image = [UIImage imageNamed:imgBanner];
            imgCell.coinImage.image = nil;

            cell = imgCell;
            break;
        case 4:
            imgCell =  [tableView dequeueReusableCellWithIdentifier:@"MKImageViewCell"];
            if (imgCell == nil)
            {
                [[NSBundle mainBundle] loadNibNamed:@"PureImageCell" owner:self options:nil];
                imgCell = self.pImageCell;
                self.pImageCell = nil;
            }
            
            assets = [dictionary objectForKey:@"Pointers"];
            imgBanner = [NSString stringWithFormat:@"Banner-%@", [assets objectAtIndex:lastPointerSel]];
            
            imgCell.mainImage.image = [UIImage imageNamed:imgBanner];
            imgCell.coinImage.image = nil;

            cell = imgCell;
            break;
            
        default:
            break;
    }
    
    return cell;
}
/*
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
 {
 return [NSArray arrayWithObjects:@"1", @"2",  @"3", @"4", @"5", @"6", @"7", @"8", @"9",nil];
 }
 */
 
 - (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
 {
     return 5;
 }
 
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
     NSString *titleName;
     switch (section) {
         case 0:
             titleName =  NSLocalizedString(@"CITY", nil);
             break;
         case 1:
             titleName =  NSLocalizedString(@"PRESICION", nil);
             break;
         case 2:
             titleName =  NSLocalizedString(@"SETTINGS", nil);
             break; 
         case 3:
             titleName =  NSLocalizedString(@"CURRBG", nil);
             break;
         case 4:
             titleName =  NSLocalizedString(@"CURRPTR", nil);
             break;
            
         default:
             break;
     }
     
     return titleName;
 }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = 1;
    
    switch (section) {
        case 0:
            count = self.parent.CityLocations.count;
            break;
        case 1:
            count = 4;
            break;
        case 2:
            count = 2;
            break; 
        case 3:
            count = 1;
            break;
        case 4:
            count = 1;
            break;
            
        default:
            break;
    }

    
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    NSString * path = [[NSBundle mainBundle] pathForResource:@"HHParameters" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    
    switch (indexPath.section) {
        case 0:
            [parent setCityData:indexPath.row];
            lastCitySelected = indexPath.row;
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    parent.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
                    break;
                case 1:
                    parent.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                    break;
                case 2:
                    parent.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                    break;
                case 3:
                    parent.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                    break;
                    
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    parent.distance.hidden = !parent.distance.hidden;
                    break;
                case 1:
                    if ( [self.parent distUnits] )
                    {
                        [parent setInMiles:NO];
                        cell.textLabel.text =  NSLocalizedString(@"KILOMETERS", nil);
                    }
                    else 
                    {
                        [parent setInMiles:YES];
                        cell.textLabel.text =  NSLocalizedString(@"MILES", nil);
                    }
                    break;

                default:
                    break;
            }
            break; 
        case 3:
            self.subimages.images = [dictionary objectForKey:@"Skins"];
            [self.subimages setImageTypes:YES];
            [self.subimages rebuildDisplayLists:self.subimages.images];
            [self.navigationController pushViewController:self.subimages animated:YES];
            [self.subimages.mySettingsView reloadData];
            break;
        case 4:
            self.subimages.images = [dictionary objectForKey:@"Pointers"];
            [self.subimages setImageTypes:NO];
            [self.subimages rebuildDisplayLists:self.subimages.images];
            [self.navigationController pushViewController:self.subimages animated:YES];
            [self.subimages.mySettingsView reloadData];
            break;
            
        default:
            break;
    }

    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


-(void) saveOptionSettings
{    
    //NSInteger cidx = [parent.CityLocations indexOfObject:parent.holycity];
    [[NSUserDefaults standardUserDefaults] setInteger:lastCitySelected forKey:kCitySelectedStr];
    [[NSUserDefaults standardUserDefaults] setInteger:lastSelectedBG forKey:kBGSelectedStr];
    [[NSUserDefaults standardUserDefaults] setInteger:lastPointerSel forKey:kPointerSelectedStr];
    [[NSUserDefaults standardUserDefaults] setDouble:parent.locationManager.desiredAccuracy forKey:kLocAccuracyStr];
    [[NSUserDefaults standardUserDefaults] setBool:self.parent.distance.hidden forKey:kHideDistanceStr];
    [[NSUserDefaults standardUserDefaults] setBool:[self.parent distUnits]  forKey:kUnitsInMilesStr];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) loadOptionSettings
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"HHParameters" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* Skins = [dictionary objectForKey:@"Skins"];
    NSArray* Pointers = [dictionary objectForKey:@"Pointers"];
    
    NSInteger cidx = [[NSUserDefaults standardUserDefaults] integerForKey:kCitySelectedStr];
    lastCitySelected = cidx;
    [self.parent setCityData:cidx];
    
    cidx = [[NSUserDefaults standardUserDefaults] integerForKey:kBGSelectedStr];
    self.parent.bgImage.image = [UIImage imageNamed:[Skins objectAtIndex:cidx]];
    lastSelectedBG = cidx;
    
    cidx = [[NSUserDefaults standardUserDefaults] integerForKey:kPointerSelectedStr];
    self.parent.arrow.image = [UIImage imageNamed:[Pointers objectAtIndex:cidx]];
    lastPointerSel = cidx;
    
    CLLocationAccuracy accuracy = [[NSUserDefaults standardUserDefaults] doubleForKey:kLocAccuracyStr];
    if (accuracy == 0)
    {
        accuracy = kCLLocationAccuracyBest;
    }
    parent.locationManager.desiredAccuracy = accuracy;

    bool value = [[NSUserDefaults standardUserDefaults] boolForKey:kHideDistanceStr];
    self.parent.distance.hidden = value;

    value = [[NSUserDefaults standardUserDefaults] boolForKey:kUnitsInMilesStr];
    [self.parent setInMiles:value];
    
}

@end
