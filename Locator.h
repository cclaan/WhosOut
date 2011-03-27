//
//  Locator.h
//  Scvngr
//
//  Created by cclaan on 4/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import <Foundation/Foundation.h>


// This protocol is used to send the text for location updates back to another view controller
@protocol LocatorDelegate <NSObject>
@required

-(void) locationTimedOut;
-(void) newLocationUpdate:(CLLocation*)loc;
-(void) newError:(NSString *)text;

@end



@interface Locator : NSObject < CLLocationManagerDelegate >{
	
	CLLocationManager *locationManager;
	CLLocation * location;
	id <LocatorDelegate> delegate;
	
	NSString * latString;
	NSString * lonString;
	
	BOOL hasReceivedLocation;
	BOOL hasReceivedError;
	
	float currentDesiredAccuracy;
	
	NSTimer * timeoutTimer;
	NSDate * updatesBeganDate;
	
	
}

@property float currentDesiredAccuracy;

@property (readwrite) BOOL hasReceivedLocation;
@property (readwrite) BOOL hasReceivedError;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic,assign) id delegate;
@property (nonatomic, retain) CLLocation * location;
@property (nonatomic, retain) NSString * latString;
@property (nonatomic, retain) NSString * lonString;

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error;

-(void) start;

+ (Locator *)instance;


@end
