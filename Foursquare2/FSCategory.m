//
//  FSCategory.m
//  MoreSquare
//
//  Created by Chris Laan on 3/31/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import "FSCategory.h"


@implementation FSCategory

@synthesize name, categoryId, iconUrl;

@synthesize genericCategory, isGeneric , isPrimary, parent; 


+(VenueGenericCategory) categoryTypeForString:(NSString*)str {
	
	// there are no IDs for parent categories, 
	// so we should cache a list of all categories and what the parents are, 
	// then people can choose what to display from this list.
	
	/*
	 
	 Travel Spots
	 Colleges & Universities
	 Shops
	 Homes, Work, Others
	 Great Outdoors
	 Food
	 Nightlife Spots
	 Arts & Entertainment
	 
	 */
	
	if ( [[str lowercaseString] rangeOfString:@"food"].length > 0 ) {
		return CATEGORY_FOOD;
	} else if ( [[str lowercaseString] rangeOfString:@"nightlife"].length > 0 ) {
		return CATEGORY_NIGHTLIFE;
	} else if ( [[str lowercaseString] rangeOfString:@"entertainment"].length > 0 ) {
		return CATEGORY_ARTS_AND_ENTERTAINMENT;
	} else if ( [[str lowercaseString] rangeOfString:@"colleges"].length > 0 ) {
		return CATEGORY_COLLEGES_AND_UNIVERSITIES;
	} else if ( [[str lowercaseString] rangeOfString:@"travel"].length > 0 ) {
		return CATEGORY_TRAVEL_SPOTS;
	} else if ( [[str lowercaseString] rangeOfString:@"homes"].length > 0 ) {
		return CATEGORY_HOMES_WORK_OTHERS;
	} else if ( [[str lowercaseString] rangeOfString:@"shops"].length > 0 ) {
		return CATEGORY_SHOPS;
	} else if ( [[str lowercaseString] rangeOfString:@"outdoors"].length > 0 ) {
		return CATEGORY_GREAT_OUTDOORS;
	}
	
}


+(FSCategory*) categoryFromJson:(id)json {
	
	FSCategory * cat = [[[FSCategory alloc] init] autorelease];
	
	cat.iconUrl = [json objectForKey:@"icon"];
	cat.name = [json objectForKey:@"name"];
	cat.categoryId = [json objectForKey:@"id"];
	

	id prim = [json objectForKey:@"primary"];
	
	if ( prim ) {
		
		cat.isPrimary = YES;
	
	}
	
	
	id _parent = [json objectForKey:@"parents"];
	
	if ( _parent && [_parent count] ) {
		
		FSCategory * parCat = [[[FSCategory alloc] init] autorelease];
		parCat.name = [_parent objectAtIndex:0];
		parCat.isGeneric = YES;
		parCat.genericCategory = [FSCategory categoryTypeForString:parCat.name];
		cat.parent = parCat;
		
	}
	
	
	return cat;
	
	
}


@end
