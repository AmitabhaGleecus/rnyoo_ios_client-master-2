//
//  WelcomeViewController.m
//  Rynoo
//
//  Created by Rnyoo on 10/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()
{
    NSMutableArray *aryPhotoOptions;
    UIActionSheet *actionSheet;
    BOOL _isClicked;

}
@end

@implementation WelcomeViewController

@synthesize imgViewProfile,lblTextWelcome, strWelcomeText;

/* Update Constraints */

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if(APP_DELEGATE.isPortrait)
    {
        [_imgBgView setImage:[UIImage imageNamed:@"Welcome_bg@3x.png"]];
        
        _imgProfileTopConstraint.constant = 170.0;
        
        _lblWelcomeTopConstraint.constant = 115;
        
        _tblWidthConstrint.constant = 320;
        
        _tblRightConstraint.constant = 0;
        
    }
    else
    {
        [_imgBgView setImage:[UIImage imageNamed:@"Welcome_bg_Landscape@3x.png"]];
        
        _imgProfileTopConstraint.constant = 100.0;
        
        _lblWelcomeTopConstraint.constant = 65;
        
        _tblWidthConstrint .constant = 290;
        
        _tblRightConstraint.constant = 15;



    }
   
}

# pragma mark view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedIndex = 0;
    
    aryPhotoOptions = [[NSMutableArray alloc]initWithObjects:@"Camera",@"Use Gallery", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];

    self.imgViewProfile.layer.cornerRadius = self.imgViewProfile.frame.size.width / 2;
    self.imgViewProfile.clipsToBounds = YES;
    self.imgViewProfile.layer.borderWidth = 5.0f;
    self.imgViewProfile.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imgViewProfile.contentMode = UIViewContentModeScaleAspectFit;
    [self.imgViewProfile sizeToFit];
    
    self.imgViewProfile.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.imgViewProfile.layer.shouldRasterize = YES;
    
    
    NSString *strImageUrl =[Util getImgUrl];
    
    if([strImageUrl rangeOfString:@"?"].length > 0)
    {
        //Getting 150*150 size image of User
        NSArray *arySeperator = [strImageUrl componentsSeparatedByString:@"?"];
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
                    strImageUrl = [NSString stringWithFormat:@"%@?sz=150",[arySeperator objectAtIndex:0]];
                }
            }
            
            // imageURLString=   [imageURLString stringByReplacingOccurrencesOfString:[aryLastObject objectAtIndex:1] withString:@"150"];
        }
    }

    
    self.imgViewProfile.strImageUrl = strImageUrl;
    
    [self.imgViewProfile setImageWithURL:[NSURL URLWithString:self.imgViewProfile.strImageUrl]];
    [self.view insertSubview:_imgBgView atIndex:-1];
    
    
    
    for(UIView *aView in self.view.subviews)
    {
        if(![aView isEqual:_imgBgView])
        {
            [self.view bringSubviewToFront:aView];
        }
    }
    
    _tblInterestAndSkip.backgroundColor = [UIColor clearColor];
    
    _tblInterestAndSkip.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _txtFldUserName.userInteractionEnabled = NO;
    
    NSDictionary *dictUserDetails = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserDetails"];
    
    _txtFldUserName.text = [dictUserDetails valueForKey:@"screenName_s"];
    
    self.lblTextWelcome.text = self.strWelcomeText;
    
    [self.view bringSubviewToFront:_txtFldUserName];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark UITableView Delegate and DataSource Methods
#pragma mark ===========================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
     NSString *cellIdentifier = [NSString stringWithFormat:@"Cell %d",(int)indexPath.row] ;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSArray *arrTitles = [NSArray arrayWithObjects:@"PICK YOUR INTERESTS", @"OR SKIP THIS STEP", nil];
    
    if([self.strWelcomeText isEqualToString:@"WELCOME BACK!"])
    {
        arrTitles = [NSArray arrayWithObjects:@"PROCEED TO HOME", @"", nil];
    }
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
            [cell.textLabel setFont:[Util Font:FontTypeSemiBold Size:14.0]];
           // [cell.textLabel setFont:[Util Font:FontTypeRegular Size:13.0]];
            [cell.textLabel setTextColor:[UIColor whiteColor]];
        
            [cell.textLabel setText:[arrTitles objectAtIndex:indexPath.row]];
            
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    
        
    }
    
    
    if(indexPath.row == selectedIndex)
    {
        cell.backgroundColor = [Util appHeaderColor];
    }
    else
    {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = (int)indexPath.row;
    
    [tableView reloadData];
    
          switch (indexPath.row) {
            case 0:
            {
                if([self.strWelcomeText isEqualToString:@"WELCOME BACK!"])
                {
                    [APP_DELEGATE setMenuScreenAsRootViewController];

                }
                else
                [self performSegueWithIdentifier:@"Interests" sender:self];
            }
                break;
                
            case 1:
            {
                if([self.strWelcomeText isEqualToString:@"WELCOME BACK!"])
                {
                }
                else
                [self performSegueWithIdentifier:@"InviteFriends" sender:self];
            }
                break;
                
            default:
                break;
        }
  }

- (IBAction)editBtnClicked:(id)sender
{
    
    [_txtFldUserName becomeFirstResponder];
}

/* To show actionsheet based on ios version */

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touch_point = [[touches anyObject] locationInView:self.view];
    if ([self.imgViewProfile pointInside: [self.view convertPoint:touch_point toView: self.imgViewProfile] withEvent:event])
    {

        if ([UIAlertController class])
        {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@""
                                                  message:nil
                                                  preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *cameraAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Camera", @"Camera action")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               [self photoPicker:PhotoPickOptionUseCamera];
                                           }];
            
            UIAlertAction *galleryAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Use Gallery", @"Gallery action")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                           [self photoPicker:PhotoPickOptionUsePhotoGallery];

                                       }];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                            actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                            style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *action)
                                            {
                                                [self photoPicker:PhotoPickOptionCancel];

                                            }];
            
            [alertController addAction:cameraAction];
            [alertController addAction:galleryAction];
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];

            
            
        }
        else
        {
            _isClicked = YES;

            [self showActionSheet];

        }
   
    }
}

/* Show actionsheet */

- (void)showActionSheet
{
    if (!_isClicked) return;
  UIActionSheet *actionSheet1=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Camera",@"Use Gallery",nil];
    actionSheet1.tag = 1000;
    
    
    
    [actionSheet1 showInView:self.view];
    actionSheet = actionSheet1;
    
}


#pragma mark Photo related code
#pragma mark ===================

/* Performs action based on selection */

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex ==0)
    {
        [self photoPicker:PhotoPickOptionUseCamera];

    }
    else if(buttonIndex ==1)
    {
        [self photoPicker:PhotoPickOptionUsePhotoGallery];

    }
    else
    
        [self photoPicker:PhotoPickOptionCancel];
    
}

/* To show actionsheet during orientation */

- (void)didRotate:(NSNotification *)note
{
    [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    [self performSelector:@selector(showActionSheet) withObject:nil afterDelay:1.0];
}


-(void)showPhotoOptions
{
    CGFloat xWidth = self.view.window.bounds.size.width - 50.0f;
    CGFloat yHeight = 150.0f;
    CGFloat yOffset = (self.view.window.bounds.size.height - yHeight)/2.0f;
    poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = FALSE;
    poplistview._titleView.text = @"Choose";
    poplistview._titleView.font = [Util Font:FontTypeLight Size:15];
    [poplistview showInView:self.view];
}

# pragma mark-Orientation Methods For UIPopover List

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
        [self showPhotoOptions];
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
        [self showPhotoOptions];
    }
}


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


#pragma mark - UIPopoverListViewDataSource
#pragma mark ===========================================

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:identifier] ;
    
    cell.textLabel.text =[aryPhotoOptions objectAtIndex:indexPath.row];
    cell.textLabel.font = [Util Font:FontTypeLight Size:15];    
    return cell;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView numberOfRowsInSection:(NSInteger)section
{
    return [aryPhotoOptions count];
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView  didSelectIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0)
    {
        [self photoPicker:PhotoPickOptionUseCamera];
    }
    else if(indexPath.row == 1)
    {
        [self photoPicker:PhotoPickOptionUsePhotoGallery];
    }
    else{
        [self photoPicker:PhotoPickOptionCancel];
    }
    
    pickedOption = (int)indexPath.row;
   [poplistview dismiss];
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

#pragma mark UIImagePickerDelegateMethods
#pragma mark =============================


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    pickedImage = info[UIImagePickerControllerOriginalImage];
    
    RLogs(@"info - %@", [info[UIImagePickerControllerMediaURL] description]);
    
    if([self connected])
    {
        [self uploadPhoto];
    }
    else
    {
        [self showNoInternetMessage];
        return;
    }

    if(UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        APP_DELEGATE.isPortrait = YES;
    }
    else
    {
        APP_DELEGATE.isPortrait = NO;
    }
    [self updateViewConstraints];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/*  Performing actions based on selection */

-(void)photoPicker:(PhotoPickOption)opt
{
    
    UIImagePickerController *imagePicker;
    switch (opt) {
        case 0:
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                imagePicker = [[UIImagePickerController alloc] init];

                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            }
            else
            {
                return;
            }
            
            break;
        case 1:
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                imagePicker = [[UIImagePickerController alloc] init];
                [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
            else
            {
                return;
            }
            
            break;
       
        default:
            break;
    }
    if(imagePicker != nil)
    {
        [imagePicker setDelegate:self];
        [imagePicker setAllowsEditing:NO];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        imagePicker = nil;
        
    }
    
}

# pragma Upload avatar to server

/* upload avatar to server */

-(void)uploadPhoto{
    
    [self showLoader];
    NSString *strUserId = [Util getNewUserID];

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:ServerURL]];
     [manager.requestSerializer setValue:@"RnyooiOS" forHTTPHeaderField:@"x-rnyoo-client"];

    [manager.requestSerializer setValue:strUserId forHTTPHeaderField:@"x-rnyoo-uid"];
    
    [manager.requestSerializer setValue:[Util getSessionId] forHTTPHeaderField:@"x-rnyoo-sid"];
    
    RLogs(@"header - %@", [manager.requestSerializer.HTTPRequestHeaders description]);
    
    
    NSData *imageData = UIImageJPEGRepresentation(pickedImage, 0.5);
    
    AFHTTPRequestOperation *op = [manager POST:@"users/avatars/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        RLogs(@"Success: %@ ***** %@", operation.responseString, responseObject);
        
        [self removeLoader];
        RLogs(@"%@",[responseObject valueForKey:@"avatar"]);
        NSString *strError = [responseObject valueForKey:@"error"];

        
        if(strError != nil && [strError length])
        {
            [self showTheAlert:strError];
        }
        else
        {
            RLogs(@"settingImage");
            [Util setImageUrl:[responseObject valueForKey:@"avatar"]];
            
            [self.imgViewProfile clearImageCacheForURL:[NSURL URLWithString:[responseObject valueForKey:@"avatar"]]];
            
            [self.imgViewProfile setImageWithURL:[NSURL URLWithString:[responseObject valueForKey:@"avatar"]]];

        }
        
        
        
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            [self removeLoader];
            RLogs(@"Error: %@ ***** %@", operation.responseString, error);
            [self showNetworkErrorAlertWithTag:111111];
        }];
    [op start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(alertView.tag == 111111)
    {
        if(buttonIndex == 0)
        {
            [self uploadPhoto];
            return;
        }
    }
}
@end
