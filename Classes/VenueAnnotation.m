//
//  VenueAnnotation.m
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "VenueAnnotation.h"


@implementation VenueAnnotation

@synthesize venue;


- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
	theCoordinate.latitude = venue.lat;
    theCoordinate.longitude = venue.lng;
    return theCoordinate; 
	
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString *)title
{
    return venue.name;
}

// optional
- (NSString *)subtitle
{
    return @"Click for details";
}



@end
