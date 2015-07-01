//
//  Interests.h
//  Rnyoo
//
//  Created by Rnyoo on 03/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserInfo;

@interface Interests : NSManagedObject

@property (nonatomic, retain) NSString * imgUrl;
@property (nonatomic, retain) NSString * interestName;
@property (nonatomic, retain) NSString * simgUrl;
@property (nonatomic, retain) UserInfo *interestsToUserRel;

@end
