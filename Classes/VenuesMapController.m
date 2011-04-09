//
//  VenuesMapController.m
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "VenuesMapController.h"
#import <MapKit/MKAnnotation.h>
//#import "VenueAnnotation.h"
#import "Locator.h"
#import "Model.h"
#import "Foursquare2.h"
#import "VenuePeopleDetailController.h"
#import "SettingsPopupController.h"
#import "FSVenueMapAnnotationView.h"
#import <MapKit/MKGeometry.h>

#import "NSString+EscapingUtils.h"


@interface VenuesMapController()

-(VenueAnnotation*) doesAnnotationExistForVenue:(FSVenue*) ven;

@end


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
	
	
	dataOutOfDate = YES;
	
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:nil];
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Fav" style:UIBarButtonItemStylePlain target:self action:nil];
	
	mapView.showsUserLocation = YES;
	
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)]; 
	//longPress.minimumPressDuration = 0.5;
	[mapView addGestureRecognizer:longPress];
	

	//self.title = @"Back";
	//self.navigationItem.title = @"Back";
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom-navbar-logo.png"]];
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Ω" style:UIBarButtonItemStylePlain target:self action:@selector(settingsClicked)];
	
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-bar-button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsClicked)];
	//self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh-icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(refreshClicked)];
	
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithButtonImage:[UIImage imageNamed:@"settings-bar-button.png"] target:self action:@selector(settingsClicked)];
	self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithButtonImage:[UIImage imageNamed:@"refresh-icon.png"] target:self action:@selector(refreshClicked)];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genderPrefChanged) name:kGenderChangedNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(venuesUpdated) name:kVenuesUpdatedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(venuesUpdateFinished) name:kVenuesUpdateFinishedNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(venuesUpdateStarted) name:kVenuesUpdateStartedNotification object:nil];	
	
}

-(void) viewDidUnload {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

-(void) handleLongPress:(id) obj {
	
	NSLog(@"obj: %@ " , obj );
	UILongPressGestureRecognizer * longPress = (UILongPressGestureRecognizer*)obj;
	
	if ( longPress.state == UIGestureRecognizerStateBegan ) {
		
		
		CGPoint point = [longPress locationInView:mapView];
		
		CLLocationCoordinate2D coord= [mapView convertPoint:point toCoordinateFromView:mapView];
		
		NSLog(@"lat  %f",coord.latitude);
		NSLog(@"long %f",coord.longitude);

		if ( !fakeLocation ) {
			
			fakeLocation = [[SimpleAnnotation alloc] init];
			//FSVenue * ven = [[FSVenue alloc] init];
			//ven.name = @"Fake Location";
			//fakeLocation.venue = ven;
			
		} else {
			[mapView removeAnnotation:fakeLocation];
		}
		
		//fakeLocation.venue.lat = coord.latitude;
		//fakeLocation.venue.lng = coord.longitude;
		[fakeLocation setCoordinate:coord];
		//fakeLocation.latitude = [NSNumber numberWithDouble:coord.latitude];
		//fakeLocation.longitude = [NSNumber numberWithDouble:coord.longitude];
		
		
		
		[mapView addAnnotation:fakeLocation];
		
		[self performSelector:@selector(showUseLocationAlert) withObject:nil afterDelay:0.85];
		
	}
	
}

-(void) showUseLocationAlert {
	
	UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Make this your location?" message:@"Do you want to change your location to this point? Tap the pin to cancel anytime" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
	[al show];
	[al release];
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
	
	
	if ( buttonIndex == 1 ) 
		
	{
		
		//CLLocationCoordinate2D faker = CLLocationCoordinate2DMake(fakeLocation.venue.lat, fakeLocation.venue.lng);		
		//CLLocationCoordinate2D faker = CLLocationCoordinate2DMake(fakeLocation.coordinate.latitude, fakeLocation.coordinate.longitude);		
		CLLocation * loc = [[CLLocation alloc] initWithLatitude:fakeLocation.coordinate.latitude longitude:fakeLocation.coordinate.longitude];
		//loc.coordinate = faker;
		[Model instance].chosenLocation = loc;
		//[self startL
		[self refreshClicked];
		
	} else {
		
		
		[mapView removeAnnotation:fakeLocation];
		[fakeLocation release];
		fakeLocation = nil;
		
	}
	
	
	
}
	

-(void) viewDidAppear:(BOOL)animated {
	
	
	if ( [Foursquare2 isNeedToAuthorize]) {
		
		return;
		
		//} else if ( !isLoading && (venuesArray ==nil || ([venuesArray count] ==0) ) ) {
	} else if ( ![Model instance].isLoadingNearbyVenues && ([Model instance].venuesArray ==nil || ([[Model instance].venuesArray count] ==0) ) ) {	
		
		//[self startLocation];
		[[Model instance] startLocationAndFindNearbyVenues];
		
	//} else if ( ![Model instance].isLoadingNearbyVenues && !venuesDisplayed ) {
	} else if ( ![Model instance].isLoadingNearbyVenues && dataOutOfDate ) {
		
		// may already be loaded..
		[self displayVenues];
		
	} else if ( ![Model instance].isLoadingNearbyVenues ) {
		
		// can call display instead...
		//[self refreshVenueAnnotations];
		[self displayVenues];
		
	}
		
			   
	
	
	
}

-(void) viewWillDisappear:(BOOL)animated {
	
	// kind of a hack it seems, but the only way it re-appears upon popping
	self.hidesBottomBarWhenPushed = NO;
	
}


-(void) genderPrefChanged {
	
	//[self refreshClicked];
	//[self displayVenues];
	
	dataOutOfDate = YES;
	
}


#pragma mark -
#pragma mark Buttons

-(IBAction) refreshClicked {
	
	if ( [Model instance].isLoadingNearbyVenues ) { return; }
	
	[[Model instance] startLocationAndFindNearbyVenues];
	
}

-(IBAction) settingsClicked {
	
	
	SettingsPopupController * settingsController = [[SettingsPopupController alloc] init];
	settingsController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	[self presentModalViewController:settingsController animated:YES];
	[settingsController release];
	
	
}


#pragma mark -
#pragma mark Model events


-(void) venuesUpdateStarted {
	
	//[mapView removeAnnotations:mapView.annotations];
	
	[mapView removeAnnotations: [mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!((self isKindOfClass: %@)||(self isKindOfClass: %@))", [MKUserLocation class], [SimpleAnnotation class]]]];
	
	
	
}

-(void) venuesUpdated {
	
	[self displayVenues];
	
}

-(void) venuesUpdateFinished {
	
	[self displayVenues];
	
	/*
	NSArray * venuesArray = [Model instance].venuesArray;
	
	if ( [venuesArray count] == 0 ) {
		
		venuesDisplayed = YES;
		dataOutOfDate = NO;
		
		if ( self.parentViewController.tabBarController.selectedViewController == self.parentViewController ) {
			UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"No Venues" message:@"No one is checked in around here.\n\nTry manually selecting a location like New York by tapping and holding it on the map.\n\nYou can also adjust your search radius in settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[al show];
			[al release];
		}
		
	} else {
		[self displayVenues];
	}
	*/
	
}

#pragma mark -

-(void) refreshVenueAnnotations {
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"updateVenueMapAnnotations" object:nil];
	//MKMapView
	
	for (id <MKAnnotation> annotation in mapView.annotations) {
	//for (id viewser in [[mapView.subviews objectAtIndex:0] subviews] ) {
		
		//if ( [viewser isKindOfClass:FSVenueMapAnnotationView
		MKAnnotationView * annoView = [mapView viewForAnnotation:annotation];
		
		if ( [annoView isKindOfClass:[FSVenueMapAnnotationView class]] ) {
			
			//NSLog(@"setting!");
			FSVenueMapAnnotationView * fsView = (FSVenueMapAnnotationView*)annoView;
			fsView.annotation = fsView.annotation;
			//fsView.numPeople = 0;
			//[fsView refreshData];
			
		}
		
	}
	
	
}

-(VenueAnnotation*) doesAnnotationExistForVenue:(FSVenue*) ven {
	
	NSArray * existingAnnotations = [mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!((self isKindOfClass: %@)||(self isKindOfClass: %@))", [MKUserLocation class], [SimpleAnnotation class]]];
	
	for (VenueAnnotation * venAnno in existingAnnotations) {
			
		if ( [venAnno.venue isSameAs:ven] ) {
			return venAnno;
		} 
		
	}
	
	return nil;
	
}

-(void) zoomToMyLocation {
	
	MKCoordinateRegion newRegion;
	
	if ( [Model instance].chosenLocation ) {
		newRegion.center.latitude = mapView.userLocation.coordinate.latitude;
		newRegion.center.longitude = mapView.userLocation.coordinate.longitude;
	} else {
		newRegion.center.latitude = mapView.userLocation.coordinate.latitude;
		newRegion.center.longitude = mapView.userLocation.coordinate.longitude;
	}
	
	newRegion.span.latitudeDelta = 0.0112872*4;
	newRegion.span.longitudeDelta = 0.0109863*4;
	[mapView setRegion:newRegion animated:NO];
	
}

-(void) displayVenues {

	
	//[mapView removeAnnotations:mapView.annotations];
	//[mapView removeAnnotations: [mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!(self isKindOfClass: %@)", [MKUserLocation class]]]];
	
	//--[mapView removeAnnotations: [mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!((self isKindOfClass: %@)||(self isKindOfClass: %@))", [MKUserLocation class], [SimpleAnnotation class]]]];
	
	
	
	NSArray * venuesArray = [Model instance].venuesArray;
	
	
									 
	
	if ( venuesArray ) {
		
		FSVenue * venue = nil;
		GenderPreference g = [Model instance].genderPreference;
		
		for (venue in venuesArray) {
			
			VenueAnnotation * existingAnno = [self doesAnnotationExistForVenue:venue];
			
			BOOL shouldRemove = NO;
	
			// maybe category changed...
			if ( g == GENDER_PREFERENCE_ALL ) {
				if ( venue.numPeopleHereWithPhotos == 0 ) { shouldRemove=YES; }
			} else if ( g == GENDER_PREFERENCE_MALES ) {
				if ( venue.numGuysHereWithPhotos == 0 ) { shouldRemove=YES; }
			} else if ( g == GENDER_PREFERENCE_FEMALES ) {
				if ( venue.numGirlsHereWithPhotos == 0 ) { shouldRemove=YES; }
			}
			
			if ( [[Model instance] isBannedCategory:venue.primaryCategory.parent]  ) {
				shouldRemove=YES;
			}
			
			if ( shouldRemove && existingAnno ) {
				[mapView removeAnnotation:existingAnno];
				continue;
			} else if ( shouldRemove ) {
				continue;	
			}
			
			if ( !existingAnno ) {
				
				VenueAnnotation * venueAnno = [[VenueAnnotation alloc] init];
				venueAnno.venue = venue;
				venueAnno.canShowDetails = YES;
				
				[mapView addAnnotation:venueAnno];
				
			} else {
				
				existingAnno.venue = venue;
				
				MKAnnotationView * annoView = [mapView viewForAnnotation:existingAnno];
				
				if ( annoView && [annoView isKindOfClass:[FSVenueMapAnnotationView class]] ) {
					FSVenueMapAnnotationView * fsView = (FSVenueMapAnnotationView*)annoView;
					fsView.annotation = fsView.annotation;
				}
				
			}
			
			
			
		}
		
	}
	
	
	NSArray * venueAnnotations = [mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!((self isKindOfClass: %@)||(self isKindOfClass: %@))", [MKUserLocation class], [SimpleAnnotation class]]];
	
	if ( [venueAnnotations count] == 0 ) {
		
		NSLog(@"No annoatations!");
		
		if ( self.parentViewController.tabBarController.selectedViewController == self.parentViewController ) {
			UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"No Venues" message:@"No one is checked in around here.\n\nTry manually selecting a location like New York by tapping and holding it on the map.\n\nYou can also adjust your search filters in settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[al show];
			[al release];
		}
		
		/*
		for (id <MKAnnotation> annotation in mapView.annotations ) {
			
			if ( [annotation isKindOfClass:[MKUserLocation class]] ) {
				
				MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
				MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 50000, 50000);
				[mapView setVisibleMapRect:pointRect edgePadding:UIEdgeInsetsMake(5, 5, 5, 5) animated:YES];
				break;
				
			}
			
		}
		*/
		
		[self zoomToMyLocation];
		
	} else {
		
		MKMapRect flyTo = MKMapRectNull;
		
		for (id <MKAnnotation> annotation in venueAnnotations ) {
			
			if ( [annotation isKindOfClass:[MKUserLocation class]] ) continue;
			
			MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
			MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
			if (MKMapRectIsNull(flyTo)) {
				flyTo = pointRect;
			} else {
				flyTo = MKMapRectUnion(flyTo, pointRect);
			}
			
		}
			
		NSLog(@"Map width: %f " , MKMapRectGetWidth(mapView.visibleMapRect) );
		//272315
		double mWidth = MKMapRectGetWidth(mapView.visibleMapRect);
		double mWidth2 = MKMapRectGetWidth(flyTo);
		
		if ( !MKMapRectIntersectsRect(mapView.visibleMapRect , flyTo) || (mWidth > 150000) || ( mWidth2>mWidth ) ) { 
			// Position the map so that all overlays and annotations are visible on screen.
			//mapView.visibleMapRect = flyTo;
			[mapView setVisibleMapRect:flyTo edgePadding:UIEdgeInsetsMake(5, 5, 5, 5) animated:YES];
		}
		
	}

	
	
	// change to time based, or location based ?
	venuesDisplayed = YES;
	
	dataOutOfDate = NO;
	
	
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	
	
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    if ([annotation isKindOfClass:[VenueAnnotation class]]) 
    {
		
		VenueAnnotation * venAnno = (VenueAnnotation*)annotation;
		
				
		// try to dequeue an existing pin view first
        static NSString* VenueAnnotationIdentifier = @"venueAnnotationIdentifier";
		
		FSVenueMapAnnotationView * viewToReturn = nil;
		
			
        FSVenueMapAnnotationView * pinView = (FSVenueMapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:VenueAnnotationIdentifier];
		
        if (!pinView)
        {
			FSVenueMapAnnotationView * annotationView = [[[FSVenueMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:VenueAnnotationIdentifier] autorelease];
			
			UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			[rightButton addTarget:self
							action:@selector(showDetails:)
				  forControlEvents:UIControlEventTouchUpInside];
			annotationView.rightCalloutAccessoryView = rightButton;
			
			viewToReturn = annotationView;
			
        }
        else
        {
            viewToReturn = pinView;
			//viewToReturn.annotation = annotation;
			
        }
		
		viewToReturn.annotation = annotation;
		//viewToReturn.numPeople = numPeople;
		//viewToReturn.hotnessLevel = level;
		
		//if (!venuesDisplayed) {
		[viewToReturn dropIn];
		//}
		
        return viewToReturn;
		
    } else if ([annotation isKindOfClass:[SimpleAnnotation class]]) {
		
        // try to dequeue an existing pin view first
        static NSString* SimpleAnnotationIdentifier = @"simpleAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
		[mapView dequeueReusableAnnotationViewWithIdentifier:SimpleAnnotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:SimpleAnnotationIdentifier] autorelease];
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
			
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
			rightButton.frame = CGRectMake(0, 0, 24, 24);
			[rightButton setFont:[UIFont boldSystemFontOfSize:24.]];
			[rightButton setTitle:@"X" forState:UIControlStateNormal];
            [rightButton addTarget:self
                            action:@selector(removeChosenLocationPinClicked)
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

-(void) removeChosenLocationPinClicked {
	
	[mapView removeAnnotation:fakeLocation];
	[fakeLocation release];
	fakeLocation = nil;
	
	[Model instance].chosenLocation = nil;
	
	[self refreshClicked];
	
	
}

-(void) showDetails:(id)sender {
	
	NSLog(@"details %@  " , sender );
	
	if ( [sender superview] ) {
		id mkview = [[sender superview] superview];
		if ( [mkview isKindOfClass:[MKAnnotationView class]] ) {
			
			self.hidesBottomBarWhenPushed = YES;
			
			MKAnnotationView * annoView = (MKAnnotationView*)mkview;
			VenueAnnotation * anno = (VenueAnnotation*)annoView.annotation;
			
			FSVenue * ven = anno.venue;
			
			VenuePeopleDetailController * vpdc = [[VenuePeopleDetailController alloc] initWithVenue:ven];
			vpdc.hidesBottomBarWhenPushed = YES;
			
			[self.navigationController pushViewController:vpdc animated:YES];
			[vpdc release];
			
		}
	}
	
	
	
	
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


- (void)dealloc {
    [super dealloc];
}


@end
