//
//  PostInfoCell.m
//  Rnyoo
//
//  Created by Rnyoo on 04/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "PostInfoCell.h"

@implementation PostInfoCell

- (void)awakeFromNib {
    // Initialization code
    _switchBtn.hidden = YES;
    _postTitleTxtFld.hidden = YES;
    _pictureLbl.hidden = YES;
//    _lineLbl.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
