//
//  FRGWaterfallDecorationReusableView.m
//  WaterfallCollectionView
//
//  Created by Rnyoo on 25/11/14.
//  Copyright (c) 2014 RNyoo All rights reserved.
//

#import "FRGWaterfallDecorationReusableView.h"

@implementation FRGWaterfallDecorationReusableView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"decorationImage"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
    }
    return self;
}

+ (CGSize)defaultSize {
    return [UIImage imageNamed:@"decorationImage"].size;
}

@end
