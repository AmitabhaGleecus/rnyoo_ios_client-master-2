//
//  ViewController.h
//  Rynoo
//
//  Created by Rnyoo on 07/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BaseViewController.h"
#import "UIPopoverListView.h"


@interface PhoneNumberViewController1 : BaseViewController<UIPopoverListViewDataSource,UIPopoverListViewDelegate>
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSMutableArray *countryNamesArr;
    UIPopoverListView *poplistview;
    NSMutableDictionary *dictLogin;

}



@property (strong, nonatomic)  UITextField *txt_Email;
@property (strong, nonatomic)  UITextField *txt_CountryField;
@property (strong, nonatomic)  UITextField *txt_PhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivatePolicy;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblTopConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tblUserDetails;


- (IBAction)btn_SendVerificationCode:(id)sender;

-(void)privacyPolicy:(UIGestureRecognizer*)sender;

-(void)showCountries;

-(void)handleOrientaionForView:(UIPopoverListView*)tempView withOrientation:(UIInterfaceOrientation)orientation;

-(void)handleOrientaionForView:(UIPopoverListView*)tempView;



@end

