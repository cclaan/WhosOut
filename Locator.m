//
//  Locator.m
//  Scvngr
//
//  Created by cclaan on 4/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Locator.h"
#import "Constants.h"

#define	kDesiredAccuracyRadiusInMeters 5000. // meters
#define kLocationTimeout				5. // seconds
#define kLifeOfLocationMeasurement		-1000. // seconds that one measurement is valid for... so after this time it will restart location manager.

#define kDefaultLatitude -71.058197
#define kDefaultLongitude 42.379851

static Locator *instance = nil;


@implementation Locator

@synthesize delegate, locationManager, location, latString, lonString;
@synthesize hasReceivedLocation,hasReceivedError , currentDesiredAccuracy;


- (id) init {
	self = [super init];
	if (self != nil) {
		
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		self.locationManager.delegate = self; // Tells the location manager to send updates to this object
		self.location = nil;
		hasReceivedLocation = NO;
		hasReceivedError = NO;
		timeoutTimer = nil;
		//NSLog(@"Old Location: %@  " , locationManager.location  );
		
		currentDesiredAccuracy = kDesiredAccuracyRadiusInMeters;
		
		//self.latString = [[NSString alloc] init];
		//self.lonString = [[NSString alloc] init];
		
	}
	return self;
}

-(void) start {
	
	if ( timeoutTimer ){ 
		
		[timeoutTimer invalidate];
		timeoutTimer = nil;
		
	}
	
	hasReceivedLocation = NO;
	self.location = nil;
	
	if ( !locationManager.locationServicesEnabled ) {
		
		// delegate
		// event
		hasReceivedError = YES;
		hasReceivedLocation = YES;
		UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Enabling location services will give you much more relevant search results." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[al show];
		[al release];
		
	} else {
		
		NSLog(@"Starting location manager");
		
		//locationManager.desiredAccuracy 
		[self.locationManager startUpdatingLocation];
		
	}
}

-(void) timeoutTimerFired {
	
	NSLog(@"timeout timer fired");
	
	
	NSTimeInterval t = [updatesBeganDate timeIntervalSinceNow];
	
	if ( abs(t) > kLocationTimeout && !hasReceivedLocation ) {
		
		hasReceivedLocation = YES;
		
		
		// default location
		
		if ( !location ) {
			
			hasReceivedError = YES;
			self.location = [[CLLocation alloc] initWithLatitude:37.744 longitude:37.55];
			///NSLog(@"Setting to default location.");
			NSLog(@"Location services timed out with no location recieved at all, Setting to default location ");
			
		} else {
			
			NSLog(@"Location services timed out for desired accuracy, using most recent measurement");
			
		}
			
		[self.locationManager stopUpdatingLocation];
		
		[timeoutTimer invalidate];
		timeoutTimer = nil;
		
		
		
		
	}
	
}

// Called when the location is updated
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	
	NSLog(@"didUpdateToLocation: %@ " , newLocation );
	
	// Horizontal coordinates
	
	if (signbit(newLocation.horizontalAccuracy)) {
		
		// Negative accuracy means an invalid or unavailable measurement
		// [update appendString:LocStr(@"LatLongUnavailable")];
		
	} else {
		
	
		
		self.location = newLocation;
		
		//self.latString = [NSString stringWithFormat:@"%+.6f", newLocation.coordinate.latitude];
		//self.lonString = [NSString stringWithFormat:@"%+.6f", newLocation.coordinate.longitude];
		self.latString = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.latitude];
		self.lonString = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.longitude];
		
		NSTimeInterval t = [newLocation.timestamp timeIntervalSinceNow];
		
		NSLog(@"lat: %@ , lng: %@ " , self.latString , self.lonString );
		
		//NSLog(@"age of update: %f " , t );
		
		//NSLog(@"Accuracy: %f " , newLocation.horizontalAccuracy );
		
		if ( newLocation.horizontalAccuracy < currentDesiredAccuracy && t > -100.) {
			
			hasReceivedLocation = YES;
			NSLog(@"Conditions met, hasReceivedLocation.. stopping");
			// broadcast event
			
			self.location = newLocation;
			
			if ( timeoutTimer ) {
				[timeoutTimer invalidate];
				timeoutTimer = nil;
			}
			
			// delegate method
			
			[self.locationManager performSelector:@selector(stopUpdatingLocation) withObject:nil afterDelay:4.0];
			
		} else {
			
			// start timer... 
			
			if ( !timeoutTimer ) {
				//NSLog(@"Starting timeout timer");
				
				updatesBeganDate = [[NSDate date] retain];
				timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timeoutTimerFired) userInfo:nil repeats:YES];
				
			}
			
		}
		
	}
}


// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	
	NSLog(@"Location manager failed");
	
	hasReceivedError = YES;
	//self.location = [[CLLocation alloc] initWithLatitude:22. longitude:99.];
	
	if ( timeoutTimer ) {
		[timeoutTimer invalidate];
		timeoutTimer = nil;
	}
	
	
	NSMutableString *errorString = [[[NSMutableString alloc] init] autorelease];
	
	if ([error domain] == kCLErrorDomain) {
		
		// We handle CoreLocation-related errors here
		
		switch ([error code]) {
				// This error code is usually returned whenever user taps "Don't Allow" in response to
				// being told your app wants to access the current location. Once this happens, you cannot
				// attempt to get the location again until the app has quit and relaunched.
				//
				// "Don't Allow" on two successive app launches is the same as saying "never allow". The user
				// can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
				//
			case kCLErrorDenied:
				
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationDenied", nil)];
				break;
				
				// This error code is usually returned whenever the device has no data or WiFi connectivity,
				// or when the location cannot be determined for some other reason.
				//
				// CoreLocation will keep trying, so you can keep waiting, or prompt the user.
				//
			case kCLErrorLocationUnknown:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationUnknown", nil)];
				break;
				
				// We shouldn't ever get an unknown error code, but just in case...
				//
			default:
				[errorString appendFormat:@"%@ %d\n", NSLocalizedString(@"GenericLocationError", nil), [error code]];
				break;
		}
	} else {
		// We handle all non-CoreLocation errors here
		// (we depend on localizedDescription for localization)
		[errorString appendFormat:@"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];
		[errorString appendFormat:@"Description: \"%@\"\n", [error localizedDescription]];
	}
	
	// Send the update to our delegate
	//[self.delegate newLocationUpdate:errorString];
}


+ (Locator *)instance {
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
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
	
}

- (id)autorelease {
    return self;
}



@end
