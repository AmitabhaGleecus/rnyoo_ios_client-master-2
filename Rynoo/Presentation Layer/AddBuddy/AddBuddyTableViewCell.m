//
//  AddBuddyTableViewCell.m
//  Rnyoo
//
//  Created by Suvarna on 12/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "AddBuddyTableViewCell.h"
#import "Util.h"

@implementation AddBuddyTableViewCell

 @synthesize radioButtonImageview,friendName,imgViewFriend;

- (void)awakeFromNib {
    // Initialization code
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        friendName = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 250, 25)];
        friendName.textAlignment = NSTextAlignmentLeft;
        [friendName setFont:[Util Font:FontTypeSemiBold Size:13.0]];
        friendName.backgroundColor = [UIColor clearColor];
//        friendName.textColor  =[UIColor colorWithRed:52.0/255.0 green:73.0/255.0 blue:94.0/255.0 alpha:1.0];
        [self.contentView addSubview:friendName];
        
        imgViewFriend =[[UIImageView alloc]initWithFrame:CGRectMake(20, 5, 50, 50)];
        self.imgViewFriend.layer.cornerRadius = self.imgViewFriend.frame.size.width / 2;
        self.imgViewFriend.backgroundColor = [UIColor clearColor];
        self.imgViewFriend.clipsToBounds = YES;

        [self addSubview:imgViewFriend];
        
        
        radioButtonImageview =[[UIImageView alloc]initWithFrame:CGRectMake(285, 100, 20, 20)];
        radioButtonImageview.backgroundColor=[UIColor clearColor];
        radioButtonImageview.image = [UIImage imageNamed:@"unchecked.png"];
        [self setAccessoryView:radioButtonImageview];

    }
    return self;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
