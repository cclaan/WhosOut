//
//  VenueView.m
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "VenueView.h"
#import "EGOImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "FSVenue.h"
#import "Model.h"

@implementation VenueView

@synthesize venue, delegate;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		[self setupUi];
		
	}
	return self;
}


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

-(void) setupUi {
	
	bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-fade.png"]];
	[self addSubview:bgImgView];

	venueInformation = [[UIButton alloc] init];
	venueInformation.font = [UIFont boldSystemFontOfSize:22];
	venueInformation.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	//venueInformation.textColor = [UIColor whiteColor];
	//venueInformation.textAlignment = UITextAlignmentLeft;
	[self addSubview:venueInformation];
	
	[venueInformation addTarget:self action:@selector(venueClicked) forControlEvents:UIControlEventTouchUpInside];
	//UITapGestureRecognizer* t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(venueClicked)];
	//[venueInformation addGestureRecognizer:t];
	
	/*
	venueInformation = [[UILabel alloc] init];
	venueInformation.font = [UIFont boldSystemFontOfSize:22];
	venueInformation.backgroundColor = [UIColor clearColor];
	venueInformation.textColor = [UIColor whiteColor];
	venueInformation.textAlignment = UITextAlignmentLeft;
	[self addSubview:venueInformation];
	*/
	
	subLabel = [[UILabel alloc] init];
	subLabel.font = [UIFont systemFontOfSize:16];
	subLabel.backgroundColor = [UIColor clearColor];
	subLabel.textColor = [UIColor whiteColor];
	subLabel.textAlignment = UITextAlignmentLeft;
	[self addSubview:subLabel];
	
		
}

-(void) layoutSubviews {
	
	venueInformation.frame = CGRectMake(0, 0, self.frame.size.width , 40);
	subLabel.frame = CGRectMake(6, 35, self.frame.size.width , 25);
	
	bgImgView.frame = CGRectMake(0, 0, self.frame.size.width , 150);
}

-(void) setVenue:(FSVenue *)v {
	
	[venue release];
	venue = [v retain];
	
	/*
	if ( rand() % 4 < 2 ) {
		self.backgroundColor = [UIColor blackColor];
	} else {
		self.backgroundColor = [UIColor grayColor];	
	}*/
	
	//venueInformation.text = venue.name;
	[venueInformation setTitle:venue.name forState:UIControlStateNormal];
	
	//float ratio = (float)venue.numGuysHere / (float)venue.numGirlsHere;
	
	//subLabel.text = [NSString stringWithFormat:@"%i ppl here / Sausage Ratio: %1.1f:1 / %3.1f miles" , venue.numPeopleHere ,  ratio , venue.distanceFromMe ];
	
	if ( venue.distanceFromMe > 0.09 ) {
		subLabel.text = [NSString stringWithFormat:@"%i Girls, %i Dudes   %3.1f miles" , venue.numGirlsHere, venue.numGuysHere , venue.distanceFromMe ];
	} else {
		int feet = (venue.distanceFromMe*5280.0);
		feet = feet - (feet % 100);
		subLabel.text = [NSString stringWithFormat:@"%i Girls, %i Dudes   %i feet" , venue.numGirlsHere, venue.numGuysHere , feet ];
	}
	
	

	GenderPreference pref = [Model instance].genderPreference;
	
	for (FSUser * user in venue.peopleHere) {
		
		int col = photoIndex % 2;
		int row = photoIndex / 2;
		
		if ( pref == GENDER_PREFERENCE_FEMALES && user.itsaLady && user.hasPhoto ) {
		//if ( user.itsaLady && user.hasPhoto  ) {
			
			FSUserButton * userButton = [[FSUserButton alloc] initWithFrame:CGRectMake(4 + col*154, 64+row*154, 150, 150)];
			userButton.user = user;
			
			UITapGestureRecognizer* t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userClicked:)];
			[userButton addGestureRecognizer:t];
			[self addSubview:userButton];
			[userButton release];
			
			photoIndex++;
			
		} else if ( pref == GENDER_PREFERENCE_MALES && !user.itsaLady && user.hasPhoto ) {
			
			FSUserButton * userButton = [[FSUserButton alloc] initWithFrame:CGRectMake(4 + col*154, 64+row*154, 150, 150)];
			userButton.user = user;
			
			UITapGestureRecognizer* t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userClicked:)];
			[userButton addGestureRecognizer:t];
			[self addSubview:userButton];
			[userButton release];
			
			photoIndex++;
			
		} else if ( pref == GENDER_PREFERENCE_ALL  && user.hasPhoto ) {
			
			FSUserButton * userButton = [[FSUserButton alloc] initWithFrame:CGRectMake(4 + col*154, 64+row*154, 150, 150)];
			userButton.user = user;
			
			UITapGestureRecognizer* t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userClicked:)];
			[userButton addGestureRecognizer:t];
			[self addSubview:userButton];
			[userButton release];
			
			photoIndex++;
			
		}
		
		
	}
	
	[self layoutSubviews];
	
	
	
}

-(void) venueClicked {
	
	NSLog(@"venue clicked");
	
	if ( delegate ) {
		[delegate venueViewDidClickVenueTitle:self];
	}
	
	
}

-(void) userClicked:(id) sender {
	
	UITapGestureRecognizer * t = (UITapGestureRecognizer*)sender;
	FSUserButton * userButton = (FSUserButton*)t.view;
	//FSUserButton * userButton = (FSUserButton*)sender;
	FSUser * user = userButton.user;
	
	NSLog(@"User clicked: %@" , user.firstName );
	
	if ( delegate ) {
		[delegate venueView:self clickedUser:user];
	}
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	
	[venueInformation removeFromSuperview];
	[venueInformation release];
	venueInformation = nil;
	
	[bgImgView removeFromSuperview];
	[bgImgView release];
	bgImgView = nil;
	
	[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	//NSLog(@"Dealloc venue View");
	
    [super dealloc];
}


@end
