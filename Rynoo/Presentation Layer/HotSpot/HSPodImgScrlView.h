//
//  HSPodImgScrlView.h
//  Rnyoo
//
//  Created by Rnyoo on 02/12/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"


@interface HSPodImgScrlView : UIScrollView

@property(nonatomic, assign) CGSize prevBoundsSize;
@property(nonatomic, assign)  CGPoint prevContentOffset;

@end
