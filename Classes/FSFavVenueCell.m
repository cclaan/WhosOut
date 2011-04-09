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
		nameLabel.font = [UIFont boldSystemFontOfSize:20];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.textColor = [UIColor darkTextColor];
		nameLabel.textAlignment = UITextAlignmentLeft;
		[self.contentView addSubview:nameLabel];
		
		
		subLabel = [[UILabel alloc] init];
		subLabel.font = [UIFont systemFontOfSize:16];
		subLabel.backgroundColor = [UIColor clearColor];
		subLabel.textColor = [UIColor lightGrayColor];
		subLabel.textAlignment = UITextAlignmentLeft;
		[self.contentView addSubview:subLabel];
		
		
		addButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-add-button.png"]];
		checkButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-check-button.png"]];
		
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
	
	/*
	if ( vnu.categoryIconUrl ) {
		profileImageView.imageURL = [NSURL URLWithString:vnu.categoryIconUrl];
	} else {
		profileImageView.imageURL = nil;
	}
	*/
	
	if ( vnu.primaryCategory.iconUrl ) {
		profileImageView.imageURL = [NSURL URLWithString:vnu.primaryCategory.iconUrl];
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
	
	if ( vnu.animateFavoriteChangeInCell ) {
		
		// reset this for next time..
		vnu.animateFavoriteChangeInCell = NO;
		
		if ( vnu.isLocalFavorite ) {
			
			NSLog(@"Show Check");
			//[addButton removeFromSuperview];
			checkButton.alpha = 0.0;
			[self addSubview:checkButton];
			checkButton.transform = CGAffineTransformMakeRotation(-(90.0 / 180.0) * M_PI );
			
			addButton.alpha = 1.0;
			[self addSubview:addButton];
			addButton.transform = CGAffineTransformIdentity;
			
			[UIView beginAnimations:@"addCheckBox" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:0.6];
			[UIView setAnimationDidStopSelector:@selector(addCheckAnimationDone)];
			checkButton.alpha = 1.0;
			addButton.alpha = 0.0;
			addButton.transform = CGAffineTransformMakeRotation((90.0 / 180.0) * M_PI );
			checkButton.transform = CGAffineTransformIdentity;
			
			[UIView commitAnimations];
			
			
		} else {
			
			
			addButton.alpha = 0.0;
			addButton.transform = CGAffineTransformMakeRotation((90.0 / 180.0) * M_PI );
			[self addSubview:addButton];
			
			checkButton.alpha = 1.0;
			checkButton.transform = CGAffineTransformIdentity;
			[self addSubview:checkButton];
			
			[UIView beginAnimations:@"removeCheckBox" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:0.6];
			[UIView setAnimationDidStopSelector:@selector(removeCheckAnimationDone)];
			checkButton.alpha = 0.0;
			addButton.alpha = 1.0;
			checkButton.transform = CGAffineTransformMakeRotation(-(90.0 / 180.0) * M_PI );
			addButton.transform = CGAffineTransformIdentity;
			[UIView commitAnimations];
			
		}
		
	} else {
		
		[checkButton.layer removeAllAnimations];
		[addButton.layer removeAllAnimations];
		checkButton.transform = CGAffineTransformIdentity;
		addButton.transform = CGAffineTransformIdentity;
		
		if ( vnu.isLocalFavorite ) {
			
			
			[addButton removeFromSuperview];
			[self addSubview:checkButton];
			checkButton.alpha = 1.0;
			
		} else {
			
			
			[checkButton removeFromSuperview];
			[self addSubview:addButton];
			addButton.alpha = 1.0;
			
		}

		
	}
	
		
	nameLabel.text = venue.name;
	
	
	if ( venue.distanceFromMe > 0.09 ) {
		subLabel.text = [NSString stringWithFormat:@"%3.1f miles" , venue.distanceFromMe ];
	} else {
		int feet = (venue.distanceFromMe*5280.0);
		feet = feet - (feet % 100);
		subLabel.text = [NSString stringWithFormat:@"%i feet" , feet ];
	}
	
	
	[self layoutSubviews];
	
}

-(void) addCheckAnimationDone {

	[addButton removeFromSuperview];
	
}

-(void) removeCheckAnimationDone {

	[checkButton removeFromSuperview];
	
}

-(void) layoutSubviews {
	
	[super layoutSubviews];
	
	//self.contentView.frame = self.bounds;
	nameLabel.frame = CGRectMake(58, self.frame.size.height/2-19, self.frame.size.width-100, 23);
	subLabel.frame = CGRectMake(58, self.frame.size.height/2+4, self.frame.size.width-100, 20);
	
	profileImageView.frame = CGRectMake(12, self.frame.size.height/2 - 32/2 , 32, 32);
	
	addButton.center = CGPointMake(self.frame.size.width - addButton.frame.size.width/2 - 6 , self.frame.size.height/2 );
	checkButton.center = CGPointMake(self.frame.size.width - checkButton.frame.size.width/2 - 6 , self.frame.size.height/2);
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
