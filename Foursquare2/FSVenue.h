//
//  FSVenue.h
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSCategory.h"



@interface FSVenue : NSObject {
	
}


@property int beenHereCount;

@property double lat;
@property double lng;
@property double distanceFromMe;

@property BOOL isLocalFavorite;

@property BOOL hasRetrievedPeopleHere;

// kind of a hack... 
@property BOOL animateFavoriteChangeInCell;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * venueId;

//@property (nonatomic, retain) NSString * categoryIconUrl;
//@property (nonatomic, retain) NSString * primaryCategory;
@property (nonatomic, retain) FSCategory * primaryCategory;
//@property (nonatomic, retain) FSCategory * parentCategory;

//@property VenueGenericCategory parentCategory;
//@property (nonatomic, retain) NSString * parentCategoryName;
@property (nonatomic, retain) NSMutableArray * categories;

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

// useful for updating another venue object of the same venue
-(void) copyDataFromAnotherVenue:(FSVenue*)ven;
-(BOOL) isSameAs:(FSVenue*)ven;

+(FSVenue*) venueFromJson:(id)data;
//+(NSArray*) venuesArrayFromJson:(id)

+(NSMutableArray*) getLocalFavorites;


@end
