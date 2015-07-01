//
//  NetworkViewController.m
//  Rnyoo
//
//  Created by Rnyoo on 19/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "NetworkViewController.h"
#import "CustomNetworkCell.h"
#import "CustomPostCommentTableViewCell.h"
#import "UIImage+WebP.h"
#import "hotSpotCircleView.h"
#import "HotSpotViewController.h"
#import "postBO.h"

#import "NetworkTableViewCell.h"



@interface NetworkViewController ()
{
    BOOL isFilter;
    UITableView *subMenuTableView;
    NSMutableArray *aryFilterData;
    NSArray *arrTest, *arr;
    NSString *strImageUrl;
    NSMutableDictionary *dictPostData;
    UIImageView *imageViewDelete;
    UIButton *imgLike;
    NSInteger numberOfLikes;
    BOOL isLike;
    CGSize imageBounds, imgBoundsAtNormalZoomInPortrait, imgBoundsAtNormalZoomInLandScape;
    UIImageView *hotspotImageVw;
    UIImage *selectedImg;
    NSMutableArray *aryImagePaths;
    NSInteger index;
    UILabel *lblNoData;

}

@end

#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation NetworkViewController
@synthesize context,networkVwObj;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setRightBarButtonOnNavigationBarwithText:@"Filter"];
    isLike = NO;
    
    arrPostsByMe = [[NSMutableArray alloc] init];
    
    arrPostsToMe = [[NSMutableArray alloc] init];
    
    arrPosts = [[NSMutableArray alloc] init];
    
    filterIndex = 0;
    
    aryFilterData = [[NSMutableArray alloc]initWithObjects:@"All Network",@"Posts by me",@"Posts shared to me", nil];
    strImageUrl = @"";
    [self setNavigationBarTitle:@"Network"];
    numberOfLikes = 0;
    dictPostData = [[NSMutableDictionary alloc]init];
    aryImagePaths = [[NSMutableArray alloc]init];
    
    context = [APP_DELEGATE managedObjectContext];
    
    isFiltering = NO;
    index = 0;
    _txtFldComment.delegate = self;
    _txtFldComment.autocorrectionType = UITextAutocorrectionTypeNo;
    
    subMenuTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 65, self.view.frame.size.width, 90) style:UITableViewStylePlain];
    subMenuTableView.tag = 222;
    subMenuTableView.separatorColor = [UIColor whiteColor];
    subMenuTableView.rowHeight = 60.0;
    subMenuTableView.delegate = self;
    subMenuTableView.dataSource = self;
    subMenuTableView.hidden = YES;
    [self.view addSubview:subMenuTableView];

   
    if(![self connected])
    {
        [self showNoInternetMessage];
        return;
    }
     else
     {
         [self showLoaderWithTitle:@""];
        [self  getPostsByMe];
     }
    
    
    tblTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToResignKeyBoard)];

    [self.view bringSubviewToFront:_btmView];
    
   
    _tblPosts.hidden = YES;

    RLogs(@"tblPosts frame - %@, view - %@", NSStringFromCGRect(_tblPosts.frame), NSStringFromCGRect(self.view.frame));
    
    
   _tblPosts.transform=CGAffineTransformMakeRotation(-M_PI_2);
    
    _tblPosts.frame = CGRectMake(1, 70, self.view.frame.size.width - 2, self.view.frame.size.height - _btmView.frame.size.height - 20);

    
    int ypos = 0.0;
    
    
     _tblPosts.pagingEnabled = YES;

    NSLog(@"_tblPost frame - %@", NSStringFromCGRect(_tblPosts.frame));
    
    refreshControl = [[UIRefreshControl alloc] init];
    
    [_tblPosts addSubview:refreshControl];
    
    
    lblNoData = [[UILabel alloc]initWithFrame:CGRectMake(40, self.view.frame.size.height/2, 300, 30)];
    
    lblNoData.text = @"There are no posts to show.";
    [self.view addSubview:lblNoData];
    
    lblNoData.hidden = YES;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setRightBarButtonOnNavigationBarwithText:@"Filter"];
  
    [self setNavigationBarTitle:@"Network"];
    isFiltering = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:)
                                                 name:UIKeyboardDidChangeFrameNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCommentSuccessfully:) name:@"Comment" object:nil];
    
    if([objUtil isiOS7])
        [[UITextField appearance] setTintColor:[UIColor blackColor]];
    else
    {
        
    }

}

-(void) viewWillDisappear :(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    index =0;
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    
}

-(void)addViews
{
    
}

-(void)reloadPostViews
{
    NSLog(@"Index - %li", (long)index);
    
    /*NSInteger totalSize;
    
    for(NSDictionary *obj in arrPosts)
    {
        totalSize += malloc_size((__bridge const void *)(obj));
    }
    
    NSLog(@">>>>Size of arrPosts - %li, count - %lu", (long)totalSize, (unsigned long)[arrPosts count]);*/

    isRefreshRequestProcessing = NO;
    [refreshControl endRefreshing];
    [self removeLoader];
    
    if(isShowloader)
    index = 0;
    
    
    _tblPosts.delegate = self;
   _tblPosts.dataSource = self;
    
    if([arrPosts count])
    {
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
        [arrPosts sortUsingDescriptors:[NSArray arrayWithObject:sort]];

        [_tblPosts reloadData];
        [_tblPosts setHidden:NO];
        
        lblNoData.hidden = YES;
    }
    else
    {
        [_tblPosts setHidden:YES];
        lblNoData.hidden = NO;
       
    }
    
    if([APP_DELEGATE isPortrait])
    {
        
    }
   
   /* RLogs(@">>>After tblPsost frame - %@", NSStringFromCGRect(_tblPosts.frame));

    _tblPosts.contentOffset = CGPointZero;
    RLogs(@">>>After tblPosts Content Offset - %@", NSStringFromCGPoint(_tblPosts.contentOffset));
    [_tblPosts setContentInset:UIEdgeInsetsZero];*/

 //   _tblPosts.contentOffset = CGPointZero;
  //   [_tblPosts setContentInset:UIEdgeInsetsZero];
    
    NSLog(@"tblPost contentoffset - %@", NSStringFromCGPoint(_tblPosts.contentOffset));
    NSLog(@"tblPost EdgesInset - %@", NSStringFromUIEdgeInsets(_tblPosts.contentInset));

  //  _tblPosts.contentOffset = CGPointZero;
  //  [_tblPosts setContentInset:UIEdgeInsetsZero];

    NSLog(@"tblPost contentoffset - %@", NSStringFromCGPoint(_tblPosts.contentOffset));
    NSLog(@"tblPost EdgesInset - %@", NSStringFromUIEdgeInsets(_tblPosts.contentInset));

    if(index < [arrPosts count])
    {
       // [_tblPosts scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    return;
}

-(void)tapToResignKeyBoard
{
    [_txtFldComment resignFirstResponder];
    subMenuTableView.hidden = YES;
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    subMenuTableView.frame = CGRectMake(0,65, self.view.frame.size.width, 90);


   /* if(APP_DELEGATE.isPortrait)
    {
        _tblTopConstraint.constant = 30;

    }
    else
    {
        _tblTopConstraint.constant = 20;

        if(![Util isIOS8])
        {
            _tblTopConstraint.constant = 50;

        }
    }*/
    
    [subMenuTableView reloadData];
    if([arrPosts count])
    {
        _tblPosts.hidden = NO;
        lblNoData.hidden = YES;
        [_tblPosts reloadData];
    }
    
}



-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(IS_IPHONE_6)
        NSLog(@"iPhone6");
    if(IS_IPHONE_4_OR_LESS)
        NSLog(@"iPhone4");
    if(IS_IPHONE_5)
        NSLog(@"iPhone5");
    if(IS_IPHONE_6P)
        NSLog(@"iPhone6plus");

      
    if(![APP_DELEGATE isPortrait])
       [lblNoData setFrame:CGRectMake(130,self.view.frame.size.height/2-20, 300, 30 )];
    else
        [lblNoData setFrame:CGRectMake(40,self.view.frame.size.height/2, 300, 30 )];

    if (UIDevice.currentDevice.systemVersion.floatValue >= 8.f)
    {
       //  _tblPosts.frame = CGRectMake(0, 0, _tblPosts.frame.size.height, _tblPosts.frame.size.width);
       // _tblPosts.frame = self.view.bounds;
       // _tblPosts.translatesAutoresizingMaskIntoConstraints = NO;
    }
   
    _tblPosts.frame = CGRectMake(1, 70, self.view.frame.size.width - 2, self.view.frame.size.height - _btmView.frame.size.height - 20);
    if(!APP_DELEGATE.isPortrait)
        _tblPosts.frame = CGRectMake(1, 40, self.view.frame.size.width - 2, self.view.frame.size.height - _btmView.frame.size.height - 20);
    
    NSLog(@"Now tblposts frame - %@", NSStringFromCGRect(_tblPosts.frame));
    NSLog(@"Now tblposts frame1 - %@", NSStringFromCGRect(_tblPosts.frame));

    _tblPosts.hidden = NO;
    
    
    if([arrPosts count])
    {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
        [arrPosts sortUsingDescriptors:[NSArray arrayWithObject:sort]];
        [_tblPosts reloadData];
        
        if(index < [arrPosts count])
            [_tblPosts scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
        else
            [_tblPosts scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];

        lblNoData.hidden = YES;
    }
    else
    {
        [_tblPosts setHidden:YES];
        lblNoData.hidden = NO;
    }
}

-(void)rightBarButtonTapped:(id)sender
{
    subMenuTableView.hidden = NO;
    [self.view bringSubviewToFront:subMenuTableView];
    [subMenuTableView reloadData];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return true;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation ==UIInterfaceOrientationLandscapeRight)
    {
        [self updateViewConstraints];
    }
    else
    {
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(![arrPosts count])
    {
        return NO;
    }
    
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_txtFldComment resignFirstResponder];
    
    return YES;
    
}

#pragma mark UITableView Delegate and DataSource Methods
#pragma mark ===========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(tableView == _tblPosts)
        return [arrPosts count];
    
    if(tableView.tag == 222)
        return 3;
   
        return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  
    if(tableView == _tblPosts)
        return tableView.frame.size.width;

   if(tableView.tag ==222)
   {
       return 30;
   }
  
    else return 60;

}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:YES];
    }
    

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"Cell";
    
    
    NSString *cellIdentifier1 = [NSString stringWithFormat:@"Cell%li", indexPath.row%2];
    
    UITableViewCell *cell;
    

    NetworkTableViewCell *cell1;
    
    if(tableView == _tblPosts )
    {
        cell1 = (NetworkTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
     //   cell1.transform = CGAffineTransformMakeRotation(M_PI_2);


    }
    else
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil || cell1 == nil)
    {
        if(tableView == _tblPosts )
        {
            cell1 = [[NetworkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
      //      cell1.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        else
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        
    }
    cell1.transform = CGAffineTransformMakeRotation(M_PI_2);

    NSLog(@"Cell centre - %@", NSStringFromCGPoint(cell1.contentView.center));
    NSLog(@"#### Cell Frame - %@", NSStringFromCGRect(cell1.contentView.frame));

    if(tableView == _tblPosts )
    {
      
        NSLog(@"#### Cell Frame after- %@", NSStringFromCGRect(cell1.contentView.frame));
        NSLog(@"Cell centre after - %@", NSStringFromCGPoint(cell1.contentView.center));

       // cell1.layoutMargins = UIEdgeInsetsZero;
        
    if(indexPath.row >= [arrPosts count])
        return cell1;
    }
    
    if(tableView == _tblPosts )
    {
        for(UIView *aview in cell1.contentView.subviews)
        {
            if([aview isKindOfClass:[NetworkView class]])
            {
                [(NetworkView*)aview removeFromSuperview];
            }
        }
        
        postBO *objPost = [arrPosts objectAtIndex:indexPath.row];
        int ypos = 0.0;
        NSLog(@"tableview ht:%f",cell1.frame.size.height);
        NSLog(@"tableview ht:%f",cell1.frame.size.height);

       
        NetworkView *objNetWorkView = [[NetworkView alloc] initWithFrame:CGRectMake(1, ypos, tableView.frame.size.width - 2, tableView.frame.size.height-ypos )];
        
        if (UIDevice.currentDevice.systemVersion.floatValue >= 8.f)
        {
            ypos = 5.0;
            
            if(APP_DELEGATE.isPortrait)
            {
                ypos = 5.0;

            objNetWorkView.frame = CGRectMake(1, ypos, tableView.frame.size.width - 2, tableView.frame.size.height-ypos - 55);
            }
            else
            {
                ypos = 5.0;

                objNetWorkView.frame = CGRectMake(1, ypos, self.view.frame.size.width - 2, tableView.frame.size.height-ypos - 30 );
            }
  
        }


        NSLog(@"Network View Frame - %@", NSStringFromCGRect(objNetWorkView.frame));
        objNetWorkView.delegate = self;
        objNetWorkView.objPost = objPost;
        objNetWorkView.tag = indexPath.row;
       // objNetWorkView.backgroundColor = [UIColor greenColor];
        [objNetWorkView designPostView];

        [cell1.contentView addSubview:objNetWorkView];
        
      //  [cell1 setTranslatesAutoresizingMaskIntoConstraints:YES];
        
        NSLog(@"#### Cell contentView Frame - %@", NSStringFromCGRect(cell.contentView.frame));
       // cell1.contentView.backgroundColor = [UIColor yellowColor];
    

        return cell1;
    }

    
    cell.backgroundColor = [UIColor clearColor];
    
    if(tableView == _tblPosts)
    {
        return cell1;
    }

    if(tableView.tag == 222)
    {
        cell.backgroundColor = [UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.text = [aryFilterData objectAtIndex:indexPath.row];
        
        if(indexPath.row == filterIndex)
        {
            RLogs(@"EQUAL INDEX");
            
            //[cell setSelected:YES];
            //[cell setSelected:YES animated:YES];
            //[cell setHighlighted:YES animated:YES];
            
            cell.textLabel.textColor = [UIColor colorWithRed:52/255.0f green:73/255.0f blue:94/255.0f alpha:1.0f];
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        else
        {
            RLogs(@"Not EQUAL INDEX");
            cell.textLabel.textColor = [UIColor whiteColor];
            [cell setSelected:NO];
        }
        return cell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(tableView.tag == 222)
    {
        filterIndex = indexPath.row;

        [arrPosts removeAllObjects];
         tableView.hidden = YES;
        
        [self refreshNetworkWithLoader:YES];
        
        for(UITableView *tblView in currentView.subviews)
        {
            [tblView removeGestureRecognizer:tblTapGesture];
        }

    }
    
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset
{}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;      // called when scroll view grinds to a halt
{
    index = [self getCurrentVisiblePostIndex];
    if(index == 0 )
    {
        [self refreshNetworkWithLoader:NO];
    }

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // RLogs(@"Index of Post123 - %li", (long)index);

}

-(void)refreshNetworkWithLoader:(BOOL)istoShowloader
{
    NSLog(@"*****Refreshing Network*****");
    
    if(isRefreshRequestProcessing)
        return;
    
    isRefreshRequestProcessing = YES;
    isShowloader = istoShowloader;
    
         if(isShowloader)
        [arrPosts removeAllObjects];
        
        if(filterIndex == 0)
        {
            
            if([self connected])
            {
                if(isShowloader)
                [self showLoader];
                
                [arrPostsByMe removeAllObjects];
                [arrPostsToMe removeAllObjects];
                isFiltering = NO;
                lblNoData.hidden = YES;
                [self getPostsByMe];
                
            }
            else
            {
                
                [arrPosts removeAllObjects];
                [arrPosts addObjectsFromArray:arrPostsByMe];
                [arrPosts addObjectsFromArray:arrPostsToMe];
            
                [self reloadPostViews];
                
            }
            
        }
        else if(filterIndex == 1)
        {
            if([self connected])
            {
                if(isShowloader)
                [self showLoader];
                
                [arrPostsByMe removeAllObjects];
                [arrPostsToMe removeAllObjects];
                isFiltering = YES;
                [self getPostsByMe];
            }
            else
            {
                [arrPosts removeAllObjects];

                [arrPosts addObjectsFromArray:arrPostsByMe];
                [self reloadPostViews];
                
            }
        }
        else
        {
            if([self connected])
            {
                if(isShowloader)
                [self showLoader];
                
                [arrPostsToMe removeAllObjects];
                [arrPostsByMe removeAllObjects];
                isFiltering = YES;

                [self getPostsToMe];
            }
            else
            {
                [arrPosts removeAllObjects];

                [arrPosts addObjectsFromArray:arrPostsToMe];
                [self reloadPostViews];
                
            }
            
        }
        
        
        
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnSendClicked:(id)sender
{
    
    
    UITableView *tableView = _tblPosts; // Or however you get your table view
    NSArray *paths = [tableView indexPathsForVisibleRows];
    
    for(NSIndexPath *path in paths)
    {
        RLogs(@"visible index2 - %li", path.row);
    }
    NSIndexPath *path = [paths objectAtIndex:0];

    UITableViewCell *cell = [_tblPosts cellForRowAtIndexPath:path];
    
    
    NetworkView *objNetworkView;
    
    for(UIView *aView in cell.contentView.subviews)
    {
        if([aView isKindOfClass:[NetworkView class]])
        {
            objNetworkView = (NetworkView*)aView;
            break;
        }
    }
    
    if([_txtFldComment.text length] >0)
    {
        [objNetworkView sendCommentToServerwithComment:_txtFldComment.text withObj:(postBO*)[arrPosts objectAtIndex:path.row]];
    }
    
    [_txtFldComment resignFirstResponder];
    return;
    
    
}

#pragma mark KeyBoard Notifications
-(void)keyboardDidShow:(NSNotification*)notification
{
        RLogs(@"keyboardDidShow - %@", [notification.userInfo description]);
    
   
    
        CGFloat height;
        
        CGRect keyBoardRect = [[notification.userInfo objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
        
        if(APP_DELEGATE.isPortrait)
            height = keyBoardRect.size.height;
        else
            height = keyBoardRect.size.height;
        
        
        RLogs(@"height - %f", height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
        //self.view.center = CGPointMake(self.view.center.x, ((keyBoardRect.origin.y + keyBoardRect.size.height) / 2) - height);
    
    _btmView.center = CGPointMake(_btmView.center.x, _btmView.center.y - height);


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
    _btmView.center = CGPointMake(_btmView.center.x, _btmView.center.y + height);

    [UIView commitAnimations];
    RLogs(@"After Bottom View Centre - %@", NSStringFromCGPoint(_btmView.center));

 

}


-(void)getHotspotComments
{
    
    
    NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
    
    [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPostComments setValue:[dictPostData valueForKey:@"rpostid_s"] forKey:@"rpostid_s"];
    
    [dictPostComments setValue:[dictPostData valueForKey:@"screenName_s"] forKey:@"screenName_s"];
    
    [dictPostComments setValue:@"Awesome Click!" forKey:@"comment"];
    [dictPostComments setValue:[dictPostData valueForKey:@"rpid_s"] forKey:@"rpid_s"];

    
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/pods/hotspots/comments/new",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"post hotspot comment response:%@",responseObject);
         [self removeLoader];
         
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post  hotspot comment Error: %@", error);
              [self removeLoader];
              
              
          }];
    


}


-(void)sendCommentSuccessfully:(NSNotification*)notification
{
     _txtFldComment.text = @"";
    
}

#pragma mark get data from DB

// getting pod data from database

-(NSManagedObject*)getPodDataFromDBwithPodId:(NSString*)podId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Pod" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pid == %@",podId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count])
    {
        RLogs(@"Pod data:%@",[fetchedObjects objectAtIndex:0]);
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
    
}

-(NSManagedObject*)getPostDataFromDB:(NSString*)postId
{
 
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@",postId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count])
    {
        RLogs(@"Pod data:%@",[fetchedObjects objectAtIndex:0]);
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    RLogs(@"touched negan");
    subMenuTableView.hidden = YES;
    
}

#pragma mark PostView Deelgate Methods

-(void)imageTapped:(postBO*)objPost withHotspots:(NSArray*)arrHotspots
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:objPost.strImgLocalPath])
    {
        RLogs(@"No vault Image");
        return;
    }
    RLogs(@"NetworkImagePath - %@", objPost.strImgLocalPath);
    
    HotSpotViewController *hotSpotVC = (HotSpotViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"HotSpot"];
    hotSpotVC.strImagePath = objPost.strImgLocalPath;
    hotSpotVC.strSelectedImageFrom = @"Network";
    hotSpotVC.selectedImgId = objPost.strImgid;
    hotSpotVC.isPodExisting = NO;
    if(objPost.isPublishedByUser)
        hotSpotVC.source = FROM_PUBLISHER;
    else
    {
        hotSpotVC.source = FROM_CONSUMER;
        hotSpotVC.arrHotspotRating = objPost.arrHotspotRating ;
//        hotSpotVC.aryQuestionComments = objPost.arrQuestions;
//        hotSpotVC.aryHotspotComments = objPost.aryHotspotComments;
        
    }
    hotSpotVC.aryHotspotComments = objPost.aryHotspotComments;
    hotSpotVC.aryQuestionComments = objPost.arrQuestions;
    
    hotSpotVC.strParentPodId = objPost.strPodId;
    hotSpotVC.strPostId = objPost.strPostId;
    hotSpotVC.arrHotspotInfo = arrHotspots;
    [self.navigationController pushViewController:hotSpotVC animated:NO];
}

-(void)postDelete:(postBO*)objPost
{
    
    if([self connected])
    {
        [self deletePost:objPost];
    }
    else
    {
        [self showNoInternetMessage];
        return;
    }

}

-(void)deletePost:(postBO*)objPost
{
    [self showLoader];
    NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
    
    
    [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPostComments setValue:objPost.strPostId forKey:@"rpostid_s"];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/delete",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         RLogs(@"post delete response:%@",responseObject);
         
         if([[responseObject valueForKey:@"status"] isEqualToString:@"deleted"])
         {
             RLogs(@"Deleted Index - %li", (long)index);
             
             
              [arrPosts removeObjectAtIndex:[self getCurrentVisiblePostIndex]];
             
             if([arrPosts count])
             {
                 NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
                 [arrPosts sortUsingDescriptors:[NSArray arrayWithObject:sort]];
                 [_tblPosts reloadData];
                 [_tblPosts setHidden:NO];
                 lblNoData.hidden = YES;

             }
             else
             {
                 [_tblPosts setHidden:YES];
                 lblNoData.hidden = NO;
             }

             
         }
         
         [self removeLoader];
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post delete Error: %@", error);
              //[self showTheAlert:error.description];
              [self showNetworkErrorAlertWithTag:111111];
              [self removeLoader];
              
          }];
    
}

-(NSInteger)getCurrentVisiblePostIndex
{
    
    UITableView *tableView = _tblPosts; // Or however you get your table view
    NSArray *paths = [tableView indexPathsForVisibleRows];
    
    
    
    for(NSIndexPath *path in paths)
    {
        RLogs(@"visible index - %li", path.row);
    }
    
    NSIndexPath *path = (NSIndexPath*)[paths objectAtIndex:0];
    
    NSInteger rowIndex = path.row;
    
    if(rowIndex >= [arrPosts count])
    {
        rowIndex = [arrPosts count] - 1;
    }
    if(rowIndex < 0)
        rowIndex = 0;
    
    return path.row;
    
    
}
-(void)downloadedPost:(postBO*)objPost
{
    
    RLogs(@"UnknownCreatedDatePosts - %d", unknownCreatedDatePosts);
    if(!unknownCreatedDatePosts)
    {
        return;
    }
    
    unknownCreatedDatePosts--;
    
    for(postBO *post in arrPosts)
    {
        if([post.strPostId isEqualToString:objPost.strPostId])
        {
            NSUInteger indexOfPost = [arrPosts indexOfObject:post];
            [arrPosts removeObject:post];
            [arrPosts insertObject:objPost atIndex:indexOfPost];
            break;
        }
    }
    
    if(!unknownCreatedDatePosts)
        [self reloadPostViews];
}

# pragma mark alertview delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    
    if(alertView.tag == 111111)
    {
        if(buttonIndex == 0)
        {
            [self postDelete:currentView.objPost];
            return;
        }
    }
    else if(alertView.tag == 222222)
    {
        if(buttonIndex == 0)
        {
            [self postHide:currentView.objPost];
            return;
        }
    }
}


-(void)deletePostAserrorOccured:(postBO*)objPost
{
    for(postBO *post in arrPosts)
    {
        if([post.strPostId isEqualToString:objPost.strPostId])
        {
            [arrPosts removeObject:post];
            break;
        }
    }
    
}

-(void)postHide:(postBO*)objPost
{
    if([self connected])
    {
        [self hidePost:objPost];
    }
    else
    {
        [self showNoInternetMessage];
    }
}

-(void)hidePost:(postBO*)objPost
{
    [self showLoader];
    NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
    
    [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPostComments setValue:objPost.strPostId forKey:@"rpostid_s"];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/users/timeline/hide",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"post hide response:%@",responseObject);
         if([[responseObject valueForKey:@"status"] isEqualToString:@"success"])
         {
             NSInteger currentIndex = [self getCurrentVisiblePostIndex];
             [arrPosts removeObjectAtIndex:currentIndex];
             

             if([arrPosts count])
             {
                 RLogs(@"Index - %li", (long)index);
                 NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
                 [arrPosts sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            // [_tblPosts reloadData];
               //  [_tblPosts scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
             }
             else
             {
                 _tblPosts.hidden = YES;
             }
             

         }
         [self removeLoader];

         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post delete Error: %@", error);
              //      [self showTheAlert:error.description];
              [self showNetworkErrorAlertWithTag:222222];
              [self removeLoader];

          }];
}



-(void)deleteDatainDBwithPostId:(NSString*)strPostId
{
    NSManagedObject *objPostsData = [Util_HotSpot getPostDataFromDBwithPostId:strPostId];
    
  if(objPostsData != nil)
      [context deleteObject:objPostsData];
    
    NSArray *aryHotspotsShared = [Util_HotSpot getHotspotsSharedDataFromDBwithPostId:strPostId];
    
    for(NSManagedObject *objHotspotShared in aryHotspotsShared)
    {
        if(objHotspotShared != nil)
            [context deleteObject:objHotspotShared];
    }
    
    NSError *error= nil;
    if (![context save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
}


#pragma mark Web Service Call
-(void)getPostsByMe
{
    
    NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
    
    [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
    
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/posts",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
          {
         NSLog(@"all posts response:%@",responseObject);
         unknownCreatedDatePosts = 0;
         NSArray *arrPost = (NSArray*)[responseObject valueForKey:@"posts"];
         
         [self testPostsInDB:arrPost];
         
         //Here we are loading posts based on filter.
         if(!isFiltering)
         {
             [self removeLoader];
             [arrPosts removeAllObjects];
             [arrPosts addObjectsFromArray:arrPostsByMe];
             [self reloadPostViews];
             [self performSelectorInBackground:@selector(getPostsToMe) withObject:nil];

         }
         else
         {
             [arrPosts removeAllObjects];
             [arrPosts addObjectsFromArray:arrPostsByMe];
             [self reloadPostViews];
             
         }

         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              NSLog(@"list of posts Error: %@", error);
              //Here we are loading posts based on filter.
              if(!isFiltering)
              {
                  [self getPostsToMe];
                  
              }
              else
              {
                  
                  [arrPosts removeAllObjects];
                  [arrPosts addObjectsFromArray:arrPostsByMe];
                  [self reloadPostViews];
                  
                  if(![arrPosts count])
                      [self showTheAlert:@"Network error. Please try again."];

                  
              }
              
          }];
    
    
}

-(void)getPostsToMe
{
    
    NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
    
    [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
    
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/users/timeline",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSLog(@"timeline response:%@",responseObject);
         
         if([responseObject isKindOfClass:[NSDictionary class]])
         {
         for (NSString *strkey in [responseObject allKeys])
         {
             if([strkey isEqualToString:@"error"])
             {
                 [self removeLoader];
                 return;
                 
             }
         }
         }

         NSArray *arrPost = (NSArray*)responseObject;
         
         if([arrPost count])
         {
             if(arrPostsToMe == nil)
                 arrPostsToMe = [[NSMutableArray alloc] init];
             
             [arrPostsToMe removeAllObjects];
         }
         
         for(NSDictionary *dictPost in arrPost)
         {
             RLogs(@"DictPost - %@", [dictPost description]);
             
             postBO *objPost = [[postBO alloc] init];
             
             objPost.strAvatarUrl = [dictPost valueForKey:@"avatar"];
             
             NSDictionary *postDetails = [dictPost valueForKey:@"postDetails"];
             
             NSDictionary *podDetails = [postDetails valueForKey:@"pod"];
             
             NSDictionary *podImg = [podDetails valueForKey:@"podImage"];

            objPost.strImgid = [podImg valueForKey:@"imgId"];
             
             objPost.strImgUrl = [podImg valueForKey:@"baseUrl"];
             
             objPost.strImgLocalPath =  [self getFilePathwithFileName:[(NSString*)[podImg valueForKey:@"baseUrl"] lastPathComponent] inFolder:VAULT_FOLDER];
             
             objPost.strPictureTakenLocation = [podDetails valueForKey:@"location"];
             
             objPost.strScreenName = [dictPost valueForKey:@"screenName_s"];
             
             
             objPost.createdAt = (NSString*)[postDetails valueForKey:@"createdAt"];

                objPost.isPublishedByUser = NO;
         
             objPost.strPostId = [dictPost valueForKey:@"rpostid_s"];
             
             objPost.strPostTitle =[postDetails valueForKey:@"postDescription"];
             
             objPost.strPodId = [podDetails valueForKey:@"rpid_s"];
             
             objPost.arrHotspotsShared = [postDetails valueForKey:@"hotspotsShared"];
             
             objPost.arrHotspots = [podDetails valueForKey:@"hotspots"];
             
             if(objPost.isPublishedByUser)
             {
                 
                 //Publisher can visualise all the questions...
                 objPost.arrQuestions = [postDetails valueForKey:@"questions"];
             }
             else
             objPost.arrQuestions = [self checkAndRetrieveQuestionsIfAnyPostedByThisUser:postDetails];
             
             objPost.arrComments  = [postDetails valueForKey:@"podComments"];
             
//             objPost.aryHotspotComments = [postDetails valueForKey:@"hotspotComments"];
          
             objPost.numberOfLikes = [[postDetails valueForKey:@"likes"] count];
             objPost.isAlreadyLikedByUser = [self checkWhetherUserHasAlreadyLikedThisPost:[postDetails valueForKey:@"likes"]];
             
             objPost.arrHotspotRating = [postDetails valueForKey:@"hotspotRatings"];
             
             NSMutableArray *arrCommentsWithRating = [self sortCommentsAndRatings:[postDetails valueForKey:@"hotspotComments"] andRating:[postDetails valueForKey:@"hotspotRatings"] withHotspots:objPost.arrHotspots];
             
             
             objPost.aryHotspotComments = arrCommentsWithRating;
            
             objPost.pictureTakenOn = [podImg valueForKey:@"takenAt"];
                                                      
            [arrPostsToMe addObject:objPost];

            [self saveQuestions:objPost];
             
        //     [self saveHotspotComments:objPost];
            
             
         }
         
         //Here we are loading posts based on filter.
         [arrPosts removeAllObjects];
         if(!isFiltering)
         {
             NSLog(@"isFiltering");
             [arrPosts addObjectsFromArray:arrPostsByMe];
             [arrPosts addObjectsFromArray:arrPostsToMe];

         }
         else
         {
             NSLog(@"not Filtering");

             [arrPosts addObjectsFromArray:arrPostsToMe];

         }
         [self performSelectorOnMainThread:@selector(reloadPostViews) withObject:nil waitUntilDone:YES];
         [self removeLoader];

         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              [self removeLoader];
              NSLog(@"list of posts Error: %@", error);
              
              //Here we are loading posts based on filter.
              [arrPosts removeAllObjects];
              if(!isFiltering)
              {
                  [arrPosts addObjectsFromArray:arrPostsByMe];
                  [arrPosts addObjectsFromArray:arrPostsToMe];
                  
              }
              else
              {
                  [arrPosts addObjectsFromArray:arrPostsToMe];
                  
              }
              [self reloadPostViews];
              
              if(![arrPosts count])
                  [self showTheAlert:@"Network error. Please try again."];
          }];
    
    
}

-(BOOL)checkWhetherUserHasAlreadyLikedThisPost:(NSArray*)arrLikedUsers
{
    NSString *strCurrentUserId = [Util getNewUserID];
    
    for(NSString *strUserId in arrLikedUsers)
    {
        if([strUserId isEqualToString:strCurrentUserId])
        {
            return YES;
            
        }
        else
        {
            
        }
    }
    
    return NO;
    
}


-(NSArray*)checkAndRetrieveQuestionsIfAnyPostedByThisUser:(NSDictionary*)dictPostDetails
{
    NSArray *arrQuestions = [dictPostDetails valueForKey:@"questions"];
    
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



-(NSMutableArray*)sortCommentsAndRatings:(NSArray*)aryHotspotComments andRating:(NSArray*)aryHotspotRating withHotspots:(NSArray*)arrHotspots
{
    NSMutableArray *arrHotspotComment = [[NSMutableArray alloc]init];
    NSMutableArray *arrHotspotRating = [[NSMutableArray alloc]init];
    BOOL isExists = NO;
    NSMutableArray *arrHotspotwithComemntAndRating = [[NSMutableArray alloc]init];

    for(NSDictionary *dictHotspot in arrHotspots)
    {
        [arrHotspotComment removeAllObjects];
        [arrHotspotRating removeAllObjects];
        
    NSArray *aryHotspoComments = [aryHotspotComments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hotspotId == %@",[dictHotspot valueForKey:@"hotspotId"]]];
    
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

-(void)saveHotspotComments:(postBO*)objPost
{
    RLogs(@"hotspot comments:%@",objPost.aryHotspotComments);
    NSArray *aryHotspotComments = objPost.aryHotspotComments;
    
    
    for(NSDictionary *dictHotspotComments in aryHotspotComments)
    {
        NSArray *aryComments = [dictHotspotComments valueForKey:@"comments"];
        NSString *strHotspotId = [dictHotspotComments valueForKey:@"hotspotId"];
        
        for(NSDictionary *dict in aryComments)
        {
            BOOL isExists = [self checkToSaveOrUpdateHotspotComments:strHotspotId :objPost];

            if(!isExists)
            {
                [Util_HotSpot saveHotspotCommentsData:dict :strHotspotId];
            }
        }
    }
    
    
}
-(void)saveQuestions:(postBO*)objPost
{
    for(NSDictionary *dict in objPost.arrQuestions)
    {
        BOOL isExists = [self checkToSaveOrUpdate:dict];
        if(!isExists)
        {
            NSManagedObject *objQuestion= [NSEntityDescription insertNewObjectForEntityForName:@"Questions" inManagedObjectContext:context];
            
            NSDictionary *dictLocation = [dict valueForKey:@"location"];

            [objQuestion setValue:[dict valueForKey:@"avatar"] forKey:@"avatar"];
            
            [objQuestion setValue:[dict valueForKey:@"createdAt"] forKey:@"createdAt"];
            
            [objQuestion setValue:[dict valueForKey:@"locationColor"] forKey:@"locationColor"];
            
            [objQuestion setValue:[dict valueForKey:@"locationMarker"] forKey:@"locationMarker"];
            
            [objQuestion setValue:[dict valueForKey:@"postedBy"] forKey:@"postedBy"];
            
            [objQuestion setValue:[dict valueForKey:@"question"] forKey:@"question"];
            
            [objQuestion setValue:[dict valueForKey:@"questionId"] forKey:@"questionId"];
            
            
            [objQuestion setValue:[dict valueForKey:@"screenName_s"] forKey:@"screenName_s"];
            
            [objQuestion setValue:[dict valueForKey:@"audioUrl"] forKey:@"audioUrl"];
            
            [objQuestion setValue:objPost.strPostId forKey:@"postId"];
            
            [objQuestion setValue:[NSNumber numberWithInteger:[[dictLocation valueForKey:@"x"] integerValue]] forKey:@"xCoordinate"];
            
            [objQuestion setValue:[NSNumber numberWithInteger:[[dictLocation valueForKey:@"y"] integerValue]] forKey:@"yCoordinate"];

            NSError *error= nil;
            if (![context save:&error])
            {
                RLogs(@"Problem saving: %@", [error localizedDescription]);
            }
        }
        
    }
}

-(BOOL)checkToSaveOrUpdate:(NSDictionary*)dict
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Questions" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"questionId == %@",[dict valueForKey:@"questionId"]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
   
    if([fetchedObjects count])
        return YES;
    else
        return NO;
    
    
}


-(BOOL)checkToSaveOrUpdateHotspotComments:(NSString*)strHotspotId :(postBO*)objPost
{
    
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"HotspotComments" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hotspotId == %@ && podId == %@",strHotspotId,objPost.strPodId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return YES;
    else
        return NO;
    
}

-(void)testPostsInDB:(NSArray*)arrPost
{
    if(arrPostsByMe == nil)
        arrPostsByMe = [[NSMutableArray alloc] init];

    [arrPostsByMe removeAllObjects];
    
     for(NSString *strPostId in arrPost)
     {
     NSManagedObject *objManagedObjPost = [self getPostDataFromDB:strPostId];
     
     NSString *strPodId = [objManagedObjPost valueForKey:@"podId"];
     
     NSManagedObject *objPod =[self getPodDataFromDBwithPodId:strPodId];
     
     NSString *strImgId = [objPod valueForKey:@"imgId"];
     
     
     NSArray *aryHotspots = [Util_HotSpot getHotspotDataFromDBOfImgId:strImgId withPodId:[objPod valueForKey:@"pid"]];
     
     NSArray *aryHotspotsShared = [Util_HotSpot getHotspotsSharedDataFromDBwithPostId:strPostId];
     
     /*  NSMutableArray *arrHsOfPost = [[NSMutableArray alloc] init];
     for(NSManagedObject *objSharedHs in aryHotspotsShared)
     {
     for(NSManagedObject *objHs in aryHotspots)
     {
     if([[objSharedHs valueForKey:@"hotSpotId"] isEqualToString:[objHs valueForKey:@"hId"]])
     {
     [arrHsOfPost addObject:objHs];
     break;
     }
     }
     }*/
     
     if(objPod == nil )
     {
     RLogs(@"####no data in DB");
     
     postBO *objPost = [[postBO alloc] init];
     
     NSManagedObject *objUser = [Util_HotSpot getUserDataFromDB];
     
     objPost.strAvatarUrl =  [objUser valueForKey:@"avatar"];
     objPost.strScreenName = [objUser valueForKey:@"screenName"];
     objPost.strImgLocalPath = [self getFilePathwithFileName:@"" inFolder:VAULT_FOLDER];
     
     objPost.isExistingInDB = NO;
     objPost.isPublishedByUser = YES;
     objPost.strPostId = strPostId;

     
     [arrPostsByMe addObject:objPost];
         
         unknownCreatedDatePosts++;
     
     continue;
     }
     
     
     NSManagedObject *objImg = [Util_HotSpot getImageDataFromDBOfImgId:strImgId];
     
     NSManagedObject *objUser = [Util_HotSpot getUserDataFromDB];
     
     
     NSArray *aryQuestionsData = [Util_HotSpot getQuestionsDatafromDB:strPostId];
     
     NSArray *aryCommentsData = [Util_HotSpot getCommentDatafromDB:strPostId];
         
     NSArray *aryHotspotComments = [Util_HotSpot getHotspotCommentsDatawithPostId:strPostId];
         
     
     postBO *objPost = [[postBO alloc] init];
     
     objPost.strAvatarUrl =  [objUser valueForKey:@"avatar"];
     
     objPost.isExistingInDB = YES;
     
     objPost.strImgid = strImgId;
     
     objPost.strImgLocalPath = [objImg valueForKey:@"imgPath"];
     
     objPost.strImgUrl = [objImg valueForKey:@"imgUrl"];
     
     if([[objPod valueForKey:@"location"] length] > 0)
     objPost.strPictureTakenLocation = [objPod valueForKey:@"location"];
     else
     objPost.strPictureTakenLocation = @"";
     
     objPost.strScreenName = [objUser valueForKey:@"screenName"];
     
     NSManagedObject *objHotspotShared = [aryHotspotsShared objectAtIndex:0];
     objPost.createdAt = (NSString*)[objHotspotShared valueForKey:@"createdAt"];
         
     objPost.strPostTitle = [objPod valueForKey:@"title"];
     
     objPost.arrHotspots = aryHotspots;
     
     objPost.strPostId = strPostId;
     
     objPost.strPodId = [objPod valueForKey:@"pid"];
     
     objPost.isPublishedByUser = YES;
     
     objPost.arrQuestions = aryQuestionsData;
         
     objPost.arrComments = nil;
     objPost.arrComments = [aryCommentsData mutableCopy];
         
     objPost.aryHotspotComments = aryHotspotComments;
         
     objPost.arrHotspotsShared = aryHotspotsShared;
         
     objPost.pictureTakenOn = [objImg valueForKey:@"imageCreatedTime"];

         
     [arrPostsByMe addObject:objPost];
     }
   

}




@end
