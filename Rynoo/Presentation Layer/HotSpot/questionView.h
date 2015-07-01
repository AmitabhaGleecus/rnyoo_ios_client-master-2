//
//  questionView.h
//  Rnyoo
//
//  Created by Sreenadh G on 12/01/15.
//  Copyright (c) 2015 Suvarna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface questionView : UIView
{
    CGPoint defaultCentre;
    BOOL isPortrait;
    NSString *strAudioFilePath;
    UIFont *titleFont;
}

@property(nonatomic,retain)NSString *strAudioFilePath;
@property(nonatomic,retain)NSString*strAudioUrl;
@property(nonatomic,retain)NSString *strLabel;
@property(nonatomic,retain)NSString *strDescText;
@property(nonatomic,retain)NSString *strUrlText;
@property(nonatomic,assign)BOOL isSaved, isModified;
@property(nonatomic,assign)NSInteger imgId;
@property(nonatomic)int hotspotColor;
@property(nonatomic,retain)NSString *strQuestionId;
@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) UILabel *lblTitle;
@property(nonatomic,retain)NSString *strAudioFileName;
@property(nonatomic, assign) float addedInZoomScale;
@property(nonatomic,retain)NSString *strAudioId;
@property(nonatomic,assign)BOOL isUploaded;
@property(nonatomic,assign)BOOL isHotspotTapped, isInZoomedState;

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
