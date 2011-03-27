//
//  FSVenue.m
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "FSVenue.h"
#import "FSUser.h"

#import "Model.h"


@implementation FSVenue

@synthesize name, venueId, peopleHere;
@synthesize contentHeightForCell, numPeopleHere, numGirlsHere, numGuysHere, numGirlsHereWithPhotos, numGuysHereWithPhotos, numPeopleHereWithPhotos, address, state , city;
@synthesize phone , isLocalFavorite;

@synthesize distanceFromMe, lat, lng;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		
		//contentHeightForCell = 140;
		
	}
	return self;
}


-(void) insertToDb {
	
	FMDatabase * db = [Model instance].db;
	[db executeUpdate:@"INSERT INTO favorite_venues(venue_id, is_favorite) VALUES(?,?);" , self.venueId , [NSNumber numberWithBool:self.isLocalFavorite] ];
		
	if ([db hadError]) {
		
		NSLog(@"Err inserting fav venue for favorite use count %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return NO;
		
	} 
	
	return YES;
	
}

-(void) markAsFavorite {
	
	self.isLocalFavorite = YES;
	
	if ( ![[Model instance] isVenueLocalFavorite:self] ) {
		[self insertToDb];
		[[Model instance] refreshLocalFavorites];
		return;
	}
	
	//-[[Model instance] addFavoriteVenue:self];
	
	FMDatabase * db = [Model instance].db;
	
	[db executeUpdate:@"UPDATE favorite_venues SET is_favorite = ? WHERE venue_id = ?;" , [NSNumber numberWithBool:self.isLocalFavorite], self.venueId ];
	
	if ([db hadError]) {
		
		NSLog(@"Err updating fav venue for favorite use count %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return NO;
		
	} 
	
	[[Model instance] refreshLocalFavorites];
	
	return YES;
	
	
}

-(void) unFavorite {
	
	self.isLocalFavorite = NO;
	
	//-[[Model instance] removeFavoriteVenue:self];
	
	FMDatabase * db = [Model instance].db;
	
	[db executeUpdate:@"UPDATE favorite_venues SET is_favorite = ? WHERE venue_id = ?;" , [NSNumber numberWithBool:self.isLocalFavorite], self.venueId ];
	
	if ([db hadError]) {
		
		NSLog(@"Err updating fav venue for favorite use count %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return NO;
		
	} 
	
	[[Model instance] refreshLocalFavorites];
	
	return YES;
	
	
}


+(NSMutableArray*) getLocalFavorites {
	
	FMDatabase * db = [Model instance].db;
	
	FMResultSet *rs = [db executeQuery:@"SELECT * FROM favorite_venues WHERE is_favorite = ?;" , [NSNumber numberWithBool:YES]];	
	
	NSMutableArray * arr = [[[NSMutableArray alloc] init] autorelease];
	
    while ([rs next]) {
		
		[arr addObject:[FSVenue venueFromResultSet:rs]];
		
    }
	
	[rs close]; 
	
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
	}
	
	
	
	return arr;
	
	
}

+(FSVenue*) venueFromResultSet:(FMResultSet*) rs {

	FSVenue * ven = [[[FSVenue alloc] init] autorelease];
	ven.venueId = [rs stringForColumn:@"venue_id"];
	ven.isLocalFavorite = [rs boolForColumn:@"is_favorite"];
	
	return ven;
	
	
}



+(FSVenue*) venueFromJson:(id)data {
	
	
	FSVenue * venue = [[[FSVenue alloc] init] autorelease];
	
	venue.name = [data objectForKey:@"name"];
	venue.venueId = [data objectForKey:@"id"];
	
	//NSLog(@"VENUE ------- \n %@ " , data );
	
	
	//venue.peopleHere = arr;
	/*
	 location =                 {
	 address = "35 S 2nd St";
	 city = Philadelphia;
	 crossStreet = "btw Chestnut & Market St";
	 lat = "39.9490833";
	 lng = "-75.1439159";
	 postalCode = 19106;
	 state = PA;
	 };
	*/
	id location = [data objectForKey:@"location"];
	
	venue.lat = [[location objectForKey:@"lat"] doubleValue];
	venue.lng = [[location objectForKey:@"lng"] doubleValue];
	
	venue.address = [location objectForKey:@"address"];
	venue.city = [location objectForKey:@"city"];
	venue.state = [location objectForKey:@"state"];
	
	
	id contact = [data objectForKey:@"contact"];
	
	if ( contact != nil ) {
		
		venue.phone = [contact objectForKey:@"phone"];
		
	}
	
	venue.isLocalFavorite = [[Model instance] isVenueLocalFavorite:venue];
	
	NSArray * hereNow = [[data objectForKey:@"hereNow"] objectForKey:@"groups"];
	
	if ( hereNow && [hereNow count] > 0 ) {
	
		venue.peopleHere = [[NSMutableArray alloc] init];
		
		for (id group in hereNow) {
			
			int count = [[group objectForKey:@"count"] integerValue];
			
			//venue.contentHeightForCell = 44 + ceil( count / 2 ) * 154;
			
			if ( count ) {
				
				//NSLog(@"group: %@ " , group );
				
				//NSLog(@"YAY %i people at %@ " , count, vName );
				
				NSArray * people = [group objectForKey:@"items"];
				
				for (id person in people) {
					
					id user = [person objectForKey:@"user"];
					FSUser * fsUser = [FSUser userFromJson:user];
					[venue.peopleHere addObject:fsUser];
					
					if ( fsUser.hasPhoto ) {
						venue.numPeopleHereWithPhotos++;
						
						if ( fsUser.itsaLady ) { 
							venue.numGirlsHereWithPhotos++; 
						} else { 
							venue.numGuysHereWithPhotos++; 
						}
					}
					
					if ( fsUser.itsaLady ) {
						venue.numGirlsHere++;
					} else {
						venue.numGuysHere++;
					}
					
					venue.numPeopleHere++;
					
				}
				
			}
			
		}
		
		
	}
	
	return venue;
	
	
}

+(NSMutableArray*) venueArrayFromJson:(id) data {
	
	if ( ![data isKindOfClass:[NSArray class]] ) { return nil; }
	
	NSMutableArray * arr = [[[NSMutableArray alloc] init] autorelease];
	
	for (id obj in data) {
		[arr addObject:[FSVenue venueFromJson:obj]];
	}
	
	return arr;
	
}


@end
