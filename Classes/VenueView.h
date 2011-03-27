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

@interface VenueView : UIView {
	
	NSMutableArray * images;
	
	UIButton * venueInformation;
	UILabel * subLabel;
	
	UIButton * venueButton;
	
	
	int photoIndex;
	
	UIImageView * bgImgView;
	
	
	
}


@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) FSVenue * venue;


@end
