
#import "Model.h"

#define kGenderPreferenceKey @"kGenderPreferenceKey"

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

@synthesize genderPreference;

#pragma mark -
#pragma mark setup

-(void) setupModel {
	
	[self createUserDirsIfNotThere];
	
	[self initDb];
	
	
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

-(void) refreshLocalFavorites {
	
	[favoriteVenues release];
	favoriteVenues = nil;
	
	favoriteVenues = [[FSVenue getLocalFavorites] retain];
	
	NSLog(@"Have %i favs!" , [favoriteVenues count]);
	
	
}

-(NSMutableArray*) favoriteVenues {
	
	if ( favoriteVenues == nil ) {
		[self refreshLocalFavorites];
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
	}
	
	
}

// dont call this directly...
-(void) addFavoriteVenue:(FSVenue*)ven {
	
	FSVenue * venToAdd = nil;
	
	for (FSVenue * venue in self.favoriteVenues ) {
		
		if ( [venue.venueId isEqualToString:ven.venueId] ) {
			venToAdd = venue;
		}
		
	}
	
	if ( !venToAdd ) { 
		[[Model instance].favoriteVenues addObject:ven];
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
