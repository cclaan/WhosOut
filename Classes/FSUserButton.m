//
//  FSUserButton.m
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "FSUserButton.h"


@implementation FSUserButton

@synthesize user;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

-(void) setUser:(FSUser *)u {
	
	self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
	
	[user release];
	user = [u retain];
	
	if ( !imgView ) {
		imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
	}
	
	[imgView setImageURL:[NSURL URLWithString:user.photoUrl ]];
	[self addSubview:imgView];	
	
	
	if ( !infoLabel ) {
		
		infoLabel = [[UILabel alloc] init];
		infoLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.55];
		infoLabel.font = [UIFont boldSystemFontOfSize:17.0];
		infoLabel.textAlignment = UITextAlignmentLeft;
		infoLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.75];
	} 
	
	infoLabel.frame = CGRectMake(0, self.frame.size.height-26, self.frame.size.width, 26);
	
	if ( user.lastName ) {
		infoLabel.text = [NSString stringWithFormat:@"  %@ %@" , user.firstName , user.lastName ];
	} else {
		infoLabel.text = [NSString stringWithFormat:@"  %@" , user.firstName ];
	}
	
	[self addSubview:infoLabel];
	
}
	
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	
	//NSLog(@"dealloc imgview");
	[imgView removeFromSuperview];
	[imgView release];
	imgView = nil;
	
    [super dealloc];
}


@end
