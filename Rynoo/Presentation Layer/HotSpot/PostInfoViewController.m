//
//  PostInfoViewController.m
//  Rnyoo
//
//  Created by Rnyoo on 04/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "PostInfoViewController.h"
#import "PostInfoCell.h"

@interface PostInfoViewController ()
{
    BOOL isLocationSwitchOn;
    BOOL isDateSwitchOn;

    NSString *strLongitude;
    NSString *strLatitude;
    UILabel *lblLocation;
    UILabel *lblCustomLocation;
    NSString *strLocation;
      NSString  *strDate;
}
@end

@implementation PostInfoViewController
@synthesize selectedImgId;
@synthesize context,hotspotId,objHotSpotSharedBO,isPodCreated;


- (void)viewDidLoad {
    [super viewDidLoad];
    isLocationSwitchOn= NO;
    isDateSwitchOn = NO;
    
    context = [APP_DELEGATE managedObjectContext];

    strLocation =[NSString stringWithFormat:@"HYD , INDIA"];
    strLatitude = @"";
    strLongitude = @"";
    
    // Do any additional setup after loading the view.
    tblTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToResignKeyBoard)];
    
    if(!self.isPublisherRePost)
    {
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
        [locationManager startUpdatingLocation];
    }
    
    tblLocationsList = [[UITableView alloc] initWithFrame:CGRectMake(50, 50, (self.view.frame.size.width - 100), self.view.frame.size.height - 100) style:UITableViewStylePlain];
    tblLocationsList.delegate = self;
    tblLocationsList.dataSource = self;
    tblLocationsList.hidden = YES;
    tblLocationsList.layer.borderColor = [[UIColor grayColor] CGColor];
    tblLocationsList.layer.borderWidth = 1.0;
    tblLocationsList.layer.cornerRadius = 4.0;
    tblLocationsList.clipsToBounds = YES;
    [self.view addSubview:tblLocationsList];


}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self setNavigationBarTitle:@"Information"];
    [self setLeftBarButtonOnNavigationBarAsBackButton];
}


#pragma mark KeyBoard Notifications
-(void)keyboardDidShow:(NSNotification*)notification
{
    RLogs(@"textfield :%@",txtFld.text);
    [_postInfoTableView addGestureRecognizer:tblTapGesture];
    if(txtFld.tag == 2222)
    {
        RLogs(@"keyboardDidShow - %@", [notification.userInfo description]);
    
    
        CGFloat height;
    
        CGRect keyBoardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
        if(APP_DELEGATE.isPortrait)
            height = keyBoardRect.size.height;
        else
            height = keyBoardRect.size.height;
    
    
        RLogs(@"height - %f", height);
        
        NSLog(@"self centre - %@", NSStringFromCGPoint(self.view.center));
        NSLog(@"KeyBoard - %@", NSStringFromCGRect(keyBoardRect));
        NSLog(@"TxtFld - %@", NSStringFromCGRect(txtFldCustomLocation.frame));
    
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
       
        
        _tblBottomConstrait.constant = keyBoardRect.size.height - 50;

        
        tblLocationsList.frame = CGRectMake(50, 80, self.view.frame.size.width - 100,  keyBoardRect.origin.y - 100 - txtFldCustomLocation.frame.size.height );
        _postInfoTableView.contentOffset = CGPointMake(_postInfoTableView.contentOffset.x, _postInfoTableView.contentOffset.y + (2*txtFldCustomLocation.frame.size.height));


        [UIView commitAnimations];
        
       
    }
    
    
    
}
-(void)keyboardFrameChanged:(NSNotification*)notification
{
    
}
-(void)keyboardWillBeHidden:(NSNotification*)notification
{
    [_postInfoTableView removeGestureRecognizer:tblTapGesture];
    
    if(txtFld.tag == 2222)
    {
        RLogs(@"keyboardWillBeHidden");
        
        RLogs(@"keyboardWillBeHidden - %@", [notification.userInfo description]);
        
        
        CGFloat height;
        height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        
        
        
        RLogs(@"height - %f", height);
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.3];
      //  self.view.center = CGPointMake(self.view.center.x, self.view.center.y + height);
        
      //  _postInfoTableView.frame = CGRectMake(_postInfoTableView.frame.origin.x, _postInfoTableView.frame.origin.y, _postInfoTableView.frame.size.width, self.view.frame.size.height - height);
        
      //  [_postInfoTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        _tblBottomConstrait.constant = 0;
        [UIView commitAnimations];

    }
}

-(void)tapToResignKeyBoard
{
    lblCustomLocation.text = [NSString stringWithFormat:@"%@",txtFld.text];
    
    [txtFld resignFirstResponder];
    
    tblLocationsList.hidden = YES;

}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtFld resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    if (APP_DELEGATE.isPortrait) {
        self.tableTopConstraint.constant = 64;
    }
    else{
        self.tableTopConstraint.constant = 44;
    }
}

#pragma mark TextField Delegates

//These are the TextField delegate methods for hotspot name textfield.
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    //When the user wants to edit textfield, jsut clearing the text like Label in textfield.
    txtFld = textField;

    if(textField.tag == 2222)
    {
        if(self.isPublisherRePost)
            return NO;
        
        textField.text = @"";
        textField.placeholder = nil;
        return YES;
    }
  
   
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if(textField.tag == 2222)
    {
        tblLocationsList.hidden = YES;
     if(string.length)
     {
         if(textField.text.length + 1 >= 2)
         {
             [self fetchCitiesFromGoogleAPI:textField.text];
         }
     }
        else
        {
            if(textField.text.length - 1 >= 2)
            {
                [self fetchCitiesFromGoogleAPI:textField.text];
            }
        }
    }
    
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
     lblCustomLocation.text = [NSString stringWithFormat:@"%@",txtFld.text];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Post Info tableview delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == tblLocationsList)
        return 1;
    
    return 3;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if(tableView == tblLocationsList)
        return [arrLocations count];
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    
    if(indexPath.section != 0)
        return 44;
    else
        return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == tblLocationsList)
    {
        static NSString *cellIdentifier1 = @"cell";
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (cell1 == nil) {
            cell1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
        }
        
        cell1.textLabel.text = [arrLocations objectAtIndex:indexPath.row];
        
        return cell1;

    }
    
    static NSString *cellIdentifier = PostInfoCellID;
    PostInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PostInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
  
    if (indexPath.section == 0) {
        cell.lineLbl.hidden = NO;
        cell.postTitleTxtFld.hidden = NO;
        [cell.postTitleTxtFld setFont:[Util Font:FontTypeRegular Size:15.0]];
        txtFld = cell.postTitleTxtFld;
        txtFld.delegate = self;
        txtFld.tag = 111;
        txtFld.autocorrectionType = UITextAutocorrectionTypeNo;

        if([objUtil isiOS7])
            [[UITextField appearance] setTintColor:[Util appHeaderColor]];
        else
        {
            
        }
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else if(indexPath.section ==1){
        cell.switchBtn.hidden = NO;
        cell.pictureLbl.hidden = NO;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:205.0/255.0f green:205.0/255.0f blue:205.0/255.0f alpha:1.0f];

        cell.lineLbl.hidden = YES;
        switchDate = cell.switchBtn;
        switchDate.tag = 222;
       
    }
    
    else if(indexPath.section ==2 )
    {
   
        cell.switchBtn.hidden = NO;
       
        cell.pictureLbl.hidden = NO;
        cell.pictureLbl.text = @"Picture taken at";
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor colorWithRed:205.0/255.0f green:205.0/255.0f blue:205.0/255.0f alpha:1.0f];
        cell.lineLbl.hidden = YES;
        switchDate = cell.switchBtn;
           switchDate.tag = 333;
        if([switchDate isOn])
        {
            switchDate.on = YES;
            switchDate.tag = 333;

        }

    }
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0 || section ==1)
        return 20.0;
    
    return 40.0;
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 2 && isLocationSwitchOn)
        return 150;
    return 0.0;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if(isDateSwitchOn && section == 2 )
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 30)];
        label.font = [Util Font:FontTypeItalic Size:13.0];
        
        if([strDate length]>0)
             label.text = [NSString stringWithFormat:@"%@",strDate];
        else
            label.text =  @"Picture taken time not found!";
       
        [view addSubview:label];
        return view;
    }
    else
        return [[UIView alloc] initWithFrame:CGRectZero] ;
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    if(isLocationSwitchOn && section ==2)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 150)];
        
        lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, tableView.frame.size.width, 30)];
        lblLocation.font = [Util Font:FontTypeItalic Size:13.0];
        
        if(self.isPublisherRePost)
        {
            NSManagedObject *objManagedObjPod = [self getPodDataFromDB];
             lblLocation.text = [objManagedObjPod valueForKey:@"location"];
        }
        else
                lblLocation.text =  strLocation;
        
        [view addSubview:lblLocation];
        
        
        txtFldCustomLocation = [[UITextField alloc] initWithFrame:CGRectMake(10, 55, tableView.frame.size.width, 30)];
        txtFldCustomLocation.font = [Util Font:FontTypeItalic Size:13.0];
        txtFldCustomLocation.delegate = self;
        txtFldCustomLocation.autocorrectionType = UITextAutocorrectionTypeNo;
        txtFldCustomLocation.tag = 2222;
        if(self.isPublisherRePost)
        {

       //     txtFldCustomLocation.text = [objManagedObjPod valueForKey:@"location"];
            txtFldCustomLocation.hidden = YES;
        }
        else
        {
            txtFldCustomLocation.placeholder = @"Or Type Custom Location" ;
            txtFldCustomLocation.hidden = NO;

        }
       
        [view addSubview:txtFldCustomLocation];
        
        
        UIView *lineVw = [[UIView alloc]initWithFrame:CGRectMake(10, 85, tableView.frame.size.width - 20, 2)];
        lineVw.backgroundColor = [Util appHeaderColor];
        if(self.isPublisherRePost)
        {
            lineVw.hidden = YES;
        }
        else
            lineVw.hidden = NO;
        
        [view addSubview:lineVw];
        
        return view;
    }
    else
        return [[UIView alloc] initWithFrame:CGRectZero] ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tblLocationsList)
    {
    tableView.hidden = YES;
    txtFldCustomLocation.text = [arrLocations objectAtIndex:indexPath.row];
        [txtFldCustomLocation resignFirstResponder];
    }
}

- (IBAction)postNow:(id)sender
{
    RLogs(@"title:%@",txtFld.text);
    
    
    if([self connected])
    {
        if(isPodCreated && _isPublisherRePost)
        {
            [self updatePodData];
            [self callUpdatePodService];

        }
        else if(!_isPublisherRePost )
        {
            [self updatePodData];
            [self callUpdatePodService];

        }
        
        else
            [self sendRequestForPost];

    }
    else
    {
         [self showNoInternetMessage];
         return;
    }
    
//    
//    if([self connected])
//    {
//        [self sendRequestForPost];
//    }
//    else
//    {
//        [self showNoInternetMessage];
//        return;
//    }

    
    //[self performSegueWithIdentifier:PostDetails sender:nil];
}

- (IBAction)switchActionForLocation:(UISwitch*)sender
{
    NSManagedObject *objImage = [self getImageDataFromDB];

    if(sender.tag == 333 )
    {
        if([sender isOn])
        {
            isLocationSwitchOn = YES;
            if([[objImage valueForKey:@"imgLocation"]length] > 0)
            {
                   [locationManager startUpdatingLocation];
                
         //       strLocation = [NSString stringWithFormat:@"%@",[objImage valueForKey:@"imgLocation"]];
            }
            

        //    [locationManager startUpdatingLocation];

        }
        else
            isLocationSwitchOn = NO;
        
        [_postInfoTableView reloadData];

    }
    else
    {
        if([sender isOn])
        {
            isDateSwitchOn = YES;
            
            
            NSLog(@"image created time:%@",[objImage valueForKey:@"imageCreatedTime"]);
            
            if([objImage valueForKey:@"imageCreatedTime"] != nil)
            {
                
                strDate = [Util dateFromInterval:[objImage valueForKey:@"imageCreatedTime"] inDateFormat:DATE_TIME_FORMAT];
            }
            
            NSLog(@"date:%@",strDate);
       
        }
        else
        {
            isDateSwitchOn = NO;

        }
        [_postInfoTableView reloadData];

    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RLogs(@"identifier:%@",segue.identifier);
    
    if ([segue.identifier isEqualToString:PostDetails])
    {
        PostDetailsViewController *objPostDetails = (PostDetailsViewController*)segue.destinationViewController;
        objPostDetails.selectedImgId = self.selectedImgId;
        objPostDetails.hotspotId = hotspotId;
        
    }
  
}

-(void)updatePodData
{
    NSManagedObject *objManagedObjPod = [self getPodDataFromDB];
    
    if([txtFld.text length]> 0 && txtFld.tag == 111)
    {
        [objManagedObjPod setValue:txtFld.text forKey:@"title"];
    }
    else
        [objManagedObjPod setValue:@"" forKey:@"title"];
    
    if(switchDate.on && switchDate.tag == 222)
    {
        [objManagedObjPod setValue:[NSDate date] forKey:@"pictureTakenOn"];
    }
//    else
//        [objManagedObjPod setValue:@"" forKey:@"pictureTakenOn"];

    
    if([txtFldCustomLocation.text length]> 0)
    {
        if(![txtFldCustomLocation.text isEqualToString:@"OR TYPE CUSTOM LOCATION"])

            [objManagedObjPod setValue:txtFldCustomLocation.text forKey:@"location"];
    }
    else if([lblLocation.text length]>0 )
     {
         [objManagedObjPod setValue:lblLocation.text forKey:@"location"];
     }
    else
        [objManagedObjPod setValue:@"" forKey:@"location"];
    
    if([strLatitude length]>0)
    {
        [objManagedObjPod setValue:strLatitude forKey:@"latitude"];
    }
    else
        [objManagedObjPod setValue:@"" forKey:@"latitude"];
    
    if([strLongitude length]>0)
    {
        [objManagedObjPod setValue:strLongitude forKey:@"longitude"];
    }
    else
        [objManagedObjPod setValue:@"" forKey:@"longitude"];
    
    //    if([_postDetailTxtView.text length] > 0)
    //    {
    //        [objManagedObjPod setValue:_postDetailTxtView.text forKey:@"descriptionPod"];
    //    }
    //    else
    
    [objManagedObjPod setValue:@"" forKey:@"descriptionPod"];
    
    
    NSError *error= nil;
    if (![context save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }

}

#pragma mark get data from DB

// getting pod data from database

-(NSManagedObject*)getPodDataFromDB
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Pod" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && pid == %@",self.selectedImgId, self.strPodId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count])
    {
        RLogs(@"Pod data:%@",[fetchedObjects objectAtIndex:0]);
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
    
}

-(NSManagedObject*)getImageDataFromDB
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ ",self.selectedImgId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count])
    {
        RLogs(@"Pod data:%@",[fetchedObjects objectAtIndex:0]);
        return [fetchedObjects objectAtIndex:0];
    }
    return nil;
}


#pragma mark - CLLocationManagerDelegate
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
            
            strLocation = [NSString stringWithFormat:@"%@,%@",placemark.locality,placemark.country];
            strLongitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
            strLatitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
         
            [_postInfoTableView reloadData];

        }
        else
        {
            RLogs(@"%@", error.debugDescription);
        }
    } ];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    RLogs(@"didFailWithError: %@", error);
    
    txtFld.text = @"";
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  //  [errorAlert show];
}


#pragma mark webservice calls

/* calling webservice for post */
-(void)sendRequestForPost
{
//    [self showLoader];
    
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc]init];
    
    NSArray *aryHoptspotSharedBO = APP_DELEGATE.aryHotspotSharedBO;

    if([[[aryHoptspotSharedBO objectAtIndex:0]valueForKey:@"strPodId"]length] == 0)
   // if([(NSString*)[objManagedObjPod valueForKey:@"pid"] length] == 0)
    {
        RLogs(@"No Pod Id");
        [self removeLoader];
        return;
    }
    
    
    [dictPost setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPost setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPost setValue:[[aryHoptspotSharedBO objectAtIndex:0]valueForKey:@"strPodId"] forKey:@"rpid_s"];
    
    if([txtFld.text length]> 0 && txtFld.tag == 111)
    {
        [dictPost setValue:txtFld.text forKey:@"postDescription"];
    }
    else
        [dictPost setValue:@"" forKey:@"postDescription"];

    
    NSMutableArray *aryHotspotsShared = [[NSMutableArray alloc]init];
    
    
    for(hotspotSharedBO *obj in aryHoptspotSharedBO)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        NSMutableArray *arySharedUids = [[NSMutableArray alloc]init];
        
        [dict setValue:obj.strHotspotId forKey:@"hotspotId"];
        
        for(NSString *strUid in obj.arrHotspotsSharedUIds)
        {
            [arySharedUids addObject:strUid];

        }
   //     NSString *strUID = [obj.arrHotspotsSharedUIds componentsJoinedByString:@","];

    //    [arySharedUids addObject:strUID];

        [dict setValue:arySharedUids forKey:@"sharedWith"];
        
        [aryHotspotsShared addObject:dict];
    }
    [dictPost setValue:aryHotspotsShared forKey:@"hotspotsShared"];
    
    if(isDateSwitchOn)
        [dictPost setValue:[NSNumber numberWithBool:YES] forKey:@"showTakenOn"];
    else
        [dictPost setValue:[NSNumber numberWithBool:NO] forKey:@"showTakenOn"];

    
    if(isLocationSwitchOn)
        [dictPost setValue:[NSNumber numberWithBool:YES] forKey:@"showTakenAt"];
    else
        [dictPost setValue:[NSNumber numberWithBool:NO] forKey:@"showTakenAt"];
    RLogs(@"dict:%@",dictPost);
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/batch/new",ServerURL] parameters:dictPost success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         RLogs(@"post response:%@",responseObject);
         [self removeLoader];
         if([[responseObject valueForKey:@"status"] isEqualToString:@"success"])
         {
             // need to save postId
             
             [self updatePodDatainDB];
             
             [self savePostDatainDB:[responseObject valueForKey:@"rpostid"]];
             
             [self saveSharedHotspotInfo:[responseObject valueForKey:@"rpostid"]];
             
             [Util setPostId:[responseObject valueForKey:@"rpostid"]];
             
             [self performSegueWithIdentifier:@"PostInfoToNetwork" sender:self];
             
         }
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post Error: %@", error);
              [self removeLoader];
              [self showNetworkErrorAlertWithTag:111111];
              
              
          }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    
    if(alertView.tag == 111111)
    {
        if(buttonIndex == 0)
        {
            [self sendRequestForPost];
            return;
        }
    }
    
}


/* get selected hotspot data from db */

-(NSArray*)getSelectedHotspotData
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Hotspot" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && podId == %@",self.selectedImgId, self.strPodId];
    
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

/* update pod data in DB */
-(void)updatePodDatainDB
{
    NSManagedObject *objManagedObjPod = [self getPodDataFromDB];
    
    [objManagedObjPod setValue:[NSNumber numberWithBool:NO] forKey:@"draft"];
    
    [objManagedObjPod setValue:[NSNumber numberWithBool:YES] forKey:@"published"];
    
   // [objManagedObjPod setValue: postId forKey:@"postId"];

    
    NSError *error= nil;
    if (![context save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
}

/* save post data in DB*/
-(void)savePostDatainDB :(NSString*)postId
{
    
    NSManagedObject *objPost= [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:context];
   
    NSArray *aryHotspotSharedBO = APP_DELEGATE.aryHotspotSharedBO;
    
    NSString *strPodId = [[aryHotspotSharedBO objectAtIndex:0] valueForKey:@"strPodId"];
    
    [objPost setValue:postId forKey:@"postId"];
    
    [objPost setValue:strPodId forKey:@"podId"];
    
    NSError *error= nil;
    if (![context save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
}

/* save hotspots shared data in DB*/
-(void)saveSharedHotspotInfo :(NSString*)postId
{
    
    for(hotspotSharedBO *obj in APP_DELEGATE.aryHotspotSharedBO)
    {
        for(NSString *strUid in  obj.arrHotspotsSharedUIds )
        {
            NSManagedObject *objHotspotShareInfo= [NSEntityDescription insertNewObjectForEntityForName:@"HotspotShareInfo" inManagedObjectContext:context];
            
            [objHotspotShareInfo setValue:obj.strHotspotId forKey:@"hotSpotId"];
            
            [objHotspotShareInfo setValue:postId forKey:@"postId"];
            
            [objHotspotShareInfo setValue:strUid forKey:@"userId"];
            
    //         [objHotspotShareInfo setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] forKey:@"createdAt"];
//     [objHotspotShareInfo setValue:[NSNumber numberWithDouble:[[NSDate date]timeIntervalSince1970] forKey:@"createdAt"]];
            
          //  long currentTime = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);

          //  [objHotspotShareInfo setValue:[NSNumber numberWithLong:currentTime] forKey:@"createdAt"];
            
          //  [objHotspotShareInfo setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970] * 1000] forKey:@"createdAt"];
            
            [objHotspotShareInfo setValue:[NSNumber numberWithLongLong:(long long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970] * 1000)] forKey:@"createdAt"];

            
            NSError *error= nil;
            if (![context save:&error])
            {
                RLogs(@"Problem saving: %@", [error localizedDescription]);
            }
            
        }
     }
    
    [APP_DELEGATE.aryHotspotSharedBO removeAllObjects];
}

-(void)fetchCitiesFromGoogleAPI:(NSString*)strInfo
{
    
    // NSData *data =
    
    // NSString *strInput = [@"input" UTF8String];
    
    [arrLocations removeAllObjects];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@%@?key=%@&components=country:in&types=(cities)&input=%@",PLACES_API_BASE, TYPE_AUTOCOMPLETE, OUT_JSON, GOOGLE_PLACES_API_KEY, strInfo];
    
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *strResponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSError *error;
        
        NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if(!error)
        {
            NSArray *arrLoc = [dictResponse valueForKey:@"predictions"];
            
            for(NSDictionary *dictLoc in arrLoc)
            {
                if(arrLocations == nil)
                    arrLocations = [[NSMutableArray alloc] init];
                [arrLocations addObject:[dictLoc valueForKey:@"description"]];
            }
            
            if([arrLocations count])
            {
                [tblLocationsList reloadData];
                tblLocationsList.hidden = NO;
            }
            else
            {
                tblLocationsList.hidden = YES;
            }
        }
        
        NSLog(@"Response - %@", strResponse);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if([arrLocations count])
        {
            [tblLocationsList reloadData];
            tblLocationsList.hidden = NO;
        }
        else
        {
            tblLocationsList.hidden = YES;
        }

    }];
    [operation start]
    ;
    
}

-(void)callUpdatePodService
{
        [self showLoader];
    NSMutableDictionary *dict;// = [[NSMutableDictionary alloc]init];

    NSMutableDictionary *dictPod;// = [[NSMutableDictionary alloc]init];
    
        dict = [self.dictPod mutableCopy];
        dictPod = [self.dictPod valueForKey:@"pod"];

    if([txtFldCustomLocation.text length] >0)
    {
        [dictPod setValue:txtFldCustomLocation.text forKey:@"location"];
    
        NSMutableDictionary *dictCoordinates = [[NSMutableDictionary alloc]init];

        [dictCoordinates setValue:@"" forKey:@"lat"];
        [dictCoordinates setValue:@"" forKey:@"lon"];
        
        [dictPod setValue:dictCoordinates forKey:@"locationCoordinates"];

    }
    else
    {
        [dictPod setValue:strLocation forKey:@"location"];
        
        NSMutableDictionary *dictCoordinates = [[NSMutableDictionary alloc]init];
        
        [dictCoordinates setValue:strLatitude forKey:@"lat"];
        [dictCoordinates setValue:strLongitude forKey:@"lon"];
        
        [dictPod setValue:dictCoordinates forKey:@"locationCoordinates"];
    }
    
    NSMutableDictionary *dictImage = [dictPod valueForKey:@"podImage"];

    NSManagedObject *objImage = [self getImageDataFromDB];
    
    [dictImage setValue:[objImage valueForKey:@"imageCreatedTime"] forKey:@"takenAt"];
    
    [dictPod setValue:dictImage forKey:@"podImage"];
    
    NSLog(@"final dict:%@",dictPod);

    [dict setValue:dictPod forKey:@"pod"];
    
    NSLog(@"dict:%@",dict);
    
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/pods/update",ServerURL] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSLog(@"pod update response:%@",responseObject);
         
         
         if([[responseObject valueForKey:@"status"] isEqualToString:@"success"])
         {
            
             [self sendRequestForPost];

         }
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"new pod Error: %@", error);
        
              
          }];
    

         
}

@end
