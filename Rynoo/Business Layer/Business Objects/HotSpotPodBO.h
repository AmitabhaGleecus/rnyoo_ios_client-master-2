//
//  HotSpotPodBO.h
//  Rnyoo
//
//  Created by Rnyoo on 02/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotSpotPodBO : NSObject

@property(nonatomic, retain) NSString *strImageID;
@property(nonatomic, retain) NSString *strImageName;
@property(nonatomic, retain) NSString *strImageUrl;
@property(nonatomic, retain) NSString *strImageLocalPath;
@property(nonatomic, retain) NSMutableArray *arrHotSpots;
@property(nonatomic, retain) NSMutableArray *arrImages;
@property(nonatomic, assign) long imageCreatedTime;
@property(nonatomic, retain) NSString *strAudioUrl;
@property(nonatomic, retain) NSString *strUniqueID;

@end
