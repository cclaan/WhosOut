//
//  FSUser.h
//  MoreSquare
//
//  Created by Chris Laan on 3/19/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FSUser : NSObject {

}

@property BOOL itsaLady;
@property BOOL hasPhoto;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * gender;

+(FSUser*) userFromJson:(id) data;


@end
