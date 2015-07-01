//
//  PostInfoViewController.h
//  Rnyoo
//
//  Created by Rnyoo on 04/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PostDetailsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "hotspotSharedBO.h"

@interface PostInfoViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>
{
    UITextField *txtFld;
    UISwitch *switchDate;
    UITapGestureRecognizer *tblTapGesture;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    UITextField *txtFldCustomLocation;
    
    UITableView *tblLocationsList;
    NSMutableArray *arrLocations;

}
- (IBAction)postNow:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *postInfoTableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;

@property(nonatomic,retain)NSString *selectedImgId, *strPodId;

@property(nonatomic,retain)NSManagedObjectContext *context;
@property(nonatomic,retain)NSString *hotspotId;

@property(nonatomic,retain)hotspotSharedBO *objHotSpotSharedBO;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tblBottomConstrait;
@property(nonatomic,retain)NSDictionary *dictPod;

@property(nonatomic, assign) BOOL isPublisherRePost,isPodCreated;

@end
