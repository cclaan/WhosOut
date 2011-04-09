//
//  VenueView.h
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSObjects.h"

#import "FSUserButton.h"
#import "SimpleTouchView.h"

@interface VenueView : UIView {
	
	NSMutableArray * images;
	
	UILabel * venueInformation;
	UILabel * subLabel;
	
	SimpleTouchView * labelToucher;
	
	UIButton * venueButton;
	
	UIImageView * disclosureImageView;
	
	int photoIndex;
	
	UIImageView * bgImgView;
	
	
	
}
@property BOOL venuePopulated;
@property BOOL isFullPageVenue;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) FSVenue * venue;


@end
