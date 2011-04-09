//
//  PullToRefreshManager.h
//  MoreSquare
//
//  Created by Chris Laan on 4/4/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PullToRefreshHeaderView.h"

@protocol PullToRefreshDelegate
@required
-(BOOL) scrollViewShouldRefresh:(UIScrollView*)_scrollView;

@end


typedef enum PullState {
	PULL_STATE_NONE,
	PULL_STATE_UP,	
	PULL_STATE_DOWN,
} PullState;

@interface PullToRefreshManager : NSObject <UIScrollViewDelegate> {
	
	PullToRefreshHeaderView * refreshHeaderView;
	
	PullToRefreshHeaderView * refreshHeaderViewBottom;
	
	//UIView *refreshHeaderView;
    //UILabel *refreshLabel;
    //UIImageView *refreshArrow;
    //UIActivityIndicatorView *refreshSpinner;
	
    BOOL isDragging;
    BOOL isLoading;
    
	NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
	
	PullState pullState;
	PullState pullStateBottom;
	
}

@property (nonatomic, retain) NSDate * startPullUpDate;

@property BOOL showBottomHeader;

@property BOOL isLoading;

@property (nonatomic, retain) UIScrollView * scrollView;
@property (nonatomic, assign) id <PullToRefreshDelegate> delegate;

@property (nonatomic, retain) PullToRefreshHeaderView *refreshHeaderView;

/*@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;
 */
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;


- (void)stopLoading;

// when using the bottom header, reset the frame if the content size changes
-(void) resetFrames;

-(id) initWithScrollView:(UIScrollView*)_scrollView;

@end
