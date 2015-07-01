//
//  NetworkView.h
//  Rnyoo
//
//  Created by Thirupathi on 07/01/15.
//  Copyright (c) 2015 Suvarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageOccupyView.h"

#import "postBO.h"
#import "UIImageView+AFNetworking.h"

//@interface NetworkView : UIView <UITableViewDataSource,UITableViewDelegate>

@protocol NetworkViewDelegate <NSObject>
@optional
-(void)imageTapped:(postBO*)objPost withHotspots:(NSArray*)arrHotspots;
-(void)postDelete:(postBO*)objPost;
-(void)postHide:(postBO*)objPost;
-(void)deletePostAserrorOccured:(postBO*)objPost;
-(void)tapToResignKeyBoard;

-(void)downloadedPost:(postBO*)objPost;


@end

@interface NetworkView : UIView <UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate>
{
    NSInteger numberOfLikes;
    CGSize imageBounds, imgBoundsAtNormalZoomInPortrait, imgBoundsAtNormalZoomInLandScape;
    ImageOccupyView *imageExactSubView;
    CGSize aspectFitSize, preImageViewSize;
    
    
    UITableView *subMenuTableView;
    NSMutableArray *arrHotSpotInfo;
    BOOL isCommentedNow;
    
    UIRefreshControl *refreshControl;

}


@property(weak, nonatomic) id<NetworkViewDelegate> delegate;

@property(nonatomic, retain) UIImageView *imageView;

@property(nonatomic,retain)NSMutableDictionary *dictPostData;

@property(nonatomic,retain)NSManagedObjectContext *context;

@property(nonatomic,retain)UIImageView *hotspotImageVw;

@property(nonatomic,retain)UIImage *selectedImg;


@property(nonatomic,assign)NSInteger index;

@property(nonatomic,retain)NSData *imgData;

@property(nonatomic,assign)NSInteger numberOfLikes;
@property(nonatomic,retain) UIButton *btnDelete;
@property(nonatomic,assign)NSInteger commentsCount;

@property(nonatomic, retain)UIImageView *imageViewAvatar;

@property(nonatomic, retain) UILabel *lblCommentedUsername;

@property(nonatomic, retain) UILabel *lblComment;

@property(nonatomic, retain) UILabel *lblHeader;


@property(nonatomic, retain) postBO *objPost;

@property(nonatomic,assign)BOOL isHavingQuestions;

@property(nonatomic,retain)NSString *strQuestionedPostId;

@property(nonatomic,assign)BOOL isHavingHotspotComments;

@property(nonatomic,retain)NSMutableArray *aryHotspotComments;
-(void)designPostView;


-(void)getDetailsOfPostIncludingCommentswithPostId:(NSString*)postId;
-(void)sendLikerequestToServer;
-(void)sendDisLikerequestToServer;

-(void)deletePost;
-(void)sendCommentToServerwithComment:(NSString*)comment withObj:(postBO*)objPost;

@end
