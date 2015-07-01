//
//  hotSpotCircleView.m
//  Rnyoo
//
//  Created by Rnyoo on 26/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "hotSpotCircleView.h"

@implementation hotSpotCircleView

@synthesize strAudioFilePath,strImgFilePath,strLabel,strDescText,strUrlText;

@synthesize isSaved,imgId,hotspotColor,isHotspotEdit;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    imageView.image = [UIImage imageNamed:@"hotspotIconwhite.png"];
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    imageView.layer.masksToBounds = YES;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
        

}

-(void)setDefaultCentre:(CGPoint)centre
{
    NSLog(@"Default Centre - %@", NSStringFromCGPoint(centre));
    defaultCentre = centre;
}
-(CGPoint)getDefaultCentre
{
    return defaultCentre;
}
-(void)setCircleColorImage:(UIImage*)colorImage
{
    [imageView setImage:colorImage];
}

-(void)setOrientationToPortrait
{
    NSLog(@"setPortrait");
    isPortrait = YES;
}

-(void)setOrientationToLandscape
{
    NSLog(@"setLandscape");

    isPortrait = NO;
}

-(BOOL)isAddedInPortrait
{
    if(isPortrait)
        NSLog(@"hotspot isPortrait");
    else
        NSLog(@"hotspot isLandscape");

    return isPortrait;
}




@end
