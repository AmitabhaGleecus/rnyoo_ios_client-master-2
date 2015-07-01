//
//  HomeViewController.m
//  Rnyoo
//
//  Created by Rnyoo on 17/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "HomeViewController.h"
#import "Util.h"
#import "NetworkViewController.h"
#import "CommunityViewController.h"
#import "MyCornerViewController.h"
#import "SlideNavigationController.h"
#import "UIImage+Resize.h"
#import "UIImage+WebP.h"

@import AssetsLibrary;

@interface HomeViewController ()
{
    NSString *strSelectedImage;
    NSDate *imgDate ;
    NSString *strLocation;
}
@end

@implementation HomeViewController

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    int xpos = 0.0;
    
    if(APP_DELEGATE.isPortrait)
    {
        
        xpos = 25;
        _tableTopConstraint.constant = 320;
        _logoLeftConstraitn.constant = 52;
        backgroundImage.image = [UIImage imageNamed:@"login_bg@3x.png"];
        _tblRightConstraint.constant = 25;

    }
    else
    {
        backgroundImage.image = [UIImage imageNamed:@"login_bg_LandScape@3x.png"];

        _tableTopConstraint.constant = 90;
        if ([objUtil isiPhone5])
        {
            xpos = 285;
            _logoLeftConstraitn.constant = 52;
            _tblRightConstraint.constant = 25;

        }else
        {
            xpos = 220;
            _logoLeftConstraitn.constant = 15;
            _tblRightConstraint.constant = 15;


        }
    }
    _tableLeftConstraitn.constant = xpos;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    geocoder = [[CLGeocoder alloc] init];
    strSelectedImage = @"";
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

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
    return 75;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        tableView.separatorColor = [UIColor clearColor];
        
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(25, 10, 38, 53);
        [btn1 setBackgroundImage:[UIImage imageNamed:@"gallery-icon.png"] forState:UIControlStateNormal];
        [btn1 addTarget:self action:@selector(gotoGallery) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn2.frame = CGRectMake(115, 10, 38, 53);
        [btn2 setBackgroundImage:[UIImage imageNamed:@"camera-icon.png"] forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(gotoCamera) forControlEvents:UIControlEventTouchUpInside];

        UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn3.frame = CGRectMake(195, 10, 55, 53);
        [btn3 setBackgroundImage:[UIImage imageNamed:@"mycorner-icon.png"] forState:UIControlStateNormal];
        [btn3 addTarget:self action:@selector(gotoMyCorner) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn4.frame = CGRectMake(70, 10, 38, 53);
        [btn4 setBackgroundImage:[UIImage imageNamed:@"network-icon.png"] forState:UIControlStateNormal];
        [btn4 addTarget:self action:@selector(gotoNetwork) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btn5 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn5.frame = CGRectMake(160, 10, 55, 53);
        [btn5 setBackgroundImage:[UIImage imageNamed:@"community-icon.png"] forState:UIControlStateNormal];
        [btn5 addTarget:self action:@selector(gotoCommunity) forControlEvents:UIControlEventTouchUpInside];

        if(indexPath.row == 0)
        {
            [cell.contentView addSubview:btn1];
            [cell.contentView addSubview:btn2];
            [cell.contentView addSubview:btn3];
        }
        else
        {
            [cell.contentView addSubview:btn4];
            [cell.contentView addSubview:btn5];
        }
            cell.backgroundColor = [UIColor clearColor];
    
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
#pragma mark UITableView Cell Buttin Actions
#pragma mark ===========================================

-(void)gotoGallery
{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
           [imagePicker setDelegate:self];
        [self presentViewController:imagePicker animated:YES completion:nil];
        imagePicker = nil;
        strSelectedImage = @"Gallery";
    }
    else
    {
        return;
    }

    RLogs(@"gotoGallery");
}
-(void)gotoCamera
{

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
       UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        [imagePicker setDelegate:self];
        [imagePicker setAllowsEditing:NO];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        imagePicker = nil;
        strSelectedImage = @"Camera";

        
    }
    else
    {
        return;
    }

    RLogs(@"gotoCamera");

}
-(void)gotoMyCorner
{
    clickedOption = MenuOptionMyCorner;
    
   MyCornerViewController *MycornerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Mycorner"];
    RLogs(@"gotoMyCorner");
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:MycornerVC
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
    
    
    [SlideNavigationController sharedInstance].leftMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];

}
-(void)gotoNetwork
{
    clickedOption = MenuOptionNetwork;
 
     NetworkViewController *networkVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Network"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:networkVC
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];

    
    [SlideNavigationController sharedInstance].leftMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];


    RLogs(@"gotoNetwork");

}
-(void)gotoCommunity
{
    clickedOption = MenuOptionCommunity;
    CommunityViewController *CommunityVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Community"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:CommunityVC
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
    
    
    [SlideNavigationController sharedInstance].leftMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];


    RLogs(@"gotoCommunity");

}
-(void)setProperMenuView
{
    //navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    navigationController = [SlideNavigationController sharedInstance];
    
    navigationController.leftMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];

    
    switch (clickedOption) {
            
        case MenuOptionCommunity:
        {
            CommunityViewController *CommunityVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Community"];
            navigationController.viewControllers = @[CommunityVC];
        }
            break;
        case MenuOptionNetwork:
        {
            NetworkViewController *networkVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Network"];
            navigationController.viewControllers = @[networkVC];
        }
            break;
            
        case MenuOptionMyCorner:
        {
            MyCornerViewController *MycornerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Mycorner"];
            navigationController.viewControllers = @[MycornerVC];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark saving image in webp format
-(void)saveImage
{
    [APP_DELEGATE.imagePicked  writeWebPToFilePath:strWebpFilePath quality:50];
}
/* Prepare image name */
-(NSString*)prepareImageName
{
    NSString *str = [NSString stringWithFormat:@"rnyi_%@",[Util GetUUID]];
    return str;
}


#pragma mark navigating to hotspot screen

-(void)navigateToHotSpotViewControlelr
{
   /* if(![[NSFileManager defaultManager] fileExistsAtPath:strWebpFilePath])
    {
        return;
    }*/
    HotSpotViewController *hotSpotVC = (HotSpotViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"HotSpot"];
    hotSpotVC.selectedImgId = @"";
    hotSpotVC.strImagePath = strWebpFilePath;
    hotSpotVC.strSelectedImageFrom = strSelectedImage;
    hotSpotVC.isPodExisting = NO;
    hotSpotVC.imgCreatedDate = imgDate;
    hotSpotVC.strLocation = strLocation;
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:hotSpotVC
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
    
    
    [SlideNavigationController sharedInstance].leftMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"menuClicked"])
    {
      //  MenuRootViewController *menuRoot = (MenuRootViewController*)segue.destinationViewController;
       // menuRoot.contentViewController = navigationController;
    }
}

#pragma mark UIImagePickerDelegateMethods
#pragma mark =============================

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    RLogs(@"Original size - %f, %f",originalImage.size.width, originalImage.size.height);
    if (!originalImage)
        return;
    
   
    
    // Resize the image
    APP_DELEGATE.imagePicked = [originalImage resizedImage:CGSizeMake(originalImage.size.width/2, originalImage.size.height/2) interpolationQuality:kCGInterpolationDefault];
    
    RLogs(@"Resized image size - %f, %f",APP_DELEGATE.imagePicked.size.width, APP_DELEGATE.imagePicked.size.height);
    
    strImgName = [NSString stringWithFormat:@"%@.webp",[self prepareImageName]];
    
    
    strWebpFilePath = [self getFilePathwithFileName:strImgName inFolder:VAULT_FOLDER];
    
    [self performSelectorInBackground:@selector(saveImage) withObject:nil];

    
//    [self navigateToHotSpotViewControlelr];

    if(UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        APP_DELEGATE.isPortrait = YES;
    }
    else
    {
        APP_DELEGATE.isPortrait = NO;
    }
    
    
    NSURL *referenceUrl = info[UIImagePickerControllerReferenceURL];
    if (!referenceUrl) {
        RLogs(@"Media did not have reference URL.");
        [self navigateToHotSpotViewControlelr];
        
    } else {
        ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
        [assetsLib assetForURL:referenceUrl
                   resultBlock:^(ALAsset *asset) {
                       
                       CLLocation   *location =
                       [asset valueForProperty:ALAssetPropertyLocation];
                       
                       imgDate = [asset valueForProperty:ALAssetPropertyDate];
                       
                       RLogs(@"location=%@", location);
                       RLogs(@"date=%@", imgDate);
                       [self getLocationfromCoordinates:location];
                       [self navigateToHotSpotViewControlelr];
                       
                   }
                  failureBlock:^(NSError *error) {
                      RLogs(@"Failed to get asset: %@", error);
                      [self navigateToHotSpotViewControlelr];
                      
                  }];
    }

    [self updateViewConstraints];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}
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
}
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
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        
    }
    else
    {
        
    }
}
- (void)didReceiveMemoryWarning
{
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

-(void)getLocationfromCoordinates:(CLLocation*)location
{
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        RLogs(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0)
        {
            CLPlacemark *placemark = [placemarks lastObject];
            
            RLogs(@"%@",[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                         placemark.subThoroughfare, placemark.thoroughfare,
                         placemark.postalCode, placemark.locality,
                         placemark.administrativeArea,
                         placemark.country]);
            
           strLocation = [NSString stringWithFormat:@"%@,%@",placemark.locality,placemark.country];
            
        }
        else
        {
            RLogs(@"%@", error.debugDescription);
        }
    } ];

}
@end
