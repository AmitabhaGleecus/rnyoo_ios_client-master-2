//
//  ViewController.h
//  Rynoo
//
//  Created by Rnyoo on 07/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import "BaseViewController.h"


@interface ViewController : BaseViewController <GPPSignInDelegate>
{
    AFHTTPRequestOperation *retryOperation;
    NSString *screenName;
    NSMutableDictionary *dictLogin;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInLeftConstraitn;
@property (weak, nonatomic) IBOutlet UILabel *lblPostAndTerms;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *termsLblLeftConstraint;
@property (weak, nonatomic) IBOutlet GPPSignInButton *btn_GoogleLogin;
@property (weak, nonatomic) IBOutlet UIButton *fb_loginBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imgLoginBg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblBottomConstraint;
@property(nonatomic,retain)NSManagedObjectContext *context;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint;

- (IBAction)btn_googleAction:(id)sender;
-(IBAction)btn_facebookAction:(id)sender;
-(void)fbloginClicked;


-(void)btn_TermsOfUse:(id)sender;
- (NSString *)createImagePath:(NSString *)imageName;

@end

