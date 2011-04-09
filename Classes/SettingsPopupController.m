//
//  SettingsPopupController.m
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "SettingsPopupController.h"

#import "WhosOutConstants.h"


@implementation SettingsPopupController

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
	
	//UIImageView * imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-logo-backwards.png"]];
	//imgView.contentMode = UIViewContentModeCenter;
	//titleBar.topItem.titleView = imgView;
	titleBar.topItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom-navbar-logo.png"]];
	

	rangeMap[0] = 100;
	rangeMap[1] = 200;
	rangeMap[2] = 500;
	rangeMap[3] = 1000;
	rangeMap[4] = 2000;
	rangeMap[5] = 3000;
	rangeMap[6] = 5000;
	
	
	//UINavigationBar
	//UINavigationItem * item = [[UINavigationItem alloc] init];
	//item.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-logo-backwards.png"]];
	//[titleBar pushNavigationItem:item  animated:NO];
	//titleBar.topItem.titleView
}


-(void) viewWillAppear:(BOOL)animated {
	
	GenderPreference g = [Model instance].genderPreference;
	
	startPref = g;
	
	initialRange = [Model instance].nearbySearchRange;
	
	
	if ( g == GENDER_PREFERENCE_ALL ) {
		genderSegment.selectedSegmentIndex = 2;
	} else if ( g == GENDER_PREFERENCE_MALES ) {
		genderSegment.selectedSegmentIndex = 0;
	} else if ( g == GENDER_PREFERENCE_FEMALES ) { 
		genderSegment.selectedSegmentIndex = 1;
	}
	
	int rng = [Model instance].nearbySearchRange;
	NSLog(@"initial range: %i " , rng );
	
	for (int i = 0; i < 7; i++) {
		if ( rangeMap[i] == rng ) { 
			radiusSlider.value = (float)i; 
			[self radiusChanged];
		}
	}
	
	
	[self setButtonImages];
		
}

-(IBAction) closeClicked {
	
	
	GenderPreference g = [Model instance].genderPreference;
	
	if ( startPref != g ) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kGenderChangedNotification object:nil];	
	}
	
	GenderPreference rng = [Model instance].nearbySearchRange;
	
	if ( initialRange != rng ) {
		//[[NSNotificationCenter defaultCenter] postNotificationName:kGenderChangedNotification object:nil];	
		[[Model instance] startLocationAndFindNearbyVenues];
		
	}
	
	[self dismissModalViewControllerAnimated:YES];
	
}

-(IBAction) genderPrefClicked {
	
	
	
	if ( genderSegment.selectedSegmentIndex == 2 && [Model instance].genderPreference != GENDER_PREFERENCE_ALL ) {
		
		[Model instance].genderPreference = GENDER_PREFERENCE_ALL;
		//[[NSNotificationCenter defaultCenter] postNotificationName:kGenderChangedNotification object:nil];
		
	} else if ( genderSegment.selectedSegmentIndex == 0 && [Model instance].genderPreference != GENDER_PREFERENCE_MALES ) { 
		
		[Model instance].genderPreference = GENDER_PREFERENCE_MALES;
		//[[NSNotificationCenter defaultCenter] postNotificationName:kGenderChangedNotification object:nil];
		
	} else if ( genderSegment.selectedSegmentIndex == 1 && [Model instance].genderPreference != GENDER_PREFERENCE_FEMALES ) { 
		
		[Model instance].genderPreference = GENDER_PREFERENCE_FEMALES;
		//[[NSNotificationCenter defaultCenter] postNotificationName:kGenderChangedNotification object:nil];
		
	}
	
}


-(IBAction) logoutClicked {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kFSShouldLogoutNotification object:nil];
	
	[self dismissModalViewControllerAnimated:YES];
	
	
}

-(IBAction) workButtonClicked {
	
	[[Model instance] toggleBannedCategoryString:kWorkCategoryString];
	[self setButtonImages];
	
}

-(IBAction) schoolsButtonClicked {
	
	[[Model instance] toggleBannedCategoryString:kSchoolsCategoryString];
	[self setButtonImages];
	
}

-(IBAction) shopsButtonClicked {
	
	[[Model instance] toggleBannedCategoryString:kShopsCategoryString];
	[self setButtonImages];
	
}

-(IBAction) travelButtonClicked {
	
	[[Model instance] toggleBannedCategoryString:kTravelCategoryString];
	[self setButtonImages];
	
}

-(IBAction) nightlifeButtonClicked {
	
	[[Model instance] toggleBannedCategoryString:kNightlifeCategoryString];
	[self setButtonImages];
	
}

-(IBAction) outdoorsButtonClicked {
	
	[[Model instance] toggleBannedCategoryString:kOutdoorsCategoryString];
	[self setButtonImages];
	
}

-(IBAction) foodButtonClicked {
	
	[[Model instance] toggleBannedCategoryString:kFoodCategoryString];
	[self setButtonImages];
	
}

-(IBAction) artsButtonClicked {
	
	[[Model instance] toggleBannedCategoryString:kArtsCategoryString];
	[self setButtonImages];
	
}

-(void) setButtonImages {
	
	
	schoolsButton.selected = ![[Model instance] isBannedCategoryString:kSchoolsCategoryString];
	workButton.selected = ![[Model instance] isBannedCategoryString:kWorkCategoryString];
	nightlifeButton.selected = ![[Model instance] isBannedCategoryString:kNightlifeCategoryString];
	artsButton.selected = ![[Model instance] isBannedCategoryString:kArtsCategoryString];
	travelButton.selected = ![[Model instance] isBannedCategoryString:kTravelCategoryString];
	foodButton.selected = ![[Model instance] isBannedCategoryString:kFoodCategoryString];
	shopsButton.selected = ![[Model instance] isBannedCategoryString:kShopsCategoryString];
	outdoorsButton.selected = ![[Model instance] isBannedCategoryString:kOutdoorsCategoryString];
	
	
}

-(IBAction) radiusChanged {
	
	int ind = (int)radiusSlider.value;
	
	int range = rangeMap[ind];
	
	[Model instance].nearbySearchRange = range;
	
	rangeLabel.text = [NSString stringWithFormat:@"Show people within %i meters" , range ];
	
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
