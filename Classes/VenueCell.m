//
//  VenueCell.m
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "VenueCell.h"


@implementation VenueCell

@synthesize venue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
	
    // [super setSelected:selected animated:animated];
    // Configure the view for the selected state.
	
}


-(void) setVenue:(FSVenue *)v {
	
	[venue release];
	venue = [v retain];
	
	self.contentView.backgroundColor = [UIColor redColor];
	self.textLabel.text = v.name;
	
}

- (void)dealloc {
    [super dealloc];
}


@end
