//
//  FavoriteUsersController.m
//  MoreSquare
//
//  Created by Chris Laan on 3/27/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "FavoriteUsersController.h"
#import "UserDetailController.h"
#import "Foursquare2.h"

@implementation FavoriteUsersController

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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFavoriteUsersAgainstVenues) name:kVenuesUpdatedNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(venuesUpdateStarted) name:kVenuesUpdateStartedNotification object:nil];	
	
	
}


-(void) viewDidUnload {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}


/*
-(void) viewWillAppear:(BOOL)animated {
	
	[tableView reloadData];
	[self checkFavoriteUsers];
	
}
*/


-(void) viewDidAppear:(BOOL)animated {
	
	
	if ( [Foursquare2 isNeedToAuthorize]) {
		
		return;
		
		//} else if ( !isLoading && (venuesArray ==nil || ([venuesArray count] ==0) ) ) {
	} else if ( ![Model instance].isLoadingNearbyVenues && ([Model instance].venuesArray ==nil || ([[Model instance].venuesArray count] ==0) ) ) {	
		
		//[self startLocation];
		[[Model instance] startLocationAndFindNearbyVenues];
		
	} else if ( ![Model instance].isLoadingNearbyVenues ) {
		
		// may already be loaded..
		[self checkFavoriteUsersAgainstVenues];
		
	}
	
	
	
}



-(void) viewWillDisappear:(BOOL)animated {
	
	self.hidesBottomBarWhenPushed  = NO;
	
}


-(void) venuesUpdateStarted {
	
	
	
}

-(void) checkFavoriteUsersAgainstVenues {
	
	NSArray * vens = [Model instance].venuesArray;
	
	NSArray * favVens = [Model instance].favoriteVenues;
	
	NSArray * favUsers = [Model instance].favoriteUsers;
	
	for (FSUser * favUser in favUsers ) {
		
		if ( favUser.isMyFriend ) {
			
		} else {
		
			for (FSVenue * ven in vens) {
				
				for (FSUser * usr in ven.peopleHere ) {
					
					if ( [usr.userId isEqualToString:favUser.userId] ) {
						
						favUser.currentVenue = ven;
						usr.currentVenue = ven;
						
					}
				}
				
			}
			
			for (FSVenue * ven in favVens) {
				
				for (FSUser * usr in ven.peopleHere ) {
					
					if ( [usr.userId isEqualToString:favUser.userId] ) {
						
						NSLog(@"found user at: %@ , %@ " , ven , ven.name );
						favUser.currentVenue = ven;
						usr.currentVenue = ven;
						
					}
				}
				
			}
			
		}
		
	}
	
	[tableView reloadData];
	
}

-(void) checkFavoriteUsers {
	
	NSArray * favUsers = [Model instance].favoriteUsers;
	
	for (FSUser * usr in favUsers) {
		
		NSLog(@"getting data for user: %@ " , usr.firstName );
		
		//NSLog(@"val: %i " , usr.extraData->val );
		
		if ( usr.extraData->loaded ) {
			NSLog(@"loaded");
		}
		
		if ( usr.extraData->loading ) {
			NSLog(@"loading");
		}
		
		if ( !usr.extraData->loaded && !usr.extraData->loading ) {
			[self getExtraDataForUser:usr];
		}	
		
	}
	
	[tableView reloadData];
	
}

-(void) getExtraDataForUser:(FSUser*)usr {
	
	usr.extraData->loading = YES;
	
	NSLog(@"relaly getting data for user: %@ " , usr.firstName );
	
	//[Foursquare2 getVenuesVisitedByUser:usr.userId callback:^(BOOL success, id result){
		
	[Foursquare2 getDetailForUser: usr.userId callback:^(BOOL success, id result){
		

		if ( success ) {
			
			NSLog(@"result: %@ " , result );
			
		} else {
			
			NSLog(@"no success: %@ " , result );
			
		}
		
		usr.extraData->loaded = YES;
		usr.extraData->loading = NO;
		[self delayedReloadTable];
		
	}];
	
	
}	

-(void) delayedReloadTable {
	
	
	[NSObject cancelPreviousPerformRequestsWithTarget:tableView selector:@selector(reloadData) object:nil];
	[tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.2];
	
	
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

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	NSArray * favUsers = [Model instance].favoriteUsers;
	return [favUsers count];
		
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSArray * favUsers = [Model instance].favoriteUsers;
	
    static NSString *CellIdentifier = @"VenueCell";
    
    FSUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FSUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
	//FSVenue * ven = [venuesArray objectAtIndex:indexPath.row];
	//cell.venue = ven;
	FSUser * user = [favUsers objectAtIndex:indexPath.row];
	//cell.text = user.firstName;
	cell.user = user;

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
    
	self.hidesBottomBarWhenPushed  = YES;
	
	NSArray * favUsers = [Model instance].favoriteUsers;
	
	FSUser * user = [favUsers objectAtIndex:indexPath.row];
	
	UserDetailController * udc = [[UserDetailController alloc] initWithUser:user];
	[self.navigationController pushViewController:udc animated:YES];
	[udc release];
	
	
	
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
