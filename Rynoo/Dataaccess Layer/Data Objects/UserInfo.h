//
//  UserInfo.h
//  Rnyoo
//
//  Created by Rnyoo on 03/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Interests;

@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * activated;
@property (nonatomic, retain) NSNumber * activatedAt;
@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSNumber * createdAt;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * lastUpdatedAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * preferredChannels;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSString * statusMessage;
@property (nonatomic, retain) NSString * timeZone;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userType;
@property (nonatomic, retain) NSSet *usertoInterestsRel;
@end

@interface UserInfo (CoreDataGeneratedAccessors)

- (void)addUsertoInterestsRelObject:(Interests *)value;
- (void)removeUsertoInterestsRelObject:(Interests *)value;
- (void)addUsertoInterestsRel:(NSSet *)values;
- (void)removeUsertoInterestsRel:(NSSet *)values;

@end
