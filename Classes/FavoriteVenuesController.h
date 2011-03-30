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


@interface FavoriteVenuesController : UIViewController {

	BOOL isLoading;
	
	float currentYOffset;
	
	NSMutableArray * venuesArray;
	NSMutableArray * venueViews;
	
	BOOL isLocating;
	
	int photoIndex;
	
	int numberOfVenuesToQuery;
	
	MBProgressHUD * hud;
	
	IBOutlet UIScrollView * scrollView;
	
	IBOutlet UITableView * tableView;
	
	NSComparisonResult (^_sortByClosestFirst)(id obj1, id obj2);
	
	UIView * noFavsView;
	
}

-(IBAction) refreshClicked;
-(IBAction) settingsClicked;

@end
