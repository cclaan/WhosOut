//
//  SimpleTouchRecognizer.m
//  MoreSquare
//
//  Created by Chris Laan on 4/8/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "SimpleTouchRecognizer.h"


@implementation SimpleTouchRecognizer




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {  
    
	//[super touchesBegan:touches withEvent:event];  
    //self.state = UIGestureRecognizerStateRecognized;
	//self.state = UIGestureRecognizerStateBegan;
	NSLog(@"started");
	
}  

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {  
    
	//[super touchesEnded:touches withEvent:event];  
    //self.state = UIGestureRecognizerStateRecognized; 
	//self.state = UIGestureRecognizerStateEnded;
	NSLog(@"ended");
	
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//[super touchesMoved:touches withEvent:event];
	
	NSLog(@"moved");
}


-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {  
    
	//[super touchesCancelled:touches withEvent:event];  
    //self.state = UIGestureRecognizerStateRecognized; 
	//self.state = UIGestureRecognizerStateEnded;
	NSLog(@"cancelled");
	
	
} 

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	NSLog(@"gestureRecognizerShouldBegin");
	return YES;
}

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	NSLog(@"shouldRecognizeSimultaneouslyWithGestureRecognizer");
	return YES;	
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	
	NSLog(@"shouldReceiveTouch");
	return YES;
	
}



@end
