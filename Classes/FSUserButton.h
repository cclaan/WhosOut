//
//  FSUserButton.h
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSObjects.h"

#import "EGOImageView.h"
#import <QuartzCore/QuartzCore.h>


@interface FSUserButton : UIView {
	
	EGOImageView * imgView;
	
	UILabel * infoLabel;
	
	
}

@property (nonatomic, retain) FSUser * user;


@end
