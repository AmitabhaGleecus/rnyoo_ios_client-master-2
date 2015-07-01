//
//  InterestsViewController.m
//  Rynoo
//
//  Created by Rnyoo on 13/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "InterestsViewController.h"

#import "UIImageView+AFNetworking.h"


static NSString* const WaterfallCellIdentifier = @"WaterfallCell";
static NSString* const WaterfallHeaderIdentifier = @"WaterfallHeader";

@interface InterestsViewController ()<UICollectionViewDelegate>
{
    NSMutableArray *aryIntrests;
    NSMutableArray *arySelectedIntrests;

}
@property (nonatomic, strong) NSMutableArray *cellHeights;

@end

@implementation InterestsViewController
@synthesize context;

/* Update Constraints */

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if(APP_DELEGATE.isPortrait)
    {
        self.collectionViewConstraint.constant = 64.0;
    }
    else
    {
        self.collectionViewConstraint.constant = 52.0;

    }
    
}

# pragma mark view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    aryIntrests = [[NSMutableArray alloc] init];
    arySelectedIntrests = [[NSMutableArray alloc]init];
    if([self connected])
    {
        [self getInterests];

    }
    else
    {
        [self showNoInternetMessage];
        return;
    }
//    self.cv.delegate = self;
//    self.cv.allowsMultipleSelection = YES;
//    
//    FRGWaterfallCollectionViewLayout *cvLayout = [[FRGWaterfallCollectionViewLayout alloc] init];
//    cvLayout.delegate = self;
//    cvLayout.itemWidth = 160.0f;
//    cvLayout.topInset = 10.0f;
//    cvLayout.bottomInset = 25.0f;
//    cvLayout.stickyHeader = YES;
//    
//    
//    
//    [self.cv setCollectionViewLayout:cvLayout];
//    [self.cv reloadData];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setNavigationBarTitle:@"Interests"];
    
    [self setRightBarButtonOnNavigationBarwithText:@"Skip"];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateViewConstraints];
    [[self.cv collectionViewLayout] invalidateLayout];
}

/* Getting Interests from server */

-(void)getInterests
{
    [self showLoader];
    
    AFHTTPRequestOperationManager *manager = [Util getAppOperationRequestManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/interests",ServerURL] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         [self removeLoader];
         NSMutableArray *tempArr;// = [[NSMutableArray alloc] init];
         
         tempArr = [responseObject objectForKey:@"interests"];
         
         for(NSDictionary *dict in tempArr)
         {
             NSMutableDictionary *mailDict = [NSMutableDictionary dictionaryWithDictionary:dict];
             [mailDict setValue:@"NO" forKey:@"isSelected"];
             [aryIntrests addObject:mailDict];
             
         }
         
         [self saveInterests];

         [self.cv reloadData];
         
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             RLogs(@"Error: %@", error);
             [self removeLoader];

             [self showNetworkErrorAlertWithTag:111111];

         }];
    
}

#pragma mark Alert View delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    
    if(alertView.tag == 111111)
    {
        if(buttonIndex == 0)
        {
            [self getInterests];
            return;
        }
    }
    else if(alertView.tag == 222222)
    {
        if(buttonIndex == 0)
        {
            [self UpdateUserwithSelectedInterests];
            return;
        }
    }
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{

    return [aryIntrests count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    

    FRGWaterfallCollectionViewCell *waterfallCell = [collectionView dequeueReusableCellWithReuseIdentifier:WaterfallCellIdentifier forIndexPath:indexPath];
    NSDictionary *dict = [aryIntrests objectAtIndex:indexPath.row];
    waterfallCell.interestTitle.text = [dict objectForKey:kIntrestName];
    waterfallCell.interestImg.image = nil;
    [waterfallCell.interestImg setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"imgUrl"]]];
    
    
    if ([[[aryIntrests objectAtIndex:indexPath.row] valueForKey:@"isSelected"] isEqualToString:@"YES"])
    {
        waterfallCell.interestCheckedImg.hidden = NO;
    }else
    {
        waterfallCell.interestCheckedImg.hidden = YES;

    }
    
    return waterfallCell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    if ([[[aryIntrests objectAtIndex:indexPath.row] valueForKey:@"isSelected"] isEqualToString:@"YES"])
    {
        [[aryIntrests objectAtIndex:indexPath.row] setValue:@"NO" forKey:@"isSelected"];
        NSString *intrest = [[aryIntrests objectAtIndex:indexPath.row] valueForKey:kIntrestName];
        [arySelectedIntrests removeObjectAtIndex:[arySelectedIntrests indexOfObject:intrest]];
        
    }else
    {
        [[aryIntrests objectAtIndex:indexPath.row] setValue:@"YES" forKey:@"isSelected"];
        [arySelectedIntrests addObject: [[aryIntrests objectAtIndex:indexPath.row]valueForKey:kIntrestName]];
    }
    
    [self.cv reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];

}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[[aryIntrests objectAtIndex:indexPath.row] valueForKey:@"isSelected"] isEqualToString:@"YES"])
    {
        [[aryIntrests objectAtIndex:indexPath.row] setValue:@"NO" forKey:@"isSelected"];
    }else
    {
        
        [[aryIntrests objectAtIndex:indexPath.row] setValue:@"YES" forKey:@"isSelected"];
    }
    [self.cv reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];

    
}
//- (CGFloat)collectionView:(UICollectionView *)collectionView
//                   layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout
// heightForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    return 100;
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView
//                   layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout
//heightForHeaderAtIndexPath:(NSIndexPath *)indexPath {
//    return 0;
//}

//- (NSMutableArray *)cellHeights
//{
//    if (!_cellHeights)
//    {
//        _cellHeights = [NSMutableArray arrayWithCapacity:900];
//        for (NSInteger i = 0; i < 900; i++) {
//            _cellHeights[i] = @(arc4random()%100*2+100);
//        }
//    }
//    return _cellHeights;
//}

#pragma mark Collection view layout things
// Layout: Set cell size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RLogs(@"SETTING SIZE FOR ITEM AT INDEX %d", indexPath.row);
    CGSize mElementSize = CGSizeMake(155, 100);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(0,0,0,0);  // top, left, bottom, right
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/* Navigate to Invite Friends screen*/

-(void)rightBarButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"InviteFriends" sender:self];
}

/* calling Update user webservice on next button click */

- (IBAction)btnNextClicked:(id)sender
{
    RLogs(@"%@",arySelectedIntrests);
    if([arySelectedIntrests count]== 0)
    {
        [self showTheAlert:@"Please select Interest"];
    }
    else
    {
        if([self connected])
        {
            [self.nextBtn setBackgroundColor:[UIColor whiteColor]];
            [self.nextBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [self UpdateUserwithSelectedInterests];
        }
        else
        {
            [self showNoInternetMessage];
            return;
        }
    }
   

}

/*  Update user with selected Interests */

-(void)UpdateUserwithSelectedInterests
{
    [self showLoader];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    NSMutableDictionary *dictUpdateUser = [[NSMutableDictionary alloc]init];
    [dictUpdateUser setValue:[Util getNewUserID] forKey:@"uid"];
    [dictUpdateUser setValue:[Util getSessionId] forKey:@"sid"];
    [dictUpdateUser setValue:@"preferredChannels" forKey:@"field"];
    [dictUpdateUser setValue:arySelectedIntrests forKey:@"preferredChannels"];
    
    [manager POST:[NSString stringWithFormat:@"%@/users/update",ServerURL] parameters:dictUpdateUser success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         [self removeLoader];
         
         RLogs(@"UpdateUser response:%@",responseObject);
         if([[responseObject valueForKey:@"status"] isEqualToString:@"success"])
         {
       //      [self showTheAlert:@"Updated User Successfully"];
             [Util setNewUserID:[responseObject valueForKey:@"uid"]];
             
             [APP_DELEGATE setMenuScreenAsRootViewController];
         }
         
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              [self removeLoader];
              
              RLogs(@"UpdateUser Error: %@", error.description);
              
              [self showNetworkErrorAlertWithTag:222222];
              
          }];
}


# pragma mark Save Interests to DB
/* save Interests to db */
-(void)saveInterests
{
    context = [APP_DELEGATE managedObjectContext];
    
    
    for (NSDictionary *dict in aryIntrests)
    {
        NSManagedObject *objInterests= [NSEntityDescription insertNewObjectForEntityForName:@"Interests" inManagedObjectContext:context];
        [objInterests setValue:[dict objectForKey:kIntrestName] forKey:kIntrestName];
        [objInterests setValue:[dict objectForKey:@"imgUrl"] forKey:@"imgUrl"];
        [objInterests setValue:[dict objectForKey:@"simgUrl"] forKey:@"simgUrl"];
    }
    
    NSError *error= nil;
    if (![context save:&error])
    {
        RLogs(@"Problem saving: %@", [error localizedDescription]);
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
