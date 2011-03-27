//
//  VenueAnnotation.h
//  MoreSquare
//
//  Created by Chris Laan on 3/26/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <MapKit/MapKit.h>

#include "FSObjects.h"

@interface VenueAnnotation : NSObject <MKAnnotation> {

    //NSNumber *latitude;
    //NSNumber *longitude;
	
}

@property (nonatomic, retain) FSVenue * venue;

//@property (nonatomic, retain) NSNumber *latitude;
//@property (nonatomic, retain) NSNumber *longitude;

@end



@end
