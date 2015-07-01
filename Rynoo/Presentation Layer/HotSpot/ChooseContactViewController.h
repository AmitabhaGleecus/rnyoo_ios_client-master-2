//
//  ChooseContactViewController.h
//  Rnyoo
//
//  Created by Rnyoo on 03/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PostInfoViewController.h"
#import "hotspotSharedBO.h"


@interface ChooseContactViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
{
    BOOL isSelectAllButtonSelected;
    UIButton *selectButton;
    UIButton *privateButton;
    UILabel  *selectAllLbl;
    UILabel  *rnyooNetworkLbl;
    UILabel *privateLbl;
    BOOL checkBtnSelected;
}
@property (strong, nonatomic) IBOutlet UITableView *chooseContactsTableview;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;

@property(nonatomic,retain)NSManagedObjectContext *context;
@property(nonatomic,retain)NSString *selectedImgId;
@property(nonatomic,retain)NSString *hotspotId;

@property(nonatomic,retain) hotspotSharedBO *objHotspotSharedBO;

- (IBAction)DoneBtnPressed:(id)sender;

@end
