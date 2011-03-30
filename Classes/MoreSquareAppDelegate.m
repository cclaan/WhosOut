//
//  MoreSquareAppDelegate.m
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "MoreSquareAppDelegate.h"
#import "AroundMeViewController.h"
#import "FoursquareWebLogin.h"
#import "Model.h"




@implementation MoreSquareAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize tabController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	
	[[Model instance] setupModel]; 
	
	int lastTabIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kLastTabOpenIndex];
	tabController.delegate = self;
	[tabController setSelectedIndex:lastTabIndex];
	
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:tabController.view];
    [self.window makeKeyAndVisible];
	
	if ( [Foursquare2 isNeedToAuthorize]) {
		
		//[self performSelector:@selector(showAuthSplash) withObject:nil afterDelay:1.0];
		
		[self showFoursquareAuth];
		
	
	}
	
	[Model instance].mainWindow = window;
	[Model instance].viewForHUD = randomNavigationController.view;
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutEvent) name:kFSShouldLogoutNotification object:nil];
	
	
    return YES;
}

-(void) logoutEvent {
	
	//[Foursquare2 setBaseURL:nil];
	[Foursquare2 removeAccessToken];
	
	[self showAuthSplash];
	
}

-(void) showAuthSplash {
	
	
	if ( !splashView ) {
		
		splashView = [[UIView alloc] initWithFrame:tabController.view.frame];
		
		UIImageView * splashImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-auth-splash.png"]];
		[splashView addSubview:splashImage];
		[splashImage release];
		
		UIButton * authButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		authButton.frame = CGRectMake(40, 480/2-40, 320-80, 40);
		[authButton setTitle:@"Authorize" forState:UIControlStateNormal];
		[authButton addTarget:self action:@selector(showFoursquareAuth) forControlEvents:UIControlEventTouchUpInside];
		[splashView addSubview:authButton];
		
	}
	
	//[self.window insertSubview:splashView atIndex:0];
	//[tabController.view insertSubview:splashView aboveSubview:tabController.view];
	[tabController.view insertSubview:splashView atIndex:2];
	
}

-(void) hideAuthSplash {
	
	[splashView removeFromSuperview];
	[splashView release];
	splashView = nil;
	
}

-(void) showFoursquareAuth {
	
	[self authorizeWithViewController:tabController 
							 Callback:^(BOOL success,id result){
								 
								 if (success) {
									 
									 [self hideAuthSplash];
									 [tabController.selectedViewController viewWillAppear:YES];
									 
								 } else {
									 
									 [self showAuthSplash];
									 
								 }
								 
							 }];
	
	
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	
	int index = [tabBarController.viewControllers indexOfObject:viewController];
	
	[[NSUserDefaults standardUserDefaults] setInteger:index forKey:kLastTabOpenIndex];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	
}



#pragma mark -
#pragma mark Foursqaure Auth 

Foursquare2Callback authorizeCallbackDelegate;

-(void)authorizeWithViewController:(UIViewController*)controller
						  Callback:(Foursquare2Callback)callback{
	authorizeCallbackDelegate = [callback copy];
	NSString *url = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?display=touch&client_id=%@&response_type=code&redirect_uri=%@",OAUTH_KEY,REDIRECT_URL];
	FoursquareWebLogin *loginCon = [[FoursquareWebLogin alloc] initWithUrl:url];
	loginCon.delegate = self;
	loginCon.selector = @selector(setCode:);
	
	loginCon.closeSelector = @selector(closeAuthScreen);
	
	/*
	UINavigationController *navCon = [[UINavigationController alloc]initWithRootViewController:loginCon];
	
	UINavigationItem * closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeAuthController)];
	loginCon.navigationItem.rightBarButtonItem = closeButton;
	loginCon.navigationItem.title = @"Whos Out + Foursquare";
	navCon.navigationBar.tintColor = [UIColor greenColor];
	*/
	
	[controller presentModalViewController:loginCon animated:YES];
	//[navCon release];
	[loginCon release];	
	
	
	
}

-(void) closeAuthScreen {
	
	[tabController dismissModalViewControllerAnimated:YES];
	authorizeCallbackDelegate(NO,nil);
	
}

-(void)setCode:(NSString*)code{
	
	[Foursquare2 getAccessTokenForCode:code callback:^(BOOL success,id result){
		if (success) {
			[Foursquare2 setBaseURL:[NSURL URLWithString:@"https://api.foursquare.com/v2/"]];
			[Foursquare2 setAccessToken:[result objectForKey:@"access_token"]];
			authorizeCallbackDelegate(YES,result);
            [authorizeCallbackDelegate release];
		} else {
			authorizeCallbackDelegate(NO,nil);
		}
	}];
}

-(void) closeAuthController {
	
	[tabController dismissModalViewControllerAnimated:YES];
	
}




- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[tabController release];
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

