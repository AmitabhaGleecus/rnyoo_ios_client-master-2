//
//  MenuViewController.h
//  SlideMenu
//
//  Created by Rnyoo on 12/11/14.
//  Copyright (c) 2014 Rnyoo All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SlideNavigationController.h"

#import "NetworkViewController.h"

#import "CommunityViewController.h"

#import "MyCornerViewController.h"

#import "SettingsViewController.h"

#import "InviteViewController.h"

#import "HotSpotViewController.h"

#import "ProfileImageView.h"

#import "AddBuddyViewController.h"

#import "Constants.h"
#import <CoreLocation/CoreLocation.h>


@interface LeftMenuViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,CLLocationManagerDelegate>
{
    NSMutableArray *titles;
    NSMutableArray *titlesImages;
    NSMutableArray  *titles1;
    NSString *titleStr, *strImgName, *strWebpFilePath;
    CLGeocoder *geocoder;

}
-(void)navigateToHotSpotViewControlelr;

@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

@end
