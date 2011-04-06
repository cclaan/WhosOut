//
//  UIScrollViewPullRefresh.m
//  MoreSquare
//
//  Created by Chris Laan on 4/4/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "UIScrollViewPullRefresh.h"

@interface UIScrollViewPullRefresh ()

-(void) initPullToRefresh;

@end


@implementation UIScrollViewPullRefresh

@synthesize pullRefreshDelegate, isLoading;

-(void) awakeFromNib {
	
	NSLog(@"awakeFromNib");
	[super awakeFromNib];
	
	[self initPullToRefresh];
	
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		NSLog(@"uiscroll INIT");
		
		[self initPullToRefresh];
		
	}
	return self;
}


- (id)initWithFrame:(CGRect)frame {
    NSLog(@"init With Frame");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		[self initPullToRefresh];
		
    }
    return self;
}

-(void) setContentSize:(CGSize) c {

	[super setContentSize:c];
	
	[pullToRefresh resetFrames];
	
}

-(void) initPullToRefresh {
	
	if ( !pullToRefresh ) {
		pullToRefresh = [[PullToRefreshManager alloc] initWithScrollView:self];
		//pullToRefresh.delegate = self;
	}
	
}

-(void) setPullRefreshDelegate:(id <PullToRefreshDelegate>) del {
	
	pullToRefresh.delegate = del;
	
}

-(BOOL) isLoading {
	return pullToRefresh.isLoading;
}

-(void) stopLoading {
	
	[pullToRefresh stopLoading];
	
}


/*
-(BOOL) scrollViewShouldRefresh:(UIScrollView*)_scrollView {
	
	//[self refreshClicked];
	[pullToRefresh performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
	
	return YES;
	
}
*/



- (void)dealloc {
    [super dealloc];
}


@end
