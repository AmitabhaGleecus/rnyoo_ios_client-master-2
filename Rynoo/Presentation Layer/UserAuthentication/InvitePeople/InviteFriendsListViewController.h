//
//  InviteFriendsListViewController.h
//  Rynoo
//
//  Created by Rnyoo on 13/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

#import "BaseViewController.h"

@interface InviteFriendsListViewController : BaseViewController
{
    NSMutableArray *contactsArray;
    
}
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topTableConstraint;

@property (weak, nonatomic) IBOutlet UITableView *tblFriendsList;
@property (assign, nonatomic) BOOL isGmailContacts;
- (IBAction)sendInvitesClicked:(id)sender;
-(void)setGmailContactsWithArray:(NSMutableArray *)array;
@end
