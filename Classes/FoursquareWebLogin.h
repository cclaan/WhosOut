//
//  ElanceWebLogin.h
//  elance
//
//  Created by Constantine Fry on 12/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface FoursquareWebLogin : UIViewController <UIWebViewDelegate> {
	
	NSString *_url;
	UIWebView *webView;
	id delegate;
	SEL selector;
	MBProgressHUD * hud;
	
}

@property(nonatomic,assign) id delegate;
@property (nonatomic,assign)SEL selector;
@property (nonatomic,assign)SEL closeSelector;
- (id) initWithUrl:(NSString*)url;
@end
