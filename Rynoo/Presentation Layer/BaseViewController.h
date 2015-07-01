//
//  BaseViewController.h
//  Rynoo
//
//  Created by Rnyoo on 10/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#import "AppDelegate.h"

#import "Util.h"

#import "BaseViewController.h"

#import "AFNetworking.h"

#import "Constants.h"


#import "SlideNavigationController.h"

typedef enum {
    FROM_NEWPOST = 0,
    FROM_PUBLISHER = 1,
    FROM_CONSUMER = 2
}FROM_SOURCE;



@interface BaseViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, SlideNavigationControllerDelegate>
{
    Util *objUtil;
    
    UIView *loaderView;
    UIAlertView *objAlertView;
    
    float portraitWidth, LandScapeWidth;
}

-(BOOL)connected;

-(void)showNoInternetMessage;
-(void)AttributeTitle:(NSString *)title withLength:(NSInteger)length;
-(void)setNavigationBarTitle:(NSString*)strTitle;

-(void)setLeftBarButtonOnNavigationBarAsBackButton;
-(void)setRightBarButtonOnNavigationBarwithText:(NSString*)strTitle;
-(void)setLefttBarButtonOnNavigationBarwithText:(NSString*)strTitle;
-(void)leftBarButtonTapped:(id)sender;
-(void)rightBarButtonTapped:(id)sender;
-(void)backBtnClicked;

-(void)showLoader;
-(void)removeLoader;
-(void)showTheAlert:(NSString*)strAlert;
-(void)showNetworkErrorAlertWithTag:(NSInteger)tag;

-(void)loginwithDict:(NSMutableDictionary*)dictLogin from: (NSString*)strScreen;

-(void)SuccesssfullyLoggedIn:(NSString*)strScreen;
-(UIImage *)imageFromPath:(NSString *)path;
-(void)showLoaderWithTitle:(NSString*)strTitle;


-(NSString*)getFilePathwithFileName:(NSString*)fileName inFolder:(NSString*)folderName;

@end
