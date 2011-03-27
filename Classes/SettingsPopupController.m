//
//  SettingsPopupController.m
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "SettingsPopupController.h"
#import "Model.h"


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
	
	UIImageView * imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-logo-backwards.png"]];
	imgView.contentMode = UIViewContentModeCenter;
	
	titleBar.topItem.titleView = imgView;
	//UINavigationBar
	//UINavigationItem * item = [[UINavigationItem alloc] init];
	//item.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-logo-backwards.png"]];
	//[titleBar pushNavigationItem:item  animated:NO];
	//titleBar.topItem.titleView
}


-(void) viewWillAppear:(BOOL)animated {
	
	GenderPreference g = [Model instance].genderPreference;
	
	
	if ( g == GENDER_PREFERENCE_ALL ) {
		genderSegment.selectedSegmentIndex = 2;
	} else if ( g == GENDER_PREFERENCE_MALES ) {
		genderSegment.selectedSegmentIndex = 0;
	} else if ( g == GENDER_PREFERENCE_FEMALES ) { 
		genderSegment.selectedSegmentIndex = 1;
	}
		
}

-(IBAction) closeClicked {
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction) genderPrefClicked {
	
	
	
	if ( genderSegment.selectedSegmentIndex == 2 && [Model instance].genderPreference != GENDER_PREFERENCE_ALL ) {
		
		[Model instance].genderPreference = GENDER_PREFERENCE_ALL;
		[[NSNotificationCenter defaultCenter] postNotificationName:kGenderChangedNotification object:nil];
		
	} else if ( genderSegment.selectedSegmentIndex == 0 && [Model instance].genderPreference != GENDER_PREFERENCE_MALES ) { 
		
		[Model instance].genderPreference = GENDER_PREFERENCE_MALES;
		[[NSNotificationCenter defaultCenter] postNotificationName:kGenderChangedNotification object:nil];
		
	} else if ( genderSegment.selectedSegmentIndex == 1 && [Model instance].genderPreference != GENDER_PREFERENCE_FEMALES ) { 
		
		[Model instance].genderPreference = GENDER_PREFERENCE_FEMALES;
		[[NSNotificationCenter defaultCenter] postNotificationName:kGenderChangedNotification object:nil];
		
	}
	
	
	
	
}

-(IBAction) radiusChanged {
	
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
