//
//  FSUserButton.m
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "FSUserButton.h"
#import "SimpleTouchRecognizer.h"


@implementation FSUserButton

@synthesize user;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

		// why dont gesture recognizers get a touchesCancelled Event
		
		//SimpleTouchRecognizer * tapper = [[SimpleTouchRecognizer alloc] initWithTarget:self action:@selector(selfTapped:)];
		//tapper.cancelsTouchesInView = NO;
		//tapper.delaysTouchesEnded = NO;
		//tapper.delaysTouchesBegan = YES;
		//[self addGestureRecognizer:tapper];
		
    }
    return self;
}

-(void) selfTapped:(SimpleTouchRecognizer*)g {
	
	if ( g.state == UIGestureRecognizerStateRecognized ) {
		self.alpha = 0.5;
	} 
	
}

-(void) selfTapEnded:(SimpleTouchRecognizer*)g {
	
	if ( g.state == UIGestureRecognizerStateRecognized ) {
		self.alpha = 0.5;
	} 
	
}

-(void) setUser:(FSUser *)u {
	
	self.backgroundColor = [UIColor clearColor];
	
	[user release];
	user = [u retain];
	
	if (!frameImageView) {
		frameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame-bg.png"]];
	}
	[self addSubview:frameImageView];
	
	if ( !imgView ) {
		imgView = [[EGOImageView alloc] initWithFrame:CGRectMake(12, 12, 110, 110)];
	}
	
	[imgView setImageURL:[NSURL URLWithString:user.photoUrl ]];
	[self addSubview:imgView];	
	
	
	
	
	if ( !infoLabel ) {
		
		infoLabel = [[UILabel alloc] init];
		infoLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.55];
		infoLabel.font = [UIFont boldSystemFontOfSize:17.0];
		infoLabel.textAlignment = UITextAlignmentLeft;
		infoLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
	} 
	
	infoLabel.frame = CGRectMake(12, 12+110-24, 110, 24);
	
	if ( user.lastName ) {
		infoLabel.text = [NSString stringWithFormat:@"  %@ %@" , user.firstName , user.lastName ];
	} else {
		infoLabel.text = [NSString stringWithFormat:@"  %@" , user.firstName ];
	}
	
	[self addSubview:infoLabel];
	
}
	
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {  
    
	[super touchesBegan:touches withEvent:event];  
    //self.state = UIGestureRecognizerStateRecognized;
	//self.state = UIGestureRecognizerStateBegan;
	//NSLog(@"started");
	self.alpha = 0.5;
	
}  

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {  
    
	[super touchesEnded:touches withEvent:event];  
    //self.state = UIGestureRecognizerStateRecognized; 
	//self.state = UIGestureRecognizerStateEnded;
	//NSLog(@"ended");
	self.alpha = 1.0;
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[super touchesCancelled:touches withEvent:event];
	
	//NSLog(@"moved");
}


-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {  
    
	[super touchesEnded:touches withEvent:event];  
    //self.state = UIGestureRecognizerStateRecognized; 
	//self.state = UIGestureRecognizerStateEnded;
	//NSLog(@"cancelled");
	self.alpha = 1.0;
	
} 


- (void)dealloc {
	
	//NSLog(@"dealloc imgview");
	[imgView removeFromSuperview];
	[imgView release];
	imgView = nil;
	
    [super dealloc];
}


@end
