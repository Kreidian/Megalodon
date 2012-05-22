//
//  MKSpecialLocation.m
//  HolyHeading
//
//  Created by Eitan Levy on 4/25/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import "MKSpecialLocation.h"

@implementation MKSpecialLocation

@synthesize name;

- (id)initWithCoords: (CLLocationCoordinate2D) coords
{
    self = [self init];
    if (self)
    {
        coordinates = coords;
    }
    
    return self;
}

- (id)initWithCoordsAndName:(CLLocationCoordinate2D)coords Name:(NSString*)aName
{
    self = [self init];
    if (self)
    {
        coordinates = coords;
        self.name = [NSString stringWithString:aName];
    }
    
    return self;
}

+(id) specialLocationWithCoords: (CLLocationCoordinate2D) coords
{
    MKSpecialLocation* mksl = [[MKSpecialLocation alloc] initWithCoords:coords];
    return mksl;
}

+(id) specialLocationWithCoordsAndName:(CLLocationCoordinate2D)coords Name:(NSString*)aName
{
    MKSpecialLocation* mksl = [[MKSpecialLocation alloc] initWithCoordsAndName:coords Name:aName];
    return mksl;
}

-(void) setCoordinates: (CLLocationCoordinate2D) coords
{
    coordinates = coords;
}

-(CLLocationCoordinate2D) getCoordinates
{
    return coordinates;
}

@end
