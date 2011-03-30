//
//  FSFavVenueCell.m
//  MoreSquare
//
//  Created by Chris Laan on 3/27/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "FSFavVenueCell.h"


@implementation FSFavVenueCell

@synthesize venue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		profileImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(8, 54/2 - 32/2 , 32, 32)];
		profileImageView.placeholderImage = [UIImage imageNamed:@"default-venue-image.png"];
		[self.contentView addSubview:profileImageView];
		
		self.contentView.backgroundColor = [UIColor whiteColor];
		self.backgroundColor = [UIColor whiteColor];
		
		nameLabel = [[UILabel alloc] init];
		nameLabel.font = [UIFont boldSystemFontOfSize:22];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textColor = [UIColor darkTextColor];
		
		nameLabel.textAlignment = UITextAlignmentLeft;
		[self.contentView addSubview:nameLabel];
		
		/*
		CGColorRef gradientColor1 = [UIColor colorWithWhite:0.4 alpha:1.0];
		CGColorRef gradientColor2 = [UIColor colorWithWhite:0.5 alpha:1.0];
		
		
		NSArray *colors = [[NSArray arrayWithObjects:(id)gradientColor2, (id)gradientColor1, nil] retain];	
		
		gradientLayer = [CAGradientLayer layer];
		//gradientLayer.cornerRadius = 0;
		[gradientLayer setColors:colors];
		//gradientLayer.locations = [NSArray arrayWithObjects:(id)[NSNumber numberWithFloat:0.5],(id)[NSNumber numberWithFloat:1.0], nil];
		[self.contentView.layer insertSublayer:gradientLayer atIndex:0];
		*/
		
    }
    return self;
}


-(void) setVenue:(FSVenue *)vnu {
	
	[venue release];
	venue = [vnu retain];
	
	if ( vnu.categoryIconUrl ) {
		profileImageView.imageURL = [NSURL URLWithString:vnu.categoryIconUrl];
	} else {
		profileImageView.imageURL = nil;
	}
	
	/*
	if ( usr.currentVenue != nil ) {
		nameLabel.text = [NSString stringWithFormat:@"%@ - At %@", user.firstName , usr.currentVenue.name ];
	} else {
		nameLabel.text = user.firstName;
	}
	*/
	
	nameLabel.text = venue.name;
	
	[self layoutSubviews];
	
}

-(void) layoutSubviews {
	
	[super layoutSubviews];
	
	//self.contentView.frame = self.bounds;
	nameLabel.frame = CGRectMake(58, self.frame.size.height/2-15, self.frame.size.width-100, 32);
	
	profileImageView.frame = CGRectMake(12, self.frame.size.height/2 - 32/2 , 32, 32);
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
