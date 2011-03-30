//
//  FavoriteVenuesController.m
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "FavoriteVenuesController.h"

#import "Locator.h"

#import "EGOImageView.h"
#import "VenueCell.h"
#import "VenueView.h"
#import <CoreLocation/CoreLocation.h>
#import "VenueDetailController.h"
#import "UserDetailController.h"
#import "SettingsPopupController.h"
#import "PickFavoriteVenuesController.h"
#import "PickFavoriteVenuesControllerB.h"

#import "Model.h"

#import "GeoFunctions.h"

@interface FavoriteVenuesController()

-(void) setLoading:(BOOL)loading withMessage:(NSString*)msg;

@end


@implementation FavoriteVenuesController

- (void)viewDidLoad {
    
	[super viewDidLoad];
	
	
	self.title = @"Fav Venues";
	self.navigationItem.title = @"Fav Venues";
	//self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-logo.png"]];
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Ω" style:UIBarButtonItemStylePlain target:self action:@selector(settingsClicked)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-bar-button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsClicked)];
	
	//self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh-icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(refreshClicked)];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFavoriteClicked)];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genderPrefChanged) name:kGenderChangedNotification object:nil];
	
	_sortByClosestFirst = ^ NSComparisonResult (id obj1, id obj2) {
		
		FSVenue * v1 = (FSVenue*)obj1;
		FSVenue * v2 = (FSVenue*)obj2;
		
		if( v1.distanceFromMe < v2.distanceFromMe )
			return NSOrderedAscending;
		else if( v1.distanceFromMe > v2.distanceFromMe )
			return NSOrderedDescending;
		else 
			return NSOrderedSame;
		
	};
	
	
}

-(void) viewDidUnload {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

-(void) viewWillAppear:(BOOL)animated {
	
	NSLog(@"will appear");
	
	if ( [Foursquare2 isNeedToAuthorize]) {
		
		return;
		
	} else if ( !isLoading && (venuesArray ==nil || ([venuesArray count] ==0) || ([Model instance].favoritesAreOutOfDate )) ) {
		
		if ( [[Model instance].favoriteVenues count] == 0 ) { 
			
			[self showNoFavs];
			return; 
			
		} else {
			[self hideNoFavs];
		}
		
		[self startLocation];
		
	}
	
}

-(void) viewWillDisappear:(BOOL)animated {
	
	// kind of a hack it seems, but the only way it re-appears upon popping
	self.hidesBottomBarWhenPushed = NO;
	
}

-(void) genderPrefChanged {
	
	//[self refreshClicked];
	[self displayVenues];
	
}

-(void) hideNoFavs {
	
	NSLog(@"hide favs");
	
	if ( [noFavsView superview] ) {
		[noFavsView removeFromSuperview];
		noFavsView = nil;
	}
	
}

-(void) showNoFavs {
	
	NSLog(@"show favs");
	
	[self clearDataAndViews];
	
	if ( [noFavsView superview] ) {
		[noFavsView removeFromSuperview];
		noFavsView = nil;
	}
	
	noFavsView = [[UIView alloc] initWithFrame:CGRectInset(self.view.bounds, 36, 130)];
	noFavsView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
	noFavsView.layer.cornerRadius = 20;
	noFavsView.center = self.view.center;
	
	UILabel * lab = [[UILabel alloc] init];
	lab.font = [UIFont boldSystemFontOfSize:18];
	lab.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
	lab.backgroundColor = [UIColor clearColor];
	lab.textAlignment = UITextAlignmentCenter;
	lab.text = @"Choose Favorite\nVenues By Clicking\n'+' Above";
	lab.numberOfLines = 3;
	lab.frame = CGRectInset(noFavsView.bounds, 5, 5);
	
	//[lab sizeToFit];
	[noFavsView addSubview:lab];
	[lab release];
	
	[self.view addSubview:noFavsView];
	[noFavsView release];
	
}



#pragma mark -
#pragma mark Buttons

-(void) addFavoriteClicked {
	
	NSLog(@"yay");
	
	
	PickFavoriteVenuesController * pc = [[PickFavoriteVenuesController alloc] init];
	
	UINavigationController * nc = [[UINavigationController alloc ] initWithRootViewController:pc];
	
	[self presentModalViewController:nc animated:YES];
	
	[pc release];
	[nc release];
	
	
}

-(IBAction) refreshClicked {
	
	if ( [[Model instance].favoriteVenues count] == 0 ) { 
		[self showNoFavs];
		return; 
	}
		
	if ( isLoading ) { return; }
	
	[self startLocation];
	
	//[self setLoading:YES withMessage:@"Refreshing..."];
	//[self findPeople];
	
	
}

-(IBAction) settingsClicked {
	
	
	SettingsPopupController * settingsController = [[SettingsPopupController alloc] init];
	settingsController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	[self presentModalViewController:settingsController animated:YES];
	[settingsController release];
	
	
}

#pragma mark -

-(void) startLocation {
	
	isLocating = YES;
	
	[self setLoading:YES withMessage:@"Locating..."];
	
	[Locator instance].currentDesiredAccuracy = 1500;
	[Locator instance].location = nil;
	[[Locator instance] start];
	
	[self performSelector:@selector(locationLoop) withObject:nil afterDelay:0.9];
	
}


-(void) locationLoop {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locationLoop) object:nil];
	
	if ( [Locator instance].hasReceivedLocation || [Locator instance].hasReceivedError ) {
		
		CLLocation * loc;
		
		if ( [Locator instance].hasReceivedError ) {
			
			//[self stopLoading];
			
			isLocating = NO;
			
			//ALERT
			UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We could not locate you. Being indoors can degrade location accuracy." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[al show];
			[al release];
			
			return;
			
		} else {
			
			isLocating = NO;
			
			//[self stopLoading];
			
			[self findPeople];
			
		}
		
	} else {
		
		[self performSelector:@selector(locationLoop) withObject:nil afterDelay:0.5];
		
	}
	
	
}

-(void) stopLoading {
	
	isLoading = NO;
	
	if ( hud && [hud superview] ) {
		
		[hud hide:YES];
		
	}
	
}

-(void) setLoading:(BOOL)loading withMessage:(NSString*)msg {
	
	isLoading = loading;
	
	if ( loading ) {
		
		if ( !hud ) {
			
			hud = [[MBProgressHUD alloc] initWithView:self.parentViewController.view];
			[self.parentViewController.view addSubview:hud];
			
		}
		
		hud.labelText = msg;    
		[hud show:YES];
		
		
	} else {
		
		if ( hud && [hud superview] ) {
			
			[hud hide:YES];
			
		}
	}
	
}

-(void) showApiError {
	
	UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"The internet isn't behaving, please try again later!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[al show];
	[al release];
	
	[self stopLoading];
	
	
	
}

-(void) clearDataAndViews {
	
	[venueViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	scrollView.contentOffset = CGPointMake(0, 0);
	
	[venueViews removeAllObjects];
	[venueViews release];
	venueViews = [[NSMutableArray alloc] init];
	currentYOffset = 0;
	
	[venuesArray removeAllObjects];
	[venuesArray release];
	venuesArray = nil;
	
}

-(void) findPeople {
	
	
	//loc = [Locator instance].location;
	
	//NSLog(@"Got location: %@ " , [Locator instance].latString );
	
	//[Foursquare2 searchVenuesNearByLatitude:[Locator instance].latString longitude:[Locator instance].lonString accuracyLL:@"5000" altitude:nil accuracyAlt:nil query:@"" limit:@"200" intent:nil callback:^(BOOL success,id result){
	
	hud.labelText = @"Searching...";
	
	
	[self clearDataAndViews];
	
	//[Foursquare2 getTrendingVenuesNearByLatitude:[Locator instance].latString longitude:[Locator instance].lonString radius:@"5000" limit:@"50" callback:^(BOOL success,id result){
	
	
	/*if ( !success ) {
	 
	 [self performSelectorOnMainThread:@selector(showApiError) withObject:nil waitUntilDone:YES];			
	 return;
	 }
	 */
	
	//NSLog(@"got stuff: %@ , %@ " , result , [result class]);
	
	//NSArray * tempVenues = [[result objectForKey:@"response"] objectForKey:@"venues"];
	//tempVenues = [FSVenue venueArrayFromJson:tempVenues];
	
	NSArray * tempVenues = [Model instance].favoriteVenues;
	
	venuesArray = [[NSMutableArray alloc] init];
	
	numberOfVenuesToQuery = [tempVenues count];
	
	for (FSVenue * ven in tempVenues) {
		
		//NSLog(@"Name: %@ " , ven.name );
		
		[Foursquare2 getDetailForVenue:ven.venueId callback:^(BOOL success, id result2){
			
			if ( !success ) return;
			
			FSVenue * venue = [FSVenue venueFromJson:[[result2 objectForKey:@"response"] objectForKey:@"venue"]];
			[venuesArray addObject:venue];
			
			CLLocationCoordinate2D loc = [Locator instance].location.coordinate;
			
			double myLat = loc.latitude;
			double myLng = loc.longitude;
			
			//venue.distanceFromMe = sqrt( (venue.lat-myLat)*(venue.lat-myLat) + (venue.lng-myLng)*(venue.lng-myLng) );
			
			venue.distanceFromMe = geo_distance(venue.lat, venue.lng, myLat, myLng, 'M');
			
			
			NSLog(@"venue: %@ , people there: %i , lat: %f , dist: %f " , venue.name , [venue.peopleHere count] , venue.lat , venue.distanceFromMe );
			
			//[self performSelectorOnMainThread:@selector(showUsersFromVenue:) withObject:venue waitUntilDone:NO];	
			
			//[self performSelectorOnMainThread:@selector(delayedReloadTable) withObject:nil waitUntilDone:NO];	
			
			[self performSelectorOnMainThread:@selector(delayedDisplayVenues) withObject:nil waitUntilDone:NO];	
			
			
		}];
		
		
	}
	
	
	
	//}];
	
	
	
	
	
}

-(void) delayedDisplayVenues {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayVenues) object:nil];
	[self performSelector:@selector(displayVenues) withObject:nil afterDelay:0.85];
	
	
}

-(void) delayedReloadTable {
	
	
	[NSObject cancelPreviousPerformRequestsWithTarget:tableView selector:@selector(reloadData) object:nil];
	[tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.15];
	
	
}

-(void) displayVenues {
	
	NSLog(@"num: %i , count: %i " , numberOfVenuesToQuery , [venuesArray count] );
	
	if ( [venuesArray count] == numberOfVenuesToQuery ) {
		[Model instance].favoritesAreOutOfDate = NO;
		[self stopLoading];
	}
	
	NSLog(@"DISPLAY");
	
	[self sortVenuesByDistance];
	
	currentYOffset = 0;
	
	for (FSVenue * venue in venuesArray) {
		
		[self showUsersFromVenue:venue];
		
	}
	
	
}

-(void) sortVenuesByDistance {
	
	
	[venuesArray sortUsingComparator:_sortByClosestFirst];
	
	
	
}

-(void) showUsersFromVenue:(FSVenue*)ven {
	
	// check if we have a cell for it already... 
	
	// if so, update it
	
	//venueViews
	
	GenderPreference pref = [Model instance].genderPreference;
	
	/*
	if ( pref == GENDER_PREFERENCE_ALL && ven.numPeopleHereWithPhotos == 0 ) {
		return;
	} else if ( pref == GENDER_PREFERENCE_FEMALES && ven.numGirlsHereWithPhotos == 0 ) {
		return;
	} else if ( pref == GENDER_PREFERENCE_MALES && ven.numGuysHereWithPhotos == 0 ) {
		return;
	}
	*/
	
	VenueView * venView = nil;
	
	for (VenueView * vView in venueViews) {
		if ( vView.venue == ven ) {
			venView = vView;
		}
	}
	
	if ( venView == nil ) {
		
		venView = [[VenueView alloc] init];
		//venView.genderPreference = pref;
		venView.venue = ven;
		venView.delegate = self;
		[venueViews addObject:venView];
		[venView release];
		
	}
	//float height = [self getCurrentYOffset];
	
	float heightOfView; 
	
	if ( pref == GENDER_PREFERENCE_ALL ) {
		heightOfView = 64 + ceil( (float)ven.numPeopleHereWithPhotos / 2.0 ) * 154;
	} else if ( pref == GENDER_PREFERENCE_MALES ) {
		heightOfView = 64 + ceil( (float)ven.numGuysHereWithPhotos / 2.0 ) * 154;
	} else if ( pref == GENDER_PREFERENCE_FEMALES ) {
		heightOfView = 64 + ceil( (float)ven.numGirlsHereWithPhotos / 2.0 ) * 154;
	}
	
	
	
	venView.frame = CGRectMake(0, currentYOffset, self.view.frame.size.width, heightOfView );
	
	currentYOffset += (heightOfView+4);
	
	[scrollView addSubview:venView];
	
	scrollView.contentSize = CGSizeMake(self.view.frame.size.width, currentYOffset);
	
	
	
	
}


-(void) venueViewDidClickVenueTitle:(VenueView*)venView {
	
	self.hidesBottomBarWhenPushed  = YES;
	
	VenueDetailController * vdc = [[VenueDetailController alloc] initWithVenue:venView.venue];
	[self.navigationController pushViewController:vdc animated:YES];
	
	//UITabBarController * t = self.parentViewController.parentViewController;
	
	
	
	
}


-(void) venueView:(VenueView*)venView clickedUser:(FSUser*)usr {
	
	NSLog(@"User clicked: %@ " , usr );
	
	self.hidesBottomBarWhenPushed  = YES;
	
	UserDetailController * udc = [[UserDetailController alloc] initWithUser:usr];
	[self.navigationController pushViewController:udc animated:YES];
	
	
}









/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	FSVenue * ven = [venuesArray objectAtIndex:indexPath.row];
	
	return ven.contentHeightForCell;
	
	
	
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	if ( isLoading ) {
		
		return 0;	
		
	} else {
		
		return [venuesArray count];
		
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"VenueCell";
    
    VenueCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[VenueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	FSVenue * ven = [venuesArray objectAtIndex:indexPath.row];
	cell.venue = ven;
	
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}



- (void)dealloc {
    [super dealloc];
}



@end
