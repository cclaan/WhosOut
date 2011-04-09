//
//  FSFavVenueCell.h
//  MoreSquare
//
//  Created by Chris Laan on 3/27/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "FSObjects.h"
#import <QuartzCore/QuartzCore.h>

@interface FSFavVenueCell : UITableViewCell {
	
	EGOImageView * profileImageView;
	
	UILabel * nameLabel;
	UILabel * subLabel;
	
	CAGradientLayer * gradientLayer;
	
	UIImageView * addButton;
	UIImageView * checkButton;
	
	
	
}

@property (nonatomic, retain) FSVenue * venue;

@end
