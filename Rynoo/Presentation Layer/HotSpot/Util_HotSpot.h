//
//  Util_HotSpot.h
//  Rnyoo
//
//  Created by Suvarna on 29/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UIImageView+AFNetworking.h"
#import <AFHTTPRequestOperationManager.h>
#import "postBO.h"
#import "Constants.h"

@interface Util_HotSpot : NSObject
{
    UIAlertView *objAlertView;
}

@property(nonatomic,strong)NSManagedObjectContext *contextHotspot;
@property(nonatomic,assign)NSInteger indexValue;

+(Util_HotSpot*)sharedInstance;

+(void)uploadMediaFile;
+(void)uploadVaultFile;
+(void)SendReqToCreateNewPod;

+(void)updateSyncInitiated;

+(NSManagedObject*)getSelectedImageDataFromDB;
+(NSManagedObject*)getImageDataFromDBOfImgId:(NSString*)strImgId;
+(NSManagedObject*)getUserDataFromDB;
+(NSArray*)getHotspotDataFromDBOfImgId:(NSString*)strImgId withPodId:(NSString*)strPodId;
+(NSManagedObject*)getPostDataFromDBwithPostId:(NSString*)strPostId;
+(NSArray*)getHotspotsSharedDataFromDBwithPostId:(NSString*)strPostId;
+(NSArray*)getQuestionsDatafromDB:(NSString*)strPostId;
+(NSArray*)getHotspotCommentsDatawithHotspotId:(NSString*)strHotspotId podId:(NSString*)strPodId;
+(NSArray*)getHotspotCommentsDatawithPostId:(NSString*)strPostId;
+(NSManagedObject*)getQuestionsDatafromDB:(NSString*)strPostId questionId:(NSString*)strQuestionId;


+(void)saveImageData:(postBO*)objPost;
+(void)savePodData:(postBO*)objPost;
+(void)saveHotspotData:(postBO*)objPost;
+(void)savePostData:(postBO*)ObjPost;
+(void)saveHotspotsSharedData:(postBO*)objPost;
+(void)saveHotspotsSharedDataWithHsId:(NSString*)strHsId ofPostId:(NSString*)strPost withUsers:(NSArray*)arrUsers;
+(void)savequestionsData:(NSDictionary*)dictquestion;
+(void)saveCommentsData:(NSDictionary*)dict;
+(void)saveCommentData:(postBO*)objPost;
+(void)saveHotspotCommentsData:(NSDictionary*)dict :(NSString*)strHotspotId;
+(void)saveQuestionCommentsData:(NSDictionary*)dict;


+(NSArray*)getHotspotsOfHSIds:(NSArray*)arrHSIds;
+(NSArray*)getHotspotDatafromDB;
+(NSArray*)getHotspotsOfPostId:(NSString*)strPostId;
+(NSManagedObject*)getPodDataFromDBOfPodId:(NSString*)strPodId;
+(NSManagedObject*)getPodDataFromDBOfImgId:(NSString*)strImgId;
+(NSString*)getRecentPodIdFromDBOfImgId:(NSString*)strImgId;
+(NSString*)getNotPostedPodIdOfImgId:(NSString*)strImgId;
+(NSArray*)getCommentDatafromDB:(NSString*)strPostId;

+(void)deleteSharedHotspotOfId:(NSString*)strHsId ofPost:(NSString*)strPostId;
+(void)deleteHotspotOfId:(NSString*)strHsId;

+(void)updateImagedataInDBWithSyncStatus:(BOOL)syncStatus withImageUrl:(NSString*)imgUrl;
+(void)updateImageDataInDBWithNewImgId;
+(void)updateHotspotObject:(NSManagedObject*)objHotspot withURL:(NSString*)strAudioUrl;
+(void)updatePodDatawithPodId:(NSString*)pid;

+(NSInteger)indexValue;
+(void)setIndexValue:(NSInteger)index;

+(NSMutableDictionary*)prepareDictForPod;

+(NSManagedObjectContext*)getContext;

+(void)setSelectedImageId:(NSString*)selImageId;
+(void)setAboutPost:(NSString*)strpost;
+(void)setBackGround:(BOOL)isSuccess;
+(BOOL)getBackGround;

+(void)setPodId:(NSString*)podId;

+(void)uploadVaultFile2;



@end
