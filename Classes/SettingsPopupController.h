//
//  SettingsPopupController.h
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsPopupController : UIViewController {
	
	IBOutlet UISlider * radiusSlider;
	IBOutlet UISegmentedControl * genderSegment;
	IBOutlet UINavigationBar * titleBar;
	
}

-(IBAction) genderPrefClicked;
-(IBAction) radiusChanged;
-(IBAction) closeClicked;

@end
