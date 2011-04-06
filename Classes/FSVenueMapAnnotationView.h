//
//  FSVenueMapAnnotationView.h
//  MoreSquare
//
//  Created by Chris Laan on 4/1/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <MapKit/MapKit.h>
#include <MapKit/MKAnnotation.h>

@interface FSVenueMapAnnotationView : MKAnnotationView {
	
	UILabel * numPeopleLabel;
	//UIImage * pinImage;
	
	UIView * holderView;
	UIImageView * imgView;
	
	BOOL hasSetupUi;
}

// 0 - 3
@property int hotnessLevel;
@property int numPeople;

-(void) dropIn;
-(void) refreshData;

@end
