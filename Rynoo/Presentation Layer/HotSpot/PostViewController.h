//
//  PostViewController.h
//  Rnyoo
//
//  Created by Rnyoo on 02/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "hotspotSharedBO.h"

@interface PostViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate, UITextViewDelegate>
{
    BOOL isNaviagtedToContacts;
}
@property(nonatomic,strong) NSMutableArray *hotspotsArray;
@property (strong, nonatomic) IBOutlet UITableView *hotspotTableView;
@property (strong, nonatomic) IBOutlet UIButton *doneAssignClicked;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;

@property(nonatomic,retain)NSManagedObjectContext *context;
@property(nonatomic,retain)NSString *selectedImgId, *strPodId, *strPostId;
@property(nonatomic,retain)hotspotSharedBO *objHotSpotSharedBO;
@property(nonatomic, assign) FROM_SOURCE source;

@property(nonatomic, assign) BOOL isPublisherUpdate, isPublisherRePost,isPodCreated;;

@property(nonatomic, retain) NSArray *arrAddedHsIds;
@property(nonatomic, retain) NSArray *arrUpdatedHsIds, *arrRemainedHsIds, *arrDeleteHsIds;

@property(nonatomic,retain)NSDictionary *dictPod;

@end
