//
//  VenueDetailController.h
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSObjects.h"
//#import <MapKit/MapKit.h>
#include <MapKit/MapKit.h>
#include <MapKit/MKAnnotation.h>

@class MKAnnotation;

@interface VenueDetailController : UIViewController <MKMapViewDelegate> {
	
	IBOutlet MKMapView * mapView;
	
	//MKAnnotation * venueAnnotation;
	IBOutlet UIBarButtonItem * favoriteButton;
	IBOutlet UIBarButtonItem * callButton;
	
	
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) FSVenue * venue;

-(id) initWithVenue:(FSVenue*)ven;

-(IBAction) favoriteClicked;
-(IBAction) getDirectionsClicked;
-(IBAction) callClicked;
-(IBAction) checkinClicked;

@end
