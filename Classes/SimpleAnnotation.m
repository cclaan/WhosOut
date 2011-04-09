//
//  SimpleAnnotation.m
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "SimpleAnnotation.h"


@implementation SimpleAnnotation

@synthesize latitude, longitude;


- (CLLocationCoordinate2D)coordinate;
{
    //CLLocationCoordinate2D theCoordinate;
	//theCoordinate.latitude = [latitude doubleValue];
    //theCoordinate.longitude = [longitude doubleValue];
    //return theCoordinate; 
	
	return myCoord;
	
}

-(void) setCoordinate:(CLLocationCoordinate2D)newCoordinate {

	myCoord = newCoordinate;
	
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString *)title
{
    return @"My Location";
}

// optional
- (NSString *)subtitle
{
    return @"Tap X to delete";
}



@end
