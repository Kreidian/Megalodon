//
//  MKImageViewCell.h
//  HolyHeading
//
//  Created by Eitan Levy on 5/2/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKImageViewCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UIImageView* mainImage;
@property(strong, nonatomic) IBOutlet UIImageView* coinImage;

@end
