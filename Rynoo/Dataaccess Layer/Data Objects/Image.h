//
//  Image.h
//  Rnyoo
//
//  Created by Rnyoo on 05/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Image : NSManagedObject

@property (nonatomic, retain) NSNumber * imgId;
@property (nonatomic, retain) NSString * imgPath;
@property (nonatomic, retain) NSString * imgName;
@property (nonatomic, retain) NSString * imgUrl;
@property (nonatomic, retain) NSNumber * syncInitiated;
@property (nonatomic, retain) NSNumber * syncStatus;

@end
