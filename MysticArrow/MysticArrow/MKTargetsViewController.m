//
//  MKTargetsViewController.m
//  MysticArrow
//
//  Created by Eitan Levy on 5/27/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import "MKTargetsViewController.h"
#import "MKViewController.h"
#import "MKTargetInfoViewCtrl.h"

@interface MKTargetsViewController ()

-(void)doneButton;

@end

@implementation MKTargetsViewController

@synthesize parent;
@synthesize mySettingsView;

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
    
    self.title = NSLocalizedString(@"TARGETS", nil);
    
    UIBarButtonItem* donebtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton)];
    self.navigationItem.leftBarButtonItem = donebtn;
}

-(void)doneButton
{
    NSLog(@"BACK");
   
    [parent doneButton];
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

#pragma mark - TableView data source and delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OptionCell"]; 
    }
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* spookies = [dictionary objectForKey:@"Spookies"];
    
    cell.textLabel.text = NSLocalizedString([spookies objectAtIndex:indexPath.row], nil);
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    int sel = [self.parent.options getLastSpookySelected];
    
    if (sel == indexPath.row)
    {
        cell.backgroundColor = [UIColor redColor];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = 1;
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* spookies = [dictionary objectForKey:@"Spookies"];
 
    count = spookies.count;
    
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.parent.options setLastSpookySelected:indexPath.row];
    
    UITableViewCell  * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    [self.mySettingsView reloadData];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", indexPath);
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"MAProperties" ofType:@"plist"];
    NSDictionary * dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray* spookies = [dictionary objectForKey:@"Spookies"];
    
    MKTargetInfoViewCtrl* infoView = [[MKTargetInfoViewCtrl alloc] initWithNibName:@"MKTargetInfoView_iPhone" bundle:nil];
    
    NSString* name = [spookies objectAtIndex:indexPath.row];
    //self.parent.spookyName.text = [NSString stringWithString:name];
    infoView.title = name;
    
    [self.navigationController pushViewController:infoView animated:YES];
}
    
@end
