
//
//  BaseViewController.m
//  Rynoo
//
//  Created by Rnyoo on 10/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    objUtil = [Util sharedInstance];
    
    if([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationUnknown)
    {
        RLogs(@"Unknown");
        
    }
    else
    {
    
    if(UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        APP_DELEGATE.isPortrait = YES;
    }
    else
    {
        APP_DELEGATE.isPortrait = NO;
    }
    }
    

    
    
    if (![objUtil isiOS7])
    {
        [self.navigationController.navigationBar setTintColor: [Util appHeaderColor]];
        
    }
    else
    {
        
        [self.navigationController.navigationBar setBarTintColor: [Util appHeaderColor]];
        
    }
    
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    self.navigationItem.hidesBackButton = YES;
    


    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:)
                                                 name:UIKeyboardDidChangeFrameNotification object:self.view.window];
   
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];

}

#pragma mark KeyBoard Notification calls
-(void)keyboardDidShow:(NSNotification*)notification
{
    //When keyboard appeared, we are moving the screen towards top.
    
    RLogs(@"keyboardDidShow - %@", [notification.userInfo description]);
    
    
}
-(void)keyboardFrameChanged:(NSNotification*)notification
{
    RLogs(@"keyboardFrameChanged");
    
}


-(void)keyboardWillBeHidden:(NSNotification*)notification
{
    //When keyboard will be hidden, resetting the frames.
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        UIDeviceOrientation deviceOrientation;
        switch ([[[UIDevice currentDevice] valueForKey:@"orientation"] integerValue]) {
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
    
    
    
}



- (BOOL)connected {
      
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
    
}

-(void)showNoInternetMessage
{
    UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:@"Rnyoo" message:@"Please check internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(BOOL)prefersStatusBarHidden   // iOS8 definitely needs this one. checked.
{
    return YES;
}

-(UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}*/
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
   // RLogs(@"size - %f, %f", size.width, size.height);
    
    
    if(size.width < 480.0)
    {
        APP_DELEGATE.isPortrait = YES;
    }
    else
    {
        APP_DELEGATE.isPortrait = NO;

    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    RLogs(@"should auto");
    
    
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        
        APP_DELEGATE.isPortrait = YES;
        
        RLogs(@"portrait");
    }
    else
    {
        APP_DELEGATE.isPortrait = NO;
    }
    return YES;
}


- (NSUInteger)supportedInterfaceOrientations // iOS 6 autorotation fix
{
    
    
    return UIInterfaceOrientationMaskAll;
}


- (BOOL)shouldAutorotate
{
    
    RLogs(@"should auto rotate");
    
    if(UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
        APP_DELEGATE.isPortrait = YES;
    else
        APP_DELEGATE.isPortrait = NO;
    
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(UIDeviceOrientationIsPortrait(toInterfaceOrientation))
    {
        APP_DELEGATE.isPortrait = YES;
    }
    else
    {
        APP_DELEGATE.isPortrait = NO;
    }
    
    
    [self updateViewConstraints];
    
}



- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
        

}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        
        APP_DELEGATE.isPortrait = NO;
        
    }
    else
    {
        APP_DELEGATE.isPortrait = YES;
    }
}

-(void)AttributeTitle:(NSString *)title withLength:(NSInteger)length
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title];
    
    NSRange range = NSMakeRange(0, length);
    [string addAttribute:NSFontAttributeName value:[Util Font:FontTypeRegular Size:19.0] range:range];
    
    range = NSMakeRange(length, title.length-length);
    [string addAttribute:NSFontAttributeName value:[Util Font:FontTypeHeavy Size:19.0] range:range];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    lbl.attributedText = string;
    lbl.textColor = [UIColor whiteColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.topItem.titleView = lbl;
    
}

-(void)setNavigationBarTitle:(NSString*)strTitle
{
    [self.navigationController setNavigationBarHidden:NO];
    
    RLogs(@"title - %@", strTitle);
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,30)];
    lbl.text = strTitle;
    lbl.textColor = [UIColor whiteColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.backgroundColor = [UIColor clearColor];
    [lbl setFont:[Util Font:FontTypeBold Size:20.0]];
    self.navigationController.navigationBar.topItem.titleView = lbl;
}


-(void)setLeftBarButtonOnNavigationBarAsBackButton
{
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setImage:[UIImage imageNamed:@"back-icon1.png"] forState:UIControlStateNormal];
    btnBack.frame = CGRectMake(0, 0, 40, 40);
    [btnBack addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setContentMode:UIViewContentModeLeft];
    [btnBack setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [btnBack setBackgroundColor:[UIColor clearColor]];
    
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    backBarBtn.width = 50;
    self.navigationItem.leftBarButtonItem = backBarBtn;

}

-(void)setRightBarButtonOnNavigationBarwithText:(NSString*)strTitle
{
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.frame = CGRectMake(0, 0, 60, 24);
    btnSearch.backgroundColor = [UIColor clearColor];
    btnSearch.titleLabel.textAlignment = NSTextAlignmentRight;
    [btnSearch addTarget:self action:@selector(rightBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch setTitle:strTitle forState:UIControlStateNormal];
    btnSearch.titleLabel.font = [Util Font:FontTypeBold Size:14.0];
    
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:btnSearch];
    self.navigationItem.rightBarButtonItem = backBarBtn;
    
  

    
}

-(void)setLefttBarButtonOnNavigationBarwithText:(NSString*)strTitle
{
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.frame = CGRectMake(0, 0, 60, 24);
    [btnSearch addTarget:self action:@selector(leftBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnSearch setTitle:strTitle forState:UIControlStateNormal];
    btnSearch.titleLabel.font = [Util Font:FontTypeLight Size:13.0];
    
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:btnSearch];
    self.navigationItem.leftBarButtonItem = backBarBtn;
    
}

-(void)leftBarButtonTapped:(id)sender
{
    
}

-(void)rightBarButtonTapped:(id)sender
{
    
}
-(void)backBtnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark Loader and Alerts methods
#pragma mark ==========================
-(void)showLoader
{
    if(loaderView.superview)
        return;
    
    UIView *loadView = [[UIView alloc] init];
    loadView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.7];
    
    
    loadView.tag = 222222;
    loadView.frame = [[UIScreen mainScreen] applicationFrame];
    // loadView.bounds = [[UIScreen mainScreen] bounds];
    // loadView.center = self.view.center;
    
    
    
    UIActivityIndicatorView *loadIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadIndicator.center = loadView.center;
    [loadIndicator startAnimating];
    [loadView addSubview:loadIndicator];
    
    [self.view addSubview:loadView];
    [self.view bringSubviewToFront:loadView];
    loaderView = loadView;
    
    CGPoint centre = loaderView.center;
    
        if(![objUtil isiOS7])
            centre.y = centre.y - 20;
        loaderView.center = CGPointMake(centre.x, centre.y);
        centre = loadView.center;
        loadIndicator.center = CGPointMake(centre.x, centre.y-20);
    
    NSLog(@"<><Loader added><>");
    
    
    
}

-(void)showLoaderWithTitle:(NSString*)strTitle
{
    NSLog(@"ShowLoader");
    
    
    UIView *loadView = [[UIView alloc] init];
    loadView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.7];
    
    
    loadView.tag = 222222;
    loadView.frame = [[UIScreen mainScreen] applicationFrame];
    // loadView.bounds = [[UIScreen mainScreen] bounds];
    // loadView.center = self.view.center;
    
    
    
    UIActivityIndicatorView *loadIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadIndicator.tag = 111;
    loadIndicator.center = loadView.center;
    [loadIndicator startAnimating];
    [loadView addSubview:loadIndicator];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, loadIndicator.frame.origin.y + loadIndicator.frame.size.height + 10, loadView.frame.size.width, 30)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [lblTitle setText:strTitle];
    [lblTitle setFont:[Util Font:FontTypeSemiBold Size:12.0]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.tag = 222;
    [loadView addSubview:lblTitle];
    
    [self.view addSubview:loadView];
    [self.view bringSubviewToFront:loadView];
    loaderView = loadView;
    
    CGPoint centre = loaderView.center;
    
    if(![objUtil isiOS7])
        centre.y = centre.y - 20;
    loaderView.center = CGPointMake(centre.x, centre.y);
    centre = loadView.center;
    loadIndicator.center = CGPointMake(centre.x, centre.y-20);
    
    
    
    
}

-(void)changeOrientationOfLoader
{
    if(loaderView.superview)
    {
        loaderView.frame = [[UIScreen mainScreen] applicationFrame];
        UIActivityIndicatorView *activity = (UIActivityIndicatorView*)[loaderView viewWithTag:111];
        activity.center = loaderView.center;
        
        UILabel *lblTitle = (UILabel *)[loaderView viewWithTag:222];
        lblTitle.frame = CGRectMake(0, activity.frame.origin.y + activity.frame.size.height + 10, loaderView.frame.size.width, 30);
        
    }
}

-(void)removeLoader
{
    NSLog(@"<><Removeloader>");
    
    for(UIView *aView in self.view.subviews)
    {
        if(aView.tag == 222222)
        {
            NSLog(@"Removed");
            [aView removeFromSuperview];
        }
    }
    
    if(loaderView == nil)
    {
        NSLog(@"loaderview is nil");
    }
    [loaderView removeFromSuperview];
    loaderView = nil;
}
-(void)showTheAlert:(NSString*)strAlert
{
    
    if(![objAlertView isVisible])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rnyoo" message:strAlert delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        objAlertView = alert;
        [alert show];
    }
    else
    {
        
    }
    
}

-(void)showNetworkErrorAlertWithTag:(NSInteger)tag
{
    
    if(![objAlertView isVisible])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rnyoo" message:@"Network Error. Do you want to retry?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel",nil];
        alert.tag = tag;
        objAlertView = alert;
        [alert show];
    }
    else
    {
        
    }
    
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    [self changeOrientationOfLoader];
}

#pragma login webservice call
-(void)loginwithDict:(NSMutableDictionary*)dictLogin from: (NSString*)strScreen
{
    
    [self showLoader];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/users/login",ServerURL] parameters:dictLogin success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         [self removeLoader];
         
         RLogs(@"login response:%@",responseObject);
         
         [Util setNewUserID:[responseObject valueForKey:@"uid"]];
         [Util setSessionId:[responseObject valueForKey:@"sid"]];

         if([strScreen isEqualToString:@"Search"])
           [ self SuccesssfullyLoggedIn:strScreen];
         else
             [self SuccesssfullyLoggedIn:strScreen];

         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              [self removeLoader];
              
              RLogs(@"login Error: %@", error.description);
              
              
              //[self showTheAlert:error.description];
              [self showNetworkErrorAlertWithTag:333333];
              
          }];
}

-(void)SuccesssfullyLoggedIn:(NSString*)strScreen
{
    
}

-(UIImage *)imageFromPath:(NSString *)path
{
    UIImage *img;
    NSData *data = [NSData dataWithContentsOfFile:path];
    img = [UIImage imageWithData:data];
    return img;
}

#pragma mark To Create FilePath
-(NSString*)getFilePathwithFileName:(NSString*)fileName inFolder:(NSString*)folderName
{
    BOOL success = [self checkOrCreateFolder:folderName];
    if(!success)
    {
        RLogs(@">>>>folder not created successfullly<<<<");
    }
    NSString *filePath = [[[Util sandboxPath] stringByAppendingPathComponent:folderName]stringByAppendingPathComponent:fileName];
    
    return filePath;
}

-(BOOL)checkOrCreateFolder:(NSString*)fldName
{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *folderPath = [path stringByAppendingPathComponent:fldName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        return YES;
    }
    else{
        if ([[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil]){
            return YES;
        }
        else{
            return NO;
        }
    }
    return YES;
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
