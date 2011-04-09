//
//  FavoriteVenuesController.h
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Foursquare2.h"
#import "MBProgressHUD.h"
#import "FSObjects.h"
#import "UIScrollViewPullRefresh.h"


@interface FavoriteVenuesController : UIViewController <PullToRefreshDelegate> {

	BOOL isLoading;
	
	float currentYOffset;
	
	NSMutableArray * venuesThatNeedData;
	NSMutableArray * venuesArray;
	NSMutableArray * venueViews;
	
	
	BOOL favoritesWereAddedSinceLastUpdate;
	BOOL favoritesWereRemovedSinceLastUpdate;
	
	BOOL isLocating;
	
	int photoIndex;
	
	int numberOfVenuesToQuery;
	int numberOfVenuesQueried;
	
	MBProgressHUD * hud;
	
	IBOutlet UIScrollViewPullRefresh * scrollView;
	
	IBOutlet UITableView * tableView;
	
	NSComparisonResult (^_sortByClosestFirst)(id obj1, id obj2);
	
	UIImageView * noFavsView;
	UIImageView * noFavsArrow;
	
	//PullToRefreshManager * pullToRefresh;
	
	UILabel * statusLabel;
	
}

-(IBAction) refreshClicked;
-(IBAction) settingsClicked;

@end
