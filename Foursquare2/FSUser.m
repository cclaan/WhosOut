//
//  FSUser.m
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "FSUser.h"


@implementation FSUser

@synthesize gender, photoUrl, firstName, lastName, itsaLady, userId, hasPhoto;



+(FSUser*) userFromJson:(id) data {

	FSUser * user = [[[FSUser alloc] init] autorelease];
	
	user.firstName = [data objectForKey:@"firstName"];
	user.lastName = [data objectForKey:@"lastName"];
	user.userId = [data objectForKey:@"id"];
	user.gender = [data objectForKey:@"gender"];				
	user.photoUrl = [data objectForKey:@"photo"];
	
	if ([user.photoUrl rangeOfString:@"blank"].length == 0) {
		user.hasPhoto = YES;
	} else {
		user.hasPhoto = NO;
	}
	
	if ( [user.gender isEqualToString:@"female"] ) {
		
		user.itsaLady = YES;
		
	}
	
	return user;
	
	
}



@end
