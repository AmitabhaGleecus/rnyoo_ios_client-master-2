//
//  MyCornerViewController.h
//  Rnyoo
//
//  Created by Rnyoo on 19/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

@interface MyCornerViewController : BaseViewController <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tblOptions;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tblTopConstraint;
@property (strong, nonatomic) IBOutlet UIView *vaultView;
@property (strong, nonatomic) IBOutlet UIView *cornerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *vaultViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cornerVewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cornerViewYPosConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cornerViewXPosConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *vaultViewXPosConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;

@property (strong, nonatomic) IBOutlet UITableView *tblVault;

@property(nonatomic,retain)NSManagedObjectContext *context;

@property (strong, nonatomic) IBOutlet UITableView *tblClipBoard;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tblClipBoardXPosConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tblClipBoardWidthConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tblClipBoardYPosConstraint;

@end
