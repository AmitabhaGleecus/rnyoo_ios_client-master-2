//
//  NLCropViewLayer.h
//  NLImageCropper
//
//  Copyright (c) 2014 Rnyoo. All rights reserved.


#import <UIKit/UIKit.h>
#import "Constants.h"
#define IMAGE_BOUNDRY_SPACE 0
enum rectPoint { LeftTop = 0, RightTop = 1, LeftBottom = 2, RightBottom = 3, MoveCenter = 4, NoPoint = 1};
@interface NLCropViewLayer : UIButton
{
    CGRect _cropRect;
    UIImageView* leftTopCorner;
    UIImageView* leftBottomCorner;
    UIImageView* rightTopCorner;
    UIImageView* rightBottomCorner;
    
    UIView *leftConnector, *rightConnector, *topConnector, *bottomConnector;
    
    enum rectPoint _movePoint;
    CGPoint _lastMovePoint, lastCentrePoint;
    CGFloat _scalingFactor;
    
    CGPoint dafaultPoint;
    
    CGSize minSize;
}

@property(nonatomic, assign) float addedInZoomScale;

- (void)setCropRegionRect:(CGRect)cropRect;
- (void)updateCornerFrames;

- (void)setDefaultCenterPoint:(CGPoint)point;
- (CGPoint)getDefaultCenterPoint;
@end
