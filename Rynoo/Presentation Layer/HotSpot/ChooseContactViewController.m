//
//  ChooseContactViewController.m
//  Rnyoo
//
//  Created by Rnyoo on 03/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "ChooseContactViewController.h"
#import "ChooseContactsCustomeCell.h"
#import "AppDelegate.h"
#import "PostViewController.h"
#import "Constants.h"

// Class for keeping contacts info
@interface Contacts : NSObject
@property(nonatomic,strong) NSString *userName;
@property(nonatomic,strong) NSString *networkStatus;
@property(nonatomic) BOOL isSelected;

@end

@implementation Contacts

@end


@interface ChooseContactViewController (){
//    NSArray *usersStatus; // For temparary
    NSMutableArray *contactsArray;
    BOOL isPrivateBtnSelected;
    BOOL isSelected;
    NSMutableArray *arySelectedContacts;
    NSInteger index;
    
}
@end

@implementation ChooseContactViewController
@synthesize context,selectedImgId,hotspotId,objHotspotSharedBO;

# pragma mark view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    checkBtnSelected = NO;
    isPrivateBtnSelected = YES;
    contactsArray = [[NSMutableArray alloc]init];
    index = 0;
    arySelectedContacts = [[NSMutableArray alloc]init];
    
    context = [APP_DELEGATE managedObjectContext];

    isSelectAllButtonSelected = NO;
    objHotspotSharedBO = [[hotspotSharedBO alloc]init];

    
  //  [self getFriends];
    
    if([self connected])
    {
        [self getListOfFriends];  // getting list from server
    }
    else
    {
        [self getFriends]; // getting from db if there is no internet connection
    }
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [arySelectedContacts removeAllObjects];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self.chooseContactsTableview setSeparatorColor:[UIColor grayColor]];
    [self setNavigationBarTitle:@"Choose Contacts"];
    [self setLeftBarButtonOnNavigationBarAsBackButton];
}

/* Update Constraints */

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    if([Util isIOS8])
    {
        if(self.view.frame.size.width > self.view.frame.size.height)
            APP_DELEGATE.isPortrait = NO;
        else
            APP_DELEGATE.isPortrait = YES;
        
        if (APP_DELEGATE.isPortrait) {
            self.tableTopConstraint.constant = 63;
        }
        else{
            self.tableTopConstraint.constant = 30;
        }

    }
    else{
        if (APP_DELEGATE.isPortrait) {
            self.tableTopConstraint.constant = 63;
        }
        else{
            self.tableTopConstraint.constant = 30;
        }
    }
    
    [self.chooseContactsTableview reloadData];
   
}




#pragma mark TableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0) {
      // return 0;
        return [contactsArray count];
    }
    return [contactsArray count]; // for temperary
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = ChooseContactsCellID;
    ChooseContactsCustomeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self.chooseContactsTableview setSeparatorColor:[UIColor grayColor]];

    if (cell == nil) {
        cell = [[ChooseContactsCustomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
  
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.estimatedRowHeight = 60.0;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSManagedObject *contactObj = [contactsArray objectAtIndex:indexPath.row];
    cell.userNameLbl.text = [contactObj valueForKey:@"screenName_s"];
    
    
    cell.checkImgView.tag = indexPath.row;
    
   
  
    NSDictionary *dictcontacts = [contactsArray objectAtIndex:indexPath.row];

    
    BOOL isAlreadySelected = [self checkifFriendAlreadyexistswithUID:[dictcontacts valueForKey:@"uid"]];
    if(isAlreadySelected == YES)
    {
        [cell.checkImgView setImage:[UIImage imageNamed:CHECKED_IMAGE] ];
         [arySelectedContacts addObject:[contactsArray objectAtIndex:indexPath.row]];
    }
    else
    {
        [cell.checkImgView setImage:[UIImage imageNamed:UNCHECKED_IMAGE] ];
    }
    
    if(isSelectAllButtonSelected || cell.isSelected)
    {
        [cell.checkImgView setImage:[UIImage imageNamed:CHECKED_IMAGE]];
        [arySelectedContacts addObject:[contactsArray objectAtIndex:indexPath.row]];

    }
    else
        [cell.checkImgView setImage:[UIImage imageNamed:UNCHECKED_IMAGE]];
    
    return cell;
}

-(void)checkBtnActionForCell:(id)sender{
    
   // UIButton *btn = (UIButton*)sender;
    RLogs(@"checked button pressed");
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ChooseContactsCustomeCell *cell = (ChooseContactsCustomeCell*)[tableView cellForRowAtIndexPath:indexPath];
   
    NSDictionary *dict = [contactsArray objectAtIndex:indexPath.row];
    
    BOOL isAlreadySelected = [self checkifFriendAlreadyexistswithUID:[dict valueForKey:@"uid"]];
    
    if(isAlreadySelected == YES)
    {
   //     objHotspotSharedBO.strHotspotsSharedUIds = [dict valueForKey:@"uid"];
        objHotspotSharedBO.arrHotspotsSharedUIds = [contactsArray objectAtIndex:indexPath.row];
     //   [self updateHotspotDatawithUid:[dict valueForKey:@"uid"]];
        [cell.checkImgView setImage:[UIImage imageNamed:UNCHECKED_IMAGE] ];
        [[contactsArray objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"isSelected"];
        [arySelectedContacts removeObject:[contactsArray objectAtIndex:indexPath.row]];

    }
    
    else if([[dict objectForKey:@"isSelected"] isEqualToString:@"YES"])
    {
        [cell.checkImgView setImage:[UIImage imageNamed:UNCHECKED_IMAGE] ];
        [[contactsArray objectAtIndex:indexPath.row] setObject:@"NO" forKey:@"isSelected"];
        
        [arySelectedContacts removeObject:[contactsArray objectAtIndex:indexPath.row]];
        
    }
    else
    {
        [cell.checkImgView setImage:[UIImage imageNamed:CHECKED_IMAGE] ];
        [[contactsArray objectAtIndex:indexPath.row] setObject:@"YES" forKey:@"isSelected"];
        [arySelectedContacts addObject:[contactsArray objectAtIndex:indexPath.row]];
        
    }


}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

-(UILabel*)configureLabelWithText:(NSString*)text{
    UILabel *lbl = [[UILabel alloc]init];
    
    lbl.text = text;
    if ([text isEqualToString:@"Select All"])
        lbl.textColor = [UIColor redColor];
    else
        lbl.textColor=[UIColor darkGrayColor];
    
    lbl.font = [Util Font:FontTypeLight Size:13.0];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment = NSTextAlignmentLeft;
    return lbl;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]init];
    [headerView setBackgroundColor:LIGHT_GRAY];
    
    selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    privateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (section == 1) { // Adding private label and selection button
     /*   privateLbl = [self configureLabelWithText:@"Private"];
        if(APP_DELEGATE.isPortrait){
            privateButton.frame  =CGRectMake(285, 5, 20, 20);
            privateLbl.frame = CGRectMake(15, 5, 60,20);
            self.tableTopConstraint.constant = 64;
        }
        else{
            self.tableTopConstraint.constant = 34;
            privateButton.frame  =CGRectMake(self.view.frame.size.width-35, 5, 20, 20);
            privateLbl.frame = CGRectMake(15, 5, 60,20);
        }
        if(isPrivateBtnSelected) // Checking private button is selected
            [privateButton setImage:[UIImage imageNamed:CHECKED_IMAGE] forState:UIControlStateNormal];
        else
            [privateButton setImage:[UIImage imageNamed:UNCHECKED_IMAGE] forState:UIControlStateNormal];
        [privateButton addTarget:self action:@selector(privateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerView addSubview:privateLbl];
        [headerView addSubview:privateButton];*/
        return headerView;
    }
    else{ // Adding Rnyoo network label and select all button
        rnyooNetworkLbl = [self configureLabelWithText:@"My Rnyoo Network"];
        selectAllLbl = [self configureLabelWithText:@"Select All"];
        
        if(APP_DELEGATE.isPortrait){
            selectButton.frame  =CGRectMake(self.view.frame.size.width-42, 0, 40, 40);
            rnyooNetworkLbl.frame = CGRectMake(15, 10, 200,20);
            selectAllLbl.frame = CGRectMake(225, 10, 60,20);
            //        self.topTableConstraint.constant = 64;
        }
        else{
            //        self.topTableConstraint.constant = 34;
            selectButton.frame  =CGRectMake(self.view.frame.size.width-42, 0, 40, 40);
            rnyooNetworkLbl.frame = CGRectMake(15, 10, 200,20);
            selectAllLbl.frame = CGRectMake(self.view.frame.size.width-95, 10, 60,20);
        }
        
        selectButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        selectButton.backgroundColor = [UIColor clearColor];
        if(isSelectAllButtonSelected) // checking select all button is selected
            [selectButton setImage:[UIImage imageNamed:CHECKED_IMAGE] forState:UIControlStateNormal];
        else
            [selectButton setImage:[UIImage imageNamed:UNCHECKED_IMAGE] forState:UIControlStateNormal];
        
        [selectButton addTarget:self action:@selector(selectAllRnyooContacts:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerView addSubview:selectAllLbl];
        [headerView addSubview:rnyooNetworkLbl];
        [headerView addSubview:selectButton];
        
    }
    
    return headerView;
    
}
// check for selection of buddy

-(BOOL)checkifFriendAlreadyexistswithUID:(NSString*)Uid
{
    if([objHotspotSharedBO.arrHotspotsSharedUIds count])
    {
        NSMutableArray *aryUids =[[NSMutableArray alloc]init];
        
        [aryUids addObject:objHotspotSharedBO.arrHotspotsSharedUIds];
        
        NSString *strSharedUids = [aryUids componentsJoinedByString:@","];
        
        // NSString *strSharedUids = objHotspotSharedBO.strHotspotsSharedUIds;
        
        if ([strSharedUids rangeOfString:@","].location == NSNotFound) {
            RLogs(@"string does not contain ,");
        }
        else
        {
            //        NSArray *aryUids = [objHotspotSharedBO.strHotspotsSharedUIds componentsSeparatedByString:@","];
            if([aryUids containsObject:Uid])
            {
                return YES;
            }
            
        }
  
    }
  
 /*   NSArray *arrhotSpots = [self getSelectedHotspotData];
    
    for(NSManagedObject *obj in arrhotSpots)
    {
        if([[obj valueForKey:@"friendsList"] length] > 0)
        {
            NSArray *aryFreinds = [[obj valueForKey:@"friendsList"]componentsSeparatedByString:@","];
            if([aryFreinds containsObject:Uid])
            {
                return YES;
            }
        }
    }*/

    return NO;
}

-(void)updateHotspotDatawithUid:(NSString*)Uid
{

    /* NSArray *arrhotSpots = [self getSelectedHotspotData];
    for(NSManagedObject *obj in arrhotSpots)
    {
        NSArray *ary;
        NSArray *aryFreinds = [[obj valueForKey:@"friendsList"]componentsSeparatedByString:@","];
        RLogs(@"%@",aryFreinds);
        if([aryFreinds containsObject:Uid])
        {
            ary =    [aryFreinds filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@",Uid]];
            NSString *strUID = [ary componentsJoinedByString:@","];

            [obj setValue:strUID forKey:@"friendsList"];

            NSError *error= nil;
            if (![context save:&error])
            {
                RLogs(@"Problem saving: %@", [error localizedDescription]);
            }
        }
        
      
    }*/
}

-(void)selectAllRnyooContacts:(id)sender
{
    isSelectAllButtonSelected = (!isSelectAllButtonSelected);
    [_chooseContactsTableview reloadData];
}

-(void)privateBtnClicked:(id)sender{
    if (isPrivateBtnSelected) {
        isPrivateBtnSelected = NO;
    }
    else{
        isPrivateBtnSelected = YES;
    }
    [_chooseContactsTableview reloadData];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
}

- (IBAction)DoneBtnPressed:(id)sender
{
    if([contactsArray count] == 0)
    {
   //     [self.navigationController popViewControllerAnimated:YES];
     //   return;

    }
    else if([arySelectedContacts count] == 0)
    {
        [self showTheAlert:@"Please select contact"];
        return;
    }
    
    if([arySelectedContacts count])
    {
        [self updateHotspotdatawithContacts:arySelectedContacts];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

#pragma get contacts from DB

-(void)getFriends
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Friends" inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    RLogs(@"all FRIENDS array:%@",fetchedObjects);
    for(NSManagedObject *obj in fetchedObjects)
    {
        [obj setValue:@"NO" forKey:@"isContactSelectedForPost"];
    }
    
    [contactsArray addObjectsFromArray:fetchedObjects];
    
    
}


/* get selected hotspot data from db */

-(NSArray*)getSelectedHotspotData
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Hotspot" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && hId == %@",self.selectedImgId,self.hotspotId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    RLogs(@"all hotspots array:%@",fetchedObjects);
    
    if([fetchedObjects count])
        return fetchedObjects;
    else
        return nil;
    return nil;
}


-(void)updateHotspotdatawithContacts:(NSMutableArray*)aryContacts
{

    NSArray *arrhotSpots = [self getSelectedHotspotData];
    NSString *strUid;
    NSMutableArray *aryUids = [[NSMutableArray alloc]init];
    
    for(NSManagedObject *contactObj in aryContacts)
    {
        strUid = [NSString stringWithFormat:@"%@",[contactObj valueForKey:@"uid"]];
        [aryUids addObject:strUid];
        
    }
    
    objHotspotSharedBO.strImgId = self.selectedImgId;
    
    objHotspotSharedBO.strHotspotId = self.hotspotId;
    
    objHotspotSharedBO.arrHotspotsSharedUIds = aryUids;
   
    for(NSManagedObject *objHotspot in arrhotSpots)
    {
        objHotspotSharedBO.strPodId = [objHotspot valueForKey:@"podId"];
    }
    
    [APP_DELEGATE.aryHotspotSharedBO addObject:objHotspotSharedBO];
    
 }

#pragma webservice calls

/*getting list of friends from server */

-(void)getListOfFriends
{
    [self showLoader];
    
    AFHTTPRequestOperationManager *manager = [Util getAppOperationRequestManager];
    
    NSMutableDictionary *dictInfo = [[NSMutableDictionary alloc]init];
    [dictInfo setValue:[Util getNewUserID] forKey:@"uid"];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@/buddies/uid/%@",ServerURL,[Util getNewUserID]];
    
    [manager GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"list of friends response:%@",responseObject);
       
         NSArray *arrFriendsList = [responseObject valueForKey:@"buddies"];
         
         for(int i=0;i< [arrFriendsList count];i++)
         {
             NSDictionary   *userInfo = [arrFriendsList objectAtIndex:i];
             
             NSMutableDictionary *dictInfo = [[NSMutableDictionary alloc]init];
             [dictInfo setObject:@"NO" forKey:@"isSelected"];
             [dictInfo setObject:[userInfo valueForKey:@"avatar"] forKey:@"avatar"];
             [dictInfo setObject:[userInfo valueForKey:@"uid"] forKey:@"uid"];
             [dictInfo setObject:[userInfo valueForKey:@"screenName_s"] forKey:@"screenName_s"];
             
             [dictInfo setObject:[userInfo valueForKey:@"acceptedInvite"] forKey:@"acceptedInvite"];
             [dictInfo setObject:[userInfo valueForKey:@"blocked"] forKey:@"blocked"];
            
             
             if([userInfo valueForKey:@"createdAt"]  != nil && [userInfo valueForKey:@"createdAt"] > 0)
                 [dictInfo setObject:[userInfo valueForKey:@"createdAt"] forKey:@"createdAt"];
             else
                 [dictInfo setObject:@"" forKey:@"createdAt"];

             [dictInfo setObject:[userInfo valueForKey:@"name_s"] forKey:@"name_s"];
             [dictInfo setObject:[userInfo valueForKey:@"showStatus"] forKey:@"showStatus"];
             [dictInfo setObject:[userInfo valueForKey:@"uid"] forKey:@"uid"];


             [contactsArray addObject:dictInfo];
         }

         RLogs(@"contactsarray:%@",contactsArray);
       //  contactsArray = [responseObject valueForKey:@"buddies"];
         [self.chooseContactsTableview reloadData];
         [self removeLoader];
         
         
       //  [contactsArray addObjectsFromArray:fetchedObjects];

         
         
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             RLogs(@"Error: %@", error);
             [self removeLoader];
             [self showNetworkErrorAlertWithTag:333333];
             
         }];
    
}

# pragma mark alertview delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(alertView.tag == 333333)
    {
        if(buttonIndex == 0)
        {
            [self getListOfFriends];
            return;
        }
    }
    
    
 }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
