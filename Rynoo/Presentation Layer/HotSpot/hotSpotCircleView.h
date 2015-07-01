//
//  hotSpotCircleView.h
//  Rnyoo
//
//  Created by Rnyoo on 26/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//
//This is the custom view of Hotspot.

#import <UIKit/UIKit.h>

@interface hotSpotCircleView : UIView
{
    
    CGPoint defaultCentre;
    BOOL isPortrait;
     NSString *strAudioFilePath;
    UIFont *titleFont;
    
}
@property(nonatomic,retain)NSString *strAudioFilePath;
@property(nonatomic,retain)NSString *strLabel;
@property(nonatomic,retain)NSString *strDescText;
@property(nonatomic,retain)NSString *strUrlText;
@property(nonatomic,assign)BOOL isSaved, isModified, isInZoomedState;
@property(nonatomic,assign)NSInteger imgId,numberofRatings;
@property(nonatomic)int hotspotColor;
@property(nonatomic,retain)NSString *strHotspotId;
@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) UILabel *lblTitle;
@property(nonatomic,retain)NSString *strAudioFileName;
@property(nonatomic, assign) float addedInZoomScale;
@property(nonatomic,retain)NSString *strAudioId;

-(void)setCircleColorImage:(UIImage*)colorImage;
-(void)setDefaultCentre:(CGPoint)centre;
-(CGPoint)getDefaultCentre;
-(void)setOrientationToPortrait;
-(void)setOrientationToLandscape;
-(BOOL)getOrientation;
-(BOOL)isAddedInPortrait;

-(void)setWhiteColor;
-(void)setRedColor;
-(void)setBlueColor;
-(void)setYellowColor;

-(void)addCircleImage;
-(void)updateTitle:(NSString*)strTitle;

@end
