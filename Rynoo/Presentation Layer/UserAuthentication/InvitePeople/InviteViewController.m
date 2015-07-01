//
//  InviteViewController.m
//  Rynoo
//
//  Created by Rnyoo on 13/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "InviteViewController.h"
#import "InviteFriendsListViewController.h"
#import "XMLParser.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@interface InviteViewController (){
    
    NSMutableArray *gmailContactsarray;
    
    IBOutlet NSLayoutConstraint *topLabelConstraint;
    
    IBOutlet NSLayoutConstraint *btnVerticalSpacing;
}

@end

@implementation InviteViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetGmailContacts:) name:@"gmailContacts" object:nil];
    
    // Do any additional setup after loading the view.
    
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    self.navigationItem.hidesBackButton = NO;

    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    
    self.navigationItem.hidesBackButton = YES;
    
    [self setNavigationBarTitle:@"Invite Friends"];
    
    [self setRightBarButtonOnNavigationBarwithText:@"Skip"];
    
}

/* Update Constraints */

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if(APP_DELEGATE.isPortrait)
    {
        topLabelConstraint.constant = 100;
        btnVerticalSpacing.constant = 20;
    }
    else
    {
        topLabelConstraint.constant = 44;
        btnVerticalSpacing.constant = 5;
       
    }
}

/* Getting gmail contacts */

-(void)GetGmailContacts:(NSNotification *)notification
{
    gmailContactsarray = notification.object;
    
    [self removeLoader];
    
    [self performSegueWithIdentifier: @"Invite" sender: self];
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Invite"])
    {
        if([gmailContactsarray count])
        {
            
            InviteFriendsListViewController *object = (InviteFriendsListViewController *)[segue destinationViewController];
            object.isGmailContacts = YES;
            [object setGmailContactsWithArray:gmailContactsarray];
        }
    }
}



#pragma mark Invite button actions

/* Navigate to Invite screen */

- (IBAction)AddressBookInviteClicked:(id)sender {
    
    gmailContactsarray = nil;
    [self performSegueWithIdentifier: @"Invite" sender: self];
    
}
/* Fb invitation */

- (IBAction)FBInviteClicked:(id)sender {
    
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Work in Progress!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

/* Navigate to Invite screen */

- (IBAction)GoogleInviteClicked:(id)sender {
    
    
    NSString *gmail_token = [Util getGmailAccessToken];
    
    if([gmail_token length])
    {
        
        [self getGmailContcatsWithAccessToken:gmail_token];
    }
    else
    {
        [self gmailSignIn];
    }
    
}

/* Google signin */

-(void)gmailSignIn
{
    if([self connected]){
        GPPSignIn *signIn= [GPPSignIn sharedInstance];
        signIn.clientID = kClientId;
        signIn.shouldFetchGooglePlusUser = YES;
        signIn.shouldFetchGoogleUserEmail = YES;
        signIn.scopes = [NSArray arrayWithObjects:kGTLAuthScopePlusLogin,@"https://www.googleapis.com/auth/userinfo.email" ,@"https://www.googleapis.com/auth/contacts.readonly",nil];
        signIn.delegate = self;
        
        [signIn authenticate];
    }
    else{
        [self showNoInternetMessage];
        
    }
}

/* Google Plus signin delegate method after authorization*/

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth  error: (NSError *) error
{
    if(!error){
        
        [Util setGmailAccessToken:[auth.parameters objectForKey:@"access_token"]];
        
        [self getGmailContcatsWithAccessToken:[auth.parameters objectForKey:@"access_token"]];
    }
    else {
        
        [self showTheAlert:@"Unable to login. Please try again."];
        
    }
    
}

/* Getting google contacts */

-(void)getGmailContcatsWithAccessToken:(NSString *)token
{
    
    if([self connected]){
        
        [self showLoader];
        
        NSString *urlStr = [NSString stringWithFormat:@"https://www.google.com/m8/feeds/contacts/default/full?access_token=%@&max-results=2000", token];
        
        NSURL * url = [NSURL URLWithString:urlStr];
        NSData * data = [NSData dataWithContentsOfURL:url];
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        RLogs(@"response is ====%@", response);
        
        XMLParser *parserObj  = [[XMLParser alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
        parserObj.delegate = parserObj;
        BOOL success =  [parserObj parse];
        if(!success)
        {
            [self showTheAlert:@"Error while retrieving Gmail Contacts"];
            [self removeLoader];
            
        }
    }
    else{
        
        [self showNoInternetMessage];
    }
    
}

/* Navigation to home screen*/

-(void)rightBarButtonTapped:(id)sender
{
   // [self.navigationController popViewControllerAnimated:YES];
    
    [APP_DELEGATE setMenuScreenAsRootViewController];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
