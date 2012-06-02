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
        lastSpookySelected = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //view.layer.cornerRadius = 10;
    self.title = NSLocalizedString(@"OPTIONS", nil);
    
    UIBarButtonItem* donebtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backButton:)];
    //UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* removeAds = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"REMOVEADS", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(removeAdsSelected:)];
    
    //[self setToolbarItems:[NSArray arrayWithObjects:donebtn, space, removeAds, nil] animated:YES];
    self.navigationItem.leftBarButtonItem = donebtn;
    self.navigationItem.rightBarButtonItem = removeAds;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

-(IBAction)backButton:(id)sender
{
    NSLog(@"BACK");
/*    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* pointers = [dictionary objectForKey:@"Pointers"];
    NSArray* skins = [dictionary objectForKey:@"Skins"];
    
    self.parent.bgImage.image = [UIImage imageNamed:[skins objectAtIndex:lastSelectedBG]];
    self.parent.arrow.image = [UIImage imageNamed:[pointers objectAtIndex:lastPointerSel]];
 */   
    [parent doneButton];
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


-(int) getLastSelectedTheme
{
    return  lastSelectedTheme;
}

-(int) getLastSpookySelected
{
    return lastSpookySelected;
}

-(void) setLastSelectedTheme: (NSInteger) index
{
    lastSelectedTheme = index;
}

-(void) setLastSpookySelected: (NSInteger) index
{
    if (lastSpookySelected != index)
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
        NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray* spookies = [dictionary objectForKey:@"Spookies"];
        
        NSString* name = [spookies objectAtIndex:index];
        NSLog(@"%@", name);
        
        self.parent.spookyName.text = NSLocalizedString(name, nil);
        
        lastSpookySelected = index;
        
        [self.parent resetScan];
    }
}

#pragma mark - TableView data source and delegate methods


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OptionCell"]; 
    }
    
    cell.selected = NO;
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* assets = nil;
    
    switch (indexPath.section) {
        case 0: // distance settings
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
        case 1: // theme choice
            
            assets = [dictionary objectForKey:@"Themes"];
            
            cell.textLabel.text =  NSLocalizedString([assets objectAtIndex:indexPath.row], nil);
            
            if (indexPath.row == lastSelectedTheme)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
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
     return 2;
 }
 
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
     NSString *titleName;
     switch (section) {
         case 0:
             titleName =  NSLocalizedString(@"SETTINGS", nil);
             break;
         case 1:
             titleName =  NSLocalizedString(@"THEME", nil);
             break;
            
         default:
             break;
     }
     
     return titleName;
 }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = 1;
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* assets = nil;
    
    switch (section) {
        case 0:
        //    assets = [dictionary objectForKey:@"Spookies"];
            count = 1;
            break;
        case 1:
            assets = [dictionary objectForKey:@"Themes"];
            count = assets.count;
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
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    
    switch (indexPath.section) {
        case 0:
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
        case 1:
            [parent setCityData:indexPath.row];
            lastSelectedTheme = indexPath.row;
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
    [[NSUserDefaults standardUserDefaults] setInteger:lastSelectedTheme forKey:kCitySelectedStr];
//    [[NSUserDefaults standardUserDefaults] setInteger:lastSelectedBG forKey:kBGSelectedStr];
//    [[NSUserDefaults standardUserDefaults] setInteger:lastPointerSel forKey:kPointerSelectedStr];
    [[NSUserDefaults standardUserDefaults] setDouble:parent.locationManager.desiredAccuracy forKey:kLocAccuracyStr];
    [[NSUserDefaults standardUserDefaults] setBool:self.parent.distance.hidden forKey:kHideDistanceStr];
    [[NSUserDefaults standardUserDefaults] setBool:[self.parent distUnits]  forKey:kUnitsInMilesStr];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) loadOptionSettings
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* Themes = [dictionary objectForKey:@"Themes"];

    NSInteger cidx = [[NSUserDefaults standardUserDefaults] integerForKey:kCitySelectedStr];
    lastSelectedTheme = cidx;
    [self.parent setCityData:cidx];
    
    cidx = [[NSUserDefaults standardUserDefaults] integerForKey:kBGSelectedStr];
    self.parent.bgImage.image = [UIImage imageNamed:[Themes objectAtIndex:cidx]];
//    lastSelectedBG = cidx;
    
    cidx = [[NSUserDefaults standardUserDefaults] integerForKey:kPointerSelectedStr];
    self.parent.arrow.image = [UIImage imageNamed:[Themes objectAtIndex:cidx]];
//    lastPointerSel = cidx;
    
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
