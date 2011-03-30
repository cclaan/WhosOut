//
//  VenueDetailController.m
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "VenueDetailController.h"
#import <MapKit/MKAnnotation.h>
#import "VenueAnnotation.h"
#import "Locator.h"
#import "MBProgressHUD.h"
#import "Foursquare2.h"

#import "NSString+EscapingUtils.h"

@implementation VenueDetailController

@synthesize delegate, venue;


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



-(id) initWithVenue:(FSVenue*)ven
{
	self = [super init];
	if (self != nil) {
		
		self.venue = ven;
		self.title = ven.name;
		self.navigationItem.hidesBackButton = NO;
		self.navigationItem.title = ven.name;
		
	}
	return self;
}

-(void) setVenue:(FSVenue *)v {
	
	[venue release];
	
	venue = [v retain];
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:nil];
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Fav" style:UIBarButtonItemStylePlain target:self action:nil];
	
	mapView.showsUserLocation = YES;
	
	
	if ( self.venue ) {
		
		VenueAnnotation * venueAnno = [[VenueAnnotation alloc] init];
		venueAnno.venue = self.venue;
		[mapView addAnnotation:venueAnno];
		
		
		MKCoordinateRegion newRegion;
    
		newRegion.center.latitude = self.venue.lat;
		newRegion.center.longitude = self.venue.lng;
	
		newRegion.span.latitudeDelta = 0.0112872;
		newRegion.span.longitudeDelta = 0.0109863;
		
		[mapView setRegion:newRegion animated:YES];
		
		
		if ( venue.phone != nil ) {
			
			callButton.enabled = YES;
			
		} else {
			callButton.enabled = NO;
		}	
		
		if ( venue.isLocalFavorite ) {
			
			[favoriteButton setTitle:@"Unfavorite"];
			
		} else {
			[favoriteButton setTitle:@"Mark Favorite"];
		}
			
		
	
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


#pragma mark Buttons Actions

-(IBAction) favoriteClicked {
	
	
	if ( self.venue.isLocalFavorite ) {
		[self.venue unFavorite];
	} else {
		[self.venue markAsFavorite];
	}
	
	if ( venue.isLocalFavorite ) {
		[favoriteButton setTitle:@"Unfavorite"];
	} else {
		[favoriteButton setTitle:@"Mark Favorite"];
	}
	
	
}

-(IBAction) getDirectionsClicked {
	
	Locator * loc = [Locator instance];
	
	NSString * myLocString = [NSString stringWithFormat:@"%@,%@" , loc.latString , loc.lonString ];
	
	//NSString * destString = [NSString stringWithFormat:@"%f,%f" , venue.lat , venue.lng ];
	NSString * destString = nil;
	
	if ( venue.address != nil ) {
		destString = [NSString stringWithFormat:@"%@ %@,%@ %@" , venue.name, venue.address , venue.city, venue.state ];
		destString = [destString stringByPreparingForURL];
	} else if ( venue.lat != 0.0 )  {
		destString = [NSString stringWithFormat:@"%f,%f" , venue.lat , venue.lng ];
	} else {
		
		UIAlertView * al  = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There doesn't appear to be an address for this Venue." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[al show];
		[al release];
		
		return;
	}
	
	
	NSLog(@"dest: %@ " , destString );
	
	NSString* urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@" , myLocString , destString ];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
	
	
}

-(IBAction) callClicked {

	
	if ( venue.phone != nil ) {
		
		
		NSMutableString *phone = [[venue.phone mutableCopy] autorelease];
		[phone replaceOccurrencesOfString:@" " 
							   withString:@"" 
								  options:NSLiteralSearch 
									range:NSMakeRange(0, [phone length])];
		[phone replaceOccurrencesOfString:@"(" 
							   withString:@"" 
								  options:NSLiteralSearch 
									range:NSMakeRange(0, [phone length])];
		[phone replaceOccurrencesOfString:@")" 
							   withString:@"" 
								  options:NSLiteralSearch 
									range:NSMakeRange(0, [phone length])];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]];
		[[UIApplication sharedApplication] openURL:url];
		
			
	}
	
}

-(IBAction) checkinClicked {
	
	/*
	broadcastPrivate,
	broadcastPublic,
	broadcastFacebook,
	broadcastTwitter,
	broadcastBoth
	*/
	
	//
	
	UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Do you want to publicly check in at %@",venue.name] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
	[al show];
	[al release];
							
	

	
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
	
	
	if ( buttonIndex == 1 ) 
		
	{
		
		MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:self.view];
		hud.labelText  = @"Checking In..";
		[hud show:YES];
		[hud release];
		
		NSString * latString = [NSString stringWithFormat:@"%f", venue.lat];
		NSString * lngString = [NSString stringWithFormat:@"%f", venue.lng];
		
		[Foursquare2 createCheckinAtVenue:self.venue.venueId venue:self.venue.name shout:nil broadcast:broadcastPublic latitude:latString longitude:lngString accuracyLL:nil altitude:nil accuracyAlt:nil callback:^(BOOL success,id result){
			
			//NSLog(@"resu %@ ", result );
			
			[hud hide:YES];
			
			if ( success ) {
				
				UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Checked In" message:[NSString stringWithFormat:@"You are checked in to %@",venue.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[al show];
				[al release];
				
				
			}
			
		}];
		
		
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
