//
//  MKViewController.m
//  DeariPhone
//
//  Created by Eitan Levy on 6/10/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import "MKViewController.h"

@interface MKViewController ()

@end

@implementation MKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
