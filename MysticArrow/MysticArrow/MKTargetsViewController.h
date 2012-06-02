//
//  MKTargetsViewController.h
//  MysticArrow
//
//  Created by Eitan Levy on 5/27/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKViewController;

@interface MKTargetsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView* mySettingsView;
}

@property(strong, nonatomic) IBOutlet UITableView* mySettingsView;
@property(weak, nonatomic) MKViewController* parent;

@end
