//
//  MKCapturedImageViewController.m
//  MysticArrow
//
//  Created by Eitan Levy on 5/28/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import "MKCapturedImageViewController.h"
#import <Twitter/Twitter.h>

@interface MKCapturedImageViewController ()
{
    UIImage* loadImage;
}

@property(strong, nonatomic) UIImage* loadImage;

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@implementation MKCapturedImageViewController

@synthesize mainImage;
@synthesize loadImage;

- (id)initWithImage: (UIImage*) image
{
    self = [self initWithNibName:@"MKCapturedImageView_iPhone" bundle:nil];
    
    if (self) {
        loadImage = image;
    }
    
    return self;
}

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
    
    [self loadInImage:loadImage];
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

-(void) loadInImage: (UIImage*) image
{
//    mainImage.image = image;
//    return; 
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGRect frame = mainImage.frame;
    UIScreen* myscreen = [UIScreen mainScreen];
    CGFloat scWidth = myscreen.bounds.size.width * myscreen.scale;
    CGFloat scHeight = myscreen.bounds.size.height * myscreen.scale;
    CGFloat ratio, delta;
    int x, y;
    UIImage* overlay = [UIImage imageNamed:@"Arrow-tribalcross"];
    
    
    if (width > height)
    {
        ratio = width / height;
        frame.size.width = scHeight * ratio;
        
        if ( scWidth > frame.size.width )
        {
            ratio = height / width;
            frame.size.height =  scWidth * ratio;
            frame.size.width = scWidth;
            
            delta = frame.size.height - scHeight;
            delta /= 2;
            
            frame.origin.y = -delta;
            frame.origin.x = 0;
        }
        else
        {
            frame.size.height = scHeight;
            delta = frame.size.width - scWidth;
            delta /= 2;
            
            frame.origin.y = 0;
            frame.origin.x = -delta;
        }
    }
    else
    {
        ratio = height / width;
        frame.size.height =  scWidth * ratio;
        
        if (scHeight > frame.size.height) 
        {
            ratio = width / height;
            frame.size.height = scHeight;
            frame.size.width = scHeight * ratio;
            
            delta = frame.size.width - scWidth;
            delta /= 2;
            
            frame.origin.y = 0;
            frame.origin.x = -delta;
        }
        else
        {
            frame.size.width = scWidth;
            
            delta = frame.size.height - scHeight;
            delta /= 2;
            
            frame.origin.y = -delta;
            frame.origin.x = 0;
        }
    }
    
    width = 200 * myscreen.scale; // change for ipad
    height = 200 * myscreen.scale;
    
    x = scWidth;
    y = scHeight;
    
    x = rand() % x;
    y = rand() % y;
    x -= width/2;
    y -= height/2;
    
    UIGraphicsBeginImageContext( frame.size );
    [image drawInRect:CGRectMake(0,0,frame.size.width,frame.size.height)];
    [overlay drawInRect:CGRectMake(x, y, width, height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    frame.size.width /= myscreen.scale;
    frame.size.height /= myscreen.scale;

    mainImage.frame = frame;
    mainImage.image = newImage;
}
// http://itunes.apple.com/us/app/mystic-arrow/id530383736?ls=1&mt=8
-(IBAction)onTwitter:(id)sender
{
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController* tweetView = [[TWTweetComposeViewController alloc] init];
        
        [tweetView setInitialText:NSLocalizedString(@"TWITTERPOST", nil)];
        [tweetView addURL:[NSURL URLWithString:@"itunes.com/apps/mysticarrow"]];
        [tweetView addImage:mainImage.image];
        
        [self presentModalViewController:tweetView animated:YES];
    }
    else 
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TWITTERERR", nil) message:NSLocalizedString(@"TWITERRMSG", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

-(IBAction)onSavePic:(id)sender
{
    UIImage* image = mainImage.image;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    
    // Unable to save the image  
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                           message:@"Unable to save image to Photo Album." 
                                          delegate:self cancelButtonTitle:@"Ok" 
                                 otherButtonTitles:nil];
    else // All is well
        alert = [[UIAlertView alloc] initWithTitle:@"Success" 
                                           message:@"Image saved to Photo Album." 
                                          delegate:self cancelButtonTitle:@"Ok" 
                                 otherButtonTitles:nil];
    [alert show];
}

-(IBAction)onExit:(id)sender
{
    [self.view removeFromSuperview];
}

@end
