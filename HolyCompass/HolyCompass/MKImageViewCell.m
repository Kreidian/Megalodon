//
//  MKImageViewCell.m
//  HolyHeading
//
//  Created by Eitan Levy on 5/2/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import "MKImageViewCell.h"

@implementation MKImageViewCell

@synthesize mainImage;
@synthesize coinImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
