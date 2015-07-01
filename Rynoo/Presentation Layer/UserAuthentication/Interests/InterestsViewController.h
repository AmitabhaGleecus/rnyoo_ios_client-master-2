//
//  InterestsViewController.h
//  Rynoo
//
//  Created by Rnyoo on 13/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRGWaterfallCollectionViewCell.h"
//#import "FRGWaterfallCollectionViewLayout.h"
#import "FRGWaterfallHeaderReusableView.h"
#import <QuartzCore/QuartzCore.h>
#import "BaseViewController.h"

@interface InterestsViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UICollectionView *cv;
@property(nonatomic,retain)NSManagedObjectContext *context;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewConstraint;
- (IBAction)btnNextClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *nextBtn;

@end
