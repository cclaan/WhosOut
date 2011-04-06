//
//  FSVenueMapAnnotationView.m
//  MoreSquare
//
//  Created by Chris Laan on 4/1/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "FSVenueMapAnnotationView.h"
#import "VenueAnnotation.h"

#import "Model.h"


@implementation FSVenueMapAnnotationView


@synthesize hotnessLevel, numPeople;


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {

	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self != nil) {
		
		//[self setupUi];
		self.frame = CGRectMake(0, 0, 40, 60);
		//self.backgroundColor = [UIColor greenColor];
	}
	return self;
}


-(void) setAnnotation:(id <MKAnnotation>)anno {
	
	[super setAnnotation:anno];
	
	if ( !hasSetupUi ) {
			
		[self setupUi];
		
	}
	
	
	hotnessLevel = 0; // 0 - 3 
	numPeople = 0;
	GenderPreference g = [Model instance].genderPreference;
	
	VenueAnnotation * venAnno = (VenueAnnotation*)anno;
	
	if ( g == GENDER_PREFERENCE_ALL ) {
		numPeople = venAnno.venue.numPeopleHere;
	} else if ( g == GENDER_PREFERENCE_MALES ) {
		numPeople = venAnno.venue.numGuysHere;
	} else if ( g == GENDER_PREFERENCE_FEMALES ) {
		numPeople = venAnno.venue.numGirlsHere;
	}
	
	if ( numPeople < 2 ) {
		hotnessLevel = 0;
	} else if ( numPeople < 5 ) {
		hotnessLevel = 1;
	} else if ( numPeople < 10 ) {
		hotnessLevel = 2;
	} else {
		hotnessLevel = 3;
	}
	
	//VenueAnnotation * venAnno = (VenueAnnotation*)anno;
	
	numPeopleLabel.text = [NSString stringWithFormat:@"%i" , numPeople ];
	
	UIImage * pinImage = nil;
	
	switch (hotnessLevel) {
		case 0:
			pinImage = [UIImage imageNamed:@"map-pin-low.png"];
			break;
		case 1:
			pinImage = [UIImage imageNamed:@"map-pin-medium.png"];
			break;
		case 2:
			pinImage = [UIImage imageNamed:@"map-pin-medium-high.png"];
			break;
		case 3:
			pinImage = [UIImage imageNamed:@"map-pin-high.png"];
			break;
	}
	
	holderView.frame = CGRectMake(0, -10 -1, pinImage.size.width, pinImage.size.height);
	imgView.frame = holderView.bounds;
	imgView.image = pinImage;
	
	
}	

-(void) refreshData {
	
}

-(void) setNumPeople:(int)n {
	numPeople = n;
	numPeopleLabel.text = [NSString stringWithFormat:@"%i" , numPeople ];
}

/*
-(void) setHotnessLevel:(int)h {
	
	hotnessLevel = h;
	UIImage * pinImage = nil;
	
	switch (hotnessLevel) {
		case 0:
			pinImage = [UIImage imageNamed:@"map-pin-low.png"];
			break;
		case 1:
			pinImage = [UIImage imageNamed:@"map-pin-medium.png"];
			break;
		case 2:
			pinImage = [UIImage imageNamed:@"map-pin-medium-high.png"];
			break;
		case 3:
			pinImage = [UIImage imageNamed:@"map-pin-high.png"];
			break;
	}
	
	holderView.frame = CGRectMake(0, 18, pinImage.size.width, pinImage.size.height)
	imgView.image = pinImage;
	
}
*/

-(void) setupUi {
	
	hasSetupUi = YES;
	
	self.canShowCallout = YES;

	
	numPeopleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5 -1, 19, 24)];
	numPeopleLabel.font = [UIFont boldSystemFontOfSize:19.];
	numPeopleLabel.adjustsFontSizeToFitWidth = YES;
	numPeopleLabel.minimumFontSize = 15.;
	numPeopleLabel.backgroundColor = [UIColor clearColor];
	numPeopleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.2];
	numPeopleLabel.shadowOffset = CGSizeMake(0, -1);
	numPeopleLabel.textAlignment = UITextAlignmentCenter;
	numPeopleLabel.textColor = [UIColor whiteColor];
	
	//numPeopleLabel.text = [NSString stringWithFormat:@"%i" , numPeople];
	
	self.opaque = NO;
	
	//holderView = [[UIView alloc] initWithFrame:CGRectMake(0, 18, pinImage.size.width, pinImage.size.height)];
	holderView = [[UIView alloc] initWithFrame:CGRectZero];
	//imgView = [[UIImageView alloc] initWithImage:pinImage];
	imgView = [[UIImageView alloc] init];
	
	[holderView addSubview:imgView];
	[holderView addSubview:numPeopleLabel];
	[self addSubview:holderView];
	
	self.frame = CGRectMake(0, 0, 40, 60);
	holderView.frame = CGRectMake(0, -20, 40, 50);
	
	
	
	
}

-(void) dropIn {
	
	self.alpha = 0.0;
	//holderView.backgroundColor = [UIColor greenColor];
	[self.layer removeAllAnimations];
	
	//static float delay = 0.0;
	
	float randTime = (float)(rand() % 6) * 0.1;
	int randDist = 120;//10 + (rand() % 50);
	CGPoint p = holderView.center;
	p.y -= randDist;
	holderView.center = p;
	p.y += randDist;
	
	[UIView beginAnimations:@"fadeIn" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelay:randTime];
	self.alpha = 1.0;
	holderView.center = p;
	[UIView commitAnimations];
	
	
}


	
	

@end
