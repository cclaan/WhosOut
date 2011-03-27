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

#import "FSObjects.h"

@interface AroundMeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	

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
	
	
	
}

-(IBAction) refreshClicked;
-(IBAction) settingsClicked;

@end





