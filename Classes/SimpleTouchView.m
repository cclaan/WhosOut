//
//  SimpleTouchView.m
//  MoreSquare
//
//  Created by Chris Laan on 4/8/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "SimpleTouchView.h"


@implementation SimpleTouchView

@synthesize delegate, handleEvent, state;



- (id) initWithTarget:(id)targ action:(SEL)sel
{
	self = [super init];
	if (self != nil) {
		
		state = SIMPLE_TOUCH_STATE_NONE;
		self.delegate = targ;
		self.handleEvent = sel;
		
	}
	return self;
}



- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		state = SIMPLE_TOUCH_STATE_NONE;
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {  
    
	[super touchesBegan:touches withEvent:event];  
	
	self.state = SIMPLE_TOUCH_STATE_BEGAN;
	[self.delegate performSelector:handleEvent withObject:self];
    //self.state = UIGestureRecognizerStateRecognized;
	//self.state = UIGestureRecognizerStateBegan;
	NSLog(@"started");
	
}  

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {  
    
	[super touchesEnded:touches withEvent:event];  
	
	self.state = SIMPLE_TOUCH_STATE_ENDED;
    //self.state = UIGestureRecognizerStateRecognized; 
	//self.state = UIGestureRecognizerStateEnded;
	[self.delegate performSelector:handleEvent withObject:self];
	
	NSLog(@"ended");
	
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[super touchesMoved:touches withEvent:event];
	self.state = SIMPLE_TOUCH_STATE_MOVED;
	[self.delegate performSelector:handleEvent withObject:self];
	
	NSLog(@"moved");
}


-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {  
    
	[super touchesCancelled:touches withEvent:event];  
	self.state = SIMPLE_TOUCH_STATE_CANCELLED;
	[self.delegate performSelector:handleEvent withObject:self];
    //self.state = UIGestureRecognizerStateRecognized; 
	//self.state = UIGestureRecognizerStateEnded;
	NSLog(@"cancelled");
	
	
} 



- (void)dealloc {
    [super dealloc];
}


@end
