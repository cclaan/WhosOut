//
//  MoreSquareAppDelegate.h
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foursquare2.h"
#import "WhosOutConstants.h"

#import "AuthSplashViewController.h"

@interface MoreSquareAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    IBOutlet UINavigationController * randomNavigationController;
	UITabBarController * tabController;
	
	UIView * splashView;
	
	AuthSplashViewController * authController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UITabBarController * tabController;

@end

