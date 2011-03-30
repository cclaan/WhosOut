//
//  PickFavoriteVenuesControllerB.h
//  MoreSquare
//
//  Created by Chris Laan on 3/27/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSObjects.h"
#import "FSFavVenueCell.h"
#import "MBProgressHUD.h"
#import "PickFavoriteVenuesController.h"
/*
typedef enum PickVenueViewMode {
	
	VIEW_MODE_NEARBY,
	VIEW_MODE_PAST_VENUES,
	VIEW_MODE_SEARCH,
	
} PickVenueViewMode;
*/

@interface PickFavoriteVenuesControllerB : UIViewController <UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate> {
	
	IBOutlet UITableView * tableView;
	IBOutlet UISearchBar * searchBar;
	IBOutlet UISegmentedControl * segmentedControl;

	
	UISearchDisplayController * searchController;
	
	PickVenueViewMode viewMode;
	
	MBProgressHUD * hud;
	
	NSComparisonResult (^_sortByClosestFirst)(id obj1, id obj2);
	NSComparisonResult (^_sortByBeenHereCount)(id obj1, id obj2);
	
}

@property (nonatomic, retain) NSMutableArray * nearbyVenues;
@property (nonatomic, retain) NSMutableArray * pastVenues;
@property (nonatomic, retain) NSMutableArray * filteredVenues;
@property (nonatomic, retain) NSMutableArray * searchResultsVenues;

-(IBAction) closeClicked;
-(IBAction) segmentChanged;

@end
