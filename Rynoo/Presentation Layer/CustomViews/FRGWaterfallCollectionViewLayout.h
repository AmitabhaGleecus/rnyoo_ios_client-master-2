//
//  FRGWaterfallCollectionViewLayout.h
//  WaterfallCollectionView
//
//  Created by Rnyoo on 25/11/14.
//  Copyright (c) 2014 Rnyoo All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRGWaterfallCollectionViewLayout;

@protocol FRGWaterfallCollectionViewDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(FRGWaterfallCollectionViewLayout *)collectionViewLayout
heightForHeaderAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface FRGWaterfallCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) IBOutlet id<FRGWaterfallCollectionViewDelegate> delegate;
@property (nonatomic) CGFloat itemWidth;

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) BOOL stickyHeader;

@end
