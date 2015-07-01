//
//  SavedHotspotsViewController.h
//  Rnyoo
//
//  Created by Rnyoo on 05/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HotSpotViewController.h"
#import "CustomIOS7AlertView.h"

@interface SavedHotspotsViewController : BaseViewController <UICollectionViewDataSource,UICollectionViewDelegate,CustomIOS7AlertViewDelegate>
{
    NSInteger deleteIndex;
    BOOL isShowingAlert;
}

@property(nonatomic,strong) NSString *viewTitle;
@property(nonatomic,retain)NSManagedObjectContext *context;
@property (strong, nonatomic) IBOutlet UICollectionView *hotspotCollectionView;

@property (strong, nonatomic) IBOutlet UIButton *btnVaultSync;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topBarConstraint;

@end
