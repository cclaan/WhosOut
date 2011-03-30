//
//  VenuePeopleDetailController.h
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSObjects.h"
#import "VenueView.h"

@class MKAnnotation;

@interface VenuePeopleDetailController : UIViewController {
		
	IBOutlet UIBarButtonItem * favoriteButton;
	IBOutlet UIBarButtonItem * callButton;
	
	VenueView * venueView;
	IBOutlet UIScrollView * scrollView;
	
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) FSVenue * venue;

-(id) initWithVenue:(FSVenue*)ven;

-(IBAction) favoriteClicked;
-(IBAction) getDirectionsClicked;
-(IBAction) callClicked;
-(IBAction) checkinClicked;

@end
