//
//  FRGWaterfallCollectionViewCell.h
//  WaterfallCollectionView
//
//  Created by Rnyoo on 25/11/14.
//  Copyright (c) 2014 Rnyoo All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FRGWaterfallCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *interestTitle;
@property (weak, nonatomic) IBOutlet UIImageView *interestImg;
@property (weak, nonatomic) IBOutlet UIImageView *interestCheckedImg;

@end
