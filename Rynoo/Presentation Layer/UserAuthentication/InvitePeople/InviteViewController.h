//
//  InviteViewController.h
//  Rynoo
//
//  Created by Rnyoo on 13/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <GooglePlus/GooglePlus.h>


@interface InviteViewController : BaseViewController<GPPSignInDelegate>
- (IBAction)AddressBookInviteClicked:(id)sender;
- (IBAction)FBInviteClicked:(id)sender;
- (IBAction)GoogleInviteClicked:(id)sender;

@end
