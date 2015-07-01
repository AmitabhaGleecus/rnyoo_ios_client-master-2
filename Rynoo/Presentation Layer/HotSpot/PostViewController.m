//
//  PostViewController.m
//  Rnyoo
//
//  Created by Rnyoo on 02/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "PostViewController.h"
#import "HotspotCustomCell.h"
#import "Util.h"
#import "BaseViewController.h"
#import "ChooseContactViewController.h"
#import "hotSpotCircleView.h"
#import "Util_HotSpot.h"
#import "NetworkViewController.h"


@interface PostViewController ()
{
    NSString *strHotspotId;
}
@end

@implementation PostViewController
@synthesize context,selectedImgId,hotspotsArray,objHotSpotSharedBO, strPodId, source;
@synthesize arrAddedHsIds;
@synthesize arrUpdatedHsIds, arrRemainedHsIds,isPodCreated;

@synthesize isPublisherUpdate, isPublisherRePost, strPostId;

# pragma mark view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    context = [APP_DELEGATE managedObjectContext];
    hotspotsArray = [[NSMutableArray alloc]init];

    [APP_DELEGATE.aryHotspotSharedBO removeAllObjects];
    
    NSMutableArray *arrHsIds = [[NSMutableArray alloc] init];
    if([self.arrAddedHsIds count])
        [arrHsIds addObjectsFromArray:self.arrAddedHsIds];
    
    if([self.arrUpdatedHsIds count])
        [arrHsIds addObjectsFromArray:self.arrUpdatedHsIds];
    
    if([self.arrRemainedHsIds count])
        [arrHsIds addObjectsFromArray:self.arrRemainedHsIds];
    
    if(self.source == FROM_PUBLISHER && self.isPublisherUpdate)
    {
        NSArray *arrHs = [Util_HotSpot getHotspotsOfHSIds:arrHsIds];
        [hotspotsArray addObjectsFromArray:arrHs];
    }
    else
        [self getHotspotsDatafromDB];
    
    for(NSManagedObject *hs in hotspotsArray)
    {
        RLogs(@"Hotspto Id1 - %@", [hs valueForKey:@"hId"]);
    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   // [self getHotspotsDatafromDB];
   // [_hotspotTableView reloadData];
    
    isNaviagtedToContacts = YES;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.hotspotTableView setSeparatorColor:[UIColor grayColor]];
    [self setNavigationBarTitle:@"Choose Hotspots"];
    [self setLeftBarButtonOnNavigationBarAsBackButton];
}

/* Update Constraints */
-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (APP_DELEGATE.isPortrait) {
        self.tableTopConstraint.constant = 0;
    }
    else{
        self.tableTopConstraint.constant = 0;
    }
}
#pragma mark UITextField delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark TableView Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [self.hotspotsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = HotspotCellID;
    [self.hotspotTableView setSeparatorColor:[UIColor grayColor]];
    HotspotCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[HotspotCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.hotspotDesc.delegate = self;
    cell.hotspotDesc.tag = indexPath.row;

    [cell.hotspotDesc setFrame:CGRectMake(cell.hotspotDesc.frame.origin.x, cell.hotspotDesc.frame.origin.y, cell.hotspotDesc.frame.size.width + 200, cell.hotspotDesc.frame.size.height)];
    cell.hotspotDesc.backgroundColor = [UIColor clearColor];
    
    //cell.hotspotDesc.editable = NO;
    
   /* tableView.estimatedRowHeight = 100.0;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;*/
    
    // Configuring hotspot contents on the cell
    NSManagedObject *hotspotObj = [self.hotspotsArray objectAtIndex:indexPath.row];
    cell.hotspotTitle.text = [hotspotObj valueForKey:@"strLabel"];
    cell.hotspotDesc.text = [hotspotObj valueForKey:@"strDescription"];
    [cell.hotspotBGImgView setBackgroundColor:[UIColor grayColor]];
    
    NSString *strColor = [[hotspotObj valueForKey:@"hotspotColor"] lowercaseString];
    
    RLogs(@"prestrColor - %@", strColor);
    
    if([strColor isEqualToString:@"red"])
    {
        RLogs(@"strColor - %@", strColor);
        cell.hotspotImgView.image = [UIImage imageNamed:HOTSPOT_RED_ICON];
    }
    else if ([strColor isEqualToString:@"white"])
    {
        RLogs(@"strColor - %@", strColor);
        cell.hotspotImgView.image = [UIImage imageNamed:HOTSPOT_WHITE_ICON];
    }
    else if ([strColor isEqualToString:@"blue"])
    {
        RLogs(@"strColor - %@", strColor);
        cell.hotspotImgView.image = [UIImage imageNamed:HOTSPOT_BLUE_ICON];
    }
    else if ([strColor isEqualToString:@"yellow"])
    {
        RLogs(@"strColor - %@", strColor);
        cell.hotspotImgView.image = [UIImage imageNamed:HOTSPOT_YELLOW_ICON];
    }
    else
    {
        RLogs(@"strColor - %@", strColor);
        cell.hotspotImgView.image = [UIImage imageNamed:HOTSPOT_WHITE_ICON];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSManagedObject *hotspotObj = [self.hotspotsArray objectAtIndex:indexPath.row];
    strHotspotId = [hotspotObj valueForKey:@"hId"];
    
    [self performSegueWithIdentifier:ChooseContactSegue sender:nil];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark UITextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:textView.tag inSection:0];
    NSManagedObject *hotspotObj = [self.hotspotsArray objectAtIndex:index.row];
    strHotspotId = [hotspotObj valueForKey:@"hId"];
    
    [self performSegueWithIdentifier:ChooseContactSegue sender:nil];
    return NO;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    RLogs(@"identifier:%@",segue.identifier);
    
    if ([segue.identifier isEqualToString:ChooseContactSegue]) {
        
        ChooseContactViewController *objContacts = (ChooseContactViewController*)segue.destinationViewController;
        objContacts.selectedImgId = self.selectedImgId;
        objContacts.hotspotId = strHotspotId;
        
    }
    else if([segue.identifier isEqualToString:@"postInfoFromHotspots"])
    {
        PostInfoViewController *objPostInfo = (PostInfoViewController*)segue.destinationViewController;
        objPostInfo.selectedImgId = self.selectedImgId;
        objPostInfo.hotspotId = strHotspotId;
        objPostInfo.strPodId = self.strPodId;
        
        objPostInfo.dictPod = self.dictPod;
        objPostInfo.isPublisherRePost = self.isPublisherRePost;
        objPostInfo.isPodCreated =  isPodCreated;
        
        
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
     if ([identifier isEqualToString:ChooseContactSegue]) {
         if(!isNaviagtedToContacts)
             return YES;
         else
             return NO;
     }
    return YES;
}
# pragma  get hotspots data from DB

-(void)getHotspotsDatafromDB
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Hotspot" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && podId == %@",self.selectedImgId, self.strPodId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    [hotspotsArray addObjectsFromArray:fetchedObjects];
    RLogs(@"all hotspots array:%@",hotspotsArray);
}

- (IBAction)DoneAssigningContactsButtonAction:(id)sender
{

    NSArray *aryobjHotSpotSharedBO = APP_DELEGATE.aryHotspotSharedBO;
    
    if(self.source == FROM_PUBLISHER)
    {
        if(self.isPublisherUpdate)
        {
            //Call Update service...
            [self updatePost];
            return;
        }
        
        if(self.isPublisherRePost)
        {
            //Repost action...
        }
        
    }
    
    
    if([aryobjHotSpotSharedBO count] == 0)
    {
        [self showTheAlert:@"Please select Contacts to post"];
        return;
    }
    [self performSegueWithIdentifier:@"postInfoFromHotspots" sender:self];
}

-(void)updatePost
{
    
    if([self.arrAddedHsIds count])
    {
        [self showLoader];
        
        [self callAddHotspotsService];
    }
    else if ([self.arrUpdatedHsIds count])
    {
        [self showLoader];

        [self callUpdateHotspotsService];
    }
    else if ([self.arrDeleteHsIds count])
    {
        [self showLoader];

        [self callDeleteHotspotsService];
    }
    else
    {
        //There is no change in HS structure.
        
        [self showLoader];
        [self callUpdateHotspotsSharedService];
    }
}

-(void)callAddHotspotsService
{
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc]init];
    
    NSArray *aryHoptspotSharedBO = APP_DELEGATE.aryHotspotSharedBO;
    
    [dictPost setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPost setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPost setValue:self.strPostId forKey:@"rpostid_s"];
    
    
    NSMutableArray *aryHotspotsShared = [[NSMutableArray alloc]init];
    NSMutableArray *aryHotspots = [[NSMutableArray alloc]init];

    
    
    
    for(NSString *strHsId in self.arrAddedHsIds)
    {
    
        for(NSManagedObject *objHotspot in hotspotsArray)
        {
            if([strHsId isEqualToString:[objHotspot valueForKey:@"hId"]])
            {
                NSMutableDictionary *dictHotspot = [[NSMutableDictionary alloc]init];
                
                [dictHotspot setValue:[objHotspot valueForKey:@"hId"] forKey:@"hotspotId"];
                
                [dictHotspot setValue:[objHotspot valueForKey:@"strLabel"] forKey:@"hotspotLabel"];
                [dictHotspot setValue:[objHotspot valueForKey:@"strDescription"] forKey:@"hotspotDescription"];

                
                NSMutableDictionary *dictLocation = [[NSMutableDictionary alloc]init];
                
                [dictLocation setValue:[objHotspot valueForKey:@"xCoordinate"] forKey:@"x"];
                
                [dictLocation setValue:[objHotspot valueForKey:@"yCoordinate"] forKey:@"y"];
                
                [dictHotspot setValue:dictLocation forKey:@"location"];
                
                NSMutableDictionary *dictAudio = [[NSMutableDictionary alloc]init];
                
                if([[objHotspot valueForKey:@"audioFilePath"] length] >0)
                {
                    
                    [dictAudio setValue:[objHotspot valueForKey:@"audioId"] forKey:@"audioId"];
                    [dictAudio setValue:[objHotspot valueForKey:@"audioFileUrl"] forKey:@"audioUrl"];
                }
                else
                {
                    [dictAudio setValue:@"" forKey:@"audioId"];
                    [dictAudio setValue:@"" forKey:@"audioUrl"];
                }
                
                [dictHotspot setValue:dictAudio forKey:@"media"];
                
                [dictHotspot setValue:[NSNumber numberWithBool:YES] forKey:@"sharable"];
                [dictHotspot setValue:[NSNumber numberWithBool:NO] forKey:@"editable"];

                [dictHotspot setValue:[objHotspot valueForKey:@"url"] forKey:@"clickUrl"];
                
                NSString *strColor = @"white";
                
                if([objHotspot valueForKey:@"hotspotColor"] != nil && [[objHotspot valueForKey:@"hotspotColor"] length] > 0)
                    strColor = [[objHotspot valueForKey:@"hotspotColor"] lowercaseString];
                
                [dictHotspot setValue:strColor forKey:@"markerColor"];
                
                [dictHotspot setValue:[objHotspot valueForKey:@"zoomFactor"] forKey:@"zoomFactor"];

                
                [aryHotspots addObject:dictHotspot];
                break;

            }
        }
        
        
    for(hotspotSharedBO *obj in aryHoptspotSharedBO)
    {
        if([strHsId isEqualToString:obj.strHotspotId])
        {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        NSMutableArray *arySharedUids = [[NSMutableArray alloc]init];
        
        [dict setValue:obj.strHotspotId forKey:@"hotspotId"];
        
        for(NSString *strUid in obj.arrHotspotsSharedUIds)
        {
            [arySharedUids addObject:strUid];
            
        }
        
        
        [dict setValue:arySharedUids forKey:@"sharedWith"];
        
        [aryHotspotsShared addObject:dict];
            break;
        }
    }
    
    }
    [dictPost setValue:aryHotspots forKey:@"hotspots"];

    [dictPost setValue:aryHotspotsShared forKey:@"hotspotsShared"];
    
    RLogs(@"dict:%@",dictPost);
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/update/addhotspots",ServerURL] parameters:dictPost success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"post response:%@",responseObject);
         
         for(NSDictionary *dict in aryHotspotsShared)
         {
             [Util_HotSpot saveHotspotsSharedDataWithHsId:[dict valueForKey:@"hotspotId"] ofPostId:self.strPostId withUsers:[dict valueForKey:@"sharedWith"]];
         }
         
         if ([self.arrUpdatedHsIds count])
         {
             
             [self callUpdateHotspotsService];
         }
         else if ([self.arrDeleteHsIds count])
         {
             
             [self callDeleteHotspotsService];
         }
         else
         {
             //There is no change in HS structure.
             
             [self callUpdateHotspotsSharedService];
         }

       }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post Error: %@", error);
              //[self removeLoader];
              //[self showNetworkErrorAlertWithTag:111111];
              if ([self.arrUpdatedHsIds count])
              {
                  
                  [self callUpdateHotspotsService];
              }
              else if ([self.arrDeleteHsIds count])
              {
                  
                  [self callDeleteHotspotsService];
              }
              else
              {
                  //There is no change in HS structure.
                  
                  [self callUpdateHotspotsSharedService];
              }

              
          }];

}

-(void)callUpdateHotspotsService
{
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc]init];
    
    NSArray *aryHoptspotSharedBO = APP_DELEGATE.aryHotspotSharedBO;
    
    [dictPost setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPost setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPost setValue:self.strPostId forKey:@"rpostid_s"];
    
    
    NSMutableArray *aryHotspotsShared = [[NSMutableArray alloc]init];
    NSMutableArray *aryHotspots = [[NSMutableArray alloc]init];
    
    
    
    
    for(NSString *strHsId in self.arrUpdatedHsIds)
    {
        
        for(NSManagedObject *objHotspot in hotspotsArray)
        {
            if([strHsId isEqualToString:[objHotspot valueForKey:@"hId"]])
            {
                NSMutableDictionary *dictHotspot = [[NSMutableDictionary alloc]init];
                
                [dictHotspot setValue:[objHotspot valueForKey:@"hId"] forKey:@"hotspotId"];
                
                [dictHotspot setValue:[objHotspot valueForKey:@"strLabel"] forKey:@"hotspotLabel"];
                
                [dictHotspot setValue:[objHotspot valueForKey:@"strDescription"] forKey:@"hotspotDescription"];

                NSMutableDictionary *dictLocation = [[NSMutableDictionary alloc]init];
                
                [dictLocation setValue:[objHotspot valueForKey:@"xCoordinate"] forKey:@"x"];
                
                [dictLocation setValue:[objHotspot valueForKey:@"yCoordinate"] forKey:@"y"];
                
                [dictHotspot setValue:dictLocation forKey:@"location"];
                
                NSMutableDictionary *dictAudio = [[NSMutableDictionary alloc]init];
                
                if([[objHotspot valueForKey:@"audioFilePath"] length] >0)
                {
                    
                    [dictAudio setValue:[objHotspot valueForKey:@"audioId"] forKey:@"audioId"];
                    [dictAudio setValue:[objHotspot valueForKey:@"audioFileUrl"] forKey:@"audioUrl"];
                }
                else
                {
                    [dictAudio setValue:@"" forKey:@"audioId"];
                    [dictAudio setValue:@"" forKey:@"audioUrl"];
                }
                
                [dictHotspot setValue:dictAudio forKey:@"media"];
                
                [dictHotspot setValue:[NSNumber numberWithBool:YES] forKey:@"sharable"];
                [dictHotspot setValue:[NSNumber numberWithBool:NO] forKey:@"editable"];
                
                [dictHotspot setValue:[objHotspot valueForKey:@"url"] forKey:@"clickUrl"];
                
                NSString *strColor = @"white";
                
                if([objHotspot valueForKey:@"hotspotColor"] != nil && [[objHotspot valueForKey:@"hotspotColor"] length] > 0)
                    strColor = [[objHotspot valueForKey:@"hotspotColor"] lowercaseString];
                
               [dictHotspot setValue:strColor forKey:@"markerColor"];
                
                [dictHotspot setValue:[objHotspot valueForKey:@"zoomFactor"] forKey:@"zoomFactor"];

                [aryHotspots addObject:dictHotspot];
                break;
                
            }
        }
        
        
        for(hotspotSharedBO *obj in aryHoptspotSharedBO)
        {
            if([strHsId isEqualToString:obj.strHotspotId])
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                NSMutableArray *arySharedUids = [[NSMutableArray alloc]init];
                
                [dict setValue:obj.strHotspotId forKey:@"hotspotId"];
                
                for(NSString *strUid in obj.arrHotspotsSharedUIds)
                {
                    [arySharedUids addObject:strUid];
                    
                }
                
                
                [dict setValue:arySharedUids forKey:@"sharedWith"];
                
                [aryHotspotsShared addObject:dict];
                break;
            }
        }
        
    }
    [dictPost setValue:aryHotspots forKey:@"hotspots"];
    
    [dictPost setValue:aryHotspotsShared forKey:@"hotspotsShared"];
    
    RLogs(@"dict:%@",dictPost);
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/update/hotspots",ServerURL] parameters:dictPost success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"post response:%@",responseObject);
         if ([self.arrDeleteHsIds count])
         {
             
             [self callDeleteHotspotsService];
         }
         else
         {
             //There is no change in HS structure.
             
             [self callUpdateHotspotsSharedService];
         }

     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post Error: %@", error);
              //[self removeLoader];
              //[self showNetworkErrorAlertWithTag:111111];
              if ([self.arrDeleteHsIds count])
              {
                  
                  [self callDeleteHotspotsService];
              }
              else
              {
                  //There is no change in HS structure.
                  
                  [self callUpdateHotspotsSharedService];
              }

              
              
          }];
    
}

-(void)callDeleteHotspotsService
{
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc]init];
    
    [dictPost setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPost setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPost setValue:self.strPodId forKey:@"rpid_s"];
    
    [dictPost setValue:self.arrDeleteHsIds forKey:@"hotspots"];
    
    
    RLogs(@"dict:%@",dictPost);
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/pods/delete/hotspots",ServerURL] parameters:dictPost success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"post response:%@",responseObject);
         [self showUpdateMessage];

     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post Error: %@", error);
              [self showUpdateMessage];
              //[self showNetworkErrorAlertWithTag:111111];
              
              
          }];
    
}

-(void)callUpdateHotspotsSharedService
{
    if(![self.arrRemainedHsIds count])
    {
        [self showUpdateMessage];
        return;
    }
    
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc]init];
    
    NSArray *aryHoptspotSharedBO = APP_DELEGATE.aryHotspotSharedBO;
    
    [dictPost setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPost setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPost setValue:self.strPostId forKey:@"rpostid_s"];
    
    
    NSMutableArray *aryHotspotsShared = [[NSMutableArray alloc]init];
    NSMutableArray *aryHotspots = [[NSMutableArray alloc]init];
    
    
        
        for(hotspotSharedBO *obj in aryHoptspotSharedBO)
        {
            
            
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                NSMutableArray *arySharedUids = [[NSMutableArray alloc]init];
                
                [dict setValue:obj.strHotspotId forKey:@"hotspotId"];
                
                for(NSString *strUid in obj.arrHotspotsSharedUIds)
                {
                    [arySharedUids addObject:strUid];
                    
                }
                
                
                [dict setValue:arySharedUids forKey:@"sharedWith"];
                
                [aryHotspotsShared addObject:dict];
            
            
        }
        
    
    [dictPost setValue:aryHotspots forKey:@"hotspots"];
    
    [dictPost setValue:aryHotspotsShared forKey:@"hotspotsShared"];
    
    RLogs(@"dict:%@",dictPost);
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/update/hotspots",ServerURL] parameters:dictPost success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"post response:%@",responseObject);
                      [self showUpdateMessage];
         
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post Error: %@", error);
              //[self removeLoader];
              //[self showNetworkErrorAlertWithTag:111111];
                               [self showUpdateMessage];
              
              
              
              
          }];
    
}

-(void)showUpdateMessage
{
    [self removeLoader];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rnyoo" message:@"Updated Successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 2;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 2)
    {
        [self navigateToNetwork];
    }
}

-(void)navigateToNetwork
{
    NetworkViewController *networkVC = (NetworkViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"Network"];
    
    [self.navigationController pushViewController:networkVC animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
