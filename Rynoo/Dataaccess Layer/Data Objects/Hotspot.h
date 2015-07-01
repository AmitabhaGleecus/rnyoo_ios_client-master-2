//
//  Hotspot.h
//  Rnyoo
//
//  Created by Rnyoo on 05/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Hotspot : NSManagedObject

@property (nonatomic, retain) NSString * audioFilePath;
@property (nonatomic, retain) NSString * audioFileUrl;
@property (nonatomic, retain) NSNumber * hId;
@property (nonatomic, retain) NSString * hotspotColor;
@property (nonatomic, retain) NSNumber * imgId;
@property (nonatomic, retain) NSString * strDescription;
@property (nonatomic, retain) NSString * strLabel;
@property (nonatomic, retain) NSNumber * mediaFlag;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * xCoordinate;
@property (nonatomic, retain) NSNumber * yCoordinate;

@end
