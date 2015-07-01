//
//  FeedbackViewController.m
//  Rnyoo
//
//  Created by Logictree on 11/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

@synthesize isFromLeftMenu;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    if (self.isFromLeftMenu) {
        return YES;
    }
    else
        return NO;

    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavigationBarTitle:self.titleStr];
    
    [self setLeftBarButtonOnNavigationBarAsBackButton];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.feedbackTxtFld.text = @"";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendFeedbackAction:(id)sender
{
    if([self.feedbackTxtFld.text length]>0)
    {
        if([self connected])
        {
            [self sendFeedbacktoServer];
        }
        else
        {
            [self showNoInternetMessage];
            return;
        }
    }
}


-(void)sendFeedbacktoServer
{
    [self showLoader];
    
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc]init];
    
    [dictPost setValue:[Util getNewUserID] forKey:@"uid"];
    
    [dictPost setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPost setValue:[Util getDeviceToken]  forKey:@"devid"];
    
    [dictPost setValue:self.feedbackTxtFld.text  forKey:@"feedback"];
    
    RLogs(@"dict feedback:%@",dictPost);
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/feedback",ServerURL] parameters:dictPost success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         [self removeLoader];
         if([[responseObject valueForKey:@"status"]isEqualToString:@"success"])
         {
             RLogs(@"feedback response:%@",responseObject);
             UIAlertView *feedbackAlert = [[UIAlertView alloc]initWithTitle:@"" message:@"Thank you for your feedback." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
             [feedbackAlert show];
         }
     }
              failure:^(AFHTTPRequestOperation *operation, NSError *error){
                  
                  RLogs(@"feedback Error: %@", error);
                  [self removeLoader];
                  [self showNetworkErrorAlertWithTag:111111];
                  
                  
              }];
        
         
    
     
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    
    if(alertView.tag == 111111)
    {
        if(buttonIndex == 0)
        {
            [self sendFeedbackAction:nil];
            return;
        }
    }
    
    //[self.navigationController popViewControllerAnimated:YES];
}


@end
