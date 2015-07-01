//
//  HotSpotViewController.m
//  Rnyoo
//
//  Created by Rnyoo on 20/11/14.
//  Copyright (c) 2014 Rnyoo. All rights reserved.
//

#import "HotSpotViewController.h"
#import "NetworkViewController.h"
#import "PostViewController.h"
#import "Hotspot.h"
#import <AudioToolbox/AudioServices.h>

#import "UIImage+WebP.h"
#import "NetworkViewController.h"
#import "RateView.h"
#import "CommentsViewController.h"
#import "HotspotCommentViewController.h"
#import <QuartzCore/QuartzCore.h>


static int croppedImagesCount;

@interface HotSpotViewController () <UITextFieldDelegate,UIScrollViewDelegate>
{
    float firstX;
    float firstY;
    
    IBOutlet UIView *addHotSpotView;
    IBOutlet UIView *hotSpotEditToolView;

    IBOutlet UIView *hotSpotLabelView;
    IBOutlet UIView *hotSpotColorView;
    IBOutlet UIView *hotSpotTextView;
    IBOutlet UIView *hotSpotLinkView;
    IBOutlet UIView *hotSpotAudioView;
    
    IBOutlet NSLayoutConstraint *saveWidthConstraint;
    IBOutlet NSLayoutConstraint *hotspotWidthConstraint;
    IBOutlet NSLayoutConstraint *cropWidthConstraint;
    IBOutlet NSLayoutConstraint *eyeWidthConstraint;
    IBOutlet NSLayoutConstraint *postWidthConstraint;
    
     IBOutlet NSLayoutConstraint *closeWidthConstraint;
     IBOutlet NSLayoutConstraint *hotSpotLabelWidthConstraint;
     IBOutlet NSLayoutConstraint *hotSpotColorWidthConstraint;
     IBOutlet NSLayoutConstraint *hotSpotTextWidthConstraint;
     IBOutlet NSLayoutConstraint *hotSpotLinkWidthConstraint;
     IBOutlet NSLayoutConstraint *hotSpotAudioWidthConstraint;
    
     IBOutlet UIView *clipBoardView;
    
     BOOL isRecorded;
     NSTimer   *sliderTimer;
    
    BOOL isHospotSavedinDB;
    NSString *strAudioFileName;
    NSInteger index;
    
    UIView *topMenuView;
    
    BOOL isHsStructureModified;
    BOOL isComment;
    BOOL isHotSpotTapped;
    
    IBOutlet UIView *hotspotConsumerView;
    IBOutlet UIButton *btnConsumerAudio;
    IBOutlet NSLayoutConstraint *audioXPosConstraint;
    IBOutlet NSLayoutConstraint *rateXPosconstraint;
    IBOutlet NSLayoutConstraint *commentXPosConstraint;
    IBOutlet NSLayoutConstraint *audioWidthConstraint;
    IBOutlet NSLayoutConstraint *rateWidthConstraint;
    IBOutlet NSLayoutConstraint *commentWidthConstraint;
    
    BOOL isPreview;
    UIButton *btnHotspotComment;
    
    IBOutlet NSLayoutConstraint *descWidthConstraint;
    IBOutlet NSLayoutConstraint *linkWidthConstraint;
    IBOutlet UIButton *btnDescConsumerView;
    IBOutlet UIButton *btnLinkConsumerView;
    IBOutlet NSLayoutConstraint *descXPOSConstraint;
    IBOutlet NSLayoutConstraint *linkXPOSConstraint;
    IBOutlet UIButton *btnRate;
    IBOutlet UIButton *btnComment;
    
    BOOL isQuestionChangedToHS;
    NSMutableArray *aryConvertedQuestions;
    
    NSDictionary *dictPod;
}
@property(nonatomic,strong)UITextField *txtFld;

@end

@implementation HotSpotViewController

@synthesize pickedImage ,txtFld, arrHotspots, pickdImageView,context, arrHotspotInfo;
@synthesize selectedImgId,strSelectedImageFrom, source, isPodExisting, strParentPodId, strPodId,arrQuestions, strPostId,rateView;

@synthesize aryHotspotComments,aryQuestionComments,strLocation,imgCreatedDate,arrHotspotRating;

//Top Menu Back Button Clicked
-(void)backBtnClicked
{

    if(isPreview)
    {
        [self.navigationController popViewControllerAnimated:NO];
        isPreview = NO;
        return;
    }

    
    if([self.audioPlayer isPlaying])
    {
        [self.audioPlayer stop];
    }
    if([audioRecorder isRecording])
        [audioRecorder stop];
    
    
    if(self.source == FROM_CONSUMER)
    {
        [self sendBack];
        return;
    }
    
    BOOL isSaved = YES;
    
     if([arrHotspots count])
     {
         for(hotSpotCircleView *hsCircleViewObject in arrHotspots)
         {
             if(hsCircleViewObject.isSaved == NO || hsCircleView.isModified == YES)
             {
                 NSString *strMessage = @"";
                 
                 if(self.source == FROM_PUBLISHER)
                 {
                     
                     //This is from network screen and "UPDATE" and "RE-POST" screnario.
                     strMessage = @"You have made some changes. Do you want update?";
                 }
                 else{
                     
                     //This is from Gallery or Camera or vault. "SAVE" and "POST" screnario.

                     strMessage = @"Do you want to save Hotspots?";

                 }
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hotspot"
                                                                 message:strMessage
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
                 alert.tag = 101;
                 [alert show];
                 isSaved = NO;
                 return;
               
             }
         }
         if(isSaved ==YES)
             [self sendBack];

     }

     else if(!self.selectedImgId.length)
     {
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hotspot"
                                                         message:@"Do you want to save Image?"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
         alert.tag = 100;
         [alert show];
         return;

     }
     else
    {
        [self sendBack];

    }
    
}

-(void)previewBtnClicked
{
    isPreview = YES;
    
    UIButton *btnClose = (UIButton*)[self.view viewWithTag:1111];
    
    UIButton *btnPreview = (UIButton*)[self.view viewWithTag:2222];
    
    UIButton *btnZoomLock = (UIButton*)[self.view viewWithTag:3333];
    btnPreview.hidden = YES;
    btnZoomLock.hidden = YES;
    
    [btnClose setImage:[UIImage imageNamed:@"back-icon1.png"] forState:UIControlStateNormal];

   [btnClose setImageEdgeInsets:UIEdgeInsetsMake(-5, -20, -5, -20)];

    UIView *imgPreview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [imgPreview setBackgroundColor:[UIColor colorWithPatternImage:[self captureImage]]];

    imgPreview.userInteractionEnabled = NO;
    pickdImageView.userInteractionEnabled = NO;
    hotspotConsumerView.userInteractionEnabled = NO;
    addHotSpotView.userInteractionEnabled = NO;
    
    [UIView transitionWithView:imgPreview
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCurlDown
                    animations:^{
                        [imgPreview setBackgroundColor:[UIColor colorWithPatternImage:[self captureImage]]];
                    } completion:NULL];
    [self.view addSubview:imgPreview];
    
}

- (UIImage *)captureImage
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)disableZoomClicked:(id)sender
{
    UIButton *btnZoomLock = (UIButton*)sender;
    
    if(btnZoomLock.selected)
    {
        btnZoomLock.selected = NO;
        isZoomLocked = NO;
        [self enableScroll];

    }
    else
    {
        btnZoomLock.selected = YES;
        [self disableScroll];
        isZoomLocked = YES;


    }
}

#pragma mark UIScrollView Delegate Methods
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    //Setting selected image as content for scrollview to make the image scrollable.
    NSLog(@"Setting zoom View");
    NSLog(@"========================");
   
    isZoomLocked = NO;
    [self enableScroll];
    
    NSLog(@"Zoom Enbled : %d",_scrlImgView.scrollEnabled);
    
    return self.pickdImageView;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"?????Dragging");
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
  
    NSLog(@"scrollView Offset - %@", NSStringFromCGPoint(scrollView.contentOffset));
    NSLog(@"zoom level - %f",_scrlImgView.zoomScale);
    
    [self refreshImageWithHotspots];
    [self refreshImageWithCropView];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"End Decelerating");
    [self refreshImageWithHotspots];
}

-(void)refreshImageWithHotspots
{
    //Here Calculating the size of image when user zoomed in and out prior to repositioning the hotspots.
    
    
    if(_scrlImgView.zoomScale <= _scrlImgView.minimumZoomScale)
    {
        NSLog(@"<<<<<<<<<<<Ratio3>>>>>>>");
        //The image is in normal zoom level.
        
        [self.pickdImageView setFrame:CGRectMake(0, 0, _scrlImgView.frame.size.width, _scrlImgView.frame.size.height)];
        _scrlImgView.contentSize = self.pickdImageView.frame.size;
        
        [self calculateAspectRatioOfImage];
    }
    else
    {
        //Here the image is in some other zoom level. 'imageExactSubView' is the object of UIView on which we are adding hotspots making its bounds as per the fitted image.
        
        float imageBoundsWidth = imageBounds.width;
        
        float imageBoundsHeight = imageBounds.height;
        
        imageBoundsWidth = (_scrlImgView.contentSize.width/preImageViewSize.width) * imageBoundsWidth;
        
        imageBoundsHeight = (_scrlImgView.contentSize.height/preImageViewSize.height) * imageBoundsHeight;
        imageBounds = CGSizeMake(imageBoundsWidth, imageBoundsHeight);
        [imageExactSubView setFrame:CGRectMake(0, 0, imageBoundsWidth, imageBoundsHeight)];
        imageExactSubView.center = CGPointMake(_scrlImgView.contentSize.width/2, _scrlImgView.contentSize.height/2);
        NSLog(@"++++++imageExactSubView frame - %@",NSStringFromCGRect(imageExactSubView.frame));
        
        
        CGSize contentSize;
        if(imageExactSubView.frame.size.width > _scrlImgView.frame.size.width && imageExactSubView.frame.size.height < _scrlImgView.frame.size.height)
        {
            contentSize = CGSizeMake(imageExactSubView.frame.size.width, _scrlImgView.frame.size.height);
        }
        else if(imageExactSubView.frame.size.width < _scrlImgView.frame.size.width && imageExactSubView.frame.size.height > _scrlImgView.frame.size.height)
        {
            contentSize = CGSizeMake(_scrlImgView.frame.size.width, imageExactSubView.frame.size.height);
        }
        else
        {
            contentSize = CGSizeMake(imageExactSubView.frame.size.width, imageExactSubView.frame.size.height);
        }
        
        [_scrlImgView setContentSize:contentSize];
        self.pickdImageView.frame = CGRectMake(0, 0, _scrlImgView.contentSize.width, _scrlImgView.contentSize.height);
        preImageViewSize = self.pickdImageView.frame.size;
        imageExactSubView.center = CGPointMake(_scrlImgView.contentSize.width/2, _scrlImgView.contentSize.height/2);
        
    }
    
    
    
    
    //If hotspots added on the image and zoomed it, repositioning the hotspots to their relative positons.
    if([arrHotspots count])
    {
        [self refreshHotspotsPosition];
    }
    
    NSLog(@"ImageexactsubView Frame - %@", NSStringFromCGSize(imageExactSubView.frame.size));

}

-(void)refreshImageWithCropView
{
    //Getting the current bounds of selected image.
    float imgCurrentWidth = imageBounds.width;
    float imgCurrentHeight = imageBounds.height;
    
    CGPoint defaultCenter = [_cropView getDefaultCenterPoint];
    NSLog(@">>CropView Centre - %@", NSStringFromCGPoint(defaultCenter));
    
    CGPoint newCentre;
    
    //  newCentre.x = (imgCurrentWidth/imgOriginalWidth) * defaultCentre.x;
    // newCentre.y = (imgCurrentHeight/imgOriginalHeight) * defaultCentre.y;
    
    newCentre.x = (imgCurrentWidth/self.pickedImage.size.width) * defaultCenter.x;
    newCentre.y = (imgCurrentHeight/self.pickedImage.size.height) * defaultCenter.y;
    
    NSLog(@">>CropView Centre - %@", NSStringFromCGPoint(newCentre));
    
    [_cropView setCenter:newCentre];
}

#pragma HotSpot Positioning and tapping related Methods
-(void)refreshHotspotsPosition
{
    //Here we are repositioning the hotspots when the image is zoomed - In and Out
    CGSize normalSize;
    if(APP_DELEGATE.isPortrait)
    {
        normalSize = imgBoundsAtNormalZoomInPortrait;
    }
    else
    {
        normalSize = imgBoundsAtNormalZoomInLandScape;

    }
    
    NSLog(@"##########refreshHotspotsPosition############");
    NSLog(@"Normal Bounds - %@", NSStringFromCGSize(normalSize));
    NSLog(@"Current Bounds - %@", NSStringFromCGSize(imageBounds));

    float imgOriginalWidth;
    float imgOriginalHeight;
    
    
    //Getting the current bounds of selected image.
    float imgCurrentWidth = imageBounds.width;
    float imgCurrentHeight = imageBounds.height;
    
    CGPoint defaultCentre;

    //For every hotspot, based on its centre and the orientation in which it is added on image, calculating relative point to position hotspot on the image.
    
    for(UIView *aView in imageExactSubView.subviews)
    {
        if([aView isKindOfClass:[hotSpotCircleView class]])
        {
            hotSpotCircleView *hotspot = (hotSpotCircleView*)aView;
            
            NSLog(@"Portrait Normal size - %@", NSStringFromCGSize(imgBoundsAtNormalZoomInPortrait));
            NSLog(@"Landscape Normal size - %@", NSStringFromCGSize(imgBoundsAtNormalZoomInLandScape));

            if([APP_DELEGATE isPortrait])
            {
                 normalSize = imgBoundsAtNormalZoomInPortrait;
            }
            else
            {
                 normalSize = imgBoundsAtNormalZoomInLandScape;
            }
            
            NSLog(@" Normal size - %@", NSStringFromCGSize(normalSize));
            
            imgOriginalWidth = normalSize.width;
            imgOriginalHeight = normalSize.height;
            
            defaultCentre = [hotspot getDefaultCentre];
        
            NSLog(@">>Default Centre - %@", NSStringFromCGPoint(defaultCentre));
            CGPoint newCentre;
        
            //  newCentre.x = (imgCurrentWidth/imgOriginalWidth) * defaultCentre.x;
            // newCentre.y = (imgCurrentHeight/imgOriginalHeight) * defaultCentre.y;
            
            newCentre.x = (imgCurrentWidth/self.pickedImage.size.width) * defaultCentre.x;
            newCentre.y = (imgCurrentHeight/self.pickedImage.size.height) * defaultCentre.y;
        
            NSLog(@">>1New Centre - %@", NSStringFromCGPoint(newCentre));

            [hotspot setCenter:newCentre];
        }

    }
}

-(void)refreshHotspotsPositionInOrientation
{
    //Here we are repositioning the hotspots in Device Orientation.
    CGSize normalSize, currentSize;
    if(APP_DELEGATE.isPortrait)
    {
        NSLog(@"----Device is in Portrait");
        currentSize = imgBoundsAtNormalZoomInPortrait;
    }
    else
    {
        NSLog(@"---Device is in Landscape");

        currentSize = imgBoundsAtNormalZoomInLandScape;

        
    }
    NSLog(@"######refreshHotspotsPosition#########");
    NSLog(@"Normal Bounds - %@", NSStringFromCGSize(normalSize));
    NSLog(@"Current Bounds - %@", NSStringFromCGSize(imageBounds));
    
    float imgOriginalWidth;
    
    float imgOriginalHeight;
    
    float imgCurrentWidth = currentSize.width;
    
    float imgCurrentHeight = currentSize.height;
    
    CGPoint defaultCentre;
    
     //For every hotspot, based on its centre and the orientation in which it is added on image, calculating relative point to position hotspot on the image.
    
    for(UIView *aView in imageExactSubView.subviews)
    {
        if([aView isKindOfClass:[hotSpotCircleView class]])
        {
            hotSpotCircleView *hotspot = (hotSpotCircleView*)aView;
            
            if([hotspot isAddedInPortrait])
            {
                  NSLog(@"----Hotspot added in Portrait");
                normalSize = imgBoundsAtNormalZoomInPortrait;
            }
            else
            {
                NSLog(@"----Hotspot added in Landscape");

                normalSize = imgBoundsAtNormalZoomInLandScape;

            }
            NSLog(@"normalSize - %@", NSStringFromCGSize(normalSize));
            
            imgOriginalWidth = normalSize.width;
            imgOriginalHeight = normalSize.height;
            
            defaultCentre = [hotspot getDefaultCentre];
            
            if(hotspot )
            
            NSLog(@">>Default Centre - %@", NSStringFromCGPoint(defaultCentre));
            
            CGPoint newCentre;
            
         //   newCentre.x = (imgCurrentWidth/imgOriginalWidth) * defaultCentre.x;
            
         //   newCentre.y = (imgCurrentHeight/imgOriginalHeight) * defaultCentre.y;
            
            newCentre.x = (imgCurrentWidth/self.pickedImage.size.width) * defaultCentre.x;
            
            newCentre.y = (imgCurrentHeight/self.pickedImage.size.height) * defaultCentre.y;

            
            NSLog(@">>2New Centre - %@", NSStringFromCGPoint(newCentre));
            
            [hotspot setCenter:newCentre];
        }
        
    }
}

-(void)singleTap:(UITapGestureRecognizer *)gesture
{
NSLog(@">>>>>Tapped Image<<<<<<<<<<");
    
    //This method will get a call, when user taps on Image.

    if(isKeyBoardAppeared)
    {
        //if any text editing is under process, resigning that editing.
        [txtFld resignFirstResponder];
        [_descriptionTxtView resignFirstResponder];
        return;
        
    }
    
    //If any Hotspot is selected and its menu is showing, just hiding that edit tool menu of hotspot.

    if(hsCircleView != nil ||  hsQuestionView != nil)
    {
        if(!hotSpotEditToolView.isHidden)
        {
           // hotSpotEditToolView.hidden = YES;
            [self hideHotspotEditTool];
            
            hotSpotLabelView.hidden = YES;
            hotSpotColorView.hidden = YES;
            hotSpotTextView.hidden = YES;
            hotSpotLinkView.hidden = YES;
            hotSpotAudioView.hidden = YES;
            self.rateView.hidden = YES;
            
            hotspotConsumerView.hidden = YES;
            
        }
        
    }
    
    //storing the details in local varialbes of particular hotspot.
    if(self.source != FROM_CONSUMER)
        [self updateSelectedHotSpotDetails];
    
    //Stopping audio if any audio files are playing of a selected hotspot.
    [self stopAudio];
    
    if(self.source == FROM_CONSUMER)
    {
        hotspotConsumerView.hidden = YES;
        self.rateView.hidden = YES;
        isHotSpotTapped = NO;
         [self hideHotspotEditTool];

        [self updateSelectedQuestionDetails];
    }
    

}

-(void)updateSelectedHotSpotDetails
{
    if(![hsCircleView.strLabel isEqualToString:_hotspotTitle.text])
    {
        hsCircleView.strLabel = _hotspotTitle.text;
        hsCircleView.isModified = YES;
    }
    
    if(![hsCircleView.strDescText isEqualToString:_descriptionTxtView.text])
    {
        hsCircleView.strDescText = _descriptionTxtView.text;
        hsCircleView.isModified = YES;
        
    }
    if(![hsCircleView.strUrlText isEqualToString:_hotspotUrlTextField.text])
    {
        hsCircleView.strUrlText = _hotspotUrlTextField.text;
        hsCircleView.isModified = YES;
        
    }

}

#pragma mark View LifeCycle Methods
- (void)viewDidLoad
{
    //this mehtod will get executed after loading the view from storyboard after selecting the image.
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageSavedInWebpFormat) name:@"imageSaved" object:nil];

    isSendBack = NO;
    isHotSpotTapped = NO;
    isPreview = NO;
    isQuestionChangedToHS = NO;
    isToCreateNewPodForRepost = NO;
    
    context = [APP_DELEGATE managedObjectContext];

    objUtilForHotspot = [Util_HotSpot sharedInstance];
    [Util_HotSpot setIndexValue:0];
    [Util_HotSpot setBackGround:NO];
    
    self.arrHotspots = [[NSMutableArray alloc] init];
    self.arrQuestions= [[NSMutableArray alloc]init];
    
    aryConvertedQuestions = [[NSMutableArray alloc] init];
    index = 0;
   // hotSpotEditToolView.hidden = YES;
    [self hideHotspotEditTool];

    hotSpotLabelView.hidden = YES;
    hotSpotColorView.hidden = YES;
    hotSpotTextView.hidden = YES;
    hotSpotLinkView.hidden = YES;
    hotSpotAudioView.hidden = YES;
    clipBoardView.hidden = YES;
    
    [self adjustBottomFrames];
    isHospotSavedinDB = NO;
    isComment = NO;
    if(self.source == FROM_PUBLISHER)
    {
        isHospotSavedinDB = YES;
    }
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    tap.numberOfTapsRequired = 1;
    [_scrlImgView addGestureRecognizer:tap];
    
    [_scrlImgView setBackgroundColor:[UIColor blackColor]];
    
   
    
    [self addTopMenu];
    
    
    
    
    //setting the properties of scrollView in which the selected image will be added as content.
    
    [_scrlImgView setCanCancelContentTouches:NO];
    _scrlImgView.clipsToBounds = YES; // default is NO, we want to restrict drawing within our scrollview
    _scrlImgView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
  
    
    self.pickdImageView = [[UIImageView alloc] init];
    
    self.pickdImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=_scrlImgView.frame.size};
    
    [_scrlImgView addSubview:self.pickdImageView];
    
    _scrlImgView.delegate = self;
    
    [_scrlImgView setScrollEnabled:YES];
    
    [self.pickdImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    self.pickdImageView.backgroundColor = [UIColor clearColor];
    
    _scrlImgView.backgroundColor = [UIColor blackColor];

    self.view.backgroundColor = [UIColor blackColor];

    NSLog(@"ImagePath - %@", self.strImagePath);
    
    if([[NSFileManager defaultManager] fileExistsAtPath:self.strImagePath])
    {
        isImgSavedInWebp = YES;
        [self loadImage];
    }
    else
    {
        isImgSavedInWebp = NO;
        
        NSLog(@"showloader1");
        [self showLoader];
    }
    
    if([aryHotspotComments count] && self.source == FROM_PUBLISHER)
    {
        btnHotspotComment = [UIButton buttonWithType:UIButtonTypeCustom];
        btnHotspotComment.frame = CGRectMake(265, 0, 46, 40);
        [btnHotspotComment setImage:[UIImage imageNamed:@"comment.png"] forState:UIControlStateNormal];
        [btnHotspotComment addTarget:self action:@selector(navigateToHotspotCommentsScreen) forControlEvents:UIControlEventTouchUpInside];
        btnHotspotComment.hidden = YES;
        [hotSpotEditToolView addSubview:btnHotspotComment];
 
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    _descriptionTxtView.backgroundColor = [UIColor blackColor];
    
    [self.view bringSubviewToFront:hotSpotTextView];
    
    descriptionTextHeightConstant = _HotSpotTxtViewHeight.constant;
    
    

}

-(void)loadImage
{
    [self removeLoader];
    
    NSLog(@"Image path - %@",self.strImagePath);
    if([[NSFileManager defaultManager] fileExistsAtPath:self.strImagePath])
    {
        NSLog(@"File Existing at path");
    }
    else
    {
        NSLog(@"File not Existing at path");

    }
    
    [self.pickdImageView setImage:[UIImage imageWithWebPAtPath:self.strImagePath]];
    
    self.pickedImage = self.pickdImageView.image;
    
    
    NSLog(@"<<<<<<<<<<<Ratio1>>>>>>>");
    
    NSLog(@"imagesize - %@", NSStringFromCGSize(self.pickdImageView.image.size));
    [self calculateAspectRatioOfImage];
    
    recordEncoding = ENC_PCM;
    isRecorded = NO;
    self.sliderAudio.value = 0.0;
    self.sliderAudio.continuous = YES;
    self.btnDelete.hidden = YES;
    
    _hotspotTitle.delegate = self;
    //  self.sliderAudio.maximumValue = 2.0;
    
    if(self.selectedImgId.length)
    {
        if( self.source == FROM_PUBLISHER || self.source == FROM_CONSUMER)
        {
            //Already PodID is existing.
            NSLog(@"Pod ID is - %@", self.strParentPodId);
            
            self.strPodId = self.strParentPodId;
            
            [self loadHotSpots:self.arrHotspotInfo withSaveStatus:YES];
            
            
        }
        else
        {
            
            if(self.isPodExisting && self.strPodId.length)
            {
                //That is from draft of vault...
                [self loadHotspotsOfDraftPod];
                
            }
            else
            {
            //If it is from vault load hotspots of previous pod current image...
            [self loadHotpsotOfPreviousPodOfCurrentImageFromVault];
            }
            

         
        }
        
     }
    else
    {

        
    }
    
    if(self.strPodId.length == 0 || self.strPodId == nil)
    {
        self.strPodId = [Util GetUUID];
    }
    else{
        
    }

    [Util_HotSpot setPodId:self.strPodId];

    
    
    originalViewCentre = self.view.center;
    
    _scrlImgView.minimumZoomScale = 1.0f;
    _scrlImgView.maximumZoomScale = 4.0f;
    
    if([strSelectedImageFrom isEqualToString:@"Camera"])
    {
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    }
    else if([strSelectedImageFrom isEqualToString:@"Network"])
    {
        if(self.source == FROM_PUBLISHER)
        {
            UIButton *btnRePost = (UIButton*)[addHotSpotView viewWithTag:115];
            [btnRePost setTitle:@"RE-POST" forState:UIControlStateNormal];
        }
        
        UIButton *btnUpdate = (UIButton*)[addHotSpotView viewWithTag:111];
        [btnUpdate setTitle:@"UPDATE" forState:UIControlStateNormal];
        
    }
    if(self.source == FROM_CONSUMER || self.source == FROM_PUBLISHER)
    {
        [self loadQuestionsofSelectedImg];
    }
   
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:)
                                                 name:UIKeyboardDidChangeFrameNotification object:self.view.window];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableScroll) name:@"scrollEnable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableScroll) name:@"scrollDisable" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(podSyncSuccess:) name:@"PodSyncSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEntersIntoBackground) name:@"appIntoBG" object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(podSyncError:) name:@"PodSyncError" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPodData:) name:@"PodData" object:nil];
    

    
    //When loaded hotspots in publisher's view, we are using these bool variables...
    isPublisherRePost = NO;
    isPublisherUpdate = NO;
    
    
}

-(void)imageSavedInWebpFormat
{
    
    NSLog(@"<<<<webpNotification>>>>");
    [self loadImage];

    
}

- (void)centerScrollViewContents
{
    CGSize boundsSize = _scrlImgView.bounds.size;
    CGRect contentsFrame = self.pickdImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.pickdImageView.frame = contentsFrame;
    
    if(imageExactSubView.superview)
    imageExactSubView.center = self.pickdImageView.center;
    
    
    
    

}

-(void)disableScroll
{
    NSLog(@"disable");
    _scrlImgView.scrollEnabled = NO;

}

-(void)enableScroll
{
    NSLog(@"enable");
    if(isZoomLocked)
        return;

    _scrlImgView.scrollEnabled = YES;

}

-(void)addTopMenu
{
    int btnWidth = 40, btnHeight = 40;
    
   /* topMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [topMenuView setBackgroundColor:[UIColor redColor]];
    
    topMenuView.hidden = YES;*/
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnClose setFrame:CGRectMake(5, 20, btnWidth, btnHeight)];
    
    [btnClose setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    
    [btnClose addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    btnClose.tag = 1111;
    
    [btnClose setBackgroundColor:[UIColor clearColor]];
    
    [btnClose setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

    
    [self.view addSubview:btnClose];
    
    if(self.source != FROM_PUBLISHER && self.source != FROM_CONSUMER)
    {
        
        //There is no preview button for publisher and consumer. when came from network screen.
    UIButton *btnPreview = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnPreview setFrame:CGRectMake(self.view.frame.size.width - 110, 20, btnWidth, btnHeight)];
    
    [btnPreview setImage:[UIImage imageNamed:@"find.png"] forState:UIControlStateNormal];
    
    [btnPreview addTarget:self action:@selector(previewBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    btnPreview.tag = 2222;
    
    [btnPreview setBackgroundColor:[UIColor clearColor]];

    [btnPreview setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

    [self.view addSubview:btnPreview];
    }
    
    UIButton *btnZoomLock = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnZoomLock setFrame:CGRectMake(self.view.frame.size.width - 55, 20, btnWidth, btnHeight)];
    
    [btnZoomLock setImage:[UIImage imageNamed:@"scaling_fill.png"] forState:UIControlStateSelected];
    
    [btnZoomLock setImage:[UIImage imageNamed:@"scaling_outline.png"] forState:UIControlStateNormal];
    
    [btnZoomLock addTarget:self action:@selector(disableZoomClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    btnZoomLock.tag = 3333;
    
    [btnZoomLock setBackgroundColor:[UIColor clearColor]];

    [btnZoomLock setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    btnZoomLock.selected = NO;

    [self.view addSubview:btnZoomLock];

    
    
    
}

-(void)adjustTopMenuInOrientation
{
   // [topMenuView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    int ypos = 0;
    if(APP_DELEGATE.isPortrait)
        ypos = 20;
    else
        ypos = 0;
    
    UIButton *btnClose = (UIButton*)[self.view viewWithTag:1111];
    [btnClose setFrame:CGRectMake(5, ypos, 30, 30)];
    
    UIButton *btnPreview = (UIButton*)[self.view viewWithTag:2222];
    [btnPreview setFrame:CGRectMake(self.view.frame.size.width - 70, ypos, 30, 30)];
    
    UIButton *btnZoomLock = (UIButton*)[self.view viewWithTag:3333];
    [btnZoomLock setFrame:CGRectMake(self.view.frame.size.width - 35, ypos, 30, 30)];
}

#pragma mark Loading Hotspots

-(void)loadHotpsotOfPreviousPodOfCurrentImageFromVault
{
    NSString *strRecentPodIdOfImage = [Util_HotSpot getRecentPodIdFromDBOfImgId:self.selectedImgId];
    
    if(strRecentPodIdOfImage == nil)
    {
        return;
    }
    NSArray *arrHotSpotInfo = [Util_HotSpot getHotspotDataFromDBOfImgId:self.selectedImgId withPodId:strRecentPodIdOfImage];
    if(![arrHotSpotInfo count])
        return;
    
    [self loadHotSpots:arrHotSpotInfo withSaveStatus:NO];

}

-(void)loadHotspotsOfDraftPod
{
    NSArray *arrHotSpotInfo = [Util_HotSpot getHotspotDataFromDBOfImgId:self.selectedImgId withPodId:self.strPodId];
    if(![arrHotSpotInfo count])
        return;
    
    [self loadHotSpots:arrHotSpotInfo withSaveStatus:YES];
}

-(void)loadHotspotsOfSelectedPost
{
    
}

-(void)loadHotSpots:(NSArray*)arrHotSpotInfo withSaveStatus:(BOOL)isSaved
{
    
    NSLog(@"rating array :%@",arrHotspotRating);
    
    for(NSManagedObject *hotspotInfo in arrHotSpotInfo)
    {
        NSLog(@"hotspotInfo - %@", [hotspotInfo description]);
        CGPoint centre;
        
        NSString *strColor = @"white";
        
        
        hotSpotCircleView *hotSpot = [[hotSpotCircleView alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
        
        if([hotspotInfo isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dictLoc = [hotspotInfo valueForKey:@"location"];
            centre = CGPointMake([[dictLoc valueForKey:@"x"] integerValue], [[dictLoc valueForKey:@"y"] integerValue]);
            hotSpot.strLabel = [hotspotInfo valueForKey:@"hotspotLabel"];
            hotSpot.strHotspotId = [hotspotInfo valueForKey:@"hotspotId"];
            hotSpot.strDescText = [hotspotInfo valueForKey:@"hotspotDescription"];
            
            hotSpot.addedInZoomScale = [(NSNumber*)[hotspotInfo valueForKey:@"zoomFactor"] floatValue];
            
            
            NSLog(@">>>zoom2 - %f", (float)[[hotspotInfo valueForKey:@"zoomFactor"] floatValue]);
            
            NSLog(@">>>zoom3 - %f", (float)hotSpot.addedInZoomScale);

            
            strColor = [[hotspotInfo valueForKey:@"markerColor"] lowercaseString];

            NSDictionary *dictMedia = [hotspotInfo valueForKey:@"media"];
            
            hotSpot.strAudioId = [dictMedia valueForKey:@"audioId"];
            hotSpot.strAudioFilePath = [dictMedia valueForKey:@"audioUrl"];
            
            if([[hotspotInfo valueForKey:@"orientation"] isEqualToString:@"portrait"])
            {
                [hotSpot setOrientationToPortrait];
            }
            else
            {
                [hotSpot setOrientationToLandscape];
            }
            hotSpot.strUrlText = [hotspotInfo valueForKey:@"clickUrl"];
      //      hotSpot.numberofRatings = [[hotspotInfo valueForKey:@"ratings"]integerValue];

          
        }
        else
        {
            centre = CGPointMake([[hotspotInfo valueForKey:@"xCoordinate"] integerValue], [[hotspotInfo valueForKey:@"yCoordinate"] integerValue]);
            hotSpot.strLabel = [hotspotInfo valueForKey:@"strLabel"];
            hotSpot.strDescText = [hotspotInfo valueForKey:@"strDescription"];
            hotSpot.strUrlText = [hotspotInfo valueForKey:@"url"];
            hotSpot.strHotspotId = [hotspotInfo valueForKey:@"hId"];
            hotSpot.addedInZoomScale = [[hotspotInfo valueForKey:@"zoomFactor"] floatValue];
            
            
            NSLog(@">>>zoom21 - %f", (float)[[hotspotInfo valueForKey:@"zoomFactor"] floatValue]);
            
            NSLog(@">>>zoom31 - %f", (float)hotSpot.addedInZoomScale);
            
            hotSpot.strAudioFileName = [hotspotInfo valueForKey:@"audioFileName"];
            hotSpot.strAudioFilePath = [hotspotInfo valueForKey:@"audioFilePath"];
            
            if([[hotspotInfo valueForKey:@"orientation"] isEqualToString:@"portrait"])
            {
                [hotSpot setOrientationToPortrait];
            }
            else
            {
                [hotSpot setOrientationToLandscape];
            }
             strColor = [[hotspotInfo valueForKey:@"hotspotColor"] lowercaseString];


        }
        
        hotSpot.backgroundColor= [UIColor clearColor];
        [hotSpot addCircleImage];

        [hotSpot setDefaultCentre:centre];
        
       
        
        hotSpot.isSaved = isSaved;
        
        if(![hotSpot.strLabel isEqualToString:@""])
        [hotSpot updateTitle:hotSpot.strLabel];
        
        
        if([hotSpot.strUrlText isEqualToString:@""])
            hotSpot.strUrlText = @"http://www.";
    

    

        NSLog(@"audio filename:%@",hotSpot.strAudioFileName);
        
        
        CGSize imagSize;
        imagSize = CGSizeMake(self.pickedImage.size.width, self.pickedImage.size.height);
        
        CGPoint newCentre;
        if(APP_DELEGATE.isPortrait)
        {
            
            
            newCentre.x = (imgBoundsAtNormalZoomInPortrait.width / imagSize.width) * centre.x;
            newCentre.y = (imgBoundsAtNormalZoomInPortrait.height / imagSize.height) * centre.y;

        }
        else
        {
            newCentre.x = (imgBoundsAtNormalZoomInLandScape.width / imagSize.width) * centre.x;
            newCentre.y = (imgBoundsAtNormalZoomInLandScape.height / imagSize.height) * centre.y;
        }
        
        hotSpot.center = newCentre;
        
           hotSpot.isSaved = YES;
        if(imageExactSubView == nil)
            NSLog(@"imageExactSubView is nil");
        [imageExactSubView addSubview:hotSpot];
        
        //Here adding pangesture for dragging the Hotspot over the image.
        if(self.source != FROM_CONSUMER)
        {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        [hotSpot addGestureRecognizer:panGesture];
        panGesture = nil;
        }
        
        //Adding tapGesture to select the hotspot among all hotspots added to the image.
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hotSpotTap:)];
        tap.numberOfTapsRequired = 1;
        [hotSpot addGestureRecognizer:tap];
        
        [arrHotspots addObject:hotSpot];
        
        [hotSpot setTag:[arrHotspots count]];
        
        
        
        
        NSLog(@"prestrColor - %@", strColor);
        
        if([strColor isEqualToString:@"red"])
        {
            NSLog(@"strColor - %@", strColor);
            
            [hotSpot setRedColor];
        }
        else if ([strColor isEqualToString:@"white"])
        {
            NSLog(@"strColor - %@", strColor);
            
            [hotSpot setWhiteColor];
            
        }
        else if ([strColor isEqualToString:@"blue"])
        {
            NSLog(@"strColor - %@", strColor);
            
            [hotSpot setBlueColor];
            
        } else if ([strColor isEqualToString:@"yellow"])
        {
            NSLog(@"strColor - %@", strColor);
            
            [hotSpot setYellowColor];
            
        }
        else
        {
            NSLog(@"strColor - %@", strColor);
            
            [hotSpot setWhiteColor];
            
        }

        if(self.source == FROM_CONSUMER)
        {
           // hotSpot.userInteractionEnabled = NO;
        }
    }
    
   // [self refreshHotspotsPosition];
}

-(void)loadImageAndHotspotsfromImagePath:(NSString*)strImgPath
{
    [self.pickdImageView setImage:[self imageFromPath:strImgPath]];
}

#pragma mark UIViewController orientation methods
-(void)updateViewConstraints
{
    
    NSLog(@"============================");
    NSLog(@"updateViewConstraints - %@", NSStringFromCGSize(self.view.frame.size));
    NSLog(@"============================");

    
    //Changing layout constraints in Orientation
    
    [super updateViewConstraints];
    

    float width;
    

    if([Util isIOS8])
    {
        if(self.view.frame.size.width > self.view.frame.size.height)
            APP_DELEGATE.isPortrait = NO;
        else
            APP_DELEGATE.isPortrait = YES;
    }
    
    
    
    if(APP_DELEGATE.isPortrait)
    {
        NSLog(@"adjust portrait");
        width = portraitWidth;
    }
    else
    {
        NSLog(@"adjust landscape");

        width = LandScapeWidth;

    }
    NSLog(@">>>>>>>>>width - %f",width);
    

    
    
   // _scrlImgView.contentOffset = CGPointZero;
    
    
    isOrientationChanged = YES;
    
    
    
    //[[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];

}
-(void)viewWillLayoutSubviews
{
    
    NSLog(@"============================");
    NSLog(@"viewWillLayoutSubviews- %@", NSStringFromCGSize(self.view.frame.size));
    NSLog(@"============================");
    
    float btnWidth = self.view.frame.size.width/5;
    
    if(self.source == FROM_CONSUMER)
    {
        btnWidth = self.view.frame.size.width/3;
        _saveXposConstraint.constant = 0.0;
        _hotSpotXposConstraint.constant = btnWidth;
        _eyeXposConstraint.constant = 2*btnWidth;
        
        _saveWidthConstraint.constant = _eyeWidthConstraint.constant = _hotSpotWidthConstraint.constant = btnWidth;
        
        [_btnCropClip setHidden:YES];
        
        UIButton *btnPost = (UIButton*)[addHotSpotView viewWithTag:115];
        [btnPost setHidden:YES];
       
        
    }
    else
    {
    //NSLog(@"btnWidth - %f", btnWidth);
    
    _saveXposConstraint.constant = 0.0;
    _hotSpotXposConstraint.constant = btnWidth;
    _cropXposConstraint.constant = 2*btnWidth;
    _eyeXposConstraint.constant = 3*btnWidth;
    _postXposConstraint.constant = 0.0;
    
    
    _saveWidthConstraint.constant = _hotSpotWidthConstraint.constant = _cropWidthConstraint.constant = _eyeWidthConstraint.constant = _postWidthConstraint.constant = btnWidth;
    }

    
    float xposInset = (btnWidth - 20)/2;
    float yposInset = (_btnAddHotSpot.frame.size.height - 15)/2;
    _btnAddHotSpot.imageEdgeInsets = UIEdgeInsetsMake(-yposInset, -xposInset, -yposInset, -xposInset);
    if(![Util isIOS8])
    {
        NSLog(@"isIos7 & ios6 only");
        
        [_btnAddHotSpot setImage:[UIImage imageNamed:@"hotspot.png"] forState:UIControlStateNormal];
        
        [_btnCropClip setImage:[UIImage imageNamed:@"scissors.png"] forState:UIControlStateNormal];
        
        [_btnEye setImage:[UIImage imageNamed:@"eye.png"] forState:UIControlStateNormal];
        
        
    }
    //NSLog(@"Insets - %@", NSStringFromUIEdgeInsets(_btnAddHotSpot.imageEdgeInsets));
    if(self.source == FROM_CONSUMER)
    {
        
    }
    else
    {
    xposInset = (btnWidth - 20)/2;
    yposInset = (_btnCropClip.frame.size.height - 15)/2;
    _btnCropClip.imageEdgeInsets = UIEdgeInsetsMake(-yposInset, -xposInset, -yposInset, -xposInset);
    }
    
    xposInset = (btnWidth - 20)/2;
    yposInset = (_btnEye.frame.size.height - 15)/2;
    _btnEye.imageEdgeInsets = UIEdgeInsetsMake(-yposInset, -xposInset, -yposInset, -xposInset);
    
    ///Changing Width Constrint for all the buttons on hotspot tool View.
    
    
    if(self.source == FROM_CONSUMER)
    {
        //close,question color,text,audio
        if(hsQuestionView.isUploaded)
        {
            if(isHotSpotTapped)
            {
                hotspotConsumerView.hidden = NO;
                if(isOrientationChanged)
                {
                    [self loadConsumerHSEditToolView];

                }
                return;
                
            }
            btnWidth = self.view.frame.size.width/5;
            xposInset = (btnWidth - 20)/2;
            yposInset = (_btnAudio.frame.size.height - 15)/2;

         //   _btnAudio.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset,yposInset, xposInset);
            [_btnAudio setImage:[UIImage imageNamed:@"comment.png"] forState:UIControlStateNormal];
            
            [_btnLink setImage:[UIImage imageNamed:@"hotspotAudio.png"] forState:UIControlStateNormal];

            _btnLabel.hidden = YES;
            _btnLink.hidden = NO;
            hotSpotLabelWidthConstraint.constant = 0;
          
            closeWidthConstraint.constant = hotSpotColorWidthConstraint.constant = hotSpotTextWidthConstraint.constant = hotSpotAudioWidthConstraint.constant= hotSpotLinkWidthConstraint.constant = btnWidth;
            
            [_btnAddHotSpot setImage:[UIImage imageNamed:@"hotspotQuestion.png"] forState:UIControlStateNormal];

          
        }
        else if(isHotSpotTapped)
        {
            hotspotConsumerView.hidden = NO;
            if([hsCircleView.strAudioFilePath length]>0)
                self.btnDelete.hidden = YES;
            
            if(isOrientationChanged)
            {
                [self loadConsumerHSEditToolView];

            }
        }
        else {
            btnWidth = self.view.frame.size.width/4;
            _btnLabel.hidden = YES;
            _btnLink.hidden = YES;
            hotSpotLabelWidthConstraint.constant = 0;
            hotSpotLinkWidthConstraint.constant = 0;
             closeWidthConstraint.constant = hotSpotColorWidthConstraint.constant = hotSpotTextWidthConstraint.constant = hotSpotAudioWidthConstraint.constant=  btnWidth;
            [_btnAddHotSpot setImage:[UIImage imageNamed:@"hotspotQuestion.png"] forState:UIControlStateNormal];
            
            [_btnAudio setImage:[UIImage imageNamed:@"hotspotAudio.png"] forState:UIControlStateNormal];



        }

        
        //_btnAddHotSpot.imageEdgeInsets = UIEdgeInsetsMake(-yposInset, -xposInset, -yposInset, -xposInset);

        
    }
    else
    {
        if(hsQuestionView.isUploaded && !isHotSpotTapped )
        {
            if(isOrientationChanged)
               [self loadPublisherQuestionToolView];
            
            return;
        }
            
        if([aryHotspotComments count] )
        {
            btnWidth = self.view.frame.size.width/7;
            btnHotspotComment.hidden = NO;
            xposInset = (btnWidth - 20)/2;
            yposInset = (btnHotspotComment.frame.size.height - 15)/2;
            
            btnHotspotComment.imageEdgeInsets =  UIEdgeInsetsMake(-yposInset, -xposInset, -yposInset, -xposInset);

            NSLog(@"width%f",hotSpotEditToolView.frame.size.width -40);
          
            [btnHotspotComment setImage:[UIImage imageNamed:@"comment.png"] forState:UIControlStateNormal];

            if(APP_DELEGATE.isPortrait)
                [btnHotspotComment setFrame:CGRectMake(hotSpotEditToolView.frame.size.width -40, yposInset+11, btnWidth-15, 27)];

            NSLog(@"frame button:%@",btnHotspotComment);
        }
        else
        {
            btnWidth = self.view.frame.size.width/6;
             btnHotspotComment.hidden = YES;
        }
        closeWidthConstraint.constant = btnWidth;
        hotSpotLabelWidthConstraint.constant = btnWidth;
        hotSpotColorWidthConstraint.constant = btnWidth;
        hotSpotTextWidthConstraint.constant = btnWidth;
        hotSpotLinkWidthConstraint.constant = btnWidth;
        hotSpotAudioWidthConstraint.constant = btnWidth;
    
    }
    
    
    NSArray *arrHotspotToolImages = [NSArray arrayWithObjects:@"hotspotLabel@2x", @"hotspotColor@2x", @"hotspotText@2x", @"hotspotLink@2x", @"hotspotAudio@2x",nil];
    UIImage *imgBtn = nil;
    CGSize imgSize;
    UIButton *btn;
    
    int i = 1;
    
   
    for(NSString *strImage in arrHotspotToolImages)
    {
        
        imgBtn = [Util imageWithName:strImage];
        
        imgSize = imgBtn.size;
        
        NSLog(@"size - %@", NSStringFromCGSize(imgSize));
        
        btn = (UIButton*)[hotSpotEditToolView viewWithTag:i];
        
        i++;
        //NSLog(@"btnsize - %@", NSStringFromCGSize(btn.frame.size));
        
        xposInset = (btnWidth - (imgSize.width/2))/2;
        yposInset = (btn.frame.size.height - (imgSize.height/2))/2;
        
        btn.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset, yposInset, xposInset);
        
        //NSLog(@"btnInsets - %@", NSStringFromUIEdgeInsets(btn.imageEdgeInsets));
        
        
    }
   
   
}

/* handle hotspot consumer view when tapped on hotspot in orientation */
-(void)loadConsumerHSEditToolView
{
    
    float btnWidth;
    
    float xposInset ;
    float yposInset;
    
    btnConsumerAudio.hidden = YES;
    btnDescConsumerView.hidden = YES;
    btnLinkConsumerView.hidden = YES;
    
    
    int MenuItems = 2; //As rating and comment tabs are common.
    
    if([hsCircleView.strDescText length] > 0)
        MenuItems++;
    if([hsCircleView.strAudioFilePath length] > 0)
        MenuItems++;
    if([hsCircleView.strUrlText length] > 0 && ![hsCircleView.strUrlText isEqualToString:@"http://www."])
        MenuItems++;

    btnWidth = self.view.frame.size.width/MenuItems;
    xposInset = (btnWidth - 20)/2;

    
    int xposConstraint = 0.0;
    
    if(hsCircleView.strDescText.length)
    {
        btnDescConsumerView.hidden = NO;

        descXPOSConstraint.constant = xposConstraint;
        xposConstraint += btnWidth;
        descWidthConstraint.constant = btnWidth;
        
        yposInset = (btnDescConsumerView.frame.size.height - 15)/2;
        btnDescConsumerView.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset, yposInset, xposInset);
    }
    else
    {
        btnDescConsumerView.hidden = YES;

        descWidthConstraint.constant = 0.0;

    }
    
    if(hsCircleView.strUrlText.length && ![hsCircleView.strUrlText isEqualToString:@"http://www."])
    {
        btnLinkConsumerView.hidden = NO;

        linkXPOSConstraint.constant = xposConstraint;
        xposConstraint += btnWidth;
        linkWidthConstraint.constant = btnWidth;
        
        yposInset = (btnLinkConsumerView.frame.size.height - 15)/2;
        btnLinkConsumerView.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset, yposInset, xposInset);

    }
    else
    {
        btnLinkConsumerView.hidden = YES;
        linkWidthConstraint.constant = 0.0;

    }
    
    if(hsCircleView.strAudioFilePath.length)
    {
        btnConsumerAudio.hidden = NO;

        audioXPosConstraint.constant = xposConstraint;
        xposConstraint += btnWidth;
        audioWidthConstraint.constant = btnWidth;
        
        yposInset = (btnConsumerAudio.frame.size.height - 15)/2;
        btnConsumerAudio.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset, yposInset, xposInset);

        
    }
    else
    {
        btnConsumerAudio.hidden = YES;
        audioWidthConstraint.constant = 0.0;

    }
    
    rateXPosconstraint.constant = xposConstraint;
    commentXPosConstraint.constant = xposConstraint + btnWidth;
    rateWidthConstraint.constant = commentWidthConstraint.constant = btnWidth;
}

-(void)loadHotspotEditToolView
{
    float btnWidth = self.view.frame.size.width/5;

    NSLog(@"btnWidth - %f", btnWidth);
    
    _saveXposConstraint.constant = 0.0;
    _hotSpotXposConstraint.constant = btnWidth;
    _cropXposConstraint.constant = 2*btnWidth;
    _eyeXposConstraint.constant = 3*btnWidth;
    _postXposConstraint.constant = 0.0;
    
    _saveWidthConstraint.constant = _hotSpotWidthConstraint.constant = _cropWidthConstraint.constant = _eyeWidthConstraint.constant = _postWidthConstraint.constant = btnWidth;
    
    [_btnCropClip setHidden:NO];
    
    UIButton *btnPost = (UIButton*)[addHotSpotView viewWithTag:115];
    [btnPost setHidden:NO];
}
-(void)viewDidLayoutSubviews
{
    
    NSLog(@"============================");
    NSLog(@"viewDidLayoutSubviews- %@", NSStringFromCGSize(self.view.frame.size));
    NSLog(@"addHotSpotView- %@", NSStringFromCGSize(addHotSpotView.frame.size));
    NSLog(@"============================");
    

    if(isOrientationChanged)
    {
       // self.pickdImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.pickedImage.size};


       // [self centerScrollViewContents];
        
        [_scrlImgView setZoomScale:_scrlImgView.minimumZoomScale animated:YES];
        
        [self.pickdImageView setFrame:CGRectMake(0, 0, _scrlImgView.frame.size.width, _scrlImgView.frame.size.height)];
        _scrlImgView.contentSize = self.pickdImageView.frame.size;
       // [_scrlImgView setContentOffset:CGPointZero];
    
    NSLog(@"Img Frame -  %@", NSStringFromCGSize(self.pickdImageView.frame.size));
    NSLog(@"Scroll Frame -  %@", NSStringFromCGSize(_scrlImgView.frame.size));
    NSLog(@"Scroll Content Size -  %@", NSStringFromCGSize(_scrlImgView.contentSize));
    NSLog(@"Scroll Content Offset -  %@", NSStringFromCGPoint(_scrlImgView.contentOffset));
    
        float xposInset,yposInset,btnWidth;
        
         if([aryHotspotComments count] && self.source == FROM_PUBLISHER)
        {
            btnWidth = self.view.frame.size.width/7;
            btnHotspotComment.hidden = NO;
            xposInset = (btnWidth - 20)/2;
            yposInset = (btnHotspotComment.frame.size.height - 15)/2;
            //22.5
            NSLog(@"xpos :%f ypos:%f",xposInset,yposInset);
            
            btnHotspotComment.imageEdgeInsets =  UIEdgeInsetsMake(-yposInset, -xposInset, -yposInset, -xposInset);
            
            NSLog(@"width%f",hotSpotEditToolView.frame.size.width -40);
            
            [btnHotspotComment setFrame:CGRectMake(510, yposInset+11, btnWidth-50, 27)];
           
            
            NSLog(@"frame button:%@",btnHotspotComment);
        }

        isOrientationChanged = NO;

        NSLog(@"<<<<<<<<<<<Ratio2>>>>>>>>>>>>");
         if(self.pickedImage != nil)
        [self calculateAspectRatioOfImage];
        
        if([arrHotspots count])
        {
            [self refreshHotspotsPositionInOrientation];
        }
        
        if([arrQuestions count])
        {
            [self refreshQuestionsPositionInOrientation];

        }

    }
    else
    {
        isOrientationChanged = NO;
    }

    [self adjustTopMenuInOrientation];
    
    [self calculateAndSetDescriptionHeight:_descriptionTxtView.text];


}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
   
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
       [self updateViewConstraints];
}

-(void)adjustBottomFrames
{
    
    NSLog(@"adjust - %@", NSStringFromCGSize(self.view.frame.size));

    if(APP_DELEGATE.isPortrait)
    {
        NSLog(@"adjust portrait");
        portraitWidth = self.view.frame.size.width;
        LandScapeWidth = self.view.frame.size.height;
    }
    else
    {
        NSLog(@"adjust Landscape");

        LandScapeWidth = self.view.frame.size.width;
        portraitWidth = self.view.frame.size.height;
    }
}

#pragma mark Calculating Image Size
-(void)calculateAspectRatioOfImage
{
    
    //Here we are calculating the actual image area occupying and adding an UIView over the scrollVIew to add Hotspots.
    
    float aspectRatio = 1.0;
    
    CGSize imageOriginalSize = self.pickdImageView.image.size;
    
    CGSize imageViewSize = self.pickdImageView.frame.size;
    
    NSLog(@"############### imageViewSize - %@", NSStringFromCGSize(imageViewSize));
    
    CGSize finalImageSize;
    
    float xRatio =  imageOriginalSize.width / imageViewSize.width ;
    
    float yRatio = imageOriginalSize.height / imageViewSize.height;
    
    aspectRatio = MIN(xRatio, yRatio);
    
    if(xRatio >= yRatio)
    {
        finalImageSize.width = imageViewSize.width;
        
        finalImageSize.height = imageOriginalSize.height * (imageViewSize.width / imageOriginalSize.width);
    }
    else
    {
        finalImageSize.height = imageViewSize.height;
        
         finalImageSize.width = imageOriginalSize.width * (imageViewSize.height / imageOriginalSize.height);
    }
    
    
    NSLog(@"imageOriginalSize - %@", NSStringFromCGSize(imageOriginalSize));
    NSLog(@"finalImageSize - %@", NSStringFromCGSize(finalImageSize));
    NSLog(@"Aspect image Size - %@", NSStringFromCGSize(self.pickdImageView.image.size));
    
       
    if(!imageExactSubView.superview)
    {
    ImageOccupyView *aView = [[ImageOccupyView alloc] init];
    
    [aView setFrame:CGRectMake(0, 0, finalImageSize.width, finalImageSize.height)];
    
    [aView setBackgroundColor:[UIColor clearColor]];
    
    aView.tag = 111111;
        
    aView.center = self.pickdImageView.center;
    
        [_scrlImgView addSubview:aView];

    imageExactSubView = aView;
    }
    else
    {
        [imageExactSubView setFrame:CGRectMake(0, 0, finalImageSize.width, finalImageSize.height)];
        imageExactSubView.center = self.pickdImageView.center;


    }

       

    aspectFitSize = finalImageSize;
    
    //imageBounds = CGRectMake((_scrlImgView.frame.size.width - finalImageSize.width)/2, (_scrlImgView.frame.size.height - finalImageSize.height)/2, finalImageSize.width, finalImageSize.height);
    
    imageBounds = CGSizeMake(finalImageSize.width, finalImageSize.height);
    
    //Here we are calculating the image occupying area in both Orientations Portrait and Landscape. Base on these sizes we are repositioning hotspots to their relative positions when device is rotated.
    
    if(APP_DELEGATE.isPortrait)
    {
        imgBoundsAtNormalZoomInPortrait = CGSizeMake(finalImageSize.width, finalImageSize.height);
        
    }
    else
    {
        imgBoundsAtNormalZoomInLandScape = CGSizeMake(finalImageSize.width, finalImageSize.height);
    }
    
    
    NSLog(@"Bounds Size - %@, Portrait -%@, Landscape - %@",NSStringFromCGSize(imageBounds), NSStringFromCGSize(imgBoundsAtNormalZoomInPortrait), NSStringFromCGSize(imgBoundsAtNormalZoomInLandScape));
    preImageViewSize = pickdImageView.frame.size;
    
    
    //[imageExactSubView setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:0.6]];
    
    
    NSLog(@"###scrollView Centre - %@", NSStringFromCGPoint(_scrlImgView.center));


    
    [_scrlImgView setContentSize:_scrlImgView.frame.size];
   // self.pickdImageView.frame = CGRectMake(0, 0, _scrlImgView.Contentsize.width, _scrlImgView.Contentsize.height);
     self.pickdImageView.frame = CGRectMake(0, 0, _scrlImgView.frame.size.width, _scrlImgView.frame.size.height);

    imageExactSubView.center = self.pickdImageView.center;

    
    

    
}

-(CGRect)getVisibleImageRect
{
    
    CGRect visibleRect;
    
    
    visibleRect = _scrlImgView.frame;
    
    
    
    NSLog(@"visibleRect x, y - %f, %f", visibleRect.origin.x, visibleRect.origin.y);
    
   /* float visibleScale = 1.0/ _scrlImgView.zoomScale;
    
    visibleRect.origin.x *=  visibleScale;
    
    visibleRect.origin.y *=  visibleScale;
    
    visibleRect.size.width *= visibleScale;
    
    visibleRect.size.height *= visibleScale;
    
    NSLog(@"visibleRect1 x, y - %f, %f", visibleRect.origin.x, visibleRect.origin.y);*/
    
    //  visibleRect = CGRectMake(visibleRect.origin.x + 10, visibleRect.origin.y + 10, visibleRect.size.width - 20, visibleRect.size.height - 20);
    
    
    
    
    CGRect imageFrame = imageExactSubView.frame;
    
    if(imageExactSubView.frame.origin.x < 0)
        imageFrame.origin.x = 0;
    
    if(imageExactSubView.frame.origin.y < 0)
        imageFrame.origin.y = 0;

    
    NSLog(@"visibleRect - %@", NSStringFromCGRect(visibleRect));
    NSLog(@"imageExactSubView - %@", NSStringFromCGRect(imageExactSubView.frame));

    
    CGRect frame = CGRectIntersection(visibleRect, imageExactSubView.frame);
    NSLog(@"frame - %@", NSStringFromCGRect(frame));
    
    
    return frame;
}

-(CGRect)getVisibleImageRect1
{
    
    
    CGRect visibleRect = [_scrlImgView convertRect:_scrlImgView.bounds toView:imageExactSubView];

    return visibleRect;
    
    
    //CGRect visibleRect;
    visibleRect.origin = _scrlImgView.contentOffset;
    visibleRect.size = _scrlImgView.bounds.size;
    
    float theScale = _scrlImgView.zoomScale;
    visibleRect.origin.x *= theScale;
    visibleRect.origin.y *= theScale;
    visibleRect.size.width *= theScale;
    visibleRect.size.height *= theScale;
    NSLog(@"visibleRect1 x, y - %f, %f", visibleRect.origin.x, visibleRect.origin.y);
    //  visibleRect = CGRectMake(visibleRect.origin.x + 10, visibleRect.origin.y + 10, visibleRect.size.width - 20, visibleRect.size.height - 20);
    
    return visibleRect;
    
    NSLog(@"==============================");
    NSLog(@"GreenView - %@", NSStringFromCGRect(imageExactSubView.frame));
    NSLog(@"visibleRect - %@", NSStringFromCGRect(visibleRect));
    
    CGRect frame = CGRectIntersection(visibleRect, imageExactSubView.frame);
    NSLog(@"frame - %@", NSStringFromCGRect(frame));
    
    //frame = CGRectMake(frame.origin.x + 5, frame.origin.y + 5, frame.size.width - 10, frame.size.height - 10);
    
    return frame;
}

-(void)calculatePositionCoordinatesOfSelectedHotSpotToPoint:(CGPoint)point
{
    
    //Here we are calculating the centre coordinates of hotspot for image's normal zoom level and setting the properties of Orientaion and centre of hotspot at the time of adding to image.
    
    CGPoint pointWRTNormalSize;
    CGSize normalBounds;
    if(APP_DELEGATE.isPortrait)
    {
        normalBounds = imgBoundsAtNormalZoomInPortrait;
        [hsCircleView setOrientationToPortrait];
    }
    else
    {
        normalBounds = imgBoundsAtNormalZoomInLandScape;
        [hsCircleView setOrientationToLandscape];
    }
    
    pointWRTNormalSize.x = (normalBounds.width/imageBounds.width) * point.x;
    pointWRTNormalSize.y = (normalBounds.height/imageBounds.height) * point.y;

    CGPoint defaultCenter = [self getCentreWRTImageSize:pointWRTNormalSize];
    NSLog(@"Setting default center : %@",NSStringFromCGPoint(defaultCenter));
    [hsCircleView setDefaultCentre:defaultCenter];
    //hsCircleView.addedInZoomScale = ceil(_scrlImgView.zoomScale);
    hsCircleView.addedInZoomScale = _scrlImgView.zoomScale;

}

-(CGPoint)getCentreWRTImageSize:(CGPoint)currentCentre
{
    CGSize imageOriginalSize = self.pickedImage.size;
    
    CGSize normalSize;
    
    if(APP_DELEGATE.isPortrait)
    {
        NSLog(@"----Hotspot added in Portrait");
        normalSize = imgBoundsAtNormalZoomInPortrait;
    }
    else
    {
        NSLog(@"----Hotspot added in Landscape");
        
        normalSize = imgBoundsAtNormalZoomInLandScape;
        
    }
    NSLog(@"normalSize - %@", NSStringFromCGSize(normalSize));
    
   float imgOriginalWidth = normalSize.width;
   float imgOriginalHeight = normalSize.height;
    
    //defaultCentre = [hotspot getDefaultCentre];
    
    
      //  NSLog(@">>Default Centre - %@", NSStringFromCGPoint(defaultCentre));
    
    CGPoint newCentre;
    newCentre.x = (self.pickedImage.size.width/imgOriginalWidth) * currentCentre.x ;
    newCentre.y = (self.pickedImage.size.height/imgOriginalHeight) * currentCentre.y;
    NSLog(@"ImageCenter>>3New Centre - %@", NSStringFromCGPoint(newCentre));
    
    return newCentre;

}

#pragma mark PanGesture
-(void)handlePanGesture:(id)sender
{
    NSLog(@"Hotspot Touch in zoom Level - %f", _scrlImgView.zoomScale);

   //This method will get call when the user tries to drag or move an hotspot on the image. Repositioning the hotspot as user dragged within the bounds of image.
    
    NSLog(@"...%d",self.source);
    
    if(self.source ==  FROM_CONSUMER)
    {
        hsQuestionView = (questionView*)[sender view];
    }
    else if (self.source == FROM_NEWPOST)
    {
        hsCircleView = (hotSpotCircleView*)[sender view];
    }
    else
    {
        
    }

    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:imageExactSubView];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        firstX = [[sender view] center].x;
        firstY = [[sender view] center].y;
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
    NSLog(@"imageBounds - %@", NSStringFromCGSize(imageBounds));
    NSLog(@"translatedPoint - %@", NSStringFromCGPoint(translatedPoint));
    
    if((translatedPoint.x > 0 && translatedPoint.x < imageExactSubView.frame.size.width) && (translatedPoint.y > 0 && translatedPoint.y < imageExactSubView.frame.size.height))
    {
        if(self.source ==  FROM_CONSUMER)
        {
            [hsQuestionView setCenter:translatedPoint];
            [self calculatePositionCoordinatesOfSelectedQuestionToPoint:translatedPoint];
            hsQuestionView.isModified = YES;
        }
        else if (self.source == FROM_NEWPOST)
        {
            [hsCircleView setCenter:translatedPoint];
            [self calculatePositionCoordinatesOfSelectedHotSpotToPoint:translatedPoint];
            hsCircleView.isModified = YES;
        }
        else
        {
            [_cropView setCenter:translatedPoint];
            [self calculatePositionCoordinatesOfCropViewToPoint:translatedPoint];
        }
    }
  }

-(void)handleCropViewPanGesture:(id)sender
{
    NSLog(@"CropHandlePan");
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:imageExactSubView];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        
        //isZoomLocked = YES;
        //[self disableScroll];
        
        firstX = [[sender view] center].x;
        firstY = [[sender view] center].y;
        
    }else if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded)
    {
        //isZoomLocked = NO;
        //[self enableScroll];
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    
    NSLog(@"imageBounds - %@", NSStringFromCGSize(imageBounds));
    NSLog(@"translatedPoint - %@", NSStringFromCGPoint(translatedPoint));
    
    if((translatedPoint.x > 0 && translatedPoint.x < imageExactSubView.frame.size.width) && (translatedPoint.y > 0 && translatedPoint.y < imageExactSubView.frame.size.height))
    {
        [self calculatePositionCoordinatesOfCropViewToPoint:translatedPoint];
        [_cropView setCenter:translatedPoint];
    }
 
}

-(void)hotSpotTap:(id)sender
{
    //Selecting an hotspot event make a call to here to show the hotspot menu and hide the regular menu.
    
    //if snip functionality is already performing, then stopping to edit hotspots.
    if(_cropView.superview)
        return;
    
    hsCircleView = (hotSpotCircleView*)[sender view];
    NSLog(@"Tag - %@, %li", hsCircleView.strHotspotId, (long)[sender view].tag);
    
    NSLog(@"audiofilename:%@",hsCircleView.strAudioFileName);
    NSLog(@"Label - %@", hsCircleView.strLabel);
    
    hsQuestionView = nil;
   
    if(self.source == FROM_CONSUMER)
    {
        
        hotspotConsumerView.hidden = NO;
        [self loadConsumerHSEditToolView];
        isHotSpotTapped = YES;
        hotSpotLabelView.hidden = YES;
        hotSpotAudioView.hidden = YES;

        if(_scrlImgView.zoomScale != (float)hsCircleView.addedInZoomScale)
        {
            [_scrlImgView setZoomScale:(float)hsCircleView.addedInZoomScale animated:YES];
            [self refreshImageWithHotspots];
        }
    
        [self zoomAndCentreToView:hsCircleView];
        if(isZoomLocked)
        {
            //Disabling zoom lock
            UIButton *zoomLockBtn = (UIButton*)[self.view viewWithTag:3333];
            [self disableZoomClicked:zoomLockBtn];
        }

        if([_descriptionTxtView.text isEqualToString:@""]|| _descriptionTxtView.text.length == 0)
            _lblPlaceHolder.hidden = NO;
        else
            _lblPlaceHolder.hidden = YES;
        
        NSLog(@"HS Description - %@", hsCircleView.strDescText);
        
        [self setDescriptionText:hsCircleView.strDescText];
        _hotspotUrlTextField.text = hsCircleView.strUrlText;
        
        
        return;

    }
    
    if(self.source == FROM_PUBLISHER)
    {
        isHotSpotTapped = YES;
        hotspotConsumerView.hidden = YES;
        hotSpotAudioView.hidden = YES;
    }
    //hotSpotEditToolView.hidden = NO;
    [self showHotspotEditTool];
    hotSpotLabelView.hidden = NO;
    
    _hotspotTitle.text =  hsCircleView.strLabel ;
    
    if(_hotspotTitle.text.length == 0)
       [_lablePlaceHolder setHidden:NO];
    else
        [_lablePlaceHolder setHidden:YES];
    
    NSLog(@"HS Description1 - %@", hsCircleView.strDescText);

    [self setDescriptionText:hsCircleView.strDescText];
    _hotspotUrlTextField.text = hsCircleView.strUrlText;
    

    NSLog(@"hsCircleView.strDescText.length - %lu", (unsigned long)hsCircleView.strDescText.length);
    
    if([_descriptionTxtView.text isEqualToString:@""]|| _descriptionTxtView.text.length == 0)
        _lblPlaceHolder.hidden = NO;
    else
        _lblPlaceHolder.hidden = YES;
    
    [self hideKeyboard];
    if([hsCircleView.strAudioFileName length] > 0)
    {
        [self.btnRecord setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
        self.btnDelete.hidden = NO;
        isRecorded = YES;

    }
    else
    {
        [self.btnRecord setImage:[UIImage imageNamed:@"Record.png"] forState:UIControlStateNormal];
        isRecorded = NO;
        self.btnDelete.hidden = YES;

        
        [audioRecorder stop];

        if (audioPlayer) [audioPlayer stop];
        
        if(sliderTimer != nil)
        {
            [sliderTimer invalidate];
            sliderTimer = nil;
        }
        self.sliderAudio.value=0.0;


    }
    
    NSLog(@">>>zoom378 - %f", (float)hsCircleView.addedInZoomScale);

    NSLog(@"scrollview zoom - %f to %f", _scrlImgView.zoomScale, (float)hsCircleView.addedInZoomScale);
    
    if(hsCircleView.isInZoomedState)
    {
        hsCircleView.isInZoomedState = NO;
        [_scrlImgView setZoomScale:_scrlImgView.minimumZoomScale animated:YES];

    }
    else
    {
        hsCircleView.isInZoomedState = YES;

    if(_scrlImgView.zoomScale != (float)hsCircleView.addedInZoomScale)
    {
        [_scrlImgView setZoomScale:(float)hsCircleView.addedInZoomScale animated:YES];
        
        [self refreshImageWithHotspots];
    }
    }
    [self zoomAndCentreToView:hsCircleView];

    
    //[_scrlImgView scrollRectToVisible:hsCircleView.frame animated:YES];
    //[_scrlImgView setContentOffset:CGPointMake(hsCircleView.center.x - (_scrlImgView.frame.size.width/2), hsCircleView.center.y - (_scrlImgView.frame.size.height/2))];

    
    if(isZoomLocked)
    {
        //Disabling zoom lock
        UIButton *zoomLockBtn = (UIButton*)[self.view viewWithTag:3333];
        [self disableZoomClicked:zoomLockBtn];
    }

   

}

-(void)zoomAndCentreToView:(hotSpotCircleView*)hsCircle
{
    
    NSLog(@"_scrlView sizes - %@, %@", NSStringFromCGSize(_scrlImgView.frame.size), NSStringFromCGSize(_scrlImgView.contentSize));
   if(_scrlImgView.contentSize.width <= _scrlImgView.frame.size.width && _scrlImgView.contentSize.height <= _scrlImgView.frame.size.height)
   {
       NSLog(@"HS not centred");
       return;
   }
    
    if((hsCircle.center.x > (_scrlImgView.contentSize.width - (_scrlImgView.frame.size.width/2))) && (hsCircle.center.y > (_scrlImgView.contentSize.height - (_scrlImgView.frame.size.height/2))))
    {
        [_scrlImgView scrollRectToVisible:hsCircle.frame animated:YES];

    }
    else if ((hsCircle.center.x > (_scrlImgView.contentSize.width - (_scrlImgView.frame.size.width/2))))
    {
        [_scrlImgView setContentOffset:CGPointMake(_scrlImgView.contentSize.width - _scrlImgView.frame.size.width, hsCircle.center.y - (_scrlImgView.frame.size.height/2))];

    }
    else if (hsCircle.center.y > (_scrlImgView.contentSize.height - (_scrlImgView.frame.size.height/2)))
    {
        [_scrlImgView setContentOffset:CGPointMake(hsCircle.center.x - (_scrlImgView.frame.size.width/2), _scrlImgView.contentSize.height - _scrlImgView.frame.size.height)];

    }
    else if ((hsCircle.center.x < _scrlImgView.frame.size.width/2) && (hsCircle.center.y < _scrlImgView.frame.size.height/2))
    {
        [_scrlImgView scrollRectToVisible:hsCircle.frame animated:YES];

    }
    else if ((hsCircle.center.x < _scrlImgView.frame.size.width/2))
    {
        [_scrlImgView setContentOffset:CGPointMake(0.0, hsCircle.center.y - (_scrlImgView.frame.size.height/2))];
        
    }
    else if (hsCircle.center.y < _scrlImgView.frame.size.height/2)
    {
        [_scrlImgView setContentOffset:CGPointMake(hsCircle.center.x - (_scrlImgView.frame.size.width/2), 0.0)];
        
    }
    else
    {
        [_scrlImgView setContentOffset:CGPointMake(hsCircle.center.x - (_scrlImgView.frame.size.width/2), hsCircle.center.y - (_scrlImgView.frame.size.height/2))];
    }
    
//    int x=0, y=0;
//    
//    hsCircle.frame.origin.x = x;
//    hsCircle.frame.y = y;
//    [_scrlImgView scrollRectToVisible:hsCircle.frame animated:YES];
//    
//    


}

-(void)zoomAndCentreQuestionView:(questionView*)hsQuestion
{
    
    NSLog(@"_scrlView sizes - %@, %@", NSStringFromCGSize(_scrlImgView.frame.size), NSStringFromCGSize(_scrlImgView.contentSize));
    if(_scrlImgView.contentSize.width <= _scrlImgView.frame.size.width && _scrlImgView.contentSize.height <= _scrlImgView.frame.size.height)
    {
        NSLog(@"HS not centred");
        return;
    }
    
    if((hsQuestion.center.x > (_scrlImgView.contentSize.width - (_scrlImgView.frame.size.width/2))) && (hsQuestion.center.y > (_scrlImgView.contentSize.height - (_scrlImgView.frame.size.height/2))))
    {
        [_scrlImgView scrollRectToVisible:hsQuestion.frame animated:YES];
        
    }
    else if ((hsQuestion.center.x > (_scrlImgView.contentSize.width - (_scrlImgView.frame.size.width/2))))
    {
        [_scrlImgView setContentOffset:CGPointMake(_scrlImgView.contentSize.width - _scrlImgView.frame.size.width, hsQuestion.center.y - (_scrlImgView.frame.size.height/2))];
        
    }
    else if (hsQuestion.center.y > (_scrlImgView.contentSize.height - (_scrlImgView.frame.size.height/2)))
    {
        [_scrlImgView setContentOffset:CGPointMake(hsQuestion.center.x - (_scrlImgView.frame.size.width/2), _scrlImgView.contentSize.height - _scrlImgView.frame.size.height)];
        
    }
    else if ((hsQuestion.center.x < _scrlImgView.frame.size.width/2) && (hsQuestion.center.y < _scrlImgView.frame.size.height/2))
    {
        [_scrlImgView scrollRectToVisible:hsQuestion.frame animated:YES];
        
    }
    else if ((hsQuestion.center.x < _scrlImgView.frame.size.width/2))
    {
        [_scrlImgView setContentOffset:CGPointMake(0.0, hsQuestion.center.y - (_scrlImgView.frame.size.height/2))];
        
    }
    else if (hsQuestion.center.y < _scrlImgView.frame.size.height/2)
    {
        [_scrlImgView setContentOffset:CGPointMake(hsQuestion.center.x - (_scrlImgView.frame.size.width/2), 0.0)];
        
    }
    else
    {
        [_scrlImgView setContentOffset:CGPointMake(hsQuestion.center.x - (_scrlImgView.frame.size.width/2), hsQuestion.center.y - (_scrlImgView.frame.size.height/2))];
    }
    
    
    
}

#pragma mark UITextView Delegate Methods
//These are the textView delegate methods of textview placed for description of hotspot.

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if(self.source == FROM_CONSUMER && [hsCircleView.strDescText length] >0 && isHotSpotTapped)
    {
        return NO;
    }
    [_lblPlaceHolder setHidden:YES];
    
    return YES;
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(textView.text.length)
    lastChar = [textView.text substringFromIndex:textView.text.length - 1];
    
    strTxt = text;
    
    NSLog(@"strtxt - %@", strTxt);
    float constraintFactor = 10;
    if([strTxt isEqualToString:@"\n"])
    {
        NSLog(@"New Line");
        if(_HotSpotTxtViewHeight.constant < 80)
        {
            _HotSpotTxtViewHeight.constant += constraintFactor;
            textView.contentOffset = CGPointZero;
            
        }
    }
    else if(strTxt.length == 0)
    {
        //backspace clicked.
        
        NSLog(@"last character - %@", lastChar);
        
        if([lastChar isEqualToString:@"\n"])
        {
            
            if(_HotSpotTxtViewHeight.constant > 41)
            {
                NSLog(@"Not New Line");
                
                _HotSpotTxtViewHeight.constant -= constraintFactor;
            }
        }
        
        
    }
    // _HotSpotTxtViewHeight.constant = textView.contentSize.height;
    
    NSLog(@"TextView Frame - %@, %@", NSStringFromCGRect(_descriptionTxtView.frame), NSStringFromCGRect(hotSpotTextView.frame));
    
    descriptionTextHeightConstant = _HotSpotTxtViewHeight.constant;
    
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
   
               return YES;
    }
    else if(textView.text.length < 250)
    {
        NSLog(@"entered - %@", strTxt);
    return YES;
    }
   
    else
        return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    //Here raising the height of textview dynamically as the text of description increases.
    // NSLog(@"content height - %@", NSStringFromCGSize(textView.contentSize));
}

-(void)setDescriptionText:(NSString*)strDescription
{
    _descriptionTxtView.text = strDescription;
    [self calculateAndSetDescriptionHeight:strDescription];
}

-(void)calculateAndSetDescriptionHeight:(NSString*)strDesc
{
    CGSize fontSize = [strDesc sizeWithFont:_descriptionTxtView.font constrainedToSize:CGSizeMake(_descriptionTxtView.frame.size.width, 80)];
    
    descriptionTextHeightConstant = fontSize.height;
    
    if(descriptionTextHeightConstant <= 80)
    {
        if(descriptionTextHeightConstant >= _HotSpotTxtViewHeight.constant)
        {
            _HotSpotTxtViewHeight.constant = descriptionTextHeightConstant;
            _descriptionTxtView.contentOffset = CGPointZero;
        }
        
    }
    else
    {
        _HotSpotTxtViewHeight.constant = descriptionTextHeightConstant;
        _descriptionTxtView.contentOffset = CGPointZero;
        
    }
    
    
    if([strDesc isEqualToString:@""]|| strDesc.length == 0)
        _lblPlaceHolder.hidden = NO;
    else
        _lblPlaceHolder.hidden = YES;
    
}

#pragma mark TextField Delegates
//These are the TextField delegate methods for hotspot name textfield.
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.source == FROM_CONSUMER  && isHotSpotTapped)
    {
        if(textField == _hotspotTitle && [hsCircleView.strDescText length]>0)
        {
            return NO;
        }
         if(textField == _hotspotUrlTextField && [hsCircleView.strUrlText length] >0)
         {
             // url navigation
             [self navigatewithURL:textField.text];
             return NO;
         }
    }
    //When the user wants to edit textfield, jsut clearing the text like Label in textfield.
    if(textField == _hotspotTitle && [hsCircleView.strLabel isEqualToString:@""])
    {
        textField.text = @"";
    }
    txtFld = textField;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidEndEditing");

}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSLog(@"string - %@,%li", string, (unsigned long)string.length);
    
    if(textField == _hotspotTitle && [string isEqualToString:@""] && string.length == 0)
    {
        //if it is backspace.
        if(textField.text.length == 1 && string.length == 0)
            [_lablePlaceHolder setHidden:NO];
        [hsCircleView updateTitle:[textField.text substringToIndex:textField.text.length-1]];
        return YES;
    }
    
    if(textField == _hotspotTitle)
    {
        
        if(textField.text.length == 0 && string.length > 0)
           [_lablePlaceHolder setHidden:YES];
        else if(textField.text.length == 1 && string.length == 0)
            [_lablePlaceHolder setHidden:NO];
        else
            [_lablePlaceHolder setHidden:YES];
        
    NSString *strText = [NSString stringWithFormat:@"%@%@",textField.text, string];
     
        

    if(strText.length <= 15)
    {

        if(strText.length == 1 && string.length == 0)
        {
            NSLog(@"length is 1");
            [hsCircleView updateTitle:@""];
            return YES;
        }
        else
        {
           [hsCircleView updateTitle:strText];
           return YES;
        }
    }
    else
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField             // called when 'return' key pressed. return NO to ignore.
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark KeyBoard Notification calls
-(void)keyboardDidShow:(NSNotification*)notification
{
    //When keyboard appeared, we are moving the screen towards top.
    
    NSLog(@"keyboardDidShow - %@", [notification.userInfo description]);
    

    CGFloat height;
    
    CGRect keyBoardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if(APP_DELEGATE.isPortrait)
    height = keyBoardRect.size.height;
    else
        height = keyBoardRect.size.height;

    
    NSLog(@"height - %f", height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.view.center = CGPointMake(self.view.center.x, ((keyBoardRect.origin.y + keyBoardRect.size.height) / 2) - height);
    
   /* hotSpotEditToolView.center = CGPointMake(hotSpotEditToolView.center.x, hotSpotEditToolView.center.y - height);
    hotSpotLabelView.center = CGPointMake(hotSpotLabelView.center.x,  hotSpotLabelView.center.y - height);
    hotSpotColorView.center = CGPointMake(hotSpotColorView.center.x,  hotSpotColorView.center.y - height);
    hotSpotTextView.center = CGPointMake(hotSpotTextView.center.x,  hotSpotTextView.center.y - height);
    hotSpotLinkView.center = CGPointMake(hotSpotLinkView.center.x,  hotSpotLinkView.center.y - height);
    _hsToolBtnConstraint.constant = height;


   /* hotSpotColorView.center = CGPointMake(hotSpotColorView.center.x, ((keyBoardRect.origin.y + keyBoardRect.size.height) / 2) - height);
    hotSpotTextView.center = CGPointMake(hotSpotTextView.center.x, ((keyBoardRect.origin.y + keyBoardRect.size.height) / 2) - height);
    hotSpotLinkView.center = CGPointMake(hotSpotLinkView.center.x, ((keyBoardRect.origin.y + keyBoardRect.size.height) / 2) - height);
    hotSpotAudioView.center = CGPointMake(hotSpotAudioView.center.x, ((keyBoardRect.origin.y + keyBoardRect.size.height) / 2) - height);*/


    [UIView commitAnimations];
    
    isKeyBoardAppeared = YES;
    
}

-(void)keyboardFrameChanged:(NSNotification*)notification
{
    NSLog(@"keyboardFrameChanged");
    //self.view.center = originalViewCentre;
}

-(void)appEntersIntoBackground
{
    [txtFld resignFirstResponder];
    [_descriptionTxtView resignFirstResponder];
}

-(void)keyboardWillBeHidden:(NSNotification*)notification
{
    //When keyboard will be hidden, resetting the frames.

    
    NSLog(@"keyboardWillBeHidden");
    NSLog(@"keyboardWillBeHidden - %@", [notification.userInfo description]);

    [_lblPlaceHolder setHidden:YES];

    CGFloat height;
    height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    NSLog(@"height - %f", height);
    if(isKeyBoardAppeared)
    {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    self.view.center = CGPointMake(self.view.center.x, self.view.center.y + height);
        
       /* hotSpotEditToolView.center = CGPointMake(hotSpotEditToolView.center.x,  hotSpotEditToolView.center.y + height);
        hotSpotLabelView.center = CGPointMake(hotSpotLabelView.center.x,  hotSpotLabelView.center.y + height);
        hotSpotColorView.center = CGPointMake(hotSpotColorView.center.x,  hotSpotColorView.center.y + height);
        hotSpotTextView.center = CGPointMake(hotSpotTextView.center.x,  hotSpotTextView.center.y + height);
        hotSpotLinkView.center = CGPointMake(hotSpotLinkView.center.x,  hotSpotLinkView.center.y + height);
        hotSpotAudioView.center = CGPointMake(hotSpotAudioView.center.x,  hotSpotAudioView.center.y + height);
        
        _hsToolBtnConstraint.constant = 0.0;*/

    [UIView commitAnimations];
    }


    isKeyBoardAppeared = NO;
    ///Checking whether any hotspot information is modified...
    [self updateSelectedHotSpotDetails];
    

    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        UIDeviceOrientation deviceOrientation;
        switch ([[[UIDevice currentDevice] valueForKey:@"orientation"] integerValue]) {
            case UIInterfaceOrientationLandscapeLeft:
                deviceOrientation=UIDeviceOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationLandscapeRight:
                deviceOrientation=UIDeviceOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationPortrait:
                deviceOrientation=UIDeviceOrientationPortrait;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                deviceOrientation=UIDeviceOrientationPortraitUpsideDown;
                break;
            default: deviceOrientation=UIDeviceOrientationUnknown;
                break;
        }
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:deviceOrientation] forKey:@"orientation"];
    }

    
    
}

-(void)hideKeyboard
{
    [_hotspotTitle resignFirstResponder];
    [_descriptionTxtView resignFirstResponder];
    [_hotspotUrlTextField resignFirstResponder];
}

#pragma mark Touches

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    return [super initWithCoder:aDecoder];
}

#pragma mark - HotSpot Regular Menu Button Actions
#pragma - =================================


-(IBAction)saveClicked:(id)sender
{
    //This method will get executed when user wants to save the hotspots. 
    [txtFld resignFirstResponder];
    
    if(self.source == FROM_CONSUMER)
    {
        if(isHotSpotTapped)
        {
            hotSpotEditToolView.hidden = YES;

            [self hotSpotAudioClicked:nil];
            return;
        }
        
        //update clicked in consumer view
        
        if(![arrQuestions count])
        {
            
            return;
        }
            
        if([self connected])
        {
            [self uploadQuestionAudioFiles];
            return;
        }
        else
        {
            [self showNoInternetMessage];
            return;
        }
       
    }

    if(self.source == FROM_PUBLISHER )
    {
        NSLog(@"Pod Id - %@", self.strPodId);
        
        //UPDATE Clicked from publisher
        [self checkWhetherPublisherAddedOrUpdatedHs];
        [self updateHotspotsInLocalDB];
        isPublisherUpdate = YES;
        
        // delete changed questions(from question to HS)

        if([self connected])
        {
            if([aryConvertedQuestions count])
            {
                [self deletePublisherQuestions];
            }
            else
            {
                [self showNoInternetMessage];
                return;
            }
            
        }
        else
            [self navigateToPostViewController];
        return;
    }
    
    if(!self.selectedImgId.length)
        [self saveImagetoDBWithLocalPath:self.strImagePath WithImageName:[self.strImagePath lastPathComponent]];
    
    if([arrHotspots count]==0)
    {
        return;
    }
    else
    {
        if(!self.isPodExisting)
        [self savePodDataToDB];

    }
  
    for(hotSpotCircleView *hsCircleViewObj in arrHotspots)
    {
        if([hsCircleViewObj.strUrlText length] > 0)
        {
            BOOL isvalid = [self  checkForvalidationwithURL:hsCircleViewObj.strUrlText];
            if(isvalid == NO)
            {
                [self showTheAlert:@"Please enter valid url"];
                return;
            }
            NSLog(@"%i",isvalid);
        }
    }
    
    for(hotSpotCircleView *hsCircleViewObject in arrHotspots)
    {
        if(hsCircleViewObject.isSaved == NO || hsCircleViewObject.isModified == YES)
        {
            isHospotSavedinDB = [self saveOrUpdateHotspotwithObj:hsCircleViewObject];
        }
    }
    
    if(isHospotSavedinDB == YES)
    {
        if(self.source == FROM_PUBLISHER)
            [self showTheAlert:@"Changes Updated Successfully"];
        else
        [self showTheAlert:@"Hotspots are saved successfully"];
    }
    
   
}

-(void)checkWhetherPublisherAddedOrUpdatedHs
{
    int i = 0, j = 0, k=0;
    [arrAddedHsIds removeAllObjects];
    [arrUpdatedHsIds removeAllObjects];
    [arrRemainedHsIds removeAllObjects];
    
    NSLog(@"Arr HS Count - %lu", (unsigned long)[arrHotspots count]);

    for(hotSpotCircleView *hsCircleViewObject in arrHotspots)
    {
        NSLog(@"hsCircleViewObject Id - %@", hsCircleViewObject.strHotspotId);
        if(hsCircleViewObject.isSaved == NO)
        {
            //NewlyAdded by publisher.
            
            if(arrAddedHsIds == nil)
                arrAddedHsIds = [[NSMutableArray alloc] init];
            [arrAddedHsIds addObject:hsCircleViewObject.strHotspotId];
            
            i++;
            //isHospotSavedinDB = [self saveOrUpdateHotspotwithObj:hsCircleViewObject];
        }
        else if (hsCircleViewObject.isModified)
        {
            if(arrUpdatedHsIds == nil)
                arrUpdatedHsIds = [[NSMutableArray alloc] init];
            [arrUpdatedHsIds addObject:hsCircleViewObject.strHotspotId];

            j++;
        }
        else
        {
            if(arrRemainedHsIds == nil)
                arrRemainedHsIds = [[NSMutableArray alloc] init];
            if([hsCircleViewObject.strHotspotId length] >0)
                [arrRemainedHsIds addObject:hsCircleViewObject.strHotspotId];

            k++;
        }
    }
    
    NSLog(@"Added new count %d", i);
    NSLog(@"Updated count %d", j);
    NSLog(@"undo count %d", k);

   


}

-(void)updateHotspotsInLocalDBBYPublisher
{
    if(![arrHotspots count])
    {
        return;
    }
    
    
    for(hotSpotCircleView *hsCircleViewObject in arrHotspots)
    {
        if(hsCircleViewObject.isSaved == NO || hsCircleViewObject.isModified == YES)
        {
            isHospotSavedinDB = [self saveOrUpdateHotspotwithObj:hsCircleViewObject];
        }
    }
    
    if(isHospotSavedinDB)
        [self showTheAlert:@"Hotspots are saved successfully"];
    
}

-(void)updateHotspotsInLocalDB
{
    if(![arrHotspots count])
    {
        return;
    }
        
        
        for(hotSpotCircleView *hsCircleViewObject in arrHotspots)
        {
            if(hsCircleViewObject.isSaved == NO || hsCircleViewObject.isModified == YES)
            {
                isHospotSavedinDB = [self saveOrUpdateHotspotwithObj:hsCircleViewObject];
            }
        }
    
    if(isHospotSavedinDB == YES)
        [self showTheAlert:@"Hotspots are saved successfully"];

}

-(NSString *)prepareImageWithName:(NSString*)sImgName withID:(NSString*)vImgId
{
    
    //Here we are creating the image name and image id dynamically based on previous images.
    
    NSString *imgId = [[NSUserDefaults standardUserDefaults] objectForKey:vImgId];
    NSString *imgName;
    if (imgId != nil) {
        int num = [imgId intValue] + 1;
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",num] forKey:vImgId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        imgName = [NSString stringWithFormat:@"%@%d.png",sImgName,num];
        hsCircleView.imgId = num;
        return imgName;
    }
    else{
        imgName = [NSString stringWithFormat:@"%@%d.png",sImgName,1];
        hsCircleView.imgId = 1;
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:vImgId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return imgName;
    }
    return imgName;
}

/* Prepare image name */
-(NSString*)prepareImageName
{
    NSString *str = [NSString stringWithFormat:@"rnyi_%@",[Util GetUUID]];
    
    return str;
    
}

-(void)showHotspotEditTool
{
    if(!hotSpotEditToolView.hidden)
        return;

    hotSpotEditToolView.hidden = NO;
    
   
    
    __scrlBtmView.constant = 100;
     _scrlImgView.frame = CGRectMake(_scrlImgView.frame.origin.x, _scrlImgView.frame.origin.y, _scrlImgView.frame.size.width, _scrlImgView.frame.size.height - hotSpotLabelView.frame.size.height);

}

-(void)loadQuestionToolView
{
    float btnWidth = self.view.frame.size.width/5;
    
    float   xposInset = (btnWidth - 20)/2;
    float   yposInset = (_btnAudio.frame.size.height - 15)/2;
    
    _btnAudio.imageEdgeInsets = UIEdgeInsetsMake(-yposInset, -xposInset,-yposInset, -xposInset);
    [_btnAudio setImage:[UIImage imageNamed:@"comment.png"] forState:UIControlStateNormal];
    
    [_btnLink setImage:[UIImage imageNamed:@"hotspotAudio.png"] forState:UIControlStateNormal];
    
    _btnLabel.hidden = YES;
    _btnLink.hidden = NO;
    hotSpotLabelWidthConstraint.constant = 0;
    
    closeWidthConstraint.constant = hotSpotColorWidthConstraint.constant = hotSpotTextWidthConstraint.constant = hotSpotAudioWidthConstraint.constant= hotSpotLinkWidthConstraint.constant = btnWidth;
       
    [_btnAddHotSpot setImage:[UIImage imageNamed:@"hotspotQuestion.png"] forState:UIControlStateNormal];
  
}

-(void)loadNewQuestionToolView
{
   float btnWidth = self.view.frame.size.width/4;
    _btnLabel.hidden = YES;
    _btnLink.hidden = YES;
    hotSpotLabelWidthConstraint.constant = 0;
    hotSpotLinkWidthConstraint.constant = 0;
    closeWidthConstraint.constant = hotSpotColorWidthConstraint.constant = hotSpotTextWidthConstraint.constant = hotSpotAudioWidthConstraint.constant=  btnWidth;
    [_btnAddHotSpot setImage:[UIImage imageNamed:@"hotspotQuestion.png"] forState:UIControlStateNormal];
    
    [_btnAudio setImage:[UIImage imageNamed:@"hotspotAudio.png"] forState:UIControlStateNormal];
}

-(void)loadPublisherQuestionToolView
{
  
    float  btnWidth = self.view.frame.size.width/3;
    
    NSLog(@"Audio - %@, label - %@", hsQuestionView.strAudioUrl, hsQuestionView.strDescText);
    
    float xposInset,yposInset;
    
    if([hsQuestionView.strAudioUrl length] >0 && [hsQuestionView.strDescText length] > 0)
    {
        btnWidth = self.view.frame.size.width/5;
        
        audioXPosConstraint.constant = 0.0;
        descXPOSConstraint.constant = btnWidth;
        linkXPOSConstraint.constant = btnWidth *2;
        rateXPosconstraint.constant = btnWidth *3;
        commentXPosConstraint.constant = btnWidth *4;
       
        xposInset = (btnWidth - 20)/2;
        yposInset = (btnConsumerAudio.frame.size.height - 15)/2;
        btnConsumerAudio.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset, yposInset, xposInset);
        
        yposInset = (btnDescConsumerView.frame.size.height - 15)/2;
        btnDescConsumerView.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset, yposInset, xposInset);
        
        yposInset = (btnLinkConsumerView.frame.size.height - 15)/2;
        btnLinkConsumerView.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset, yposInset, xposInset);
        [btnLinkConsumerView setImage:[UIImage imageNamed:@"hotspotAudio.png"] forState:UIControlStateNormal];
        
        if(!isOrientationChanged)
        {
            xposInset = (btnWidth - 20)/2;
            yposInset = (btnComment.frame.size.height - 15)/2;
            btnComment.imageEdgeInsets = UIEdgeInsetsMake(-yposInset, -xposInset, -yposInset, -xposInset);
        }
        descWidthConstraint.constant = linkWidthConstraint.constant = audioWidthConstraint.constant = rateWidthConstraint.constant = commentWidthConstraint.constant = btnWidth;

    }
    else if([hsQuestionView.strDescText length] >0 && [hsQuestionView.strAudioUrl length] == 0)
    {
         btnWidth = self.view.frame.size.width/4;
        
       
        audioXPosConstraint.constant = 0.0;
        descXPOSConstraint.constant = btnWidth;
        rateXPosconstraint.constant = 2 * btnWidth ;
        commentXPosConstraint.constant = 3 * btnWidth;
        
        linkWidthConstraint.constant = 0;
        btnDescConsumerView.hidden = NO;
        btnLinkConsumerView.hidden = YES;


        float   xposInset = (btnWidth - 20)/2;
        float yposInset = (btnDescConsumerView.frame.size.height - 15)/2;
        btnDescConsumerView.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset, yposInset, xposInset);
        
        yposInset = (btnComment.frame.size.height - 15)/2;
        btnComment.imageEdgeInsets = UIEdgeInsetsMake(-yposInset, -xposInset, -yposInset, -xposInset);
        
        descWidthConstraint.constant = audioWidthConstraint.constant = rateWidthConstraint.constant = commentWidthConstraint.constant = btnWidth;
    }
    else if([hsQuestionView.strDescText length] == 0 && [hsQuestionView.strAudioUrl length] > 0)
    {
        btnWidth = self.view.frame.size.width/4;
        
        
        audioXPosConstraint.constant = 0.0;
        linkXPOSConstraint.constant = btnWidth;
        rateXPosconstraint.constant = 2 * btnWidth ;
        commentXPosConstraint.constant = 3 * btnWidth;
        
        linkWidthConstraint.constant = 0;
        btnConsumerAudio.hidden = NO;
        
        float   xposInset = (btnWidth - 20)/2;
        float yposInset = (btnDescConsumerView.frame.size.height - 15)/2;
        btnConsumerAudio.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset, yposInset, xposInset);
        btnDescConsumerView.hidden = YES;

        yposInset = (btnComment.frame.size.height - 15)/2;
        btnComment.imageEdgeInsets = UIEdgeInsetsMake(-yposInset, -xposInset, -yposInset, -xposInset);
        btnLinkConsumerView.hidden = NO;

        yposInset = (btnLinkConsumerView.frame.size.height - 15)/2;
        btnLinkConsumerView.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset, yposInset, xposInset);
        [btnLinkConsumerView setImage:[UIImage imageNamed:@"hotspotAudio.png"] forState:UIControlStateNormal];
        
        linkWidthConstraint.constant = audioWidthConstraint.constant = rateWidthConstraint.constant = commentWidthConstraint.constant = btnWidth;
    }
    else
    {
        audioXPosConstraint.constant = 0.0;
        rateXPosconstraint.constant = btnWidth;
        commentXPosConstraint.constant = 2*btnWidth;
        btnDescConsumerView.hidden = YES;
     //   [btnDescConsumerView setImage:nil forState:UIControlStateNormal];
        
        btnLinkConsumerView.hidden = YES;

        descWidthConstraint.constant = linkWidthConstraint.constant = 0;
        audioWidthConstraint.constant = rateWidthConstraint.constant = commentWidthConstraint.constant = btnWidth;
    }
    
    
    xposInset = (btnWidth - 20)/2;
    yposInset = (btnConsumerAudio.frame.size.height - 15)/2;
    btnConsumerAudio.imageEdgeInsets = UIEdgeInsetsMake(yposInset, xposInset, yposInset, xposInset);
    
    
    [btnConsumerAudio setImage:nil forState:UIControlStateNormal];
    
    [btnConsumerAudio setTitle:@"X" forState:UIControlStateNormal];
    [btnConsumerAudio setBackgroundColor:[UIColor colorWithRed:247/255.0f green:97/255.0f blue:81/255.0f alpha:0.85f]];
    
    
    [btnRate setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    
    [btnComment setImage:[UIImage imageNamed:@"question-hotspot"] forState:UIControlStateNormal];


}

-(void)hideHotspotEditTool
{
    hotSpotEditToolView.hidden = YES;
    
    //_scrlImgView.frame = CGRectMake(_scrlImgView.frame.origin.x, _scrlImgView.frame.origin.y, _scrlImgView.frame.size.width, _scrlImgView.frame.size.height + hotSpotLabelView.frame.size.height);
    __scrlBtmView.constant = 60;

}

-(IBAction)hotSpotClicked:(id)sender
{
    //this method will get call when user tapped on hotspot button on regular menu.
    
    [self showHotspotEditTool];

    if(self.source == FROM_CONSUMER)
    {
        if(isHotSpotTapped)
        {
 //           hotSpotEditToolView.hidden = YES;
//            self.rateView.hidden = NO;
//            [self loadimagesForRating];
            return;
        }
        
        hotSpotEditToolView.hidden = NO;
        [self addNewQuestion];
        return;
    }
    
        hotSpotEditToolView.hidden = NO;
        hotSpotLabelView.hidden = NO;
        [self addNewHotspot];
 
}

-(void)addNewHotspot
{
    
    //This method will be called when user wants to create a new hotspot on selected Image.
    // Here checking whether the user has already reached the limit of hotspots count(i.e.,9). If he is not adding the new hotspot.
    if([arrHotspots count] >= 10)
    {
        [self showTheAlert:@"No more Hotspot could be added"];
        return;
    }
    
    //Here we are adding new Hotspot on selected image.
    
    hotSpotCircleView *hotSpot = [[hotSpotCircleView alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
    hotSpot.backgroundColor= [UIColor clearColor];
    hotSpot.center = CGPointMake(imageBounds.width/2, imageBounds.height/2);
    [hotSpot addCircleImage];
    [hotSpot setWhiteColor];
    
    if(APP_DELEGATE.isPortrait)
    {
        [hotSpot setOrientationToPortrait];
    }
    else
    {
        [hotSpot setOrientationToLandscape];
    }
    
    if(imageExactSubView == nil)
        NSLog(@"imageExactSubView is nil");
    [imageExactSubView addSubview:hotSpot];
    
    //Here adding pangesture for dragging the Hotspot over the image.
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [hotSpot addGestureRecognizer:panGesture];
    panGesture = nil;
    
    //Adding tapGesture to select the hotspot among all hotspots added to the image.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hotSpotTap:)];
    tap.numberOfTapsRequired = 1;
    [hotSpot addGestureRecognizer:tap];
    
    hotSpot.strHotspotId = [Util GetUUID];
    
    if(isQuestionChangedToHS)
    {
        hotSpot.center = hsQuestionView.center;
        
    }
    else
    {
        CGRect visibleImageRect = [self getVisibleImageRect1];
        
        hotSpot.center = CGPointMake(visibleImageRect.origin.x + (visibleImageRect.size.width/2), visibleImageRect.origin.y + (visibleImageRect.size.height/2));
        
        for(hotSpotCircleView *aHotspot in arrHotspots)
        {
            NSLog(@"aHotspot centre - %@", NSStringFromCGPoint(aHotspot.center));
            NSLog(@" Hotspot centre - %@", NSStringFromCGPoint(aHotspot.center));
            
            if((hotSpot.center.x == aHotspot.center.x) && (hotSpot.center.y == aHotspot.center.y))
            {
                CGPoint centre = hotSpot.center;
                
                centre.x += 5.0;
                
                centre.y += 5.0;
                
                [hotSpot setCenter:centre];
            }
        }
    }
    // float roundedupZoom = ceil([_scrlImgView zoomScale]);
    hotSpot.addedInZoomScale =  [_scrlImgView zoomScale];
    
    [arrHotspots addObject:hotSpot];
    
    hsCircleView = hotSpot;
    if(isQuestionChangedToHS)
    {
        
        if(hsQuestionView.hotspotColor == 1)
        {
            [hsCircleView setWhiteColor];
        }
        else if(hsQuestionView.hotspotColor == 2)
        {
            [hsCircleView setRedColor];
        }
        else if(hsQuestionView.hotspotColor == 3)
        {
            [hsCircleView setBlueColor];
        }
        else if(hsQuestionView.hotspotColor == 4)
        {
            [hsCircleView setYellowColor];
        }
        
    }
    else
        [hsCircleView setWhiteColor];
    
    //As an user can add a hotspot in any zoom level, we are calculating the original centre of hotspot as per image's normal zoom level and setting to its properties.
    
    [self calculatePositionCoordinatesOfSelectedHotSpotToPoint:hsCircleView.center];
    NSLog(@"hsTag - %@", hsCircleView.strHotspotId);
    [self initializeDefault];
    
}

-(void)calculatePositionCoordinatesOfCropViewToPoint:(CGPoint)point
{
    //Here we are calculating the centre coordinates of hotspot for image's normal zoom level and setting the properties of Orientaion and centre of hotspot at the time of adding to image.
    
    CGPoint pointWRTNormalSize;
    CGSize normalBounds;
    
    if(APP_DELEGATE.isPortrait)
    {
        normalBounds = imgBoundsAtNormalZoomInPortrait;
        // [hsCircleView setOrientationToPortrait];
    }
    else
    {
        normalBounds = imgBoundsAtNormalZoomInLandScape;
        // [hsCircleView setOrientationToLandscape];
    }
    
    pointWRTNormalSize.x = (normalBounds.width/imageBounds.width) * point.x;
    pointWRTNormalSize.y = (normalBounds.height/imageBounds.height) * point.y;
    
    CGPoint defaultCenter = [self getCentreWRTImageSize:pointWRTNormalSize];
    NSLog(@"Setting default center for crop view : %@",NSStringFromCGPoint(defaultCenter));
    [_cropView setDefaultCenterPoint:defaultCenter];
    //hsCircleView.addedInZoomScale = ceil(_scrlImgView.zoomScale);
    _cropView.addedInZoomScale = _scrlImgView.zoomScale;

}

-(IBAction)cropClicked:(id)sender
{
    //this method will get call when user tapped on Crop button on regular menu.

    [self addCropView];
    
    clipBoardView.hidden = NO;
    addHotSpotView.hidden = YES;
    //hotSpotEditToolView.hidden = YES;
    [self hideHotspotEditTool];
    
    //Disabling Swipe Gesture to show left menu to adjust the size of image to crop.
    if([self.navigationController isKindOfClass:[SlideNavigationController class]])
    {
        [(SlideNavigationController*)self.navigationController  setEnableSwipeGesture:NO];
        NSLog(@"menu disabled");
    }
    
}

-(void)addCropView
{
    NLCropViewLayer *cropView = [[NLCropViewLayer alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    [cropView setBackgroundColor:[UIColor clearColor]];
    [cropView updateCornerFrames];
    
    //Here adding pangesture for dragging the question over the image.
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCropViewPanGesture:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [cropView addGestureRecognizer:panGesture];
    panGesture = nil;
    
    [imageExactSubView setBackgroundColor:[UIColor clearColor]];
    [imageExactSubView addSubview:cropView];
    
    CGRect visibleImageRect = [self getVisibleImageRect1];
    
    cropView.center = CGPointMake(visibleImageRect.origin.x + visibleImageRect.size.width/2, visibleImageRect.origin.y + visibleImageRect.size.height/2);
    
    _cropView = cropView;
    [self calculatePositionCoordinatesOfCropViewToPoint:cropView.center];
}

-(IBAction)eyeClicked:(id)sender
{
    //this method will get call when user tapped on Eye button on regular menu. It will show the hotspots and hides as well.
    if(self.source == FROM_CONSUMER && isHotSpotTapped)
    {
        [self navigateToHotspotCommentsScreen];
        return;
    }
    
   for(UIView *aView in imageExactSubView.subviews)
   {
       if([aView isKindOfClass:[hotSpotCircleView class]])
       {
           hotSpotCircleView *circle = (hotSpotCircleView*)aView;
           
           if([circle isHidden])
           {
               [circle setHidden:NO];
           }
           else
           {
               [circle setHidden:YES];
           }
       }
       
       if([aView isKindOfClass:[questionView class]])
       {
           questionView *questionCircle = (questionView*)aView;
           
           if([questionCircle isHidden])
           {
               [questionCircle setHidden:NO];
           }
           else
           {
               [questionCircle setHidden:YES];
           }
       }
   }
}

-(IBAction)postClicked:(id)sender
{
    [txtFld resignFirstResponder];

    if(self.source == FROM_PUBLISHER)
    {
        //Re-Post Clicked
        //[self updateHotspotsInLocalDB];
        isPublisherRePost = YES;
        NSLog(@"++++++++PodId of Repost - %@", self.strPodId);
        //return;
    }

    
    //this method will get call when user tapped on Post button on regular menu.
    if([arrHotspots count]==0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Please add atleast one hotspot" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else
    {
        [Util_HotSpot setIndexValue:0];

        //IF there are hotspots added on Vault image, then posting Vault image and hotspot audios if existing to the server.
        //Saving Pod Info
        if([arrHotspots count]==0)
        {
            return;
        }
        else
        {
            if(!self.isPodExisting)
            {
                
                if(isPublisherRePost)
                {
                    [self checkWhetherPublisherAddedOrUpdatedHs];
                    
                    if([arrDeleteHsIds count] || [arrAddedHsIds count] || [arrUpdatedHsIds count])
                    {
//                        if([self isAllPreviousHSDeleted])
//                        {
                            //ALL the previous HS are deleted. So create new pod with newly added HS.
                            self.strPodId = [Util GetUUID];
                            [Util_HotSpot setPodId:self.strPodId];
                            [self savePodDataToDB];
                            isToCreateNewPodForRepost = YES;
                 //       }
//                        else
//                        {
//                            //Just update current pod and make a post.
//                        }
                    
                    }
                    else
                    {
                        //Just update current pod and make a post.
                        [self navigateToPostViewController];
                        return;

                    }
                  
                }
                else
                {
                    [self savePodDataToDB];
                }
            }
            else
            {}
            
        }

        //Saving Hotspot Inforamtion in DB if not saved
        for(hotSpotCircleView *hsCircleViewObject in arrHotspots)
        {
            if(hsCircleViewObject.isSaved == NO || hsCircleView.isModified == YES)
            {
                isHospotSavedinDB = [self saveOrUpdateHotspotwithObj:hsCircleViewObject];
            }
        }

        [self postToServer];
    }
}

-(BOOL)isAllPreviousHSDeleted
{
    BOOL isPreviousHSDeleted = NO;
    //Checking whether the user has deleted all previous HS and Added new HSs to repost. If it is the case we need to create new pod.
    
    NSInteger previousHSCount = [self.arrHotspotInfo count];
    NSInteger deletedHSCount = 0;
    NSString *strHotspotId;
   
        
        if([[self.arrHotspotInfo objectAtIndex:0] isKindOfClass:[NSManagedObject class]])
        {
            for(NSManagedObject *objHotspot in self.arrHotspotInfo)
            {
                strHotspotId = [objHotspot valueForKey:@"hId"];
                
                for(NSString *strHSId in arrDeleteHsIds)
                {
                    if([strHSId isEqualToString:strHotspotId])
                    {
                        deletedHSCount++;
                        break;
                    }
                }
            }
        }
        else
        {
            for(NSDictionary *dictHotspot in self.arrHotspotInfo)
            {
                strHotspotId = [dictHotspot valueForKey:@"hotspotId"];
                
                for(NSString *strHSId in arrDeleteHsIds)
                {
                    if([strHSId isEqualToString:strHotspotId])
                    {
                        deletedHSCount++;
                        break;
                    }
                }

            }
        }
    

    
    
    

    NSLog(@"PreviousHSCount - deletedHSCount : %li, %li", (long)previousHSCount, (long)deletedHSCount
          );
    
    if(previousHSCount == deletedHSCount)
    {
        isPreviousHSDeleted = YES;
    }

    return isPreviousHSDeleted;

}

-(void)postToServer
{
    
    [Util_HotSpot setSelectedImageId:self.selectedImgId];
    
    if(self.source == FROM_PUBLISHER)
    {
        //Repost Clicked
        if(isToCreateNewPodForRepost)
        {
            //Based on this string we are creating or updating web service call...
            [Util_HotSpot setAboutPost:@"post"];
        }
        else
        {
            
            [Util_HotSpot setAboutPost:@"repost"];
           
            /*
             for now we are not deleting questions in 'RePost'.
            //here we are deleting the questions from server if any converted as HS by the publisher.
            
            if([aryConvertedQuestions count])
            {
                [self deletePublisherQuestions];
            }
            else
            {
                //Here uploading media files of pod if any and making 'Re-Post' by the publisher.
                [self uploadVaultAndMediaFiles];

            }
            
            return;*/
        }
    }
    else
    {
        //Post Clicked.
        [Util_HotSpot setAboutPost:@"post"];
    }

    [self uploadVaultAndMediaFiles];
   
}

-(void)uploadVaultAndMediaFiles
{
    NSManagedObject *objImg = [self getSelectedImageDataFromDB];
    
    if([[objImg valueForKey:@"syncStatus"]integerValue] == 0 )
    {
        if([self connected])
        {
            [self showLoaderWithTitle:@"Uploading media files..."];
            [Util_HotSpot uploadVaultFile];
        }
        else
        {
            [self showNoInternetMessage];
            return;
        }
    }
    else
    {
        
        if([self connected])
        {
            //If Vault files is already there on server....
            
            [self showLoaderWithTitle:@"Uploading media files..."];
            [Util_HotSpot uploadMediaFile];
            
        }
        else
        {
            [self showNoInternetMessage];
            return;
        }
        
        
        
    }

}

-(void)podSyncSuccess:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSLog(@">>>podSyncSuccess -  %@", [userInfo valueForKey:@"rpid"]);
    self.strPodId = [userInfo valueForKey:@"rpid"];
    
    [self removeLoader];
    [self showTheAlert:[userInfo valueForKey:@"message"]];
    [self navigateToPostViewController];

}

-(void)podSyncError:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;

    [self removeLoader];
    
    [self showTheAlert:[userInfo valueForKey:@"NSLocalizedDescription"]];
    
}

-(void)getPodData:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    dictPod = notification.userInfo;
    NSLog(@"pod data:%@",userInfo);
}

-(void)navigateToPostViewController
{
    
    //Navigating to assign hotspots to the users screen.
    [self performSegueWithIdentifier:PostView sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PostView]) {
        PostViewController *postViewObj = (PostViewController*)segue.destinationViewController;
        postViewObj.selectedImgId = self.selectedImgId;
        postViewObj.strPodId = self.strPodId;
        postViewObj.dictPod = dictPod;
        postViewObj.isPodCreated = isToCreateNewPodForRepost;

        if(self.source == FROM_PUBLISHER)
        {
            postViewObj.strPostId = self.strPostId;
            
            postViewObj.source = FROM_PUBLISHER;
            if([arrAddedHsIds count])
            {
            postViewObj.arrAddedHsIds = arrAddedHsIds;
            }
            if([arrUpdatedHsIds count])
            {
            postViewObj.arrUpdatedHsIds = arrUpdatedHsIds;
            }
            if([arrRemainedHsIds count])
            {
                postViewObj.arrRemainedHsIds = arrRemainedHsIds;
            }
            if([arrDeleteHsIds count])
            {
                postViewObj.arrDeleteHsIds = arrDeleteHsIds;
            }

            
                postViewObj.isPublisherUpdate = isPublisherUpdate;
                postViewObj.isPublisherRePost = isPublisherRePost;

        }
        
    }
}


#pragma mark - Bottom Green View1 Button Actions
#pragma - =================================
-(IBAction)closeHotSpotClicked:(id)sender
{
    //hotSpotEditToolView.hidden = YES;
    [self hideHotspotEditTool];

    hotSpotLabelView.hidden = YES;
    hotSpotColorView.hidden = YES;
    hotSpotTextView.hidden = YES;
    hotSpotLinkView.hidden = YES;
    hotSpotAudioView.hidden = YES;
    
    
    if(!isHotSpotTapped && [arrQuestions count])
    {
        [self deleteSelectedQuestion];
        return;
    }
    
    if(self.source == FROM_PUBLISHER)
    {
        if(arrDeleteHsIds == nil)
            arrDeleteHsIds = [[NSMutableArray alloc] init];
        [arrDeleteHsIds addObject:hsCircleView.strHotspotId];
       // [Util_HotSpot deleteSharedHotspotOfId:hsCircleView.strHotspotId ofPost:self.strPostId];
        [Util_HotSpot deleteHotspotOfId:hsCircleView.strHotspotId];
    }
    
    for(hotSpotCircleView *objCircle in arrHotspots)
    {
        if([objCircle.strHotspotId isEqualToString:hsCircleView.strHotspotId])
        {
        [arrHotspots removeObject:objCircle];
            break;
        }
    }
    [hsCircleView removeFromSuperview];
    
    [self deleteAudioFile];
    [self commonForHSandQuestionDelete];
    
    hsCircleView = nil;

}

-(void)deleteSelectedQuestion
{
    if(arrDeletedQuestionIds == nil)
        arrDeletedQuestionIds = [[NSMutableArray alloc] init];
    [arrDeletedQuestionIds addObject:hsQuestionView.strQuestionId];

    for(questionView *objQuestion in arrQuestions)
    {
        if([objQuestion.strQuestionId isEqualToString:hsQuestionView.strQuestionId])
        {
            [arrHotspots removeObject:objQuestion];
            break;
        }
    }
    [hsQuestionView removeFromSuperview];
    hsQuestionView = nil;
    if(self.source == FROM_PUBLISHER)
    {
        //
    }
    [self commonForHSandQuestionDelete];
}

-(void)commonForHSandQuestionDelete
{
    if (audioPlayer) {
        if (audioPlayer.isPlaying)
        {
            [audioPlayer stop];
            
        }
    }
    if([audioRecorder isRecording])
    {
        [audioRecorder stop];
        
    }
    [self.btnRecord setImage:[UIImage imageNamed:@"Record.png"] forState:UIControlStateNormal];
    
    isRecorded = NO;
    if(sliderTimer != nil)
    {
        [sliderTimer invalidate];
        sliderTimer = nil;
    }
    self.sliderAudio.value=0.0;
    
    [self hideKeyboard];

}

-(IBAction)hotSpotLabelClicked:(id)sender
{
    
    hotSpotLabelView.hidden = NO;
    hotSpotColorView.hidden = YES;
    hotSpotTextView.hidden = YES;
    hotSpotLinkView.hidden = YES;
    hotSpotAudioView.hidden = YES;
}
-(IBAction)hotSpotColorClicked:(id)sender
{
    [self hideKeyboard];
    
    if(self.source == FROM_CONSUMER)
    {
        
        [self.btn_HotspotWhite setImage:[UIImage imageNamed:@"hotspotQuestion_white"] forState:UIControlStateNormal];
        [self.btn_HotspotBlue setImage:[UIImage imageNamed:@"hotspotQuestion_blue"] forState:UIControlStateNormal];
        [self.btn_HotspotRed setImage:[UIImage imageNamed:@"hotspotQuestion_red"] forState:UIControlStateNormal];
        [self.btn_HotspotYellow setImage:[UIImage imageNamed:@"hotspotQuestion_yellow"] forState:UIControlStateNormal];
    }
    // else part need to check
    
    hotSpotLabelView.hidden = YES;
    hotSpotColorView.hidden = NO;
    hotSpotTextView.hidden = YES;
    hotSpotLinkView.hidden = YES;
    hotSpotAudioView.hidden = YES;
}
-(IBAction)hotSpotTextClicked:(id)sender
{
    [self hideKeyboard];

    if(self.source == FROM_CONSUMER)
    {
        _lblPlaceHolder.hidden = YES;
        self.rateView.hidden = YES;
        [self showHotspotEditTool];
    }
    hotSpotLabelView.hidden = YES;
    hotSpotColorView.hidden = YES;
    hotSpotTextView.hidden = NO;
    hotSpotLinkView.hidden = YES;
    hotSpotAudioView.hidden = YES;
    
    if(self.source == FROM_PUBLISHER && hsQuestionView.isUploaded)
    {
        _lblPlaceHolder.hidden = YES;
        [self setDescriptionText:hsQuestionView.strDescText];

    }

}
-(IBAction)hotSpotLinkClicked:(id)sender
{
    if(self.source == FROM_CONSUMER && isHotSpotTapped)
    {
        self.rateView.hidden = YES;
        hotSpotAudioView.hidden = YES;

        _hotspotUrlTextField.text = hsCircleView.strUrlText;
        [self showHotspotEditTool];
    }
    else if(hsQuestionView.isUploaded == YES)
    {
        [self initializeAudio];
        return;
    }
    [self hideKeyboard];

    hotSpotLabelView.hidden = YES;
    hotSpotColorView.hidden = YES;
    hotSpotTextView.hidden = YES;
    hotSpotLinkView.hidden = NO;
    hotSpotAudioView.hidden = YES;
}
-(IBAction)hotSpotAudioClicked:(id)sender
{
    [self hideKeyboard];
  
    if(self.source == FROM_CONSUMER && isHotSpotTapped)
    {
        self.rateView.hidden = YES;
     //   hotSpotEditToolView.hidden = NO;
        [self initializeAudio];
        return;
    }
    if(self.source == FROM_CONSUMER && hsQuestionView.isUploaded == YES )
    {
        
        [self navigateToCommentsScreen];
        
        return;
    }
   
    [self initializeAudio];

   
}

-(void)initializeAudio
{
    hotSpotLabelView.hidden = YES;
    hotSpotColorView.hidden = YES;
    hotSpotTextView.hidden = YES;
    hotSpotLinkView.hidden = YES;
    hotSpotAudioView.hidden = NO;
    
    if(self.source == FROM_CONSUMER)
    {
        if(isHotSpotTapped && [hsCircleView.strAudioFilePath length] >0)
        {
            if (audioPlayer) {
                if (audioPlayer.isPlaying)
                {
                    [audioPlayer stop];
                    
                }
            }
            if([audioRecorder isRecording])
            {
                [audioRecorder stop];
                
            }
            
            [self.btnRecord setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
            isRecorded = YES;
            self.btnDelete.hidden = NO;
        }
        else if([hsQuestionView.strAudioFilePath length] >0 || [hsQuestionView.strAudioUrl length] > 0)
        {
            if (audioPlayer) {
                if (audioPlayer.isPlaying)
                {
                    [audioPlayer stop];
                    
                }
            }
            if([audioRecorder isRecording])
            {
                [audioRecorder stop];
                
            }
            
            [self.btnRecord setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
            isRecorded = YES;
            self.btnDelete.hidden = NO;

            
        }
        else
        {
            [self.btnRecord setImage:[UIImage imageNamed:@"Record.png"] forState:UIControlStateNormal];
            isRecorded = NO;
            self.btnDelete.hidden = YES;
        }
        return;
    }
    
    else if([hsCircleView.strAudioFilePath length] >0 || [hsQuestionView.strAudioUrl length] >0)
    {
        if (audioPlayer) {
            if (audioPlayer.isPlaying)
            {
                [audioPlayer stop];
                
            }
        }
        if([audioRecorder isRecording])
        {
            [audioRecorder stop];
            
        }
        
        [self.btnRecord setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
        isRecorded = YES;
        self.btnDelete.hidden = NO;
    }
    else
    {
        [self.btnRecord setImage:[UIImage imageNamed:@"Record.png"] forState:UIControlStateNormal];
        isRecorded = NO;
        self.btnDelete.hidden = YES;
        
    }
    
    
    if(sliderTimer !=nil)
    {
        [sliderTimer invalidate ];
        sliderTimer = nil;
    }
    self.sliderAudio.value = 0.0;
}

#pragma mark - Hotspot Color Choose Button Actions
#pragma - =================================
//These methods will be called when user wants to change the color of selected hotspot.
-(IBAction)hotSpotWhiteColorClicked:(id)sender
{
    if(self.source == FROM_CONSUMER)
    {
        [hsQuestionView setWhiteColor];
        return;
    }
   
    [hsCircleView setWhiteColor];
    
    
}
-(IBAction)hotSpotRedColorClicked:(id)sender
{
    if(self.source == FROM_CONSUMER)
    {
        [hsQuestionView setRedColor];
        hsQuestionView.isModified = YES;

        return;
    }
   
        [hsCircleView setRedColor];
        hsCircleView.isModified = YES;
   


}
-(IBAction)hotSpotBlueColorClicked:(id)sender
{
    if(self.source == FROM_CONSUMER)
    {
        [hsQuestionView setBlueColor];
        hsQuestionView.isModified = YES;
        return;
    }
   
    [hsCircleView setBlueColor];
    hsCircleView.isModified = YES;

}
-(IBAction)hotSpotYellowColorClicked:(id)sender
{
    if(self.source == FROM_CONSUMER)
    {
        [hsQuestionView setYellowColor];
        hsQuestionView.isModified = YES;
        return;
    }
    
    [hsCircleView setYellowColor];
    hsCircleView.isModified = YES;
   


}

#pragma mark - Hotspot Clipboard Button Actions
#pragma - =================================
//These are the methods of clipboard menu actions.
-(IBAction)clipBoardCloseClicked:(id)sender
{
    //Close button action of Crop menu.

    clipBoardView.hidden = YES;
    addHotSpotView.hidden = NO;
    
    
    [_cropView removeFromSuperview];
    if([self.navigationController isKindOfClass:[SlideNavigationController class]])
    {
    [(SlideNavigationController*)self.navigationController  setEnableSwipeGesture:YES];
    }

}

-(IBAction)saveToClipBoardClicked:(id)sender
{
    //SaveToClipBoard button action of Crop menu.
    
    UIImage *croppedImage = [self getCroppedImage];
    
    // Saving Croppeed images in clipboard folder and made them to not exceed 6
    if (croppedImagesCount == 6) {
        [self showTheAlert:@"Clipboard images should not exceed"];
    }
    else{
        NSString *imgName = [self prepareImageWithName:CLIPBOARD_IMAGENAME withID:kClipboardImageID];
        BOOL success = [Util saveImage:croppedImage withName:imgName inFolder:CLIPBOARD_FOLDER];
        if (success) {
            [self showTheAlert:@"Image saved to clipboard "];
            croppedImagesCount ++;
        }
        else{
            [self showTheAlert:@"Unable to save clipboard image"];
        }
    }

    clipBoardView.hidden = YES;
    addHotSpotView.hidden = NO;
    [_cropView removeFromSuperview];

}

- (UIImage *)getCroppedImage
{
    
    UIImage *_image = self.pickedImage;
    
    float xRatio =   _image.size.width / imageExactSubView.frame.size.width;
    float yRatio =   _image.size.height / imageExactSubView.frame.size.height;
    
    
    CGRect imageRect = CGRectMake(_cropView.frame.origin.x * xRatio,
                                  _cropView.frame.origin.y * yRatio,
                                  _cropView.frame.size.width * xRatio ,
                                  _cropView.frame.size.height * yRatio);
    
    NSLog(@"Image size - %@", NSStringFromCGSize(_image.size));
    NSLog(@"imageExactSubView - %@", NSStringFromCGRect(imageExactSubView.frame));
    NSLog(@"CropView - %@", NSStringFromCGRect(_cropView.frame));
    NSLog(@"CropView image rect - %@", NSStringFromCGRect(imageRect));

    
    float scale = 1.0f/_scrlImgView.zoomScale;
    
   // return imageFromView(_image, &imageRect);

    
    CGImageRef imageRef = CGImageCreateWithImageInRect([_image CGImage], imageRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef
                                          scale:_image.scale
                                    orientation:_image.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

UIImage* imageFromView(UIImage* srcImage, CGRect* rect)
{
    CGImageRef cr = CGImageCreateWithImageInRect(srcImage.CGImage, *rect);
    UIImage* cropped = [UIImage imageWithCGImage:cr];
    
    CGImageRelease(cr);
    return cropped;
}

-(UIImage*) getCroppedImage1
{
    
    
    UIImage *_image = self.pickdImageView.image;
    
    int xRatio =   _image.size.width / imageExactSubView.frame.size.width;
    int yRatio =   _image.size.height / imageExactSubView.frame.size.height;
    
    
    
    
  /*  CGRect imageRect = CGRectMake((_cropView.frame.origin.x + imageExactSubView.frame.origin.x) ,
                                  ( _cropView.frame.origin.y + imageExactSubView.frame.origin.y) ,
                                  _cropView.frame.size.width  ,
                                  _cropView.frame.size.height );*/
    
    CGRect imageRect = CGRectMake(_cropView.frame.origin.x * xRatio, _cropView.frame.origin.y * yRatio, _cropView.frame.size.width * xRatio, _cropView.frame.size.height * yRatio);
    
    //Calculate the required area from the scrollview
    CGRect visibleRect;
    float scale = 1.0f/_scrlImgView.zoomScale;
    visibleRect.origin.x = imageRect.origin.x * scale;
    visibleRect.origin.y = imageRect.origin.y * scale;
    visibleRect.size.width = imageRect.size.width * scale;
    visibleRect.size.height = imageRect.size.height * scale;
    
    imageRect.size.width = imageRect.size.width * scale;
    imageRect.size.height = imageRect.size.height * scale;
    
    return imageFromView(_image, &imageRect);
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

-(void) viewWillDisappear :(BOOL)animated
{
    isKeyBoardAppeared = NO;
    [txtFld resignFirstResponder];
    [_descriptionTxtView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [sliderTimer invalidate];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnDelete_action:(id)sender
{
    //This is the delete action of audio menu items.
   
    self.btnDelete.hidden = YES;
   
    
    [self deleteAudioFile];
    if([hsCircleView.strAudioFileName length] == 0 || [hsQuestionView.strAudioFileName length] == 0)
    {
        [audioRecorder stop];
         isRecorded = NO;
        [self.btnRecord setImage:[UIImage imageNamed:@"Record.png"] forState:UIControlStateNormal];
        if (audioPlayer) [audioPlayer stop];

        if(sliderTimer != nil)
                {
                    [sliderTimer invalidate];
                    sliderTimer = nil;
                }
                self.sliderAudio.value=0.0;
    }

}

#pragma mark Audio recording functionality

- (IBAction)btnRecord_TouchUpInside:(id)sender
{
    //This is the audio record action of audio menu items.

    if(isRecorded == NO)
    {
        NSLog(@"start record");
        if([audioRecorder isRecording])
        {
            [audioRecorder stop];
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setActive:NO error:nil];

            isRecorded = YES;
            [self.btnRecord setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
            self.btnDelete.hidden = NO;
            return;
        }
        else
        {
            if(self.source == FROM_CONSUMER && isHotSpotTapped == NO)
            {
                strAudioFileName = [self prepareAudioFileNamewithHotspotId:hsQuestionView.strQuestionId];
            }
            else
                strAudioFileName = [self prepareAudioFileNamewithHotspotId:hsCircleView.strHotspotId];
            
            
           
            NSURL *urlAudio =  [self saveAudioToDocumentsDirectory:strAudioFileName inFolder:kHotspotAudioFile];
            
            
            
            
            [self recordNewAudioWithFileURL:urlAudio];
            
            sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
            
            self.sliderAudio.maximumValue = 20;

            
            return;
        }

     
    }
    else
    {
        
        NSLog(@"play Record");
        
        if (audioPlayer.isPlaying) {
          
                [audioPlayer stop];
                [sliderTimer invalidate];
                self.sliderAudio.value =0.0;
                [self.btnRecord setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
                audioPlayer = nil;
                return;

            
        }
        else
        {
            NSError *error;

            if(self.source == FROM_CONSUMER)
            {
                if(!isHotSpotTapped)
                {
                    NSString *strAudioUrlOrPath;
                    
                    if([hsQuestionView.strAudioFilePath length])
                        strAudioUrlOrPath = hsQuestionView.strAudioFilePath;
                    else
                        strAudioUrlOrPath = hsQuestionView.strAudioUrl;
                    
                    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:strAudioUrlOrPath] error:&error];
                    if(error)
                    {
                        NSString *urlstr =  strAudioUrlOrPath;
                        urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        NSURL *url = [NSURL URLWithString:urlstr];
                        NSData *data = [NSData dataWithContentsOfURL:url];
                        audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
                        audioPlayer.delegate = self;

                    }
                    NSLog(@"Question audio path - %@", hsQuestionView.strAudioFilePath);
                    
                    NSLog(@"Question audio Url - %@", hsQuestionView.strAudioUrl);

                }
               else
               {
                   NSString *urlstr =hsCircleView.strAudioFilePath;
                   urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                   NSURL *url = [NSURL URLWithString:urlstr];
                   NSData *data = [NSData dataWithContentsOfURL:url];
                   audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
                   audioPlayer.delegate = self;
                   
                   
                }
            }
            else if(self.source == FROM_PUBLISHER && hsQuestionView.isUploaded)
            {
                audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:hsQuestionView.strAudioUrl] error:&error];
                if(error)
                {
                    NSString *urlstr =hsQuestionView.strAudioUrl;
                    urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    NSURL *url = [NSURL URLWithString:urlstr];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
                    audioPlayer.delegate = self;
                    
                }
                NSLog(@"Question audio path - %@", hsQuestionView.strAudioFilePath);
                
                NSLog(@"Question audio Url - %@", hsQuestionView.strAudioUrl);
            }
            else
            {
                 audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:hsCircleView.strAudioFilePath] error:&error];
            }
            
            
            if(error)
            {
                NSLog(@"Error - %@", error.description);
                
                NSString *urlstr =hsCircleView.strAudioFilePath;
                urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *url = [NSURL URLWithString:urlstr];
                NSData *soundData = [NSData dataWithContentsOfURL:url];
                NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                           NSUserDomainMask, YES) objectAtIndex:0]
                                      stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.aac",hsCircleView.strAudioId]];
                [soundData writeToFile:filePath atomically:YES];
                audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL
                                                                       fileURLWithPath:filePath] error:&error];
                audioPlayer.delegate = self;

                NSLog(@"error %@", error);
                //return;
            }
            else
            {
                NSLog(@"No Error");
            }
           
            [audioPlayer setDelegate:self];
            [audioPlayer play];
            
            
            [self.btnRecord setImage:[UIImage imageNamed:@"Pause.png"] forState:UIControlStateNormal];
            self.btnDelete.hidden = NO;
            
            self.sliderAudio.value =0.0;
            sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
        
            self.sliderAudio.maximumValue = audioPlayer.duration;


        }
        
    }
  
}

-(NSString*)prepareAudioFileNamewithHotspotId:(NSString*)hotspotId
{
    NSString *strAudioId = [NSString stringWithFormat:@"rnyi_%@", [Util GetUUID]];
    
    NSString *strFileName = [NSString stringWithFormat:@"%@.aac",strAudioId];
    NSLog(@"audio file name:%@",strFileName);
    if(self.source == FROM_CONSUMER && isHotSpotTapped == NO)
    {
        hsQuestionView.strAudioFileName = strFileName;
        hsQuestionView.strAudioId = strAudioId;
        hsQuestionView.isModified = YES;
        return strFileName;
    }
   
        hsCircleView.strAudioFileName = strFileName;
        hsCircleView.isModified = YES;
        hsCircleView.strAudioId = strAudioId;
    
    return strFileName;
}

- (void)updateSlider
{
    //Setting slider while playing and recording the audio.
    
    if(isRecorded)
    {
        self.sliderAudio.value = audioPlayer.currentTime;
    }
    else
        self.sliderAudio.value = audioRecorder.currentTime;

    NSLog(@"slider value%f",self.sliderAudio.value);
  
}

-(void)initializeAudioRecord
{
    //Initialize audio session
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    /*
    //Override record to mix with other app audio, background audio not silenced on record
    OSStatus propertySetError = 0;
    UInt32 allowMixing = true;
    propertySetError = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    
    NSLog(@"Mixing: %lx", propertySetError); // This should be 0 or there was an issue somewhere
    
    //[[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:8], AVLinearPCMBitDepthKey,
                                    nil];*/
    
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    nil];
    if(self.source == FROM_CONSUMER)
    {
        strAudioFileName = [self prepareAudioFileNamewithHotspotId:hsQuestionView.strQuestionId];
    }
    else
        strAudioFileName = [self prepareAudioFileNamewithHotspotId:hsCircleView.strHotspotId];
  
    

    NSURL *urlAudio =  [self saveAudioToDocumentsDirectory:strAudioFileName inFolder:kHotspotAudioFile];
    
    
    NSLog(@"%@",hsCircleView);
    NSLog(@">>>>>>>>Record audio path - %@", hsCircleView.strAudioFilePath);

    
    NSError *error = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:urlAudio settings:recordSettings error:&error];
    
    if (!audioRecorder) {
        NSLog(@"audioRecorder: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
        return;
    }
    
    audioRecorder.meteringEnabled = YES;
    
}

-(void)recordNewAudioWithFileURL:(NSURL*)fileUrl
{
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    
    
    OSStatus propertySetError = 0;
    UInt32 allowMixing = true;
    propertySetError = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(allowMixing), &allowMixing);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    
    NSLog(@"Mixing: %x", (int)propertySetError); // This should be 0 or there was an issue somewhere
   
    
    // Define the recorder setting
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:fileUrl settings:recordSetting error:nil];
    //recorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
    [audioRecorder prepareToRecord];
    
    
    if (!audioRecorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [audioRecorder record];
        
    }

}

-(void)record
{
    //Recording the audiio.
   
    sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    
    self.sliderAudio.maximumValue = 20;
    
    [audioRecorder record];
    NSLog(@"audiorecorder time%f",audioRecorder.currentTime);
    
    NSLog(@"recording");
}

-(void)playAudio
{
   //Playing audio of particular hotspot
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    NSError *error;
    NSData *data;
    NSURL *url;
    if(self.source == FROM_CONSUMER)
    {
        data = [NSData dataWithContentsOfFile:hsQuestionView.strAudioFilePath];
    }
    else
    {
        data = [NSData dataWithContentsOfFile:hsCircleView.strAudioFilePath];
    }
    
    
    if(data ==  nil)
    {
        NSLog(@"data is nil");
        return;
    }
    
    if([data length])
    {
        NSLog(@"data length - %lui", (unsigned long)[data length]);
    }
    
    if(self.source == FROM_CONSUMER)
    {
        url = [NSURL URLWithString:hsQuestionView.strAudioFilePath];
        
    }
    else
        url = [NSURL URLWithString:hsCircleView.strAudioFilePath];
   
    
    NSLog(@">>>>>>>>>>audio path - %@", hsCircleView.strAudioFilePath);
    
   AVAudioPlayer *audioPlayer1 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer1.delegate = self;
    
    if(error)
    {
        [self showTheAlert:[error description]];
        return;
    }

    
    self.sliderAudio.value =0.0;
    sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    //  self.sliderAudio.maximumValue = 20;
    
    // Set the maximum value of the UISlider
    self.sliderAudio.maximumValue = audioPlayer.duration;
   
   
    if([audioPlayer1 prepareToPlay])
    {
        NSLog(@"play audio ok");
    }
    else
    {
        NSLog(@"Failed to play");
    }
    
   
    
    [audioPlayer1 play];
    
    audioPlayer = audioPlayer1;
    [self.btnRecord setImage:[UIImage imageNamed:@"Pause.png"] forState:UIControlStateNormal];
    self.btnDelete.hidden = NO;
}

-(void)stopAudio
{
    //Stop playing audio.
    
    if (audioPlayer) {
        if (audioPlayer.isPlaying)
        {
            [audioPlayer stop];
            [self.btnRecord setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
            self.btnDelete.hidden = NO;
            
        }
    }
    if([audioRecorder isRecording])
    {
        [audioRecorder stop];
       
        [self.btnRecord setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
        self.btnDelete.hidden = NO;
        isRecorded = YES;
        
    }
      [sliderTimer invalidate ];

}

#pragma mark AudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying : (AVAudioPlayer *)player successfully : (BOOL)flag
{
    // Music completed
    NSLog(@"delegate method called");
    [self.btnRecord setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
    [sliderTimer invalidate ];
    sliderTimer = nil;
    self.sliderAudio.value=0.0;
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Decoding error - %@", [error localizedDescription]);
}
#pragma mark delete audiofile from documents directory

/* delete selected audio file*/
-(void)deleteAudioFile
{
    
    if(self.source == FROM_CONSUMER)
    {
         [self removeAudioFilefromDocumentsDirectorywithFilename:hsQuestionView.strAudioFileName inFolder:kHotspotAudioFile];
        
        hsQuestionView.strAudioFileName = nil;
        hsQuestionView.strAudioFilePath = nil;
        hsQuestionView.isModified = YES;
        return;
    }
    NSArray *arrHotspotsData = [self getSelectedHotspotData];
    if([arrHotspotsData count])
    {
        for(NSManagedObject *obj in arrHotspotsData)
        {
            [self removeAudioFilefromDocumentsDirectorywithFilename:[obj valueForKey:@"audioFileName"] inFolder:kHotspotAudioFile];
            [obj setValue:@"" forKey:@"audioFileUrl"];
            [obj setValue:@"" forKey:@"audioFileName"];
            [obj setValue:@"" forKey:@"audioFilePath"];
            
        }
    }
    else
        [self removeAudioFilefromDocumentsDirectorywithFilename:hsCircleView.strAudioFileName inFolder:kHotspotAudioFile];

    
    hsCircleView.strAudioFileName = nil;
    hsCircleView.isModified = YES;

}
-(NSURL*)saveAudioToDocumentsDirectory:(NSString*)fileName inFolder :(NSString*)folderName
{
    //Saving audio file in application documents directory.
    
    BOOL success = [Util checkOrCreateFolder:folderName];
    NSURL *url;
    if (success) {
        NSString *filePath = [self getFilePathwithFileName:fileName inFolder:folderName];

        if(self.source == FROM_CONSUMER && isHotSpotTapped == NO)
        {
            hsQuestionView.strAudioFilePath = filePath;
            hsQuestionView.isModified = YES;
            NSURL *url = [NSURL fileURLWithPath:filePath];
            return url;
        }
       
            hsCircleView.strAudioFilePath = filePath;
            hsCircleView.isModified = YES;
       
        
        NSURL *url = [NSURL fileURLWithPath:filePath];
        return url;
    }
    else{
        NSLog(@"Unable to create folder");
    }
    
    return url;
}

-(NSString*)getFilePathwithFileName:(NSString*)fileName inFolder:(NSString*)folderName
{
    BOOL success = [self checkOrCreateFolder:folderName];
    
    NSString *filePath = [[[Util sandboxPath] stringByAppendingPathComponent:folderName]stringByAppendingPathComponent:fileName];

    return filePath;
}

-(BOOL)checkOrCreateFolder:(NSString*)fldName{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *folderPath = [path stringByAppendingPathComponent:fldName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        return YES;
    }
    else{
        if ([[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil]){
            return YES;
        }
        else{
            return NO;
        }
    }
    return YES;
}

-(void)removeAudioFilefromDocumentsDirectorywithFilename:(NSString*)fileName inFolder :(NSString*)folderName
{
    
    //Removing audio file from physical path
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
   
    NSString *filePath =  [self getFilePathwithFileName:fileName inFolder:folderName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
   
    if (success)
    {
        NSLog(@"successfully deleted audiofile");
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

#pragma mark Save Hotspot and image data in DB
-(BOOL)saveOrUpdateHotspotwithObj:(hotSpotCircleView*)hsCircleViewObj
{
    
    //Saving HotSpot information in Local DB.
    
    NSString *strHotspotColor = [self setHotspotcolorWithObj:hsCircleViewObj];
    hsCircleViewObj.isSaved = YES;
    hsCircleViewObj.isModified = NO;

    NSManagedObject *objHotspot;
    objHotspot = [self getHotspotInfoWithId:hsCircleViewObj.strHotspotId andImgId:self.selectedImgId];
    
    if(objHotspot == nil)
        objHotspot = [NSEntityDescription insertNewObjectForEntityForName:@"Hotspot" inManagedObjectContext:context];

    if([hsCircleViewObj.strUrlText isEqualToString:@"http://www."])
    {
        hsCircleViewObj.strUrlText = @"";
    }
    
    if([hsCircleViewObj.strAudioFilePath length]>0)
    {
        [objHotspot setValue:hsCircleViewObj.strAudioFilePath forKey:@"audioFilePath"];
    }
    else
        [objHotspot setValue:@"" forKey:@"audioFilePath"];
    
    if([self.selectedImgId length] > 0 )
    {
        [objHotspot setValue:self.selectedImgId forKey:@"imgId"];
    }
    
    NSLog(@">>>Label - %@", hsCircleViewObj.strLabel);
    
    if([hsCircleViewObj.strLabel length] > 0)
    {
        [objHotspot setValue:hsCircleViewObj.strLabel forKey:@"strLabel"];
    }
    else
        [objHotspot setValue:@"" forKey:@"strLabel"];
    
    
    if([hsCircleViewObj.strDescText length] > 0)
    {
        [objHotspot setValue:hsCircleViewObj.strDescText forKey:@"strDescription"];
    }
    else
        [objHotspot setValue:@"" forKey:@"strDescription"];
    
    
    if([hsCircleViewObj.strUrlText length] > 0)
    {
        [objHotspot setValue:hsCircleViewObj.strUrlText forKey:@"url"];
    }
    else
        [objHotspot setValue:@"" forKey:@"url"];
    
    
    if([hsCircleViewObj.strHotspotId length] > 0 )
    {
        [objHotspot setValue:hsCircleViewObj.strHotspotId forKey:@"hId"];
        
    }
    else
        [objHotspot setValue:@"" forKey:@"hId"];
    
    [objHotspot setValue:self.strPodId forKey:@"podId"];

    
    
    if(hsCircleViewObj.getDefaultCentre.x)
    {
        [objHotspot setValue:[NSNumber numberWithInt:hsCircleViewObj.getDefaultCentre.x] forKey:@"xCoordinate"];
    }
    else
        [objHotspot setValue:@"0" forKey:@"xCoordinate"];
    
    
    
    if(hsCircleViewObj.getDefaultCentre.y)
    {
        [objHotspot setValue:[NSNumber numberWithInt:hsCircleViewObj.getDefaultCentre.y] forKey:@"yCoordinate"];
    }
    else
        [objHotspot setValue:@"0" forKey:@"yCoordinate"];
    
    
    [objHotspot setValue:[NSNumber numberWithFloat:hsCircleViewObj.addedInZoomScale] forKey:@"zoomFactor"];

    
    [objHotspot setValue:strHotspotColor forKey:@"hotspotColor"];
    
    [objHotspot setValue:[NSNumber numberWithBool:NO] forKey:@"mediaFlag"];  //default need to get clarification
    
    [objHotspot setValue:@"" forKey:@"audioFileUrl"];
    
    if([hsCircleViewObj isAddedInPortrait])
    {
        [objHotspot setValue: @"portrait" forKey:@"orientation"];
    }
    else
        
        [objHotspot setValue: @"landscape" forKey:@"orientation"];
    
  //  [objHotspot setValue:@"" forKey:@"friendsList"];
    
    if([hsCircleViewObj.strAudioFileName length]>0)
    {
        [objHotspot setValue: hsCircleViewObj.strAudioFileName forKey:@"audioFileName"];
        
    }
    else
        [objHotspot setValue: @"" forKey:@"audioFileName"];
    
    
    if([hsCircleViewObj.strAudioId length]>0)
    {
        [objHotspot setValue:hsCircleViewObj.strAudioId forKey:@"audioId"];
    }
    else
        [objHotspot setValue:@"" forKey:@"audioId"];
    
    NSError *error= nil;
    if (![context save:&error])
    {
        NSLog(@"Problem saving: %@", [error localizedDescription]);
        return NO;
    }
    else
        return YES;
    
}

// set hotspot color to save in DB
-(NSString*)setHotspotcolorWithObj:(hotSpotCircleView*)hotspotobj
{
    NSString *strHotspotColor = @"white";

    if(hotspotobj.hotspotColor == 1)
    {
        strHotspotColor = @"white";
    }
    else if(hotspotobj.hotspotColor == 2)
    {
        strHotspotColor = @"red";
    }
    else if(hotspotobj.hotspotColor == 3)
    {
        strHotspotColor = @"blue";
    }
    else if(hotspotobj.hotspotColor == 4)
    {
        strHotspotColor = @"yellow";
    }
    return strHotspotColor;
}

-(void)saveImagetoDBWithLocalPath:(NSString*)strLocalPath WithImageName:(NSString*)strImagName
{
    //Saving image name and path to the local DB
    NSLog(@">>>saving db imgpath - %@", strLocalPath);
    
    self.selectedImgId = [NSString stringWithFormat:@"rnyi_%@",[Util GetUUID]];

    [Util_HotSpot setSelectedImageId:self.selectedImgId];
    
    NSManagedObject *objImage= [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
    
    [objImage setValue:self.selectedImgId forKey:@"imgId"];
    [objImage setValue:strLocalPath forKey:@"imgPath"];
    [objImage setValue:strImagName forKey:@"imgName"];
    
    [objImage setValue:[NSNumber numberWithBool:NO] forKey:@"syncInitiated"];
    
    [objImage setValue:[NSNumber numberWithBool:NO] forKey:@"syncStatus"];
    [objImage setValue:@"" forKey:@"imgUrl"];

    NSLog(@"imgcreated time:%@",imgCreatedDate);
    NSLog(@"image location:%@",strLocation);
    
    if([strLocation length] >0)
    {
        [objImage setValue:strLocation forKey:@"imgLocation"];
    }
    else
        [objImage setValue:@"" forKey:@"imgLocation"];

    
    long long imgCreatedTime = (long long)(NSTimeInterval)([imgCreatedDate timeIntervalSince1970]*1000);

    if(imgCreatedTime >0)
    {
          [objImage setValue:[NSNumber numberWithLongLong:imgCreatedTime] forKey:@"imageCreatedTime"];
        
      //  [objImage setValue:[NSNumber numberWithLong:(long)(NSTimeInterval)([imgCreatedDate timeIntervalSince1970] * 1000)] forKey:@"imageCreatedTime"];

    }
    else
        [objImage setValue:[NSNumber numberWithLongLong:(long long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970] * 1000)] forKey:@"imageCreatedTime"];

    
    NSError *error= nil;
    if (![context save:&error])
    {
        NSLog(@"Problem saving: %@", [error localizedDescription]);
    }
    
}

-(void)saveWebPImageAtPath:(NSString*)filePath{
    
    
        //Saving image in webp format
        NSLog(@">>>before image save");
        
         [self.pickedImage writeWebPToFilePath:filePath quality:50];
    
    
    NSLog(@">>>After1 image save");
    
    if([Util_HotSpot getBackGround] == NO)
        [self performSelectorOnMainThread:@selector(removeLoader) withObject:nil waitUntilDone:YES];
 
    
    
}

-(void)uploadInBackGround
{
    [Util_HotSpot uploadVaultFile];
}

-(NSString*)sandboxPath
{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"sand box path is:%@",path);
    //    NSURL *path = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    return path;
}

-(NSString*)getImagePathwithImageName:(NSString*)imgName inFolder:(NSString*)folderName
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [[path stringByAppendingPathComponent:folderName]stringByAppendingPathComponent:imgName];
    return filePath;
}

-(void)savePodDataToDB
{
    if(!self.selectedImgId.length)
    [self saveImagetoDBWithLocalPath:self.strImagePath WithImageName:[self.strImagePath lastPathComponent]];

    if(![arrHotspots count])
        return;
    
    
    //If Pod data already existing for this image ID we are not saving pod info again.
    NSManagedObject *objPod = [Util_HotSpot getPodDataFromDBOfPodId:self.strPodId];

    if(objPod != nil)
    {
        NSLog(@"Image ID - %@", [objPod valueForKey:@"imgId"]);
        NSLog(@"pod data already existing");
        return;
    }
    
    NSManagedObject *managedObjPod= [NSEntityDescription insertNewObjectForEntityForName:@"Pod" inManagedObjectContext:context];
    
    [managedObjPod setValue:self.strPodId forKey:@"pid"];

    [managedObjPod setValue:self.selectedImgId forKey:@"imgId"];
    
    [managedObjPod setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]* 1000] forKey:@"createdAt"];
    
    [managedObjPod setValue:[NSNumber numberWithBool:YES] forKey:@"draft"];

    [managedObjPod setValue:[NSNumber numberWithBool:NO] forKey:@"published"];

    if(APP_DELEGATE.isPortrait)
    {
        [managedObjPod setValue:@"portrait" forKey:@"orientation"];
    }
    else
        [managedObjPod setValue:@"landscape" forKey:@"orientation"];
    
    [managedObjPod setValue:@"locked" forKey:@"ownership"];
    if(self.strParentPodId.length > 0)
    {
        [managedObjPod setValue:self.strParentPodId forKey:@"parentId"];

    }
    else
    [managedObjPod setValue:@"" forKey:@"parentId"];

    [managedObjPod setValue:[NSNumber numberWithInteger:1] forKey:@"zoomscale"];

    [managedObjPod setValue:@"" forKey:@"latitude"];
    [managedObjPod setValue:@"" forKey:@"longitude"];
    [managedObjPod setValue:@"" forKey:@"location"];
    
    [managedObjPod setValue:@"" forKey:@"title"];
    
    [managedObjPod setValue:@"" forKey:@"descriptionPod"];
    
    NSError *error= nil;
    if (![context save:&error])
    {
        NSLog(@"Problem saving: %@", [error localizedDescription]);
    }
    else
    {
        self.isPodExisting = YES;
    }

    
    
}


/* get selected hotspot data from db */
-(NSArray*)getSelectedHotspotData
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Hotspot" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && hId == %@",self.selectedImgId,hsCircleView.strHotspotId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"all hotspots array:%@",fetchedObjects);
    
    if([fetchedObjects count])
        return fetchedObjects;
    else
        return nil;
    return nil;
}

# pragma mark  get Hotspot data from DB

// get hotspots data from DB based on imgid
-(NSArray*)getHotspotDatafromDB:(NSString*)strpodId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Hotspot" inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && podId == %@",self.selectedImgId, strpodId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"selected imageid:%@",self.selectedImgId);
    NSLog(@"all hotspots image ids array:%@",[fetchedObjects valueForKey:@"imgId"]);
    
    return fetchedObjects;
    
}
-(NSManagedObject*)getHotspotInfoWithId:(NSString*)strHSId andImgId:(NSString*)strImgId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Hotspot" inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ AND hId == %@ AND podId == %@",strImgId, strHSId, self.strPodId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count])
    return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    
}
-(NSManagedObject*)getSelectedImageDataFromDB
{
    NSError *error;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@",self.selectedImgId];
    
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count])
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    return nil;
}
// getting pod data from database
-(NSString*)getNotPostedPodIdOfImgId:(NSString*)strImgId
{
    NSError *error;
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Pod" inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imgId == %@ && draft == %@ && published == %@",strImgId, [[NSNumber numberWithBool:YES] stringValue], [[NSNumber numberWithBool:NO] stringValue]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entityDesc];
    
    NSArray *fetchedObjects = [[APP_DELEGATE managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    
    if([fetchedObjects count])
    {
        NSManagedObject *obj = [fetchedObjects objectAtIndex:0];
        return [obj valueForKey:@"pid"];
    }
    else
        return @"";
    
}

# pragma mark alertview delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(alertView.tag == 111 && buttonIndex == 1)
    {
        //Retry clicked
        [Util_HotSpot uploadVaultFile];
    }
    else if(buttonIndex == 0 & alertView.tag ==100)
    {
        //User dont want to save image...Deleting the webp image from physical path.
        
        if([[NSFileManager defaultManager] fileExistsAtPath:self.strImagePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:self.strImagePath error:nil];
        }
        [self sendBack];

        
    }
     else if(buttonIndex == 1 & alertView.tag ==100)
    {
        if(!self.selectedImgId.length)
            [self saveImagetoDBWithLocalPath:self.strImagePath WithImageName:[self.strImagePath lastPathComponent]];
        [self sendBack];

    }
    else if (buttonIndex == 1)
    {
        
        // save and upload in background
        [Util_HotSpot setBackGround:YES];

        [self performSelectorOnMainThread:@selector(checkForImageOrHotsptSaved) withObject:nil waitUntilDone:YES];
        
                NSLog(@"calling webservice in background");
            [self performSelectorInBackground:@selector(uploadInBackGround) withObject:nil];
    
        [self sendBack];
    }
    else
        [self sendBack];

}

//When Back button clicked
-(void)sendBack
{
    /*if([self.navigationController isKindOfClass:[SlideNavigationController class]])
    {
        NSLog(@"Views Count - %d", [[SlideNavigationController sharedInstance].viewControllers count]);
        if([[SlideNavigationController sharedInstance].viewControllers count] > 2)
        {
            [self.navigationController popViewControllerAnimated:YES];
            return;
 
        }
        [[SlideNavigationController sharedInstance] toggleLeftMenu];
        return;
    }*/
    isSendBack = YES;
    NSLog(@"Sendback");
    [self.navigationController popViewControllerAnimated:NO];
    
    //[self dismissViewControllerAnimated:YES completion:nil];

}

//URL validation method
-(BOOL)checkForvalidationwithURL:(NSString*)strUrl
{
    
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                               error:&error];


    NSURL *url = nil;
    NSTextCheckingResult *result = [detector firstMatchInString:strUrl
                                                        options:0
                                                          range:NSMakeRange(0, strUrl.length)];
    if (result.resultType == NSTextCheckingTypeLink)
    {
        url = result.URL;
        NSLog(@"matched: %@", url);

        return YES;
    }
    else
        return NO;
}

/* Initialize Default values for hotspot label,description and url fields */

-(void)initializeDefault
{
    if(self.source == FROM_CONSUMER)
    {
        [self setDescriptionText:@""];

        hsQuestionView.strDescText = _descriptionTxtView.text;
        return;
    }
    else if(self.source == FROM_PUBLISHER)
    {
        hsCircleView.strDescText = _descriptionTxtView.text;
        hsCircleView.strLabel = @"";
        hsCircleView.strUrlText = _hotspotUrlTextField.text;
    }
    
    [self setDescriptionText:@""];
    _hotspotUrlTextField.text = @"http://www.";
    _hotspotTitle.text = @"";
    
    _lblPlaceHolder.hidden = NO;
    _lablePlaceHolder.hidden = NO;
    
    hsCircleView.strDescText = _descriptionTxtView.text;
    hsCircleView.strLabel = @"";
    hsCircleView.strUrlText = _hotspotUrlTextField.text;
    
}

/* check whether image or hotspot already saved, if not save */
-(void)checkForImageOrHotsptSaved
{
    if(!self.isPodExisting)
        [self savePodDataToDB];
    
    
    for(hotSpotCircleView *hsCircleViewObject in arrHotspots)
    {
        if(hsCircleViewObject.isSaved == NO || hsCircleView.isModified == YES)
        {
            isHospotSavedinDB = [self saveOrUpdateHotspotwithObj:hsCircleViewObject];
        }
    }


}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        
    }
    
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0)
        {
            placemark = [placemarks lastObject];
            
            [locationManager stopUpdatingLocation];
            /*NSLog(@"%@",[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                         placemark.subThoroughfare, placemark.thoroughfare,
                         placemark.postalCode, placemark.locality,
                         placemark.administrativeArea,
                         placemark.country]);
             */
            
            NSMutableArray *aryCurrentLocation = [[NSMutableArray alloc]init];
            
            [aryCurrentLocation setValue: [NSString stringWithFormat:@"%@,%@",placemark.locality,placemark.country] forKey:@"location"];
            
            [aryCurrentLocation setValue:[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude] forKey:@"longitude"];
            
            
            [aryCurrentLocation setValue:[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude] forKey:@"latitude"];
            

            [[NSUserDefaults standardUserDefaults]setObject:aryCurrentLocation forKey:@"CurrentLocation"];
            
            [[NSUserDefaults standardUserDefaults]synchronize];
            
        }
        else
        {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    txtFld.text = @"";
 //   UIAlertView *errorAlert = [[UIAlertView alloc]
  //                             initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  //  [errorAlert show];
}

#pragma mark =======================
#pragma mark Consumer's view designs
#pragma mark =======================
-(void)designConsumersToolView
{
    
}

-(void)addNewQuestion
{
    //This method will be called when user wants to create a new hotspot on selected Image.
    // Here checking whether the user has already reached the limit of hotspots count(i.e.,9). If he is not adding the new hotspot.

    if([arrQuestions count] >= 3)
    {
        [self showTheAlert:@"No more Question could be added"];
        return;
    }
    
    //Here we are adding new question on selected image.
    
    hotspotConsumerView.hidden = YES;
    

    questionView *questionVw = [[questionView alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
    questionVw.backgroundColor= [UIColor clearColor];
    questionVw.center = CGPointMake(imageBounds.width/2, imageBounds.height/2);
    [questionVw addCircleImage];
    
    
    if(APP_DELEGATE.isPortrait)
    {
        [questionVw setOrientationToPortrait];
    }
    else
    {
        [questionVw setOrientationToLandscape];
    }
    if(imageExactSubView == nil)
        NSLog(@"imageExactSubView is nil");
    [imageExactSubView addSubview:questionVw];
    
    //Here adding pangesture for dragging the question over the image.
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [questionVw addGestureRecognizer:panGesture];
    panGesture = nil;
    
    //Adding tapGesture to select the hotspot among all hotspots added to the image.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(questionTap:)];
    tap.numberOfTapsRequired = 1;
    [questionVw addGestureRecognizer:tap];
    
    questionVw.strQuestionId = [Util GetUUID];
    
    CGRect visibleImageRect = [self getVisibleImageRect1];
    
    
    questionVw.center = CGPointMake(visibleImageRect.origin.x + (visibleImageRect.size.width/2), visibleImageRect.origin.y + (visibleImageRect.size.height/2));
    
    
    for(questionView *questionView in arrQuestions)
    {
        NSLog(@"aHotspot centre - %@", NSStringFromCGPoint(questionView.center));
        NSLog(@" Hotspot centre - %@", NSStringFromCGPoint(questionView.center));
        
        
        if((questionVw.center.x == questionView.center.x) && (questionVw.center.y == questionView.center.y))
        {
            CGPoint centre = questionVw.center;
            
            centre.x += 5.0;
            
            centre.y += 5.0;
            
            [questionVw setCenter:centre];
        }
    }
    
   // float roundedupZoom = ceil([_scrlImgView zoomScale]);
    questionVw.addedInZoomScale =  [_scrlImgView zoomScale];
  //  questionVw.isModified = NO;
    [arrQuestions addObject:questionVw];
    
    hsQuestionView = questionVw;
    [hsQuestionView setWhiteColor];
    
    //As an user can add a hotspot in any zoom level, we are calculating the original centre of hotspot as per image's normal zoom level and setting to its properties.
    
    [self calculatePositionCoordinatesOfSelectedQuestionToPoint:hsQuestionView.center];
    
  //  NSLog(@"hsTag - %@", hsCircleView.strHotspotId);
    
    [self initializeDefault];
}

-(void)calculatePositionCoordinatesOfSelectedQuestionToPoint:(CGPoint)point
{
    CGPoint pointWRTNormalSize;
    CGSize normalBounds;
    if(APP_DELEGATE.isPortrait)
    {
        normalBounds = imgBoundsAtNormalZoomInPortrait;
        [hsQuestionView setOrientationToPortrait];
    }
    else
    {
        normalBounds = imgBoundsAtNormalZoomInLandScape;
        [hsQuestionView setOrientationToLandscape];
        
        
    }
    pointWRTNormalSize.x = (normalBounds.width/imageBounds.width) * point.x;
    pointWRTNormalSize.y = (normalBounds.height/imageBounds.height) * point.y;
    
    
    [hsQuestionView setDefaultCentre:[self getCentreWRTImageSize:pointWRTNormalSize]];

}

-(void)questionTap:(id)sender
{
    
    //Selecting an hotspot event make a call to here to show the hotspot menu and hide the regular menu.
    
    //if snip functionality is already performing, then stopping to edit hotspots.
    if(_cropView.superview)
        return;
   
    hsQuestionView = (questionView*)[sender view];
    NSLog(@"Tag - %@, %li", hsQuestionView.strQuestionId, (long)[sender view].tag);
    
    NSLog(@"audiofilename:%@",hsQuestionView.strAudioFileName);
    
    hsCircleView = nil;
    
    isHotSpotTapped = NO;
    //hotSpotEditToolView.hidden = NO;
    [self showHotspotEditTool];
    
    if(self.source == FROM_PUBLISHER)
    {
        if( hsQuestionView.isUploaded)
        {
            hotSpotTextView.hidden = YES;
             hotspotConsumerView.hidden = NO;
            [self loadPublisherQuestionToolView];
        }
    }
    else
    {
        hotspotConsumerView.hidden = YES;
        if( hsQuestionView.isUploaded)
        {
            [self loadQuestionToolView];
        }
        else
        {
            [self loadNewQuestionToolView];
            
        }
  
    }
    hotSpotLabelView.hidden = YES;
    self.rateView.hidden = YES;
    hotSpotAudioView.hidden = YES;
    hotSpotColorView.hidden = YES;
    hotSpotLinkView.hidden = YES;
  //  _hotspotTitle.text =  hsQuestionView.strLabel ;
    
    if(_hotspotTitle.text.length == 0)
        [_lablePlaceHolder setHidden:NO];
    else
        [_lablePlaceHolder setHidden:YES];
    
    
    [self setDescriptionText:hsQuestionView.strDescText];

    NSLog(@"hsCircleView.strDescText.length - %lu", (unsigned long)hsQuestionView.strDescText.length);
    
    if([_descriptionTxtView.text isEqualToString:@""]|| _descriptionTxtView.text.length == 0)
        _lblPlaceHolder.hidden = NO;
    else
        _lblPlaceHolder.hidden = YES;
    
    [self hideKeyboard];
    if([hsQuestionView.strAudioFileName length] > 0)
    {
        [self.btnRecord setImage:[UIImage imageNamed:@"Play.png"] forState:UIControlStateNormal];
        self.btnDelete.hidden = NO;
        isRecorded = YES;
        
    }
    else
    {
        [self.btnRecord setImage:[UIImage imageNamed:@"Record.png"] forState:UIControlStateNormal];
        isRecorded = NO;
        self.btnDelete.hidden = YES;
        
        
        [audioRecorder stop];
        
        if (audioPlayer) [audioPlayer stop];
        
        if(sliderTimer != nil)
        {
            [sliderTimer invalidate];
            sliderTimer = nil;
        }
        self.sliderAudio.value=0.0;
        
    }
    
    if(_scrlImgView.zoomScale != (float)hsQuestionView.addedInZoomScale)
    {
        [_scrlImgView setZoomScale:(float)hsQuestionView.addedInZoomScale animated:YES];
        
        }
    
    if(hsQuestionView.isInZoomedState)
    {
        hsQuestionView.isInZoomedState = NO;
        [_scrlImgView setZoomScale:_scrlImgView.minimumZoomScale animated:YES];
        
    }
    else
    {
        hsQuestionView.isInZoomedState = YES;
        
        if(_scrlImgView.zoomScale != (float)hsQuestionView.addedInZoomScale)
        {
            [_scrlImgView setZoomScale:(float)hsQuestionView.addedInZoomScale animated:YES];
            
           // [self refreshImageWithHotspots];
        }
    }

        
    [self zoomAndCentreQuestionView:hsQuestionView];

    if(isZoomLocked)
    {
        //Disabling zoom lock
        UIButton *zoomLockBtn = (UIButton*)[self.view viewWithTag:3333];
        [self disableZoomClicked:zoomLockBtn];
    }

}

-(void)updateSelectedQuestionDetails
{
    if(![hsQuestionView.strDescText isEqualToString:_descriptionTxtView.text])
    {
        hsQuestionView.strDescText = _descriptionTxtView.text;
        hsQuestionView.isModified = YES;
        
    }
}

-(void)refreshQuestionsPositionInOrientation
{
    //Here we are repositioning the hotspots in Device Orientation.
    CGSize normalSize, currentSize;
    if(APP_DELEGATE.isPortrait)
    {
        NSLog(@"----Device is in Portrait");
        currentSize = imgBoundsAtNormalZoomInPortrait;
    }
    else
    {
        NSLog(@"---Device is in Landscape");
        
        currentSize = imgBoundsAtNormalZoomInLandScape;
        
        
    }
    NSLog(@"######refreshHotspotsPosition#########");
    NSLog(@"Normal Bounds - %@", NSStringFromCGSize(normalSize));
    NSLog(@"Current Bounds - %@", NSStringFromCGSize(imageBounds));
    
    float imgOriginalWidth;
    
    float imgOriginalHeight;
    
    float imgCurrentWidth = currentSize.width;
    
    float imgCurrentHeight = currentSize.height;
    
    CGPoint defaultCentre;
    
    //For every hotspot, based on its centre and the orientation in which it is added on image, calculating relative point to position hotspot on the image.
    
    for(UIView *aView in imageExactSubView.subviews)
    {
        if([aView isKindOfClass:[questionView class]])
        {
            questionView *question = (questionView*)aView;
            
            if([question isAddedInPortrait])
            {
                NSLog(@"----Hotspot added in Portrait");
                normalSize = imgBoundsAtNormalZoomInPortrait;
            }
            else
            {
                NSLog(@"----Hotspot added in Landscape");
                
                normalSize = imgBoundsAtNormalZoomInLandScape;
                
            }
            NSLog(@"normalSize - %@", NSStringFromCGSize(normalSize));
            
            imgOriginalWidth = normalSize.width;
            imgOriginalHeight = normalSize.height;
            
            defaultCentre = [question getDefaultCentre];
            
            if(question )
                
                NSLog(@">>Default Centre - %@", NSStringFromCGPoint(defaultCentre));
            
            CGPoint newCentre;
            
            //   newCentre.x = (imgCurrentWidth/imgOriginalWidth) * defaultCentre.x;
            
            //   newCentre.y = (imgCurrentHeight/imgOriginalHeight) * defaultCentre.y;
            
            newCentre.x = (imgCurrentWidth/self.pickedImage.size.width) * defaultCentre.x;
            
            newCentre.y = (imgCurrentHeight/self.pickedImage.size.height) * defaultCentre.y;
            
            
            NSLog(@">>2New Centre - %@", NSStringFromCGPoint(newCentre));
            
            [question setCenter:newCentre];
        }
        
    }

}

#pragma mark Question update to server

-(void)uploadQuestionAudioFiles
{
    //Posting audio files of questions recursively in sequence manner.
    
    
    
    if(![arrQuestions count])
    {
        
        return;
    }
    
    [self showLoaderWithTitle:@"Updating post..."];
    questionView *objQuestion = (questionView*)[arrQuestions objectAtIndex:questionAudioIndex];
    
    
    if(objQuestion.strAudioUrl.length > 0)
    {
        NSLog(@"Already existing Audio URL - %@", objQuestion.strAudioUrl);
        //If already having the audio URL...
        questionAudioIndex++;
        
        
        if(questionAudioIndex == [arrQuestions count])
        {
            //Here all the audio file upload completed, then navigating to the assigning hotspots to user's friends screen.
            [self sendNewQuestionToServer];
        }
        else
        {
            //making recursive call over same method to upload audio files.
            [self uploadQuestionAudioFiles];
        }
        
        return;
        
    }
    
    
    
    
    NSLog(@"audioFilePath - %@, index - %li", objQuestion.strAudioFilePath, (long)questionAudioIndex);
    
    if( [arrQuestions count] && [objQuestion.strAudioFilePath length] > 0)
    {
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:ServerURL]];
        
        [manager.requestSerializer setValue:@"RnyooiOS" forHTTPHeaderField:@"x-rnyoo-client"];
        
        [manager.requestSerializer setValue:[Util getNewUserID] forHTTPHeaderField:@"x-rnyoo-uid"];
        
        [manager.requestSerializer setValue:[Util getSessionId] forHTTPHeaderField:@"x-rnyoo-sid"];
        
        [manager.requestSerializer setValue:self.selectedImgId forHTTPHeaderField:@"x-rnyoo-vfid"];
        
        NSLog(@"header - %@", [manager.requestSerializer.HTTPRequestHeaders description]);
        
        NSData *audioData = [NSData dataWithContentsOfFile:objQuestion.strAudioFilePath];
        
        if(audioData == nil)
        {
            NSLog(@"audioData is nil");
            
            if([[NSFileManager defaultManager] fileExistsAtPath:objQuestion.strAudioFilePath])
            {
                NSLog(@"But file existing at path");
            }else
            {
                NSLog(@"Because file doesnot exist");
            }
        }
        
        AFHTTPRequestOperation *op = [manager POST:@"vault/files/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                      {
                                          //do not put image inside parameters dictionary as I did, but append it!
                                          [formData appendPartWithFileData:audioData name:@" vaultfile" fileName:objQuestion.strAudioFileName mimeType:@"audio/m4a"];
                                      } success:^(AFHTTPRequestOperation *operation, id responseObject)
                                      {
                                          
                                          NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
                                          
                                          
                                          objQuestion.strAudioUrl = [responseObject valueForKey:@"vaultfile"];
                                          
                                          //index++;
                                          //[self incrementIndex];
                                          
                                          questionAudioIndex++;
                                          
                                          if(questionAudioIndex == [arrQuestions count])
                                          {
                                              //Here all the audio file upload completed, then navigating to the assigning hotspots to user's friends screen.
                                              [self sendNewQuestionToServer];
                                          }
                                          else
                                          {
                                              //making recursive call over same method to upload audio files.
                                              [self uploadQuestionAudioFiles];
                                          }
                                          
                                      }
                                      
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                      {
                                          /*[self removeLoader];
                                           NSLog(@"Error: %@ ***** %@", operation.responseString, error);
                                           [self showTheAlert:error.description];*/
                                          
                                          questionAudioIndex++;
                                          
                                          if(questionAudioIndex == [arrQuestions count])
                                          {
                                              //Here all the audio file upload completed, then navigating to the assigning hotspots to user's friends screen.
                                              [self sendNewQuestionToServer];
                                          }
                                          else
                                          {
                                              //making recursive call over same method to upload audio files.
                                              [self uploadQuestionAudioFiles];
                                          }
                                          
                                          
                                      }];
        
        [op start];
        
        
        
    }
    else
    {
        //if there is no audio for a particular hotspot, control comes here and try to upload the audio of further hotspots in the array.
        //        index++;
        
        questionAudioIndex++;
        
        if(questionAudioIndex == [arrQuestions count])
        {
            //Here all the audio file upload completed, then navigating to the assigning hotspots to user's friends screen.
            [self sendNewQuestionToServer];
        }
        else
        {
            //making recursive call over same method to upload audio files.
            [self uploadQuestionAudioFiles];
        }

        
    }
    
}

-(void)sendNewQuestionToServer
{
    NSLog(@"postid:%@",self.strPostId);
    
    NSLog(@"%@",hsQuestionView);
    
    NSMutableDictionary *dictQuestion = [[NSMutableDictionary alloc]init];
    
    [dictQuestion setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictQuestion setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictQuestion setValue:self.strPostId forKey:@"rpostid_s"];
    
    NSLog(@"array questions:%@",arrQuestions);
    
    NSMutableArray *aryQuestions =[[NSMutableArray alloc]init];
    
    for(questionView *questionVw in arrQuestions)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];

        [dict setValue:questionVw.strQuestionId forKey:@"questionId"];
        
        [dict setValue:questionVw.strDescText forKey:@"question"];

        
        if([questionVw.strAudioUrl length])
        [dict setValue:questionVw.strAudioUrl forKey:@"audioUrl"];
        else
            [dict setValue:@"" forKey:@"audioUrl"];

        
        
        NSMutableDictionary *dictCoordinates = [[NSMutableDictionary alloc]init];
        
        
        if(questionVw.getDefaultCentre.x)
        {
            [dictCoordinates setValue:[NSNumber numberWithInt:questionVw.getDefaultCentre.x] forKey:@"x"];
        }
        else
            [dictCoordinates setValue:@"0" forKey:@"x"];
        
        
        if(questionVw.getDefaultCentre.y)
        {
            [dictCoordinates setValue:[NSNumber numberWithInt:questionVw.getDefaultCentre.y] forKey:@"y"];
        }
        else
            [dictCoordinates setValue:@"0" forKey:@"y"];
        
        [dict setValue:dictCoordinates forKey:@"location"];
        
        [dict setValue:@"dot" forKey:@"locationMarker"];
        
        if(questionVw.hotspotColor == 1)
            [dict setValue:@"white" forKey:@"locationColor"];
        else if(questionVw.hotspotColor == 2)
            [dict setValue:@"red" forKey:@"locationColor"];
        else if(questionVw.hotspotColor == 3)
            [dict setValue:@"blue" forKey:@"locationColor"];
        else if(questionVw.hotspotColor == 4)
            [dict setValue:@"yellow" forKey:@"locationColor"];
        
        if(questionVw.isUploaded && questionVw.isModified)
        {
            if(arrModifiedQuestions == nil)
                arrModifiedQuestions = [[NSMutableArray alloc] init];
            [arrModifiedQuestions addObject:dict];
        }
        else
        [aryQuestions addObject:dict];
        
        
    }

    [dictQuestion setValue:aryQuestions forKey:@"questionBody"];
    
    NSLog(@"dict:%@",dictQuestion);

    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/questions/new",ServerURL] parameters:dictQuestion success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSLog(@"new question response:%@",responseObject);
         if([[responseObject valueForKey:@"status"] isEqualToString:@"success"])
         {
             hsQuestionView.isUploaded = YES;
             hsQuestionView.isModified = NO;
             
             [Util_HotSpot savequestionsData:dictQuestion];
             //navigate to network screen
             
            

             
         }
         [self updateModifiedQuestionsInserver];
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              NSLog(@"post Error: %@", error);
              [self removeLoader];
              [self showTheAlert:error.description];
              
          }];

  
}

-(void)updateModifiedQuestionsInserver
{
    NSLog(@"postid:%@",self.strPostId);
    
    NSLog(@"%@",hsQuestionView);
    
    
    if(![arrModifiedQuestions count])
    {
        [self deleteQuestionsFromServer];
        return;
    }
    
    NSMutableDictionary *dictQuestion = [[NSMutableDictionary alloc]init];
    
    [dictQuestion setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictQuestion setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictQuestion setValue:self.strPostId forKey:@"rpostid_s"];
    
    NSLog(@"array questions:%@",arrQuestions);
    
    [dictQuestion setValue:arrModifiedQuestions forKey:@"questionBody"];
    
    NSLog(@"dict:%@",dictQuestion);
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/questions/update",ServerURL] parameters:dictQuestion success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSLog(@"update question response:%@",responseObject);
         if([[responseObject valueForKey:@"status"] isEqualToString:@"success"])
         {
             hsQuestionView.isUploaded = YES;
         //    [self updateQuestionwithDict:]
         //    [Util_HotSpot]
       //      [Util_HotSpot savequestionsData:dictQuestion];
             //navigate to network screen
             
             
             
             
         }
         [self deleteQuestionsFromServer];
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              NSLog(@"post Error: %@", error);
              [self removeLoader];
              [self showTheAlert:error.description];
              
          }];
    
    
}

/*-(void)updateQuestionswithDict:(NSDictionary*)dictQuestion
{
    for(NSDictionary *dictQuestionData in arrModifiedQuestions)
    {
        NSManagedObject *objQuestion = [Util_HotSpot getQuestionsDatafromDB:self.strPostId questionId:[dictQuestionData valueForKey:@"questionId"]];
        
        NSDictionary *dictLocation = [dictQuestionData valueForKey:@"location"];

        
        [objQuestion setValue:[dictQuestionData valueForKey:@"questionId"] forKey:@"questionId"];
        
        [objQuestion setValue:[dictQuestionData valueForKey:@"audioUrl"] forKey:@"audioUrl"];
        
        [objQuestion setValue:[dictQuestionData valueForKey:@"locationColor"] forKey:@"locationColor"];
        
        [objQuestion setValue:[dictQuestionData valueForKey:@"locationMarker"] forKey:@"locationMarker"];
        
        [objQuestion setValue:self.strPostId forKey:@"postId"];
        
        [objQuestion setValue:[NSNumber numberWithInteger:[[dictLocation valueForKey:@"x"] integerValue]] forKey:@"xCoordinate"];
        
        [objQuestion setValue:[NSNumber numberWithInteger:[[dictLocation valueForKey:@"y"] integerValue]] forKey:@"yCoordinate"];
        
        [objQuestion setValue:[Util getImgUrl] forKey:@"avatar"];
        
        [objQuestion setValue:[Util getScreenName] forKey:@"screenName_s"];
        
        [objQuestion setValue:[dictQuestionData valueForKey:@"question"] forKey:@"question"];
        
        [objQuestion setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]* 1000] forKey:@"createdAt"];
        
        [objQuestion setValue:@"" forKey:@"postedBy"];
        
        NSError *error= nil;
        if (![context save:&error])
        {
            NSLog(@"Problem saving: %@", [error localizedDescription]);
        }

        
        
    }
}*/
-(void)deleteQuestionsFromServer
{
    
    
    if(![arrDeletedQuestionIds count])
    {
        [self removeLoader];
        NetworkViewController *networkVC = (NetworkViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"Network"];
        
        [self.navigationController pushViewController:networkVC animated:NO];
        return;
    }

    
    
    NSLog(@"postid:%@",self.strPostId);
    
    NSMutableDictionary *dictQuestion = [[NSMutableDictionary alloc]init];
    
    [dictQuestion setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictQuestion setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictQuestion setValue:self.strPostId forKey:@"rpostid_s"];
    
    
    
    [dictQuestion setValue:arrDeletedQuestionIds forKey:@"questions"];
    
    NSLog(@"dict:%@",dictQuestion);
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/questions/delete",ServerURL] parameters:dictQuestion success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSLog(@"new question response:%@",responseObject);
         [self removeLoader];
         
         NetworkViewController *networkVC = (NetworkViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"Network"];
         
         [self.navigationController pushViewController:networkVC animated:NO];
         return;
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              NSLog(@"post Error: %@", error);
              [self removeLoader];
              [self showTheAlert:error.description];
              
          }];
    
    
}



-(void)loadQuestionsofSelectedImg
{
    
    NSLog(@"array questions:%@",aryQuestionComments);
    
    if(![aryQuestionComments count])
                return;
    [self loadQuestions:aryQuestionComments];

//    NSArray *aryQuestionsData = [Util_HotSpot getQuestionsDatafromDB:self.strPostId];
//
//    if(![aryQuestionsData count])
//        return;
//    
//    [self loadQuestions:aryQuestionComments];
    
}

-(void)loadQuestions:(NSArray*)aryQuestions
{
    
    NSString *strColor = @"";
    

    if([[aryQuestions objectAtIndex:0] isKindOfClass:[NSDictionary class]])
    {
        for(NSMutableDictionary *questionInfo in aryQuestions)
        {
            NSLog(@"hotspotInfo - %@", [questionInfo description]);
            
            NSMutableDictionary *dict = [questionInfo valueForKey:@"location"];
            
            CGPoint centre = CGPointMake([[dict valueForKey:@"x"] integerValue], [[dict valueForKey:@"y"] integerValue]);
            questionView *questionVw = [[questionView alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
            questionVw.backgroundColor= [UIColor clearColor];
            [questionVw addCircleImage];
            
            [questionVw setDefaultCentre:centre];
            
            questionVw.strQuestionId  = [questionInfo valueForKey:@"questionId"];
            
            questionVw.strDescText = [questionInfo valueForKey:@"question"];
            
            
            questionVw.strAudioUrl = [questionInfo valueForKey:@"audioUrl"];
            questionVw.strAudioFilePath = [questionInfo valueForKey:@"audioUrl"];

            //    hotSpot.strLabel = [hotspotInfo valueForKey:@"hotspotLabel"];
            //    hotSpot.strDescText = [hotspotInfo valueForKey:@"strDescription"];
            //     hotSpot.strUrlText = [hotspotInfo valueForKey:@"clickUrl"];
            questionVw.isSaved = YES;
            
            //       NSLog(@"Hotspot desc - %@ , %@", [hotspotInfo valueForKey:@"hotspotLabel"],[hotspotInfo valueForKey:@"clickUrl"]);
            
            if([questionVw.strUrlText isEqualToString:@""])
                questionVw.strUrlText = @"http://www.";
            
            if(![questionVw.strDescText isEqualToString:@""])
                [questionVw updateTitle:questionVw.strDescText];
            
            strColor = [[questionInfo valueForKey:@"locationColor"] lowercaseString];
            questionVw.isUploaded = YES;
            
            questionVw.backgroundColor= [UIColor clearColor];
            [questionVw addCircleImage];
            
            [questionVw setDefaultCentre:centre];
            
            
            
            questionVw.isUploaded = YES;
            
       //    NSLog(@"audio filename:%@",hotSpot.strAudioFileName);
            
            
            CGSize imagSize;
            imagSize = CGSizeMake(self.pickedImage.size.width, self.pickedImage.size.height);
            
            CGPoint newCentre;
            if(APP_DELEGATE.isPortrait)
            {
                
                
                newCentre.x = (imgBoundsAtNormalZoomInPortrait.width / imagSize.width) * centre.x;
                newCentre.y = (imgBoundsAtNormalZoomInPortrait.height / imagSize.height) * centre.y;
                
            }
            else
            {
                newCentre.x = (imgBoundsAtNormalZoomInLandScape.width / imagSize.width) * centre.x;
                newCentre.y = (imgBoundsAtNormalZoomInLandScape.height / imagSize.height) * centre.y;
            }
            
            questionVw.center = newCentre;
            
            questionVw.isSaved = YES;
            if(imageExactSubView == nil)
                NSLog(@"imageExactSubView is nil");
            [imageExactSubView addSubview:questionVw];
            
            //Here adding pangesture for dragging the Hotspot over the image.
            
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
            [panGesture setMinimumNumberOfTouches:1];
            [panGesture setMaximumNumberOfTouches:1];
            [questionVw addGestureRecognizer:panGesture];
            panGesture = nil;
            
            //Adding tapGesture to select the hotspot among all hotspots added to the image.
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(questionTap:)];
            tap.numberOfTapsRequired = 1;
            [questionVw addGestureRecognizer:tap];
            
            [self.arrQuestions addObject:questionVw];
            
            [questionVw setTag:[self.arrQuestions count]];
            
            
            
            
            NSLog(@"prestrColor - %@", strColor);
            
            if([strColor isEqualToString:@"red"])
            {
                NSLog(@"strColor - %@", strColor);
                
                [questionVw setRedColor];
            }
            else if ([strColor isEqualToString:@"white"])
            {
                NSLog(@"strColor - %@", strColor);
                
                [questionVw setWhiteColor];
                
            }
            else if ([strColor isEqualToString:@"blue"])
            {
                NSLog(@"strColor - %@", strColor);
                
                [questionVw setBlueColor];
                
            } else if ([strColor isEqualToString:@"yellow"])
            {
                NSLog(@"strColor - %@", strColor);
                
                [questionVw setYellowColor];
                
            }
            else
            {
                NSLog(@"strColor - %@", strColor);
                
                [questionVw setWhiteColor];
                
            }

        }

    }
    else {
  
    for(NSManagedObject *hotspotInfo in aryQuestions)
    {
        NSLog(@"hotspotInfo - %@", [hotspotInfo description]);
        CGPoint centre;
        
        
        questionView *hotSpot = [[questionView alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
        
        if([hotspotInfo isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dictLoc = [hotspotInfo valueForKey:@"location"];
            centre = CGPointMake([[dictLoc valueForKey:@"x"] integerValue], [[dictLoc valueForKey:@"y"] integerValue]);
            hotSpot.strDescText = [hotspotInfo valueForKey:@"hotspotLabel"];
            
        }
        else
        {
            centre = CGPointMake([[hotspotInfo valueForKey:@"xCoordinate"] integerValue], [[hotspotInfo valueForKey:@"yCoordinate"] integerValue]);
            hotSpot.strDescText = [hotspotInfo valueForKey:@"question"];
            hotSpot.strAudioFilePath = [hotspotInfo valueForKey:@"audioUrl"];
            hotSpot.strQuestionId = [hotspotInfo valueForKey:@"questionId"];
            
//            if([[hotspotInfo valueForKey:@"orientation"] isEqualToString:@"portrait"])
//            {
//                [hotSpot setOrientationToPortrait];
//            }
//            else
//            {
//                [hotSpot setOrientationToLandscape];
//            }
            strColor = [[hotspotInfo valueForKey:@"locationColor"] lowercaseString];
            
            
        }
        
        hotSpot.backgroundColor= [UIColor clearColor];
        [hotSpot addCircleImage];
        
        [hotSpot setDefaultCentre:centre];
        
        if(![hotSpot.strDescText isEqualToString:@""])
            [hotSpot updateTitle:hotSpot.strDescText];
        
        
        if([hotSpot.strUrlText isEqualToString:@""])
            hotSpot.strUrlText = @"http://www.";
        
        
        hotSpot.isUploaded = YES;
        
        NSLog(@"audio filename:%@",hotSpot.strAudioFileName);
        
        
        CGSize imagSize;
        imagSize = CGSizeMake(self.pickedImage.size.width, self.pickedImage.size.height);
        
        CGPoint newCentre;
        if(APP_DELEGATE.isPortrait)
        {
            
            
            newCentre.x = (imgBoundsAtNormalZoomInPortrait.width / imagSize.width) * centre.x;
            newCentre.y = (imgBoundsAtNormalZoomInPortrait.height / imagSize.height) * centre.y;
            
        }
        else
        {
            newCentre.x = (imgBoundsAtNormalZoomInLandScape.width / imagSize.width) * centre.x;
            newCentre.y = (imgBoundsAtNormalZoomInLandScape.height / imagSize.height) * centre.y;
        }
        
        hotSpot.center = newCentre;
        
        hotSpot.isSaved = YES;
        if(imageExactSubView == nil)
            NSLog(@"imageExactSubView is nil");
        [imageExactSubView addSubview:hotSpot];
        
        //Here adding pangesture for dragging the Hotspot over the image.
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        [hotSpot addGestureRecognizer:panGesture];
        panGesture = nil;
        
        //Adding tapGesture to select the hotspot among all hotspots added to the image.
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(questionTap:)];
        tap.numberOfTapsRequired = 1;
        [hotSpot addGestureRecognizer:tap];
        
        [self.arrQuestions addObject:hotSpot];
        
        [hotSpot setTag:[self.arrQuestions count]];
        
        
        
        NSLog(@"prestrColor - %@", strColor);
        
        if([strColor isEqualToString:@"red"])
        {
            NSLog(@"strColor - %@", strColor);
            
            [hotSpot setRedColor];
        }
        else if ([strColor isEqualToString:@"white"])
        {
            NSLog(@"strColor - %@", strColor);
            
            [hotSpot setWhiteColor];
            
        }
        else if ([strColor isEqualToString:@"blue"])
        {
            NSLog(@"strColor - %@", strColor);
            
            [hotSpot setBlueColor];
            
        } else if ([strColor isEqualToString:@"yellow"])
        {
            NSLog(@"strColor - %@", strColor);
            
            [hotSpot setYellowColor];
            
        }
        else
        {
            NSLog(@"strColor - %@", strColor);
            
            [hotSpot setWhiteColor];
            
        }
        
       
    }
    }
    
}

-(void)navigateToCommentsScreen
{
    CommentsViewController *commentsVC = (CommentsViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"Comment"];
 
    NSLog(@"questionId:%@",hsQuestionView.strQuestionId);
    
    commentsVC.hsQuestionView = hsQuestionView;
    commentsVC.strPostId = self.strPostId;
    commentsVC.aryQuestions = self.aryQuestionComments;
    [self.navigationController pushViewController:commentsVC animated:NO];
}

-(void)navigateToHotspotCommentsScreen
{
    HotspotCommentViewController *commentsVC = (HotspotCommentViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"Hotspot Comment"];
    
    commentsVC.strHotspotId = hsCircleView.strHotspotId;
    commentsVC.strPostId = self.strPostId;
    commentsVC.strPodId = self.strPodId;
    commentsVC.aryComments =self.aryHotspotComments;
    
    commentsVC.objHsCircleView = hsCircleView;
    commentsVC.numberOfRatings = hsCircleView.numberofRatings;
  //  commentsVC.numberofRatings = numberOfRatings;
    
    [self.navigationController pushViewController:commentsVC animated:NO];
}

-(void)loadimagesForRating
{
    [self hideKeyboard];
    
    if(self.source == FROM_CONSUMER && isHotSpotTapped )
    {
        self.rateView.notSelectedImage = [UIImage imageNamed:@"rating_unselected.png"];
        self.rateView.fullSelectedImage = [UIImage imageNamed:@"rating_selected.png"];
        
     //  self.rateView.rating =  hsCircleView.numberofRatings;
       
        NSArray *aryHotspoComments = [self.aryHotspotComments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hotspotId == %@",hsCircleView.strHotspotId]];
        if([aryHotspoComments count])
        {
            self.rateView.rating = [[[aryHotspoComments objectAtIndex:0]valueForKey:@"rating"]integerValue];
            hsCircleView.numberofRatings = [[[aryHotspoComments objectAtIndex:0]valueForKey:@"rating"]integerValue];

        }
        else
        {
            self.rateView.rating = 0;
            hsCircleView.numberofRatings = 0;
        }
      //  self.rateView.rating = hsCircleView.numberofRatings;
        self.rateView.editable = YES;
        self.rateView.maxRating = 5;
        self.rateView.delegate = self;
    }
    
}

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating
{
   NSLog(@"rating:%@",[NSString stringWithFormat:@"Rating: %f", rating]);
    
 //   numberOfRatings =rating;
    hsCircleView.numberofRatings = rating;
    [self rateHotspot];
}

- (void)viewDidUnload
{
    [self setRateView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

# pragma consumerview hotspot actions
- (IBAction)btnRateClicked:(id)sender
{
    if(self.source == FROM_PUBLISHER && hsQuestionView.isUploaded )
    {
        [self navigateToCommentsScreen];
        return;
    }
    [self showHotspotEditTool];
    hotSpotEditToolView.hidden = YES;

    self.rateView.hidden = NO;
    [self loadimagesForRating];
}

- (IBAction)btnAudioClicked:(id)sender
{
    if(self.source == FROM_PUBLISHER && hsQuestionView.isUploaded)
    {
        for(questionView *objCircle in arrQuestions)
        {
            if([objCircle.strQuestionId isEqualToString:hsQuestionView.strQuestionId])
            {
                [arrQuestions removeObject:objCircle];
                break;
            }
        }
        [hsQuestionView removeFromSuperview];
        hsQuestionView = nil;
        
        hotspotConsumerView.hidden = YES;
        hotSpotEditToolView.hidden = YES;

        return;
    }
    self.rateView.hidden = YES;
    [self showHotspotEditTool];
    [self initializeAudio];

}

- (IBAction)btnCommentClicked:(id)sender
{
    if(self.source == FROM_PUBLISHER && hsQuestionView.isUploaded)
    {
           //convert question to hotspot
        [self changeQuestionToHotspot];
        return;
     
    }
    [self navigateToHotspotCommentsScreen];
    
}


-(void)rateHotspot
{
    NSLog(@"showloader2");

    [self showLoader];
    NSMutableDictionary *dictPostComments = [[NSMutableDictionary alloc]init];
    
    [dictPostComments setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictPostComments setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictPostComments setValue:self.strPostId forKey:@"rpostid_s"];
    
    [dictPostComments setValue:[Util getScreenName] forKey:@"screenName_s"];
    
    [dictPostComments setValue:self.strPodId forKey:@"rpid_s"];
    
    NSMutableDictionary *dictHotspot = [[NSMutableDictionary alloc]init];
    
    [dictHotspot setValue:hsCircleView.strHotspotId forKey:@"hotspotId"];
    
    [dictHotspot setValue:[NSNumber numberWithInteger:hsCircleView.numberofRatings] forKey:@"rating"];

    NSMutableArray *aryHotspots = [[NSMutableArray alloc]init];
    [aryHotspots addObject:dictHotspot];
    [dictPostComments setValue:aryHotspots forKey:@"hotspotRatings"];
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/pods/hotspots/ratings/new",ServerURL] parameters:dictPostComments success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSLog(@"post hotspot rating response:%@",responseObject);
         [self removeLoader];
         
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              NSLog(@"post  hotspot rating Error: %@", error);
              [self removeLoader];
              
              
          }];
    

}

-(void)changeQuestionToHotspot
{
    isQuestionChangedToHS = YES;
    [self addNewHotspot];
    
    [aryConvertedQuestions addObject:hsQuestionView.strQuestionId];
    
    [hsQuestionView removeFromSuperview];
    hsQuestionView = nil;
    hotspotConsumerView.hidden = YES;
}

-(void)navigatewithURL:(NSString*)strUrl
{
    NSURL *url = [ [ NSURL alloc ] initWithString: strUrl];
    
    BOOL res = [[UIApplication sharedApplication] canOpenURL:url];

     if(res)
         [[UIApplication sharedApplication] openURL:url];
}

-(void)deletePublisherQuestions
{

    NSLog(@"postid:%@",self.strPostId);
    
    NSMutableDictionary *dictQuestion = [[NSMutableDictionary alloc]init];
    
    [dictQuestion setValue:[Util getNewUserID] forKey:@"uid_s"];
    
    [dictQuestion setValue:[Util getSessionId] forKey:@"sid"];
    
    [dictQuestion setValue:self.strPostId forKey:@"rpostid_s"];
    
    
    [dictQuestion setValue:aryConvertedQuestions forKey:@"questions"];
    
    NSLog(@"dict:%@",dictQuestion);
    
    AFHTTPRequestOperationManager *manager = [Util getAppPostOperationRequestManager];
    
    [manager POST:[NSString stringWithFormat:@"%@/posts/questions/delete",ServerURL] parameters:dictQuestion success:^(AFHTTPRequestOperation *operation, id responseObject)
     
     {
         NSLog(@"new question response:%@",responseObject);
         [self removeLoader];
         
       //  [self navigateToPostViewController];
         [self uploadVaultAndMediaFiles];

         return;
         
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
              NSLog(@"post Error: %@", error);
              [self removeLoader];
              [self showTheAlert:error.description];
              
          }];
    

}
@end