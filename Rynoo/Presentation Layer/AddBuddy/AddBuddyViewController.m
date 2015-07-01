//
//  AddBuddyViewController.m
//  Rnyoo
//
//  Created by Rnyoo on 20/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "AddBuddyViewController.h"
#import "AddBuddyTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "ProfileImageView.h"


@interface AddBuddyViewController ()
{
    NSMutableArray *aryBuddies;
    NSMutableArray *aryFriendsFromServer;
    BOOL isSearch;
    NSMutableArray *arySelectedFriends;
}
@end

@implementation AddBuddyViewController
@synthesize context;

# pragma mark view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    context = [APP_DELEGATE managedObjectContext];

    isSearch = NO;
    if(![objUtil isiOS7])
        self.topSearchBarConstraint.constant = 44;
    else
        self.topSearchBarConstraint.constant = 44;

    
    if(!APP_DELEGATE.isPortrait)
    {
        if([Util isIOS8])
            self.topSearchBarConstraint.constant = 32;
    }
   
    aryBuddies = [[NSMutableArray alloc]init];
    aryFriendsFromServer = [[NSMutableArray alloc]init];
    arySelectedFriends = [[NSMutableArray alloc]init];
    
    
   // [self setTitle:@"Add Buddy"];

    self.searchBar.delegate = self;
    self.tblBuddies.delegate = self;
    self.tblBuddies.dataSource = self;
    
    self.btnAddFriends.enabled = NO;
    
    if([self connected])
    {
        [self getListOfFriends];  // getting list from server
    }
    else
    {
        [self getFriends]; // getting from db if there is no internet connection
    }
    
   
    tblTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToResignKeyBoard)];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationBarTitle:@"Add Friends"];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_searchBar resignFirstResponder];

}

#pragma mark KeyBoard Notifications
-(void)keyboardDidShow:(NSNotification*)notification
{
    [_tblBuddies addGestureRecognizer:tblTapGesture];
}

-(void)keyboardFrameChanged:(NSNotification*)notification
{
    
}

-(void)keyboardWillBeHidden:(NSNotification*)notification
{
    [_tblBuddies removeGestureRecognizer:tblTapGesture];

}

-(void)tapToResignKeyBoard
{
    [_searchBar resignFirstResponder];
}

/* navigation menu changes*/
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}
/* Update Constraints */


-(void)updateViewConstraints
{
    
    [super updateViewConstraints];
    
    if(![objUtil isiOS7])
        self.topSearchBarConstraint.constant = 44;
    else
        self.topSearchBarConstraint.constant = 64;

    if(APP_DELEGATE.isPortrait)
    {
        NSLog(@"%f",self.topSearchBarConstraint.constant);
    }
    else
    {
        if([Util isIOS8])
            self.topSearchBarConstraint.constant = 32;
    }
    
    NSLog(@"top %f",self.topSearchBarConstraint.constant);

}

# pragma Webservice calls

/* Search buddy */
-(void)searchBuddy
{
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [self showLoader];
    NSMutableDictionary *dictName = [[NSMutableDictionary alloc]init];
    NSString *strSearch = [NSString stringWithFormat:@"%@*",[self.searchBar.text lowercaseString]];
    NSLog(@"search string:%@",strSearch);
    [dictName setValue:strSearch  forKey:@"screenName_s"];

    [dictName setValue:[Util getSessionId] forKey:@"sid"];
    
    NSLog(@"dict:%@",dictName);
    
    [manager POST:[NSString stringWithFormat:@"%@/buddies/search",ServerURL] parameters:dictName success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSLog(@"buddies search response:%@",responseObject);
         
         NSArray *arrUsers = [(NSDictionary*)responseObject valueForKey:@"users"];
         [self removeLoader];
         
         if([arrUsers count])
         {
             for(int i=0;i< [arrUsers count];i++)
             {
                 NSDictionary   *userInfo = [arrUsers objectAtIndex:i];
             
                 NSMutableDictionary *dictInfo = [[NSMutableDictionary alloc]init];
                 [dictInfo setObject:@"NO" forKey:@"isSelected"];
                 [dictInfo setObject:[userInfo valueForKey:@"avatar"] forKey:@"avatar"];
                 [dictInfo setObject:[userInfo valueForKey:@"uid"] forKey:@"uid"];
                 [dictInfo setObject:[userInfo valueForKey:@"screenName_s"] forKey:@"screenName_s"];
                 
                 [aryFriendsFromServer addObject:dictInfo];
             }
             
             NSLog(@"buddies array:%@",aryFriendsFromServer);
             isSearch = YES;
             [self.tblBuddies reloadData];
             
         }
         else
         {
             [self showTheAlert:@"No buddies"];
             [self.tblBuddies reloadData];
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              NSLog(@"buddies search error: %@", error);
              [self removeLoader];
              [self showNetworkErrorAlertWithTag:111111];
              
              
          }];
    
}

/* Add buddies webserice call */
-(void)addBuddies
{
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [self showLoader];
      NSLog(@"%@",arySelectedFriends);
    if([arySelectedFriends count]== 0)
    {
        [self removeLoader];
        [self showTheAlert:@"Please select buddy"];
        return;
    }
    else
    {
        
        NSMutableDictionary *dictName = [[NSMutableDictionary alloc]init];
        NSMutableArray *aryInfo = [[NSMutableArray alloc]init];

        [dictName setValue:[Util getNewUserID] forKey:@"uid"];
        [dictName setValue:[Util getSessionId] forKey:@"sid"];
        NSLog(@"dict:%@",dictName);
        
        NSMutableDictionary *dictInfo = [[NSMutableDictionary alloc]init];
        
        for(int i=0;i< [arySelectedFriends count];i++)
        {
            [dictInfo setValue:[[arySelectedFriends objectAtIndex:i] valueForKey:@"uid"] forKey:@"uid"];
            [dictInfo setValue:[[arySelectedFriends objectAtIndex:i] valueForKey:@"screenName_s"] forKey:@"screenName_s"];
            [dictInfo setValue:[[arySelectedFriends objectAtIndex:i] valueForKey:@"avatar"] forKey:@"avatar"];
            
            [dictInfo setValue:[NSNumber numberWithBool:YES] forKey:@"acceptedInvite"];
            [dictInfo setValue:[NSNumber numberWithBool:YES] forKey:@"showStatus"];
            [dictInfo setValue:[NSNumber numberWithBool:NO] forKey:@"blocked"];
            [dictInfo setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] forKey:@"createdAt"];
            
            NSDictionary *dictUserDetails = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserDetails"];
            [dictInfo setValue:[dictUserDetails valueForKey:@"screenName_s"] forKey:@"name_s"];
            
            NSLog(@"dict info:%@",dictInfo);
            
            [aryInfo addObject:dictInfo];
        }
        [dictName setValue:aryInfo forKey:@"buddies"];
        
        NSLog(@"final dict:%@",dictName);


        [manager POST:[NSString stringWithFormat:@"%@/buddies/new",ServerURL] parameters:dictName success:^(AFHTTPRequestOperation *operation, id responseObject)
         
         {
             NSLog(@" add buddies  response:%@",responseObject);
             
             [self removeLoader];
             
             
             if([[responseObject valueForKey:@"status"] isEqualToString:@"failed"]
                )
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                 message:[responseObject valueForKey:@"message"]
                                                                delegate:self
                                                       cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
                 [alert show];
                 return;

             }
             else
             {
                 [self saveFriendsArray:arySelectedFriends];
                 isSearch = NO;
           
                 aryBuddies = [NSMutableArray arrayWithArray:aryBuddies];
                 [aryBuddies addObjectsFromArray:arySelectedFriends];

                 [self.tblBuddies reloadData];
                 
                 [self showTheAlert:@"Added Successfully"];
                 return;
             }
             
             
         }
              failure:^(AFHTTPRequestOperation *operation, NSError *error){
                  
                  NSLog(@"add buddies error: %@", error);
                  [self removeLoader];
                  [self showNetworkErrorAlertWithTag:222222];
                  
                  
              }];

    }
  
}

/*getting list of friends from server */
-(void)getListOfFriends
{
    [self showLoader];
    
    AFHTTPRequestOperationManager *manager = [Util getAppOperationRequestManager];

    NSMutableDictionary *dictInfo = [[NSMutableDictionary alloc]init];
    [dictInfo setValue:[Util getNewUserID] forKey:@"uid"];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@/buddies/uid/%@",ServerURL,[Util getNewUserID]];
    
    [manager GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    
     {
         NSLog(@"list of friends response:%@",responseObject);
         aryBuddies = [responseObject valueForKey:@"buddies"];
         [self saveFriendsArray:aryBuddies];

         [self.tblBuddies reloadData];
         [self removeLoader];

         
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [self removeLoader];
             [self showNetworkErrorAlertWithTag:333333];
             
         }];


}

#pragma Button action methods
/* add friends*/
- (IBAction)btnAddBuddiesClicked:(id)sender
{
    if([aryFriendsFromServer count]==0)
        return;
    if([self connected])
    {
        [self addBuddies];
    }
    else
    {
        [self showNoInternetMessage];
        return;
    }
}

#pragma search bar delegate methods
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;
{
    return  YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search text %@",self.searchBar.text);
    [searchBar resignFirstResponder];
    
    if([aryFriendsFromServer count])
    {
        [aryFriendsFromServer removeAllObjects];
    }
    if([arySelectedFriends count])
    [arySelectedFriends removeAllObjects];
    
    [self.tblBuddies reloadData];
    
    if([self.searchBar.text length])
    {
        if([self connected])
        {
            [self searchBuddy];
        }
        else
        {
            [self showNoInternetMessage];
            return;
        }
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
    if(isSearch)
        return [aryFriendsFromServer count];
    
    return [aryBuddies count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60;
}

/* Create custom view to display section header... */
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
  
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.frame.size.width, 40)];
    label.font = [Util Font:FontTypeSemiBold Size:13.0];
    [label setText:@"Added Friends"];
    label.textColor = [Util appHeaderColor];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]];
    CGRect sepFrame = CGRectMake(0, view.frame.size.height, 320, 1);
    UIView *seperatorView = [[UIView alloc] initWithFrame:sepFrame] ;
    seperatorView.backgroundColor = [UIColor blackColor];

    [view addSubview:seperatorView];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(isSearch)
        return 0.0;
    
    return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"Cell";
    
    AddBuddyTableViewCell *cell=(AddBuddyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = [[AddBuddyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if(isSearch == YES)
    {
        
        cell.friendName.text = [[aryFriendsFromServer objectAtIndex:indexPath.row]valueForKey:@"screenName_s"];
        cell.radioButtonImageview.image = [UIImage imageNamed:@"unchecked.png"];
        [cell.imgViewFriend setImage:nil];
        [cell.imgViewFriend setImageWithURL:[NSURL URLWithString:[[aryFriendsFromServer objectAtIndex:indexPath.row]valueForKey:@"avatar"]]];
        
    }
    else
    {
        cell.friendName.text = [[aryBuddies objectAtIndex:indexPath.row]valueForKey:@"screenName_s"];
        cell.radioButtonImageview.image = nil;
        [cell.imgViewFriend setImage:nil];

        [cell.imgViewFriend setImageWithURL:[NSURL URLWithString:[[aryBuddies objectAtIndex:indexPath.row]valueForKey:@"avatar"]]];

    }
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isSearch)
    {
        AddBuddyTableViewCell *cell = (AddBuddyTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSDictionary *dict = [aryFriendsFromServer objectAtIndex:indexPath.row];
        
        if([[dict objectForKey:@"isSelected"] isEqualToString:@"YES"])
        {
            cell.radioButtonImageview.image = [UIImage imageNamed:@"unchecked.png"];
            [[aryFriendsFromServer objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"isSelected"];
           

            [arySelectedFriends removeObject:[aryFriendsFromServer objectAtIndex:indexPath.row]];
            if([aryFriendsFromServer count]==1)
            {
                self.btnAddFriends.enabled = NO;
            }
            else
                self.btnAddFriends.enabled = YES;
        }
        else
        {
            cell.radioButtonImageview.image = [UIImage imageNamed:@"checked.png"];
            [[aryFriendsFromServer objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"isSelected"];
            self.btnAddFriends.enabled = YES;
            [arySelectedFriends addObject:[aryFriendsFromServer objectAtIndex:indexPath.row]];
            
        }
    
    }
    else
        self.btnAddFriends.enabled = NO;

    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

/* orientation methods*/
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        UIDeviceOrientation deviceOrientation;
        switch (toInterfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                deviceOrientation=UIDeviceOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationLandscapeRight:
                deviceOrientation=UIDeviceOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationPortrait:
                deviceOrientation=UIDeviceOrientationPortrait;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                deviceOrientation=UIDeviceOrientationPortraitUpsideDown;
                break;
            default: deviceOrientation=UIDeviceOrientationUnknown;
                break;
        }
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:deviceOrientation] forKey:@"orientation"];
    }
    [self updateViewConstraints];
}

# pragma mark save and retreiving buddies

/* save buddies in DB */
-(void)saveFriendsArray:(NSArray*)arrBuddies
{
    for(int i=0;i< [arrBuddies count];i++)
    {
        NSManagedObject *objFriends= [NSEntityDescription insertNewObjectForEntityForName:@"Friends" inManagedObjectContext:context];
        
        NSMutableDictionary *dictFriend = [arrBuddies objectAtIndex:i];
       
        [objFriends setValue:[dictFriend objectForKey:@"avatar"] forKey:@"avatar"];
       
        [objFriends setValue:[dictFriend objectForKey:@"isSelected"] forKey:@"isSelected"];
        
        [objFriends setValue:[dictFriend objectForKey:@"uid"] forKey:@"uid"];
        
        [objFriends setValue:[dictFriend objectForKey:@"screenName_s"] forKey:@"screenName_s"];
        
        [objFriends setValue:@"" forKey:@"status"];    // need to change
        
        [objFriends setValue:@"NO" forKey:@"isContactSelectedForPost"]; // to select contacts for post

        NSError *error= nil;
        if (![context save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }
   
    }

}

/* get friends from db */
-(NSArray*)getFriends
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Friends" inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"all FRIENDS array:%@",fetchedObjects);
    NSMutableArray *aryObjects = [NSMutableArray array];
    
    [aryObjects addObjectsFromArray:fetchedObjects];
    
    return aryObjects;

}

# pragma mark alertview delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    
    if(alertView.tag == 111111)
    {
        if(buttonIndex == 0)
        {
            [self searchBuddy];
            return;
        }
    }
    else if(alertView.tag == 222222)
    {
        if(buttonIndex == 0)
        {
            [self addBuddies];
            return;
        }
    }
    else if(alertView.tag == 333333)
    {
        if(buttonIndex == 0)
        {
            [self getListOfFriends];
            return;
        }
    }


    
    if(buttonIndex==0)
    {
        isSearch = NO;
        [self.tblBuddies reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
