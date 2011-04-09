//
//  RootViewController.h
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foursquare2.h"
#import "MBProgressHUD.h"
#import "PullToRefreshManager.h"
#import "UIScrollViewPullRefresh.h"

#import "FSObjects.h"

@interface AroundMeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PullToRefreshDelegate> {
	

	//BOOL isLoading;
	
	float currentYOffset;
	
	BOOL usersDisplayed;
	
	
	//NSMutableArray * venuesArray;
	NSMutableArray * venueViews;
	
	//BOOL isLocating;
	
	int photoIndex;
	
	//int numberOfVenuesToQuery;
	
	//MBProgressHUD * hud;
	
	IBOutlet UIScrollViewPullRefresh * scrollView;
	
	IBOutlet UITableView * tableView;
	
	PullToRefreshManager * pullToRefresh;
	
	UILabel * statusLabel;
	
	int totalGuysOut;
	int totalGirlsOut;
	
	UIImageView * noVenuesView;
	
	
}

-(IBAction) refreshClicked;
-(IBAction) settingsClicked;

@end





