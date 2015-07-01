//
//  MenuViewController.m
//  SlideMenu
//  Created by Rnyoo on 12/11/14.
//  Copyright (c) 2014 Rnyoo All rights reserved.
//

#import "LeftMenuViewController.h"
#import "FeedbackViewController.h"
#import "TermsOfUseViewController.h"
#import "UIImage+Resize.h"
#import "UIImage+WebP.h"

@import AssetsLibrary;

@interface LeftMenuViewController ()
{
    NSDate *imgDate ;
    NSString *strLocation;
    
}
@end

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self.slideOutAnimationEnabled = YES;
	
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    geocoder = [[CLGeocoder alloc] init];

    
    titles = [[NSMutableArray alloc]initWithObjects:@"Camera", @"Gallery", @"Network", @"Community", @"My Corner",@"Invite Friends",@"Settings", @"Add Friends", nil];
    
    titlesImages = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"camera-slideicon.png"],[UIImage imageNamed:@"gallery-slideicon.png"],[UIImage imageNamed:@"network-slideicon.png"],[UIImage imageNamed:@"community-slideicon.png"],[UIImage imageNamed:@"mycorner-slideicon.png"],[UIImage imageNamed:@"invitefriends-slideicon.png"],[UIImage imageNamed:@"settings-slideicon.png"],[UIImage imageNamed:@"add-buddy.png"], nil];
    
    titles1  = [[NSMutableArray alloc]initWithObjects:@"Know about Rnyoo", @"Terms of Use", @"Privacy Policy",@"Feedback", nil];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = ({
        
        
        
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
        
        
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        ProfileImageView *imageView = [[ProfileImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        RLogs(@"Profile Image - %@", [Util getImgUrl]);
        
        
        [imageView setImageWithURL:[NSURL URLWithString:strImageUrl]];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        //        [imageView setBackgroundColor:[UIColor blackColor]];
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        label.text = [Util getScreenName];
        label.font = [Util Font:FontTypeSemiBold Size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });
    
    
    // Do any additional setup after loading the view.
}

#pragma mark -
#pragma mark UITableView Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
    view.backgroundColor = [UIColor whiteColor];
    
    
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
                
                
            case 0:
            {
                //Camera
                if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    
                    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                    
                    [imagePicker setDelegate:self];
                    [imagePicker setAllowsEditing:NO];
                    
                    [[SlideNavigationController sharedInstance].visibleViewController presentViewController:imagePicker animated:YES completion:nil];
                    [SlideNavigationController sharedInstance].leftMenu = self;

                    imagePicker = nil;
                    
                    
                }
                else
                {
                    return;
                }
                
            }
                break;

            case 1:
            {
                //Gallery
                if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                    [imagePicker setDelegate:self];
                    [[SlideNavigationController sharedInstance].visibleViewController presentViewController:imagePicker animated:YES completion:nil];
                    //[[SlideNavigationController sharedInstance] toggleLeftMenu];
                    [SlideNavigationController sharedInstance].leftMenu = self;

                    imagePicker = nil;
                    
                }
                else
                {
                    return;
                }
                
            }
                
                break;

            case 2:
            {
               
                
                NetworkViewController *networkVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Network"];
                
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:networkVC
                                                                         withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                                 andCompletion:nil];
                [SlideNavigationController sharedInstance].leftMenu = self;

                
            }
                break;

            case 3:
            {
                
                CommunityViewController *CommunityVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Community"];
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:CommunityVC
                                                                         withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                                 andCompletion:nil];
                [SlideNavigationController sharedInstance].leftMenu = self;


                
            }
                break;
                
            case 4:
            {
                
                MyCornerViewController *MycornerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Mycorner"];
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:MycornerVC
                                                                         withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                                 andCompletion:nil];
                [SlideNavigationController sharedInstance].leftMenu = self;


                
            }
                break;
                
                
            case 5:
            {
              
                InviteViewController *InviteFriendsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteFriends"];
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:InviteFriendsVC
                                                                         withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                                 andCompletion:nil];
                [SlideNavigationController sharedInstance].leftMenu = self;


                
                
            }
                break;
                
            case 6:
            {
                SettingsViewController *SettingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:SettingsVC
                                                                         withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                                 andCompletion:nil];
                [SlideNavigationController sharedInstance].leftMenu = self;


                
                
            }
                break;
                
            case 7:
            {
               
                AddBuddyViewController *AddBuddyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddBuddy"];
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:AddBuddyVC
                                                                         withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                                 andCompletion:nil];
                [SlideNavigationController sharedInstance].leftMenu = self;


                
                
            }
                break;
                
            default:
                break;
        }
        
    }
    else{
        titleStr = [titles1 objectAtIndex:indexPath.row];
        // Navigating to the feedback view
        if ([titleStr isEqualToString:@"Feedback"]){
            FeedbackViewController *feedback = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedbackView"];
            feedback.titleStr = titleStr;
            feedback.isFromLeftMenu = YES;
            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:feedback
                                                                     withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                             andCompletion:nil];
            [SlideNavigationController sharedInstance].leftMenu = self;


        }
        else{// Navigation to the termsofuse view
            TermsOfUseViewController *terms = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsView"];
            terms.titleStr = titleStr;
            terms.isFromLeftMenu = YES;
            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:terms
                                                                     withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                             andCompletion:nil];
            [SlideNavigationController sharedInstance].leftMenu = self;


        }
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    
    RLogs(@"Original size - %f, %f",originalImage.size.width, originalImage.size.height);
    if (!originalImage)
        return;
    
   
    
    // Resize the image
      APP_DELEGATE.imagePicked = [originalImage resizedImage:CGSizeMake(originalImage.size.width/2, originalImage.size.height/2) interpolationQuality:kCGInterpolationDefault];
    
    RLogs(@"Resized image size - %f, %f",APP_DELEGATE.imagePicked.size.width, APP_DELEGATE.imagePicked.size.height);
    strImgName = [NSString stringWithFormat:@"%@.webp",[self prepareImageName]];
    strWebpFilePath = [self getFilePathwithFileName:strImgName inFolder:VAULT_FOLDER];
    //[self saveImage];
    [self performSelectorInBackground:@selector(saveImage) withObject:nil];

    if(UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        APP_DELEGATE.isPortrait = YES;
    }
    else
    {
        APP_DELEGATE.isPortrait = NO;
    }
    
 //   [self navigateToHotSpotViewControlelr];
    
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
                       
                       imgDate =
                       [asset valueForProperty:ALAssetPropertyDate];
                       
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
    
    
    
    [self updateViewConstraints];
    
  /*  [picker dismissViewControllerAnimated:YES completion:^(void){
        [self navigateToHotSpotViewControlelr];
        
    }];*/
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark saving image in webp format
-(void)saveImage
{
    
    [APP_DELEGATE.imagePicked writeWebPToFilePath:strWebpFilePath quality:50];

    
    RLogs(@">>>>>>After image save");
    
        
}

/* Prepare image name */
-(NSString*)prepareImageName
{
    NSString *str = [NSString stringWithFormat:@"rnyi_%@",[Util GetUUID]];
    
    return str;
    
}

-(NSString*)getFilePathwithFileName:(NSString*)fileName inFolder:(NSString*)folderName
{
    BOOL success = [self checkOrCreateFolder:folderName];
    
    NSString *filePath = [[[Util sandboxPath] stringByAppendingPathComponent:folderName]stringByAppendingPathComponent:fileName];
    
    return filePath;
}

-(BOOL)checkOrCreateFolder:(NSString*)fldName{
    
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

#pragma mark navigating to hotspot screen

-(void)navigateToHotSpotViewControlelr
{
    
    HotSpotViewController *hotSpotVC = (HotSpotViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"HotSpot"];
    //hotSpotVC.pickedImage = imagePicked;
    hotSpotVC.selectedImgId = @"";
    hotSpotVC.strImagePath = strWebpFilePath;
    hotSpotVC.isPodExisting = NO;
    hotSpotVC.imgCreatedDate = imgDate;
    hotSpotVC.strLocation = strLocation;

    [[SlideNavigationController sharedInstance] pushViewController:hotSpotVC animated:NO];
    [SlideNavigationController sharedInstance].leftMenu = self;
    

   
    
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 40;
        
    }else{
        return 25;
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
    {
        return [titles count];
        
    }else{
        return [titles1 count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RLogs(@"<><><>CellForRow<><><>");
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    tableView.separatorColor = [UIColor clearColor];
    
    for(UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }

    
    
    UIImageView * menuItemImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, 8, 20, 15)];
    
    UILabel *menuItemLbl=[[UILabel alloc]initWithFrame:CGRectMake(90, 5, 120, 25)];
    menuItemLbl.backgroundColor=[UIColor clearColor];
    
    if (indexPath.section == 0)
    {
        menuItemLbl.font = [Util Font:FontTypeLight Size:17];
        menuItemLbl.text=[titles objectAtIndex:indexPath.row];
        if([titlesImages count])
            menuItemImage.image = [titlesImages objectAtIndex:indexPath.row];
        
    } else {
        menuItemLbl.frame = CGRectMake(45, 5, 130, 20);
        menuItemLbl.font = [Util Font:FontTypeLight Size:13];
        menuItemLbl.text=[titles1 objectAtIndex:indexPath.row];
    }
    menuItemLbl.textColor = [Util appHeaderColor];
    
    [cell.contentView addSubview:menuItemLbl];
    [cell.contentView addSubview:menuItemImage];
    
    return cell;
}


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
