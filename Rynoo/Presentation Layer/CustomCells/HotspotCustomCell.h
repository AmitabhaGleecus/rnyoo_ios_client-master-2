//
//  HotspotCustomCell.h
//  Rnyoo
//
//  Created by Rnyoo on 02/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

@interface HotspotCustomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *hotspotImgView;
@property (strong, nonatomic) IBOutlet UILabel *hotspotTitle;
@property (strong, nonatomic) IBOutlet UITextView *hotspotDesc;
@property (strong, nonatomic) IBOutlet UIImageView *hotspotBGImgView;

@end
