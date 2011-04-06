//
//  PullToRefreshHeaderView.h
//  MoreSquare
//
//  Created by Chris Laan on 4/4/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PullToRefreshHeaderView : UIView {
	
	
	//UIView *refreshHeaderView;
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;

    
	/*NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
	*/
}


//@property (nonatomic, retain) UIView *refreshHeaderView;
@property (nonatomic, retain) UILabel *refreshLabel;
@property (nonatomic, retain) UIImageView *refreshArrow;
@property (nonatomic, retain) UIActivityIndicatorView *refreshSpinner;

/*@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;
*/


@end
