//
//  FeedbackViewController.h
//  Rnyoo
//
//  Created by Logictree on 11/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface FeedbackViewController : BaseViewController<UITextFieldDelegate>

@property(nonatomic, assign) BOOL isFromLeftMenu;
@property(strong,nonatomic) NSString *titleStr;
@property (strong, nonatomic) IBOutlet UIButton *sendFeedbackBtn;
- (IBAction)sendFeedbackAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *feedbackTxtFld;

@end
