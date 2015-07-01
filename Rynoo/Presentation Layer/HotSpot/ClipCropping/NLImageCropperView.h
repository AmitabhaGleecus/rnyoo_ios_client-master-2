//
//  NLImageCropperView.h
//  NLImageCropper
//
//  Copyright (c) 2014 Rnyoo. All rights reserved.

#import <UIKit/UIKit.h>
#import "NLCropViewLayer.h"
#import "Constants.h"

#define IMAGE_BOUNDRY_SPACE 0
enum rectPoint1 { LeftTop1 = 0, RightTop1 = 1, LeftBottom1 = 2, RightBottom1 = 3, MoveCenter1 = 4, NoPoint1 = 1};
@interface NLImageCropperView : UIView
{
    UIImageView* _imageView;
    UIImage* _image;
    NLCropViewLayer* _cropView;
    enum rectPoint1 _movePoint;
    CGRect _cropRect;
    CGRect _translatedCropRect;
    CGPoint _lastMovePoint;
    CGFloat _scalingFactor;
}
- (void)setCropRegionRect:(CGRect)cropRect;
- (void) setImage:(UIImage*)image;
- (void) setFrame:(CGRect)frame;
- (void) reLayoutView;
- (UIImage *)getCroppedImage;
@end
