//
//  VenueCell.h
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSObjects.h"

@interface VenueCell : UITableViewCell {
	
	NSMutableArray * images;
	
}

@property (nonatomic, retain) FSVenue * venue;

@property float contentHeight;


@end
