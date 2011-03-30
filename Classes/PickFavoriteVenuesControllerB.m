//
//  PickFavoriteVenuesControllerB.m
//  MoreSquare
//
//  Created by Chris Laan on 3/27/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "PickFavoriteVenuesControllerB.h"
#import "Foursquare2.h"
#import "Model.h"
#import "Locator.h"

@implementation PickFavoriteVenuesControllerB

@synthesize searchResultsVenues, filteredVenues, pastVenues, nearbyVenues;

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



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	viewMode = VIEW_MODE_PAST_VENUES;
	
	self.navigationItem.title = @"Pick a Fav";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeClicked)];
	
	
	segmentedControl.selectedSegmentIndex = viewMode;
	[segmentedControl addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];
	
	if ( !hud ) {
		hud = [[MBProgressHUD alloc] initWithView:self.view];
	}
	
	
	searchController = [[UISearchDisplayController alloc]
						initWithSearchBar:searchBar contentsController:self];
	searchController.delegate = self;
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
	
	searchBar.delegate = self;
	
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
	
	
	_sortByBeenHereCount = ^ NSComparisonResult (id obj1, id obj2) {
		
		FSVenue * v1 = (FSVenue*)obj1;
		FSVenue * v2 = (FSVenue*)obj2;
		
		if( v1.beenHereCount > v2.beenHereCount )
			return NSOrderedAscending;
		else if( v1.beenHereCount < v2.beenHereCount )
			return NSOrderedDescending;
		else 
			return NSOrderedSame;
		
	};
	
	
}

-(void) viewDidAppear:(BOOL)animated {
	
	
	[self getDataIfNeeded];
	
	
}

-(void) getDataIfNeeded {
	
	switch (viewMode) {
		case VIEW_MODE_NEARBY:
		{
			
			if ( nearbyVenues == nil ) {
				[self getNearbyVenues];
			} else {
				[tableView reloadData];
			}
			
			break;
		}
			
		case VIEW_MODE_PAST_VENUES:
		{
			if ( pastVenues == nil ) {
				[self getPastVenues];
			} else {
				[tableView reloadData];
			}
			break;
		}
			
		case VIEW_MODE_SEARCH:
		{
			[tableView reloadData];
			// do nothing ?
			break;
		}
			
	}
	
	
	
}

-(void) networkDataLoaded {
	
	[tableView reloadData];
	
}

-(void) getPastVenues {
	
	[self.view addSubview:hud];
	hud.labelText = @"Searching...";
	[hud show:YES];
	
	[Foursquare2 getVenuesVisitedByUser:@"self" callback:^(BOOL success, id result){
		
		[hud hide:YES];
		
		//NSLog(@"result: %@ " , result );
		
		if ( success ) {
			
			id venuesObject = [[[result objectForKey:@"response"] objectForKey:@"venues"] objectForKey:@"items"];
			
			//pastVenues = [[FSVenue venueArrayFromJson:result] retain];
			pastVenues = [[FSVenue venueArrayFromHistoryJson:venuesObject] retain];			  
			
			[pastVenues sortUsingComparator:_sortByBeenHereCount];
			
			[self performSelectorOnMainThread:@selector(networkDataLoaded) withObject:nil waitUntilDone:NO];
			
		}
		
	}];
	
}


-(void) getNearbyVenues {
	
	/*
	NSArray * arr = [Model instance].venuesArray;
	
	if ( arr ) {
		self.nearbyVenues = arr;
	}
	
	[self networkDataLoaded];
	*/
	
	[self.view addSubview:hud];
	hud.labelText = @"Looking...";
	[hud show:YES];
	
	[Foursquare2 searchVenuesNearByLatitude:[Locator instance].latString longitude:[Locator instance].lonString accuracyLL:nil altitude:nil accuracyAlt:nil query:nil limit:@"200" intent:nil callback:^(BOOL success, id result){
	//[Foursquare2 getVenuesVisitedByUser:@"self" callback:^(BOOL success, id result){
		
		[hud hide:YES];
		
		NSLog(@"search result: %@ " , result );
		
		
		if ( success ) {
		
									  
			id groupsArr = [[result objectForKey:@"response"] objectForKey:@"groups"];
			id itemsArr = [[groupsArr objectAtIndex:0] objectForKey:@"items"];
			
			nearbyVenues = [[FSVenue venueArrayFromJson:itemsArr] retain];
			//pastVenues = [[FSVenue venueArrayFromHistoryJson:venuesObject] retain];			  
			
			//[pastVenues sortUsingComparator:_sortByBeenHereCount];
			
			[self performSelectorOnMainThread:@selector(networkDataLoaded) withObject:nil waitUntilDone:NO];
			
		}
		
	}];
	
	
}

-(void) searchForVenueWithString:(NSString*)str {
	
	
	[self.view addSubview:hud];
	hud.labelText = @"Finding...";
	[hud show:YES];
	
	[Foursquare2 searchVenuesNearByLatitude:[Locator instance].latString longitude:[Locator instance].lonString accuracyLL:nil altitude:nil accuracyAlt:nil query:str limit:@"200" intent:nil callback:^(BOOL success, id result){
		//[Foursquare2 getVenuesVisitedByUser:@"self" callback:^(BOOL success, id result){
		
		[hud hide:YES];
		
		//NSLog(@"search result: %@ " , result );
		
		
		if ( success ) {
			
			
			id groupsArr = [[result objectForKey:@"response"] objectForKey:@"groups"];
			id itemsArr = [[groupsArr objectAtIndex:0] objectForKey:@"items"];
			
			searchResultsVenues = [[FSVenue venueArrayFromJson:itemsArr] retain];
			//pastVenues = [[FSVenue venueArrayFromHistoryJson:venuesObject] retain];			  
			
			//[pastVenues sortUsingComparator:_sortByBeenHereCount];
			
			[self performSelectorOnMainThread:@selector(networkDataLoaded) withObject:nil waitUntilDone:NO];
			
		}
		
	}];
	
}


-(IBAction) segmentChanged {

	
	if ( viewMode != segmentedControl.selectedSegmentIndex ) {
		
		viewMode = segmentedControl.selectedSegmentIndex;
		[self getDataIfNeeded];
		
	}
	
	
}


-(IBAction) closeClicked {
	
	[self dismissModalViewControllerAnimated:YES];
	
	
}



#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
	return 1;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	return 64;
	
}

-(NSArray*)arrayForTableView:(UITableView*)tbl andMode:(PickVenueViewMode)moder {
	
	if ( tbl == tableView ) {
		
		switch (moder) {
			case VIEW_MODE_NEARBY:
				return nearbyVenues;
				break;
			case VIEW_MODE_PAST_VENUES:
				return pastVenues;
				break;
			case VIEW_MODE_SEARCH:
				return searchResultsVenues;
				break;
		}
		
	} else if ( tbl == searchController.searchResultsTableView ) {
		
		return filteredVenues;
		
	}
	
}	

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    
	NSArray * arr = [self arrayForTableView:_tableView andMode:viewMode];
	
	return [arr count];
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSArray * arr = [self arrayForTableView:_tableView andMode:viewMode];
	
    static NSString *CellIdentifier = @"VenueCell";
    
    FSFavVenueCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FSFavVenueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	FSVenue * ven = [arr objectAtIndex:indexPath.row];
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

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSLog(@"select venue");
	
	NSArray * arr = [self arrayForTableView:_tableView andMode:viewMode];
	
	FSVenue * ven = [arr objectAtIndex:indexPath.row];
	
	
	[ven markAsFavorite];
	
	
	
	
}



#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
	[self filterContentForSearchText:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
	
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	//--[[NSNotificationCenter defaultCenter] postNotificationName:@"tableSearchBegan" object:nil];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	//--[[NSNotificationCenter defaultCenter] postNotificationName:@"tableSearchEnded" object:nil];
}

#pragma mark search bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	
	
	NSString * txt = [_searchBar.text copy];
	NSLog(@"search buttons clicked ");
	
	//[searchController setActive:NO animated:YES];
	
	segmentedControl.selectedSegmentIndex = VIEW_MODE_SEARCH;
	
	//searchBar.text = txt;
	
	[self searchForVenueWithString:txt];
	
	
}


#pragma mark search controller

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	self.filteredVenues = nil; // First clear the filtered array.
	
	//searchController.searchResultsTableView.separatorColor = [UIColor colorWithWhite:0.1 alpha:1.0];
	//searchController.searchResultsTableView.backgroundColor = [UIColor colorWithWhite:0.24 alpha:1.0];
	
	/*
	 
	 NSPredicate *predicate = [NSPredicate predicateWithFormat:
	 @"(SELF contains[cd] %@)", searchText];
	 [product.productID compare:searchText options:NSCaseInsensitiveSearch];
	 BOOL resultID = [predicate evaluateWithObject:product.productID];
	 BOOL resultName = [predicate evaluateWithObject:product.productName];
	 
	 */
	
	
	filteredVenues = [[NSMutableArray alloc] init];
	
	NSArray * arr = [self arrayForTableView:tableView andMode:viewMode];
	
	for (FSVenue * ven in arr) {
		
		if ( [[ven.name lowercaseString] rangeOfString:[searchText lowercaseString]].length > 0 ) {
			[filteredVenues addObject:ven];
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
