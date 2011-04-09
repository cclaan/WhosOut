
#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"

#import "Reachability.h"

#import "FSObjects.h"

#import "MBProgressHUD.h"

#import "GeoFunctions.h"
#import <CoreLocation/CoreLocation.h>

#define DATABASE_FILE @"cacheditems.sqlite3"

#define kGenderChangedNotification @"GenderChangedNotification"
#define kVenuesUpdatedNotification @"VenuesUpdatedNotification"
#define kVenuesUpdateFinishedNotification @"VenuesUpdateFinishedNotification"
#define kVenuesUpdateStartedNotification @"VenuesUpdateStartedNotification"

#define kFavoriteVenuesWereRemovedNotification @"kFavoriteVenuesWereRemovedNotification"
#define kFavoriteVenuesWereAddedNotification @"kFavoriteVenuesWereAddedNotification"


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
	
	
	BOOL isLoadingNearbyVenues;
	NSMutableArray * venuesArray;
	int numberOfVenuesToQuery;
	MBProgressHUD * hud;
	
	//CLLocationCoordinate2D * chosenLocation;
	int numberOfVenuesRetrieved;
	
	CLLocation * chosenLocation;
	
	
}

//@property CLLocationCoordinate2D  chosenLocation;
@property CLLocation * chosenLocation;

// new ones
@property BOOL isLoadingNearbyVenues;
@property (nonatomic, retain) NSMutableArray * venuesArray;

//@property BOOL favoritesAreOutOfDate;
//@property BOOL favoriteUsersAreOutOfDate;

@property GenderPreference genderPreference;

@property BOOL hasInternet;

@property int nearbySearchRange;


@property (nonatomic, retain) NSMutableSet * bannedCategories;

@property (nonatomic, assign) UIView * mainWindow;
@property (nonatomic, assign) UIView * viewForHUD;

@property (nonatomic, retain) Reachability * hostReach;

@property (nonatomic, retain) NSMutableArray * favoriteVenues;
@property (nonatomic, retain) NSMutableArray * favoriteUsers;

@property (nonatomic,assign) FMDatabase * db;

+ (Model *) instance;

-(BOOL) isVenueLocalFavorite:(FSVenue*)ven;
-(void) removeFavoriteVenue:(FSVenue*)ven;
-(void) addFavoriteVenue:(FSVenue*)ven;

-(void) refreshLocalFavoriteVenues;

-(void) startLocationAndFindNearbyVenues;

-(BOOL) isBannedCategory:(FSCategory*)cat;
-(BOOL) isBannedCategoryString:(NSString*)str;
-(void) removeBannedCategory:(FSCategory*)cat;
-(void) addBannedCategory:(FSCategory*)cat;
-(void) toggleBannedCategoryString:(NSString*)str;

@end
