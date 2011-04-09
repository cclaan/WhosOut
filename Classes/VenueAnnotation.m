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
@synthesize canShowDetails;

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
    if ( self.canShowDetails ) {
		return @"Click for details";
	} else {
		
		NSString * str;
		if ( venue.distanceFromMe > 0.09 ) {
			str = [NSString stringWithFormat:@"%i Girl%@, %i Guy%@   %3.1f Miles" , venue.numGirlsHere, (venue.numGirlsHere==1?@"":@"s"),  venue.numGuysHere, (venue.numGuysHere==1?@"":@"s") , venue.distanceFromMe ];
		} else {
			int feet = (venue.distanceFromMe*5280.0);
			feet = feet - (feet % 100);
			str = [NSString stringWithFormat:@"%i Girl%@, %i Guy%@   %i Feet" , venue.numGirlsHere, (venue.numGirlsHere==1?@"":@"s"),  venue.numGuysHere, (venue.numGuysHere==1?@"":@"s") , feet ];
		}
		
		return str;
		
	}
	
}



@end
