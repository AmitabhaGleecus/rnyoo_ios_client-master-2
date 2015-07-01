//
//  NetworkView.m
//  Rnyoo
//
//  Created by Thirupathi on 07/01/15.
//  Copyright (c) 2015 Suvarna. All rights reserved.
//

#import "NetworkView.h"
#import "Util.h"
#import "UIImage+WebP.h"
#import "hotSpotCircleView.h"
#import "HotSpotViewController.h"

#define imageHeight 230

@implementation NetworkView
@synthesize dictPostData,context,hotspotImageVw,selectedImg,imageViewAvatar,lblCommentedUsername,lblComment,lblHeader;
@synthesize index,imgData,numberOfLikes,btnDelete,commentsCount;
@synthesize delegate;

@synthesize objPost,isHavingQuestions,strQuestionedPostId,isHavingHotspotComments;
@synthesize aryHotspotComments;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)designPostView
{
    RLogs(@"######## designPostView #######");
    
    RLogs(@"Self Frame - %@", NSStringFromCGRect(self.frame));
    
    isHavingQuestions = NO;
    isHavingHotspotComments = NO;
    if([self.objPost.arrQuestions count] >0)
    {
        isHavingQuestions = YES;
    }
    if([self.objPost.aryHotspotComments count]>0)
    {
        isHavingHotspotComments = YES;
        aryHotspotComments = [[NSMutableArray alloc]init];

//        if(!self.objPost.isExistingInDB)
//        {
//            for(NSDictionary *dict in self.objPost.aryHotspotComments)
//            {
//                [aryHotspotComments addObjectsFromArray:[dict valueForKey:@"comments"]];
//                
//            }
//       
//        }
//        else
        
            aryHotspotComments = [self.objPost.aryHotspotComments mutableCopy];
    }
    int pading = 2;
    subMenuTableView = [[UITableView alloc]initWithFrame:CGRectMake(pading/2, 1, self.frame.size.width - pading, self.frame.size.height-2 ) style:UITableViewStylePlain];
    subMenuTableView.tag = 100;
    subMenuTableView.separatorColor = [UIColor clearColor];
    //subMenuTableView.backgroundColor = [UIColor yellowColor];
    subMenuTableView.delegate = self;
    subMenuTableView.dataSource = self;
    subMenuTableView.contentInset = UIEdgeInsetsZero;
    [self addSubview:subMenuTableView];
    
    if(self.objPost.isPublishedByUser)
    {
        
        [self performSelectorInBackground:@selector(getDetailsOfPostIncludingCommentswithPostId:) withObject:self.objPost.strPostId];

        
    }
    
  
    
    RLogs(@"Self.superView frame - %@", NSStringFromCGRect(self.superview.frame));
    NSLog(@"Self frame - %@", NSStringFromCGRect(self.frame));
    RLogs(@"Self.subMenuTableView frame - %@", NSStringFromCGRect(subMenuTableView.frame));


}
-(void)refreshPost
{
    //if(self.objPost.isPublishedByUser )
       // return;
    
    if(isCommentedNow)
    {
        isCommentedNow = NO;
    
    }
    else
    {
         [self performSelectorInBackground:@selector(getDetailsOfPostIncludingCommentswithPostId:) withObject:self.objPost.strPostId];
    }
}


-(void)tapToResignKeyBoard
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(tapToResignKeyBoard)])
    {
        RLogs(@">>>Tapped image path - %@", self.objPost.strImgLocalPath);
        
        
        [self.delegate tapToResignKeyBoard];
    }
    
}
//manage datasource and  delegate for submenu tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int noOfSections = 4;
    
   /* if([self.objPost.arrQuestions count])
    {
        noOfSections++;
    }
    if([self.objPost.arrComments count])
    {
        noOfSections++;
    }*/
    return noOfSections;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if(section == 0)
   {
       return 4;
   }
    else if (section == 1)
    {
        if(isHavingQuestions)
            return 1;
        else
            return 0;
    }
    else if (section == 2)
    {
        return [aryHotspotComments count];
    }
    else
    {
        if([self.objPost.arrComments count])
        {
            RLogs(@"No. of rows - %lu", (unsigned long)[self.objPost.arrComments count]);
        return [self.objPost.arrComments count];
        }
        else
            return 1;
    }
    
    
    
    if(isHavingQuestions && isHavingHotspotComments)
        return 7;
    if(isHavingQuestions || isHavingHotspotComments)
        return 6;

    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 160;
    
    
    if(indexPath.section == 0)
    {
    
   if(indexPath.row==0)
       return 70;
    else if(indexPath.row == 1)
    {
        //return 230;
        return imageHeight;
    }
    else if(indexPath.row == 2)
        return 35;
    else if(indexPath.row ==3)
    {
        if([self.objPost.strPostTitle length]==0)
            height = height-20;
        if ([self.objPost.strPictureTakenLocation length]==0)
            height = height-30;
        return height;
    }
    }
    else if(indexPath.section == 1)
    {
        return 30;
    }
  
    else
    {
        NSString *strComment;
        NSDictionary *dictComment;
        CGFloat height = 40;
        
        if(indexPath.section == 2)
        {
            dictComment = [aryHotspotComments objectAtIndex:indexPath.row];
            
        }
        else
        {
            dictComment = [self.objPost.arrComments objectAtIndex:indexPath.row];
            height = 60;
        }
        
        strComment = [dictComment valueForKey:@"comment"];

        CGSize commentSize = [strComment sizeWithFont:[Util Font:FontTypeLight Size:11.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 40 , 200)];
        
        return commentSize.height + height;
        
     //   return 60;
    }
   
          return 40;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   if(section == 1)
   {
       if(isHavingQuestions)
       {
           return 30.0;
       }
       else
           return 0.0;
   }
   else if (section == 2)
   {
       if(isHavingHotspotComments)
           return 30.0;
       else
           return 0.0;
   }
   else if (section == 3)
   {
      // if([self.objPost.arrComments objectAtIndex:section] length )
       return 30.0;
   }
    else
        return 0.0;
    
    return 30.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 1)
    {
        if(isHavingQuestions)
        {
            // for consumer view to add questions posted by
            
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width, 1)];
            [line setBackgroundColor:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f]];
            [headerView addSubview:line];
            
            UILabel *lblCommentsTitle = [self createLabelWithTitle:@"Questions Posted By" frame:CGRectMake(20, 5, 285, 20) tag:1 font:[Util Font:FontTypeSemiBold Size:11.0] color:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f] numberOfLines:0];
            [headerView addSubview:lblCommentsTitle];
            return headerView;
        }
       // else
    //        return 0.0;
    }
    else if (section == 2)
    {
        if(isHavingHotspotComments)
        {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
            
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width, 1)];
            [line setBackgroundColor:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f]];
            [headerView addSubview:line];
            
            UILabel *lblCommentsTitle = [self createLabelWithTitle:@"Recent Hotspot Comments" frame:CGRectMake(20, 5, 285, 20) tag:1 font:[Util Font:FontTypeSemiBold Size:11.0] color:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f] numberOfLines:0];
            [headerView addSubview:lblCommentsTitle];
            return headerView;
        }
//            return 30.0;
//        else
//            return 0.0;
    }
    else if (section == 3)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 21)];
        
        
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width, 1)];
        [line setBackgroundColor:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f]];
        [headerView addSubview:line];
        
        UILabel *lblCommentsTitle = [self createLabelWithTitle:@"Post Comments" frame:CGRectMake(20, 5, 285, 20) tag:1 font:[Util Font:FontTypeSemiBold Size:11.0] color:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f] numberOfLines:0];
        [headerView addSubview:lblCommentsTitle];
        return headerView;
    }
    
    
    
    return nil;

}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     NSString *cellIdentifier = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.section];
    UITableViewCell *cell;
    
    if(indexPath.section == 0)
    {
        NSInteger identifierCount = 10+indexPath.row;
        cellIdentifier = [NSString stringWithFormat:@"Cell%li",identifierCount];
    }
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        
        
    }
    
    
    if(indexPath.section > 1)
    for(UIView *aView in cell.contentView.subviews)
        [aView removeFromSuperview];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row != 1)
            for(UIView *aView in cell.contentView.subviews)
                [aView removeFromSuperview];

    }
    
    
    NSString  *strDate;
    
    
    if(self.objPost.createdAt != nil)
    {
        strDate = [Util dateFromInterval:self.objPost.createdAt inDateFormat:DATE_TIME_FORMAT];
        
        RLogs(@">>>Created At - %@", strDate);
        
    }
    else
    {
        NSLog(@"created date is nil.");
    }
    NSLog(@"date:%@",strDate);
    
    NSString *strPictureTaken;
    if(self.objPost.pictureTakenOn != nil)
    {
        strPictureTaken = [Util dateFromInterval:self.objPost.pictureTakenOn inDateFormat:DATE_TIME_FORMAT];

    }
    if(indexPath.section == 0)
    {
        
        if(indexPath.row == 0)
        {
            UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:222];
            if(imageView == nil)
            {imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5,5, 40, 40)];
            imageView.layer.cornerRadius = imageView.frame.size.width / 2;
            imageView.clipsToBounds = YES;
            imageView.layer.borderWidth = 3.0f;
            imageView.layer.borderColor = [UIColor blackColor].CGColor;
            imageView.tag = 222;
                [cell.contentView addSubview:imageView];

            }
            
            NSURL *imgAvatarUrl = [NSURL URLWithString:self.objPost.strAvatarUrl];
            if(imgAvatarUrl)
                [imageView setImageWithURL:imgAvatarUrl];
            
            
            UILabel *lblUserName = [self createLabelWithTitle:self.objPost.strScreenName frame:CGRectMake(50, 10, 285, 20) tag:1 font:[Util Font:FontTypeSemiBold Size:11.0] color:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f] numberOfLines:0];
            [cell.contentView addSubview:lblUserName];
            
            UILabel *lblPostedOn = [self createLabelWithTitle:@"" frame:CGRectMake(50, 30, 285, 20) tag:1 font:[Util Font:FontTypeLight Size:13.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:1];
            RLogs(@"????Post Created - %@", self.objPost.createdAt);
            
            lblPostedOn.text = strDate;
            [cell.contentView addSubview:lblPostedOn];
            
            UIButton *btnDeleteOrHide = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnDeleteOrHide setFrame:CGRectMake(self.frame.size.width - 40, 10, 40, 40)];
            [btnDeleteOrHide setBackgroundColor:[UIColor clearColor]];
            [btnDeleteOrHide setClipsToBounds:YES];
            if(self.objPost.isPublishedByUser == YES)
            {
                [btnDeleteOrHide setImage:[UIImage imageNamed:@"deletePost11.png"] forState:UIControlStateNormal];
                [btnDeleteOrHide setImageEdgeInsets:UIEdgeInsetsMake(8, 12, 8, 12)];
                
            }
            else
            {
                [btnDeleteOrHide setImage:[UIImage imageNamed:@"hidePost11.png"] forState:UIControlStateNormal];
                [btnDeleteOrHide setImageEdgeInsets:UIEdgeInsetsMake(12, 10, 12, 10)];
                
            }
            
            [btnDeleteOrHide addTarget:self action:@selector(deleteOrHidePost) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btnDeleteOrHide];
            
        }
        
        else if(indexPath.row == 1)
        {
            cell.backgroundColor = [UIColor blackColor];
            
            if([self.objPost.strImgLocalPath length]>0 || [self.objPost.strImgUrl length] >0)
            {
                hotspotImageVw = (UIImageView*)[cell.contentView viewWithTag:222];

                if(hotspotImageVw == nil)
                {
                    UIImageView *hotspotImageVw1 = [[UIImageView alloc]initWithFrame:CGRectMake(2, 0, self.frame.size.width, imageHeight)];
                    hotspotImageVw = hotspotImageVw1;
                    [hotspotImageVw setContentMode:UIViewContentModeScaleAspectFit];
                    hotspotImageVw.userInteractionEnabled = YES;
                    hotspotImageVw.tag = 222;
                    [cell.contentView addSubview:hotspotImageVw];

                }
                RLogs(@"Image Path - %@, url - %@", self.objPost.strImgLocalPath, self.objPost.strImgUrl);

                if([[NSFileManager defaultManager] fileExistsAtPath:self.objPost.strImgLocalPath])
                {
                    if(hotspotImageVw.image == nil)
                        [hotspotImageVw setImage:[UIImage imageWithWebPAtPath:self.objPost.strImgLocalPath]];
                    
                    selectedImg = hotspotImageVw.image;
                    // load hotspots
                    
                    RLogs(@"<<<<<Loding Hotspot>>>>>");
                    
                    if(selectedImg != nil)
                    {
                        [self loadHotSpotsOfPostedImage];
                        
                        if([self.objPost.arrQuestions count] >0)
                        {
                            [self loadQuestionsOfPostedImg];
                        }
                    }
                    
                }
                else
                {
                    // [self downloadImageFromUrl:self.objPost.strImgUrl toPath:self.objPost.strImgLocalPath];
                    
                    [self performSelectorInBackground:@selector(downloadImage) withObject:nil];
                }
                
                
                selectedImg = hotspotImageVw.image;
                
                // load hotspots
                if(self.objPost.isPublishedByUser && self.objPost.isExistingInDB)
                {
                    RLogs(@"<<<<<Loding Hotspot>>>>>");
                    
                    if(selectedImg != nil)
                    {
                        [self loadHotSpotsOfPostedImage];
                    }
                }
                
                if([self.objPost.arrQuestions count] >0 && selectedImg != nil)
                {
                    [self loadQuestionsOfPostedImg];
                }
                
            }
        }
        else if(indexPath.row == 2)
        {
            UIView *vwLike = [[UIView alloc]initWithFrame:CGRectMake(0, 1, self.frame.size.width, 35)];
            vwLike.tag = 3333;
            UIButton  *imgLike = [[UIButton alloc]initWithFrame:CGRectMake((self.frame.size.width - 24)/2, 6, 24,21)];
            [imgLike setBackgroundImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
            if(self.objPost.isAlreadyLikedByUser)
            {
                NSLog(@"+++++User Liked");
                vwLike.backgroundColor = [UIColor colorWithRed:247/255.0f green:97/255.0f blue:81/255.0f alpha:0.85f];
            }
            else
            {
                NSLog(@"+++++User dis Liked");

            vwLike.backgroundColor =[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f];
            }
            [vwLike addSubview:imgLike];
            [cell.contentView addSubview:vwLike];
            
            
        }
        else if(indexPath.row == 3)
        {
            UILabel *lblNumberofLike = [self createLabelWithTitle:[NSString stringWithFormat:@"%li Likes",(long)self.objPost.numberOfLikes] frame:CGRectMake(20,5,100,20) tag:123 font:[Util Font:FontTypeSemiBold Size:12.0] color:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f] numberOfLines:0];
            [cell.contentView addSubview:lblNumberofLike];
            
            if([self.objPost.strPostTitle length] >0)
            {
                UILabel *lblTitle = [self createLabelWithTitle:self.objPost.strPostTitle frame:CGRectMake(20,30,200,20) tag:1 font:[Util Font:FontTypeSemiBold Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
                [cell.contentView addSubview:lblTitle];
            }
            
            
            if([self.objPost.strPictureTakenLocation  length] > 0)
            {
                UILabel *lblPicTakenAt = [self createLabelWithTitle:@"Picture taken at" frame:CGRectMake(20,50,200,20) tag:1 font:[Util Font:FontTypeItalic Size:11.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
                
                if([self.objPost.strPostTitle length]==0)
                   [lblPicTakenAt setFrame:CGRectMake(20,30,200,20)];
               
                [cell.contentView addSubview:lblPicTakenAt];
                
                UILabel *lblPicTakenLocation = [self createLabelWithTitle:self.objPost.strPictureTakenLocation frame:CGRectMake(20,65,200,20) tag:1 font:[Util Font:FontTypeSemiBold Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
                
                if([self.objPost.strPostTitle length]==0)
                    [lblPicTakenLocation setFrame:CGRectMake(20,45,200,20)];
                
                [cell.contentView addSubview:lblPicTakenLocation];
            }
            
            UILabel *lblPicTakenOn = [self createLabelWithTitle:@"Picture taken on" frame:CGRectMake(20,90,200,20) tag:1 font:[Util Font:FontTypeItalic Size:11.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
            

            UILabel *lblPicTakenDate = [self createLabelWithTitle:strDate frame:CGRectMake(20,105,200,20) tag:1 font:[Util Font:FontTypeSemiBold Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
            if([strPictureTaken length]>0)
                lblPicTakenDate.text = strPictureTaken;

            
            if([self.objPost.strPostTitle length]==0 && [self.objPost.strPictureTakenLocation length]== 0)
            {
                [lblPicTakenOn setFrame:CGRectMake(20,30,200,20)];
                [lblPicTakenDate setFrame:CGRectMake(20,45,200,20)];

                
            }
            else  if([self.objPost.strPostTitle length] == 0 && [self.objPost.strPictureTakenLocation length]> 0)
            {
                [lblPicTakenOn setFrame:CGRectMake(20,65,200,20)];
                [lblPicTakenDate setFrame:CGRectMake(20,80,200,20)];

                
            }
            else  if([self.objPost.strPostTitle length] > 0 && [self.objPost.strPictureTakenLocation length]== 0)
            {
                [lblPicTakenOn setFrame:CGRectMake(20,50,200,20)];
                [lblPicTakenDate setFrame:CGRectMake(20,65,200,20)];
                
            }
            
            [cell.contentView addSubview:lblPicTakenOn];
            [cell.contentView addSubview:lblPicTakenDate];

            
            
        }
    }
    else if (indexPath.section == 1)
    {
        for(int i=0;i<[self.objPost.arrQuestions count];i++)
        {
            NSDictionary *dict = [self.objPost.arrQuestions objectAtIndex:i];
            
            BOOL isExisting = [self checkForDuplicatesofQuestionsPostedBy:dict];
            
            if(!isExisting)
            {
                UIImageView *imageViewQuestion = [[UIImageView alloc]initWithFrame:CGRectMake(20+i*30,0, 25, 25)];
                imageViewQuestion.layer.cornerRadius = imageViewQuestion.frame.size.width / 2;
                imageViewQuestion.clipsToBounds = YES;
                imageViewQuestion.layer.borderWidth = 3.0f;
                imageViewQuestion.layer.borderColor = [UIColor blackColor].CGColor;
                [imageViewQuestion setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"avatar"]]];
                [cell.contentView addSubview:imageViewQuestion];
                strQuestionedPostId = [dict valueForKey:@"postedBy"];
            }
            
        }
        
    }
    else if (indexPath.section == 2)
    {
        if(indexPath.row >= [aryHotspotComments count])
            return nil;
        
        NSDictionary *dict = [aryHotspotComments objectAtIndex:indexPath.row];
        
        UILabel *lblCommentUsername = [self createLabelWithTitle:[dict valueForKey:@"screenName_s"] frame:CGRectMake(20, 0 , 285, 20) tag:1 font:[Util Font:FontTypeSemiBold Size:10.0] color:[UIColor colorWithRed:241.0/255.0 green:73.0/255.0 blue:64.0/255.0 alpha:1.0] numberOfLines:0];
        [cell.contentView addSubview:lblCommentUsername];
        
        NSString *strComment = [dict valueForKey:@"comment"];
        
        CGSize commentSize = [strComment sizeWithFont:[Util Font:FontTypeLight Size:11.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 40 , 200)];
        RLogs(@"Comment Height - %f", commentSize.height);
        
        UILabel *lblComment1 = [self createLabelWithTitle:strComment frame:CGRectMake(20, 20,self.frame.size.width - 40, commentSize.height) tag:1 font:[Util Font:FontTypeItalic Size:10.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:6];
        lblComment1.lineBreakMode = NSLineBreakByWordWrapping ;
        lblComment1.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:lblComment1];
        
     
        NSString   *strCommentedDate = [Util dateFromInterval:[dict valueForKey:@"commentedAt"] inDateFormat:DATE_TIME_FORMAT];

        UILabel *lblCommentedAt = [self createLabelWithTitle:[NSString stringWithFormat:@"commented at %@",strCommentedDate] frame:CGRectMake(20, lblComment1.frame.origin.y + lblComment1.frame.size.height ,self.frame.size.width - 40, 20) tag:1 font:[Util Font:FontTypeItalic Size:10.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:2];
        lblCommentedAt.lineBreakMode = NSLineBreakByWordWrapping ;
        lblCommentedAt.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:lblCommentedAt];
    }
    else
    {
        UILabel *lblComments = [self createLabelWithTitle:@"" frame:CGRectMake(70, 25, 285, 20) tag:1 font:[Util Font:FontTypeLight Size:11.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
        
        if([self.objPost.arrComments count]==0)
        {
            lblComments.text = @"No comments yet";
            [cell.contentView addSubview:lblComments];
        }
        else
        {
            if(indexPath.row >= [self.objPost.arrComments count])
                return nil;
            
            NSDictionary *dict = [self.objPost.arrComments objectAtIndex:indexPath.row];
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20,0 , 25, 25)];
            imageView.layer.cornerRadius = imageView.frame.size.width / 2;
            imageView.clipsToBounds = YES;
            imageView.layer.borderWidth = 3.0f;
            imageView.layer.borderColor = [UIColor blackColor].CGColor;
            [imageView setImageWithURL:[NSURL URLWithString:[dict valueForKey:@"avatar"]]];
            [cell.contentView addSubview:imageView];
            
            UILabel *lblCommentUsername = [self createLabelWithTitle:[dict valueForKey:@"screenName_s"] frame:CGRectMake(50, 0 , 285, 20) tag:1 font:[Util Font:FontTypeSemiBold Size:10.0] color:[UIColor colorWithRed:241.0/255.0 green:73.0/255.0 blue:64.0/255.0 alpha:1.0] numberOfLines:0];
            //lblCommentedUsername.backgroundColor = [UIColor blueColor];
            
            [cell.contentView addSubview:lblCommentUsername];
            
            
            NSString *strComment = [dict valueForKey:@"comment"];
            
            CGSize commentSize = [strComment sizeWithFont:[Util Font:FontTypeLight Size:11.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 40 , 200)];
            RLogs(@"Comment Height - %f", commentSize.height);
            UILabel *lblComment1 = [self createLabelWithTitle:strComment frame:CGRectMake(40, 20 ,self.frame.size.width - 40, commentSize.height) tag:1 font:[Util Font:FontTypeItalic Size:10.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:6];
            lblComment1.lineBreakMode = NSLineBreakByWordWrapping ;
            //lblComment1.backgroundColor = [UIColor orangeColor];
            
            lblComment1.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:lblComment1];
            
            NSString *strCommentedDate = [Util dateFromInterval:[dict valueForKey:@"commentedAt"] inDateFormat:DATE_TIME_FORMAT];
            
            UILabel *lblCommentedAt = [self createLabelWithTitle:[NSString stringWithFormat:@"commented at %@",strCommentedDate] frame:CGRectMake(40, lblComment1.frame.origin.y + lblComment1.frame.size.height ,self.frame.size.width - 40, 20) tag:1 font:[Util Font:FontTypeItalic Size:10.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:2];
            lblCommentedAt.lineBreakMode = NSLineBreakByWordWrapping ;
            //lblCommentedAt.backgroundColor = [UIColor greenColor];
            lblCommentedAt.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:lblCommentedAt];
            
        }
    }

   
    
    return cell;
    
}


-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y > 0){
        
        RLogs(@"targetContentOffset - %@", NSStringFromCGPoint(*targetContentOffset));
        RLogs(@"ScrollView ContentSize - %@", NSStringFromCGSize(scrollView.contentSize));
        RLogs(@"up");
        [self refreshPost];

    }
    if (velocity.y < 0){
        RLogs(@"down");
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row ==0)
    {
        
    }
    else if (indexPath.row == 1)
    {
        //Tapped on image...
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(imageTapped: withHotspots:)])
        {
            RLogs(@">>>Tapped image path - %@", self.objPost.strImgLocalPath);
            
            
            [self.delegate imageTapped:self.objPost withHotspots:arrHotSpotInfo];
        }
    }
    
    else if(indexPath.row ==2)
    {
        
        //Tapping on like button...
        
        UIView *viewimageLike = (UIView*)[self viewWithTag:3333];
        UILabel *lblNumberoflikes = (UILabel*)[self viewWithTag:123];
     

        if(self.objPost.isAlreadyLikedByUser == NO)
        {
            viewimageLike.backgroundColor = [UIColor colorWithRed:247/255.0f green:97/255.0f blue:81/255.0f alpha:0.85f];
            
            self.objPost.numberOfLikes =  self.objPost.numberOfLikes +1 ;
            lblNumberoflikes.text = [NSString stringWithFormat:@"%li likes",(long)self.objPost.numberOfLikes];
            self.objPost.isAlreadyLikedByUser = YES;
            if([self connected])
            {
                [self sendLikerequestToServer];
            }
            else
            {
                [self showNoInternetMessage];
                return;
            }
        }
        else
        {
            if(self.objPost.numberOfLikes>0)
            {
                viewimageLike.backgroundColor =[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f];
                
                if(self.objPost.numberOfLikes>0)
                {
                    self.objPost.numberOfLikes = self.objPost.numberOfLikes -1 ;
                    lblNumberoflikes.text = [NSString stringWithFormat:@"%li likes",(long)self.objPost.numberOfLikes];
                }
                self.objPost.isAlreadyLikedByUser = NO;
                if([self connected])
                {
                    if(self.objPost.numberOfLikes>0)
                    {
                        [self sendDisLikerequestToServer];
                    }
                }
                else
                {
                    [self showNoInternetMessage];
                    return;
                }
            }
            else
            {
                self.objPost.isAlreadyLikedByUser = NO;

            }
  
        }
        
    }
    
}

-(void)loadHotSpotsOfPostedImage
{
    
    if(self.objPost.isPublishedByUser == NO)
    {
        RLogs(@"<<<<<not posted by user >>>>>");
    }
    else
    {
        if(self.objPost.isExistingInDB)
            RLogs(@"<<<< Existing in DB>>>>>");
    }
    
    [self calculateAspectRatioOfImage];
    
    
    if(arrHotSpotInfo == nil)
    arrHotSpotInfo = [[NSMutableArray alloc] init];
    
    [arrHotSpotInfo removeAllObjects];
    
    /*if(self.objPost.isPublishedByUser)
    [arrHotSpotInfo addObjectsFromArray:self.objPost.arrHotspots];
    else*/
    {
        if(![self.objPost.arrHotspotsShared count])
            return;
         if([[self.objPost.arrHotspotsShared objectAtIndex:0] isKindOfClass:[NSManagedObject class]])
         {
             for(NSManagedObject *objHS in self.objPost.arrHotspotsShared)
             {
                 NSString *strHSId = [objHS valueForKey:@"hotSpotId"];
                 
                 RLogs(@"*****Shared HS Id - %@", strHSId);
                 
                 if([[self.objPost.arrHotspots objectAtIndex:0] isKindOfClass:[NSManagedObject class]])
                 {
                     for(NSManagedObject *objHotspot in self.objPost.arrHotspots)
                     {
                         if([strHSId isEqualToString:[objHotspot valueForKey:@"hId"]])
                         {
                             [arrHotSpotInfo addObject:objHotspot];
                             break;
                         }
                     }
                 }
                 else
                 {
                     for(NSDictionary *dictHotspot in self.objPost.arrHotspots)
                     {
                         if([strHSId isEqualToString:[dictHotspot valueForKey:@"hotspotId"]])
                         {
                             [arrHotSpotInfo addObject:dictHotspot];
                             break;
                         }
                     }
                 }
             }
         }
        else
        {
        for(NSDictionary *dictHS in self.objPost.arrHotspotsShared)
        {
            NSString *strHSId = [dictHS valueForKey:@"hotspotId"];
            
            RLogs(@"*****Shared HS Id - %@", strHSId);
            
            for(NSDictionary *dictHotspot in self.objPost.arrHotspots)
            {
                if([strHSId isEqualToString:[dictHotspot valueForKey:@"hotspotId"]])
                {
                    [arrHotSpotInfo addObject:dictHotspot];
                    break;
                }
            }
        }
        }
    }
    
    if(![arrHotSpotInfo count])
        return;
    if([[arrHotSpotInfo objectAtIndex:0] isKindOfClass:[NSDictionary class]])
    {
        for(NSMutableDictionary *hotspotInfo in arrHotSpotInfo)
        {
            RLogs(@"hotspotInfo - %@", [hotspotInfo description]);
            
            NSMutableDictionary *dict = [hotspotInfo valueForKey:@"location"];
            
            CGPoint centre = CGPointMake([[dict valueForKey:@"x"] integerValue], [[dict valueForKey:@"y"] integerValue]);
            NSString *strColor = @"white";

            hotSpotCircleView *hotSpot = [[hotSpotCircleView alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
            hotSpot.backgroundColor= [UIColor clearColor];
            [hotSpot addCircleImage];
            
            [hotSpot setDefaultCentre:centre];
            
            hotSpot.strLabel = [hotspotInfo valueForKey:@"hotspotLabel"];
            hotSpot.strDescText = [hotspotInfo valueForKey:@"hotspotDescription"];
            hotSpot.strUrlText = [hotspotInfo valueForKey:@"clickUrl"];
            hotSpot.isSaved = YES;
            hotSpot.strHotspotId = [hotspotInfo valueForKey:@"hotspotId"];
            hotSpot.addedInZoomScale = [(NSNumber*)[hotspotInfo valueForKey:@"zoomFactor"] floatValue];
            
            
            RLogs(@">>>zoom22 - %f", (float)[[hotspotInfo valueForKey:@"zoomFactor"] floatValue]);
            
            RLogs(@">>>zoom32 - %f", (float)hotSpot.addedInZoomScale);
            
            RLogs(@"Hotspot desc - %@ , %@", [hotspotInfo valueForKey:@"hotspotLabel"],[hotspotInfo valueForKey:@"clickUrl"]);
            
            if([hotSpot.strUrlText isEqualToString:@""])
                hotSpot.strUrlText = @"http://www.";
            
            if(![hotSpot.strLabel isEqualToString:@""])
                [hotSpot updateTitle:hotSpot.strLabel];
            
            if([[[dictPostData valueForKey:@"pod"] valueForKey:@"orientation"] isEqualToString:@"portrait"])
            {
                [hotSpot setOrientationToPortrait];
            }
            else
            {
                [hotSpot setOrientationToLandscape];
            }
            strColor = [[hotspotInfo valueForKey:@"markerColor"] lowercaseString];
            
            RLogs(@"prestrColor - %@", strColor);
            
            if([strColor isEqualToString:@"red"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [hotSpot setRedColor];
            }
            else if ([strColor isEqualToString:@"white"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [hotSpot setWhiteColor];
                
            }
            else if ([strColor isEqualToString:@"blue"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [hotSpot setBlueColor];
                
            } else if ([strColor isEqualToString:@"yellow"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [hotSpot setYellowColor];
                
            }
            else
            {
                RLogs(@"strColor - %@", strColor);
                
                [hotSpot setWhiteColor];
                
            }
            
            CGSize imagSize;
            imagSize = CGSizeMake(selectedImg.size.width, selectedImg.size.height);
            // imagSize = CGSizeMake(self.pickedImage.size.width, self.pickedImage.size.height);
            
            if(imagSize.width == 0.0 || imagSize.height == 0.0)
            {
                return;
            }
            
            CGPoint newCentre;
            
            
            RLogs(@">>>imgsize - %@", NSStringFromCGSize(imagSize));
            RLogs(@">>>imageExactSubView frame - %@", NSStringFromCGRect(imageExactSubView.frame));
            RLogs(@">>>centre - %@", NSStringFromCGPoint(centre));

            
            if(APP_DELEGATE.isPortrait)
            {
                
                
                newCentre.x = (imageExactSubView.frame.size.width / imagSize.width) * centre.x;
                newCentre.y = (imageExactSubView.frame.size.height / imagSize.height) * centre.y;
                
            }
            else
            {
                newCentre.x = (imgBoundsAtNormalZoomInLandScape.width / imagSize.width) * centre.x;
                newCentre.y = (imgBoundsAtNormalZoomInLandScape.height / imagSize.height) * centre.y;
            }
            
          
            hotSpot.center = newCentre;
            
            hotSpot.isSaved = YES;
            
            [imageExactSubView addSubview:hotSpot];
            
            
            //     if(imageExactSubView == nil)
            RLogs(@"imageExactSubView is nil");
            //   [imageExactSubView addSubview:hotSpot];
            
            
        }

    }
    else
    {
        for(NSManagedObject *hotspotInfo in arrHotSpotInfo)
        {
            RLogs(@"hotspotInfo - %@", [hotspotInfo description]);
            
            NSString *strColor = @"white";
            
            CGPoint centre = CGPointMake([[hotspotInfo valueForKey:@"xCoordinate"] integerValue], [[hotspotInfo valueForKey:@"yCoordinate"] integerValue]);
            hotSpotCircleView *hotSpot = [[hotSpotCircleView alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
            hotSpot.backgroundColor= [UIColor clearColor];
            [hotSpot addCircleImage];
            
            [hotSpot setDefaultCentre:centre];
            
            hotSpot.strLabel = [hotspotInfo valueForKey:@"strLabel"];
            hotSpot.strUrlText = [hotspotInfo valueForKey:@"url"];
            hotSpot.isSaved = YES;
            hotSpot.strHotspotId = [hotspotInfo valueForKey:@"hId"];
            hotSpot.addedInZoomScale = [(NSNumber*)[hotspotInfo valueForKey:@"zoomFactor"] floatValue];

            
            RLogs(@">>>zoom23 - %f", (float)[[hotspotInfo valueForKey:@"zoomFactor"] floatValue]);
            
            RLogs(@">>>zoom33 - %f", (float)hotSpot.addedInZoomScale);
            
            if([hotSpot.strUrlText isEqualToString:@""])
                hotSpot.strUrlText = @"http://www.";
            
            if([hotSpot.strLabel isEqualToString:@""])
                hotSpot.strLabel = @"Label";
            
            if([[hotspotInfo valueForKey:@"orientation"] isEqualToString:@"portrait"])
            {
                [hotSpot setOrientationToPortrait];
            }
            else
            {
                [hotSpot setOrientationToLandscape];
            }
            
            if(![hotSpot.strLabel isEqualToString:@""])
                [hotSpot updateTitle:hotSpot.strLabel];
            
            
            
            strColor = [[hotspotInfo valueForKey:@"hotspotColor"] lowercaseString];
            
            RLogs(@"prestrColor - %@", strColor);
            
            if([strColor isEqualToString:@"red"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [hotSpot setRedColor];
            }
            else if ([strColor isEqualToString:@"white"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [hotSpot setWhiteColor];
                
            }
            else if ([strColor isEqualToString:@"blue"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [hotSpot setBlueColor];
                
            } else if ([strColor isEqualToString:@"yellow"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [hotSpot setYellowColor];
                
            }
            else
            {
                RLogs(@"strColor - %@", strColor);
                
                [hotSpot setWhiteColor];
                
            }

            
            
            CGSize imagSize;
            imagSize = CGSizeMake(selectedImg.size.width, selectedImg.size.height);
            // imagSize = CGSizeMake(self.pickedImage.size.width, self.pickedImage.size.height);
            
            RLogs(@"###image size - %@", NSStringFromCGSize(imagSize));
            
            if(selectedImg == nil)
                RLogs(@"selected img is nil");
            
            CGPoint newCentre;
            if(APP_DELEGATE.isPortrait)
            {
                
                
                newCentre.x = (imgBoundsAtNormalZoomInPortrait.width / imagSize.width) * centre.x;
                newCentre.y = (imgBoundsAtNormalZoomInPortrait.height / imagSize.height) * centre.y;
                
            }
            else
            {
                newCentre.x = (imgBoundsAtNormalZoomInLandScape.width / imagSize.width) * centre.x;
                newCentre.y = (imgBoundsAtNormalZoomInLandScape.height / imagSize.height) * centre.y;
            }
            
            hotSpot.center = newCentre;
            
            hotSpot.isSaved = YES;
            
            [imageExactSubView addSubview:hotSpot];
            
            
            //     if(imageExactSubView == nil)
            RLogs(@"imageExactSubView is nil");
            //   [imageExactSubView addSubview:hotSpot];
            
            
        }

      }
}


-(void)loadQuestionsOfPostedImg
{
    //   [self calculateAspectRatioOfImage];
    
    RLogs(@"imageview:%@",hotspotImageVw);
    
    NSArray *arrQuestionInfo = self.objPost.arrQuestions;
    RLogs(@"array questions:%@",arrQuestionInfo);
    
    NSString *strColor = @"";
    
    if(![arrQuestionInfo count])
        return;
    if([[arrQuestionInfo objectAtIndex:0] isKindOfClass:[NSDictionary class]])
    {
        for(NSMutableDictionary *questionInfo in arrQuestionInfo)
        {
            RLogs(@"hotspotInfo - %@", [questionInfo description]);
            
            NSMutableDictionary *dict = [questionInfo valueForKey:@"location"];
            
            CGPoint centre = CGPointMake([[dict valueForKey:@"x"] integerValue], [[dict valueForKey:@"y"] integerValue]);
            questionView *questionVw = [[questionView alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
            questionVw.backgroundColor= [UIColor clearColor];
            
            questionVw.strAudioUrl = [questionInfo valueForKey:@"audioUrl"];
            
            [questionVw addCircleImage];
            
            [questionVw setDefaultCentre:centre];
            
            //    hotSpot.strLabel = [hotspotInfo valueForKey:@"hotspotLabel"];
            //    hotSpot.strDescText = [hotspotInfo valueForKey:@"strDescription"];
            //     hotSpot.strUrlText = [hotspotInfo valueForKey:@"clickUrl"];
            questionVw.isSaved = YES;
            
            //       RLogs(@"Hotspot desc - %@ , %@", [hotspotInfo valueForKey:@"hotspotLabel"],[hotspotInfo valueForKey:@"clickUrl"]);
            
            if([questionVw.strUrlText isEqualToString:@""])
                questionVw.strUrlText = @"http://www.";
            
            if(![questionVw.strLabel isEqualToString:@""])
                [questionVw updateTitle:questionVw.strLabel];
            
            if([[[dictPostData valueForKey:@"pod"] valueForKey:@"orientation"] isEqualToString:@"portrait"])
            {
                [questionVw setOrientationToPortrait];
            }
            else
            {
                [questionVw setOrientationToLandscape];
            }
            
            strColor = [[questionInfo valueForKey:@"locationColor"] lowercaseString];
            
            RLogs(@"prestrColor - %@", strColor);
            
            if([strColor isEqualToString:@"red"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [questionVw setRedColor];
            }
            else if ([strColor isEqualToString:@"white"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [questionVw setWhiteColor];
                
            }
            else if ([strColor isEqualToString:@"blue"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [questionVw setBlueColor];
                
            } else if ([strColor isEqualToString:@"yellow"])
            {
                RLogs(@"strColor - %@", strColor);
                
                [questionVw setYellowColor];
                
            }
            else
            {
                RLogs(@"strColor - %@", strColor);
                
                [questionVw setWhiteColor];
                
            }

            
            
            CGSize imagSize;
            imagSize = CGSizeMake(selectedImg.size.width, selectedImg.size.height);
            // imagSize = CGSizeMake(self.pickedImage.size.width, self.pickedImage.size.height);
            
            if(imagSize.width == 0.0 || imagSize.height == 0.0)
            {
                return;
            }
           

            CGPoint newCentre;
            
            
            RLogs(@">>>imgsize - %@", NSStringFromCGSize(imagSize));
            RLogs(@">>>imageExactSubView frame - %@", NSStringFromCGRect(imageExactSubView.frame));
            RLogs(@">>>centre - %@", NSStringFromCGPoint(centre));
            
            
            if(APP_DELEGATE.isPortrait)
            {
                
                
                newCentre.x = (imageExactSubView.frame.size.width / imagSize.width) * centre.x;
                newCentre.y = (imageExactSubView.frame.size.height / imagSize.height) * centre.y;
                
            }
            else
            {
                newCentre.x = (imgBoundsAtNormalZoomInLandScape.width / imagSize.width) * centre.x;
                newCentre.y = (imgBoundsAtNormalZoomInLandScape.height / imagSize.height) * centre.y;
            }
            
            
            questionVw.center = newCentre;
            
            questionVw.isSaved = YES;
            
            
            [imageExactSubView addSubview:questionVw];
            
            
            //     if(imageExactSubView == nil)
            RLogs(@"imageExactSubView is nil");
            //   [imageExactSubView addSubview:hotSpot];
            
            
        }
        
    }
    
}

#pragma mark Calculating Image Size

-(void)calculateAspectRatioOfImage
{
    
    //Here we are calculating the actual image area occupying and adding an UIView over the scrollVIew to add Hotspots.
    
    if(selectedImg != nil && hotspotImageVw!= nil)
    {
 //   float aspectRatio = 1.0;
    
    CGSize imageOriginalSize = selectedImg.size;
    
    CGSize imageViewSize = hotspotImageVw.frame.size;
    
    RLogs(@"############### imageViewSize - %@", NSStringFromCGSize(imageViewSize));
    
    CGSize finalImageSize;
    
    float xRatio =  imageOriginalSize.width / imageViewSize.width ;
    
    float yRatio = imageOriginalSize.height / imageViewSize.height;
    
   // aspectRatio = MIN(xRatio, yRatio);
    
    if(xRatio >= yRatio)
    {
        finalImageSize.width = imageViewSize.width;
        
        finalImageSize.height = imageOriginalSize.height * (imageViewSize.width / imageOriginalSize.width);
    }
    else
    {
        finalImageSize.height = imageViewSize.height;
        
        finalImageSize.width = imageOriginalSize.width * (imageViewSize.height / imageOriginalSize.height);
    }
    
    
    RLogs(@"imageOriginalSize - %@", NSStringFromCGSize(imageOriginalSize));
    
    RLogs(@"Aspect image Size - %@", NSStringFromCGSize(hotspotImageVw.image.size));
    
    
    if(!imageExactSubView.superview)
    {
        ImageOccupyView *aView = [[ImageOccupyView alloc] init];
        
        [aView setFrame:CGRectMake(0, 0, finalImageSize.width, finalImageSize.height)];
        
        [aView setBackgroundColor:[UIColor clearColor]];
        
        aView.tag = 111111;
        
        aView.center = hotspotImageVw.center;
        
        //      [_scrlImgView addSubview:aView];
        
              [hotspotImageVw addSubview:aView];
              imageExactSubView = aView;
    }
    else
    {
        [imageExactSubView setFrame:CGRectMake(0, 0, finalImageSize.width, finalImageSize.height)];
        imageExactSubView.center = hotspotImageVw.center;
        
        
    }
    
    
    
    aspectFitSize = finalImageSize;
    
    //imageBounds = CGRectMake((_scrlImgView.frame.size.width - finalImageSize.width)/2, (_scrlImgView.frame.size.height - finalImageSize.height)/2, finalImageSize.width, finalImageSize.height);
    
    imageBounds = CGSizeMake(finalImageSize.width, finalImageSize.height);
    
    //Here we are calculating the image occupying area in both Orientations Portrait and Landscape. Base on these sizes we are repositioning hotspots to their relative positions when device is rotated.
    
    if(APP_DELEGATE.isPortrait)
    {
        imgBoundsAtNormalZoomInPortrait = CGSizeMake(finalImageSize.width, finalImageSize.height);
        
    }
    else
    {
        imgBoundsAtNormalZoomInLandScape = CGSizeMake(finalImageSize.width, finalImageSize.height);
    }
    
    
    RLogs(@"Bounds Size - %@, Portrait -%@, Landscape - %@",NSStringFromCGSize(imageBounds), NSStringFromCGSize(imgBoundsAtNormalZoomInPortrait), NSStringFromCGSize(imgBoundsAtNormalZoomInLandScape));
    preImageViewSize = hotspotImageVw.frame.size;
    }
    
}


#pragma mark webservice calls

-(void)getDetailsOfPostIncludingCommentswithPostId:(NSString*)postId
{
    NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
    
    
    [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPostComments setValue:postId forKey:@"rpostid_s"];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/post",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSLog(@"post details  response:%@",responseObject);
         
        if([[responseObject valueForKey:@"error"]length]==0)
         {
             NSDictionary *dictPostDetails = (NSDictionary*)responseObject;
             
             NSDictionary *dictPodData =[dictPostDetails valueForKey:@"pod"];
             
             NSDictionary *dictPodImageData = [dictPodData valueForKey:@"podImage"];

             self.objPost.strAvatarUrl = [dictPostDetails valueForKey:@"avatar"];
             
             self.objPost.strScreenName = [dictPostDetails valueForKey:@"screenName_s"];
             
             self.objPost.strPostId = [dictPostDetails valueForKey:@"rpostid_s"];
             
             self.objPost.strPodId = [dictPostDetails valueForKey:@"rpid_s"];
             
             self.objPost.strImgid = [dictPodImageData valueForKey:@"imgId"];
             
             self.objPost.strImgUrl = [dictPodImageData valueForKey:@"baseUrl"];
             
             RLogs(@">>>Localpath - %@", self.objPost.strImgLocalPath);
             
             self.objPost.strImgLocalPath = [NSString stringWithFormat:@"%@/%@",self.objPost.strImgLocalPath,[self.objPost.strImgUrl lastPathComponent]];
             RLogs(@">>>Localpath - %@", self.objPost.strImgLocalPath);
             
             
             
             self.objPost.arrHotspots = [[dictPostDetails valueForKey:@"pod"] valueForKey:@"hotspots"];
             
             self.objPost.strPictureTakenLocation = [[dictPostDetails valueForKey:@"pod"]valueForKey:@"location"];
             
             self.objPost.strPostTitle = [dictPostDetails valueForKey:@"postDescription"];
             
             self.objPost.arrQuestions  = [self checkAndRetrieveQuestionsIfAnyPostedByThisUser:dictPostDetails];
             if([self.objPost.arrQuestions count] >0)
             {
                 isHavingQuestions = YES;
             }
             
             self.objPost.createdAt = (NSString*)[dictPostDetails valueForKey:@"createdAt"];
             
          //   self.objPost.aryHotspotComments = [dictPostDetails valueForKey:@"hotspotComments"];
             
             NSMutableArray *arrCommentsWithRating = [self sortCommentsAndRatings:[dictPostDetails valueForKey:@"hotspotComments"] andRating:[dictPostDetails valueForKey:@"hotspotRatings"] withHotspots:self.objPost.arrHotspots];
             
             self.objPost.pictureTakenOn  =(NSString*)[dictPodImageData valueForKey:@"takenAt"];
             
             self.objPost.aryHotspotComments = arrCommentsWithRating;
             
             if([self.objPost.aryHotspotComments count])
             {
                 isHavingHotspotComments = YES;
                 aryHotspotComments = [self.objPost.aryHotspotComments mutableCopy];

             }
             else
                 isHavingHotspotComments = NO;
             RLogs(@"///created Date2 - %@", self.objPost.createdAt);

            
             self.objPost.isExistingInDB = YES;
             
             self.objPost.arrComments = nil;
             
             self.objPost.arrComments = [dictPostDetails valueForKey:@"podComments"];
             RLogs(@"Published value - %@", [dictPodData description]);
            /* if([[dictPodData valueForKey:@"published_s"] integerValue])
             {
                 RLogs(@"User published");
                 self.objPost.isPublishedByUser = YES;
             }
             else
             {
                 RLogs(@"User Not published");

                 self.objPost.isPublishedByUser = NO;
             }*/
             
             self.objPost.numberOfLikes = [[dictPostDetails valueForKey:@"likes"] count];
             [self checkWhetherUserHasAlreadyLikedThisPost:[dictPostDetails valueForKey:@"likes"]];
             
             
             numberOfLikes = [[dictPostDetails valueForKey:@"likes"] count];
             
             self.objPost.strOrientation = [dictPostDetails valueForKey:@"orientation"];
             

             self.objPost.arrHotspotsShared = [dictPostDetails valueForKey:@"hotspotsShared"];
             
            // [subMenuTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
             [subMenuTableView reloadData];
             
             
             if([self.objPost isPublishedByUser])
             {
                 [Util_HotSpot saveImageData:self.objPost];
                 [Util_HotSpot savePodData:self.objPost];
                 [Util_HotSpot saveHotspotData:self.objPost];
                 [Util_HotSpot savePostData:self.objPost];
                 [Util_HotSpot saveHotspotsSharedData:self.objPost];
           //      [Util_HotSpot saveCommentData:self.objPost];
                 
             }
        
         }
         
         if(self.objPost == nil)
         {
             NSLog(@"####getDetail post is nil");
             return;
         }
         
         if(self.delegate != nil && [self.delegate respondsToSelector:@selector(downloadedPost:)])
          {
              [self.delegate downloadedPost:self.objPost];
          }

         
        
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post Error: %@", error);
    //          [self removeLoader];
  //            [self showTheAlert:error.description];
              
              /*if(self.delegate != nil && [self.delegate respondsToSelector:@selector(deletePostAserrorOccured:)])
              {
                  [self.delegate deletePostAserrorOccured:self.objPost];
              }*/

              
              
          }];
    

}

-(void)checkWhetherUserHasAlreadyLikedThisPost:(NSArray*)arrLikedUsers
{
    
    if([arrLikedUsers count] == 0 )
        self.objPost.isAlreadyLikedByUser = NO;
        
    NSString *strCurrentUserId = [Util getNewUserID];

    for(NSString *strUserId in arrLikedUsers)
    {
        if([strUserId isEqualToString:strCurrentUserId])
        {
            self.objPost.isAlreadyLikedByUser = YES;
            break;
            
        }
        else
        {
            self.objPost.isAlreadyLikedByUser = NO;
 
        }
    }
    
}


-(NSArray*)checkAndRetrieveQuestionsIfAnyPostedByThisUser:(NSDictionary*)dictPostDetails
{
    NSArray *arrQuestions = [dictPostDetails valueForKey:@"questions"];
    
    if(self.objPost.isPublishedByUser)
        return arrQuestions;
    
    NSMutableArray *arrQuestionsPostedByThisUser;
    
    NSString *strCurrentUserId = [Util getNewUserID];
    
    
    for(NSDictionary *dictQuestion in arrQuestions)
    {
        if([strCurrentUserId isEqualToString:[dictQuestion valueForKey:@"postedBy"]])
        {
            if(arrQuestionsPostedByThisUser == nil)
                arrQuestionsPostedByThisUser = [[NSMutableArray alloc] init];
            
            [arrQuestionsPostedByThisUser addObject:dictQuestion];
        }
    }
    
    return arrQuestionsPostedByThisUser;
    
}


-(void)sendLikerequestToServer
{
    
    NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
    
    [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPostComments setValue:self.objPost.strPostId forKey:@"rpostid_s"];
    
    [dictPostComments setValue:self.objPost.strScreenName forKey:@"screenName_s"];
    
    [dictPostComments setValue:self.objPost.strPodId forKey:@"rpid_s"];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/like",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"like response:%@",responseObject);
         
        
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"like Error: %@", error);
              //   [self showTheAlert:error.description];
              
              
          }];
    
    
}

-(void)sendDisLikerequestToServer
{
   
    NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
    
    [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPostComments setValue:self.objPost.strPostId forKey:@"rpostid_s"];
    
    [dictPostComments setValue:self.objPost.strScreenName forKey:@"screenName_s"];
    
    [dictPostComments setValue:self.objPost.strPodId forKey:@"rpid_s"];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/dislike",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"dislike response:%@",responseObject);
         
         if([[responseObject valueForKey:@"status"] isEqualToString:@"success"])
         {
     
             
             
         }
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"like Error: %@", error);
              //    [self showTheAlert:error.description];®
              
              
          }];
    
}

-(void)deleteOrHidePost
{
    NSString *strAlert = @"";
    if(self.objPost.isPublishedByUser)
    {
         strAlert = @"Are you sure you want to delete?";
    }
    else
    {
        strAlert = @"Are you sure you want to hide?";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rnyoo" message:strAlert delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 111;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 111)
    {
        if(buttonIndex == 1)
        {
            if(self.objPost.isPublishedByUser)
            {
                if(self.delegate != nil && [self.delegate respondsToSelector:@selector(postDelete:)])
                {
                    [self.delegate postDelete:self.objPost];
                }
            }
            else
            {
                if(self.delegate != nil && [self.delegate respondsToSelector:@selector(postHide:)])
                {
                    [self.delegate postHide:self.objPost];
                }
            }
        }
    }
}


-(void)sendCommentToServerwithComment:(NSString*)comment withObj:(postBO*)postObj
{
    
    NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
    
    [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPostComments setValue:postObj.strPostId forKey:@"rpostid_s"];
    
    [dictPostComments setValue:[Util getScreenName] forKey:@"screenName_s"];
    
    if(postObj.strPodId.length)
    [dictPostComments setValue:postObj.strPodId forKey:@"rpid_s"];
    else
        [dictPostComments setValue:@"" forKey:@"rpid_s"];

    [dictPostComments setValue:comment forKey:@"comment"];
    
    RLogs(@"Comment Request - %@", [dictPostComments description]);
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/pods/comments/new",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"post comment response:%@",responseObject);
         
         isCommentedNow = YES;

         if([[responseObject valueForKey:@"podComments"] count] >0)
         {
             NSMutableDictionary *dictComment = [[NSMutableDictionary alloc]init];
             
             NSDictionary *dictLastComment = [[responseObject valueForKey:@"podComments"]lastObject];
             
             [dictComment  setValue:[dictLastComment valueForKey:@"comment" ]forKey:@"comment"];
            
             [dictComment setValue:[Util getImgUrl] forKey:@"avatar"];
             
             [dictComment setValue:[Util getScreenName] forKey:@"screenName_s"];
             
             [dictComment setValue:[dictLastComment valueForKey:@"uid_s"] forKey:@"uid_s"];
             
             [dictComment setValue:[dictLastComment valueForKey:@"commentedAt"] forKey:@"commentedAt"];
             
             [dictComment setValue:postObj.strPostId forKey:@"postId"];
           
             [Util_HotSpot saveCommentsData:dictComment];

         if(postObj.arrComments == nil)
             postObj.arrComments = [[NSMutableArray alloc] init];
         NSMutableArray *aryCommentData = [postObj.arrComments mutableCopy];
         [aryCommentData  addObject:dictComment];
         
         RLogs(@"before comments count:%lu",(unsigned long)[self.objPost.arrComments count]);
         
         self.objPost.arrComments = nil;
         
         self.objPost.arrComments = aryCommentData;

         RLogs(@"after comments count:%lu",(unsigned long)[self.objPost.arrComments count]);

      
         [subMenuTableView reloadData];
             
             [subMenuTableView setContentOffset:CGPointMake(subMenuTableView.contentOffset.x, subMenuTableView.contentSize.height - subMenuTableView.frame.size.height) animated:YES];
             
         
         
         NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
         [nc postNotificationName:@"Comment" object:nil userInfo:(NSDictionary*)[responseObject valueForKey:@"podComments"]];
         }
         

     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post comment Error: %@", error);
          //   [self showTheAlert:error.description];
              
              
          }];
    
    
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


#pragma mark Image Download
-(void)downloadImageFromUrl:(NSString*)strUrl toPath:(NSString*)strPath
{
    RLogs(@"URL path  - %@, %@", strUrl, strPath);
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:strUrl forKey:@"url"];
    [dict setObject:strPath forKey:@"path"];
    [self performSelectorInBackground:@selector(downloadImage:) withObject:dict];
}

-(void)downloadImage
{
    
    NSString *strUrl = self.objPost.strImgUrl;
    NSString *strPath = self.objPost.strImgLocalPath;
    
    
    if(strUrl != nil && strUrl.length > 0 && (NSNull*)strUrl != [NSNull null])
    {
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            NSData *webPdata =  [NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
            
            if(webPdata == nil)
            {
                NSLog(@"Image data is nil");
                [self downloadImage];
                return;
            }
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                
                if([[NSFileManager defaultManager] fileExistsAtPath:strPath])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:strPath error:nil];
                }
                
                NSError * error = nil;
                
                BOOL success = [webPdata writeToFile:strPath options:NSDataWritingAtomic error:&error];
                
                if(error)
                {
                    RLogs(@"error description - %@", [error description]);
                }
                
                if(!success)
                {
                    RLogs(@"######Image save failed as there is folders missing. So created vault path with imagename and saving in that path");
                    self.objPost.strImgLocalPath = [self getFilePathwithFileName:[self.objPost.strImgUrl lastPathComponent] inFolder:VAULT_FOLDER];
                    
                    success = [webPdata writeToFile:self.objPost.strImgLocalPath options:NSDataWritingAtomic error:&error];
                    
                    if(success)
                    {
                        RLogs(@"success");
                    }
                }
               // [hotspotImageVw setImage:[UIImage imageWithWebPData:webPdata]];
                
                [hotspotImageVw setImage:[UIImage imageWithWebPAtPath:self.objPost.strImgLocalPath]];

                selectedImg = hotspotImageVw.image;
                RLogs(@"strpath - %@", strPath);
                
                RLogs(@"postImgPath - %@", self.objPost.strImgLocalPath);
                [self performSelectorOnMainThread:@selector(loadHotSpotsOfPostedImage) withObject:nil waitUntilDone:YES];
                
                  [self performSelectorOnMainThread:@selector(loadQuestionsOfPostedImg) withObject:nil waitUntilDone:YES];
                
            });
        });
        
    }
    
}

-(void)setImageAndLoadHotspots
{
    
    [self loadHotSpotsOfPostedImage];

}


#pragma mark To Create FilePath
-(NSString*)getFilePathwithFileName:(NSString*)fileName inFolder:(NSString*)folderName
{
    BOOL success = [self checkOrCreateFolder:folderName];
    if(!success)
    {
        RLogs(@">>>>folder not created successfullly<<<<");
    }
    NSString *filePath = [[[Util sandboxPath] stringByAppendingPathComponent:folderName]stringByAppendingPathComponent:fileName];
    
    return filePath;
}

-(BOOL)checkOrCreateFolder:(NSString*)fldName{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *folderPath = [path stringByAppendingPathComponent:fldName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        return YES;
    }
    else{
        if ([[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil]){
            return YES;
        }
        else{
            return NO;
        }
    }
    return YES;
}

// cheecking for duplicates based on postId(postedBy)for questions

-(BOOL)checkForDuplicatesofQuestionsPostedBy:(NSDictionary*)dict
{
    if([[strQuestionedPostId lowercaseString] isEqualToString:[[dict valueForKey:@"postedBy"]lowercaseString]])
    {
        return YES;
    }
    else
        return NO;
    
    return NO;
}


- (BOOL)connected {
    
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
    
}

-(void)showNoInternetMessage
{
    UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:@"Rnyoo" message:@"Please check internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(NSMutableArray*)sortCommentsAndRatings:(NSArray*)aryHotspotComment andRating:(NSArray*)aryHotspotRating withHotspots:(NSArray*)arrHotspots
{
    NSMutableArray *arrHotspotComment = [[NSMutableArray alloc]init];
    NSMutableArray *arrHotspotRating = [[NSMutableArray alloc]init];
    BOOL isExists = NO;
    NSMutableArray *arrHotspotwithComemntAndRating = [[NSMutableArray alloc]init];
    
    for(NSDictionary *dictHotspot in arrHotspots)
    {
        [arrHotspotComment removeAllObjects];
        [arrHotspotRating removeAllObjects];
        
        NSArray *aryHotspoComments = [aryHotspotComment filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hotspotId == %@",[dictHotspot valueForKey:@"hotspotId"]]];
        
        for(NSMutableDictionary *dict in aryHotspoComments)
        {
            [arrHotspotComment addObjectsFromArray:[dict valueForKey:@"comments"]];
            
        }
        
        NSLog(@"before ary comments:%@",arrHotspotComment);
        
        NSArray *aryHotspoRate = [aryHotspotRating filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hotspotId == %@",[dictHotspot valueForKey:@"hotspotId"]]];
        
        for(NSDictionary *dict in aryHotspoRate)
        {
            [arrHotspotRating addObjectsFromArray:[dict valueForKey:@"ratings"]];
            
        }
        
        NSInteger rating = 0;
        NSMutableArray *arrRating = [[NSMutableArray alloc]init];
        NSMutableArray *arrComments = [[NSMutableArray alloc]init];
        
        
        for(NSMutableDictionary *dictHSComment in arrHotspotComment)
        {
            [arrRating removeAllObjects];
            [arrComments removeAllObjects];
            isExists = NO;
            for(NSMutableDictionary *dictRating in arrHotspotRating)
            {
                NSLog(@"screen name:%@",[dictHSComment valueForKey:@"screenName_s"]);
                //            if([arrHotspotwithComemntAndRating containsObject:dictRating])
                //           // if([strPreviousUserId length]>0 && [strPreviousUserId isEqualToString:[dictRating valueForKey:@"uid_s"]])
                //            {
                //                isExists = YES;
                //                break;
                //            }
                if([[dictRating valueForKey:@"uid_s"] isEqualToString:[dictHSComment valueForKey:@"uid_s"]])
                {
                    [arrRating addObject:dictRating];
                    [arrComments addObject:dictHSComment];
                    
                }
            }
            //     strPreviousUserId = [dictHSComment valueForKey:@"uid_s"];
            if([arrRating count])
            {
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"ratedAt" ascending:YES];
                
                NSMutableArray *arrSortedImages = [[NSMutableArray alloc]initWithArray:[arrRating sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]]];
                
                NSLog(@"array:%@",[arrSortedImages lastObject]);
                rating =[[[arrSortedImages lastObject]valueForKey:@"rating"] integerValue];
                
            }
            if(!isExists)
            {
                for(NSMutableDictionary *dict in arrComments)
                {
                    NSMutableDictionary *tempDict;// = [[NSMutableDictionary alloc] init];
                    tempDict = [dict mutableCopy];
                    [tempDict setObject:[dictHotspot valueForKey:@"hotspotId"] forKey:@"hotspotId"];
                    [tempDict setObject:[NSNumber numberWithInteger:rating] forKey:@"rating"];
                    [arrHotspotwithComemntAndRating addObject:tempDict];
                }
                
            }
        }
        
        if([arrHotspotRating count] == 0)
        {
            for(NSMutableDictionary *dict in arrHotspotComment)
            {
                NSMutableDictionary *tempDict;// = [[NSMutableDictionary alloc] init];
                tempDict = [dict mutableCopy];
                [tempDict setObject:[dictHotspot valueForKey:@"hotspotId"] forKey:@"hotspotId"];
                [tempDict setObject:[NSNumber numberWithInteger:rating] forKey:@"rating"];
                [arrHotspotwithComemntAndRating addObject:tempDict];
            }
        }
    }
    NSLog(@"aafter%@",arrHotspotComment);
    NSLog(@"aafter new%@",arrHotspotwithComemntAndRating);
    
    
    NSLog(@"after duplicates:%@",[NSSet setWithArray:[arrHotspotwithComemntAndRating copy]]);
    
    NSOrderedSet *mySet = [[NSOrderedSet alloc] initWithArray:arrHotspotwithComemntAndRating];
    NSMutableArray *aryData = [[NSMutableArray alloc] initWithArray:[mySet array]];
    
    
    
    return aryData;
    
}

@end
