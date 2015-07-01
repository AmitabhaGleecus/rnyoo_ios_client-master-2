//
//  AddBuddyViewController.h
//  Rnyoo
//
//  Created by Rnyoo on 20/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

@interface AddBuddyViewController : BaseViewController<UISearchBarDelegate>
{
    UITapGestureRecognizer *tblTapGesture;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSearchBarConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tblBuddies;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIButton *btnAddFriends;
@property(nonatomic,retain)NSManagedObjectContext *context;

- (IBAction)btnAddBuddiesClicked:(id)sender;

@end
