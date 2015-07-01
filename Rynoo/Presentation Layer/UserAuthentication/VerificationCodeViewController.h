//
//  VerificationCodeViewController.h
//  Rynoo
//
//  Created by Rnyoo on 07/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

#import "WelcomeViewController.h"


@interface VerificationCodeViewController : BaseViewController
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
}
@property (weak, nonatomic) IBOutlet UITextField *txtFldVerificationCode;
@property(nonatomic,retain)NSManagedObjectContext *context;

- (IBAction)resendVerificationCode:(id)sender;

- (IBAction)btn_SendVerificationCode:(id)sender;

-(void)activateUser;


@end

