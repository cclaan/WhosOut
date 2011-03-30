//
//  UserDetailController.m
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "UserDetailController.h"

#import "Foursquare2.h"

@implementation UserDetailController

@synthesize user;

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

- (id) initWithUser:(FSUser*)usr
{
	self = [super init];
	if (self != nil) {
		
		self.user = usr;
		
	}
	return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	[super viewDidLoad];
	
	userImageView.backgroundColor = [UIColor darkGrayColor];
	userImageView.contentMode = UIViewContentModeScaleAspectFit;
	
	//userImageView.image = 
	[userImageView setImageURL:[NSURL URLWithString:user.photoUrl ]];
	
	//userName.text = [NSString stringWithFormat:@"%@ %@ " , user.firstName , user.lastName];
	
	if ( user.lastName ) {
		userName.text = [NSString stringWithFormat:@"  %@ %@" , user.firstName , user.lastName ];
	} else {
		userName.text = [NSString stringWithFormat:@"  %@" , user.firstName ];
	}
	
	[userStatsButton setTitle:[NSString stringWithFormat:@"%i Checkins" , 3 ] forState:UIControlStateNormal];
	
	if ( user.isLocalFavorite ) {
		[favoriteUserButton setTitle:@"Unfavorite" forState:UIControlStateNormal];
	} else {
		[favoriteUserButton setTitle:@"Mark Favorite" forState:UIControlStateNormal];
	}
	
	[Foursquare2 getDetailForUser: user.userId callback:^(BOOL success, id result){
		
		
		if ( success ) {
			NSLog(@"result: %@ " , result );
		}
		
	}];

	
	
}


-(IBAction) favoriteUserClicked {
	
	
	
	if ( user.isLocalFavorite ) {
		[self.user unFavorite];
	} else {
		[self.user markAsFavorite];
	}
	
	
	if ( user.isLocalFavorite ) {
		[favoriteUserButton setTitle:@"Unfavorite" forState:UIControlStateNormal];
	} else {
		[favoriteUserButton setTitle:@"Mark Favorite" forState:UIControlStateNormal];
	}
	
	
	
}

-(IBAction) buyDrinkClicked {
	
	
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
