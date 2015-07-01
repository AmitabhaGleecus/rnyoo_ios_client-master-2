//
//  SettingsViewController.m
//  Rnyoo
//
//  Created by Rnyoo on 19/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

{
    NSMutableArray *arrOptions;
}
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    arrOptions = [[NSMutableArray alloc]initWithObjects:@"LOGOUT", @"DELETE MY RNYOO ACCOUNT",@"", nil];

//    if ([self.tblOptions respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.tblOptions setSeparatorInset:UIEdgeInsetsZero];
//    }
    
    self.tblOptions.separatorColor = [UIColor grayColor];
    
    _tblOptions.scrollEnabled = NO;
    
   // _tblOptions.backgroundColor = [UIColor redColor];


}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationBarTitle:@"Settings"];

}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


#pragma mark UITableView Delegate and DataSource Methods
#pragma mark ===========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrOptions count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
//    arrOptions = [NSArray arrayWithObjects:@"LOGOUT", @"DELETE MY RNYOO ACCOUNT",@"", nil];
    

    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        tableView.separatorColor = [Util colorWithRed:0.0 green:31.0 blue:57.0 alpha:1.0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [arrOptions objectAtIndex:indexPath.row];
    
    [cell.textLabel setFont:[Util Font:FontTypeSemiBold Size:15.0]];
    
    [cell.textLabel setTextColor:[Util colorWithRed:0.0 green:31.0 blue:57.0 alpha:1.0]];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        [self logOut];
    }
    else if(indexPath.row == 1)
    {
        
    }
    else{
        
    }
}

-(void)logOut
{
    
    NSMutableDictionary *dictLogout = [[NSMutableDictionary alloc]init];
    [dictLogout setValue:[Util getNewUserID] forKey:@"uid"];
    [dictLogout setValue:[Util getSessionId] forKey:@"sid"];

    [dictLogout setValue:[Util getDeviceToken] forKey:@"devid"];

    [self showLoader];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/users/logout",ServerURL] parameters:dictLogout success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         [self removeLoader];
         RLogs(@"logout response:%@",responseObject);
         
         [Util setPreviousUserScreenName:[Util getScreenName]];
         
         [APP_DELEGATE signOut];
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              [self removeLoader];
              RLogs(@"logout Error: %@", error.description);
              [self showNetworkErrorAlertWithTag:111111];
              
          }];

    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(alertView.tag == 111111)
    {
        if(buttonIndex == 0)
        {
            [self logOut];
            return;
        }
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
