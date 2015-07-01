//
//  NetworkTableViewCell.m
//  Rnyoo
//
//  Created by Sreenadh G on 18/03/15.
//  Copyright (c) 2015 Suvarna. All rights reserved.
//

#import "NetworkTableViewCell.h"

@implementation NetworkTableViewCell
static CGSize onLoadSize;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
   /* if(CGSizeZero.width==onLoadSize.width && CGSizeZero.height==onLoadSize.height)
    {
        onLoadSize=self.contentView.bounds.size;
    }
    self.textLabel.frame = CGRectMake(0, 0, onLoadSize.width, onLoadSize.height);
    self.contentView.frame=self.textLabel.frame;*/
}



@end
