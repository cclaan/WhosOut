//
//  VenuePeopleDetailController.m
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "VenuePeopleDetailController.h"
#import "Locator.h"
#import "Model.h"
#import "UserDetailController.h"

#import "NSString+EscapingUtils.h"

#import "Foursquare2.h"

@implementation VenuePeopleDetailController

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
	
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom-navbar-logo.png"]];
	
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:nil];
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Fav" style:UIBarButtonItemStylePlain target:self action:nil];
	

	
	if ( self.venue ) {
		
		
		if ( venue.phone != nil ) {
			
			callButton.enabled = YES;
			
		} else {
			callButton.enabled = NO;
		}	
		
		if ( venue.isLocalFavorite ) {
			
			//[favoriteButton setTitle:@"Unfavorite"];
			[favoriteButton setImage:[UIImage imageNamed:@"unfavorite-icon.png"] forState:UIControlStateNormal];
			
		} else {
			//[favoriteButton setTitle:@"Favorite"];
			[favoriteButton setImage:[UIImage imageNamed:@"favorite-icon.png"] forState:UIControlStateNormal];
		}
			
	
	}
	
	
	if ( venueView == nil ) {
		
		venueView = [[VenueView alloc] init];
		//venView.genderPreference = pref;
		venueView.isFullPageVenue = YES;
		venueView.venue = self.venue;
		venueView.delegate = self;
		
	}
	
	GenderPreference pref = [Model instance].genderPreference;
	float heightOfView; 
	
	if ( pref == GENDER_PREFERENCE_ALL ) {
		heightOfView = 64 + ceil( (float)venue.numPeopleHereWithPhotos / 2.0 ) * 154;
	} else if ( pref == GENDER_PREFERENCE_MALES ) {
		heightOfView = 64 + ceil( (float)venue.numGuysHereWithPhotos / 2.0 ) * 154;
	} else if ( pref == GENDER_PREFERENCE_FEMALES ) {
		heightOfView = 64 + ceil( (float)venue.numGirlsHereWithPhotos / 2.0 ) * 154;
	}
	
	
	
	venueView.frame = CGRectMake(0, 0, self.view.frame.size.width, heightOfView );
	
	[scrollView addSubview:venueView];
	
	scrollView.contentSize = CGSizeMake(self.view.frame.size.width, heightOfView);

	
}

#pragma mark -
#pragma mark Venue View Delegate


-(void) venueViewDidClickVenueTitle:(VenueView*)venView {
	
	// nothing...
	
	
}


-(void) venueView:(VenueView*)venView clickedUser:(FSUser*)usr {
	
	NSLog(@"User clicked: %@ " , usr );
	
	//self.hidesBottomBarWhenPushed  = YES;
	
	UserDetailController * udc = [[UserDetailController alloc] initWithUser:usr];
	[self.navigationController pushViewController:udc animated:YES];
	
	
}




#pragma mark Buttons Actions

-(IBAction) favoriteClicked {
	
	
	if ( self.venue.isLocalFavorite ) {
		[self.venue unFavorite];
	} else {
		[self.venue markAsFavorite];
	}
	
	if ( venue.isLocalFavorite ) {
		//[favoriteButton setTitle:@"Unfavorite"];
		[favoriteButton setImage:[UIImage imageNamed:@"unfavorite-icon.png"] forState:UIControlStateNormal];
	} else {
		//[favoriteButton setTitle:@"Favorite"];
		[favoriteButton setImage:[UIImage imageNamed:@"favorite-icon.png"] forState:UIControlStateNormal];
	}
	
	
}

-(IBAction) getDirectionsClicked {
	
	
	UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Leave App?" message:@"Directions uses the Google Maps Application" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
	al.tag = 2967;
	[al show];
	[al release];
	
}

-(void) doDirections {


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
	al.tag = 5478;
	[al show];
	[al release];
	
	
	
	
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
	
	
	if ( buttonIndex == 1 && alertView.tag == 5478 ) 
		
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
		
		
	}  else if ( buttonIndex == 1 && alertView.tag == 2967 )  {
		
		[self doDirections];
		
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
