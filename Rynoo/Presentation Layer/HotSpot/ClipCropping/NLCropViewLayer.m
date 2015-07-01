//
//  NLCropViewLayer.m
//  NLImageCropper
//
//  Copyright (c) 2014 Rnyoo. All rights reserved.

#import "NLCropViewLayer.h"
#import <QuartzCore/QuartzCore.h>

#define MIN_IMG_SIZE 50
#define EDGE_THRESHOLD 0
#define SEPARATORWIDTH 5
#define SEPARATOR_COLOR [UIColor colorWithRed:226.0/255.0 green:76.0/255.0 blue:66.0/255.0 alpha:1.0]
@implementation NLCropViewLayer
@synthesize addedInZoomScale;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _cropRect = CGRectMake(0, 0, 0, 0);
        minSize = CGSizeMake(80, 80);
    }
    leftTopCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"node.png"]];
    leftTopCorner.layer.shadowColor = [UIColor blackColor].CGColor;
    leftTopCorner.layer.shadowOffset = CGSizeMake(1, 1);
    leftTopCorner.layer.shadowOpacity = 0.6;
    leftTopCorner.layer.shadowRadius = 1.0;
    
    leftBottomCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"node.png"]];
    leftBottomCorner.layer.shadowColor = [UIColor blackColor].CGColor;
    leftBottomCorner.layer.shadowOffset = CGSizeMake(1, 1);
    leftBottomCorner.layer.shadowOpacity = 0.6;
    leftBottomCorner.layer.shadowRadius = 1.0;
    
    rightTopCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"node.png"]];
    rightTopCorner.layer.shadowColor = [UIColor blackColor].CGColor;
    rightTopCorner.layer.shadowOffset = CGSizeMake(1, 1);
    rightTopCorner.layer.shadowOpacity = 0.6;
    rightTopCorner.layer.shadowRadius = 1.0;
    
    rightBottomCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"node.png"]];
    rightBottomCorner.layer.shadowColor = [UIColor blackColor].CGColor;
    rightBottomCorner.layer.shadowOffset = CGSizeMake(1, 1);
    rightBottomCorner.layer.shadowOpacity = 0.6;
    rightBottomCorner.layer.shadowRadius = 1.0;
    
    
    
    [self addSubview:leftTopCorner];
    [self addSubview:leftBottomCorner];
    [self addSubview:rightTopCorner];
    [self addSubview:rightBottomCorner];
    
    float sideYpos = leftTopCorner.frame.origin.y + leftTopCorner.frame.size.height;
    
    leftConnector = [[UIView alloc] initWithFrame:CGRectMake(leftTopCorner.center.x - SEPARATORWIDTH/2 , sideYpos, SEPARATORWIDTH, leftBottomCorner.frame.origin.y - sideYpos)];
    [leftConnector setBackgroundColor:SEPARATOR_COLOR];
    [self addSubview:leftConnector];
    
    rightConnector = [[UIView alloc] initWithFrame:CGRectMake(rightTopCorner.center.x - SEPARATORWIDTH/2 , sideYpos, SEPARATORWIDTH, rightBottomCorner.frame.origin.y - sideYpos)];
    [rightConnector setBackgroundColor:SEPARATOR_COLOR];

    [self addSubview:rightConnector];
    
    float sideXpos = leftTopCorner.frame.origin.x + leftTopCorner.frame.size.width;
    topConnector = [[UIView alloc] initWithFrame:CGRectMake(sideXpos , leftTopCorner.center.y - SEPARATORWIDTH/2, rightTopCorner.frame.origin.x - sideXpos, SEPARATORWIDTH)];
    [topConnector setBackgroundColor:SEPARATOR_COLOR];

    [self addSubview:topConnector];
    
    bottomConnector = [[UIView alloc] initWithFrame:CGRectMake(sideXpos , leftBottomCorner.center.y - SEPARATORWIDTH/2, rightBottomCorner.frame.origin.x - sideXpos, SEPARATORWIDTH)];
    [bottomConnector setBackgroundColor:SEPARATOR_COLOR];

    [self addSubview:topConnector];
    
    [self insertSubview:leftConnector belowSubview:leftTopCorner];
    [self insertSubview:rightConnector belowSubview:rightTopCorner];
    [self insertSubview:topConnector belowSubview:rightTopCorner];
    [self insertSubview:bottomConnector belowSubview:rightBottomCorner];

    _scalingFactor = 1.0;
    _movePoint = NoPoint;
    _lastMovePoint = CGPointMake(0, 0);
    
     /*UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCropPanGesture:)];
     [panGesture setMinimumNumberOfTouches:1];
     [panGesture setMaximumNumberOfTouches:1];
     [self addGestureRecognizer:panGesture];
     panGesture = nil;*/
    return self;
}

-(void)handleCropPanGesture:(id)gesture
{
    RLogs(@"Panning");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollDisable" object:nil];

}

-(void)updateCornerFrames
{
    [leftTopCorner setFrame:CGRectMake(0, 0, leftTopCorner.frame.size.width, leftTopCorner.frame.size.height)];
    
    [leftBottomCorner setFrame:CGRectMake(0, self.frame.size.height - leftBottomCorner.frame.size.height, leftBottomCorner.frame.size.width, leftBottomCorner.frame.size.height)];
    
    [rightTopCorner setFrame:CGRectMake(self.frame.size.width - rightTopCorner.frame.size.width, 0, rightTopCorner.frame.size.width, rightTopCorner.frame.size.height)];
    
    [rightBottomCorner setFrame:CGRectMake(self.frame.size.width - rightBottomCorner.frame.size.width, self.frame.size.height - rightBottomCorner.frame.size.height, rightBottomCorner.frame.size.width, rightBottomCorner.frame.size.height)];
    
    float sideYpos = leftTopCorner.frame.origin.y + leftTopCorner.frame.size.height;
    
    [leftConnector setFrame:CGRectMake(leftTopCorner.center.x - SEPARATORWIDTH/2 , sideYpos, SEPARATORWIDTH, leftBottomCorner.frame.origin.y - sideYpos)];
    
    [rightConnector setFrame:CGRectMake(rightTopCorner.center.x - SEPARATORWIDTH/2 , sideYpos, SEPARATORWIDTH, rightBottomCorner.frame.origin.y - sideYpos)];
    
    float sideXpos = leftTopCorner.frame.origin.x + leftTopCorner.frame.size.width;
    [topConnector setFrame:CGRectMake(sideXpos , leftTopCorner.center.y - SEPARATORWIDTH/2, rightTopCorner.frame.origin.x - sideXpos, SEPARATORWIDTH)];
    
    [bottomConnector setFrame:CGRectMake(sideXpos , leftBottomCorner.center.y - SEPARATORWIDTH/2, rightBottomCorner.frame.origin.x - sideXpos, SEPARATORWIDTH)];
    
    
    
}
- (void)setCropRegionRect:(CGRect)cropRect
{
    RLogs(@"cropRect - %@", NSStringFromCGRect(cropRect));
    
    if(cropRect.size.width <= minSize.width && cropRect.size.height <= minSize.height)
    {
        return;
    }
    /*_cropRect = cropRect;
    self.frame =CGRectMake(cropRect.origin.x/_scalingFactor, cropRect.origin.y/_scalingFactor, cropRect.size.width/_scalingFactor, cropRect.size.height/_scalingFactor);
    [_cropView setCropRegionRect:self.frame];*/
    if(cropRect.size.width <= minSize.width)
        cropRect.size.width = minSize.width;
    if(cropRect.size.height <= minSize.height)
        cropRect.size.height = minSize.height;
    [self setFrame:cropRect];
    
    //self.frame =CGRectMake(0/_scalingFactor, 0/_scalingFactor, cropRect.size.width/_scalingFactor, cropRect.size.height/_scalingFactor);

    //self.frame = self.frame;
    
    _cropRect = cropRect;
    
    /*leftTopCorner.center = _cropRect.origin;
    leftBottomCorner.center = CGPointMake(_cropRect.origin.x , _cropRect.origin.y + _cropRect.size.height);
    rightTopCorner.center = CGPointMake(_cropRect.origin.x + _cropRect.size.width , _cropRect.origin.y);
    rightBottomCorner.center = CGPointMake(_cropRect.origin.x + _cropRect.size.width , _cropRect.origin.y + _cropRect.size.height);*/
    
    
    [leftTopCorner setFrame:CGRectMake(0, 0, leftTopCorner.frame.size.width, leftTopCorner.frame.size.height)];
    [leftBottomCorner setFrame:CGRectMake(0, _cropRect.size.height - leftBottomCorner.frame.size.height, leftBottomCorner.frame.size.width, leftBottomCorner.frame.size.height)];
    
    [rightTopCorner setFrame:CGRectMake(_cropRect.size.width - rightTopCorner.frame.size.width, 0, rightTopCorner.frame.size.width, rightTopCorner.frame.size.height)];
    
    [rightBottomCorner setFrame:CGRectMake(_cropRect.size.width - rightBottomCorner.frame.size.width, _cropRect.size.height - rightBottomCorner.frame.size.height, rightBottomCorner.frame.size.width, rightBottomCorner.frame.size.height)];

    
    
}

/*-(void) drawRect:(CGRect)rect2
{
    [super drawRect:rect2];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = _cropRect;
    
    
    
    CGContextSetRGBFillColor(context,   0.6, 0.6, 0.6, 0.7);
    CGContextSetRGBStrokeColor(context, 0.6, 0.6, 0.6, 1.0);
    
    
    CGFloat lengths[2];
    lengths[0] = 0.0;
    lengths[1] = 3.0 * 2;
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 3.0);
    CGContextSetLineDash(context, 0.0f, lengths, 2);
    
    
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;
    
    CGRect clips2[] =
	{
        CGRectMake(0, 0, w, rect.origin.y),
        CGRectMake(0, rect.origin.y,rect.origin.x, rect.size.height),
        CGRectMake(0, rect.origin.y + rect.size.height, w, h-(rect.origin.y+rect.size.height)),
        CGRectMake(rect.origin.x + rect.size.width, rect.origin.y, w-(rect.origin.x + rect.size.width), rect.size.height),
	};
    CGContextClipToRects(context, clips2, sizeof(clips2) / sizeof(clips2[0]));
    
    CGContextFillRect(context, self.bounds);
    CGContextStrokeRect(context, rect);
    UIGraphicsEndImageContext();
}*/


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    RLogs(@"Touch Begins");
    [super touchesBegan:touches withEvent:event];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollDisable" object:nil];
    
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    RLogs(@"touch Began location point - %@", NSStringFromCGPoint(locationPoint));

    if(locationPoint.x < 0 || locationPoint.y < 0 || locationPoint.x > self.bounds.size.width || locationPoint.y > self.bounds.size.height)
    {
        _movePoint = NoPoint;
        return;
    }
    _lastMovePoint = locationPoint;
    
    lastCentrePoint = self.center;
    
    //Checking whether the user touched corner points are not.
    int cornerPadding = 5.0;
   if((locationPoint.x >= leftTopCorner.frame.origin.x - cornerPadding && locationPoint.x <= leftTopCorner.frame.origin.x + leftTopCorner.frame.size.width + 2*cornerPadding) && (locationPoint.y >= leftTopCorner.frame.origin.y - cornerPadding && locationPoint.y <= leftTopCorner.frame.origin.y + leftTopCorner.frame.size.height + 2* cornerPadding))
   {
       _movePoint = LeftTop;
   }
   else if((locationPoint.x >= leftBottomCorner.frame.origin.x - cornerPadding && locationPoint.x <= leftBottomCorner.frame.origin.x + leftBottomCorner.frame.size.width + 2*cornerPadding) && (locationPoint.y >= leftBottomCorner.frame.origin.y - cornerPadding && locationPoint.y <= leftBottomCorner.frame.origin.y + leftBottomCorner.frame.size.height + 2*cornerPadding))
   {
       _movePoint = LeftBottom;
   }
    else if((locationPoint.x >= rightTopCorner.frame.origin.x - cornerPadding && locationPoint.x <= rightTopCorner.frame.origin.x + rightTopCorner.frame.size.width + 2 * cornerPadding) && (locationPoint.y >= rightTopCorner.frame.origin.y - cornerPadding && locationPoint.y <= rightTopCorner.frame.origin.y + rightTopCorner.frame.size.height + 2*cornerPadding))
    {
        _movePoint = RightTop;

    }

    else if((locationPoint.x >= rightBottomCorner.frame.origin.x - cornerPadding && locationPoint.x  <= rightBottomCorner.frame.origin.x + rightBottomCorner.frame.size.width + 2*cornerPadding) && (locationPoint.y >= rightBottomCorner.frame.origin.y - cornerPadding && locationPoint.y <= rightBottomCorner.frame.origin.y + rightBottomCorner.frame.size.height + 2*cornerPadding))
    {
        _movePoint = RightBottom;
        
    }
    else if (locationPoint.x < self.bounds.size.width && locationPoint.y < self.bounds.size.height)
    {
        _movePoint = MoveCenter;
    }
    else
        _movePoint = NoPoint;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self.superview];
    
    CGPoint locationPoint1 = [[touches anyObject] locationInView:self];

    
    RLogs(@"Location Point: (%f,%f)", locationPoint.x, locationPoint.y);
    
    RLogs(@"touch Move location point - %@", NSStringFromCGPoint(locationPoint));

    
    if(locationPoint.x < 0 || locationPoint.y < 0 || locationPoint.x > self.superview.bounds.size.width || locationPoint.y > self.superview.bounds.size.height)
    {
        _movePoint = NoPoint;
        return;
    }
    float x,y;
    
    CGRect frame;
    
    switch (_movePoint) {
        case LeftTop:
        {
            RLogs(@"leftTop");
            frame = CGRectMake(locationPoint.x, locationPoint.y, self.frame.size.width + (self.frame.origin.x - locationPoint.x), self.frame.size.height + (self.frame.origin.y - locationPoint.y));
            
        }
            break;
        case LeftBottom:
        {
            RLogs(@"LeftBottom");

            frame = CGRectMake(locationPoint.x, self.frame.origin.y,
                                             self.frame.size.width + (self.frame.origin.x - locationPoint.x),
                                             locationPoint.y - self.frame.origin.y);
        }
            break;
        case RightTop:
        {
            RLogs(@"rightTop");

            frame = CGRectMake(self.frame.origin.x, locationPoint.y,
                                             locationPoint.x - self.frame.origin.x,
                                             self.frame.size.height + (self.frame.origin.y - locationPoint.y));
        }
            break;
        case RightBottom:
           
            frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                             locationPoint.x - self.frame.origin.x,
                                             locationPoint.y - self.frame.origin.y);
            break;
        case MoveCenter:
            
            x = _lastMovePoint.x - locationPoint1.x;
            y = _lastMovePoint.y - locationPoint1.y;
            if(((self.frame.origin.x-x) > 0) && ((self.frame.origin.x + self.frame.size.width - x) <
                                                          self.superview.bounds.size.width) &&
               ((self.frame.origin.y-y) > 0) && ((self.frame.origin.y + self.frame.size.height - y) < self.superview.bounds.size.height))
            {
               // self.center = CGPointMake(self.center.x - x, self.center.y - y);
                //frame = CGRectMake(self.frame.origin.x - x, self.frame.origin.y - y, self.frame.size.width, self.frame.size.height);
            }
            
            if((locationPoint.x + (self.frame.size.width/2) < self.superview.bounds.size.width) && (locationPoint.x - (self.frame.size.width/2) > 0) && (locationPoint.y - (self.frame.size.height/2) > 0) && (locationPoint.y + (self.frame.size.height/2) < self.superview.bounds.size.height))
             self.center = locationPoint;

            _lastMovePoint = locationPoint1;
            break;
        default: //NO Point
            return;
            break;
    }
    RLogs(@"setting frame1 - %@, \n %@", NSStringFromCGRect(frame), NSStringFromCGRect(self.frame));
    
    
     if(frame.size.width <= minSize.width && frame.size.height <= minSize.height)
     {
         return;
    }
    else
    {
        
        RLogs(@"setting frame2 - %@", NSStringFromCGRect(frame));
        
        if(frame.size.width <= minSize.width)
            frame.size.width = minSize.width;
        
        if(frame.size.height <= minSize.height)
            frame.size.height = minSize.height;
        
        [self setFrame:frame];
        [self setNeedsDisplay];
        [self updateCornerFrames];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollEnable" object:nil];
}

- (void)setDefaultCenterPoint:(CGPoint)point
{
    dafaultPoint = point;
}

- (CGPoint)getDefaultCenterPoint
{
    return dafaultPoint;
}

@end
