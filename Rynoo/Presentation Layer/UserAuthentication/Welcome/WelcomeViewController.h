//
//  WelcomeViewController.h
//  Rynoo
//
//  Created by Rnyoo on 10/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileImageView.h"
#import "BaseViewController.h"
#import "UIPopoverListView.h"


typedef enum {
    
    PhotoPickOptionUseCamera = 0,
    PhotoPickOptionUsePhotoGallery = 1,
    PhotoPickOptionCancel = 2
}PhotoPickOption;

@interface WelcomeViewController : BaseViewController<UIPopoverListViewDataSource,UIPopoverListViewDelegate,UIActionSheetDelegate>

{
    int selectedIndex;
    UIImagePickerController *imageProfile;
    UIView *photoOptionalView;
    PhotoPickOption pickedOption;
    UIPopoverListView *poplistview;
    
    UIImage *pickedImage;
    



}
@property (weak, nonatomic) IBOutlet ProfileImageView *imgViewProfile;
@property (weak, nonatomic) IBOutlet UIImageView *lblWelcome;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgProfileLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgProfileTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblWelcomeTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *imgBgView;
@property (weak, nonatomic) IBOutlet UITableView *tblInterestAndSkip;
- (IBAction)editBtnClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtFldUserName;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tblWidthConstrint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tblRightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *lblTextWelcome;

@property(nonatomic, retain) NSString *strWelcomeText;

-(void)uploadPhoto;


@end
