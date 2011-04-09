//
//  SettingsPopupController.h
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface SettingsPopupController : UIViewController {
	
	IBOutlet UISlider * radiusSlider;
	IBOutlet UISegmentedControl * genderSegment;
	IBOutlet UINavigationBar * titleBar;
	
	GenderPreference startPref;
	int initialRange;
	
	
	IBOutlet UIButton * workButton;
	IBOutlet UIButton * schoolsButton;
	IBOutlet UIButton * shopsButton;
	IBOutlet UIButton * travelButton;
	IBOutlet UIButton * nightlifeButton;
	IBOutlet UIButton * outdoorsButton;
	IBOutlet UIButton * foodButton;
	IBOutlet UIButton * artsButton;
	
	IBOutlet UISlider * rangeSlider;
	IBOutlet UILabel * rangeLabel;
	
	int rangeMap[8];
	
}

-(IBAction) rangeChanged;

-(IBAction) genderPrefClicked;
-(IBAction) radiusChanged;
-(IBAction) closeClicked;

-(IBAction) logoutClicked;


// fix this crap...
-(IBAction) workButtonClicked;
-(IBAction) schoolsButtonClicked;
-(IBAction) shopsButtonClicked;
-(IBAction) travelButtonClicked;
-(IBAction) nightlifeButtonClicked;
-(IBAction) outdoorsButtonClicked;
-(IBAction) foodButtonClicked;
-(IBAction) artsButtonClicked;



@end
