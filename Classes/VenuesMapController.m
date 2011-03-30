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
#import "Model.h"
#import "Foursquare2.h"
#import "VenuePeopleDetailController.h"
#import "SettingsPopupController.h"

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
	
	//--mapView.showsUserLocation = YES;
	

	//self.title = @"Back";
	//self.navigationItem.title = @"Back";
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-logo.png"]];
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Ω" style:UIBarButtonItemStylePlain target:self action:@selector(settingsClicked)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-bar-button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsClicked)];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh-icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(refreshClicked)];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genderPrefChanged) name:kGenderChangedNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayVenues) name:kVenuesUpdatedNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(venuesUpdateStarted) name:kVenuesUpdateStartedNotification object:nil];	
	
}

-(void) viewDidUnload {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}



-(void) viewDidAppear:(BOOL)animated {
	
	
	if ( [Foursquare2 isNeedToAuthorize]) {
		
		return;
		
		//} else if ( !isLoading && (venuesArray ==nil || ([venuesArray count] ==0) ) ) {
	} else if ( ![Model instance].isLoadingNearbyVenues && ([Model instance].venuesArray ==nil || ([[Model instance].venuesArray count] ==0) ) ) {	
		
		//[self startLocation];
		[[Model instance] startLocationAndFindNearbyVenues];
		
	} else if ( ![Model instance].isLoadingNearbyVenues && !venuesDisplayed ) {
		
		// may already be loaded..
		[self displayVenues];
		
	}
	
	
	
}

-(void) viewWillDisappear:(BOOL)animated {
	
	// kind of a hack it seems, but the only way it re-appears upon popping
	self.hidesBottomBarWhenPushed = NO;
	
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



-(void) venuesUpdateStarted {
	
	[mapView removeAnnotations:mapView.annotations];
	
	
}

-(void) displayVenues {

	
	[mapView removeAnnotations:mapView.annotations];
	
	NSArray * venuesArray = [Model instance].venuesArray;
	
	if ( venuesArray ) {
		
		FSVenue * venue = nil;
		
		for (venue in venuesArray) {
			
			VenueAnnotation * venueAnno = [[VenueAnnotation alloc] init];
			venueAnno.venue = venue;
			[mapView addAnnotation:venueAnno];
			
		}
		
		/*
		MKCoordinateRegion newRegion;
		
		newRegion.center.latitude = venue.lat;
		newRegion.center.longitude = venue.lng;
		
		newRegion.span.latitudeDelta = 0.0112872;
		newRegion.span.longitudeDelta = 0.0109863;
		
		[mapView setRegion:newRegion animated:YES];
		*/
		
	}
	
	MKMapRect flyTo = MKMapRectNull;
	
	for (id <MKAnnotation> annotation in mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
    }
    
    // Position the map so that all overlays and annotations are visible on screen.
    mapView.visibleMapRect = flyTo;
	
	
	// change to time based, or location based ?
	venuesDisplayed = YES;
	
	
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	
	
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    if ([annotation isKindOfClass:[VenueAnnotation class]]) 
    {
		
		VenueAnnotation * venAnno = (VenueAnnotation*)annotation;
		
		int level = 0; // 0 - 3 
		int numPeople = 0;
		GenderPreference g = [Model instance].genderPreference;
		
		if ( g == GENDER_PREFERENCE_ALL ) {
			numPeople = venAnno.venue.numPeopleHereWithPhotos;
		} else if ( g == GENDER_PREFERENCE_MALES ) {
			numPeople = venAnno.venue.numGuysHereWithPhotos;
		} else if ( g == GENDER_PREFERENCE_FEMALES ) {
			numPeople = venAnno.venue.numGirlsHereWithPhotos;
		}
		
		// try to dequeue an existing pin view first
        static NSString* VenueAnnotationIdentifier = @"venueAnnotationIdentifier";
		static NSString* VenueAnnotationIdentifierLow = @"VenueAnnotationIdentifierLow";
		static NSString* VenueAnnotationIdentifierMed = @"VenueAnnotationIdentifierMed";
		static NSString* VenueAnnotationIdentifierMedHigh = @"VenueAnnotationIdentifierMedHigh";
		static NSString* VenueAnnotationIdentifierHigh = @"VenueAnnotationIdentifierHigh";
		
		NSString* ident = nil;
		
		if ( numPeople < 2 ) {
			level = 0;
			ident = VenueAnnotationIdentifierLow;
		} else if ( numPeople < 5 ) {
			level = 1;
			ident = VenueAnnotationIdentifierMed;
		} else if ( numPeople < 10 ) {
			level = 2;
			ident = VenueAnnotationIdentifierMedHigh;
		} else {
			level = 3;
			ident = VenueAnnotationIdentifierHigh;
		}
		
        	
			
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ident];
		
        if (!pinView)
        {
			
			MKAnnotationView *annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:ident] autorelease];
            annotationView.canShowCallout = YES;
            UIImage * pinImage = nil;
			
			switch (level) {
				case 0:
					pinImage = [UIImage imageNamed:@"map-pin-low.png"];
					break;
				case 1:
					pinImage = [UIImage imageNamed:@"map-pin-medium.png"];
					break;
				case 2:
					pinImage = [UIImage imageNamed:@"map-pin-medium-high.png"];
					break;
				case 3:
					pinImage = [UIImage imageNamed:@"map-pin-high.png"];
					break;
			}
			
			
			UILabel * numPeopleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 19, 24)];
			numPeopleLabel.font = [UIFont boldSystemFontOfSize:19.];
			numPeopleLabel.adjustsFontSizeToFitWidth = YES;
			numPeopleLabel.minimumFontSize = 15.;
			numPeopleLabel.backgroundColor = [UIColor clearColor];
			numPeopleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.2];
			numPeopleLabel.shadowOffset = CGSizeMake(0, -1);
			numPeopleLabel.textAlignment = UITextAlignmentCenter;
			numPeopleLabel.textColor = [UIColor whiteColor];
			
			numPeopleLabel.text = [NSString stringWithFormat:@"%i" , numPeople];
			
            /*
            CGRect resizeRect;
            
            resizeRect.size = flagImage.size;
            CGSize maxSize = CGRectInset(self.view.bounds,
                                         [LarisMapController annotationPadding],
                                         [LarisMapController annotationPadding]).size;
            maxSize.height -= self.navigationController.navigationBar.frame.size.height + [LarisMapController calloutHeight];
            if (resizeRect.size.width > maxSize.width)
                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
            if (resizeRect.size.height > maxSize.height)
                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
            
            resizeRect.origin = (CGPoint){0.0f, 0.0f};
            UIGraphicsBeginImageContext(resizeRect.size);
            [flagImage drawInRect:resizeRect];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            */
            //--annotationView.image = pinImage;
            annotationView.opaque = NO;
			UIView * holderView = [[UIView alloc] initWithFrame:CGRectMake(0, 18, pinImage.size.width, pinImage.size.height)];
			UIImageView * imgView = [[UIImageView alloc] initWithImage:pinImage];
			
			[holderView addSubview:imgView];
			[holderView addSubview:numPeopleLabel];
			[annotationView addSubview:holderView];
			//[annotationView addSubview:numPeopleLabel];
			//holderView.center = CGPointMake(0, -18);
			annotationView.frame = CGRectMake(0, 0, 40, 60);
			holderView.frame = CGRectMake(0, -10, 40, 50);
			
			//annotationView.backgroundColor = [UIColor greenColor];
			
            //UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFIcon.png"]];
            //annotationView.leftCalloutAccessoryView = sfIconView;
            //[sfIconView release];
            
			UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
			
			annotationView.alpha = 0.0;
			//holderView.backgroundColor = [UIColor greenColor];
			[annotationView.layer removeAllAnimations];
			
			//static float delay = 0.0;
			
			float randTime = (float)(rand() % 6) * 0.1;
			int randDist = 120;//10 + (rand() % 50);
			CGPoint p = holderView.center;
			p.y -= randDist;
			holderView.center = p;
			p.y += randDist;
			
			[UIView beginAnimations:@"fadeIn" context:nil];
			[UIView setAnimationDuration:0.4];
			[UIView setAnimationDelay:randTime];
			annotationView.alpha = 1.0;
			holderView.center = p;
			[UIView commitAnimations];
			
			//delay += 0.05;
			
            return annotationView;
			
			
			
			
            //return customPinView;
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
