//
//  CustomNavigationBar.h
//  RealDJ
//
//  Created by Chris Laan on 11/15/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomNavigationBar : UINavigationBar <UINavigationControllerDelegate> {

	UIImageView * imgView;
	
}

-(void) pushViewToBack;

@end
