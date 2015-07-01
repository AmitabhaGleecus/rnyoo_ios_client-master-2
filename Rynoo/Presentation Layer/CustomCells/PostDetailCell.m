//
//  PostDetailCell.m
//  Rnyoo
//
//  Created by Rnyoo on 04/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "PostDetailCell.h"

@implementation PostDetailCell

- (void)awakeFromNib {
    // Initialization code
    _postDetailTxtView.hidden = YES;
    _pictureLbl.hidden = YES;
    _typeLocationLbl.hidden = YES;
    _locationLblk.hidden = YES;
    _lineLbl.hidden = YES;
    _swithBtn.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
