//
//  PostDetailCell.h
//  Rnyoo
//
//  Created by Rnyoo on 04/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostDetailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextView *postDetailTxtView;
@property (strong, nonatomic) IBOutlet UILabel *pictureLbl;
@property (strong, nonatomic) IBOutlet UITextField *typeLocationLbl;
@property (strong, nonatomic) IBOutlet UILabel *lineLbl;
@property (strong, nonatomic) IBOutlet UILabel *locationLblk;
@property (strong, nonatomic) IBOutlet UISwitch *swithBtn;

@end
