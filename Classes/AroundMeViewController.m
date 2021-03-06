//
//  RootViewController.m
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "AroundMeViewController.h"
//#import "Locator.h"

#import "EGOImageView.h"
#import "VenueCell.h"
#import "VenueView.h"
#import <CoreLocation/CoreLocation.h>
#import "VenueDetailController.h"
#import "UserDetailController.h"
#import "SettingsPopupController.h"

#import "Model.h"

#import "GeoFunctions.h"

@interface AroundMeViewController()

//-(void) setLoading:(BOOL)loading withMessage:(NSString*)msg;

@end



@implementation AroundMeViewController


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    
	[super viewDidLoad];

	
	//self.title = @"Back";
	self.navigationItem.title = @"Back";
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-logo.png"]];
	//self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Ω" style:UIBarButtonItemStylePlain target:self action:@selector(settingsClicked)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-bar-button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsClicked)];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh-icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(refreshClicked)];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genderPrefChanged) name:kGenderChangedNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayVenues) name:kVenuesUpdatedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(venuesUpdateStarted) name:kVenuesUpdateStartedNotification object:nil];	
	
	if ( !venueViews ) {
		venueViews = [[NSMutableArray alloc] init];
	}
	
}

-(void) viewDidUnload {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

-(void) viewWillAppear:(BOOL)animated {

	
	
	
	
}

-(void) viewDidAppear:(BOOL)animated {
	
	if ( [Foursquare2 isNeedToAuthorize]) {
		
		return;
		
		//} else if ( !isLoading && (venuesArray ==nil || ([venuesArray count] ==0) ) ) {
	} else if ( ![Model instance].isLoadingNearbyVenues && ([Model instance].venuesArray ==nil || ([[Model instance].venuesArray count] ==0) ) ) {	
		
		//[self startLocation];
		[[Model instance] startLocationAndFindNearbyVenues];
		
	} else if (![Model instance].isLoadingNearbyVenues && !usersDisplayed ) {
		
		[self displayVenues];
		
	}
	
}

/*
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
*/



-(void) viewWillDisappear:(BOOL)animated {
	
	// kind of a hack it seems, but the only way it re-appears upon popping
	self.hidesBottomBarWhenPushed = NO;
	
}

-(void) genderPrefChanged {
	
	
	[venueViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	scrollView.contentOffset = CGPointMake(0, 0);
	
	[venueViews removeAllObjects];
	[venueViews release];
	
	venueViews = [[NSMutableArray alloc] init];
	
	currentYOffset = 0;
	
	//[self refreshClicked];
	[self displayVenues];
	
	
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


-(void) delayedDisplayVenues {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(displayVenues) object:nil];
	[self performSelector:@selector(displayVenues) withObject:nil afterDelay:0.85];
	
	
}

-(void) delayedReloadTable {
	
	
	[NSObject cancelPreviousPerformRequestsWithTarget:tableView selector:@selector(reloadData) object:nil];
	[tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.15];
	
	
}

-(void) venuesUpdateStarted {
	
	[venueViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	scrollView.contentOffset = CGPointMake(0, 0);
	
	[venueViews removeAllObjects];
	[venueViews release];
	
	venueViews = [[NSMutableArray alloc] init];
	
	currentYOffset = 0;

	
}

-(void) displayVenues {
	
	NSArray * venuesArray = [Model instance].venuesArray;
	

	
	//scrollView.contentOffset = CGPointMake(0, 0);
	
	NSLog(@"DISPLAY VENUES, w: %f , h: %f" , scrollView.frame.size.width, scrollView.frame.size.height );
	
	//[self sortVenuesByDistance];
	
	currentYOffset = 0;
	
	for (FSVenue * venue in venuesArray) {
		
		[self showUsersFromVenue:venue];
		
	}
	
	usersDisplayed = YES;
	
}

/*
-(void) sortVenuesByDistance {
		
	NSArray * venuesArray = [Model instance].venuesArray;
	
	[venuesArray sortUsingComparator:_sortByClosestFirst];
	
	
	
}
*/

-(void) showUsersFromVenue:(FSVenue*)ven {
	
	// check if we have a cell for it already... 
	
	// if so, update it
	
	//venueViews
	
	GenderPreference pref = [Model instance].genderPreference;
	
	if ( pref == GENDER_PREFERENCE_ALL && ven.numPeopleHereWithPhotos == 0 ) {
		return;
	} else if ( pref == GENDER_PREFERENCE_FEMALES && ven.numGirlsHereWithPhotos == 0 ) {
		return;
	} else if ( pref == GENDER_PREFERENCE_MALES && ven.numGuysHereWithPhotos == 0 ) {
		return;
	}
	
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
	
	NSLog(@"height: %f , yOff: %f , " , heightOfView , currentYOffset );
	
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
	
	NSArray * venuesArray = [Model instance].venuesArray;
	
	FSVenue * ven = [venuesArray objectAtIndex:indexPath.row];
	
	return ven.contentHeightForCell;
	
	
	
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	NSArray * venuesArray = [Model instance].venuesArray;
	
	if ( [Model instance].isLoadingNearbyVenues ) {
		
		return 0;	
		
	} else {
		
		return [venuesArray count];
		
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSArray * venuesArray = [Model instance].venuesArray;
	
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

