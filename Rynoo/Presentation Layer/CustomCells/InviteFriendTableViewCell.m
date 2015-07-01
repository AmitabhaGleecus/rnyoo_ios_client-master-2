//
//  InviteFriendTableViewCell.m
//  Rynoo
//
//  Created by Rnyoo on 13/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "InviteFriendTableViewCell.h"
#import "Util.h"

@implementation InviteFriendTableViewCell

@synthesize radioButtonImageview, contactName,contactNumber;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        contactName = [[UILabel alloc] initWithFrame:CGRectMake(25, 8, 250, 20)];
        contactName.textAlignment = NSTextAlignmentLeft;
        [contactName setFont:[Util Font:FontTypeSemiBold Size:13.0]];
        contactName.backgroundColor = [UIColor clearColor];
        contactName.textColor  =[UIColor colorWithRed:52.0/255.0 green:73.0/255.0 blue:94.0/255.0 alpha:1.0];
        [self.contentView addSubview:contactName];
        
        contactNumber = [[UILabel alloc] initWithFrame:CGRectMake(25, 22, 250, 25)];
        contactNumber.textAlignment = NSTextAlignmentLeft;
        [contactNumber setFont:[Util Font:FontTypeSemiBold Size:13.0]];
        contactNumber.backgroundColor = [UIColor clearColor];
        contactNumber.textColor  =[UIColor colorWithRed:52.0/255.0 green:73.0/255.0 blue:94.0/255.0 alpha:1.0];

        [self.contentView addSubview:contactNumber];
        
        radioButtonImageview =[[UIImageView alloc]initWithFrame:CGRectMake(285, 10, 20, 20)];
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
