//
//  MKSpecialLocation.h
//  HolyHeading
//
//  Created by Eitan Levy on 4/25/12.
//  Copyright (c) 2012 info. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MKSpecialLocation : NSObject
{
    CLLocationCoordinate2D coordinates;
    NSString *name;
}

@property(strong, nonatomic) NSString *name;

-(void) setCoordinates: (CLLocationCoordinate2D) coords;
-(CLLocationCoordinate2D) getCoordinates;

- (id)initWithCoords: (CLLocationCoordinate2D) coords;
- (id)initWithCoordsAndName:(CLLocationCoordinate2D)coords Name:(NSString*)aName;

+(id) specialLocationWithCoords: (CLLocationCoordinate2D) coords;
+(id) specialLocationWithCoordsAndName:(CLLocationCoordinate2D)coords Name:(NSString*)aName;

@end
