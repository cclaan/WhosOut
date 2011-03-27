
#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"

#import "Reachability.h"

#import "FSObjects.h"

#define DATABASE_FILE @"cacheditems.sqlite3"

#define kGenderChangedNotification @"GenderChangedNotification"

//@class Reachability;

typedef enum GenderPreference {
	
	GENDER_PREFERENCE_MALES,
	GENDER_PREFERENCE_FEMALES,
	GENDER_PREFERENCE_ALL
	
} GenderPreference;


@interface Model : NSObject {
	
	
	FMDatabase * db;

	NSMutableArray * favoriteVenues;
	NSMutableArray * favoriteUsers;
	
	NSComparisonResult (^_sortByClosestFirst)(id obj1, id obj2);
	
}

@property GenderPreference genderPreference;

@property BOOL hasInternet;

@property (nonatomic, retain) Reachability * hostReach;

@property (nonatomic, retain) NSMutableArray * favoriteVenues;
@property (nonatomic, retain) NSMutableArray * favoriteUsers;

@property (nonatomic,assign) FMDatabase * db;

+ (Model *) instance;

-(BOOL) isVenueLocalFavorite:(FSVenue*)ven;
-(void) removeFavoriteVenue:(FSVenue*)ven;
-(void) addFavoriteVenue:(FSVenue*)ven;
-(void) refreshLocalFavorites;

@end
