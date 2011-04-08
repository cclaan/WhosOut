//
//  SimpleTouchView.h
//  MoreSquare
//
//  Created by Chris Laan on 4/8/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum SimpleTouchState {
	SIMPLE_TOUCH_STATE_NONE,
	SIMPLE_TOUCH_STATE_BEGAN,
	SIMPLE_TOUCH_STATE_MOVED,
	SIMPLE_TOUCH_STATE_ENDED,
	SIMPLE_TOUCH_STATE_CANCELLED
} SimpleTouchState;

@interface SimpleTouchView : UIView {
	
}

@property (nonatomic, assign) id delegate;
@property SEL handleEvent;
@property SimpleTouchState state;


- (id) initWithTarget:(id)targ action:(SEL)sel;


@end
