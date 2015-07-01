//
//  SavedHotspotsViewController.m
//  Rnyoo
//
//  Created by Rnyoo on 05/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "SavedHotspotsViewController.h"
#import "HotspotsCollectionCell.h"
#import "HotSpotViewController.h"

#import "UIImageView+AFNetworking.h"

#import "UIImage+WebP.h"
#import "Image.h"

static int selectionCount;

@interface PathWithModDate : NSObject
@property (strong) NSString *path;
@property (strong) NSDate *modDate;
@property(strong) NSString *strImgId;
@property(strong) NSString *strImgUrl;

@property BOOL isSelected;
@end

@implementation PathWithModDate
@end

@interface SavedHotspotsViewController (){
    NSMutableArray *savedHotspotsPaths;
    UIImage *selectedImg;
    UIBarButtonItem *trashBtn;
    BOOL multipleSelectionEnabled;
    NSMutableArray   *arrSortedImages;
    NSMutableArray *arrSelectedImages;
    BOOL isCheckBoxSelected;
    
    UIView *view;
    CustomIOS7AlertView *alertView;
    BOOL isOrientatiomChanged;
}

@end

@implementation SavedHotspotsViewController
@synthesize context;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    savedHotspotsPaths  = [[NSMutableArray alloc]init];
    context = [APP_DELEGATE managedObjectContext];
    arrSelectedImages = [[NSMutableArray alloc]init];
    
    multipleSelectionEnabled = NO;
    isCheckBoxSelected = NO;
    isOrientatiomChanged = NO;
    // Adding long gesture recogniser to delete saved hotspot
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self.hotspotCollectionView addGestureRecognizer:longPressRecognizer];
    
    // Configuring trash button on navigation bar
    trashBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteSavedImages)];
    trashBtn.tintColor = [UIColor whiteColor];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Checking user selected option
    NSString *folderName;
    
    if ([self.viewTitle isEqualToString:MY_VAULT_VIEW])
    {
        folderName = VAULT_FOLDER;
        [self refreshImages];
        RLogs(@">>>>>savedHotspotsPaths count - %ld", (unsigned long)[savedHotspotsPaths count]);
    }
    else
    {
        _btnVaultSync.hidden = YES;
        
        folderName = CLIPBOARD_FOLDER;
        NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:folderName];
        NSArray *imgPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
        for (NSString *imgName in imgPaths) {
            //Get contents of each file path for sorting
            NSString *path = [folderPath stringByAppendingPathComponent:imgName];
            NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
            
            NSDate *modDate = [fileDict objectForKey:NSFileModificationDate];
            PathWithModDate *pathWithDate = [[PathWithModDate alloc] init];
            pathWithDate.path = path;
            pathWithDate.modDate = modDate;
            pathWithDate.isSelected = NO;
            [savedHotspotsPaths addObject:pathWithDate];
        }
        
        // Sorting images by created dates
        [savedHotspotsPaths sortUsingComparator:^(PathWithModDate *path1, PathWithModDate *path2){
            return [path1.modDate compare:path2.modDate];
        }];
        
    }

}


/* Update Constraints */


-(void)updateViewConstraints
{
    
    [super updateViewConstraints];
    
    
    if([Util isIOS8])
    {
        if(self.view.frame.size.width > self.view.frame.size.height)
            APP_DELEGATE.isPortrait = NO;
        else
            APP_DELEGATE.isPortrait = YES;
    }
    
    
    if(APP_DELEGATE.isPortrait)
    {
        self.topBarConstraint.constant = 64.0;
     //   isOrientatiomChanged = NO;
        
    }
    else
    {
        self.topBarConstraint.constant = 32.0;
        isOrientatiomChanged = YES;
        
    }
    RLogs(@"top %f",self.topBarConstraint.constant);
    
}


-(void)viewWillLayoutSubviews
{
    
    if(isOrientatiomChanged && isShowingAlert)
    {
        [alertView close];
        
        [self showCustomAlert];

    }
}

-(void)deleteSavedImages{

    
    
    if ([self.viewTitle isEqualToString:MY_VAULT_VIEW])
    {
        [self showCustomAlert];
    }
    else
        [self deleteFromSandbox];
    

}

-(void)showCustomAlert
{
    isCheckBoxSelected = NO;
    isShowingAlert = YES;
    alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createView]];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", @"OK", nil]];
    [alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView1, int buttonIndex) {
        RLogs(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView1 tag]);
        [alertView1 close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];

   
    
}


- (UIView *)createView
{
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 150)];
   
    
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 270, 30)];
    lblTitle.text = @"Delete Vault Images";
 //   lblTitle.textColor = [UIColor colorWithRed:20.0/255.0 green:71.0/255.0 blue:89.8/255.0 alpha:1.0f];
    lblTitle.textColor = [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f];
    lblTitle.font = [Util Font:FontTypeRegular Size:15] ;
//    lblTitle.textColor = [UIColor colorWithRed:51 green:181 blue:229 alpha:1.0];
    lblTitle.numberOfLines = 0;
    [view addSubview:lblTitle];
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0,50, 290, 1)];
    viewLine.backgroundColor = [UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f];
    [view addSubview:viewLine];
    
    UILabel *lblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 270, 120)];
    lblText.text = @"Delete selected pods from server? \n This will delete all the posts \n related to the Pictures you\n want to delete!";
    [lblText setFont:[Util Font:FontTypeSemiBold Size:13] ];
    lblText.textAlignment = NSTextAlignmentLeft;
    lblText.numberOfLines = 0;
    [view addSubview:lblText];
    
    
    UIButton *btnCheckBox = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCheckBox setFrame:CGRectMake(230,90 , 30, 30)];
    [btnCheckBox setBackgroundColor:[UIColor clearColor]];
    [btnCheckBox setImage:[UIImage imageNamed:@"checkBox_unselected.png"] forState:UIControlStateNormal];
    btnCheckBox.imageEdgeInsets = UIEdgeInsetsMake(0,0,15,13);
    [btnCheckBox addTarget:self action:@selector(alertCheckboxButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btnCheckBox];

    
    return view;
}

-(void)alertCheckboxButtonClicked:(UIButton*)sender
{
    if(isCheckBoxSelected)
    {
        [sender setImage:[UIImage imageNamed:@"checkBox_unselected.png"] forState:UIControlStateNormal];
        isCheckBoxSelected = NO;
    }
    else
    {
        isCheckBoxSelected = YES;
        [sender setImage:[UIImage imageNamed:@"checkBox_selected.png"] forState:UIControlStateNormal];
        sender.imageEdgeInsets = UIEdgeInsetsMake(0,0,15,13);

    }
    
}

# pragma customAlert Delegate method

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView1 clickedButtonAtIndex: (NSInteger)buttonIndex
{
    RLogs(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    [alertView1 close];
    
    isShowingAlert = NO;
    if(buttonIndex ==1)
    {
        
        [self deleteFromSandbox];
        
        if(isCheckBoxSelected)
            [self deleteImagesFromServer];
        else
        [self deleteImagesFromDB];
    }
    else
    {
        for (PathWithModDate *pathObj in savedHotspotsPaths) {
            pathObj.isSelected = NO;
        }
        [self changeToNormalMode];
        [self.hotspotCollectionView reloadData];
    }
    
}


-(void)onLongPress:(UILongPressGestureRecognizer*)pGesture{
    // When the user started long press
    if (pGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [pGesture locationInView:self.hotspotCollectionView];
        NSIndexPath* indexPath = [self.hotspotCollectionView indexPathForItemAtPoint:touchPoint];
        
        NSLog(@"selected index - %@", indexPath.description);
        
        if (indexPath != nil) {
            //Handle the long press on row
            PathWithModDate *pathObj = [savedHotspotsPaths objectAtIndex:indexPath.row];
            if ([self.viewTitle isEqualToString:MY_VAULT_VIEW]) {
                RLogs(@"managedObject: %@",[arrSortedImages objectAtIndex:indexPath.row]);
                [arrSelectedImages addObject:[arrSortedImages objectAtIndex:indexPath.row]];
                RLogs(@"managedObject array : %@",arrSelectedImages);

            }
            pathObj.isSelected = YES;
            [self changeToMultipleSelectionMode];
            
            HotspotsCollectionCell *cell = (HotspotsCollectionCell*)[self.hotspotCollectionView cellForItemAtIndexPath:indexPath];

            if (pathObj.isSelected) {
                
                cell.selectedImgView.hidden = NO;
            }
            else{
                cell.selectedImgView.hidden = YES;
            }

          //  [self.hotspotCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
           // [self.hotspotCollectionView reloadData];
            

        }
    }
}

-(void)changeToMultipleSelectionMode{
    multipleSelectionEnabled = YES;
    self.hotspotCollectionView.allowsMultipleSelection = YES;
    self.navigationItem.rightBarButtonItem = trashBtn;
}

-(void)changeToNormalMode{
    multipleSelectionEnabled = NO;
    self.hotspotCollectionView.allowsMultipleSelection = NO;
    self.navigationItem.rightBarButtonItem = nil;

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(alertView.tag == 111111)
    {
        if(buttonIndex == 0)
        {
            [self btn_VaultSyncBtnAction:nil];
            return;
        }
    }

    
    
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            // Deleting selected images from sandbox and savedHotspotsPaths array
            selectionCount = 0;
            NSMutableArray *toDelete = [NSMutableArray array];
            [arrSelectedImages removeAllObjects];
            
            for (PathWithModDate *imgObj in savedHotspotsPaths) {
                if (imgObj.isSelected) {
                    selectionCount ++;
                    BOOL success =  [[NSFileManager defaultManager] removeItemAtPath:imgObj.path error:nil];
                    if (success) {
                        
                        if ([self.viewTitle isEqualToString:MY_VAULT_VIEW])
                        {
                        [toDelete addObject:imgObj];
                        
                        [arrSelectedImages addObject:[arrSortedImages objectAtIndex:[savedHotspotsPaths indexOfObject:imgObj]]];
                        }
                    }
                }
            }

            // Refresh collection view and set to normal mode
            RLogs(@"arrSelectedImages count - %lu", (unsigned long)[arrSelectedImages count]);

            if ([self.viewTitle isEqualToString:MY_VAULT_VIEW]) {
                for(NSManagedObject *objImage in arrSelectedImages)
                {
                    [context deleteObject:objImage];
                    
                    NSError *error= nil;
                    if (![context save:&error])
                    {
                        RLogs(@"Problem saving: %@", [error localizedDescription]);
                    }

                }
            }

            if (selectionCount > 0) {
                [savedHotspotsPaths removeObjectsInArray:toDelete];
                [self.hotspotCollectionView reloadData];
                selectionCount = 0;
                [self changeToNormalMode];
               
            }
            else{
                [self showTheAlert:@"Please select hotspot(s)"];
            }
            
            [self refreshImages];
        }
        
        else{
            // If User does nt want to delete the items and reset items in to normal mode
            for (PathWithModDate *pathObj in savedHotspotsPaths) {
                pathObj.isSelected = NO;
            }
            [self changeToNormalMode];
            [self.hotspotCollectionView reloadData];
        }
    }
}

-(UIImage *)imageFromPath:(NSString *)path{
    UIImage *img;
    NSData *data = [NSData dataWithContentsOfFile:path];
    img = [UIImage imageWithWebPData:data];
    return img;
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self setNavigationBarTitle:self.viewTitle];
    [self setLeftBarButtonOnNavigationBarAsBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [savedHotspotsPaths count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    // Configuring the Collectionview cell
    static NSString *myCellID = HotspotCellID;
    
   // NSString *myCellID = [NSString stringWithFormat:@"Cell%li", indexPath.row%3];
    
    NSLog(@"Indexpath - %@", indexPath.description);
    
    HotspotsCollectionCell *cell = (HotspotsCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:myCellID forIndexPath:indexPath];
    
    if(indexPath.row < [savedHotspotsPaths count])
    {
        PathWithModDate *pathsObj = [savedHotspotsPaths objectAtIndex:indexPath.row];
        NSLog(@">>>>>Vault ImgPath - %@",pathsObj.path);
        
        
        
        if (![self.viewTitle isEqualToString:MY_VAULT_VIEW])
        {
            //This is for clipboard
            [cell.HSImgView setImageWithPath:pathsObj.path];            
            
            if (pathsObj.isSelected) {
                
                cell.selectedImgView.hidden = NO;
            }
            else{
                cell.selectedImgView.hidden = YES;
            }
            return cell;

        }
        NSDictionary *dictPathUrl = [NSDictionary dictionaryWithObjectsAndKeys:pathsObj.path, @"path", pathsObj.strImgUrl, @"url", nil];
        [cell.HSImgView setBackgroundColor:[UIColor blackColor]];
        //[cell.HSImgView setImageWithPath:pathsObj.path orWithUrl:pathsObj.strImgUrl];
        [cell.HSImgView setContentMode:UIViewContentModeScaleAspectFit];
        

       
        	if (pathsObj.isSelected) {

            cell.selectedImgView.hidden = NO;
        }
        else{
            
           

            cell.selectedImgView.hidden = YES;

        }
        
        if(!multipleSelectionEnabled)
        {
             cell.HSImgView.image = [UIImage imageNamed:@"RnyooIcon.png"];
            [cell performSelectorInBackground:@selector(setImageForVault:) withObject:dictPathUrl];

        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
      
    PathWithModDate *pathsObj = [savedHotspotsPaths objectAtIndex:indexPath.row];
    
    NSLog(@"selected index2 - %@", indexPath.description);
    
    if (!multipleSelectionEnabled) {
        
        // Picking the image and navigate to hotspot view
        
        [self performSelectorOnMainThread:@selector(getImagePath:) withObject:pathsObj.path waitUntilDone:YES];
        
     //   selectedImg = [self imageFromPath:pathsObj.path];
        if(selectedImg != nil)
            {
                
                HotSpotViewController *hotSpotVC = (HotSpotViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"HotSpot"];
                hotSpotVC.strImagePath = pathsObj.path;
                hotSpotVC.strSelectedImageFrom = @"Vault";
                hotSpotVC.selectedImgId = pathsObj.strImgId;
                hotSpotVC.isPodExisting = NO;
                if (![self.viewTitle isEqualToString:MY_VAULT_VIEW])
                {
                      NSString *strWebpFilePath = [self saveImagewithPath:pathsObj.path];
                        hotSpotVC.strImagePath = strWebpFilePath;
                }
                else
                {
                    //Checking whether any draft pod is there in local DB.
                    NSString *strDraftPostId = [Util_HotSpot getNotPostedPodIdOfImgId:pathsObj.strImgId];
                    
                    if(strDraftPostId != nil && strDraftPostId.length > 0)
                    {
                        hotSpotVC.strPodId = strDraftPostId;
                        hotSpotVC.isPodExisting = YES;
                    }

                }
                

                
                [self.navigationController pushViewController:hotSpotVC animated:NO];
                
                if([SlideNavigationController sharedInstance].leftMenu == nil)
                     [SlideNavigationController sharedInstance].leftMenu = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];

                
              
            }
            else
            {
                RLogs(@"There is no vault file at image path");
            }
        RLogs(@"selected image is %@",selectedImg);
        
 
    }
    else{
        // Handling selection and deseleciton of cells to delete
        if (pathsObj.isSelected) {
            pathsObj.isSelected = NO;
            //[savedHotspotsPaths replaceObjectAtIndex:indexPath.row withObject:pathsObj];
        }
        else{
            pathsObj.isSelected = YES;
            //[savedHotspotsPaths replaceObjectAtIndex:indexPath.row withObject:pathsObj];
            
        }
        
        HotspotsCollectionCell *cell = (HotspotsCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
        if (pathsObj.isSelected) {
            
            cell.selectedImgView.hidden = NO;
        }
        else{
            cell.selectedImgView.hidden = YES;
        }
       
    }

}



-(void)getImagePath:(NSString*)path
{
    
    if (![self.viewTitle isEqualToString:MY_VAULT_VIEW])
    {
        //if it is from MY ClipBoard then they are not in webp format.
        NSData *data = [NSData dataWithContentsOfFile:path];
        selectedImg = [UIImage imageWithData:data];
        return;
    }
        
        selectedImg = [self imageFromPath:path];
    
    
    
}
#pragma mark Collection view layout things
// Layout: Set cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    RLogs(@"SETTING SIZE FOR ITEM AT INDEX %d", indexPath.row);
    CGSize mElementSize = CGSizeMake(105, 105);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}


/*get Images from DB*/

-(NSMutableArray*)getImagesfromDB
{
    
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return [fetchedObjects mutableCopy];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
- (IBAction)btn_VaultSyncBtnAction:(id)sender
{
    
    [self showLoaderWithTitle:@"Vault Syncing..."];
    NSMutableDictionary *dictVault = [[NSMutableDictionary alloc]init];
    
    [dictVault setValue:[Util getNewUserID] forKey:@"uid"];
    
    [dictVault setValue:[Util getSessionId] forKey:@"sid"];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/vault/files/list",ServerURL] parameters:dictVault success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSLog(@"vault sync response:%@",responseObject);
         NSArray *aryVaultFiles = [responseObject valueForKey:@"vaultfiles"];
         
         
         //Filtering only image files from response.
         NSMutableArray *arrVaultImages = [[NSMutableArray alloc] init];
         for(NSDictionary *dictVault in aryVaultFiles)
         {
             NSString *strExtension = @".webp";
             if([[[dictVault valueForKey:@"fileExtension"]lowercaseString] isEqualToString:[strExtension lowercaseString]])
             {
                 [arrVaultImages addObject:dictVault];
             }
         }
         
         
         RLogs(@"array :%@",arrVaultImages);
         if([arrVaultImages count]== 0)
         {
             [self removeLoader];

             [self showTheAlert:@"Vault is up to date"];
             
         }
         else
         {
            [self removeLoader];
       
             [self checkVaultImageSavedOrNotWithArray:arrVaultImages];

             [self.hotspotCollectionView reloadData];
         }

         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"vault sync Error: %@", error);
              [self removeLoader];
              [self showNetworkErrorAlertWithTag:111111];
              
              
          }];
    
}

-(void)checkVaultImageSavedOrNotWithArray:(NSArray*)aryVaultImages
{
    
    NSMutableArray *aryImages = [self getImagesfromDB];
    NSMutableArray *aryToSaveVaultImages = [[NSMutableArray alloc]init];

    BOOL isSaved = NO;
    if([aryImages count]== 0 && [aryVaultImages count])
    {
        //We are saving all vault data in DB when there is no records in local DB.
        [self saveVaultImagesToDBWithArray:aryVaultImages];

    }
    else
    {
        //We are cehcking the records and updating and saving in DB based on "imgName" field in vault table...
        NSString *strImgFileNameOnServer;
            for(NSMutableDictionary *dictobj in aryVaultImages)
            {
                isSaved = NO;
                
                strImgFileNameOnServer = [NSString stringWithFormat:@"%@.webp",[dictobj valueForKey:@"fileId"]];

                for(NSManagedObject *objImage in aryImages)
                {
          
                if([[objImage valueForKey:@"imgName"] isEqualToString:strImgFileNameOnServer])
                    {
                        [self UpdateVaultImagewithObj:objImage andData:dictobj];
                        isSaved = YES;
                    }
                }
            
            if(isSaved == NO)
            {
                [aryToSaveVaultImages addObject:dictobj];
            }
            }
        
    }

    if([aryToSaveVaultImages count])
    {
        [self saveVaultImagesToDBWithArray:aryToSaveVaultImages];

    }
    
}

-(void)UpdateVaultImagewithObj:(NSManagedObject*)objImage andData:(NSDictionary*)dict
{
    NSString *strImageName = [NSString stringWithFormat:@"%@.webp", [dict valueForKey:@"fileId"]];
    
    [objImage setValue:[dict valueForKey:@"fileId"] forKey:@"imgId"];
    [objImage setValue:[NSString stringWithFormat:@"%@/%@/%@",[Util sandboxPath],VAULT_FOLDER,strImageName] forKey:@"imgPath"];
    [objImage setValue:strImageName forKey:@"imgName"];
    
    [objImage setValue:[NSNumber numberWithBool:YES] forKey:@"syncInitiated"]; // need to check
     [objImage setValue:[NSNumber numberWithBool:YES] forKey:@"syncStatus"]; // need to check
    
    [objImage setValue:[dict valueForKey:@"remoteUrl"] forKey:@"imgUrl"];
    
    
    [objImage setValue:[dict valueForKey:@"createdAt"]  forKey:@"imageCreatedTime"];
    
    NSError *error= nil;
    if (![context save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
}
/* save vault images to DB*/

-(void)saveVaultImagesToDBWithArray:(NSArray*)aryVaultFiles
{
    //Saving image name and path to the local DB
    
    for(NSDictionary *dict in aryVaultFiles)
    {
        RLogs(@"Dict Desc - %@", [dict description]);
        
        NSString *strImageName = [NSString stringWithFormat:@"%@.webp", [dict valueForKey:@"fileId"]];

        
        NSManagedObject *objImage= [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
        
        [objImage setValue:[dict valueForKey:@"fileId"] forKey:@"imgId"];
        [objImage setValue:[NSString stringWithFormat:@"%@/%@/%@",[Util sandboxPath],VAULT_FOLDER,strImageName] forKey:@"imgPath"];
        [objImage setValue:strImageName forKey:@"imgName"];
        
        [objImage setValue:[NSNumber numberWithBool:YES] forKey:@"syncInitiated"]; // need to check
        [objImage setValue:[NSNumber numberWithBool:YES] forKey:@"syncStatus"]; // need to check
      
        [objImage setValue:[dict valueForKey:@"remoteUrl"] forKey:@"imgUrl"];
        
        
        [objImage setValue:[dict valueForKey:@"createdAt"]  forKey:@"imageCreatedTime"];
        
        NSError *error= nil;
        if (![context save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }
    
    }
    
   // NSMutableArray *aryImages = [self getImagesfromDB];
   // RLogs(@"array after update:%lu",(unsigned long)[aryImages count]);
    [self refreshImages];

}

-(void)refreshImages
{
    [savedHotspotsPaths removeAllObjects];
    
    
    BOOL success = [Util checkOrCreateFolder:VAULT_FOLDER];

    
   NSArray *aryImages = [self getImagesfromDB]; // Retrieving image paths from DB
    RLogs(@">>>>>aryImages count - %ld", (unsigned long)[aryImages count]);
    
    // Preparing sorted images by created time
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"imageCreatedTime" ascending:YES];
    arrSortedImages = [[NSMutableArray alloc]initWithArray:[aryImages sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]]];
    
    RLogs(@">>>>>arrSortedImages count - %ld", (unsigned long)[arrSortedImages count]);
    
    for(int i=0;i< [arrSortedImages count];i++)
    {
        NSManagedObject *obj = [arrSortedImages objectAtIndex:i];
        PathWithModDate *pathWithDate = [[PathWithModDate alloc] init];
        pathWithDate.isSelected = NO;
        pathWithDate.path = [NSString stringWithFormat:@"%@/%@/%@",[Util sandboxPath],VAULT_FOLDER,[obj valueForKey:@"imgName"]];
        pathWithDate.strImgId = [obj valueForKey:@"imgId"];
        pathWithDate.strImgUrl = [obj valueForKey:@"imgUrl"];
        [savedHotspotsPaths addObject:pathWithDate];
        RLogs(@"path:%@",pathWithDate.path);
        
    }
    
    [_hotspotCollectionView reloadData];
}

#pragma mark saving image in webp format
-(NSString*)saveImagewithPath:(NSString*)imgPath
{
    
    if([Util_HotSpot getBackGround] == NO)
    {
        //[self showLoaderWithTitle:@"Saving image..."];
    }
    else
        RLogs(@"saving in background");
    
    NSString *strImgName = [NSString stringWithFormat:@"%@.webp",[self prepareImageName]];
    
    
    NSString   *strWebpFilePath = [self getFilePathwithFileName:strImgName inFolder:VAULT_FOLDER];
    
 //  UIImage *img = [self imageFromPath:imgPath];

   [selectedImg writeWebPToFilePath:strWebpFilePath quality:50];
    
    
    RLogs(@">>>>>>After image save");
    
    return strWebpFilePath;
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


-(void)deleteImagesFromServer
{
    RLogs(@"array:%@",arrSelectedImages);
    
    for(NSManagedObject *objImgid in arrSelectedImages)
    {
        NSLog(@"Img data - %@", objImgid.description);
    }

    deleteIndex = 0;
    if(deleteIndex < [arrSelectedImages count])
    {
        [self showLoader];

    NSManagedObject *objImage = [arrSelectedImages objectAtIndex:deleteIndex];
        [self callVaultDeleteWebservicewithImgId:[objImage valueForKey:@"imgId"]];

    }
   
    
}

-(void)callVaultDeleteWebservicewithImgId:(NSString*)imgId
{
    NSLog(@"imgId - %@",imgId);
    NSMutableDictionary *dictVault = [[NSMutableDictionary alloc]init];
    
    [dictVault setValue:[Util getNewUserID] forKey:@"uid"];
    
    [dictVault setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictVault setValue:imgId forKey:@"imgId"];

    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/vault/files/delete",ServerURL] parameters:dictVault success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSLog(@"vault sync response:%@",responseObject);
         //Filtering only image files from response.
         deleteIndex = deleteIndex + 1;
         NSLog(@"delete Index - %li", (long)deleteIndex);

         if(deleteIndex < [arrSelectedImages count])
         {
             NSManagedObject *objImage = [arrSelectedImages objectAtIndex:deleteIndex];
             [self callVaultDeleteWebservicewithImgId:[objImage valueForKey:@"imgId"]];
             
         }
         else
         {
             [self removeLoader];
              [self deleteImagesFromDB];

         }
     
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"vault sync Error: %@", error);
              //[self removeLoader];
              //[self showNetworkErrorAlertWithTag:111111];
              
              deleteIndex = deleteIndex + 1;
              if(deleteIndex < [arrSelectedImages count])
              {
                  NSManagedObject *objImage = [arrSelectedImages objectAtIndex:deleteIndex];
                  [self callVaultDeleteWebservicewithImgId:[objImage valueForKey:@"imgId"]];
                  
              }
              else
              {
                  [self removeLoader];
                   [self deleteImagesFromDB];


              }
              
              
          }];

}

-(void)deleteFromSandbox
{
    selectionCount = 0;
    NSMutableArray *toDelete = [NSMutableArray array];
    [arrSelectedImages removeAllObjects];
    
    for (PathWithModDate *imgObj in savedHotspotsPaths) {
        if (imgObj.isSelected) {
            
            NSLog(@"<<Selected>>");
            selectionCount ++;
            
            if([[NSFileManager defaultManager] fileExistsAtPath:imgObj.path])
            {
                NSLog(@"File existing");
            }
            else
            {
                NSLog(@"File Not existing");

            }
            
            BOOL success =  [[NSFileManager defaultManager] removeItemAtPath:imgObj.path error:nil];
            if (success) {
                
                if ([self.viewTitle isEqualToString:MY_VAULT_VIEW])
                {
                    [toDelete addObject:imgObj];
                    
                    NSLog(@"Delete imgid - %@", imgObj.strImgId);
                    NSManagedObject *objImg = [arrSortedImages objectAtIndex:[savedHotspotsPaths indexOfObject:imgObj]];
                    NSLog(@"Delete imgid1 - %@", objImg.description);

                    [arrSelectedImages addObject:objImg];
                }
            }
        }
    }

    if (selectionCount > 0) {
        [savedHotspotsPaths removeObjectsInArray:toDelete];
        [self.hotspotCollectionView reloadData];
        selectionCount = 0;
        [self changeToNormalMode];
        
    }
    else{
        [self showTheAlert:@"Please select hotspot(s)"];
    }
    
    [self refreshImages];

    
}
-(void)deleteImagesFromDB
{
    
    // Deleting selected images from sandbox and savedHotspotsPaths array
    
    // Refresh collection view and set to normal mode
    RLogs(@"arrSelectedImages count - %lu", (unsigned long)[arrSelectedImages count]);
    
    if ([self.viewTitle isEqualToString:MY_VAULT_VIEW]) {
        for(NSManagedObject *objImage in arrSelectedImages)
        {
            [self deletePodDataFromDBwithObj:objImage];
            
            [context deleteObject:objImage];
            
            NSError *error= nil;
            if (![context save:&error])
            {
                RLogs(@"Problem saving: %@", [error localizedDescription]);
            }
            
        }
    }
    [self refreshImages];

    
}


-(void)deletePodDataFromDBwithObj:(NSManagedObject*)objImage
{
    NSManagedObject *objPod = [self getPodDataFromDBwithImgId:[objImage valueForKey:@"imgId"]];
    if(objPod != nil)
    {
        // deleting post comments, hotspots shared data, questions and question comments data from db
        [self deletePostDataFromDBWithObj:objPod];
        
        // deleting hotspots and hotspot comments data from db
        [self deleteHotspotsDataFromDBwithImgId:[objImage valueForKey:@"imgId"] andPodID:[objPod valueForKey:@"pid"]];
        
       [context deleteObject:objPod];
        NSError *error= nil;
        if (![context save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }


     }
     
}

-(void)deleteHotspotsDataFromDBwithImgId:(NSString*)strImgId andPodID:(NSString*)strPodId
{
    NSArray *arrHotSpotInfo = [Util_HotSpot getHotspotDataFromDBOfImgId:strImgId withPodId:strPodId];
    
    for(NSManagedObject *objHotspot in arrHotSpotInfo)
    {
        [self deleteHotspotCommentsDataFromDBwithHotspotId:[objHotspot valueForKey:@"hId"] andPodId:strPodId];
        
        [context deleteObject:objHotspot];
        
        NSError *error= nil;
        if (![context save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }
        
    }

}

-(void)deleteHotspotCommentsDataFromDBwithHotspotId:(NSString*)strHotspotId andPodId:(NSString*)strPodId
{
    NSArray *aryHotspotComments = [Util_HotSpot getHotspotCommentsDatawithHotspotId:strHotspotId podId:strPodId];
    
    for(NSManagedObject *objHotspotComment in aryHotspotComments)
    {
        [context deleteObject:objHotspotComment];
        
        NSError *error= nil;
        if (![context save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }
        
    }
    


}
-(void)deletePostDataFromDBWithObj:(NSManagedObject*)objPod
{
    NSManagedObject *objPost = [self getPostDataFromDBWithObj:[objPod valueForKey:@"pid"]];
    if(objPost != nil)
    {
        [self deleteCommentsDatawithPostId:[objPost valueForKey:@"postId"]];
        
        [self deleteHotspotsSharedDataWithPostId:[objPost valueForKey:@"postId"]];
        
        [self deleteQuestionsFromDBwithPostId:[objPost valueForKey:@"postId"]];
        
    }

}

-(void)deleteHotspotsSharedDataWithPostId:(NSString*)strPostId
{
    NSArray *aryHotspotsShared = [Util_HotSpot getHotspotsSharedDataFromDBwithPostId:strPostId];
    for(NSManagedObject *objHotspotsShared in aryHotspotsShared)
    {
        [context deleteObject:objHotspotsShared];
        NSError *error= nil;
        if (![context save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }
    }
}

-(void)deleteCommentsDatawithPostId:(NSString*)strPostId
{
    NSArray *aryCommentsData = [Util_HotSpot getCommentDatafromDB:strPostId];
    for(NSManagedObject *objComment in aryCommentsData)
    {
        [context deleteObject:objComment];
        NSError *error= nil;
        if (![context save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }
    }
}

-(void)deleteQuestionsFromDBwithPostId:(NSString*)strPostId
{
    NSArray *aryQuestions = [Util_HotSpot getQuestionsDatafromDB:strPostId];
    for(NSManagedObject *objQuestion in aryQuestions)
    {
        [self deleteQuestionCommentsDataFromDBwithObj:objQuestion];
        
        [context deleteObject:objQuestion];
        NSError *error= nil;
        if (![context save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }
    }
    
}

-(void)deleteQuestionCommentsDataFromDBwithObj:(NSManagedObject*)objQuestion
{
    NSArray *aryQuestionComments = [self getQuestionCommentsDataFromDBwithObj:[objQuestion valueForKey:@"questionId"]];
    for(NSManagedObject *objQuestionComment in aryQuestionComments)
    {
        [context deleteObject:objQuestionComment];
        NSError *error= nil;
        if (![context save:&error])
        {
            RLogs(@"Problem saving: %@", [error localizedDescription]);
        }
    }
}

-(NSArray*)getQuestionCommentsDataFromDBwithObj:(NSString*)strquestionId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"QuestionComments" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"questionId == %@", strquestionId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return fetchedObjects;
    else
        return nil;}


# pragma mark get data from DB

-(NSManagedObject*)getPostDataFromDBWithObj:(NSString*)strPodId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"podId == %@",strPodId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
}


-(NSManagedObject*)getPodDataFromDBwithImgId:(NSString*)strImgId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Pod" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ ", strImgId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    
}



@end
