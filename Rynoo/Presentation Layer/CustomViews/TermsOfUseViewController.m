//
//  TermsOfUseViewController.m
//  Rynoo
//
//  Created by Rnyoo on 14/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "TermsOfUseViewController.h"

@interface TermsOfUseViewController ()

@end

@implementation TermsOfUseViewController
@synthesize isFromLeftMenu;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _textViewTermsOfUse.clipsToBounds = NO;
    _textViewTermsOfUse.text = [NSString stringWithFormat:@"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. \n \n Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. \n \n Nam liber te conscient to factor tum poen legum odioque civiuda.Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. \n Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."];
    
    _textViewTermsOfUse.contentInset =  UIEdgeInsetsMake(-50.0, 0.0, 20.0, 0.0);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.headIndent = 20.0;
    paragraphStyle.firstLineHeadIndent = 20.0;
    paragraphStyle.tailIndent = -20.0;
    
    NSDictionary *attrsDictionary = @{NSFontAttributeName: [Util Font:FontTypeLight Size:13.0], NSParagraphStyleAttributeName: paragraphStyle};
    _textViewTermsOfUse.attributedText = [[NSAttributedString alloc] initWithString:_textViewTermsOfUse.text attributes:attrsDictionary];


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self setNavigationBarTitle:[Util getTermsOfUseTitle]];
    [self setNavigationBarTitle:self.titleStr];
    [self setLeftBarButtonOnNavigationBarAsBackButton];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self setNavigationBarTitle:self.titleStr];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendFeedbackAction:(id)sender {
}
@end
