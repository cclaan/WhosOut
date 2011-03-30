//
//  FSUserCell.m
//  MoreSquare
//
//  Created by Chris Laan on 3/27/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "FSUserCell.h"


@implementation FSUserCell

@synthesize user;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
		
		profileImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
		profileImageView.placeholderImage = [UIImage imageNamed:@"default-profile-image.png"];
		[self.contentView addSubview:profileImageView];
		
		self.contentView.backgroundColor = [UIColor darkGrayColor];
		self.backgroundColor = [UIColor darkGrayColor];
		
		nameLabel = [[UILabel alloc] init];
		nameLabel.font = [UIFont boldSystemFontOfSize:22];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textColor = [UIColor whiteColor];
		
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


-(void) setUser:(FSUser *)usr {
	
	[user release];
	user = [usr retain];
	
	profileImageView.imageURL = [NSURL URLWithString:user.photoUrl];
	
	if ( usr.currentVenue != nil ) {
		nameLabel.text = [NSString stringWithFormat:@"%@ - At %@", user.firstName , usr.currentVenue.name ];
	} else {
		nameLabel.text = user.firstName;
	}
	
	
	[self layoutSubviews];
	
}

-(void) layoutSubviews {
	
	[super layoutSubviews];
	
	//self.contentView.frame = self.bounds;
	nameLabel.frame = CGRectMake(78, self.frame.size.height/2-15, self.frame.size.width-100, 32);
	
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
