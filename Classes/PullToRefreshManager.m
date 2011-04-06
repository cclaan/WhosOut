//
//  PullToRefreshManager.m
//  MoreSquare
// 
//  Most Code from Leah Culver's PullRefreshTableViewController
//  adapted to work with a UIScrollView and not require use of UITableViewController 
//
//  Created by Chris Laan on 4/4/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "PullToRefreshManager.h"
#import <QuartzCore/QuartzCore.h>

#define REFRESH_HEADER_HEIGHT 52.0f

@interface PullToRefreshManager()

- (void)addPullToRefreshHeader;
- (void)startLoading;
//- (void)refresh;

@end


@implementation PullToRefreshManager

@synthesize scrollView;
@synthesize delegate;
@synthesize isLoading;
@synthesize refreshHeaderView;

@synthesize textPull, textRelease, textLoading;//, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;
@synthesize showBottomHeader;

-(id) initWithScrollView:(UIScrollView*)_scrollView 
{
	self = [super init];
	if (self != nil) {
		
		textPull = [[NSString alloc] initWithString:@"Pull down to refresh..."];
        textRelease = [[NSString alloc] initWithString:@"Release to refresh..."];
        textLoading = [[NSString alloc] initWithString:@"Loading..."];
		
		self.scrollView = _scrollView;
		
	}
	return self;
}


-(void) setScrollView:(UIScrollView *)s {
	
	scrollView.delegate = nil;
	[scrollView release];
	
	scrollView = [s retain];
	scrollView.delegate = self;
	
	[self addPullToRefreshHeader];
	
	self.showBottomHeader = YES;
	
}


-(void) setShowBottomHeader:(BOOL)v {
	
	showBottomHeader = v;
	
	if ( showBottomHeader ) {
		
		if ( !refreshHeaderViewBottom ) {
			[self addPullToRefreshHeaderBottom];
		} else {
			 [self.scrollView addSubview:refreshHeaderViewBottom];
		}
		
		[self resetFrames];
		
	} else {
		
		[refreshHeaderViewBottom removeFromSuperview];
		[refreshHeaderViewBottom release];
		refreshHeaderViewBottom = nil;
		
	}
}

- (void)addPullToRefreshHeader {
	
	//NSLog(@"add header: %f " , scrollView.frame.size.width );
	
    refreshHeaderView = [[PullToRefreshHeaderView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    //refreshHeaderView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
	
    [self.scrollView addSubview:refreshHeaderView];
	
}

- (void)addPullToRefreshHeaderBottom {
	
	refreshHeaderViewBottom = [[PullToRefreshHeaderView alloc] initWithFrame:CGRectMake(0, scrollView.contentSize.height, 320, REFRESH_HEADER_HEIGHT)];
    //refreshHeaderViewBottom.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
	
    [self.scrollView addSubview:refreshHeaderViewBottom];
	
}



-(void) resetFrames {
	
	refreshHeaderViewBottom.frame = CGRectMake(0, scrollView.contentSize.height, 320, REFRESH_HEADER_HEIGHT);
	
	if ( scrollView.contentSize.height <= scrollView.frame.size.height ) {
		refreshHeaderViewBottom.hidden = YES;
	} else {
		refreshHeaderViewBottom.hidden = NO;
	}
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   
	
	//NSLog(@"Scroll: offset: %f  height: %f ", scrollView.contentOffset.y, scrollView.contentSize.height );
	
	if (isLoading) {
        
		/*
		// Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.scrollView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
		*/
		
		
    } else if (isDragging && scrollView.contentOffset.y < 0) {
		
		
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            refreshHeaderView.refreshLabel.text = self.textRelease;
            [refreshHeaderView.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            refreshHeaderView.refreshLabel.text = self.textPull;
            [refreshHeaderView.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
		
        [UIView commitAnimations];
		
		
    }  else if ( isDragging && showBottomHeader && (scrollView.contentOffset.y+scrollView.frame.size.height) > scrollView.contentSize.height ) {
		
		
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if ((scrollView.contentOffset.y+scrollView.frame.size.height) > scrollView.contentSize.height+REFRESH_HEADER_HEIGHT) {
            // User is scrolling above the header
            refreshHeaderViewBottom.refreshLabel.text = self.textRelease;
            [refreshHeaderViewBottom.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            refreshHeaderViewBottom.refreshLabel.text = self.textPull;
            [refreshHeaderViewBottom.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
		
        [UIView commitAnimations];
		
		
    }
	
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
	if (isLoading) return;
    
	isDragging = NO;
    
	if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    } else if (showBottomHeader && (scrollView.contentOffset.y+scrollView.frame.size.height) >= scrollView.contentSize.height + REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoadingBottom];
    }
}

- (void)startLoading {
	
	if ( delegate && [delegate respondsToSelector:@selector(scrollViewShouldRefresh:)] ) { 
		
		//[delegate performSelector:@selector(scrollViewShouldRefresh:) withObject:self.scrollView];
		BOOL should = [delegate scrollViewShouldRefresh:self.scrollView];
		
		if ( !should ) return;
		
		
	}
	
    isLoading = YES;
	
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
    refreshHeaderView.refreshLabel.text = self.textLoading;
    refreshHeaderView.refreshArrow.hidden = YES;
    [refreshHeaderView.refreshSpinner startAnimating];
    [UIView commitAnimations];

	
}

- (void)startLoadingBottom {
	
	if ( delegate && [delegate respondsToSelector:@selector(scrollViewShouldRefresh:)] ) { 
		
		//[delegate performSelector:@selector(scrollViewShouldRefresh:) withObject:self.scrollView];
		BOOL should = [delegate scrollViewShouldRefresh:self.scrollView];
		
		if ( !should ) return;
		
		
	}
	
    isLoading = YES;
	
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_HEADER_HEIGHT, 0);
    refreshHeaderViewBottom.refreshLabel.text = self.textLoading;
    refreshHeaderViewBottom.refreshArrow.hidden = YES;
    [refreshHeaderViewBottom.refreshSpinner startAnimating];
    [UIView commitAnimations];
	
	
}

- (void)stopLoading {
	
	if ( !isLoading ) return;
	
    isLoading = NO;
	
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.scrollView.contentInset = UIEdgeInsetsZero;
    [refreshHeaderView.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
	
	if ( showBottomHeader ) {
		[refreshHeaderViewBottom.refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
	}
    [UIView commitAnimations];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    refreshHeaderView.refreshLabel.text = self.textPull;
    refreshHeaderView.refreshArrow.hidden = NO;
    [refreshHeaderView.refreshSpinner stopAnimating];
	
	if ( showBottomHeader ) {
	// Reset the header
    refreshHeaderViewBottom.refreshLabel.text = self.textPull;
    refreshHeaderViewBottom.refreshArrow.hidden = NO;
    [refreshHeaderViewBottom.refreshSpinner stopAnimating];
	}
}


- (void)dealloc {
    
	[refreshHeaderView release];
	[refreshHeaderViewBottom release];
    //[refreshLabel release];
    //[refreshArrow release];
    //[refreshSpinner release];
    [textPull release];
    [textRelease release];
    [textLoading release];
    [super dealloc];
}



/*
-(void) setHeaderView:(UIView*)view {
	
}
*/

@end
