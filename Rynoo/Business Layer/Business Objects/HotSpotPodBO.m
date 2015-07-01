//
//  HotSpotPodBO.m
//  Rnyoo
//
//  Created by Rnyoo on 02/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "HotSpotPodBO.h"

@implementation HotSpotPodBO
@synthesize strImageID;
@synthesize strImageName;
@synthesize strImageUrl;
@synthesize strImageLocalPath;
@synthesize arrHotSpots;
@synthesize arrImages;
@synthesize imageCreatedTime;
@synthesize strAudioUrl;
@synthesize strUniqueID;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.strImageID = @"";
        self.strImageName = @"";
        self.strImageUrl = @"";
        self.strImageLocalPath = @"";
        self.arrHotSpots = [[NSMutableArray alloc] init];
        self.arrImages = [[NSMutableArray alloc]init];
        self.imageCreatedTime = 0;
        self.strAudioUrl = @"";
        self.strUniqueID = @"";
    }
    return self;
}


@end
