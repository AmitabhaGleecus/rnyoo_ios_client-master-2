//
//  PostDetailsViewController.m
//  Rnyoo
//
//  Created by Rnyoo on 04/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "PostDetailsViewController.h"
#import "PostDetailCell.h"
#import <CoreText/CoreText.h>

@interface PostDetailsViewController ()
{
    NSString *strLongitude;
    NSString *strLatitude;
}
@end

@implementation PostDetailsViewController
@synthesize context;
@synthesize selectedImgId,hotspotId;

# pragma mark view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    context = [APP_DELEGATE managedObjectContext];

    
    // Making underlined text for textview content
    NSMutableAttributedString *attributedString = [self.postDetailTxtView.attributedText mutableCopy];
    
    int valueToSet = kCTUnderlineStyleSingle;
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:valueToSet] range:NSMakeRange(0, self.postDetailTxtView.text.length)];
  
    self.postDetailTxtView.attributedText = attributedString;
  
    _postDetailTxtView.delegate = self;
    _postDetailTxtView.userInteractionEnabled = YES;
    _postDetailTxtView.editable = YES;
    
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    // Do any additional setup after loading the view.
    
    tblTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToResignKeyBoard)];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self setNavigationBarTitle:@"Information"];
    [self setLeftBarButtonOnNavigationBarAsBackButton];
}

#pragma mark KeyBoard Notifications
-(void)keyboardDidShow:(NSNotification*)notification
{
    [_postDetailScrollView addGestureRecognizer:tblTapGesture];
}

-(void)keyboardFrameChanged:(NSNotification*)notification
{
    
}

-(void)keyboardWillBeHidden:(NSNotification*)notification
{
    [_postDetailScrollView removeGestureRecognizer:tblTapGesture];
}

-(void)tapToResignKeyBoard
{
    [_cusomLocationTxtfld resignFirstResponder];
    [_postDetailTxtView resignFirstResponder];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //To hide the keyboard when user touches out side the keyboard area.
    
    [_cusomLocationTxtfld resignFirstResponder];
    [_postDetailTxtView resignFirstResponder];
}

/*update constraints */
-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (APP_DELEGATE.isPortrait) {
        self.tableTopConstraint.constant = 64;
    }
    else{
        self.tableTopConstraint.constant = 44;
    }
}

# pragma mark textfield delegate methods

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.cusomLocationTxtfld.text = @"";
    if (APP_DELEGATE.isPortrait) {
        [self.postDetailScrollView setContentSize:CGSizeMake(self.postDetailScrollView.frame.size.width, self.postDetailScrollView.frame.size.height)];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}


#pragma mark UITextView Delegate Methods
//These are the textView delegate methods of textview placed for description of hotspot.

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // To dimiss keyboard with return key
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    
   
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    RLogs(@"didFailWithError: %@", error);
    
     _locationLbl.text = @"";
 //   UIAlertView *errorAlert = [[UIAlertView alloc]
  //                             initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  //  [errorAlert show];
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
            
            _locationLbl.text = [NSString stringWithFormat:@"%@,%@",placemark.locality,placemark.country];
            strLongitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
            strLatitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];

        }
        else
        {
            RLogs(@"%@", error.debugDescription);
        }
    } ];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

/* postnow button action*/
- (IBAction)postNow:(id)sender
{
    [self updatePodDatawithLocation];
    if([self connected])
    {
        [self sendRequestForPost];
    }
    else
    {
        [self showNoInternetMessage];
    }
    
}


#pragma mark get data from DB

// getting pod data from database
-(NSManagedObject*)getPodDataFromDB
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Pod" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@",self.selectedImgId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    RLogs(@"Pod data:%@",[fetchedObjects objectAtIndex:0]);
    
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    return [fetchedObjects objectAtIndex:0];
    
}

/* get selected hotspot data from db */
-(NSArray*)getSelectedHotspotData
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Hotspot" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ ",self.selectedImgId];
    
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

/* update pod data with location and description */
-(void)updatePodDatawithLocation
{
    NSManagedObject *objManagedObjPod = [self getPodDataFromDB];
    
    if([_locationLbl.text length]>0)
    {
        [objManagedObjPod setValue:_locationLbl.text forKey:@"location"];
    }
    else if([_cusomLocationTxtfld.text length]> 0)
    {
        [objManagedObjPod setValue:_cusomLocationTxtfld.text forKey:@"location"];
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

    if([_postDetailTxtView.text length] > 0)
    {
        [objManagedObjPod setValue:_postDetailTxtView.text forKey:@"descriptionPod"];
    }
    else
        
        [objManagedObjPod setValue:@"" forKey:@"descriptionPod"];

    
    NSError *error= nil;
    if (![context save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }

    

}

-(void)updatePodDatainDB
{
    NSManagedObject *objManagedObjPod = [self getPodDataFromDB];
    
    [objManagedObjPod setValue:[NSNumber numberWithBool:NO] forKey:@"draft"];
    
    [objManagedObjPod setValue:[NSNumber numberWithBool:YES] forKey:@"published"];

    NSError *error= nil;
    if (![context save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }
    
}

/* switch action */
- (IBAction)switchAction:(id)sender
{
    if(_switchView.on)
    {
        [locationManager startUpdatingLocation];

    }
    else
        [locationManager stopUpdatingLocation];

}

#pragma mark webservice calls

/* calling webservice for post */
-(void)sendRequestForPost
{
    [self showLoader];
    
    NSMutableDictionary *dictPost = [[NSMutableDictionary alloc]init];

    NSManagedObject *objManagedObjPod = [self getPodDataFromDB];

    
    [dictPost setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPost setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPost setValue:[objManagedObjPod valueForKey:@"pid"] forKey:@"rpid_s"];
    
    NSArray *arrhotSpots = [self getSelectedHotspotData];
    
    NSMutableArray *aryHotspotsShared = [[NSMutableArray alloc]init];

    for(NSManagedObject *obj in arrhotSpots)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        NSMutableArray *arySharedUids = [[NSMutableArray alloc]init];

        [dict setValue:[obj valueForKey:@"hId"] forKey:@"hotspotId"];
        
        [arySharedUids addObject:[obj valueForKey:@"friendsList"]];
        
        
        [dict setValue:arySharedUids forKey:@"sharedWith"];
        
        [aryHotspotsShared addObject:dict];
    }
    [dictPost setValue:aryHotspotsShared forKey:@"hotspotsShared"];
    
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
             [self performSegueWithIdentifier:@"PostDetailsToNetwork" sender:self];

             
         }
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              RLogs(@"post Error: %@", error);
              [self removeLoader];
              [self showNetworkErrorAlertWithTag:111111];
              
          }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


@end
