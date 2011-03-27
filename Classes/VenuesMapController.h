//
//  VenuesMapController.h
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSObjects.h"
#include <MapKit/MapKit.h>
#include <MapKit/MKAnnotation.h>

@class MKAnnotation;

@interface VenuesMapController : UIViewController <MKMapViewDelegate> {
	
	IBOutlet MKMapView * mapView;
	
	//MKAnnotation * venueAnnotation;
	IBOutlet UIBarButtonItem * favoriteButton;
	IBOutlet UIBarButtonItem * callButton;
	
	
}

@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) NSArray * venues;

//@property (nonatomic, retain) FSVenue * venue;

-(id) initWithVenues:(NSArray*)vens;



@end
