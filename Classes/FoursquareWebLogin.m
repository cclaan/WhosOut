    //
//  ElanceWebLogin.m
//  elance
//
//  Created by Constantine Fry on 12/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "FoursquareWebLogin.h"
#import "Foursquare2.h"


@implementation FoursquareWebLogin
@synthesize delegate,selector,closeSelector;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (id) initWithUrl:(NSString*)url
{
	self = [super init];
	if (self != nil) {
		_url = url;
	}
	return self;
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	[super loadView];
	
	UIToolbar * toolBarBg = [[UIToolbar alloc] init];
	toolBarBg.tintColor = [UIColor lightGrayColor];
	toolBarBg.frame = CGRectMake(0, 0, 320, 44);
	[self.view addSubview:toolBarBg];
	
	webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
	[webView loadRequest:request];
	[webView setDelegate:self];
	
	[self.view addSubview:webView];
	[webView release];
	
	
	UIToolbar * toolBar = [[UIToolbar alloc] init];
	//toolBar.barStyle = UIBarStyleBlack;
	toolBar.translucent = YES;
	toolBar.tintColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.4 alpha:0.5];
	toolBar.frame = CGRectMake(0, 480-44-20, 320, 44);
	UIBarButtonItem * closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(closeClicked)];
	
	//UIBarButtonItem * whosOutImage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar-logo.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
	UIBarButtonItem * whosOutImage = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar-logo.png"]]];
	
	[toolBar setItems:[NSArray arrayWithObjects:closeButton,whosOutImage,nil]];
	[self.view addSubview:toolBar];
	[toolBar release];

}

-(void)cancel {
	
	[self hideLoading];
	//[self dismissModalViewControllerAnimated:YES];
	[delegate performSelector:closeSelector];
	
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
	NSString *url =[[request URL] absoluteString];
	if ([url rangeOfString:@"code="].length != 0) {
		
		NSHTTPCookie *cookie;
		NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		for (cookie in [storage cookies]) {
			if ([[cookie domain]isEqualToString:@"foursquare.com"]) {
				[storage deleteCookie:cookie];
			}
		}
		
		NSArray *arr = [url componentsSeparatedByString:@"="];
		[delegate performSelector:selector withObject:[arr objectAtIndex:1]];
		[self cancel];
	}else if ([url rangeOfString:@"error="].length != 0) {
		NSArray *arr = [url componentsSeparatedByString:@"="];
		[delegate performSelector:selector withObject:[arr objectAtIndex:1]];
		NSLog(@"Foursquare: %@",[arr objectAtIndex:1]);
	} 
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
	[self showLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
	[self hideLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	[self hideLoading];
}

-(void) closeClicked {
	
	[self hideLoading];
	//[self dismissModalViewControllerAnimated:YES];
	[delegate performSelector:closeSelector];
	
}

-(void) hideLoading {
	
	[hud hide:YES];
	
}

-(void) showLoading {
	
	if ( !hud ) {
		
		hud = [[MBProgressHUD alloc] initWithView:self.view];
		
	}
	
	[self.view addSubview:hud];
	hud.labelText = @"Loading...";
	[hud show:YES];
	
}	

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[hud release];
	hud = nil;
	
    [super dealloc];
}


@end
