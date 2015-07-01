//
//  PostDetailsViewController.h
//  Rnyoo
//
//  Created by Rnyoo on 04/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "BaseViewController.h"

@interface PostDetailsViewController : BaseViewController<UITextFieldDelegate,CLLocationManagerDelegate,UITextViewDelegate>
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
     UITapGestureRecognizer *tblTapGesture;
}

- (IBAction)postNow:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *postDetailTxtView;
@property (strong, nonatomic) IBOutlet UIScrollView *postDetailScrollView;
@property (strong, nonatomic) IBOutlet UIView *pictureView;
@property (strong, nonatomic) IBOutlet UISwitch *switchView;
@property (strong, nonatomic) IBOutlet UILabel *locationLbl;
@property (strong, nonatomic) IBOutlet UITextField *cusomLocationTxtfld;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;

@property(nonatomic,retain)NSManagedObjectContext *context;

@property(nonatomic,retain)NSString *selectedImgId;
@property(nonatomic,retain)NSString *hotspotId;


- (IBAction)switchAction:(id)sender;

@end
