//
//  MKImageListViewController.m
//  HolyHeading
//
//  Created by Eitan Levy on 5/7/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import "MKImageListViewController.h"
#import "MKOptionsViewController.h"
#import "MKViewController.h"

@interface MKImageListViewController ()

@end

@implementation MKImageListViewController

@synthesize pImageCell;
@synthesize mySettingsView;
@synthesize groupTitle;
@synthesize parent;
@synthesize images;
@synthesize grpImages;
@synthesize grpSections;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGRect frame = self.view.frame;
    frame.origin.y = -20;
    mySettingsView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    mySettingsView.delegate = self;
    mySettingsView.dataSource = self;
//    [mySettingsView setBackgroundColor:[UIColor brownColor]];
    
    [self.view addSubview:mySettingsView];
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

-(void) setImageTypes: (BOOL) isBackgrounds
{
    bgFlag = isBackgrounds;
    
    self.title = bgFlag ? NSLocalizedString(@"BGMENU", nil) : NSLocalizedString(@"PTRMENU", nil);
}

#pragma mark - rebuilding display lists

-(void) rebuildDisplayLists: (NSArray*) imgList
{
    NSString * path = [[NSBundle mainBundle] pathForResource:@"HHParameters" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary* packages = [dictionary objectForKey:@"PackageRef"];
    NSString* packName = nil;
    
    NSMutableArray* allGroups = [[NSMutableArray alloc] init];
    NSMutableDictionary* allImageList = [[NSMutableDictionary alloc] init];
    NSMutableArray* subImageList = [[NSMutableArray alloc] init];
    
    // add the free stuff first
    [allGroups addObject:NSLocalizedString(@"FREE", nil)]; 
    [allImageList setObject:subImageList forKey:NSLocalizedString(@"FREE", nil)];
    
    for (NSString* imgName in imgList) {
        packName = [packages objectForKey:imgName];
        
        if (packName == nil || [packName isEqualToString:@""])
        {
            subImageList = [allImageList objectForKey:NSLocalizedString(@"FREE", nil)];
            NSLog(@"Add SubImg %@",imgName);
            [subImageList addObject:imgName];
        }
        else 
        {
            packName = [self localizeGroupDisplayName:packName];
            
            if ( [allGroups containsObject:packName] ) {
                subImageList = [allImageList objectForKey:packName];
                NSLog(@"Add SubImg %@",imgName);
                [subImageList addObject:imgName];
            }
            else {
                NSLog(@"Add group %@",packName);
                [allGroups addObject:packName];
                NSMutableArray* subImageList = [[NSMutableArray alloc] init];
                [subImageList addObject:imgName];
                [allImageList setObject:subImageList forKey:packName];
            }
        }
        
    }
    
    grpSections = [NSArray arrayWithArray:allGroups];
    grpImages = [NSDictionary dictionaryWithDictionary:allImageList];

}

-(NSString*)localizeGroupDisplayName:(NSString*) groupName
{
    NSString* temp = nil;
    unichar num = 0;
    
    if (bgFlag) {
        if ([groupName compare:@"BgPack" options:NSLiteralSearch range:NSMakeRange(0, 6)] == NSOrderedSame) {
            num = [groupName characterAtIndex:6];
            temp = [NSString stringWithFormat:@"%@ %C", NSLocalizedString(@"BGPACK", nil), num];
        }
    }
    else {
        if ([groupName compare:@"PPack" options:NSLiteralSearch range:NSMakeRange(0, 5)] == NSOrderedSame) {
            num = [groupName characterAtIndex:5];
            temp = [NSString stringWithFormat:@"%@ %C", NSLocalizedString(@"PPACK", nil), num];
        }
    }
    
    return temp;
}

#pragma mark - TableView data source and delegate methods


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKImageViewCell *imgCell =  [tableView dequeueReusableCellWithIdentifier:@"MKImageViewCell"];
    if (imgCell == nil)
    {
        //imgCell = [MKImageViewCell alloc] initWithStyle:<#(UITableViewCellStyle)#> reuseIdentifier:<#(NSString *)#>
        [[NSBundle mainBundle] loadNibNamed:@"SubImageCell" owner:self options:nil];
        imgCell = self.pImageCell;
        self.pImageCell = nil;
    }
    
    NSString* packName = [grpSections objectAtIndex:indexPath.section];
    NSArray* imgsForSection = [grpImages objectForKey:packName];
    
    NSString* imgName = [imgsForSection objectAtIndex:indexPath.row];
    
    if (indexPath.section > 0)
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"HHParameters" ofType:@"plist"];
        NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        NSDictionary* packages = [dictionary objectForKey:@"PackageRef"];
        packName = [packages objectForKey:imgName];
        
        if (packName != nil && [[NSUserDefaults standardUserDefaults] boolForKey:packName] == NO)
        {
            imgCell.coinImage.image = [UIImage imageNamed:@"tricoin.png"];
        }
        else {
            imgCell.coinImage.image = nil;
        }
    }

    NSString* imgBanner = [NSString stringWithFormat:@"Banner-%@", imgName];
    imgCell.mainImage.image = [UIImage imageNamed:imgBanner];

    NSLog(@"%@ - %@", packName, imgName);
        
    return imgCell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.grpSections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.grpSections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* packName = [grpSections objectAtIndex:section];
    NSArray* imgsForSection = [grpImages objectForKey:packName];
    
    return imgsForSection.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* packName = [grpSections objectAtIndex:indexPath.section];
    NSArray* imgsForSection = [grpImages objectForKey:packName];
    NSString* imgName = [imgsForSection objectAtIndex:indexPath.row];
    
    if (indexPath.section > 0)
    {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"HHParameters" ofType:@"plist"];
        NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        NSDictionary* packages = [dictionary objectForKey:@"PackageRef"];
        packName = [packages objectForKey:imgName];
        
        if (packName != nil && [[NSUserDefaults standardUserDefaults] boolForKey:packName] == NO)
        {
            [self.parent.parent.iaManager makePurchase:packName];
            return;
        }
    }
    
    NSInteger idx = [self.images indexOfObject:imgName];
    
    if (bgFlag) {
        [self.parent setLastSelectedBG:idx];
    }
    else {
        [self.parent setLastPointerSel:idx];
    }
    
    [self.parent.mySettingsView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

@end
