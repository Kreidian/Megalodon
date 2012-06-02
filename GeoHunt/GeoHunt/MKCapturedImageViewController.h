//
//  MKCapturedImageViewController.h
//  MysticArrow
//
//  Created by Eitan Levy on 5/28/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKCapturedImageViewController : UIViewController
{
    IBOutlet UIImageView* mainImage;
}

@property(strong, nonatomic) IBOutlet UIImageView* mainImage;

- (id)initWithImage: (UIImage*) image;
-(void) loadInImage: (UIImage*) image;


-(IBAction)onExit:(id)sender;
-(IBAction)onTwitter:(id)sender;
-(IBAction)onSavePic:(id)sender;

@end
