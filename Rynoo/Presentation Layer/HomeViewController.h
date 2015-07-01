//
//  HomeViewController.h
//  Rnyoo
//
//  Created by Rnyoo on 17/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HotSpotViewController.h"
#import "SlideNavigationController.h"
#import <CoreLocation/CoreLocation.h>

typedef enum {
    MenuOptionMyCorner = 0,
    MenuOptionCommunity = 1,
    MenuOptionNetwork =2
}MenuOption;

@interface HomeViewController : BaseViewController<CLLocationManagerDelegate>
{
    IBOutlet UIImageView *backgroundImage;
    
    MenuOption clickedOption;
    
    SlideNavigationController *navigationController;
    
    NSString *strWebpFilePath, *strImgName;
    CLGeocoder *geocoder;


}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableLeftConstraitn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoLeftConstraitn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblRightConstraint;

-(void)setProperMenuView;
-(void)navigateToHotSpotViewControlelr;


@end
