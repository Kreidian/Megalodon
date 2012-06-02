//
//  MKOptionsViewController.h
//  HolyHeading
//
//  Created by Eitan Levy on 4/24/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKViewController;
@class MKImageListViewController;
@class MKImageViewCell;


@interface MKOptionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIBarButtonItem *removeAdsButton;
    
    IBOutlet UITableView* mySettingsView;
    
    MKImageListViewController* subimages;
    
    int lastSelectedTheme;
    int lastSpookySelected;
}

@property(strong, nonatomic) IBOutlet UIBarButtonItem *removeAdsButton;
@property(strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property(strong, nonatomic) IBOutlet UITableView* mySettingsView;

@property(strong, nonatomic) IBOutlet MKImageViewCell* pImageCell;
@property(strong, nonatomic) IBOutlet MKImageListViewController* subimages;
@property(weak, nonatomic) MKViewController* parent;

-(IBAction)backButton:(id)sender;

-(IBAction)removeAdsSelected:(id)sender;

-(void) saveOptionSettings;
-(void) loadOptionSettings;

-(void) setLastSelectedTheme: (NSInteger) index;
-(void) setLastSpookySelected: (NSInteger) index;

-(int) getLastSelectedTheme;
-(int) getLastSpookySelected;

@end
