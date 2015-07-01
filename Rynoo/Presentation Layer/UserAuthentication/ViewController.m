//
//  ViewController.m
//  Rynoo
//
//  Created by Rnyoo  on 07/11/14.
//  Copyright (c) 2014 Rnyoo . All rights reserved.
//

#import "ViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "PhoneNumberViewController1.h"
#import <FacebookSDK/FacebookSDK.h>
#import "WelcomeViewController.h"
#import "UserInfo.h"
#import "Interests.h"
#import "TermsOfUseViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize context;

/* Update Constraints */

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    RLogs(@"udate view");
    
    int xpos = 0.0;
    
    if(!APP_DELEGATE.isPortrait)
    {
        RLogs(@"landscape");
        
        if(![objUtil isiPhone5])
        {
            xpos = 300;
            _logoLeftConstraint.constant = 40;
            _lblBottomConstraint.constant = 90;

        }
        else
        {
            xpos = 360;
            _logoLeftConstraint.constant = 70;
            _lblBottomConstraint.constant = 90;


        }
        
        _logoTopConstraint.constant = 100;

        [_imgLoginBg setImage:[UIImage imageNamed:@"Login_BG_Landscape1.png"]];

    }
    else
    {
        xpos = 94;
        
        
        [_imgLoginBg setImage:[UIImage imageNamed:@"Login_BG1.png"]];

        _logoLeftConstraint.constant = 50;
        _lblBottomConstraint.constant = 50;
        _logoTopConstraint.constant = 80;
        
        if([objUtil isiPhone5])
        {
            _logoTopConstraint.constant = 184;

        }
        else
        {
            _logoTopConstraint.constant = 140;

        }


    }
    
    RLogs(@"xpos - %d", xpos);
    _signInLeftConstraitn.constant = xpos;
    _termsLblLeftConstraint.constant = xpos - 10;
    
}

# pragma mark view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    context = [APP_DELEGATE managedObjectContext];

    self.navigationController.navigationBarHidden = YES;
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"We won't post anything on your Facebook or Google+ account.\nRead our Terms of Use"]];
    [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange([commentString length]-12,12)];
    
    UIColor* textColor = [UIColor whiteColor];
    
    [commentString setAttributes:@{NSForegroundColorAttributeName:textColor,NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]} range:NSMakeRange([commentString length]-12,12)];
    // Or for adding Colored text use----------
    [_lblPostAndTerms setAttributedText:commentString];
    
    
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(btn_TermsOfUse:)];
    [tapRecognizer setDelegate:self];
    [_lblPostAndTerms addGestureRecognizer:tapRecognizer];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.view layoutSubviews];
}

# pragma mark button actions

- (IBAction)btn_googleAction:(id)sender
{
    if(![self connected])
    {
        [self showNoInternetMessage];
        return;
    }
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    
      RLogs(@"userID - %@, %@", signIn.userID, signIn.userEmail);
    // You previously set kClientID in the "Initialize the Google+ client" step
    signIn.clientID = kClientId;
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    signIn.shouldFetchGoogleUserID = YES;

     // signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    
    signIn.scopes = [NSArray arrayWithObjects:@"https://www.googleapis.com/auth/plus.login", nil];
    
    
   // signIn.scopes = @[ @"profile" ];
    
    /*signIn.scopes = [NSArray arrayWithObjects:
                     kGTLAuthScopePlusLogin,@"https://www.googleapis.com/auth/userinfo.email" ,@"https://www.googleapis.com/auth/contacts.readonly",nil];*/

    signIn.delegate = self;
    
    
   if([signIn hasAuthInKeychain])
    {
        RLogs(@"already logged in");
        [signIn trySilentAuthentication];
    }
    else
    {
        if([self connected])
        {
            [signIn authenticate];
        }
        else
        {
            [self showNoInternetMessage];
            return;
        }
    }


}

/* The authorization has finished and is successful if |error| is |nil|.*/

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth  error: (NSError *) error
{
    if(error)
    {
        RLogs(@"Received error %@ and auth object %@",error, auth);
        [self showTheAlert:@"Unable to login. Please try again."];
    }
    else
    {
        if([self connected])
        {
       // NSString *serverCode = [GPPSignIn sharedInstance].homeServerAuthorizationCode;

        GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
        if (person != nil) {
            
            if([self connected])
              {
                  [self showLoader];
                [Util setGmailAccessToken:[auth.parameters objectForKey:@"access_token"]];
                
                NSString *strEmail = [GPPSignIn sharedInstance].userEmail;
                screenName = [[strEmail componentsSeparatedByString:@"@"] objectAtIndex:0];
                
                [Util setEmail:strEmail];
                
                RLogs(@"%@",[person.JSON valueForKey:@"displayName"]);
                NSUserDefaults *fbPrefs = [NSUserDefaults standardUserDefaults];
                
                NSMutableDictionary *dict= [[NSMutableDictionary alloc]init];
                [dict setValue:[person.JSON valueForKey:@"displayName"] forKey:@"name_s"];
                [dict setValue:UserType forKey:@"userType_s"];
                RLogs (@"Result: %@", screenName);
                [dict setValue:screenName forKey:@"screenName_s"];
                [dict setValue:strEmail forKey:@"email_s"];
                [dict setValue:@"Google+" forKey:@"oauthSource"];
                NSString *imageURLString = person.image.url;
                if (imageURLString)
                {
                    [dict setValue:imageURLString forKey:@"avatar"];
                }
                RLogs(@"dict:%@",dict);
                
                [fbPrefs setObject:dict forKey:@"UserDetails"];
                [fbPrefs synchronize];
                
                if([imageURLString rangeOfString:@"?"].length > 0)
                {
                    NSArray *arySeperator = [imageURLString componentsSeparatedByString:@"?"];
                    NSString *result = [arySeperator lastObject];
                    if([result rangeOfString:@"sz"].length > 0)
                    {
                        NSArray *aryLastObject = [result componentsSeparatedByString:@"="];
                        
                        if([aryLastObject count] == 2)
                        {
                            if([[aryLastObject objectAtIndex:1] isEqualToString:@"150"])
                            {
                                
                            }
                            else
                            {
                                imageURLString = [NSString stringWithFormat:@"%@?sz=150",[arySeperator objectAtIndex:0]];
                            }
                        }
                        
                       // imageURLString=   [imageURLString stringByReplacingOccurrencesOfString:[aryLastObject objectAtIndex:1] withString:@"150"];
                    }
                }
                
                RLogs(@"image URL - %@", imageURLString);
                [Util setImageUrl:imageURLString];
                  
                      [self searchUser];
                  

              }
            }
            else
            {
                [self showNoInternetMessage];
                return;
            }

        }

    }

}

-(void)fetchFacebookUserProfileData
{
    RLogs(@"fetch fb data session");

    NSArray *requestPermissions = @[@"public_profile",@"email",@"user_about_me",@"user_friends"];
    
    
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  
                                  if ([requestPermissions count] > 0){
                                      
                                      [FBSession.activeSession requestNewReadPermissions:requestPermissions
                                                                       completionHandler:^(FBSession *session, NSError *error) {
                                                                           if (!error) {
                                                                               
                                                                               [self makeRequestForUserData];
                                                                               
                                                                           } else {
                                                                               
                                                                               RLogs(@"error in requesting user data- %@", [error description]);
                                                                           }
                                                                       }];
                                  }
                              }
                              else {
                                  
                                  RLogs(@"error in requesting user permissions");
                              }
                          }];
    
}

- (void) makeRequestForUserData
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            RLogs(@"%@",[NSString stringWithFormat:@"user info: %@", result]);
            
            
            NSUserDefaults *fbPrefs = [NSUserDefaults standardUserDefaults];
            
            [Util setEmail:[result valueForKey:@"email"]];

            screenName = [[[result valueForKey:@"email"] componentsSeparatedByString:@"@"] objectAtIndex:0];

            if([self connected])
            {
                [self searchUser];
            }
            else
            {
                [self showNoInternetMessage];
                return;
            }
            
            NSMutableDictionary *dict= [[NSMutableDictionary alloc]init];
            [dict setValue:[result valueForKey:@"first_name"] forKey:@"name_s"];
            [dict setValue:UserType forKey:@"userType_s"];
            
            
            
            RLogs (@"Result: %@", screenName);
            
            
            
            [dict setValue:screenName forKey:@"screenName_s"];
            [dict setValue:[result valueForKey:@"email"]forKey:@"email_s"];
            [dict setValue:@"Facebook" forKey:@"oauthSource"];
            
            NSString *imageURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[result valueForKey:@"id"]];

            [dict setValue:imageURLString forKey:@"avatar"];
            
            RLogs(@"dict:%@",dict);
            
            [fbPrefs setObject:dict forKey:@"UserDetails"];            
            [fbPrefs synchronize];
            
            [Util setImageUrl:imageURLString];
            
//            [self performSegueWithIdentifier: @"PhoneNumber" sender: self];

      

            
        } else {
            
            [self showTheAlert:@"Unable to login. Please try again."];
            RLogs(@"error in getting user data");
        }
        
    }];
}
#pragma mark FaceBook Login

-(IBAction)btn_facebookAction:(id)sender
{
    
    if(![self connected])
    {
        [self showNoInternetMessage];
        return;
        
    }
    else
    {
        [self fbloginClicked];
        return;
    }
    
}

// if the session is closed, then we open it here, and establish a handler for state changes

-(void)fbloginClicked
{
    // if the session is open, then load the data for our view controller
    
    if (!FBSession.activeSession.isOpen)
    {
        
        RLogs(@"not open");
        // if the session is closed, then we open it here, and establish a handler for state changes
        
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"public_profile",@"email", nil];
        
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              //                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                              //                                                                                                  message:error.localizedDescription
                                              //                                                                                                 delegate:nil
                                              //                                                                                        cancelButtonTitle:@"OK"
                                              //                                                                                        otherButtonTitles:nil];
                                              //                                              [alertView show];
                                              [self handleAPICallError:error];
                                          } else if (session.isOpen) {
                                              [self fbloginClicked];
                                          }
                                      }];
        return;
    }
    else
    {
        RLogs(@"open");
        
        RLogs(@"Token - %@",[[FBSession activeSession] accessTokenData].accessToken);
        RLogs(@"Expiration Date - %@",[[[FBSession activeSession] accessTokenData].expirationDate description]);

        
        //[FBSession activeSession].
        
        [self userLoggedInThroughFB];
        
    }
    
}

/* Error handling if Fb request failed*/

- (void)handleAPICallError:(NSError *)error
{
    NSString *alertMessage;
    
    // If the user has removed a permission that was previously granted
    if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryPermissions) {
        RLogs(@"Re-requesting permissions");
        // Ask for required permissions.
        //[self requestPermission];
        return;
    }
    
    // Some Graph API errors need retries, we will have a simple retry policy of one additional attempt
    // We also retry on a throttling error message, a more sophisticated app should consider a back-off period
    int retryCount = 0;
    if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryRetry ||
        [FBErrorUtility errorCategoryForError:error] == FBErrorCategoryThrottling) {
        if (retryCount < 2) {
            
            RLogs(@"Retrying open graph post");
            // Recovery tactic: Call API again.
            //[self makeGraphAPICall];
            
            [self userLoggedInThroughFB];
            return;
        } else {
            RLogs(@"Retry count exceeded.");
            return;
        }
    }
    
    // For all other errors...
    NSString *alertText;
    NSString *alertTitle;
    
    // Get more error information from the error
    int errorCode = error.code;
    NSDictionary *errorInformation = [[[[error userInfo] objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"]
                                       objectForKey:@"body"]
                                      objectForKey:@"error"];
    int errorSubcode = 0;
    if ([errorInformation objectForKey:@"code"]){
        errorSubcode = [[errorInformation objectForKey:@"code"] integerValue];
    }
    
    // Check if it's a "duplicate action" error
    if (errorCode == 5 && errorSubcode == 3501) {
        // Tell the user the action failed because duplicate action-object  are not allowed
        alertTitle = @"Duplicate action";
        alertText = @"You already did this, you can perform this action only once on each item.";
        
        // If the user should be notified, we show them the corresponding message
    } else if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Something Went Wrong";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
    } else {
        // show a generic error message
        RLogs(@"Unexpected error posting to open graph: %@", error);
        alertTitle = @"Something went wrong";
        alertMessage = @"Please try again later.";
    }
    [self showMessage:alertMessage withTitle:alertTitle];
}

#pragma mark FBUser Logged in methods
-(void)userLoggedInThroughFB
{
   
    
  //   [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection,   FBGraphObject *result, NSError *error){
         
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *result, NSError *error)
    {
        if (!error)
        {
            
            RLogs(@"%@",[NSString stringWithFormat:@"user info: %@", result]);
            
            if([[result valueForKey:@"email"] length] == 0)
            {
                [FBSession setActiveSession:nil];
                
                [self showTheAlert:@"Unable to fetch email from facebook"];
                return;
            }
            
            NSUserDefaults *fbPrefs = [NSUserDefaults standardUserDefaults];
            NSLog(@"Email : %@",[result valueForKey:@"email"]);
            [Util setEmail:[result valueForKey:@"email"]];
            screenName = [[[result valueForKey:@"email"] componentsSeparatedByString:@"@"] objectAtIndex:0];
            
            if([self connected])
            {
                [self searchUser];
            }
            else
            {
                [self showNoInternetMessage];
                return;
            }
            
            NSMutableDictionary *dict= [[NSMutableDictionary alloc]init];
            [dict setValue:[result valueForKey:@"first_name"] forKey:@"name_s"];
            [dict setValue:UserType forKey:@"userType_s"];
            
            NSLog(@"Result: %@", screenName);
            
            [dict setValue:screenName forKey:@"screenName_s"];
            [dict setValue:[result valueForKey:@"email"]forKey:@"email_s"];
            [dict setValue:@"Facebook" forKey:@"oauthSource"];
            
            NSString *imageURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[result valueForKey:@"id"]];
            [dict setValue:imageURLString forKey:@"avatar"];
            RLogs(@"dict:%@",dict);
            [fbPrefs setObject:dict forKey:@"UserDetails"];
            [fbPrefs synchronize];
            [Util setImageUrl:imageURLString];

        }
        else
        {
            
            [self showTheAlert:@"Unable to login. Please try again."];
            RLogs(@"error in getting user data");
        }
    }];
    
    
}

/* show alert if fb login failed */

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    RLogs(@"session");
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        
        [self fetchFacebookUserProfileData];

        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        
        return;
    }
    
    // Handle errors
    if (error){
       
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showTheAlert:alertText];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                RLogs(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showTheAlert:alertText];

                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showTheAlert:alertText];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
    }
}


/*- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    if(error)
    {
        RLogs(@"%@", error.description);
        return;
        
    }
    switch (state) {
        case FBSessionStateOpen:
        {
            [self fetchFacebookUserProfileData];
        }
            break;
            
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            
        {
            RLogs(@"Session failed or login failed");
            
        }
            break;
            
        default:
            break;
    }
    
}*/


- (NSString *)createImagePath:(NSString *)imageName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    return savedImagePath;
    
}

/* Terms of use button action */

-(void)btn_TermsOfUse:(id)sender
{
//    [Util setTermsOfUseTitle:@"Terms of Use"];
    [self performSegueWithIdentifier:@"TermsView" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"TermsView"])
    {
        TermsOfUseViewController *terms = (TermsOfUseViewController*)segue.destinationViewController;
        terms.titleStr = @"Terms Of Use" ;
    }
    if ([[segue identifier] isEqualToString:@"PhoneNumber"])
    {
      //  PhoneNumberViewController1 *PhoneNumberViewControllerObj =  [segue destinationViewController];
        
    }
    if ([[segue identifier] isEqualToString:@"Welcome"])
    {
        WelcomeViewController *welcomeViewControllerObj =  [segue destinationViewController];
        welcomeViewControllerObj.strWelcomeText = @"WELCOME BACK!";
        
    }
    else
    {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;
        RLogs(@"back btn");
    }
}

# pragma mark Webservice calls

/* checking user ,if already registered or not */

-(void)searchUser
{
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [self showLoader];
    NSMutableDictionary *dictName = [[NSMutableDictionary alloc]init];
    [dictName setValue:screenName forKey:@"screenName_s"];

    NSLog(@"dict:%@",dictName);
    NSLog(@"URL:%@",[NSString stringWithFormat:@"%@/users/search",ServerURL]);
    
       [manager POST:[NSString stringWithFormat:@"%@/users/search",ServerURL] parameters:dictName success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"search response:%@",responseObject);
         NSArray *arrUsers = [(NSDictionary*)responseObject valueForKey:@"users"];
         
         if([arrUsers count])
         {
             NSDictionary *userInfo = [arrUsers objectAtIndex:0];
             
             // delete userdata if another user logged in
             [self deletePreviousUserDataWithUserId:[userInfo valueForKey:@"uid"]];
             NSLog(@"previous user screen name:%@",[Util getPreviousUserScreenName]);
             if(![[[Util getPreviousUserScreenName]lowercaseString] isEqualToString:[[userInfo valueForKey:@"screenName_s"]lowercaseString]])
             {
                 [self deleteDataFromDocumentsDirectory];
             }

             NSString *strImageUrl = [userInfo valueForKey:@"avatar"];
            
             [Util setNewUserID:[userInfo valueForKey:@"uid"]];
             [Util setImageUrl:strImageUrl];
             [Util setScreenName:[userInfo valueForKey:@"screenName_s"]];
             
             NSString *strDeviceId = [Util getDeviceToken];
             NSString *strUserId = [Util getNewUserID];

             dictLogin = [[NSMutableDictionary alloc]init];
             [dictLogin setValue:strUserId forKey:@"uid"];
             [dictLogin setValue:strDeviceId forKey:@"devid"];
             [self loginwithDict:dictLogin from:@"Search"];
         }
         else
         {
             [self performSegueWithIdentifier: @"PhoneNumber" sender: self];
         }
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
             NSLog(@"Error: %@", error.description);
             [self removeLoader];
             [self showNetworkErrorAlertWithTag:111111];
             
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag ==  111111)
    {
        //Search User tag.
        if(buttonIndex == 0)
        {
            [self searchUser];
        }
    }
    else if (alertView.tag == 222222)
    {
        //GetUser details tag.
        if(buttonIndex == 0)
        {
            [self getUserdetailsFromServer];
        }
    }
    else if (alertView.tag == 333333)
    {
        if(buttonIndex == 0)
        {
            [self loginwithDict:dictLogin from:@"Search"];
        }
    }
}

/* login callback method */

-(void)SuccesssfullyLoggedIn:(NSString*)strScreen
{
    if([self connected])
    {
        [self getUserdetailsFromServer];
    }
    else
    {
        [self showNoInternetMessage];
        return;
    }

}

/* Get user details from user if successfully logged in */

-(void)getUserdetailsFromServer
{
    [self showLoader];
    
    AFHTTPRequestOperationManager *manager = [Util getAppOperationRequestManager];
  
    [manager GET:[NSString stringWithFormat:@"%@/users/uid/%@",ServerURL,[Util getNewUserID]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"user details:%@",responseObject);
         [self removeLoader];
         [self saveUserDetailswithDict:(NSMutableDictionary*)responseObject];
         [self performSegueWithIdentifier:@"Welcome" sender:self];
         
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
        Interests *objInterests= [NSEntityDescription insertNewObjectForEntityForName:@"Interests" inManagedObjectContext:context];
        
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


#pragma mark get User data from DB

/* get user data from DB */
-(NSArray*)getUserDataFromDB
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    RLogs(@"all users array:%@",fetchedObjects);
    
    return fetchedObjects;

}

/* check for if another user logged in*/
-(void)deletePreviousUserDataWithUserId:(NSString*)userId
{
    NSArray *aryUsers = [self getUserDataFromDB];
    
    for(NSManagedObject *obj in aryUsers)
    {
        if(![[obj valueForKey:@"userId"] isEqualToString:userId])
        {
            [self deleteAllObjectsInCoreData];
        }
    }
    

}

/* deleting previous user data */
- (void)deleteAllObjectsInCoreData
{
  
    NSArray *allEntities = APP_DELEGATE.managedObjectModel.entities;
    for (NSEntityDescription *entityDescription in allEntities)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        
        fetchRequest.includesPropertyValues = NO;
        fetchRequest.includesSubentities = NO;
        
        NSError *error;
        NSArray *items = [self.context executeFetchRequest:fetchRequest error:&error];
        
        if (error) {
            RLogs(@"Error requesting items from Core Data: %@", [error localizedDescription]);
        }
        
        for (NSManagedObject *managedObject in items) {
            [self.context deleteObject:managedObject];
        }
        
        if (![self.context save:&error]) {
            RLogs(@"Error deleting %@ - error:%@", entityDescription, [error localizedDescription]);
        }
    }  
}
# pragma mark-Orientation Methods

-(BOOL)shouldAutorotate
{
    return YES;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
    [self.navigationController.view layoutSubviews];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)deleteDataFromDocumentsDirectory
{
   // delete data from clipboard folder
    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:CLIPBOARD_FOLDER];
    NSArray *imgPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
 
    for (NSString *imgName in imgPaths)
    {
        NSString *fullPath = [folderPath stringByAppendingPathComponent:imgName];

        BOOL success =  [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        if(!success)
        {
            NSLog(@"unable  to delete");
            
        }

    }
    
    // delete data from vault folder

    NSString *folderVaultPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:VAULT_FOLDER];
    NSArray *aryVaultImages = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderVaultPath error:nil];
    
    for (NSString *strPath in aryVaultImages)
    {
        NSString *fullPath = [folderVaultPath stringByAppendingPathComponent:strPath];

        BOOL success =  [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        if(!success)
        {
            NSLog(@"unable  to delete");
            
        }
    }
    
    // delete audio files

    NSString *folderHotspotAudioPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kHotspotAudioFile];
    NSArray *aryAudioPath = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderHotspotAudioPath error:nil];
    
    for (NSString *strAudioUrl in aryAudioPath)
    {
        NSString *fullPath = [folderHotspotAudioPath stringByAppendingPathComponent:strAudioUrl];

        BOOL success =  [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        if(!success)
        {
            NSLog(@"unable  to delete");
            
        }
    }

}

@end
