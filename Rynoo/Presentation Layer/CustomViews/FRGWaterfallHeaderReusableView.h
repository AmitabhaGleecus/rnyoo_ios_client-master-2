//
//  FRGHeaderReusableView.h
//  WaterfallCollectionView
//
//  Created by Rnyoo on 25/11/14.
//  Copyright (c) 2014 RNyoo All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRGWaterfallHeaderReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *cellImg;

@end
