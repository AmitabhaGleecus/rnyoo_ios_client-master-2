//
//  networkCustomCellTableViewCell.m
//  Rnyoo
//
//  Created by Thirupathi on 07/01/15.
//  Copyright (c) 2015 Suvarna. All rights reserved.
//

#import "networkCustomCellTableViewCell.h"
#import "Util.h"

@implementation networkCustomCellTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Adding check image view to accessory view of the cell
       
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(3,2, 30, 30)];
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.clipsToBounds = YES;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.borderColor = [UIColor blackColor].CGColor;
        
     //   [imageView setImageWithURL:[NSURL URLWithString:[dictPostData valueForKey:@"avatar"]]];
        [self.contentView addSubview:imageView];
        
        UILabel *lblUserName = [self createLabelWithTitle:@"" frame:CGRectMake(36, 5, 285, 20) tag:1 font:[Util Font:FontTypeRegular Size:12.0] color:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f] numberOfLines:0];
        [self.contentView addSubview:lblUserName];
        
        UILabel *lblPostedOn = [self createLabelWithTitle:@"Posted On" frame:CGRectMake(36, 25, 285, 20) tag:1 font:[Util Font:FontTypeLight Size:13.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:1];
        NSDateFormatter *dateformater=[[NSDateFormatter alloc]init];
        [dateformater setDateFormat:@"dd-MM-YYYY"];
        
        NSDateFormatter *dtfrm = [[NSDateFormatter alloc] init];
        [dtfrm setDateFormat:@"MM/dd/yyyy"];
        
        lblPostedOn.text = [NSString stringWithFormat:@"Posted On %@",@""];
        [self.contentView addSubview:lblPostedOn];
        
        UIButton *btnDelete = [[UIButton alloc]initWithFrame:CGRectMake(40,10, 12, 16)];
        [btnDelete addTarget:self action:@selector(deletePost:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView  *imageViewDelete = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, 12, 16)];
        [imageViewDelete setImage:[UIImage imageNamed:@"deletePost"]];
        [btnDelete addSubview:imageViewDelete];
        
        [self.contentView addSubview:btnDelete];
        
        
        NSString *strImagePath =   [self getImagePathFromDB];
     //   NSLog(@"Image %@",strImagePath);
        
        
        UIButton *btnHotspot = [[UIButton alloc]initWithFrame:CGRectMake(0,60,320, 210)];
        [btnHotspot addTarget:self action:@selector(loadHotspotImage:) forControlEvents:UIControlEventTouchUpInside];
        
     UIImageView   *hotspotImageVw = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,tableView.frame.size.width, 210)];
        [hotspotImageVw setContentMode:UIViewContentModeScaleAspectFit];
        if(strImagePath!= nil && strImagePath.length)
        {
            [hotspotImageVw setImage:[UIImage imageWithWebPAtPath:strImagePath]];
            [btnHotspot addSubview: hotspotImageVw];
            [cell.contentView addSubview:btnHotspot];
            selectedImg = hotspotImageVw.image;
            NSLog(@"imageview:%@",hotspotImageVw);
            // load hotspots
            [self loadHotSpotsOfPostedImage];
            
            
        }
        UIView *vwLike = [[UIView alloc]initWithFrame:CGRectMake(0, 270, tableView.frame.size.width, 35)];
        vwLike.tag = 3333;
        vwLike.backgroundColor =[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f];
        
        imgLike = [[UIButton alloc]initWithFrame:CGRectMake(tableView.frame.size.width/2, 8, 24,21)];
        [imgLike setBackgroundImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        if(isLike== YES)
        {
            [imgLike  addTarget:self action:@selector(dislike_BtnAction:) forControlEvents:UIControlEventTouchUpInside];
            vwLike.backgroundColor = [UIColor colorWithRed:247/255.0f green:97/255.0f blue:81/255.0f alpha:0.85f];
        }
        else
            [imgLike  addTarget:self action:@selector(like_BtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [vwLike addSubview:imgLike];
        [cell.contentView addSubview:vwLike];
        
        
        
        
        //                UILabel *lblPostTitle = [self createLabelWithTitle:@"This is the title of the post and it may have #hashtags #hashtags" frame:CGRectMake(20,315, 200,50) tag:123 font:[Util Font:FontTypeSemiBold Size:13.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
        //                lblPostTitle.lineBreakMode = NSLineBreakByWordWrapping;
        //                [cell.contentView addSubview:lblPostTitle];
        
        
        NSLog(@"likes:%li",(long)numberOfLikes);
        UILabel *lblNumberofLikes = [self createLabelWithTitle:[NSString stringWithFormat:@"%li Likes",(long)numberOfLikes] frame:CGRectMake(20,340,100,60) tag:123 font:[Util Font:FontTypeSemiBold Size:12.0] color:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f] numberOfLines:0];
        
        
        [cell.contentView addSubview:lblNumberofLikes];
        
        if([[dictPostData valueForKey:@"location"] length] > 0)
        {
            NSString *strPictureTakenAt = [NSString stringWithFormat:@"Picture taken at %@",[dictPostData valueForKey:@"location"]];
            
            
            UILabel *lblPicTakenAt = [self createLabelWithTitle:strPictureTakenAt frame:CGRectMake(20,370,200,60) tag:1 font:[Util Font:FontTypeSemiBold Size:13.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
            [cell.contentView addSubview:lblPicTakenAt];
        }

    }
    
    return self;
    
}

#pragma mark - Create Label

-(UILabel*)createLabelWithTitle:(NSString*)strTitle frame:(CGRect)frame tag:(NSInteger)intTag font:(UIFont*)font color:(UIColor*)color numberOfLines:(NSInteger)intNoOflines
{
    UILabel *lbl=[[UILabel alloc]initWithFrame:frame];
    lbl.text=strTitle;
    lbl.font=font;
    lbl.tag=intTag;
    lbl.backgroundColor=[UIColor clearColor];
    lbl.textColor=color;
    lbl.numberOfLines=intNoOflines;
    return lbl;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
