//
//  MKImageListViewController.h
//  HolyHeading
//
//  Created by Eitan Levy on 5/7/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKImageViewCell.h"

@class MKOptionsViewController;

@interface MKImageListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    bool bgFlag;
    
    IBOutlet UITableView* mySettingsView;
    
    NSArray* images;
    
    NSString* groupTitle;
    
    NSArray* grpSections;
    NSDictionary* grpImages;
}

@property(strong, nonatomic) NSArray* images;
@property(strong, nonatomic) NSString* groupTitle;
@property(strong, nonatomic) NSArray* grpSections;
@property(strong, nonatomic) NSDictionary* grpImages;

@property(strong, nonatomic) IBOutlet UITableView* mySettingsView;
@property(strong, nonatomic) IBOutlet MKImageViewCell* pImageCell;

@property(weak, nonatomic) MKOptionsViewController* parent;

-(void) setImageTypes: (BOOL) isBackgrounds;
-(void) rebuildDisplayLists: (NSArray*) imgList;
-(NSString*)localizeGroupDisplayName:(NSString*) groupName;

@end
