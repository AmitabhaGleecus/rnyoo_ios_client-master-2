//
//  HotspotCommentViewController.m
//  Rnyoo
//
//  Created by Thirupathi on 05/02/15.
//  Copyright (c) 2015 Suvarna. All rights reserved.
//

#import "HotspotCommentViewController.h"
#import "Constants.h"
#import "HotspotCustomCell.h"
#import "Util_HotSpot.h"

@interface HotspotCommentViewController ()
{
    UITapGestureRecognizer *tblTapGesture;
    NSMutableArray *aryHotspotComments;
}
@end

@implementation HotspotCommentViewController
@synthesize strHotspotId,context,tblComments,strPostId,strPodId,objHsCircleView,numberOfRatings;

@synthesize aryComments;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    context = [APP_DELEGATE managedObjectContext];
    
    aryHotspotComments = [[NSMutableArray alloc]init];
    tblComments.delegate = self;
    tblComments.dataSource = self;
    tblComments.separatorColor = [UIColor clearColor];
    tblTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToResignKeyBoard)];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:)
                                                 name:UIKeyboardDidChangeFrameNotification object:self.view.window];
    
  //  [self refreshView];
    
    RLogs(@"array of hotspot comments:%@",aryComments);
    
      NSArray *aryHotspoComments = [aryComments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hotspotId == %@",self.strHotspotId]];
    
    aryHotspotComments = [aryHotspoComments mutableCopy];
//    NSMutableArray *arrHotspotComment = [[NSMutableArray alloc]init];
//    
//    for(NSDictionary *dict in aryHotspoComments)
//    {
//        [arrHotspotComment addObjectsFromArray:[dict valueForKey:@"comments"]];
//    }
//    
//    for(NSDictionary *dict in aryHotspoComments)
//    {
//        NSMutableDictionary *dictInfo = [[NSMutableDictionary alloc]init];
//        [dictInfo setObject:@"NO" forKey:@"isCommented"];
//        [dictInfo setObject:[dict valueForKey:@"avatar"] forKey:@"avatar"];
//        [dictInfo setObject:[dict valueForKey:@"comment"] forKey:@"comment"];
//        [dictInfo setObject:[dict valueForKey:@"screenName_s"] forKey:@"screenName_s"];
//        [dictInfo setObject:[dict valueForKey:@"commentedAt"] forKey:@"commentedAt"];
//
//        [aryHotspotComments addObject:dictInfo];
//
//    }
    
    if([aryHotspoComments count]==0)
       [self refreshView];
    
    
    [tblComments reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self setNavigationBarTitle:@"Comments"];
    [self setLeftBarButtonOnNavigationBarAsBackButton];
    
}


-(void)refreshView
{
    NSArray *aryComments1 = [Util_HotSpot getHotspotCommentsDatawithHotspotId:self.strHotspotId podId:self.strPodId];
    RLogs(@"comments data from db: %@",aryComments1);
    aryComments = [aryComments1 mutableCopy];
    [tblComments reloadData];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    if([Util isIOS8])
    {
        if(self.view.frame.size.width > self.view.frame.size.height)
            APP_DELEGATE.isPortrait = NO;
        else
            APP_DELEGATE.isPortrait = YES;
    }
    else{
        if (APP_DELEGATE.isPortrait) {
            self.tableViewTopConstraint.constant = 0;
        }
        else{
            self.tableViewTopConstraint.constant = 0;
        }
    }
    
    [self.tblComments reloadData];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark KeyBoard Notifications
-(void)keyboardDidShow:(NSNotification*)notification
{
    RLogs(@"keyboardDidShow - %@", [notification.userInfo description]);
    
    
    
    CGFloat height;
    
    CGRect keyBoardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if(APP_DELEGATE.isPortrait)
        height = keyBoardRect.size.height;
    else
        height = keyBoardRect.size.height;
    
    
    RLogs(@"height - %f", height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    //self.view.center = CGPointMake(self.view.center.x, ((keyBoardRect.origin.y + keyBoardRect.size.height) / 2) - height);
    
    _btmView.center = CGPointMake(_btmView.center.x, _btmView.center.y - height);
    
    [tblComments addGestureRecognizer:tblTapGesture];
    
    [UIView commitAnimations];
    
    
    
    
}

-(void)keyboardFrameChanged:(NSNotification*)notification
{
    
}
-(void)keyboardWillBeHidden:(NSNotification*)notification
{
    RLogs(@"keyboardWillBeHidden");
    
    RLogs(@"keyboardWillBeHidden - %@", [notification.userInfo description]);
    
    
    CGFloat height;
    height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    
    
    RLogs(@"height - %f", height);
    
    RLogs(@"Before Bottom View Centre - %@", NSStringFromCGPoint(_btmView.center));
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    //self.view.center = CGPointMake(self.view.center.x, self.view.center.y + height);
    // _scrollview.center = CGPointMake(_scrollview.center.x, _scrollview.center.y + height);
    _btmView.center = CGPointMake(_btmView.center.x, _btmView.center.y + height);
    [tblComments removeGestureRecognizer:tblTapGesture];
    
    [UIView commitAnimations];
    RLogs(@"After Bottom View Centre - %@", NSStringFromCGPoint(_btmView.center));
    
    
}

-(void)tapToResignKeyBoard
{
    [_txtFieldComment resignFirstResponder];
}


- (IBAction)btnSendComment:(id)sender
{
    if([_txtFieldComment.text length] >0)
    {
        [self showLoader];
        NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
        
        [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
        
        [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
        
        [dictPostComments setValue:self.strPostId forKey:@"rpostid_s"];
        
        [dictPostComments setValue:[Util getScreenName] forKey:@"screenName_s"];
        
        [dictPostComments setValue:_txtFieldComment.text forKey:@"comment"];
        [dictPostComments setValue:self.strPodId forKey:@"rpid_s"];
        
        [dictPostComments setValue:self.strHotspotId forKey:@"hotspot"];
        
        AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
        
        [manager POST:[NSString stringWithFormat:@"%@/pods/hotspots/comments/new",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
         
         {
             RLogs(@"post hotspot comment response:%@",responseObject);
             [self removeLoader];
             
             NSMutableDictionary *dictComment = [[NSMutableDictionary alloc]init];
             
             [dictComment setValue:[Util getScreenName] forKey:@"screenName_s"];
             
             [dictComment setValue:[Util getImgUrl] forKey:@"avatar"];
             
             [dictComment setValue:_txtFieldComment.text forKey:@"comment"];
             
            NSDictionary *dictLastComment = [[[responseObject valueForKey:@"hotspotComments"] valueForKey:self.strHotspotId]lastObject];
            
             [dictComment setValue:[dictLastComment valueForKey:@"commentedAt"] forKey:@"commentedAt"];
             
             [dictComment setValue:[NSNumber numberWithInteger:numberOfRatings] forKey:@"rating"];
           //  [dictComment  setObject:@"YES" forKey:@"isCommented"];
             [aryHotspotComments addObject:dictComment];
             [tblComments reloadData];

             [Util_HotSpot saveHotspotCommentsData:dictPostComments:@""];
             
             
            
         }
              failure:^(AFHTTPRequestOperation *operation, NSError *error){
                  
                  RLogs(@"post  hotspot comment Error: %@", error);
                  [self removeLoader];
                  
                  
              }];
        
    
    
}
}

#pragma mark UITableView Delegate and DataSource Methods
#pragma mark ===========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(indexPath.row ==0)
    {
        return 100;
    }else
        return [aryHotspotComments count] * 80;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = HotspotCellID;
    HotspotCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil) {
        cell = [[HotspotCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.hotspotDesc.delegate = self;
    cell.hotspotDesc.tag = indexPath.row;
   
    
    if(indexPath.row == 0)
    {
        
        [cell.hotspotDesc setFrame:CGRectMake(cell.hotspotDesc.frame.origin.x, cell.hotspotDesc.frame.origin.y, cell.hotspotDesc.frame.size.width + 200, cell.hotspotDesc.frame.size.height)];
        cell.hotspotDesc.backgroundColor = [UIColor clearColor];
        cell.hotspotTitle.text = @"Hotspot Label";
        cell.hotspotDesc.text = objHsCircleView.strLabel;
        cell.hotspotDesc.editable = NO;
        [cell.hotspotBGImgView setBackgroundColor:[UIColor grayColor]];
        
        NSString *strColor = [self setHotspotcolorWithObj:objHsCircleView];
        
                RLogs(@"prestrColor - %@", strColor);
        
        if([strColor isEqualToString:@"red"])
        {
            RLogs(@"strColor - %@", strColor);
            
            cell.hotspotImgView.image = [UIImage imageNamed:HOTSPOT_RED_ICON];
        }
        else if ([strColor isEqualToString:@"white"])
        {
            RLogs(@"strColor - %@", strColor);
            
            cell.hotspotImgView.image = [UIImage imageNamed:HOTSPOT_WHITE_ICON];
            
        }
        else if ([strColor isEqualToString:@"blue"])
        {
            RLogs(@"strColor - %@", strColor);
            
            cell.hotspotImgView.image = [UIImage imageNamed:HOTSPOT_BLUE_ICON];
            
        } else if ([strColor isEqualToString:@"yellow"])
        {
            RLogs(@"strColor - %@", strColor);
            
            cell.hotspotImgView.image = [UIImage imageNamed:HOTSPOT_YELLOW_ICON];
            
        }
        else
        {
            RLogs(@"strColor - %@", strColor);
            
            cell.hotspotImgView.image = [UIImage imageNamed:HOTSPOT_WHITE_ICON];
            
        }
        
        
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0,98,self.tblComments.frame.size.width, 1)];
        [headerView setBackgroundColor:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f]];
        [cell.contentView addSubview:headerView];
    }
    else
    {
        cell.hotspotTitle.hidden = YES;
        cell.hotspotBGImgView.hidden = YES;
        cell.hotspotDesc.hidden = YES;
        cell.hotspotImgView.hidden = YES;
        
        for(int j=0;j<[aryHotspotComments count];j++)
        {
            
            NSDictionary *dictCommentData = [aryHotspotComments objectAtIndex:j];
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5,5+j*80, 30, 30)];
            imageView.layer.cornerRadius = imageView.frame.size.width / 2;
            imageView.clipsToBounds = YES;
            imageView.layer.borderWidth = 3.0f;
            imageView.layer.borderColor = [UIColor blackColor].CGColor;
            [imageView setImageWithURL:[NSURL URLWithString:[dictCommentData valueForKey:@"avatar"]]];
            [cell.contentView addSubview:imageView];
            
            UILabel *lblUserName = [self createLabelWithTitle:[dictCommentData valueForKey:@"screenName_s"] frame:CGRectMake(50, 10+j*80, 285, 20) tag:1 font:[Util Font:FontTypeItalic Size:10.0] color:[UIColor redColor] numberOfLines:0];
            [cell.contentView addSubview:lblUserName];
            
            if([[dictCommentData valueForKey:@"rating"]integerValue] > 0)
            {
                UILabel *lblRating = [self createLabelWithTitle:@"HotspotRating " frame:CGRectMake(50, 30+j*80, 120, 20) tag:1 font:[Util Font:FontTypeItalic Size:12.0] color:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f] numberOfLines:0];
                [cell.contentView addSubview:lblRating];
                
           //     NSInteger noRating = 5-numberofRatings;

                
                for(int i=0;i< 5;i++)
                {
                    UIImageView *imageViewRate = [[UIImageView alloc]initWithFrame:CGRectMake(130 + i * 22, 30+j*80,17, 17)];
                    if(i< [[dictCommentData valueForKey:@"rating"]integerValue])
                        [imageViewRate setImage:[UIImage imageNamed:@"rating_selected"]];
                    else
                        [imageViewRate setImage:[UIImage imageNamed:@"rating_unselected"]];

                    [cell.contentView addSubview:imageViewRate];
                }
             
                
                
            }
            
            UILabel *lblComment = [self createLabelWithTitle:[dictCommentData valueForKey:@"comment"] frame:CGRectMake(50, 30+j*80, 285, 20) tag:1 font:[Util Font:FontTypeItalic Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
          
            if([[dictCommentData valueForKey:@"rating"]integerValue] > 0)
            {
                [lblComment setFrame:CGRectMake(50, 30+j*80+20, 285, 20)];
            }
            NSLog(@"comment frame:%@",lblComment);
            [cell.contentView addSubview:lblComment];
            
            
            /*NSDate *date = [NSDate dateWithTimeIntervalSince1970:([[dictCommentData valueForKey:@"commentedAt"] integerValue] / 1000.0)];
            
            NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
            [dateformater setDateFormat:@"dd MMM YYYY"];
            NSString  * strDate = [dateformater stringFromDate:date];
            RLogs(@"date:%@",strDate);*/
            
            NSString *strDate = [Util dateFromInterval:[dictCommentData valueForKey:@"commentedAt"] inDateFormat:DATE_TIME_FORMAT];

            
            NSString *strCreatedAt = [NSString stringWithFormat:@"commented at %@",strDate];
            
            RLogs(@"%@",strCreatedAt);
            
            UILabel *lblCommentedOn = [self createLabelWithTitle:strCreatedAt frame:CGRectMake(50, 50+j*80, 285, 20) tag:1 font:[Util Font:FontTypeItalic Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
            NSLog(@"commentdate frame:%@",lblComment);

            if([[dictCommentData valueForKey:@"rating"]integerValue] > 0)

            {
                [lblCommentedOn setFrame:CGRectMake(50, 50+j*80+20, 285, 20)];
            }
            [cell.contentView addSubview:lblCommentedOn];
            
            
            _txtFieldComment.text = @"";
            
            
        }
        
    }
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}


-(NSString*)setHotspotcolorWithObj:(hotSpotCircleView*)hotspotobj
{
    NSString *strHotspotColor = @"white";
    
    if(hotspotobj.hotspotColor == 1)
    {
        strHotspotColor = @"white";
    }
    else if(hotspotobj.hotspotColor == 2)
    {
        strHotspotColor = @"red";
    }
    else if(hotspotobj.hotspotColor == 3)
    {
        strHotspotColor = @"blue";
    }
    else if(hotspotobj.hotspotColor == 4)
    {
        strHotspotColor = @"yellow";
    }
    return strHotspotColor;
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





@end
