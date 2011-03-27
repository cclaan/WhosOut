//
//  FSVenue.h
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSVenue : NSObject {
	
}


@property double lat;
@property double lng;
@property double distanceFromMe;

@property BOOL isLocalFavorite;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * venueId;
@property (nonatomic, retain) NSMutableArray * peopleHere;

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;

@property (nonatomic, retain) NSString * phone;

@property int numGirlsHereWithPhotos;
@property int numGuysHereWithPhotos;
@property int numPeopleHereWithPhotos;
@property int numGirlsHere;
@property int numGuysHere;
@property int numPeopleHere;

// storage for calculated height...
@property float contentHeightForCell;


-(void) markAsFavorite;
-(void) unFavorite;


+(FSVenue*) venueFromJson:(id)data;
//+(NSArray*) venuesArrayFromJson:(id)

+(NSMutableArray*) getLocalFavorites;


@end
