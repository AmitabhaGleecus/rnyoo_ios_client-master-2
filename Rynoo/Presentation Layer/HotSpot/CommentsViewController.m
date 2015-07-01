//
//  CommentsViewController.m
//  Rnyoo
//
//  Created by Thirupathi on 03/02/15.
//  Copyright (c) 2015 Suvarna. All rights reserved.
//

#import "CommentsViewController.h"
#import "Constants.h"
#import "HotspotCustomCell.h"
#import "Util_HotSpot.h"

@interface CommentsViewController ()
{
    UITapGestureRecognizer *tblTapGesture;
    NSString *strComment ;
    NSMutableArray *aryQuestionComments;
}

@end

@implementation CommentsViewController
@synthesize tblComments,context,hsQuestionView,strPostId;
@synthesize aryQuestions;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    context = [APP_DELEGATE managedObjectContext];

    tblComments.delegate = self;
    tblComments.dataSource = self;
    
    _txtFieldComment.delegate = self;
    aryQuestionComments = [[NSMutableArray alloc]init];
    
    tblComments.separatorColor = [UIColor clearColor];

      tblTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToResignKeyBoard)];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self setNavigationBarTitle:@"Comments"];
    
    [self setLeftBarButtonOnNavigationBarAsBackButton];

    [tblComments reloadData];
}


-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:)
                                                 name:UIKeyboardDidChangeFrameNotification object:self.view.window];
    
    RLogs(@"array of questions:%@",aryQuestions);
    

    NSArray *aryQuestComments = [aryQuestions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"questionId == %@",hsQuestionView.strQuestionId]];
    
    for(NSDictionary *dict in aryQuestComments)
    {
        [aryQuestionComments addObjectsFromArray:[dict valueForKey:@"comments"]];
    }
    
    [tblComments reloadData];

    if([aryQuestions count]==0)
    [self refreshView];
    
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


-(void)refreshView
{
  //  [aryQuestions removeAllObjects];
  //  [self getQuestionCommentsDataFromDB];
    [tblComments reloadData];
    
}

#pragma mark UITableView Delegate and DataSource Methods
#pragma mark ===========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [aryQuestionComments count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = HotspotCellID;
    HotspotCustomCell *cell;
    
    UITableViewCell *commentCell;
    
    
    if(indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[HotspotCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.hotspotDesc.delegate = self;
        cell.hotspotDesc.tag = indexPath.row;

        [cell.hotspotDesc setFrame:CGRectMake(cell.hotspotDesc.frame.origin.x, cell.hotspotDesc.frame.origin.y, cell.hotspotDesc.frame.size.width + 200, cell.hotspotDesc.frame.size.height)];
        
        // Configuring hotspot contents on the cell
        
        
        cell.hotspotTitle.text = @"Question text";
        cell.hotspotDesc.text = hsQuestionView.strDescText;
        [cell.hotspotBGImgView setBackgroundColor:[UIColor grayColor]];
        
        
        NSString *strColor = [self setHotspotcolorWithObj:hsQuestionView];

        RLogs(@"prestrColor - %@", strColor);
        
        if([strColor isEqualToString:@"red"])
        {
            RLogs(@"strColor - %@", strColor);
            
            cell.hotspotImgView.image = [UIImage imageNamed:@"hotspotQuestion_red"];
        }
        else if ([strColor isEqualToString:@"white"])
        {
            RLogs(@"strColor - %@", strColor);
            
            cell.hotspotImgView.image = [UIImage imageNamed:@"hotspotQuestion_white"];
            
        }
        else if ([strColor isEqualToString:@"blue"])
        {
            RLogs(@"strColor - %@", strColor);
            
            cell.hotspotImgView.image = [UIImage imageNamed:@"hotspotQuestion_blue"];
            
        } else if ([strColor isEqualToString:@"yellow"])
        {
            RLogs(@"strColor - %@", strColor);
            
            cell.hotspotImgView.image = [UIImage imageNamed:@"hotspotQuestion_yellow"];
            
        }
        else
        {
            RLogs(@"strColor - %@", strColor);
            
            cell.hotspotImgView.image = [UIImage imageNamed:@"hotspotQuestion_white"];
            
        }

        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0,98,self.tblComments.frame.size.width, 1)];
        [headerView setBackgroundColor:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f]];
        [cell.contentView addSubview:headerView];
        

        return cell;
    }
    else 
    {
        commentCell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        
        if (commentCell == nil) {
            commentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CommentCell"];
            commentCell.backgroundColor = [UIColor clearColor];
            commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSDictionary *dictCommentData = [aryQuestionComments objectAtIndex:indexPath.row - 1];
        
         for(UIView *aView in commentCell.contentView.subviews)
         {
             if(aView.tag == 1)
                 [aView removeFromSuperview];
         }
        
        
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5,5, 30, 30)];
            imageView.layer.cornerRadius = imageView.frame.size.width / 2;
            imageView.clipsToBounds = YES;
            imageView.layer.borderWidth = 3.0f;
            imageView.layer.borderColor = [UIColor blackColor].CGColor;
            [imageView setImageWithURL:[NSURL URLWithString:[dictCommentData valueForKey:@"avatar"]]];
        imageView.tag = 1;
            [commentCell.contentView addSubview:imageView];
            
            UILabel *lblUserName = [self createLabelWithTitle:[dictCommentData valueForKey:@"screenName_s"] frame:CGRectMake(50, 10, 285, 20) tag:1 font:[Util Font:FontTypeItalic Size:10.0] color:[UIColor redColor] numberOfLines:0];
            [commentCell.contentView addSubview:lblUserName];
            
            NSArray *aryCommentData = [[dictCommentData valueForKey:@"comment"]componentsSeparatedByString:@","];
            
            UILabel *lblComment = [self createLabelWithTitle:[aryCommentData objectAtIndex:0] frame:CGRectMake(50, 30, 285, 20) tag:1 font:[Util Font:FontTypeItalic Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
            [commentCell.contentView addSubview:lblComment];
            
                   
            NSString *strDate = [Util dateFromInterval:[aryCommentData objectAtIndex:1] inDateFormat:DATE_TIME_FORMAT];
            
            NSString *strCreatedAt = [NSString stringWithFormat:@"commented at %@",strDate];
            
            RLogs(@">>>Created  --- %@",strCreatedAt);
            
            UILabel *lblCommentedOn = [self createLabelWithTitle:strCreatedAt frame:CGRectMake(50, 50, 285, 20) tag:1 font:[Util Font:FontTypeItalic Size:12.0] color:[UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f] numberOfLines:0];
            [commentCell.contentView addSubview:lblCommentedOn];
            
            
            _txtFieldComment.text = @"";
            
        return commentCell;
        

    }

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
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


-(NSString*)setHotspotcolorWithObj:(questionView*)questionObj
{
    NSString *strHotspotColor = @"white";
    
    if(questionObj.hotspotColor == 1)
    {
        strHotspotColor = @"white";
    }
    else if(questionObj.hotspotColor == 2)
    {
        strHotspotColor = @"red";
    }
    else if(questionObj.hotspotColor == 3)
    {
        strHotspotColor = @"blue";
    }
    else if(questionObj.hotspotColor == 4)
    {
        strHotspotColor = @"yellow";
    }
    return strHotspotColor;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getQuestionCommentsDataFromDB
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"QuestionComments" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"questionId == %@", hsQuestionView.strQuestionId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
  //  [aryQuestions addObjectsFromArray:fetchedObjects];
    
    RLogs(@"all questions array:%@",aryQuestions);
}


- (IBAction)btnSendComment:(id)sender
{
    if([_txtFieldComment.text length] >0)
    {
        [_txtFieldComment resignFirstResponder];
        [self showLoader];


    NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
    
    [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPostComments setValue:self.strPostId forKey:@"rpostid_s"];
    
    NSMutableDictionary *dictQuestion = [[NSMutableDictionary alloc]init];
    NSMutableArray *aryQuestion = [[NSMutableArray alloc]init];
        
    [dictQuestion setValue:hsQuestionView.strQuestionId forKey:@"questionId"];
    
    strComment = [NSString stringWithFormat:@"%@,%@",_txtFieldComment.text,[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970] * 1000]];
   
    RLogs(@"comment with date %@",strComment);
    
    [dictQuestion setValue:strComment forKey:@"comment"];
    
    [dictQuestion setValue:hsQuestionView.strAudioFilePath forKey:@"audioUrl"];
    [aryQuestion addObject:dictQuestion];
        
    [dictPostComments setValue:aryQuestion forKey:@"commentBody"];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/questions/comments/new",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         [self removeLoader];
         
         RLogs(@"post comment response:%@",responseObject);
         if([[responseObject valueForKey:@"status"] isEqualToString:@"succeess"])
         {
             NSMutableDictionary *dictComment = [[NSMutableDictionary alloc]init];
             
             [dictComment setValue:[Util getScreenName] forKey:@"screenName_s"];
             
             [dictComment setValue:[Util getImgUrl] forKey:@"avatar"];
             
             [dictComment setValue:strComment forKey:@"comment"];
             
             [aryQuestionComments addObject:dictComment];
             [tblComments reloadData];
      //       [Util_HotSpot saveQuestionCommentsData:dictPostComments];
             
     //        [self refreshView];
         }
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post comment Error: %@", error);
              //   [self showTheAlert:error.description];
              [self removeLoader];
              [self showNetworkErrorAlertWithTag:111111];

              
              
          }];
    }
 
}


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

@end
