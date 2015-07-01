//
//  hotSpotCircleView.h
//  Rnyoo
//
//  Created by Rnyoo on 26/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface hotSpotCircleView : UIView
{
    UIImageView *imageView;
    CGPoint defaultCentre;
    BOOL isPortrait;
    
    
    NSString *strAudioFilePath;
    
}
@property(nonatomic,retain)NSString *strAudioFilePath;
@property(nonatomic,retain)NSString *strImgFilePath;
@property(nonatomic,retain)NSString *strLabel;
@property(nonatomic,retain)NSString *strDescText;
@property(nonatomic,retain)NSString *strUrlText;
@property(nonatomic,assign)BOOL isSaved;
@property(nonatomic,assign)NSInteger imgId;
@property(nonatomic)int hotspotColor;
@property(nonatomic,assign)BOOL isHotspotEdit;

-(void)setCircleColorImage:(UIImage*)colorImage;

-(void)setDefaultCentre:(CGPoint)centre;

-(CGPoint)getDefaultCentre;

-(void)setOrientationToPortrait;

-(void)setOrientationToLandscape;

-(BOOL)getOrientation;

-(BOOL)isAddedInPortrait;

@end
