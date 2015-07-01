//
//  NLImageCropperView.m
//  NLImageCropper
//
//  Copyright (c) 2014 Rnyoo. All rights reserved.


#import "NLImageCropperView.h"
#import <QuartzCore/QuartzCore.h>

#define MIN_IMG_SIZE 30
#define EDGE_THRESHOLD 10

@implementation NLImageCropperView

- (void)setCropRegionRect:(CGRect)cropRect
{
    RLogs(@"cropRect - %@", NSStringFromCGRect(cropRect));
    _cropRect = cropRect;
    _translatedCropRect =CGRectMake(cropRect.origin.x/_scalingFactor, cropRect.origin.y/_scalingFactor, cropRect.size.width/_scalingFactor, cropRect.size.height/_scalingFactor);
    [_cropView setCropRegionRect:_translatedCropRect];
}

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"Cropper view called");
    self = [super initWithFrame:frame];
    _image = nil;
    if (self) {
        // Initialization code
    }
    [self setBackgroundColor:[UIColor clearColor]];
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _cropView = [[NLCropViewLayer alloc] initWithFrame:_imageView.bounds];
    [_cropView setBackgroundColor:[UIColor clearColor]];

    [self setAutoresizesSubviews:YES];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    [self addSubview:_imageView];
    [self addSubview:_cropView];
    
    [self setCropRegionRect:CGRectMake(frame.size.width/2, frame.size.height/2, 300, 300)];
    _scalingFactor = 1.0;
    _movePoint = NoPoint1;
    _lastMovePoint = CGPointMake(0, 0);
    
#ifdef ARC
    [_imageView release];
    [_cropView release];
#endif
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_image != nil) {
        [self reLayoutView];
    }
    RLogs(@"Set Frame Called");
}
- (void) setImage:(UIImage*)image
{
    _image = image;

    [self reLayoutView];
    
    [_imageView setImage:_image];
    
    if(_image == nil)
    {
        RLogs(@"Nill");
    }
    
    RLogs(@"Sertting Image");
}

- (void) reLayoutView
{
    float imgWidth = _image.size.width;
    float imgHeight = _image.size.height;
    float viewWidth = self.bounds.size.width - 2*IMAGE_BOUNDRY_SPACE;
    float viewHeight = self.bounds.size.height - 2*IMAGE_BOUNDRY_SPACE;
    
    float widthRatio = imgWidth / viewWidth;
    float heightRatio = imgHeight / viewHeight;
    _scalingFactor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    _imageView.bounds = CGRectMake(0, 0, imgWidth / _scalingFactor, imgHeight/_scalingFactor);
    

    
    _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
   /* _imageView.layer.shadowColor = [UIColor clearColor].CGColor;
    _imageView.layer.shadowOffset = CGSizeMake(3, 3);
    _imageView.layer.shadowOpacity = 0.6;
    _imageView.layer.shadowRadius = 1.0;*/
    
    _imageView.backgroundColor = [UIColor clearColor];
    
    _cropView.bounds = _imageView.bounds;
    _cropView.frame = _imageView.frame;
    
    [self setCropRegionRect:_cropRect];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        RLogs(@"Touch Begins");
    [super touchesBegan:touches withEvent:event];

    CGPoint locationPoint = [[touches anyObject] locationInView:_imageView];
    if(locationPoint.x < 0 || locationPoint.y < 0 || locationPoint.x > _imageView.bounds.size.width || locationPoint.y > _imageView.bounds.size.height)
    {
        _movePoint = NoPoint1;
        return;
    }
    _lastMovePoint = locationPoint;
    
    if(((locationPoint.x - EDGE_THRESHOLD) <= _translatedCropRect.origin.x) &&
       ((locationPoint.x + EDGE_THRESHOLD) >= _translatedCropRect.origin.x))
    {
        if(((locationPoint.y - EDGE_THRESHOLD) <= _translatedCropRect.origin.y) &&
           ((locationPoint.y + EDGE_THRESHOLD) >= _translatedCropRect.origin.y))
            _movePoint = LeftTop1;
        else if ((locationPoint.y - EDGE_THRESHOLD) <= (_translatedCropRect.origin.y + _translatedCropRect.size.height) &&
                 (locationPoint.y + EDGE_THRESHOLD) >= (_translatedCropRect.origin.y + _translatedCropRect.size.height))
            _movePoint = LeftBottom1;
        else
            _movePoint = NoPoint1;
    }
    else if(((locationPoint.x - EDGE_THRESHOLD) <= (_translatedCropRect.origin.x + _translatedCropRect.size.width)) &&
            ((locationPoint.x + EDGE_THRESHOLD) >= (_translatedCropRect.origin.x + _translatedCropRect.size.width)))
    {
        if(((locationPoint.y - EDGE_THRESHOLD) <= _translatedCropRect.origin.y) &&
           ((locationPoint.y + EDGE_THRESHOLD) >= _translatedCropRect.origin.y))
            _movePoint = RightTop1;
        else if ((locationPoint.y - EDGE_THRESHOLD) <= (_translatedCropRect.origin.y + _translatedCropRect.size.height) &&
                 (locationPoint.y + EDGE_THRESHOLD) >= (_translatedCropRect.origin.y + _translatedCropRect.size.height))
            _movePoint = RightBottom1;
        else
            _movePoint = NoPoint1;
    }
    else if ((locationPoint.x > _translatedCropRect.origin.x) && (locationPoint.x < (_translatedCropRect.origin.x + _translatedCropRect.size.width)) &&
             (locationPoint.y > _translatedCropRect.origin.y) && (locationPoint.y < (_translatedCropRect.origin.y + _translatedCropRect.size.height)))
    {
        _movePoint = MoveCenter1;
    }
    else
        _movePoint = NoPoint1;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];

    CGPoint locationPoint = [[touches anyObject] locationInView:_imageView];

    RLogs(@"Location Point: (%f,%f)", locationPoint.x, locationPoint.y);
    
    if(locationPoint.x < 0 || locationPoint.y < 0 || locationPoint.x > _imageView.bounds.size.width || locationPoint.y > _imageView.bounds.size.height)
    {
        _movePoint = NoPoint1;
        return;
    }
    float x,y;
    switch (_movePoint) {
        case LeftTop1:
            if(((locationPoint.x + MIN_IMG_SIZE) >= (_translatedCropRect.origin.x + _translatedCropRect.size.width)) ||
               ((locationPoint.y + MIN_IMG_SIZE)>= (_translatedCropRect.origin.y + _translatedCropRect.size.height)))
                return;
            _translatedCropRect = CGRectMake(locationPoint.x, locationPoint.y,
                                   _translatedCropRect.size.width + (_translatedCropRect.origin.x - locationPoint.x),
                                   _translatedCropRect.size.height + (_translatedCropRect.origin.y - locationPoint.y));
            break;
        case LeftBottom1:
            if(((locationPoint.x + MIN_IMG_SIZE) >= (_cropRect.origin.x + _translatedCropRect.size.width)) ||
               ((locationPoint.y - _translatedCropRect.origin.y) <= MIN_IMG_SIZE))
                return;
            _translatedCropRect = CGRectMake(locationPoint.x, _translatedCropRect.origin.y,
                                   _translatedCropRect.size.width + (_translatedCropRect.origin.x - locationPoint.x),
                                   locationPoint.y - _translatedCropRect.origin.y);
            break;
        case RightTop1:
            if(((locationPoint.x - _translatedCropRect.origin.x) <= MIN_IMG_SIZE) ||
               ((locationPoint.y + MIN_IMG_SIZE)>= (_translatedCropRect.origin.y + _translatedCropRect.size.height)))
                return;
            _translatedCropRect = CGRectMake(_translatedCropRect.origin.x, locationPoint.y,
                                   locationPoint.x - _translatedCropRect.origin.x,
                                   _translatedCropRect.size.height + (_translatedCropRect.origin.y - locationPoint.y));
            break;
        case RightBottom1:
            if(((locationPoint.x - _translatedCropRect.origin.x) <= MIN_IMG_SIZE) ||
               ((locationPoint.y - _translatedCropRect.origin.y) <= MIN_IMG_SIZE))
                return;
            _translatedCropRect = CGRectMake(_translatedCropRect.origin.x, _translatedCropRect.origin.y,
                                   locationPoint.x - _translatedCropRect.origin.x,
                                   locationPoint.y - _translatedCropRect.origin.y);
            break;
        case MoveCenter1:

            x = _lastMovePoint.x - locationPoint.x;
            y = _lastMovePoint.y - locationPoint.y;
            if(((_translatedCropRect.origin.x-x) > 0) && ((_translatedCropRect.origin.x + _translatedCropRect.size.width - x) <
                                                          _cropView.bounds.size.width) &&
               ((_translatedCropRect.origin.y-y) > 0) && ((_translatedCropRect.origin.y + _translatedCropRect.size.height - y) < _cropView.bounds.size.height))
            {
                
                _translatedCropRect = CGRectMake(_translatedCropRect.origin.x - x, _translatedCropRect.origin.y - y, _translatedCropRect.size.width, _translatedCropRect.size.height);
            }
            _lastMovePoint = locationPoint;
            break;
        default: //NO Point
            return;
            break;
    }
    [_cropView setNeedsDisplay];
    _cropRect = CGRectMake(_translatedCropRect.origin.x*_scalingFactor, _translatedCropRect.origin.y*_scalingFactor, _translatedCropRect.size.width*_scalingFactor, _translatedCropRect.size.height*_scalingFactor);
    [self setCropRegionRect:_cropRect];
    
}

- (UIImage *)getCroppedImage {
    
    CGRect imageRect = CGRectMake(_cropRect.origin.x*_image.scale,
                      _cropRect.origin.y*_image.scale,
                      _cropRect.size.width*_image.scale,
                      _cropRect.size.height*_image.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([_image CGImage], imageRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:_image.scale
                                    orientation:_image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

@end
