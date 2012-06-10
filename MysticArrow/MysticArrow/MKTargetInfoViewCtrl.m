//
//  MKTargetInfoViewCtrl.m
//  MysticArrow
//
//  Created by Eitan Levy on 5/27/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import "MKTargetInfoViewCtrl.h"

@interface MKTargetInfoViewCtrl ()

@end

@implementation MKTargetInfoViewCtrl

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

@end
