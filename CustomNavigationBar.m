//
//  CustomNavigationBar.m
//  RealDJ
//
//  Created by Chris Laan on 11/15/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import "CustomNavigationBar.h"

//#import "ColorManager.h"
//#import "Model.h"
//#import "UIColor+extensions.h"


@interface CustomNavigationBar()

- (void) setupNavBar;

@end

@implementation CustomNavigationBar


- (void)dealloc
{
    [super dealloc];
}


- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super initWithCoder:coder])
	{
		[self setupNavBar];
	}
	return self;
	
	
}

- (id)initWithFrame: (CGRect)frame {
	
	if ( self = [super initWithFrame:frame] ) {
		
		//NSLog(@"Init with frame: %f , %f " , frame.size.height , frame.size.width );
		[self setupNavBar];
		
	}
	
	return self;
}


- (id)init {
	
	if ( self = [super init] ) {
		
		[self setupNavBar];
		
	}
	
	return self;
}

//do not comment out this method	
- (void)drawRect:(CGRect)rect {
	
	
	
	//	UIColor *color = [[[Model sharedModel] sharedColorManager] getColorByKey:@"column_1"];
	//	CGContextRef context = UIGraphicsGetCurrentContext();
	//	CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
	//	CGContextFillRect(context, rect);
	
	
	//	CGRect frame = CGRectMake(0, 0, 320, 44);
	//	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	//	[label setBackgroundColor:[UIColor clearColor]];
	//	label.font = [UIFont boldSystemFontOfSize: 20.0];
	//	//label.shadowColor = [UIColor colorWithWhite:0.0 alpha:1];
	//	label.textAlignment = UITextAlignmentCenter;
	//	label.textColor = [UIColor whiteColor];
	//	label.text = self.topItem.title;
	//	self.topItem.titleView = label;
	
	
}

-(void) pushViewToBack {
	
	//NSLog(@"PUSH TO BACK");
	
	[self insertSubview:imgView atIndex:0];
	//imgView.alpha= 0.1;
}

- (void) setupNavBar {
	
	//self.backgroundColor = [UIColor colorWithHexString:@"172322"];
	
	//[[[Model sharedModel] sharedColorManager] getColorByKey:@"column_1"];
	
	//self.tintColor = [[[Model sharedModel] sharedColorManager] getColorByKey:@"column_1"];
	
	//self.backgroundColor = [UIColor greenColor];
	//self.tintColor = [UIColor clearColor];
	
	self.tintColor = [UIColor colorWithWhite:0.1 alpha:1.0];
	self.clipsToBounds = NO;
	imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom-navbar-bg.png"]];
	//[self addSubview:imgView];
	[self insertSubview:imgView atIndex:0];
	//[self.layer insertSublayer:imgView.layer atIndex:0];
	
	//--[self setDelegate:self];
	//[self performSelector:@selector(setSize) withObject:nil afterDelay:0.1];
	
}	


- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	int ind = [[self subviews] indexOfObject:imgView];
	
	if ( ind != 0 ) {
		[self sendSubviewToBack:imgView];
	}
}

/*
-(void) setNeedsLayout {
	
	//NSLog(@"Set needs layout");
	
}


- (void)layoutSubviews {
	
	if ( self.bounds.size.height != 44.0 ) {
		
		NSLog(@"Setting bounds");
		self.bounds = CGRectMake(0.0, 0.0, 480, 44.0);
		self.center = CGPointMake(480 / 2.0, 22.0);
		NSLog(@"Set bounds");	
		
		
		
	}
	
	
	
	[super layoutSubviews];
	
	NSLog(@"LAYOUT SUBVIEWS");
	
	//TODO: this is hack - if we want to redraw title
	//[self setNeedsDisplay];
	
}
*/

/*
-(void) setSize {
	
	NSLog(@"Setting bounds");
	//self.bounds = CGRectMake(0.0, 0.0, 480, 44.0);
	//self.center = CGPointMake(480 / 2.0, 22.0);
	NSLog(@"Set bounds");
	
	//[song_nav.navigationBar setNeedsDisplay];
	//[song_nav.navigationBar setNeedsLayout];
	
}

*/





/*
//this doesnt get called ?????
- (void)pushNavigationItem:(UINavigationItem *)item animated:(BOOL)animated {
	[super pushNavigationItem:item animated:animated];
	//[self sendSubviewToBack:backgroundView];
}

//this gets called
- (UINavigationItem *)popNavigationItemAnimated:(BOOL)animated {
	[super popNavigationItemAnimated:YES];
	return [self topItem];
}
*/


#pragma mark -
#pragma mark UINavigationDelegate Methods

//these dont get called
/*
 - (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
 NSString *title = [viewController title];
 UILabel *myTitleView = [[UILabel alloc] init];
 [myTitleView setFont:[UIFont boldSystemFontOfSize:18]];
 [myTitleView setTextColor:[UIColor redColor]];
 
 myTitleView.text = title;
 myTitleView.backgroundColor = [UIColor clearColor];
 [myTitleView sizeToFit];
 viewController.navigationItem.titleView = myTitleView;
 [myTitleView release];
 
 
 //viewController.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.33f green:0.99f blue:0.39 alpha:0.8];
 }
 
 - (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
 }
 
 */
@end