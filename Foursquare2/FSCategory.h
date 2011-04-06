//
//  FSCategory.h
//  MoreSquare
//
//  Created by Chris Laan on 3/31/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum VenueGenericCategory {
	
	//Travel Spots
	CATEGORY_TRAVEL_SPOTS,
	
	//Colleges & Universities
	CATEGORY_COLLEGES_AND_UNIVERSITIES,
	
	//Shops
	CATEGORY_SHOPS,
	
	//Homes, Work, Others
	CATEGORY_HOMES_WORK_OTHERS,
	
	//Great Outdoors
	CATEGORY_GREAT_OUTDOORS,
	
	//Food
	CATEGORY_FOOD,
	
	//Nightlife Spots
	CATEGORY_NIGHTLIFE,
	
	//Arts & Entertainment
	CATEGORY_ARTS_AND_ENTERTAINMENT
	
} VenueGenericCategory;

@class FSCategory;

@interface FSCategory : NSObject {

}

@property BOOL isPrimary;
@property BOOL isGeneric;
@property VenueGenericCategory genericCategory;

@property (nonatomic, retain) FSCategory * parent;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * categoryId;

+(FSCategory*) categoryFromJson:(id)json;
+(VenueGenericCategory) categoryTypeForString:(NSString*)str;

@end
