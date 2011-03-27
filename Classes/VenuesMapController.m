//
//  VenuesMapController.m
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "VenuesMapController.h"
#import <MapKit/MKAnnotation.h>
#import "VenueAnnotation.h"
#import "Locator.h"

#import "NSString+EscapingUtils.h"

@implementation VenuesMapController

@synthesize delegate, venues;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/



-(id) initWithVenues:(NSArray*)vens
{
	self = [super init];
	if (self != nil) {
		
		self.venues = vens;
		self.navigationItem.title = @"Venues";
		
	}
	return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:nil];
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Fav" style:UIBarButtonItemStylePlain target:self action:nil];
	
	mapView.showsUserLocation = YES;
	
	
	if ( self.venues ) {
		
		FSVenue * venue = nil;
		
		for (venue in self.venues) {
			
			
			VenueAnnotation * venueAnno = [[VenueAnnotation alloc] init];
			venueAnno.venue = venue;
			[mapView addAnnotation:venueAnno];
			
						
		}
		
		
		MKCoordinateRegion newRegion;
		
		newRegion.center.latitude = venue.lat;
		newRegion.center.longitude = venue.lng;
		
		newRegion.span.latitudeDelta = 0.0112872;
		newRegion.span.longitudeDelta = 0.0109863;
		
		[mapView setRegion:newRegion animated:YES];
		
	
	}
	
	
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    if ([annotation isKindOfClass:[VenueAnnotation class]]) 
    {
        // try to dequeue an existing pin view first
        static NSString* VenueAnnotationIdentifier = @"venueAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
		[mapView dequeueReusableAnnotationViewWithIdentifier:VenueAnnotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:VenueAnnotationIdentifier] autorelease];
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
			
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            customPinView.rightCalloutAccessoryView = rightButton;
			
			
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
    return nil;
}

-(void) showDetails:(id)sender {
	
	NSLog(@"details");
	
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
