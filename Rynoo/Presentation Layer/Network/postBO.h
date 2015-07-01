//
//  postBO.h
//  Rnyoo
//
//  Created by Sreenadh G on 13/01/15.
//  Copyright (c) 2015 Suvarna. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface postBO : NSObject


@property (nonatomic, retain) NSString *strAvatarUrl;
@property (nonatomic, retain) NSString *strScreenName;
@property (nonatomic, retain) NSString *strImgid;
@property (nonatomic, retain) NSString *strImgUrl;
@property (nonatomic, retain) NSString *strImgLocalPath;
@property (nonatomic, retain) NSString *strPictureTakenLocation;
@property (nonatomic, retain) NSMutableArray *arrComments;
@property (nonatomic, retain) NSArray *arrLikes;
@property (nonatomic, retain) NSArray *arrHotspots;
@property (nonatomic, retain) NSArray *arrQuestions,*arrHotspotRating;
@property (nonatomic, assign) BOOL isPublishedByUser, isExistingInDB, isAlreadyLikedByUser;
@property (nonatomic, retain) NSString *createdAt;
@property(nonatomic,retain) NSString *strPostTitle;
@property(nonatomic,retain) NSString *strPostId;
@property(nonatomic,retain) NSString *strPodId;
@property(nonatomic,assign) NSInteger numberOfLikes;
@property(nonatomic,retain) NSString *strOrientation;
@property (nonatomic, retain) NSArray *arrHotspotsShared;
@property(nonatomic,retain) NSArray *aryHotspotComments;
@property (nonatomic, retain) NSString *pictureTakenOn;

@end
