//
//  VerificationCodeViewController.m
//  Rynoo
//
//  Created by Rnyoo on 08/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VerificationCodeViewController.h"


@interface VerificationCodeViewController ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *txtFieldTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lblTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lbl2Topconstraint;


@end

@implementation VerificationCodeViewController
@synthesize context;

# pragma view lifecycle

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    _txtFldVerificationCode.delegate = self;
    
    _txtFldVerificationCode.keyboardType = UIKeyboardTypeNumberPad;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setNavigationBarTitle:@"Verification"];
}

#pragma mark TextField Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

/* To dismiss keyboard when clicked on view*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_txtFldVerificationCode resignFirstResponder];
}

#pragma  mark button Actions

/* Resend Verification code if not received */

- (IBAction)resendVerificationCode:(id)sender {
    
    [self btn_ResendActivationCode];
}

/*  Send Verification Code to server */

- (IBAction)btn_SendVerificationCode:(id)sender;
{
    
    NSString *strActivationCode = [Util getActivationCode];
    
    if([strActivationCode isEqualToString:_txtFldVerificationCode.text])
    {
        [self activateUser];
    }
    else  if([_txtFldVerificationCode.text isEqualToString:@"123456"]) // need to remove @ production
    {
        if([self connected])
        {
            [self activateUser];
        }
        else
        {
            [self showNoInternetMessage];
            return;
        }
    }
    else
    {
        [self showTheAlert:@"Please enter a valid Verification Code."];
    }
}

/* Activates user by calling webservice */

-(void)activateUser
{
    [self showLoader];
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    NSMutableDictionary *dictUid = [[NSMutableDictionary alloc] init];
    
    [dictUid setValue:[Util getNewUserID] forKey:@"uid"];
    
    [manager POST:[NSString stringWithFormat:@"%@/users/activate",ServerURL] parameters:dictUid success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         [self removeLoader];
         
         RLogs(@"login response:%@",responseObject);
         
         NSString *strStatus = [responseObject valueForKey:@"status"];
         
         if([strStatus isEqualToString:@"success"])
         {
             //save user details in DB
             [self getUserdetailsFromServer];
             
         }
         else
         {
             NSString *strError = [responseObject valueForKey:@"error"];
             
             [self showTheAlert:strError];
         }

         
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              [self removeLoader];
              
              RLogs(@"login Error: %@", error.description);
              
              
              [self showNetworkErrorAlertWithTag:111111];
              
          }];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(alertView.tag == 111111)
    {
        if(buttonIndex == 0)
        {
            [self activateUser];
            return;
        }
    }
    else  if(alertView.tag == 222222)
    {
        if(buttonIndex == 0)
        {
            [self btn_ResendActivationCode];
            return;
        }
    }
}

/* Resend Verification code to server */

-(void)btn_ResendActivationCode
{
    
    [self showLoader];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    
    NSString *strUserId = [Util getNewUserID];
    NSMutableDictionary *dictResendActCode = [[NSMutableDictionary alloc]init];
    [dictResendActCode setValue:strUserId forKey:@"uid"];
    
    
    
    [manager POST:[NSString stringWithFormat:@"%@/users/resendactivationcode",ServerURL] parameters:dictResendActCode success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         [self removeLoader];
         
         RLogs(@"create new user response:%@",responseObject);
         if([[responseObject valueForKey:@"status"] isEqualToString:@"error"])
         {
            // NSString *strErrorMsg = [responseObject valueForKey:@"reason"];
             
             [self showTheAlert:@"Please Retry."];
             
       
             return;
         }
         RLogs(@"uid:%@",[responseObject valueForKey:@"uid"]);
         RLogs(@"activationcode:%@",[responseObject valueForKey:@"activationCode"]);
         [Util setNewUserID:[responseObject valueForKey:@"uid"]];
         [Util setActivationCode:[responseObject valueForKey:@"activationCode"]];
         
   //      [self performSegueWithIdentifier: @"VerificationCode" sender: self];
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              [self removeLoader];
              
              RLogs(@"create new user Error: %@", error.description);
              [self showNetworkErrorAlertWithTag:222222];
              
          }];

}

# pragma mark orientation methods

- (BOOL)shouldAutorotate
{
    return YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    return true;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
    
    [self.navigationController.view layoutSubviews];
    
    [self updateViewConstraints];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.txtFieldTopConstraint.constant = 50;
        self.lblTopConstraint.constant = 10;
        self.lbl2Topconstraint.constant = 9;

    }
    
    
    else
    {
        self.txtFieldTopConstraint.constant = 99;
        self.lblTopConstraint.constant = 42;
        self.lbl2Topconstraint.constant = 69;
    }
    
    
}


#pragma mark - Navigation

/* In a storyboard-based application, you will often want to do a little preparation before navigation */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Welcome"])
    {
        WelcomeViewController *welcomeViewControllerObj =  [segue destinationViewController];
        welcomeViewControllerObj.strWelcomeText = @"WELCOME ABOARD!";
        
    }

}


-(void)getUserdetailsFromServer
{
    [self showLoader];
    
    AFHTTPRequestOperationManager *manager = [Util getAppOperationRequestManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/users/uid/%@",ServerURL,[Util getNewUserID]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"user details:%@",responseObject);
         [self removeLoader];
         [Util setScreenName:[(NSMutableDictionary*)responseObject valueForKey:@"screenName_s"]];
         [self saveUserDetailswithDict:(NSMutableDictionary*)responseObject];
         [self performSegueWithIdentifier:@"welcome" sender:self];
         
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             RLogs(@"user details Error: %@", error.description);
             [self removeLoader];
             [self showNetworkErrorAlertWithTag:222222];
             
         }];
    
}

#pragma mark Save user data to DB
/*saving user datails to DB */

-(void)saveUserDetailswithDict :(NSMutableDictionary*)dictUserDetails
{
    
    NSError *error= nil;
    
    context = [APP_DELEGATE managedObjectContext];

    NSManagedObject *objUserInfo= [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
    
    [objUserInfo setValue:[dictUserDetails valueForKey:@"name_s"] forKey:@"name"];
    [objUserInfo setValue:[dictUserDetails valueForKey:@"screenName_s"] forKey:@"screenName"];
    [objUserInfo setValue:[dictUserDetails valueForKey:@"phoneNumber_s"] forKey:@"phoneNumber"];
    [objUserInfo setValue:[dictUserDetails valueForKey:@"uid"] forKey:@"userId"];
    [objUserInfo setValue:[dictUserDetails valueForKey:@"statusMessage"] forKey:@"statusMessage"];
    [objUserInfo setValue:[dictUserDetails valueForKey:@"userType_s"] forKey:@"userType"];
    [objUserInfo setValue:[dictUserDetails valueForKey:@"email_s"] forKey:@"email"];
    [objUserInfo setValue:[NSNumber numberWithBool:YES] forKey:@"activated"];
    
    [objUserInfo setValue:[NSNumber numberWithInteger:[[dictUserDetails valueForKey:@"activatedAt"]integerValue] ] forKey:@"activatedAt"];
    
    [objUserInfo setValue:[NSNumber numberWithInteger:[[dictUserDetails valueForKey:@"createdAt"]integerValue] ] forKey:@"createdAt"];
    
    [objUserInfo setValue:[NSNumber numberWithInteger:[[dictUserDetails valueForKey:@"lastUpdatedAt"]integerValue] ] forKey:@"lastUpdatedAt"];
    
    [objUserInfo setValue:[dictUserDetails valueForKey:@"avatar"] forKey:@"avatar"];
    
    
    
    NSArray *aryPreferredChannels = [dictUserDetails valueForKey:@"preferredChannels"];
    
  
    
    for(int i=0;i< [aryPreferredChannels count];i++)
    {
        NSManagedObject *objInterests= [NSEntityDescription insertNewObjectForEntityForName:@"Interests" inManagedObjectContext:context];
        
        [objInterests setValue:[aryPreferredChannels objectAtIndex:i] forKey:@"interestName"];
        if (![context save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }
        
    }
    
    
    
    if (![context save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
    
}

@end
