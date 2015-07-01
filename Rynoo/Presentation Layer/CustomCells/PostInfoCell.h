//
//  PostInfoCell.h
//  Rnyoo
//
//  Created by Rnyoo on 04/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostInfoCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UISwitch *switchBtn;
@property (strong, nonatomic) IBOutlet UITextField *postTitleTxtFld;
@property (strong, nonatomic) IBOutlet UILabel *pictureLbl;
@property (strong, nonatomic) IBOutlet UILabel *lineLbl;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@end
