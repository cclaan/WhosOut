//
//  PickFavoriteVenuesController.h
//  MoreSquare
//
//  Created by Chris Laan on 3/27/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSObjects.h"
#import "FSFavVenueCell.h"
#import "MBProgressHUD.h"

typedef enum PickVenueViewMode {
	
	VIEW_MODE_NEARBY,
	VIEW_MODE_PAST_VENUES,
	VIEW_MODE_SEARCH,
	
} PickVenueViewMode;


@interface PickFavoriteVenuesController : UIViewController <UITableViewDelegate , UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate> {
	
	IBOutlet UITableView * tableView;
	IBOutlet UISearchBar * searchBar;
	IBOutlet UISegmentedControl * segmentedControl;

	IBOutlet UIButton * nearbyTabButton;
	IBOutlet UIButton * pastTabButton;
	
	UISearchDisplayController * searchController;
	
	PickVenueViewMode viewMode;
	
	MBProgressHUD * hud;
	
	NSComparisonResult (^_sortByClosestFirst)(id obj1, id obj2);
	NSComparisonResult (^_sortByBeenHereCount)(id obj1, id obj2);
	
	CGRect tFrame1;
	CGRect tFrame2;
}

@property (nonatomic, retain) NSMutableArray * nearbyVenues;
@property (nonatomic, retain) NSMutableArray * pastVenues;
@property (nonatomic, retain) NSMutableArray * filteredVenues;
@property (nonatomic, retain) NSMutableArray * searchResultsVenues;

-(IBAction) closeClicked;
-(IBAction) segmentChanged;

-(IBAction) nearbyTabClicked;
-(IBAction) pastTabClicked;

@end
