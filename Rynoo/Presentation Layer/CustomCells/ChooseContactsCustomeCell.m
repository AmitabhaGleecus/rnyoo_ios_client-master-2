//
//  ChooseContactsCustomeCell.m
//  Rnyoo
//
//  Created by Rnyoo on 03/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "ChooseContactsCustomeCell.h"

@implementation ChooseContactsCustomeCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Adding check image view to accessory view of the cell
        self.checkImgView =[[UIImageView alloc]initWithFrame:CGRectMake(285, 10, 20, 20)];
        self.checkImgView.backgroundColor=[UIColor clearColor];
        self.checkImgView.image = [UIImage imageNamed:@"unchecked.png"];
        [self setAccessoryView:self.checkImgView];
    }
    
    return self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
