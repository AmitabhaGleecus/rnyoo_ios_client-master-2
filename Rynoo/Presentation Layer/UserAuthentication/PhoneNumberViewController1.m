//
//  PhoneNumberViewController.m
//  Rynoo
//
//  Created by Rnyoo on 08/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PhoneNumberViewController1.h"
#import "VerificationCodeViewController.h"
#import "AFNetworking.h"
#import "TermsOfUseViewController.h"

@interface PhoneNumberViewController1 ()
{
    NSMutableArray *aryChannelsList;
    NSMutableDictionary *dictCountry;
    NSMutableArray *aryChannelNames;
}
@property (strong, nonatomic) IBOutlet UIView *contentview;

@end

@implementation PhoneNumberViewController1
@synthesize txt_CountryField;

/* Update Constraints */

-(void)updateViewConstraints
{
    [super updateViewConstraints];

    if(APP_DELEGATE.isPortrait)
    {
        _tblTopConstraint.constant = 100;
    }
    else
    {
        _tblTopConstraint.constant = 20;

    }
    
    [_tblUserDetails reloadData];
    
    if(poplistview.superview)
    {
        if([Util isIOS8])
        {
            [poplistview dismiss];
            [self showCountries];
        }
       
     
    }

}

# pragma mark view lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    countryNamesArr = [[NSMutableArray alloc] init];
   /* [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orienationChagne:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];*/
     self.navigationController.navigationBarHidden = NO;
    
    
    
    aryChannelsList = [[NSMutableArray alloc]init];
    dictCountry = [[NSMutableDictionary alloc]init];
    aryChannelNames= [[NSMutableArray alloc]init];

    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    _tblUserDetails.scrollEnabled = NO;
    _tblUserDetails.separatorColor = [Util appHeaderColor];
    if ([_tblUserDetails respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tblUserDetails setSeparatorInset:UIEdgeInsetsZero];
    }
    
    _tblUserDetails.backgroundColor = [UIColor clearColor];
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Rnyoo uses your phone number to verify your identity. This information will not be shared .\nPlease refer to Privacy Policy"]];
    [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange([commentString length]-14,14)];
    
    UIColor* textColor = [Util appHeaderColor];
    
    [commentString setAttributes:@{NSForegroundColorAttributeName:textColor,NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleNone]} range:NSMakeRange([commentString length]-14,14)];
    // Or for adding Colored text use----------
    [_lblPrivatePolicy setAttributedText:commentString];
    
    
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(privacyPolicy:)];
    [tapRecognizer setDelegate:self];
    [_lblPrivatePolicy addGestureRecognizer:tapRecognizer];

    
    if([self connected])
    {
    [self getCountriesList];
    }
    else
    {
        RLogs(@"NO Internet");
       // [self showNoInternetMessage];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
    
    [self setNavigationBarTitle:@"Phone Number"];
    
}

-(void)viewDidLayoutSubviews
{
    if([_tblUserDetails respondsToSelector:@selector(setSeparatorInset:)])
    [_tblUserDetails setSeparatorInset:UIEdgeInsetsZero];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    RLogs(@"didFailWithError: %@", error);
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dontAllow"];
    [[NSUserDefaults standardUserDefaults] synchronize];
 //   UIAlertView *errorAlert = [[UIAlertView alloc]
  //                             initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
   // [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
    }
    
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        RLogs(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0)
        {
            placemark = [placemarks lastObject];
            
            
            [locationManager stopUpdatingLocation];
            RLogs(@"%@",[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                         placemark.subThoroughfare, placemark.thoroughfare,
                         placemark.postalCode, placemark.locality,
                         placemark.administrativeArea,
                         placemark.country]);
          
            

            
        }
        else
        {
            RLogs(@"%@", error.debugDescription);
        }
    } ];
    
}

#pragma mark UITableView Delegate and DataSource Methods
#pragma mark ===========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
       return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        
        UITextField *txtFldDetails = [[UITextField alloc] init];//WithFrame:CGRectMake(5, 20, cell.contentView.frame.size.width - 10, cell.contentView.frame.size.height - 10)];
        
        [txtFldDetails setBackgroundColor:[UIColor clearColor]];
        [txtFldDetails setFont:[Util Font:FontTypeRegular Size:13.0]];
        
        
        
        if(indexPath.row == 0)
        {
            txtFldDetails.placeholder = @"YOUR EMAIL";
            self.txt_Email = txtFldDetails;
           NSString *strEmail = [Util getEmail];
            self.txt_Email.text = strEmail;
            self.txt_Email.userInteractionEnabled = NO;
        }
        else if (indexPath.row == 1)
        {
            txtFldDetails.placeholder = @"YOUR COUNTRY";
            txtFldDetails.delegate =self;
            self.txt_CountryField = txtFldDetails;
            
        }
        else
        {
            txtFldDetails.placeholder = @"YOUR PHONE NUMBER";
            self.txt_PhoneNumber = txtFldDetails;
            self.txt_PhoneNumber.keyboardType = UIKeyboardTypeNumberPad;
            txtFldDetails.delegate =self;
        }
        
        txtFldDetails.tag = 111;
        [cell.contentView addSubview:txtFldDetails];
        
        if([objUtil isiOS7])
        [[UITextField appearance] setTintColor:[Util appHeaderColor]];
        else
        {
            
        }

        cell.backgroundColor = [UIColor clearColor];
        
        
    }
    
    
    UITextField *txtFld = (UITextField*)[cell.contentView viewWithTag:111];
    txtFld.frame = CGRectMake(5, 20, tableView.frame.size.width - 10, cell.frame.size.height - 10);
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]){
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero]; // ios 8 newly added
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

/* To dismiss keyboard when clicked on view*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txt_PhoneNumber resignFirstResponder];
}

#pragma mark - UIPopoverListViewDataSource
#pragma mark ===========================================

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:identifier] ;
    
    cell.textLabel.text = [[[countryNamesArr objectAtIndex:indexPath.row] allKeys] objectAtIndex:0];

      return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView numberOfRowsInSection:(NSInteger)section
{
    return [countryNamesArr count];
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView  didSelectIndexPath:(NSIndexPath *)indexPath
{
    
    // your code here
    self.txt_CountryField.text = [[[countryNamesArr objectAtIndex:indexPath.row] allKeys] objectAtIndex:0];
    
    NSString *countryCode = [[countryNamesArr objectAtIndex:indexPath.row] objectForKey:self.txt_CountryField.text];
    
    [dictCountry setValue:countryCode forKey:@"countryCode"];
    [dictCountry setValue:self.txt_PhoneNumber.text forKey:@"number"];
   
    RLogs(@"dict Country:%@",dictCountry);
    
 }

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}


#pragma mark TextField Delegates

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.txt_CountryField)
    {
       
        [self showCountries];
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

/* To select countries from dropdown */

-(void)showCountries
{
    [_txt_PhoneNumber resignFirstResponder];
    CGFloat xWidth = self.view.window.bounds.size.width - 50.0f;
    CGFloat yHeight = 200.0f;
    CGFloat yOffset = (self.view.window.bounds.size.height - yHeight)/2.0f;
    poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = TRUE;
    poplistview._titleView.text = @"Countries";
    poplistview._titleView.font = [Util Font:FontTypeLight Size:15];
    [poplistview showInView:self.view];
   
}

/* To dismiss keypad for PhoneNumber field */

-(void)doneWithNumberPad
{
    [ self.txt_PhoneNumber resignFirstResponder];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(poplistview.superview)
    {
        [poplistview dismiss];
        [self showCountries];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    
    
    if(size.width < 480.0)
    {
        APP_DELEGATE.isPortrait = YES;
    }
    else
    {
        APP_DELEGATE.isPortrait = NO;
        
    }
    
    if(poplistview.superview)
    {
        [poplistview dismiss];
        [self showCountries];
    }
}

#pragma  mark button Actions
/* Navigates to Privacy Policy */

-(void)privacyPolicy:(UIGestureRecognizer*)sender
{
//    [Util setTermsOfUseTitle:@"Privacy Policy"];
    
    [self performSegueWithIdentifier:@"TermsView" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TermsView"]) {
        TermsOfUseViewController *terms = (TermsOfUseViewController*)segue.destinationViewController;
        terms.titleStr = @"Privacy Policy";
    }
}

/* Sync with server */

- (IBAction)btn_SendVerificationCode:(id)sender
{
    if([self connected])
    {
        if([self.txt_PhoneNumber.text length] !=  10)
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Enter your 10 Digit number that you are using now. you will get a verification code now." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        else
        {
            if([self connected])
            {
                [dictCountry setValue:self.txt_PhoneNumber.text forKey:@"number"];

                [self getChannels];
        //        [self getIntrests];
             
        //        [self performSegueWithIdentifier: @"VerificationCode" sender: self];

            }
            else
            {
                RLogs(@"no internet");
                [self showNoInternetMessage];
                return;
                
            }
        }
    }
    else
    {
        [Util showNoInternetMsg];
    }

}

# pragma mark-Orientation Methods For UIPopover List

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation
{
    CGAffineTransform transform;
    switch (orientation)
    {
            
        
        case UIInterfaceOrientationLandscapeLeft:
        {
            RLogs(@"UIInterfaceOrientationLandscapeLeft");
            transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
            break;
            
        case UIInterfaceOrientationLandscapeRight:
        {
            RLogs(@"UIInterfaceOrientationLandscapeRight");

            transform =  CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            RLogs(@"UIInterfaceOrientationPortraitUpsideDown");

            transform =  CGAffineTransformMakeRotation(-M_PI);
        }
            break;
            
        case UIInterfaceOrientationPortrait:
        {
            RLogs(@"UIInterfaceOrientationPortrait");
        
            transform =  CGAffineTransformMakeRotation(-M_PI);

        }
            break;
        case UIInterfaceOrientationUnknown:
        {
            RLogs(@"Unknown Orient");
        }
            break;
            
    }
    

    return transform;
}


#pragma mark web service calls

/* get Countries from server */

-(void)getCountriesList
{
    AFHTTPRequestOperationManager *manager = [Util getAppOperationRequestManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/countries",ServerURL] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *dict = [responseObject objectForKey:@"countries"];
         
         for(NSString *strKey in [dict allKeys])
         {
             NSString *countryName = strKey;
             NSString *countryCode = [dict objectForKey:strKey];
             RLogs(@"Country name and Codes are %@---%@",countryName,countryCode);
             NSMutableDictionary *eachCountryValueDict = [NSMutableDictionary dictionaryWithObject:countryCode forKey:countryName];
             [countryNamesArr addObject:eachCountryValueDict];
             
         }
         
         RLogs(@"countryNamesArr : %@", countryNamesArr);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         RLogs(@"Error: %@", error);
     }];
    
}

/* Getting channels from server */

-(void)getChannels
{
    [self showLoader];
    
    AFHTTPRequestOperationManager *manager = [Util getAppOperationRequestManager];

    
    [manager GET:[NSString stringWithFormat:@"%@/channels",ServerURL] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         aryChannelsList = [responseObject objectForKey:@"channels"];

         for(int i=0;i< [aryChannelsList count];i++)
         {
             [aryChannelNames addObject:[[aryChannelsList objectAtIndex:i]valueForKey:@"channelName"]];
             
         }
         
         if([self connected])
         {
             [self SendReqtoCreateUser];
         }
         else
         {
             [self showNoInternetMessage];
             return ;
         }

         
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             RLogs(@"Error: %@", error);
             [self removeLoader];
             [self showNetworkErrorAlertWithTag:111111];
             
         }];
}


/* calling Create User websevice */

-(void)SendReqtoCreateUser
{
    
   NSMutableDictionary *dictUserDetails = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserDetails"] mutableCopy];
   
    
    [dictUserDetails setValue:dictCountry forKey:@"phone"];
    RLogs(@"%@",dictUserDetails);
    [dictUserDetails setValue:PlatForm forKey:@"platformForReg"];
    BOOL isActive = false;
    [dictUserDetails setValue:[NSNumber numberWithBool:isActive] forKey:@"activated"];
    [dictUserDetails setValue:DefaultTimeZone forKey:@"timeZone"];
    [dictUserDetails setValue:DefaultStatusMsg forKey:@"statusMessage"];

    RLogs(@"array channel names:%@",aryChannelNames);
    [dictUserDetails setValue:aryChannelNames forKey:@"preferredChannels"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    [dict setValue:[Util getDeviceToken]  forKey:@"deviceId"];
    [dict setValue:[Util getDeviceRegisterID] forKey:@"registrationId"];
    
    [dict setValue:@"iPhone" forKey:@"deviceType"];
    
    RLogs(@"version:%@",[Util getOSVersion]);
    
    [dict setValue:[Util getOSVersion] forKey:@"osVersion"];
    
      
    [dict setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] forKey:@"registeredOn"];
    

    NSMutableArray *aryDevicedata = [[NSMutableArray alloc]init];

    [aryDevicedata addObject:dict];
    NSMutableDictionary *dictDevicedata = [[NSMutableDictionary alloc]init];
    [dictDevicedata setValue:aryDevicedata forKey:@"iOS"];
    [dictUserDetails setValue:dictDevicedata forKey:@"devices"];
    
    RLogs(@"final dict:%@", dictUserDetails);
 
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
        
    [manager POST:[NSString stringWithFormat:@"%@/users/new",ServerURL] parameters:dictUserDetails success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         
         RLogs(@"create new user response:%@",responseObject);
         if([[responseObject valueForKey:@"status"] isEqualToString:@"error"])
         {
             
             [self removeLoader];
             UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Rnyoo" message:@"Already registered with this number.Please enter another number" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
             return;

         }
         RLogs(@"uid:%@",[responseObject valueForKey:@"id"]);
         RLogs(@"activationcode:%@",[responseObject valueForKey:@"activationCode"]);
         [Util setNewUserID:[responseObject valueForKey:@"id"]];
         [Util setActivationCode:[responseObject valueForKey:@"activationCode"]];
         
         
         NSString *strDeviceId = [Util getDeviceToken];
         NSString *strUserId = [Util getNewUserID];
         
         dictLogin = [[NSMutableDictionary alloc]init];
         [dictLogin setValue:strUserId forKey:@"uid"];
         [dictLogin setValue:strDeviceId forKey:@"devid"];
         [self loginwithDict:dictLogin from:@"Phone"];
         
        
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             [self removeLoader];
             
             RLogs(@"create new user Error: %@", error.description);
          
             
             [self showNetworkErrorAlertWithTag:222222];
             
         }];

}

/* Navigating to Verfication screen */

-(void)SuccesssfullyLoggedIn:(NSString*)strScreen
{
    [self performSegueWithIdentifier:@"VerificationCode" sender:self];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    
    if(alertView.tag == 111111)
    {
        if(buttonIndex == 0)
        {
            [self getChannels];
            return;
        }
    }
    else if(alertView.tag == 222222)
    {
        if(buttonIndex == 0)
        {
            [self SendReqtoCreateUser];
            return;
        }
    }
    else if (alertView.tag == 333333)
    {
        if(buttonIndex == 0)
        {
            [self loginwithDict:dictLogin from:@"Phone"];
        }
    }

    
}


@end
