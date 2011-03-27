//
//  UserDetailController.h
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSObjects.h"
#import "EGOImageView.h"

@interface UserDetailController : UIViewController {
	
	IBOutlet EGOImageView * userImageView;
	IBOutlet UILabel * userName;
	
	IBOutlet UIButton * favoriteUserButton;
	IBOutlet UIButton * buyDrinkButton;
	IBOutlet UIButton * userStatsButton;
	
}

- (id) initWithUser:(FSUser*)usr;

@property (nonatomic, retain) FSUser * user;

-(IBAction) favoriteUserClicked;
-(IBAction) buyDrinkClicked;

@end
