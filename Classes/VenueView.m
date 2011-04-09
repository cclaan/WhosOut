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
#import "UIColor+extensions.h"

@implementation VenueView

@synthesize venue, delegate;
@synthesize isFullPageVenue, venuePopulated;

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
	//tableview-disabled-cell-bg 
	bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview-cell-bg.png"]];
	[self addSubview:bgImgView];

	
	
	venueInformation = [[UILabel alloc] init];
	venueInformation.font = [UIFont boldSystemFontOfSize:22];
	venueInformation.backgroundColor = [UIColor clearColor];
	venueInformation.textColor = [UIColor colorWithRGBHex:0xc4d9eb];
	venueInformation.userInteractionEnabled = NO;
	venueInformation.shadowColor = [UIColor colorWithRGBHex:0x18222e];
	venueInformation.shadowOffset = CGSizeMake(0, -1);
	venueInformation.userInteractionEnabled = YES;
	
	//venueInformation.textColor = [UIColor whiteColor];
	//venueInformation.textAlignment = UITextAlignmentLeft;
	[self addSubview:venueInformation];
	
	
	/*
	venueInformation = [[UILabel alloc] init];
	venueInformation.font = [UIFont boldSystemFontOfSize:22];
	venueInformation.backgroundColor = [UIColor clearColor];
	venueInformation.textColor = [UIColor whiteColor];
	venueInformation.textAlignment = UITextAlignmentLeft;
	[self addSubview:venueInformation];
	*/
	
	subLabel = [[UILabel alloc] init];
	subLabel.font = [UIFont boldSystemFontOfSize:12];
	subLabel.backgroundColor = [UIColor clearColor];
	subLabel.userInteractionEnabled = NO;
	subLabel.textColor = [UIColor colorWithRGBHex:0x79a5c9];
	subLabel.shadowColor = [UIColor colorWithRGBHex:0x18222e];
	subLabel.shadowOffset = CGSizeMake(0, -1);
	subLabel.textAlignment = UITextAlignmentLeft;
	
	[self addSubview:subLabel];
	
	disclosureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablecell-disclosure.png"]];
	[self addSubview:disclosureImageView];
	
	labelToucher = [[SimpleTouchView alloc] initWithTarget:self action:@selector(handleTouch:)];
	labelToucher.frame = venueInformation.frame;
	labelToucher.layer.cornerRadius = 10;
	labelToucher.backgroundColor = [UIColor clearColor];
	[self addSubview:labelToucher];
	
	//[venueInformation addTarget:self action:@selector(venueClicked) forControlEvents:UIControlEventTouchUpInside];
	// dont seem to work on labels ???
	UITapGestureRecognizer* t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(venueClicked:)];
	t.cancelsTouchesInView = NO;
	[labelToucher addGestureRecognizer:t];
	
}

-(void) handleTouch:(SimpleTouchView*) t {
	
	if ( t.state == SIMPLE_TOUCH_STATE_BEGAN ) {
		venueInformation.alpha = 0.5;
		labelToucher.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
	} else if ( t.state == SIMPLE_TOUCH_STATE_ENDED || t.state == SIMPLE_TOUCH_STATE_CANCELLED ) {
		venueInformation.alpha = 1.0;
		labelToucher.backgroundColor = [UIColor clearColor];
	}
	
}

-(void) selfTapped:(UIGestureRecognizer*)g {
	
	if ( g.state == UIGestureRecognizerStateBegan ) {
		self.alpha = 0.5;
	} else if ( g.state == UIGestureRecognizerStateEnded ) {
		self.alpha = 1.0;
	}
	
}


-(void) setIsFullPageVenue:(BOOL)val {
	
	if ( val ) {
		
		bgImgView.hidden = YES;
		disclosureImageView.hidden = YES;
		
	} else {
		
		bgImgView.hidden = NO;
		disclosureImageView.hidden = NO;
		
	}
	
}	

-(void) layoutSubviews {
	
	venueInformation.frame = CGRectMake(14, 4, self.frame.size.width - 38 , 40);
	labelToucher.frame = CGRectMake(6, 8, self.frame.size.width - 12 , 52);
	disclosureImageView.frame = CGRectMake(self.frame.size.width - 16 - 12, 16, 16, 16);
	
	subLabel.frame = CGRectMake(14, 36, self.frame.size.width - 18 , 25);
	
	CGRect fr = bgImgView.frame;
	fr.origin.y = -6;
	//fr.
	//bgImgView.frame = CGRectMake(0, -6, self.frame.size.width , 150);
	bgImgView.frame = fr;
	
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
	
	if ( venue.hasRetrievedPeopleHere ) {
		venueInformation.text = venue.name;
	} else {
		venueInformation.text = @"Loading...";
	}
	
	//[venueInformation setTitle:venue.name forState:UIControlStateNormal];
	
	//float ratio = (float)venue.numGuysHere / (float)venue.numGirlsHere;
	
	//subLabel.text = [NSString stringWithFormat:@"%i ppl here / Sausage Ratio: %1.1f:1 / %3.1f miles" , venue.numPeopleHere ,  ratio , venue.distanceFromMe ];
	
	if ( venue.distanceFromMe > 0.09 ) {
		subLabel.text = [NSString stringWithFormat:@"%i GIRL%@, %i GUY%@   %3.1f MILES" , venue.numGirlsHere, (venue.numGirlsHere==1?@"":@"S"),  venue.numGuysHere, (venue.numGuysHere==1?@"":@"S") , venue.distanceFromMe ];
	} else {
		int feet = (venue.distanceFromMe*5280.0);
		feet = feet - (feet % 100);
		subLabel.text = [NSString stringWithFormat:@"%i GIRL%@, %i GUY%@   %i FEET" , venue.numGirlsHere, (venue.numGirlsHere==1?@"":@"S"),  venue.numGuysHere, (venue.numGuysHere==1?@"":@"S") , feet ];
	}
	
	
	NSArray * arr = [self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self isKindOfClass: %@)", [FSUserButton class]]];
	[arr makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	
	GenderPreference pref = [Model instance].genderPreference;
	photoIndex = 0;
	
	for (FSUser * user in venue.peopleHere) {
		
		int col = photoIndex % 2;
		int row = photoIndex / 2;
		
		//if ( pref == GENDER_PREFERENCE_FEMALES && user.itsaLady && user.hasPhoto ) {
		if ( ( (pref == GENDER_PREFERENCE_FEMALES && user.itsaLady) || ( pref == GENDER_PREFERENCE_MALES && !user.itsaLady) || (pref == GENDER_PREFERENCE_ALL) ) && user.hasPhoto ) {
			
			//FSUserButton * userButton = [[FSUserButton alloc] initWithFrame:CGRectMake(4 + col*154, 64+row*154, 150, 150)];
			FSUserButton * userButton = [[FSUserButton alloc] initWithFrame:CGRectMake(18 + col*150, 64+row*150, 148, 148)];
			userButton.user = user;
			
			UITapGestureRecognizer* t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userClicked:)];
			[userButton addGestureRecognizer:t];
			[self addSubview:userButton];
			[userButton release];
			
			photoIndex++;
			
		} /*else if ( pref == GENDER_PREFERENCE_MALES && !user.itsaLady && user.hasPhoto ) {
			
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
			
		}*/
		
		
	}
	
	if ( photoIndex == 0 ) {
		venueInformation.alpha = 0.4;
		subLabel.alpha = 0.4;
		disclosureImageView.alpha = 0.4;
		bgImgView.image = [UIImage imageNamed:@"tableview-disabled-cell-bg.png"];
	} else {
		venueInformation.alpha = 1.0;
		subLabel.alpha = 1.0;
		disclosureImageView.alpha = 1.0;
		bgImgView.image = [UIImage imageNamed:@"tableview-cell-bg.png"];
	}
	
	[self layoutSubviews];
	
	
	
}

//-(void) venueClicked:(UITapGestureRecognizer*)t {
-(void) venueClicked:(UITapGestureRecognizer*)t {
	
	//NSLog(@"venue clicked");
	
	if ( t.state == UIGestureRecognizerStateEnded ) {
		
		//labelToucher.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
		//[labelToucher performSelector:@selector(setBackgroundColor:) withObject:[UIColor clearColor] afterDelay:1.0];
		
		if ( delegate ) {
			[delegate venueViewDidClickVenueTitle:self];
		}
	
	}
	
}

-(void) userClicked:(id) sender {
	
	UITapGestureRecognizer * t = (UITapGestureRecognizer*)sender;
	FSUserButton * userButton = (FSUserButton*)t.view;
	//FSUserButton * userButton = (FSUserButton*)sender;
	FSUser * user = userButton.user;
	
	//NSLog(@"User clicked: %@" , user.firstName );
	
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
