//
//  CommentsViewController.h
//  Rnyoo
//
//  Created by Thirupathi on 03/02/15.
//  Copyright (c) 2015 Suvarna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "questionView.h"


@interface CommentsViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate>


@property (strong, nonatomic) IBOutlet UITableView *tblComments;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;


@property(nonatomic,retain)NSString *strPostId;

@property(nonatomic,retain)NSManagedObjectContext *context;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldComment;
@property(nonatomic,retain)questionView *hsQuestionView;
- (IBAction)btnSendComment:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *btmView;

@property(nonatomic,retain)NSArray *aryQuestions;

@end
