
#import "Model.h"
#import "Locator.h"
#import "Foursquare2.h"

#import "WhosOutConstants.h"


static Model *instance = nil;

@interface Model (privates)

-(void) initDb;

-(void) createOrCopyDB;

-(void) openFMDB;

@end


#pragma mark -
@implementation Model


@synthesize  db , favoriteUsers , favoriteVenues;

@synthesize hostReach, hasInternet;

@synthesize genderPreference, nearbySearchRange;

@synthesize mainWindow, viewForHUD;

@synthesize venuesArray , isLoadingNearbyVenues;
//@synthesize favoritesAreOutOfDate, favoriteUsersAreOutOfDate;

@synthesize bannedCategories;

@synthesize chosenLocation;

#pragma mark -
#pragma mark setup

-(void) setupModel {
	
	[self createUserDirsIfNotThere];
	
	[self initDb];
	
	self.chosenLocation = nil;
	
	//--favoritesAreOutOfDate = YES;
	
	_sortByClosestFirst = ^ NSComparisonResult (id obj1, id obj2) {
		
		FSVenue * v1 = (FSVenue*)obj1;
		FSVenue * v2 = (FSVenue*)obj2;
		
		if( v1.distanceFromMe < v2.distanceFromMe )
			return NSOrderedAscending;
		else if( v1.distanceFromMe > v2.distanceFromMe )
			return NSOrderedDescending;
		else 
			return NSOrderedSame;
		
	};
	
	
	[self refreshCategoryPreferences];
		
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	hostReach = [[Reachability reachabilityWithHostName: @"www.google.com"] retain];
	BOOL success = [hostReach startNotifier];
	
	if (!success) {
		
		
	}
	
	
	[self updateReachability];	
	
	NSNumber * val = [[NSUserDefaults standardUserDefaults] valueForKey:kGenderPreferenceKey];
	
	if ( val == nil ) {
		val = [NSNumber numberWithInt:GENDER_PREFERENCE_FEMALES];
		self.genderPreference = [val intValue];
	} else {
		genderPreference = [val intValue];
	}
	
	
	val = [[NSUserDefaults standardUserDefaults] valueForKey:kNearbySearchRangePref];
	
	if ( val == nil ) {
		val = [NSNumber numberWithInt:5000];
		self.nearbySearchRange = [val intValue];
	} else {
		// no setter...
		nearbySearchRange = [val intValue];
	}
	
	
	
}

#pragma mark -
#pragma mark Location


#pragma mark -

-(void) startLocationAndFindNearbyVenues {
	
	//isLocating = YES;
	
	[self setLoading:YES withMessage:@"Locating..."];
	hud.mode = MBProgressHUDModeIndeterminate;
	
	
	if ( self.chosenLocation == nil ) {
	//if ( CLLocationCoordinate2DIsValid(self.chosenLocation) ) {
		
		[Locator instance].currentDesiredAccuracy = 1500;
		[Locator instance].location = nil;
		[[Locator instance] start];
		
		[self performSelector:@selector(locationLoop) withObject:nil afterDelay:0.9];
		
	} else {
		
		[self findPeople];
		
	}
}


-(void) locationLoop {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locationLoop) object:nil];
	
	if ( [Locator instance].hasReceivedLocation || [Locator instance].hasReceivedError ) {
		
		CLLocation * loc;
		
		if ( [Locator instance].hasReceivedError ) {
			
			//[self stopLoading];
			NSLog(@"had err!");
			//isLocating = NO;
			
			//ALERT
			UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We could not locate you. Being indoors can degrade location accuracy." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[al show];
			[al release];
			
			return;
			
		} else {
			
			//isLocating = NO;
			
			//[self stopLoading];
			
			[self findPeople];
			
		}
		
	} else {
		
		[self performSelector:@selector(locationLoop) withObject:nil afterDelay:0.5];
		
	}
	
	
}

#pragma mark -
#pragma mark Network Calls


-(void) stopLoading {
	
	isLoadingNearbyVenues = NO;
	
	if ( hud && [hud superview] ) {
		
		[hud hide:YES];
		
	}
	
}

-(void) setLoading:(BOOL)loading withMessage:(NSString*)msg {
	
	isLoadingNearbyVenues = loading;
	
	if ( loading ) {
		
		if ( !hud ) {
			
			hud = [[MBProgressHUD alloc] initWithView:self.viewForHUD];
			[self.mainWindow addSubview:hud];
			
		}
		
		hud.labelText = msg;    
		[hud show:YES];
		
		
	} else {
		
		if ( hud && [hud superview] ) {
			
			[hud hide:YES];
			
		}
	}
	
}

/*
-(CLLocationCoordinate2D*) chosenLocation {

	
}

-(void) setChosenLocation:(CLLocationCoordinate2D *)c {
	
	chosenLocation = c;
	
	[NSUserDefaults standardUserDefaults]
	
	
}
*/


-(void) delayedShowApiError {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showApiError) object:nil];
	[self performSelector:@selector(showApiError) withObject:nil afterDelay:1.4];
	
}


-(void) showApiError {
	
	UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"FourSqaure or the internet isn't behaving, you may have exceeded your FourSquare API limit. Please try again later!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[al show];
	[al release];
	
	//[self stopLoading];
	
}

/*
-(void) showNoVenues {

	UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"No Venues" message:@"No one is checked in around here, to manually set a location, tap and hold somewhere on the map." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[al show];
	[al release];
	[self stopLoading];
	
}

*/
 

-(void) findPeople {
	
	numberOfVenuesRetrieved = 0;
	
	//loc = [Locator instance].location;
	
	//NSLog(@"Got location: %@ " , [Locator instance].latString );
	
	//[Foursquare2 searchVenuesNearByLatitude:[Locator instance].latString longitude:[Locator instance].lonString accuracyLL:@"5000" altitude:nil accuracyAlt:nil query:@"" limit:@"200" intent:nil callback:^(BOOL success,id result){
	
	hud.labelText = @"Looking...";
	
	
	[self notifyVenuesUpdateStarted];
		
	[venuesArray removeAllObjects];
	[venuesArray release];
	venuesArray = nil;
	
	NSString * latString = nil;
	NSString * longString = nil;
	
	//if ( CLLocationCoordinate2DIsValid(self.chosenLocation) ) {
	if ( self.chosenLocation ) {
		
		latString = [NSString stringWithFormat:@"%f",self.chosenLocation.coordinate.latitude];
		longString = [NSString stringWithFormat:@"%f",self.chosenLocation.coordinate.longitude];
		
	} else {
		latString = [Locator instance].latString;
		longString = [Locator instance].lonString;
	}
	
	NSLog(@"looking near: %@ , %@ ",latString,longString);
	numberOfVenuesToQuery = 0;
	
	//100 - 5000 
	// 300
	// 500
	// 1000
	// 2000
	// 5000
	
	NSString * rangeString = [NSString stringWithFormat:@"%i" , self.nearbySearchRange ];
	
	[Foursquare2 getTrendingVenuesNearByLatitude:latString longitude:longString radius:rangeString limit:@"50" callback:^(BOOL success,id result){
		
		hud.mode = MBProgressHUDModeDeterminate;
		hud.progress = 0.0;
		
		if ( !success ) {
			
			[self performSelectorOnMainThread:@selector(delayedShowApiError) withObject:nil waitUntilDone:YES];			
			return;
		}
		
		NSLog(@"got stuff: %@ , %@ " , result , [result class]);
		//NSLog(@"got stuff");
			  
		NSArray * tempVenues = [[result objectForKey:@"response"] objectForKey:@"venues"];
		
		tempVenues = [FSVenue venueArrayFromJson:tempVenues];
		
		if ( [tempVenues count]==0 ) {
			
			//[self performSelectorOnMainThread:@selector(showNoVenues) withObject:nil waitUntilDone:YES];
			[self performSelectorOnMainThread:@selector(notifyVenuesUpdated) withObject:nil waitUntilDone:YES];			
			
			return;
		}
		
		
		venuesArray = [[NSMutableArray alloc] init];
		
		numberOfVenuesToQuery = [tempVenues count];
		//__block float numGot = 0;
		
		for (FSVenue * ven in tempVenues) {
			
			// - NSLog(@"Name: %@ , peeps here: %i  " , ven.name , ven.numPeopleHere );
			
			[Foursquare2 getDetailForVenue:ven.venueId callback:^(BOOL success, id result2){
				
				//NSLog(@"first venue");
				
				numberOfVenuesRetrieved ++;
				hud.progress = ((float)numberOfVenuesRetrieved / (float)numberOfVenuesToQuery);
				
				if ( !success ) {
					NSLog(@"nosucc, %@" , result2 );
					[self performSelectorOnMainThread:@selector(delayedShowApiError) withObject:nil waitUntilDone:YES];
					[self performSelectorOnMainThread:@selector(delayedNotify) withObject:nil waitUntilDone:NO];	
					return;
				}
				
				FSVenue * venue = [FSVenue venueFromJson:[[result2 objectForKey:@"response"] objectForKey:@"venue"]];
				[venuesArray addObject:venue];
				
				CLLocationCoordinate2D loc = [Locator instance].location.coordinate;
				
				double myLat = loc.latitude;
				double myLng = loc.longitude;
				
				//venue.distanceFromMe = sqrt( (venue.lat-myLat)*(venue.lat-myLat) + (venue.lng-myLng)*(venue.lng-myLng) );
				
				venue.distanceFromMe = geo_distance(venue.lat, venue.lng, myLat, myLng, 'M');
				
				
				//NSLog(@"venue: %@ , people there: %i , lat: %f , dist: %f " , venue.name , [venue.peopleHere count] , venue.lat , venue.distanceFromMe );
				
				//[self performSelectorOnMainThread:@selector(showUsersFromVenue:) withObject:venue waitUntilDone:NO];	
				
				//[self performSelectorOnMainThread:@selector(delayedReloadTable) withObject:nil waitUntilDone:NO];	
				
				[self performSelectorOnMainThread:@selector(delayedNotify) withObject:nil waitUntilDone:NO];	
				
				
			}];
			
			
		}
		
		
		
	}];
	
}

-(void) delayedNotify {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(notifyVenuesUpdated) object:nil];
	[self performSelector:@selector(notifyVenuesUpdated) withObject:nil afterDelay:0.85];
	
	
}

-(void) notifyVenuesUpdated {
	
	NSLog(@"notifyVenuesUpdated -- numberOfVenuesToQuery: %i , venuesArray count: %i " , numberOfVenuesToQuery , [venuesArray count] );
	
	[self sortVenuesByDistance];
	
	if ( numberOfVenuesRetrieved == numberOfVenuesToQuery ) {
		
		[self stopLoading];
		[[NSNotificationCenter defaultCenter] postNotificationName:kVenuesUpdateFinishedNotification object:nil];
		
	} else {
	
		[[NSNotificationCenter defaultCenter] postNotificationName:kVenuesUpdatedNotification object:nil];
	
	}
}

-(void) notifyVenuesUpdateStarted {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kVenuesUpdateStartedNotification object:nil];
	
}

-(void) sortVenuesByDistance {
	
	[venuesArray sortUsingComparator:_sortByClosestFirst];
	
	
}



#pragma mark -
#pragma mark User Defaults

-(void) setNearbySearchRange:(int) s {
	
	nearbySearchRange = s;
	
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:nearbySearchRange] forKey:kNearbySearchRangePref];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
}

-(void) setGenderPreference:(GenderPreference) g {
	
	genderPreference = g;
	
	//[[NSUserDefaults standardUserDefaults] setInteger:g forKey:kGenderPreferenceKey];
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:g] forKey:kGenderPreferenceKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	
}


#pragma mark -
#pragma mark Reachability


- (void) reachabilityChanged: (NSNotification* )note
{
	
	[self updateReachability];	
	
}

-(void) updateReachability {
	
	
	Reachability* curReach = hostReach;
	
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	
	BOOL connectionRequired= [curReach connectionRequired];
	
	switch (netStatus)
	{
		case NotReachable:
		{
			connectionRequired= NO;  
			hasInternet = NO;
			break;
		}
			
		case ReachableViaWWAN:
		{
			hasInternet= YES;
			break;
		}
		case ReachableViaWiFi:
		{
			hasInternet = YES;
			break;
		}
	}
	
	
	
}

#pragma mark -
#pragma mark inits

-(void) createUserDirsIfNotThere {
	
	// search documents DIR for recorded caf files....
	NSArray *filePaths = NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory, NSUserDomainMask , YES ); 
	NSString * docsDir = [filePaths objectAtIndex: 0];
	NSString * dbDir = [docsDir stringByAppendingString:@"/.db/"];
	

	BOOL isDir;
	
	if ( ![[NSFileManager defaultManager] fileExistsAtPath:dbDir isDirectory:&isDir]  )  {
		[[NSFileManager defaultManager] createDirectoryAtPath:dbDir withIntermediateDirectories:NO attributes:nil error:nil];
	}
	
	
}

#pragma mark Local Stuff...

-(void) refreshLocalFavoriteVenues {
	
	[favoriteVenues release];
	favoriteVenues = nil;
	
	favoriteVenues = [[FSVenue getLocalFavorites] retain];
	
	//favoritesAreOutOfDate = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteVenuesWereAddedNotification object:nil];
	
	NSLog(@"Have %i favs!" , [favoriteVenues count]);
	
	
}

-(NSMutableArray*) favoriteVenues {
	
	if ( favoriteVenues == nil ) {
		[self refreshLocalFavoriteVenues];
	}
	
	return favoriteVenues;
	
}

-(BOOL) isVenueLocalFavorite:(FSVenue*)venueFav {
		
	for (FSVenue * ven in self.favoriteVenues ) {
		
		if ( [ven.venueId isEqualToString:venueFav.venueId] ) {
			return YES;
		}
		
	}
	
}

// dont call this directly...
-(void) removeFavoriteVenue:(FSVenue*)ven {
	
	
	FSVenue * venToRemove = nil;
	
	for (FSVenue * venue in self.favoriteVenues ) {
		
		if ( [venue.venueId isEqualToString:ven.venueId] ) {
			venToRemove = venue;
		}
		
	}
	
	if ( venToRemove ) { 
		[[Model instance].favoriteVenues removeObject:venToRemove];
		//favoritesAreOutOfDate = YES;
		//favoritesWereRemoved = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteVenuesWereRemovedNotification object:nil];
	}
	
	
	// look for this venue in the places it might be
	for (FSVenue * venue in self.venuesArray ) {
		
		if ( [venue.venueId isEqualToString:ven.venueId] ) {
			venue.isLocalFavorite = NO;
		}
		
	}
	
	
}

// dont call this directly...
-(void) addFavoriteVenue:(FSVenue*)ven {
	
	// maybe it's in the nearby venues array 
	for (FSVenue * venue in self.venuesArray ) {
		
		if ( [venue.venueId isEqualToString:ven.venueId] ) {
			venue.isLocalFavorite = YES;
		}
		
	}
	
	// if its not already in the favs, add it...
	FSVenue * venToAdd = nil;
	
	for (FSVenue * venue in self.favoriteVenues ) {
		
		if ( [venue.venueId isEqualToString:ven.venueId] ) {
			venToAdd = venue;
		}
		
	}
	
	if ( !venToAdd ) { 
		//favoritesAreOutOfDate = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:kFavoriteVenuesWereAddedNotification object:nil];
		[[Model instance].favoriteVenues addObject:ven];
	}
	
	
}


#pragma mark Favorite USers Stuff...

-(void) refreshLocalFavoriteUsers {
	
	[favoriteUsers release];
	favoriteUsers = nil;
	
	favoriteUsers = [[FSUser getLocalFavorites] retain];
	
	// use notifications instead..
	// favoriteUsersAreOutOfDate = YES;
	
	NSLog(@"Have %i fav users!" , [favoriteUsers count]);
	
	
}

-(NSMutableArray*) favoriteUsers {
	
	if ( favoriteUsers == nil ) {
		[self refreshLocalFavoriteUsers];
	}
	
	return favoriteUsers;
	
}

-(BOOL) isUserLocalFavorite:(FSUser*)userFav {
	
	for (FSUser * usr in self.favoriteUsers ) {
		
		if ( [usr.userId isEqualToString:userFav.userId] ) {
			return YES;
		}
		
	}
	
}

#pragma -
#pragma mark prefs

-(BOOL) isBannedCategory:(FSCategory*)cat {
	
	//NSLog(@"isBannedCategory: %@ --  %@ " , cat , bannedCategories );
	
	if ( cat == nil || cat.name == nil ) {
		return [self.bannedCategories containsObject:@"nils"];
	} else {
		return [self.bannedCategories containsObject:cat.name];
	}
}

-(void) toggleBannedCategoryString:(NSString*)str {
	
	if ( [self isBannedCategoryString:str] ) {
		[self removeBannedCategoryString:str];
	} else {
		[self addBannedCategoryString:str];
	}
	
}

-(BOOL) isBannedCategoryString:(NSString*)str {
	
	if ( !str ) {
		return [self.bannedCategories containsObject:@"nils"];
	} else {
		return [self.bannedCategories containsObject:str];
	}
	
}

-(void) removeBannedCategory:(FSCategory*)cat {
	
	if ( cat == nil || cat.name == nil ) {
		[self.bannedCategories removeObject:@"nils"];
	} else {
		[self.bannedCategories removeObject:cat.name];
	}
	
	
	[self saveCategoryPreferences];
	
}

-(void) addBannedCategory:(FSCategory*)cat {
	
	if ( cat == nil || cat.name == nil ) {
		[self.bannedCategories addObject:@"nils"];
	} else {
		[self.bannedCategories addObject:cat.name];
	}

	[self saveCategoryPreferences];
		
}
		

-(void) removeBannedCategoryString:(NSString*)cat {
	
	if ( cat == nil ) {
		[self.bannedCategories removeObject:@"nils"];
	} else {
		[self.bannedCategories removeObject:cat];
	}
	
	
	[self saveCategoryPreferences];
	
}

-(void) addBannedCategoryString:(NSString*)cat {
	
	if ( cat == nil ) {
		[self.bannedCategories addObject:@"nils"];
	} else {
		[self.bannedCategories addObject:cat];
	}
	
	[self saveCategoryPreferences];
	
}

		 

-(void) saveCategoryPreferences {

	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *archivePath = [documentsDirectory stringByAppendingPathComponent:@"banned_cats.archive"];
	
	[NSKeyedArchiver archiveRootObject:bannedCategories toFile:archivePath];

	
}

-(void) refreshCategoryPreferences {

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *archivePath = [documentsDirectory stringByAppendingPathComponent:@"banned_cats.archive"];
	
	self.bannedCategories = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
	
	if ( !bannedCategories ) {
		self.bannedCategories = [NSMutableSet set];
	}
}


#pragma mark -
#pragma mark DB



- (void)initDb
{
	
					   
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	documentsDirectory = [documentsDirectory stringByAppendingString:@"/.db/"];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILE];
	
		
	BOOL dbExists = [fileManager fileExistsAtPath:writableDBPath];
	
	if (dbExists) {
		
		//NSLog(@"DB Exists");
		//return;
		
	} else {
	
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_FILE];
		BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		
		if (!success) {
			
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
			
		}
		
	}
	
	
	//[self doDBMigrations];
	
	[self openFMDB];

	
}

/*
-(void) doDBMigrations {
	
	NSArray *migrations = [NSArray arrayWithObjects:
						   [SongBugMigration migration], // 1
						   nil
						   ];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	documentsDirectory = [documentsDirectory stringByAppendingString:@"/.db/"];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILE];
	
	NSLog(@"Executing DB Migrations");
	
    [FmdbMigrationManager executeForDatabasePath:path withMigrations:migrations];
	
	
}
*/
	
-(void) openFMDB {
	
	
	if (db == nil) {
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		documentsDirectory = [documentsDirectory stringByAppendingString:@"/.db/"];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILE];

		
		db = [[FMDatabase databaseWithPath:path] retain];
		if (![db open]) {
			NSLog(@"Could not open db.");
			//[pool release];
			
		} else {
			//NSLog(@"DB Open Success");
		}
		
	}
	
}



#pragma mark -
#pragma mark SINGLETON

+ (Model*)instance {
    @synchronized(self) {
        if (instance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return instance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            return instance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}


// setup the data collection
- init {
	if (self = [super init]) {
		
		
		
	}
	return self;
}


@end
