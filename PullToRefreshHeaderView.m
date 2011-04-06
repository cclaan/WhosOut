//
//  PullToRefreshHeaderView.m
//  MoreSquare
//
//  Created by Chris Laan on 4/4/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "PullToRefreshHeaderView.h"


@implementation PullToRefreshHeaderView

@synthesize refreshLabel, refreshArrow, refreshSpinner;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		[self setupUi];
		
    }
    return self;
}

-(void) setupUi {
	
	/*
	textPull = [[NSString alloc] initWithString:@"Pull down to refresh..."];
	textRelease = [[NSString alloc] initWithString:@"Release to refresh..."];
	textLoading = [[NSString alloc] initWithString:@"Loading..."];
	 */
	
    self.backgroundColor = [UIColor clearColor];
	
	int hgt = self.frame.size.height;
	
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, hgt)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:18.0];
	refreshLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	refreshLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8];
	refreshLabel.shadowOffset = CGSizeMake(0, -1);
    refreshLabel.textAlignment = UITextAlignmentCenter;
	
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pull-to-refresh-arrow.png"]];
    refreshArrow.frame = CGRectMake((hgt - 32) / 2,
                                    (hgt - 44) / 2,
                                    32, 44);
	
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    refreshSpinner.frame = CGRectMake((hgt - 20) / 2, (hgt - 20) / 2, 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
	
    [self addSubview:refreshLabel];
    [self addSubview:refreshArrow];
    [self addSubview:refreshSpinner];
    
	
	
	
}	

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
