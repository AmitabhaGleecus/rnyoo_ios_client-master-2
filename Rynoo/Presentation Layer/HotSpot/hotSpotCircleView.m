//
//  hotSpotCircleView.m
//  Rnyoo
//
//  Created by Rnyoo on 26/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "hotSpotCircleView.h"

#import "Constants.h"



@implementation hotSpotCircleView



@synthesize isSaved,imgId,hotspotColor, imageView,strHotspotId,strAudioFileName, lblTitle, isModified, addedInZoomScale, isInZoomedState,numberofRatings;

@synthesize strAudioId;
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect {
    // Drawing code
    //Here adding default white cirecle image of HotSpot.
    

}*/

-(void)addCircleImage
{
    
    titleFont = [Util Font:FontTypeSemiBold Size:9.0];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 24, 24)];
    self.imageView.image = [UIImage imageNamed:@"hotspotIconwhite.png"];
    self.imageView.layer.cornerRadius = imageView.frame.size.width/2;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.clipsToBounds = YES;
    [self addSubview:self.imageView];
    
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 30, 15)];
    self.lblTitle.backgroundColor = [UIColor blackColor];
    self.lblTitle.textColor = [UIColor whiteColor];
    self.lblTitle.text = @"Label";
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    [self.lblTitle setFont:titleFont];
    [self addSubview:self.lblTitle];
    
}

-(void)updateTitle:(NSString*)strTitle
{
    if(strTitle.length == 0)
    {
        self.lblTitle.text = @"Label";
        self.lblTitle.frame = CGRectMake(0, 30, 30, 15);
        return;
    }
    self.lblTitle.text = strTitle;
    CGSize size = [strTitle sizeWithFont:titleFont constrainedToSize:CGSizeMake(100, 15)];
    if(size.width < 30)
    {
        self.lblTitle.frame = CGRectMake(0, self.lblTitle.frame.origin.y, 30, 10);

    }
    else
    self.lblTitle.frame = CGRectMake(0, self.lblTitle.frame.origin.y, size.width, 10);
    
    
}
//The Centre point coordinates get saved W.R.T bounds of Image. The Centre coordinates are updating when the hotspot is dragged over image.
-(void)setDefaultCentre:(CGPoint)centre
{
    RLogs(@"Default Centre - %@", NSStringFromCGPoint(centre));
    defaultCentre = centre;
}

//Getting Centre Coordinates W.R.T Image bounds.
-(CGPoint)getDefaultCentre
{
    return defaultCentre;
}

//Setting Color Image based on User Selection for Hotspot.
-(void)setCircleColorImage:(UIImage*)colorImage
{
    if(self.imageView == nil)
    {
        RLogs(@"<<<<<<<<<<<<<<setting Image>>>>>>>>>>>>>>>>>>");
    }
    [self.imageView setImage:colorImage];
}

//Setting whether the current Centre point is W.R.T to Portrait
-(void)setOrientationToPortrait
{
    RLogs(@"setPortrait");
    isPortrait = YES;
}

//Setting whether the current Centre point is W.R.T to LandScape
-(void)setOrientationToLandscape
{
    RLogs(@"setLandscape");

    isPortrait = NO;
}

//To know in which Orientation, the current centre of hotspot is saved.
-(BOOL)isAddedInPortrait
{
    if(isPortrait)
    {
        RLogs(@"hotspot isPortrait");
    }
    else
    {
        RLogs(@"hotspot isLandscape");
    }

    return isPortrait;
}


#pragma mark setting Colors

-(void)setWhiteColor
{
    [self setCircleColorImage:[UIImage imageNamed:@"hotspotIconwhite@2x.png"]];
    self.hotspotColor = HotspotWhiteColor;
    
}
-(void)setRedColor
{
    [self setCircleColorImage:[UIImage imageNamed:@"hotspotIconred@2x.png"]];
    self.hotspotColor = HotspotRedColor;
    
    
}
-(void)setBlueColor
{
    [self setCircleColorImage:[UIImage imageNamed:@"hotspotIconblue@2x.png"]];
    self.hotspotColor = HotspotBlueColor;
    
    
}
-(void)setYellowColor
{
    
    [self setCircleColorImage:[UIImage imageNamed:@"hotspotIconyellow@2x.png"]];
    self.hotspotColor = HotspotYellowColor;
    
}




@end
