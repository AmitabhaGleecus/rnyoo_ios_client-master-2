//
//  HotspotCommentViewController.h
//  Rnyoo
//
//  Created by Thirupathi on 05/02/15.
//  Copyright (c) 2015 Suvarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hotSpotCircleView.h"
#import "BaseViewController.h"

@interface HotspotCommentViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property(nonatomic,retain)NSString *strHotspotId;

@property(nonatomic,retain)NSString *strPostId;

@property(nonatomic,retain)NSString *strPodId;
@property(nonatomic,retain)hotSpotCircleView *objHsCircleView;
@property(nonatomic,retain)NSManagedObjectContext *context;
@property (strong, nonatomic) IBOutlet UITableView *tblComments;
@property (strong, nonatomic) IBOutlet UIView *btmView;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldComment;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property(nonatomic,assign)NSInteger numberOfRatings;
@property(nonatomic,retain)NSArray *aryComments;

- (IBAction)btnSendComment:(id)sender;

@end
