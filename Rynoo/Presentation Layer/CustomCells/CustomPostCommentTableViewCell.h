//
//  CustomPostCommentTableViewCell.h
//  Rnyoo
//
//  Created by Rnyoo on 25/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@interface CustomPostCommentTableViewCell : UITableViewCell <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)NSMutableArray *aryPostData;
@property(nonatomic,assign)BOOL isCommented;

@end
