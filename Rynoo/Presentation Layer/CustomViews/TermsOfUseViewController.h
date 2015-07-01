//
//  TermsOfUseViewController.h
//  Rynoo
//
//  Created by Rnyoo on 14/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

@interface TermsOfUseViewController : BaseViewController

@property(nonatomic, assign) BOOL isFromLeftMenu;

@property (weak, nonatomic) IBOutlet UITextView *textViewTermsOfUse;

@property(strong,nonatomic) NSString *titleStr;


@end
