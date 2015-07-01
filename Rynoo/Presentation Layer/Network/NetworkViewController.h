//
//  NetworkViewController.h
//  Rnyoo
//
//  Created by Rnyoo on 19/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"
#import "ImageOccupyView.h"
#import "NetworkView.h"


@interface NetworkViewController : BaseViewController<UIScrollViewDelegate, NetworkViewDelegate>
{
    
    ImageOccupyView *imageExactSubView;
    CGSize aspectFitSize, preImageViewSize;
    
    NSMutableArray *arrPostsByMe, *arrPostsToMe, *arrPosts;
    BOOL isFiltering;
    
    NetworkView *currentView, *leftView, *rightView;
    UITapGestureRecognizer *tblTapGesture;
    
    int filterIndex;
    
    int CurrentPageNumber;
    
    int unknownCreatedDatePosts;
    CGRect unrotatedFrame;
    UIRefreshControl *refreshControl;
    BOOL isShowloader;
    
    BOOL isRefreshRequestProcessing;

}

@property (weak, nonatomic) IBOutlet UIView *btmView;
@property (weak, nonatomic) IBOutlet UITextField *txtFldComment;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tblTopConstraint;

@property(nonatomic,retain)NSManagedObjectContext *context;
@property(nonatomic,retain)NetworkView *networkVwObj;

@property (strong, nonatomic) IBOutlet UITableView *tblPosts;

@property (nonatomic, assign) CGPoint lastContentOffset;

- (IBAction)btnSendClicked:(id)sender;



@end
