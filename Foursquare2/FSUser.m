//
//  FSUser.m
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "FSUser.h"
#import "Model.h"


@implementation FSUser

@synthesize gender, photoUrl, firstName, lastName, itsaLady, userId, hasPhoto;
@synthesize isLocalFavorite, extraData, isMyFriend;
@synthesize currentVenue;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		extraData = &_tempExtraData;
		extraData->loading = NO;
		extraData->loaded = NO;
		//extraData->val = rand() % 20;
		//NSLog(@"inited val: %i " , extraData->val );
	}
	return self;
}


-(void) insertToDb {
	
	FMDatabase * db = [Model instance].db;
	[db executeUpdate:@"INSERT INTO favorite_users(user_id, is_favorite, photo_url, first_name, last_name, gender) VALUES(?,?,?,?,?,?);" , self.userId , [NSNumber numberWithBool:self.isLocalFavorite] , self.photoUrl , self.firstName, self.lastName , self.gender ];
	
	if ([db hadError]) {
		
		NSLog(@"Err inserting fav user for favorite use count %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return NO;
		
	} 
	
	return YES;
	
}

-(void) markAsFavorite {
	
	self.isLocalFavorite = YES;
	
	if ( ![[Model instance] isUserLocalFavorite:self] ) {
		[self insertToDb];
		[[Model instance] refreshLocalFavoriteUsers];
		return;
	}
	
	//-[[Model instance] addFavoriteVenue:self];
	
	FMDatabase * db = [Model instance].db;
	
	[db executeUpdate:@"UPDATE favorite_users SET is_favorite = ? WHERE user_id = ?;" , [NSNumber numberWithBool:self.isLocalFavorite], self.userId ];
	
	if ([db hadError]) {
		
		NSLog(@"Err updating fav user for favorite use count %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return NO;
		
	} 
	
	[[Model instance] refreshLocalFavoriteUsers];
	
	return YES;
	
	
}

-(void) unFavorite {
	
	self.isLocalFavorite = NO;
	
	//-[[Model instance] removeFavoriteVenue:self];
	
	FMDatabase * db = [Model instance].db;

	[db executeUpdate:@"DELETE FROM favorite_users WHERE user_id = ?;" , self.userId ];
	
	if ([db hadError]) {
		
		NSLog(@"Err updating fav user for favorite use count %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return NO;
		
	} 
	
	[[Model instance] refreshLocalFavoriteUsers];
	
	return YES;
	
	
}


+(NSMutableArray*) getLocalFavorites {
	
	FMDatabase * db = [Model instance].db;
	
	FMResultSet *rs = [db executeQuery:@"SELECT * FROM favorite_users WHERE is_favorite = ?;" , [NSNumber numberWithBool:YES]];	
	
	NSMutableArray * arr = [[[NSMutableArray alloc] init] autorelease];
	
    while ([rs next]) {
		
		[arr addObject:[FSUser userFromResultSet:rs]];
		
    }
	
	[rs close]; 
	
	if ([db hadError]) {
		NSLog(@"Err getting fav users %d: %@", [db lastErrorCode], [db lastErrorMessage]);
	}
	
	
	
	return arr;
	
	
}

+(FSUser*) userFromResultSet:(FMResultSet*) rs {
	
	FSUser * usr = [[[FSUser alloc] init] autorelease];
	
	usr.userId = [rs stringForColumn:@"user_id"];
	usr.isLocalFavorite = [rs boolForColumn:@"is_favorite"];
	usr.photoUrl = [rs stringForColumn:@"photo_url"];
	usr.firstName = [rs stringForColumn:@"first_name"];
	usr.lastName = [rs stringForColumn:@"last_name"];
	usr.gender = [rs stringForColumn:@"gender"];
	
	if ([usr.photoUrl rangeOfString:@"blank"].length == 0) {
		usr.hasPhoto = YES;
	} else {
		usr.hasPhoto = NO;
	}
	
	if ( [usr.gender isEqualToString:@"female"] ) {
		
		usr.itsaLady = YES;
		
	}
	
	return usr;
	
	
}



+(FSUser*) userFromJson:(id) data {

	FSUser * user = [[[FSUser alloc] init] autorelease];
	
	user.firstName = [data objectForKey:@"firstName"];
	user.lastName = [data objectForKey:@"lastName"];
	user.userId = [data objectForKey:@"id"];
	user.gender = [data objectForKey:@"gender"];				
	user.photoUrl = [data objectForKey:@"photo"];
	
	user.isLocalFavorite = [[Model instance] isUserLocalFavorite:user];
	
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
