//
//  UIScrollViewPullRefresh.h
//  MoreSquare
//
//  Created by Chris Laan on 4/4/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshManager.h"
#import "PullToRefreshHeaderView.h"


@interface UIScrollViewPullRefresh : UIScrollView {
	
	PullToRefreshManager * pullToRefresh;
	
}

@property (nonatomic, assign) id <PullToRefreshDelegate> pullRefreshDelegate;
@property BOOL isLoading;

-(void) stopLoading;


@end
